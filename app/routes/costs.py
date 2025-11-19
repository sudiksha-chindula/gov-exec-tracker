# app/routes/costs.py
from flask import Blueprint, render_template, request, redirect, url_for, session
from app.db import get_db
from functools import wraps
from .auth import login_required

costs_bp = Blueprint('costs', __name__, url_prefix="/costs")

# ---------------------------------

@costs_bp.route("/")
@login_required  # --- ADDED DECORATOR ---
def list_costs():
    db = get_db()
    cur = db.cursor(dictionary=True)
    # This query was correct
    cur.execute("SELECT * FROM project_costs")
    costs = cur.fetchall()
    cur.close()
    return render_template("costs_list.html", costs=costs)

@costs_bp.route("/add", methods=["GET", "POST"])
@login_required  # --- ADDED DECORATOR ---
def add_cost():
    if session.get('role') != 'employee':
        flash("You are not authorized to perform this action.", "danger")
        return redirect(url_for("projects.list_projects"))
    if request.method == "POST":
        # --- FIXED: MAJOR SCHEMA MISMATCH ---
        # Your code sent 'material_cost', 'labor_cost', 'misc_cost'.
        # Your schema has 'projected_cost', 'actual_cost', etc.
        # Your HTML form MUST be updated to send the correct fields.
        project_id = request.form["project_id"]
        projected_cost = request.form["projected_cost"]
        actual_cost = request.form["actual_cost"]

        db = get_db()
        cur = db.cursor()
        cur.execute("""
            INSERT INTO project_costs (project_id, projected_cost, actual_cost)
            VALUES (%s, %s, %s)
        """, (project_id, projected_cost, actual_cost))
        db.commit()
        cur.close()

        return redirect(url_for("costs.list_costs"))

    return render_template("costs_form.html")