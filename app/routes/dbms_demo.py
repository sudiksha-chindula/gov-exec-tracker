from flask import Blueprint, render_template, request, flash, redirect, url_for, session
from app.db import get_db, query
from functools import wraps
from mysql.connector import Error as MySQLError

# --- Use your existing auth decorators ---
from .auth import login_required, role_required

dbms_bp = Blueprint("dbms", __name__, url_prefix="/dbms")

# --- Helper Function ---
def run_query_and_get_results(sql, params=()):
    """
    A helper function to run a query and return the
    exact dictionary format your HTML macro expects.
    """
    try:
        db = get_db()
        cur = db.cursor(dictionary=True)
        cur.execute(sql, params)
        
        if sql.strip().upper().startswith("SELECT"):
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
    # This is the main page that renders the HTML.
    # It pulls all results from the session, passes them to the template,
    # and then clears them.
    
    defaults = {
        "project_id": 201,
        "ticket_id": 703,
        "project_to_complete": 202 
    }
    
    # Gather all possible results from the session
    results = {
        "result_trigger_efficiency": session.pop("result_trigger_efficiency", None),
        "result_trigger_ticket": session.pop("result_trigger_ticket", None),
        "result_trigger_status": session.pop("result_trigger_status", None),
        "result_proc_report": session.pop("result_proc_report", None),
        "result_proc_close": session.pop("result_proc_close", None),
        "result_func_efficiency": session.pop("result_func_efficiency", None),
        "result_func_tickets": session.pop("result_func_tickets", None),
        "result_func_ratio": session.pop("result_func_ratio", None),
        "result_query_nested": session.pop("result_query_nested", None),
        "result_query_join": session.pop("result_query_join", None),
        "result_query_aggregate": session.pop("result_query_aggregate", None),
    }

    return render_template("dbms_demo.html", defaults=defaults, **results)

# --- 1. Triggers ---
@dbms_bp.route("/demo-trigger-efficiency", methods=["POST"])
@login_required
def demo_trigger_efficiency():
    project_id = int(request.form.get("project_id", 201))
    new_cost = float(request.form.get("actual_cost", 15000000))
    
    # 1. Get 'Before' state
    before_sql = "SELECT project_id, projected_cost, actual_cost, efficiency FROM project_costs WHERE project_id = %s"
    before_result = run_query_and_get_results(before_sql, (project_id,))
    
    # 2. Run the UPDATE that fires the trigger
    query("UPDATE project_costs SET actual_cost = %s WHERE project_id = %s", (new_cost, project_id), fetch=False)
    
    # 3. Get 'After' state
    after_result = run_query_and_get_results(before_sql, (project_id,))
    
    # 4. Save results to session and redirect
    session["result_trigger_efficiency"] = {"before": before_result, "after": after_result}
    flash("Trigger 'trig_calc_efficiency_before_update' executed.", "success")
    return redirect(url_for("dbms.index"))

@dbms_bp.route("/demo-trigger-ticket", methods=["POST"])
@login_required
def demo_trigger_ticket():
    ticket_id = int(request.form.get("ticket_id", 703))
    
    before_sql = "SELECT * FROM ticket_solutions WHERE ticket_id = %s"
    before_result = run_query_and_get_results(before_sql, (ticket_id,))
    
    query("UPDATE tickets SET status = 'Resolved' WHERE ticket_id = %s", (ticket_id,), fetch=False)
    
    after_result = run_query_and_get_results(before_sql, (ticket_id,))
    
    session["result_trigger_ticket"] = {"before": before_result, "after": after_result}
    flash("Trigger 'trig_auto_ticket_solution' executed.", "success")

    # Reset for next demo
    query("UPDATE tickets SET status = 'In Progress' WHERE ticket_id = %s", (ticket_id,), fetch=False)
    query("DELETE FROM ticket_solutions WHERE ticket_id = %s", (ticket_id,), fetch=False)

    return redirect(url_for("dbms.index"))

@dbms_bp.route("/demo-trigger-status", methods=["POST"])
@login_required
def demo_trigger_status():
    project_id = int(request.form.get("project_id", 201))
    
    before_sql = "SELECT * FROM project_audit_log WHERE project_id = %s" # Using 'project_audit_log' based on your old file
    before_result = run_query_and_get_results(before_sql, (project_id,))
    
    query("UPDATE projects SET status = 'Completed' WHERE project_id = %s", (project_id,), fetch=False)
    
    after_result = run_query_and_get_results(before_sql, (project_id,))
    
    session["result_trigger_status"] = {"before": before_result, "after": after_result}
    flash("Trigger 'trig_project_status_change' executed.", "success")

    # Reset for next demo
    query("UPDATE projects SET status = 'In Progress' WHERE project_id = %s", (project_id,), fetch=False)

    return redirect(url_for("dbms.index"))

# --- 2. Procedures ---
@dbms_bp.route("/demo-proc-add-project", methods=["POST"])
@login_required
def demo_proc_add_project():
    project_id = int(request.form["project_id"])
    dept_id = int(request.form["dept_id"])
    
    try:
        db = get_db()
        cur = db.cursor(dictionary=True)
        cur.callproc("add_project", (
            project_id,
            request.form["name"],
            request.form["start_date"],
            request.form["end_date"],
            dept_id,
            request.form["summary"]
        ))
        
        for result in cur.stored_results(): pass
        db.commit()
        cur.close()
        flash(f"Success! Procedure 'add_project' ran for Project {project_id}.", "success")
        
        # Clean up demo project (assuming it shouldn't be permanent)
        query("DELETE FROM project_costs WHERE project_id = %s", (project_id,), fetch=False)
        query("DELETE FROM projects WHERE project_id = %s", (project_id,), fetch=False)
        
    except MySQLError as e:
        flash(f"SQL Error: {e.msg}", "danger")
        
    return redirect(url_for("dbms.index"))

@dbms_bp.route("/demo-proc-report", methods=["POST"])
@login_required
def demo_proc_report():
    project_id = int(request.form.get("project_id", 201))
    
    try:
        db = get_db()
        cur = db.cursor(dictionary=True)
        cur.callproc("get_project_report", (project_id,))
        
        # This procedure *returns* data, so we must fetch it
        results_list = []
        for result in cur.stored_results():
            rows = result.fetchall()
            headers = [col[0] for col in result.description] if result.description else []
            results_list.append({"headers": headers, "rows": rows})
        
        cur.close()
        
        # Store the (more complex) result in the session
        session["result_proc_report"] = {
            "sql": f"CALL get_project_report({project_id})",
            "headers": results_list[0]['headers'] if results_list else [],
            "rows": results_list[0]['rows'] if results_list else [],
            "error": None
        }
        flash("Procedure 'get_project_report' executed.", "success")
    except MySQLError as e:
        flash(f"SQL Error: {e.msg}", "danger")
        session["result_proc_report"] = {"sql": f"CALL get_project_report({project_id})", "headers": [], "rows": [], "error": str(e)}
        
    return redirect(url_for("dbms.index"))

@dbms_bp.route("/demo-proc-close", methods=["POST"])
@login_required
def demo_proc_close():
    # Find projects with past end_date
    before_sql = "SELECT project_id, summary FROM projects WHERE end_date < CURDATE()"
    before_result = run_query_and_get_results(before_sql)
    
    try:
        db = get_db()
        cur = db.cursor()
        cur.callproc("close_completed_projects")
        for result in cur.stored_results(): pass
        db.commit()
        cur.close()

        after_result = run_query_and_get_results(before_sql)
        session["result_proc_close"] = {"before": before_result, "after": after_result}
        flash("Procedure 'close_completed_projects' executed.", "success")
    except MySQLError as e:
        flash(f"SQL Error: {e.msg}", "danger")
        
    return redirect(url_for("dbms.index"))

# --- 3. Functions ---
@dbms_bp.route("/demo-func-efficiency", methods=["POST"])
@login_required
def demo_func_efficiency():
    project_id = int(request.form.get("project_id", 201))
    session["result_func_efficiency"] = run_query_and_get_results("SELECT get_project_efficiency(%s) AS efficiency", (project_id,))
    flash("Function 'get_project_efficiency' executed.", "success")
    return redirect(url_for("dbms.index"))
    
@dbms_bp.route("/demo-func-tickets", methods=["POST"])
@login_required
def demo_func_tickets():
    project_id = int(request.form.get("project_id", 201))
    session["result_func_tickets"] = run_query_and_get_results("SELECT total_tickets(%s) AS total_tickets", (project_id,))
    flash("Function 'total_tickets' executed.", "success")
    return redirect(url_for("dbms.index"))

@dbms_bp.route("/demo-func-ratio", methods=["POST"])
@login_required
def demo_func_ratio():
    project_id = int(request.form.get("project_id", 201))
    session["result_func_ratio"] = run_query_and_get_results("SELECT ticket_resolution_ratio(%s) AS resolution_ratio", (project_id,))
    flash("Function 'ticket_resolution_ratio' executed.", "success")
    return redirect(url_for("dbms.index"))

# --- 4. Complex Queries ---
@dbms_bp.route("/demo-query-nested", methods=["GET"])
@login_required
def demo_query_nested():
    sql = "SELECT d.name, d.dept_id FROM department d WHERE d.dept_id = (SELECT dept_id FROM projects GROUP BY dept_id ORDER BY COUNT(*) DESC LIMIT 1)"
    session["result_query_nested"] = run_query_and_get_results(sql)
    flash("Nested Query executed.", "success")
    return redirect(url_for("dbms.index"))

@dbms_bp.route("/demo-query-join", methods=["GET"])
@login_required
def demo_query_join():
    sql = "SELECT t.ticket_id, t.title, t.status, t.date_raised, p.name AS project FROM tickets t JOIN projects p ON t.project_id = p.project_id WHERE t.status <> 'Resolved' LIMIT 5"
    session["result_query_join"] = run_query_and_get_results(sql)
    flash("Join Query executed.", "success")
    return redirect(url_for("dbms.index"))

@dbms_bp.route("/demo-query-aggregate", methods=["GET"])
@login_required
def demo_query_aggregate():
    sql = "SELECT p.name, pc.projected_cost FROM projects p JOIN project_costs pc ON p.project_id = pc.project_id ORDER BY pc.projected_cost DESC LIMIT 5"
    session["result_query_aggregate"] = run_query_and_get_results(sql)
    flash("Aggregate Query executed.", "success")
    return redirect(url_for("dbms.index"))