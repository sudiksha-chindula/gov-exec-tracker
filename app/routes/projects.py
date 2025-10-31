from flask import Blueprint, render_template, request, redirect, session, url_for
from functools import wraps
from app.db import get_db

projects_bp = Blueprint("projects", __name__, url_prefix="/projects")

def login_required(view):
    @wraps(view)
    def wrapper(*a, **kw):
        if "emp_id" not in session:
            return redirect(url_for("auth.login"))
        return view(*a, **kw)
    return wrapper

@projects_bp.route("/")
@login_required
def list_projects():
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("SELECT * FROM projects")
    rows = cur.fetchall()
    return render_template("projects_list.html", rows=rows)

@projects_bp.route("/add", methods=["GET","POST"])
@login_required
def add_project():
    if request.method == "POST":
        db = get_db()
        cur = db.cursor()
        
        # FIXED: Added the 'status' column to the INSERT query
        q = """
            INSERT INTO projects (project_id, name, start_date, end_date, dept_id, summary, status) 
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        cur.execute(q, (
            request.form["project_id"],
            request.form["name"],
            request.form["start_date"],
            request.form["end_date"],
            request.form["dept_id"],
            request.form["summary"],
            request.form["status"]  # Get 'status' from the form
        ))
        db.commit()
        return redirect(url_for("projects.list_projects"))

    return render_template("projects_form.html", project=None, title="Add Project")

@projects_bp.route("/edit/<int:pid>", methods=["GET","POST"])
@login_required
def edit_project(pid):
    db = get_db()
    cur = db.cursor(dictionary=True)

    if request.method == "POST":
        # FIXED: Added 'status' to the UPDATE query
        q = """
            UPDATE projects 
            SET name=%s, start_date=%s, end_date=%s, dept_id=%s, summary=%s, status=%s
            WHERE project_id=%s
        """
        cur.execute(q, (
            request.form["name"],
            request.form["start_date"],
            request.form["end_date"],
            request.form["dept_id"],
            request.form["summary"],
            request.form["status"],  # Get 'status' from the form
            pid
        ))
        db.commit()
        return redirect(url_for("projects.list_projects"))

    cur.execute("SELECT * FROM projects WHERE project_id=%s", (pid,))
    row = cur.fetchone()
    return render_template("projects_form.html", project=row, title="Edit Project")

@projects_bp.route("/delete/<int:pid>")
@login_required
def delete_project(pid):
    db = get_db()
    cur = db.cursor()
    cur.execute("DELETE FROM projects WHERE project_id=%s", (pid,))
    db.commit()
    return redirect(url_for("projects.list_projects"))