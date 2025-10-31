# app/routes/employees.py
from flask import Blueprint, render_template, request, redirect, session, url_for
from functools import wraps
from app.db import get_db

employees_bp = Blueprint("employees", __name__, url_prefix="/employees")

def login_required(view):
    @wraps(view)
    def wrapper(*a, **kw):
        # --- FIXED: Check for emp_id ---
        if "emp_id" not in session:
            return redirect(url_for("auth.login"))
        return view(*a, **kw)
    return wrapper

@employees_bp.route("/")
@login_required
def list_employees():
    db = get_db()
    cur = db.cursor(dictionary=True)
    # This query is correct
    cur.execute("SELECT * FROM government_employees")
    rows = cur.fetchall()
    return render_template("employees_list.html", rows=rows)