from flask import (Blueprint, render_template, request, flash, redirect, url_for, session, abort)
from app.db import get_db, query
# Use your specific auth decorators
from .auth import login_required, role_required

projects_bp = Blueprint('projects', __name__, url_prefix='/projects')

@projects_bp.route("/")
@login_required
def list_projects():
    # 1. ADMIN GUARD
    if session.get('role') == 'admin':
        abort(403) 

    db = get_db()
    cur = db.cursor(dictionary=True)
    
    # 2. Get all projects
    cur.execute("SELECT * FROM projects")
    projects = cur.fetchall() # Get the projects
    
    # 3. Get ALL subtasks
    cur.execute("SELECT * FROM subtasks")
    all_subtasks = cur.fetchall()
    
    cur.close()

    # 4. Group subtasks by their project_id
    subtasks_by_project = {}
    for task in all_subtasks:
        pid = task['project_id']
        if pid not in subtasks_by_project:
            subtasks_by_project[pid] = []
        subtasks_by_project[pid].append(task)

    # 5. Pass both to the template
    return render_template(
        "projects_list.html", 
        rows=projects, 
        subtasks_by_project=subtasks_by_project
    )

@projects_bp.route("/add", methods=["GET", "POST"])
@login_required
@role_required("employee")
def add_project():
    if request.method == "POST":
        try:
            # Call your stored procedure 'add_project'
            query(
                "CALL add_project(%s, %s, %s, %s, %s, %s)",
                (
                    request.form["project_id"],
                    request.form["name"],
                    request.form["start_date"],
                    request.form["end_date"],
                    request.form["dept_id"],
                    request.form["summary"]
                ),
                fetch=False
            )
            flash("Project added successfully!", "success")
            return redirect(url_for("projects.list_projects"))
        except Exception as e:
            flash(f"Error adding project: {e}", "danger")
            # Re-render form with an error, pass data back
            return render_template("projects_form.html", project=request.form)

    # For a GET request, just show the blank form
    return render_template("projects_form.html", project=None)


@projects_bp.route("/edit/<int:pid>", methods=["GET", "POST"])
@login_required
@role_required("employee")
def edit_project(pid):
    # 1. Handle POST (Form Submission)
    if request.method == "POST":
        try:
            # Convert data types explicitly to avoid database errors
            dept_id = int(request.form["dept_id"])
            
            query(
                """
                UPDATE projects 
                SET name = %s, start_date = %s, end_date = %s, 
                    dept_id = %s, status = %s, summary = %s
                WHERE project_id = %s
                """,
                (
                    request.form["name"],
                    request.form["start_date"],
                    request.form["end_date"],
                    dept_id,
                    request.form["status"],
                    request.form["summary"],
                    pid
                ),
                fetch=False
            )
            flash("Project updated successfully!", "success")
            return redirect(url_for("projects.list_projects"))
            
        except Exception as e:
            flash(f"Error updating project: {e}", "danger")
            # CRITICAL FIX: Return the template here if an error occurs
            # You must rebuild the 'project' object from the form data so the user doesn't lose their edits
            project_data = {
                "project_id": pid,
                "name": request.form["name"],
                "start_date": request.form["start_date"],
                "end_date": request.form["end_date"],
                "dept_id": request.form["dept_id"],
                "status": request.form["status"],
                "summary": request.form["summary"]
            }
            return render_template("projects_form.html", project=project_data)

    # 2. Handle GET (Page Load)
    # Fetch the project to pre-fill the form
    project = query("SELECT * FROM projects WHERE project_id = %s", (pid,), fetch=True)
    
    if not project:
        flash("Project not found.", "danger")
        return redirect(url_for("projects.list_projects"))
    
    # Pass the first result (project[0]) to the template
    return render_template("projects_form.html", project=project[0])

@projects_bp.route("/delete/<int:pid>", methods=["POST"])
@login_required
@role_required("employee")
def delete_project(pid):
    try:
        # You must delete from child tables first (like subtasks, tickets, etc.)
        query("DELETE FROM subtasks WHERE project_id = %s", (pid,), fetch=False)
        query("DELETE FROM tickets WHERE project_id = %s", (pid,), fetch=False)
        query("DELETE FROM project_costs WHERE project_id = %s", (pid,), fetch=False)
        # Now you can delete from the parent table
        query("DELETE FROM projects WHERE project_id = %s", (pid,), fetch=False)
        flash("Project and all related data deleted successfully.", "success")
    except Exception as e:
        flash(f"Error deleting project: {e}. (Check for other related records)", "danger")
        
    return redirect(url_for("projects.list_projects"))


@projects_bp.route("/add-subtask", methods=["POST"])
@login_required
@role_required("employee")
def add_subtask():
    title = request.form.get("title")
    status = request.form.get("status")
    project_id = request.form.get("project_id")

    try:
        # Use 'name' to match your subtasks table structure
        query(
            "INSERT INTO subtasks (name, status, project_id) VALUES (%s, %s, %s)",
            (title, status, project_id),
            fetch=False
        )
        flash("Subtask added successfully!", "success")
    except Exception as e:
        flash(f"Error adding subtask: {e}", "danger")

    return redirect(url_for('projects.list_projects'))

# ===============================================
# ==  NEW ROUTE TO DELETE A SUBTASK            ==
# ===============================================
@projects_bp.route("/subtask/delete/<int:task_id>", methods=["POST"])
@login_required
@role_required("employee")
def delete_subtask(task_id):
    try:
        # Run the delete query
        query("DELETE FROM subtasks WHERE task_id = %s", (task_id,), fetch=False)
        flash("Subtask deleted successfully.", "success")
    except Exception as e:
        flash(f"Error deleting subtask: {e}", "danger")
    
    # Redirect back to the main projects list
    return redirect(url_for('projects.list_projects'))