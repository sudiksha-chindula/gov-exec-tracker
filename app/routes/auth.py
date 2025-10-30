from flask import Blueprint, render_template, request, session, redirect
from app.db import get_db

auth_bp = Blueprint("auth", __name__, url_prefix="/auth")

@auth_bp.route("/login", methods=["GET","POST"])
def login():
    error = None
    if request.method == "POST":
        u = request.form["username"]
        p = request.form["password"]

        db = get_db()
        cur = db.cursor(dictionary=True)
        cur.execute("SELECT * FROM login_info WHERE emp_id=%s AND password=%s", (u,p))
        user = cur.fetchone()

        if user:
            session["user"] = u
            return redirect("/dashboard")
        else:
            error = "Invalid username/password"

    return render_template("login.html", error=error)

@auth_bp.route("/logout")
def logout():
    session.clear()
    return redirect("/auth/login")
