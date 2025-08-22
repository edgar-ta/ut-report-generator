from routes.pivot_table.create_pivot_table import create_pivot_table
from routes.pivot_table.edit_pivot_table import edit_pivot_table
from flask import Blueprint

blueprint = Blueprint("pivot_table", __name__, url_prefix="/pivot_table")

create_pivot_table(blueprint)
edit_pivot_table(blueprint)
