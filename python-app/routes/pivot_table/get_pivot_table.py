from lib.with_flask import with_flask
from lib.get_entities_from_request import entities_for_editing_pivot_table

from flask import request

@with_flask("/get", methods=["POST"])
def get_pivot_table():
    _, pivot_table = entities_for_editing_pivot_table(request=request)
    return pivot_table.to_dict(), 200
