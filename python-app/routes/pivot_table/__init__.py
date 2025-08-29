from routes.pivot_table.create_pivot_table import create_pivot_table
from routes.pivot_table.filter import blueprint as filter_blueprint
from flask import Blueprint

blueprint = Blueprint("pivot_table", __name__, url_prefix="/pivot_table")

create_pivot_table(blueprint)

blueprint.register_blueprint(filter_blueprint)
