from flask import Blueprint, render_template, request, redirect, url_for, flash, session
from app.db import query

auth_bp = Blueprint("auth", __name__)

@auth_bp.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "GET":
        return render_template("login.html")

    # --- CHANGED HERE ---
    # We get the 'username' field from the form, which we treat as the Employee ID
    emp_id_str = request.form.get("username", "").strip()
    password = request.form.get("password", "").strip()

    if not emp_id_str or not password:
        flash("Employee ID and password are required.", "error")
        return render_template("login.html"), 400

    # --- NEW: Convert emp_id to integer ---
    # Your schema says emp_id is an integer, so we must convert it
    try:
        emp_id = int(emp_id_str)
    except ValueError:
        # The user typed something that isn't a number
        flash("Invalid Employee ID or password.", "error")
        return render_template("login.html"), 401

    # --- CHANGED HERE ---
    # This query now matches your database schema
    rows = query(
        """
        SELECT password
        FROM login_info
        WHERE emp_id=%s LIMIT 1
        """,
        (emp_id,),  # Pass the integer emp_id
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

    # --- CHANGED HERE ---
    # Store the user's Employee ID in the session.
    # This is the new "key" we will use to check if a user is logged in.
    session.clear()
    session["emp_id"] = emp_id

    # Go to dashboard
    return redirect(url_for("dashboard.dashboard"))