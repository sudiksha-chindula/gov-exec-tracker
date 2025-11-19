# app/routes/tickets.py
from flask import Blueprint, render_template, request, redirect, session, url_for, flash
from functools import wraps
from app.db import get_db, query
from .auth import login_required,role_required
from mysql.connector import Error as MySQLError

tickets_bp = Blueprint("tickets", __name__, url_prefix="/tickets")



@tickets_bp.route("/")
@login_required
def list_tickets():
    user_role = session.get("role")
    
    if user_role in ["admin", "employee"]:
        # --- QUERY 1: FOR ADMINS / EMPLOYEES (Get ALL tickets) ---
        admin_query = """
            SELECT 
                t.ticket_id, t.title, t.status, t.date_raised, t.project_id,
                s.summary AS solution_summary, s.admin_id
            FROM 
                tickets t
            LEFT JOIN 
                ticket_solutions s ON t.ticket_id = s.ticket_id
            ORDER BY 
                CASE 
                    WHEN t.status = 'Open' THEN 1
                    WHEN t.status = 'In Progress' THEN 2
                    WHEN t.status = 'Resolved' THEN 3
                    WHEN t.status = 'Closed' THEN 4
                    ELSE 5
                END, 
                t.date_raised DESC
        """
        rows = query(admin_query, params=(), fetch=True)
        
        # Admins/Employees don't need the 'File Ticket' modal data
        projects = []

    else:
        # --- QUERY 2: FOR CITIZENS (Get ONLY their tickets) ---
        citizen_query = """
            SELECT 
                t.ticket_id, t.title, t.status, t.date_raised, t.project_id,
                s.summary AS solution_summary, s.admin_id
            FROM 
                tickets t
            LEFT JOIN 
                ticket_solutions s ON t.ticket_id = s.ticket_id
            WHERE
                t.citizen_id = %s  -- Placeholder for the citizen's ID
            ORDER BY 
                CASE 
                    WHEN t.status = 'Open' THEN 1
                    WHEN t.status = 'In Progress' THEN 2
                    WHEN t.status = 'Resolved' THEN 3
                    WHEN t.status = 'Closed' THEN 4
                    ELSE 5
                END, 
                t.date_raised DESC
        """
        params = (session.get("citizen_id"),)
        rows = query(citizen_query, params, fetch=True)
        
        # Citizens DO need the project list for the 'File Ticket' modal
        projects = query("SELECT project_id, name FROM projects WHERE status != 'Closed'", fetch=True)

    # Return the template with the correct set of rows and projects
    return render_template("tickets_list.html", rows=rows, projects=projects)

# This route handles the POST request from the "Resolve" modal form
@tickets_bp.route("/resolve", methods=["POST"])
@login_required
def resolve_ticket():
    try:
        # 1. Get all the data from the form
        solution_id = request.form["solution_id"]
        ticket_id = request.form["ticket_id"]
        summary = request.form["summary"]
        admin_id = request.form["admin_id"] # This comes from the session-filled input

        # 2. Call our new stored procedure
        db = get_db()
        cur = db.cursor()
        
        
        cur.callproc("sp_ResolveTicket", (solution_id, ticket_id, summary, admin_id))
        
        # Consume any results from the procedure
        for result in cur.stored_results():
            pass
            
        db.commit()
        cur.close()
        
        flash(f"Ticket #{ticket_id} has been successfully resolved.", "success")

    except MySQLError as e:
        # Handle errors, like a duplicate Solution ID
        flash(f"Error resolving ticket: {e.msg}", "danger")
    except Exception as e:
        flash(f"An unexpected error occurred: {str(e)}", "danger")

    return redirect(url_for("tickets.list_tickets"))


# In app/routes/tickets.py
# Make sure to import 'request', 'flash', 'redirect', 'url_for' and 'role_required'

@tickets_bp.route("/file-ticket", methods=["POST"])
@login_required
@role_required("citizen")
def file_ticket():
    # This route only handles POST requests from the modal
    
    # 1. Get all data from the form
    title = request.form.get("title")
    date_raised = request.form.get("date_raised")
    citizen_id = session.get("citizen_id") # Get from session for security
    project_id = request.form.get("project_id")
    description = request.form.get("description")

    if not all([title, date_raised, citizen_id, project_id, description]):
        flash("All form fields are required.", "danger")
        return redirect(url_for("tickets.list_tickets"))

    # 2. Build the INSERT query
    # We do NOT include 'ticket_id' (let AUTO_INCREMENT handle it)
    # We set 'status' to 'Open' automatically
    sql_insert = """
        INSERT INTO tickets (title, date_raised, citizen_id, project_id, summary, status)
        VALUES (%s, %s, %s, %s, %s, 'Open')
    """
    params = (title, date_raised, citizen_id, project_id, description)

    try:
        # 3. Execute the query
        query(sql_insert, params, fetch=False) # fetch=False for INSERT
        flash("Your ticket has been filed successfully!", "success")
    except Exception as e:
        flash(f"An error occurred while filing your ticket: {e}", "danger")

    # 4. Redirect back to the ticket list, which will show the new ticket
    return redirect(url_for("tickets.list_tickets"))