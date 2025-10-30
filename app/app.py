# app.py
from flask import Flask, render_template, request, redirect, url_for, flash
from db import query

app = Flask(__name__)
app.secret_key = "change-this-secret"  # needed for flash messages

@app.route("/")
def index():
    return render_template("base.html", title="Home")

# 1) READ: list projects
@app.route("/projects")
def projects_list():
    rows = query(
        "SELECT project_id, name, start_date, end_date, dept_id, summary FROM projects ORDER BY project_id"
    )
    return render_template("projects_list.html", rows=rows)

# 2) CREATE: show form + insert
@app.route("/projects/new", methods=["GET", "POST"])
def projects_new():
    if request.method == "POST":
        project_id = request.form.get("project_id")
        name = request.form.get("name")
        start_date = request.form.get("start_date") or None
        end_date = request.form.get("end_date") or None
        dept_id = request.form.get("dept_id") or None
        summary = request.form.get("summary")

        # Minimal validation for beginner demo
        if not project_id or not name:
            flash("project_id and name are required.")
            return redirect(url_for("projects_new"))

        # INSERT (parametrized)
        query(
            "INSERT INTO projects (project_id, name, start_date, end_date, dept_id, summary) VALUES (%s, %s, %s, %s, %s, %s)",
            (project_id, name, start_date, end_date, dept_id, summary),
            commit=True,
        )
        flash("Project created.")
        return redirect(url_for("projects_list"))

    # GET: show blank form; also load departments for a dropdown
    depts = query("SELECT dept_id, name FROM department ORDER BY dept_id")
    return render_template("projects_form.html", mode="create", depts=depts, row=None)

# 3) UPDATE: show form with existing + update on POST
@app.route("/projects/<int:project_id>/edit", methods=["GET", "POST"])
def projects_edit(project_id):
    if request.method == "POST":
        name = request.form.get("name")
        start_date = request.form.get("start_date") or None
        end_date = request.form.get("end_date") or None
        dept_id = request.form.get("dept_id") or None
        summary = request.form.get("summary")

        query(
            "UPDATE projects SET name=%s, start_date=%s, end_date=%s, dept_id=%s, summary=%s WHERE project_id=%s",
            (name, start_date, end_date, dept_id, summary, project_id),
            commit=True,
        )
        flash("Project updated.")
        return redirect(url_for("projects_list"))

    # GET: load existing row and departments
    row = query(
        "SELECT project_id, name, start_date, end_date, dept_id, summary FROM projects WHERE project_id=%s",
        (project_id,),
        fetchone=True,
    )
    if not row:
        flash("Project not found.")
        return redirect(url_for("projects_list"))

    depts = query("SELECT dept_id, name FROM department ORDER BY dept_id")
    return render_template("projects_form.html", mode="edit", depts=depts, row=row)

# 4) DELETE
@app.route("/projects/<int:project_id>/delete", methods=["POST"])
def projects_delete(project_id):
    query("DELETE FROM projects WHERE project_id=%s", (project_id,), commit=True)
    flash("Project deleted.")
    return redirect(url_for("projects_list"))

if __name__ == "__main__":
    # debug=True auto-reloads on changes
    app.run(debug=True)
