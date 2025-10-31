# app/routes/contractors.py
from flask import Blueprint, render_template, request, redirect, session, url_for
from functools import wraps
from app.db import get_db

contractors_bp = Blueprint("contractors", __name__, url_prefix="/contractors")

def login_required(view):
    @wraps(view)
    def wrapper(*a, **kw):
        # --- FIXED: Check for emp_id ---
        if "emp_id" not in session:
            return redirect(url_for("auth.login"))
        return view(*a, **kw)
    return wrapper

@contractors_bp.route("/")
@login_required
def list_contractors():
    db = get_db()
    cur = db.cursor(dictionary=True)
    # This query was correct
    cur.execute("SELECT * FROM contractors")
    rows = cur.fetchall()
    return render_template("contractors_list.html", rows=rows)

@contractors_bp.route("/add", methods=["GET","POST"])
@login_required
def add_contractor():
    if request.method == "POST":
        db = get_db()
        cur = db.cursor()
        
        # --- FIXED: MAJOR SCHEMA MISMATCH ---
        # Your code was trying to insert 'phone', which doesn't exist.
        # The schema has 'bid_amount' and 'project_id'.
        # Your HTML form MUST be updated to send these new fields.
        q = """
            INSERT INTO contractors (contractor_id, name, bid_amount, project_id) 
            VALUES (%s, %s, %s, %s)
        """
        cur.execute(q, (
            request.form["contractor_id"],
            request.form["contractor_name"],
            request.form.get("bid_amount"),  # Use .get() for optional fields
            request.form.get("project_id")   # Use .get() for optional fields
        ))
        db.commit()
        # --- FIXED: Use url_for for redirect ---
        return redirect(url_for("contractors.list_contractors"))

    return render_template("contractors_form.html", title="Add Contractor", data=None)

@contractors_bp.route("/delete/<int:cid>")
@login_required
def delete_contractor(cid):
    db = get_db()
    cur = db.cursor()
    # This query was correct
    cur.execute("DELETE FROM contractors WHERE contractor_id=%s", (cid,))
    db.commit()
    # --- FIXED: Use url_for for redirect ---
    return redirect(url_for("contractors.list_contractors"))