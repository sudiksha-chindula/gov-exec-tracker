from flask import Blueprint, render_template, request, redirect, url_for, flash, session
from app.db import query
from functools import wraps # Import wraps

auth_bp = Blueprint("auth", __name__)

# --- This decorator is needed for the logout route ---
def login_required(view):
    @wraps(view)
    def wrapper(*a, **kw):
        if "emp_id" not in session:
            return redirect(url_for("auth.login"))
        return view(*a, **kw)
    return wrapper

@auth_bp.route("/login", methods=["GET", "POST"])
def login():
    # If user is already logged in, send them to the dashboard
    if request.method == "GET" and "emp_id" in session:
        return redirect(url_for("dashboard.dashboard"))
        
    if request.method == "GET":
        return render_template("login.html")

    # --- Start of POST logic ---
    emp_id_str = request.form.get("username", "").strip()
    password = request.form.get("password", "").strip()

    if not emp_id_str or not password:
        flash("Employee ID and password are required.", "error")
        return render_template("login.html"), 400

    try:
        emp_id = int(emp_id_str)
    except ValueError:
        # The user typed something that isn't a number
        flash("Invalid Employee ID or password.", "error")
        return render_template("login.html"), 401

    # This query now matches your schema
    rows = query(
        """
        SELECT password
        FROM login_info
        WHERE emp_id=%s LIMIT 1
        """,
        (emp_id,),
        fetch=True,
    )

    if not rows:
        flash("Invalid Employee ID or password.", "error")
        return render_template("login.html"), 401

    user = rows[0]
    
    # Check the password
    if password != user["password"]:
        flash("Invalid Employee ID or password.", "error")
        return render_template("login.html"), 401

    # Store the user's Employee ID in the session
    session.clear()
    session["emp_id"] = emp_id

    # Go to dashboard
    return redirect(url_for("dashboard.dashboard"))


# --- ADDED: New Logout Route ---
@auth_bp.route("/logout")
@login_required
def logout():
    session.clear()
    # You can add a flash message here if you have flash messaging set up
    # flash("You have been logged out.", "success")
    return redirect(url_for("auth.login"))