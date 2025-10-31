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

# --- Reusable function to run demo queries ---
def run_demo_query(sql, params=(), fetch=False):
    try:
        db = get_db()
        cur = db.cursor(dictionary=True)
        cur.execute(sql, params)
        
        if fetch:
            rows = cur.fetchall()
            headers = [col[0] for col in cur.description] if cur.description else []
            cur.close()
            return {"sql": sql, "headers": headers, "rows": rows, "error": None}
        else:
            db.commit()
            cur.close()
            return {"sql": sql, "headers": [], "rows": [], "error": None}
            
    except MySQLError as e:
        return {"sql": sql, "headers": [], "rows": [], "error": str(e)}

# --- Main Page ---
@dbms_bp.route("/")
@login_required
def index():
    defaults = {
        "project_id": 201,
        "ticket_id": 703,
        "project_to_complete": 202
    }
    return render_template("dbms_demo.html", defaults=defaults)

# --- 1. Triggers ---
@dbms_bp.route("/demo-trigger-efficiency", methods=["POST"])
@login_required
def demo_trigger_efficiency():
    project_id = int(request.form.get("project_id", 201))
    new_cost = float(request.form.get("actual_cost", 1000000))
    
    run_demo_query("SELECT project_id, projected_cost, actual_cost, efficiency FROM project_costs WHERE project_id = %s", (project_id,), fetch=True)
    run_demo_query("UPDATE project_costs SET actual_cost = %s WHERE project_id = %s", (new_cost, project_id), fetch=False)
    
    flash("Trigger 'trig_calc_efficiency_before_update' executed.", "success")
    return redirect(url_for("dashboard.dashboard"))

@dbms_bp.route("/demo-trigger-ticket", methods=["POST"])
@login_required
def demo_trigger_ticket():
    ticket_id = int(request.form.get("ticket_id", 703))
    
    run_demo_query("UPDATE tickets SET status = 'resolved' WHERE ticket_id = %s", (ticket_id,), fetch=False)
    
    # Reset for next demo
    run_demo_query("UPDATE tickets SET status = 'In Progress' WHERE ticket_id = %s", (ticket_id,), fetch=False)
    run_demo_query("DELETE FROM ticket_solutions WHERE ticket_id = %s", (ticket_id,), fetch=False)

    flash("Trigger 'trig_auto_ticket_solution' executed (and reset).", "success")
    return redirect(url_for("dashboard.dashboard"))

@dbms_bp.route("/demo-trigger-status", methods=["POST"])
@login_required
def demo_trigger_status():
    project_id = int(request.form.get("project_id", 201))
    
    run_demo_query("UPDATE projects SET status = 'Completed' WHERE project_id = %s", (project_id,), fetch=False)
    
    # Reset for next demo
    run_demo_query("UPDATE projects SET status = 'In Progress' WHERE project_id = %s", (project_id,), fetch=False)

    flash("Trigger 'trig_project_status_change' executed (and reset).", "success")
    return redirect(url_for("dashboard.dashboard"))

# --- 2. Procedures ---
@dbms_bp.route("/demo-proc-add-project", methods=["POST"])
@login_required
def demo_proc_add_project():
    project_id = int(request.form["project_id"])
    dept_id = int(request.form["dept_id"])
    
    try:
        db = get_db()
        cur = db.cursor()
        cur.callproc("add_project", (
            project_id,
            request.form["name"],
            request.form["start_date"],
            request.form["end_date"],
            dept_id,
            request.form["summary"]
        ))
        
        for result in cur.stored_results():
            pass
        
        db.commit()
        cur.close()
        flash(f"Success! Procedure 'add_project' ran for Project {project_id}.", "success")
        
        run_demo_query("DELETE FROM projects WHERE project_id = %s", (project_id,), fetch=False)
        
    except MySQLError as e:
        flash(f"SQL Error: {e.msg}", "danger")
        
    return redirect(url_for("dashboard.dashboard"))

@dbms_bp.route("/demo-proc-report", methods=["POST"])
@login_required
def demo_proc_report():
    project_id = int(request.form.get("project_id", 201))
    
    try:
        db = get_db()
        cur = db.cursor(dictionary=True)
        cur.callproc("get_project_report", (project_id,))
        for result in cur.stored_results():
            pass # Consume results
        cur.close()
        flash("Procedure 'get_project_report' executed.", "success")
    except MySQLError as e:
        flash(f"SQL Error: {e.msg}", "danger")
        
    return redirect(url_for("dashboard.dashboard"))

@dbms_bp.route("/demo-proc-close", methods=["POST"])
@login_required
def demo_proc_close():
    try:
        db = get_db()
        cur = db.cursor()
        cur.callproc("close_completed_projects")
        for result in cur.stored_results():
            pass
        db.commit()
        cur.close()
        flash("Procedure 'close_completed_projects' executed.", "success")
    except MySQLError as e:
        flash(f"SQL Error: {e.msg}", "danger")
        
    return redirect(url_for("dashboard.dashboard"))

# --- 3. Functions ---
@dbms_bp.route("/demo-func-efficiency", methods=["POST"])
@login_required
def demo_func_efficiency():
    project_id = int(request.form.get("project_id", 201))
    run_demo_query("SELECT get_project_efficiency(%s) AS efficiency", (project_id,), fetch=True)
    flash("Function 'get_project_efficiency' executed.", "success")
    return redirect(url_for("dashboard.dashboard"))
    
@dbms_bp.route("/demo-func-tickets", methods=["POST"])
@login_required
def demo_func_tickets():
    project_id = int(request.form.get("project_id", 201))
    run_demo_query("SELECT total_tickets(%s) AS total_tickets", (project_id,), fetch=True)
    flash("Function 'total_tickets' executed.", "success")
    return redirect(url_for("dashboard.dashboard"))

@dbms_bp.route("/demo-func-ratio", methods=["POST"])
@login_required
def demo_func_ratio():
    project_id = int(request.form.get("project_id", 201))
    run_demo_query("SELECT ticket_resolution_ratio(%s) AS resolution_ratio", (project_id,), fetch=True)
    flash("Function 'ticket_resolution_ratio' executed.", "success")
    return redirect(url_for("dashboard.dashboard"))

# --- 4. Complex Queries ---
@dbms_bp.route("/demo-query-nested", methods=["GET"])
@login_required
def demo_query_nested():
    sql = "SELECT d.name, d.dept_id FROM department d WHERE d.dept_id = (SELECT dept_id FROM projects GROUP BY dept_id ORDER BY COUNT(*) DESC LIMIT 1)"
    run_demo_query(sql, fetch=True)
    flash("Nested Query executed.", "success")
    return redirect(url_for("dashboard.dashboard"))

@dbms_bp.route("/demo-query-join", methods=["GET"])
@login_required
def demo_query_join():
    sql = "SELECT t.ticket_id, t.title, t.status, t.date_raised, p.name AS project FROM tickets t JOIN projects p ON t.project_id = p.project_id WHERE t.status <> 'Resolved' LIMIT 5"
    run_demo_query(sql, fetch=True)
    flash("Join Query executed.", "success")
    return redirect(url_for("dashboard.dashboard"))

@dbms_bp.route("/demo-query-aggregate", methods=["GET"])
@login_required
def demo_query_aggregate():
    sql = "SELECT p.name, pc.projected_cost FROM projects p JOIN project_costs pc ON p.project_id = pc.project_id ORDER BY pc.projected_cost DESC LIMIT 5"
    run_demo_query(sql, fetch=True)
    flash("Aggregate Query executed.", "success")
    return redirect(url_for("dashboard.dashboard"))