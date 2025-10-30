from flask import Blueprint, render_template, request, redirect, url_for
from app.db import get_db

costs_bp = Blueprint('costs', __name__, url_prefix="/costs")

@costs_bp.route("/")
def list_costs():
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("SELECT * FROM project_costs")
    costs = cur.fetchall()
    cur.close()
    db.close()
    return render_template("costs_list.html", costs=costs)

@costs_bp.route("/add", methods=["GET", "POST"])
def add_cost():
    if request.method == "POST":
        project_id = request.form["project_id"]
        material_cost = request.form["material_cost"]
        labor_cost = request.form["labor_cost"]
        misc_cost = request.form["misc_cost"]

        db = get_db()
        cur = db.cursor()
        cur.execute("""
            INSERT INTO project_costs (project_id, material_cost, labor_cost, misc_cost)
            VALUES (%s, %s, %s, %s)
        """, (project_id, material_cost, labor_cost, misc_cost))
        db.commit()
        cur.close()
        db.close()

        return redirect(url_for("costs.list_costs"))

    return render_template("costs_form.html")
