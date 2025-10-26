from lib.with_flask import with_flask
from lib.get_entities_from_request import entities_for_editing_pivot_table

from routes.route_map import PIVOT_TABLE

from flask import request

@with_flask(PIVOT_TABLE.GET.value, methods=["POST"])
def get_pivot_table():
    _, __, pivot_table = entities_for_editing_pivot_table(request=request)
    return pivot_table.to_dict(), 200
