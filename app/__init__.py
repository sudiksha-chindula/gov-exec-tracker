from flask import Flask
from dotenv import load_dotenv
import os




def create_app():
    # ✅ Load .env before anything else
    env_path = os.path.join(os.path.dirname(__file__), ".env")
    load_dotenv(env_path)

    app = Flask(__name__)
    app.secret_key = "secret-key"  # or use env if you want

    # ✅ Import and register routes AFTER loading .env
    from .routes.auth import auth_bp
    from .routes.projects import projects_bp
    from .routes.dashboard import dashboard_bp

    app.register_blueprint(dashboard_bp)

    app.register_blueprint(auth_bp)
    app.register_blueprint(projects_bp)
    return app

# ✅ For flask run
app = create_app()
