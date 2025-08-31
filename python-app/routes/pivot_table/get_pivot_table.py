from lib.with_app_decorator import with_app
from lib.get_or_panic import get_or_panic
from lib.format_for_create import format_for_create
from lib.get_entities_from_request import entities_for_editing_pivot_table

from lib.pivot_table.add_pivot_table_to_report import add_pivot_table_to_report

from models.report import Report

from flask import request

@with_app("/get", methods=["POST"])
def get_pivot_table():
    _, pivot_table = entities_for_editing_pivot_table(request=request)
    return pivot_table.to_dict(), 200
