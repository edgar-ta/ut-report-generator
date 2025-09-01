from routes.pivot_table.filter.add_option import add_option_to_filter
from routes.pivot_table.filter.create_filter import create_filter
from routes.pivot_table.filter.remove_option import remove_option_from_filter
from routes.pivot_table.filter.switch_option import switch_option_in_filter
from routes.pivot_table.filter.delete_filter import delete_filter
from routes.pivot_table.filter.toggle_selection_mode_of_filter import toggle_selection_mode_of_filter

from flask import Blueprint

blueprint = Blueprint("filter", __name__, url_prefix="/filter")

add_option_to_filter(blueprint)
create_filter(blueprint)
remove_option_from_filter(blueprint)
switch_option_in_filter(blueprint)
delete_filter(blueprint)
toggle_selection_mode_of_filter(blueprint)
