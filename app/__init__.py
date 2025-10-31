# app/__init__.py
from flask import Flask
from dotenv import load_dotenv, find_dotenv

def create_app():
    # Load .env for every Flask process (cli, dev server, gunicorn, etc.)
    load_dotenv(find_dotenv())

    app = Flask(__name__)
    app.secret_key = "dev-secret"  # replace with an env var if you want

    # --- Register blueprints ---
    from .routes.auth import auth_bp
    from .routes.dashboard import dashboard_bp
    from .routes.projects import projects_bp
    from .routes.contractors import contractors_bp
    from .routes.employees import employees_bp
    from .routes.costs import costs_bp
    from .routes.tickets import tickets_bp

    app.register_blueprint(auth_bp, url_prefix="/auth")
    # dashboard exposes / and /dashboard (no prefix)
    app.register_blueprint(dashboard_bp)
    app.register_blueprint(projects_bp, url_prefix="/projects")
    app.register_blueprint(contractors_bp, url_prefix="/contractors")
    app.register_blueprint(employees_bp, url_prefix="/employees")
    app.register_blueprint(costs_bp, url_prefix="/costs")
    app.register_blueprint(tickets_bp, url_prefix="/tickets")

    return app
