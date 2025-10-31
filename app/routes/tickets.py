# app/routes/tickets.py
from flask import Blueprint, render_template, request, redirect, session, url_for
from functools import wraps
from app.db import get_db

tickets_bp = Blueprint("tickets", __name__, url_prefix="/tickets")

def login_required(view):
    @wraps(view)
    def wrapper(*a, **kw):
        # --- FIXED: Check for emp_id ---
        if "emp_id" not in session:
            return redirect(url_for("auth.login"))
        return view(*a, **kw)
    return wrapper

@tickets_bp.route("/")
@login_required
def list_tickets():
    db = get_db()
    cur = db.cursor(dictionary=True)
    # This query was correct
    cur.execute("SELECT * FROM tickets")
    rows = cur.fetchall()
    return render_template("tickets_list.html", rows=rows)

@tickets_bp.route("/resolve/<int:tid>")
@login_required
def resolve_ticket(tid):
    db = get_db()
    cur = db.cursor()
    # This query was correct
    cur.execute("UPDATE tickets SET status='Resolved' WHERE ticket_id=%s", (tid,))
    db.commit()
    # --- FIXED: Use url_for for redirect ---
    return redirect(url_for("tickets.list_tickets"))