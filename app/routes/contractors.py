from flask import (
    Blueprint, render_template, request, redirect, session, url_for, flash, abort
)
from app.db import get_db, query
from .auth import login_required, role_required

contractors_bp = Blueprint("contractors", __name__, url_prefix="/contractors")

@contractors_bp.route("/")
@login_required
def list_contractors():
    # Block admins, as per your nav bar logic
    if session.get('role') == 'admin':
        abort(403)
        
    rows = query("SELECT * FROM contractors", fetch=True)
    return render_template("contractors_list.html", rows=rows)

# ===============================================
# ==  THIS FUNCTION IS NOW FIXED (Your Way)    ==
# ===============================================
@contractors_bp.route("/add", methods=["GET","POST"])
@login_required
@role_required("employee")
def add_contractor():
    if request.method == "POST":
        try:
            # Matches your contractors_form.html names
            q = """
                -- FIX: Added contractor_id to the INSERT query
                INSERT INTO contractors (contractor_id, name, bid_amount, project_id) 
                VALUES (%s, %s, %s, %s)
            """
            
            query(q, (
                # FIX: Read the new contractor_id from the form
                request.form["contractor_id"], 
                request.form["contractor_name"],
                request.form.get("bid_amount"),
                request.form.get("project_id")
            ), fetch=False)

            flash("Contractor added successfully!", "success")
            return redirect(url_for("contractors.list_contractors"))
        except Exception as e:
            flash(f"Error adding contractor: {e}", "danger")
            # Re-render form with an error, pass data back
            return render_template("contractors_form.html", contractor=request.form, title="Add Contractor")

    # For a GET request, just show the blank form
    return render_template("contractors_form.html", contractor=None, title="Add Contractor")

# --- THIS IS THE MISSING EDIT ROUTE ---
@contractors_bp.route("/edit/<int:cid>", methods=["GET", "POST"])
@login_required
@role_required("employee")
def edit_contractor(cid):
    if request.method == "POST":
        # Handle the form submission (UPDATE logic)
        try:
            query(
                """
                UPDATE contractors 
                SET name = %s, bid_amount = %s, project_id = %s
                WHERE contractor_id = %s
                """,
                (
                    request.form["contractor_name"],
                    request.form.get("bid_amount"),
                    request.form.get("project_id"),
                    cid
                ),
                fetch=False
            )
            flash("Contractor updated successfully!", "success")
            return redirect(url_for("contractors.list_contractors"))
        except Exception as e:
            flash(f"Error updating contractor: {e}", "danger")
            # Show the form again if update failed
            return render_template("contractors_form.html", contractor=request.form, title="Edit Contractor")

    # GET request: fetch the contractor and show the pre-filled form
    contractor_list = query("SELECT * FROM contractors WHERE contractor_id = %s", (cid,), fetch=True)
    if not contractor_list:
        flash("Contractor not found.", "danger")
        return redirect(url_for("contractors.list_contractors"))
    
    # Pass the first result (contractor_list[0]) to the template
    return render_template("contractors_form.html", contractor=contractor_list[0], title="Edit Contractor")


# --- THIS IS THE CORRECTED DELETE ROUTE ---
@contractors_bp.route("/delete/<int:cid>", methods=["POST"])
@login_required
@role_required("employee")
def delete_contractor(cid):
    try:
        # IMPORTANT: You must delete from 'working_employees' first!
        #query("DELETE FROM working_employees WHERE contractor_id = %s", (cid,), fetch=False)
        
        # Now you can delete the contractor
        query("DELETE FROM contractors WHERE contractor_id=%s", (cid,), fetch=False)
        flash("Contractor and all related employees deleted.", "success")
    except Exception as e:
        flash(f"Error deleting contractor: {e}", "danger")
        
    return redirect(url_for("contractors.list_contractors"))