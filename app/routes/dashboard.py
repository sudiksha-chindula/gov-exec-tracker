# app/routes/dashboard.py
from flask import Blueprint, render_template, redirect, url_for, session
from app.db import query

dashboard_bp = Blueprint("dashboard", __name__)

@dashboard_bp.route("/")
def root_redirect():
    return redirect(url_for("dashboard.dashboard"))

@dashboard_bp.route("/dashboard")
def dashboard():
    # Simple stats: counts and a recent activity
    stats = query(
        """
        SELECT
            (SELECT COUNT(*) FROM projects)                AS projects_count,
            (SELECT COUNT(*) FROM contractors)             AS contractors_count,
            (SELECT COUNT(*) FROM government_employees)    AS employees_count,
            (SELECT COUNT(*) FROM tickets WHERE status='Open') AS open_tickets,
            (SELECT IFNULL(ROUND(AVG(efficiency),2),0) FROM project_costs) AS avg_efficiency
        """,
        fetch=True,
    )[0]

    recent_updates = query(
        """
        SELECT pu.update_id, pu.project_id, p.name AS project_name,
               pu.summary, pu.update_date
        FROM project_updates pu
        JOIN projects p ON p.project_id = pu.project_id
        ORDER BY pu.update_date DESC, pu.update_id DESC
        LIMIT 10
        """,
        fetch=True,
    )

    return render_template("dashboard.html", stats=stats, recent_updates=recent_updates)
