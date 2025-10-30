from flask import Blueprint, render_template, request, redirect, session
from functools import wraps
from app.db import get_db

contractors_bp = Blueprint("contractors", __name__, url_prefix="/contractors")

def login_required(view):
    @wraps(view)
    def wrapper(*a, **kw):
        if "user" not in session:
            return redirect("/auth/login")
        return view(*a, **kw)
    return wrapper

@contractors_bp.route("/")
@login_required
def list_contractors():
    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute("SELECT * FROM contractors")
    rows = cur.fetchall()
    return render_template("contractors_list.html", rows=rows)

@contractors_bp.route("/add", methods=["GET","POST"])
@login_required
def add_contractor():
    if request.method == "POST":
        db = get_db()
        cur = db.cursor()
        q = "INSERT INTO contractors VALUES (%s,%s,%s)"
        cur.execute(q, (
            request.form["contractor_id"],
            request.form["contractor_name"],
            request.form["phone"]
        ))
        db.commit()
        return redirect("/contractors")

    return render_template("contractors_form.html", title="Add Contractor", data=None)

@contractors_bp.route("/delete/<int:cid>")
@login_required
def delete_contractor(cid):
    db = get_db()
    cur = db.cursor()
    cur.execute("DELETE FROM contractors WHERE contractor_id=%s", (cid,))
    db.commit()
    return redirect("/contractors")
