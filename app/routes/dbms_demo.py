from flask import Blueprint, render_template, request, flash, redirect, url_for, session
from app.db import get_db, query
from functools import wraps
from mysql.connector import Error as MySQLError

dbms_bp = Blueprint("dbms", __name__)

# --- Login required for this whole demo section ---
def login_required(view):
    @wraps(view)
    def wrapper(*a, **kw):
        if "emp_id" not in session:
            return redirect(url_for("auth.login"))
        return view(*a, **kw)
    return wrapper

# --- FIXED: Reusable function to run demo queries ---
def run_demo_query(sql, params=(), fetch=False):
    """
    Runs a query. 
    If fetch=True, returns headers and rows.
    If fetch=False, commits the transaction (for UPDATE/INSERT/DELETE).
    """
    try:
        db = get_db()
        cur = db.cursor(dictionary=True)
        cur.execute(sql, params)
        
        if fetch:
            # This is a SELECT query
            rows = cur.fetchall()
            # FIX: Check if cur.description is None (e.g., for empty results)
            headers = [col[0] for col in cur.description] if cur.description else []
            cur.close()
            return {"sql": sql, "headers": headers, "rows": rows, "error": None}
        else:
            # This is an UPDATE, INSERT, or DELETE
            # FIX: Added db.commit()
            db.commit()
            cur.close()
            # FIX: Don't try to read headers when there are none
            return {"sql": sql, "headers": [], "rows": [], "error": None}
            
    except MySQLError as e:
        return {"sql": sql, "headers": [], "rows": [], "error": str(e)}

# --- Main Page ---
@dbms_bp.route("/")
@login_required
def index():
    # Pass in default data to pre-populate forms
    defaults = {
        "project_id": 201,
        "ticket_id": 703, # A ticket that is 'In Progress'
        "project_to_complete": 202 # A project with an end_date in the past
    }
    return render_template("dbms_demo.html", defaults=defaults)

# --- 1. Triggers ---
@dbms_bp.route("/demo-trigger-efficiency", methods=["POST"])
@login_required
def demo_trigger_efficiency():
    project_id = request.form.get("project_id", 201)
    new_cost = request.form.get("actual_cost", 1000000)
    
    # 1. Get "Before" state
    before = run_demo_query("SELECT project_id, projected_cost, actual_cost, efficiency FROM project_costs WHERE project_id = %s", (project_id,), fetch=True)
    
    # 2. Run the UPDATE
    #    FIX: Added fetch=False to commit the change
    update_result = run_demo_query("UPDATE project_costs SET actual_cost = %s WHERE project_id = %s", (new_cost, project_id), fetch=False)
    
    # 3. Get "After" state
    after = run_demo_query("SELECT project_id, projected_cost, actual_cost, efficiency FROM project_costs WHERE project_id = %s", (project_id,), fetch=True)
    
    flash("Trigger 'trig_calc_efficiency_before_update' executed.", "success")
    return render_template("dbms_demo.html", result_trigger_efficiency={"before": before, "after": after})

@dbms_bp.route("/demo-trigger-ticket", methods=["POST"])
@login_required
def demo_trigger_ticket():
    ticket_id = request.form.get("ticket_id", 703)
    
    before = run_demo_query("SELECT * FROM ticket_solutions WHERE ticket_id = %s", (ticket_id,), fetch=True)
    # FIX: Added fetch=False
    run_demo_query("UPDATE tickets SET status = 'resolved' WHERE ticket_id = %s", (ticket_id,), fetch=False)
    after = run_demo_query("SELECT * FROM ticket_solutions WHERE ticket_id = %s", (ticket_id,), fetch=True)
    
    # Reset for next demo (FIX: Added fetch=False)
    run_demo_query("UPDATE tickets SET status = 'In Progress' WHERE ticket_id = %s", (ticket_id,), fetch=False)
    run_demo_query("DELETE FROM ticket_solutions WHERE ticket_id = %s", (ticket_id,), fetch=False)

    flash("Trigger 'trig_auto_ticket_solution' executed.", "success")
    return render_template("dbms_demo.html", result_trigger_ticket={"before": before, "after": after})

@dbms_bp.route("/demo-trigger-status", methods=["POST"])
@login_required
def demo_trigger_status():
    project_id = request.form.get("project_id", 201)
    
    before = run_demo_query("SELECT * FROM project_updates WHERE project_id = %s ORDER BY update_id DESC", (project_id,), fetch=True)
    # FIX: Added fetch=False
    run_demo_query("UPDATE projects SET status = 'Completed' WHERE project_id = %s", (project_id,), fetch=False)
    after = run_demo_query("SELECT * FROM project_updates WHERE project_id = %s ORDER BY update_id DESC", (project_id,), fetch=True)
    
    # Reset for next demo (FIX: Added fetch=False)
    run_demo_query("UPDATE projects SET status = 'In Progress' WHERE project_id = %s", (project_id,), fetch=False)

    flash("Trigger 'trig_project_status_change' executed.", "success")
    return render_template("dbms_demo.html", result_trigger_status={"before": before, "after": after})

# --- 2. Procedures ---
@dbms_bp.route("/demo-proc-add-project", methods=["POST"])
@login_required
def demo_proc_add_project():
    project_id = request.form["project_id"]
    try:
        db = get_db()
        cur = db.cursor()
        cur.callproc("add_project", (
            project_id,
            request.form["name"],
            request.form["start_date"],
            request.form["end_date"],
            request.form["dept_id"],
            request.form["summary"]
        ))
        db.commit()
        cur.close()
        flash(f"Success! Project {project_id} added.", "success")
        
        # Clean up the demo data (FIX: Added fetch=False)
        run_demo_query("DELETE FROM projects WHERE project_id = %s", (project_id,), fetch=False)
        
    except MySQLError as e:
        flash(f"SQL Error: {e.msg}", "danger")
        
    return redirect(url_for("dbms.index"))

@dbms_bp.route("/demo-proc-report", methods=["POST"])
@login_required
def demo_proc_report():
    project_id = request.form.get("project_id", 201)
    
    try:
        db = get_db()
        cur = db.cursor(dictionary=True)
        cur.callproc("get_project_report", (project_id,))
        
        results = None
        for result in cur.stored_results():
            rows = result.fetchall()
            if rows:
                results = {"rows": rows, "headers": rows[0].keys(), "sql": f"CALL get_project_report({project_id})"}
        cur.close()
        
        flash("Procedure 'get_project_report' executed.", "success")
        return render_template("dbms_demo.html", result_proc_report=results)
        
    except MySQLError as e:
        flash(f"SQL Error: {e.msg}", "danger")
        return redirect(url_for("dbms.index"))

@dbms_bp.route("/demo-proc-close", methods=["POST"])
@login_required
def demo_proc_close():
    before = run_demo_query("SELECT project_id, summary FROM projects WHERE end_date < CURDATE()", fetch=True)
    
    try:
        db = get_db()
        cur = db.cursor()
        cur.callproc("close_completed_projects")
        db.commit()
        cur.close()
        flash("Procedure 'close_completed_projects' executed.", "success")
    except MySQLError as e:
        flash(f"SQL Error: {e.msg}", "danger")
        
    after = run_demo_query("SELECT project_id, summary FROM projects WHERE end_date < CURDATE()", fetch=True)
    return render_template("dbms_demo.html", result_proc_close={"before": before, "after": after})

# --- 3. Functions ---
@dbms_bp.route("/demo-func-efficiency", methods=["POST"])
@login_required
def demo_func_efficiency():
    project_id = request.form.get("project_id", 201)
    result = run_demo_query("SELECT get_project_efficiency(%s) AS efficiency", (project_id,), fetch=True)
    flash("Function 'get_project_efficiency' executed.", "success")
    return render_template("dbms_demo.html", result_func_efficiency=result)
    
@dbms_bp.route("/demo-func-tickets", methods=["POST"])
@login_required
def demo_func_tickets():
    project_id = request.form.get("project_id", 201)
    result = run_demo_query("SELECT total_tickets(%s) AS total_tickets", (project_id,), fetch=True)
    flash("Function 'total_tickets' executed.", "success")
    return render_template("dbms_demo.html", result_func_tickets=result)

@dbms_bp.route("/demo-func-ratio", methods=["POST"])
@login_required
def demo_func_ratio():
    project_id = request.form.get("project_id", 201)
    result = run_demo_query("SELECT ticket_resolution_ratio(%s) AS resolution_ratio", (project_id,), fetch=True)
    flash("Function 'ticket_resolution_ratio' executed.", "success")
    return render_template("dbms_demo.html", result_func_ratio=result)

# --- 4. Complex Queries ---
@dbms_bp.route("/demo-query-nested", methods=["GET"])
@login_required
def demo_query_nested():
    sql = "SELECT d.name, d.dept_id FROM department d WHERE d.dept_id = (SELECT dept_id FROM projects GROUP BY dept_id ORDER BY COUNT(*) DESC LIMIT 1)"
    result = run_demo_query(sql, fetch=True)
    flash("Nested Query executed.", "success")
    return render_template("dbms_demo.html", result_query_nested=result)

@dbms_bp.route("/demo-query-join", methods=["GET"])
@login_required
def demo_query_join():
    sql = "SELECT t.ticket_id, t.title, t.status, t.date_raised, p.name AS project FROM tickets t JOIN projects p ON t.project_id = p.project_id WHERE t.status <> 'Resolved' LIMIT 5"
    result = run_demo_query(sql, fetch=True)
    flash("Join Query executed.", "success")
    return render_template("dbms_demo.html", result_query_join=result)

@dbms_bp.route("/demo-query-aggregate", methods=["GET"])
@login_required
def demo_query_aggregate():
    sql = "SELECT p.name, pc.projected_cost FROM projects p JOIN project_costs pc ON p.project_id = pc.project_id ORDER BY pc.projected_cost DESC LIMIT 5"
    result = run_demo_query(sql, fetch=True)
    flash("Aggregate Query executed.", "success")
    return render_template("dbms_demo.html", result_query_aggregate=result)