# app/routes/auth.py

from flask import (
    Blueprint, render_template, request, redirect, url_for, session, g, flash, abort
)
from app.db import get_db, query
import functools

auth_bp = Blueprint("auth", __name__, url_prefix="/auth")

# --- LOGIN REQUIRED (Reverted) ---
def login_required(view):
    """
    Generic login required decorator.
    """
    @functools.wraps(view)
    def wrapped_view(**kwargs):
        if 'user_id' not in session:
            flash("You must be logged in to view this page.", "danger")
            return redirect(url_for('auth.login'))
        
        # Load basic info into g
        g.user_role = session.get('role')
        g.user_id = session.get('user_id')
        
        return view(**kwargs)
    return wrapped_view

# --- ROLE REQUIRED (This can stay, it's useful) ---
def role_required(role_name):
    """
    A decorator to restrict access to a specific role.
    """
    def decorator(view):
        @functools.wraps(view)
        def wrapped_view(**kwargs):
            if session.get('role') != role_name:
                abort(403)  # 403 Forbidden
            return view(**kwargs)
        return wrapped_view
    return decorator


# --- LOGIN ROUTE (Fixed) ---
@auth_bp.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "GET" and "user_id" in session:
        return redirect(url_for("dashboard.dashboard"))
        
    if request.method == "GET":
        return render_template("login.html")

    # --- POST LOGIC ---
    id_str = request.form.get("username", "").strip()
    password = request.form.get("password", "").strip()

    if not id_str or not password:
        flash("ID and password are required.", "danger")
        return render_template("login.html"), 400

    try:
        user_id = int(id_str)
    except ValueError:
        flash("Invalid ID or password.", "danger")
        return render_template("login.html"), 401

    # 1. Check if they are an Admin
    admin_user_list = query(
        "SELECT admin_id, password FROM web_admin_list WHERE admin_id = %s",
        (user_id,), fetch=True
    )
    if admin_user_list:
        admin_user = admin_user_list[0] # Get the user dict from the list
        if admin_user["password"] == password:
            session.clear()
            session["user_id"] = admin_user["admin_id"]
            session["role"] = "admin"
            
            # ===============================================
            # ==  THIS IS THE FIX                          ==
            # ===============================================
            # Also store their ID as 'emp_id' so the ticket modal works
            session["emp_id"] = admin_user["admin_id"]
            
            return redirect(url_for("dashboard.dashboard"))

    # 2. Check if they are a Government Employee
    emp_user_list = query(
        "SELECT govt_emp_id, password FROM government_employees WHERE govt_emp_id = %s",
        (user_id,), fetch=True
    )
    if emp_user_list:
        emp_user = emp_user_list[0] 
        if emp_user["password"] == password:
            session.clear()
            session["user_id"] = emp_user["govt_emp_id"]
            session["role"] = "employee"
            session["emp_id"] = emp_user["govt_emp_id"]
            return redirect(url_for("dashboard.dashboard"))

    # 3. Check if they are a Citizen
    citizen_user_list = query(
        "SELECT citizen_id, password FROM web_citizen_list WHERE citizen_id = %s",
        (user_id,), fetch=True
    )
    if citizen_user_list:
        citizen_user = citizen_user_list[0]
        if citizen_user["password"] == password:
            session.clear()
            session["user_id"] = citizen_user["citizen_id"]
            session["role"] = "citizen"
            session["citizen_id"] = citizen_user["citizen_id"]
            return redirect(url_for("tickets.list_tickets"))

    # 4. If none of the above, fail
    flash("Invalid ID or password.", "danger")
    return render_template("login.html"), 401


@auth_bp.route("/logout")
def logout():
    session.clear()
    flash("You have been logged out successfully.", "info")
    return redirect(url_for("auth.login"))