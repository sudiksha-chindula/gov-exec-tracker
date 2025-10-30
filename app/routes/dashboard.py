from flask import Blueprint, render_template, session, redirect
from functools import wraps
from app.db import get_db

dashboard_bp = Blueprint("dashboard", __name__)

def login_required(view):
    @wraps(view)
    def wrapper(*a, **kw):
        if "user" not in session:
            return redirect("/auth/login")
        return view(*a, **kw)
    return wrapper

@dashboard_bp.route("/")
@login_required
def dashboard():
    db = get_db()
    cur = db.cursor(dictionary=True)

    cur.execute("SELECT COUNT(*) AS c FROM projects")
    total_projects = cur.fetchone()["c"]

    cur.execute("SELECT COUNT(*) AS c FROM tickets WHERE status!='Resolved'")
    open_tickets = cur.fetchone()["c"]

    cur.execute("SELECT COUNT(*) AS c FROM contractors")
    contractors = cur.fetchone()["c"]

    return render_template("dashboard.html", stats={
        "projects": total_projects,
        "open_tickets": open_tickets,
        "contractors": contractors
    })
