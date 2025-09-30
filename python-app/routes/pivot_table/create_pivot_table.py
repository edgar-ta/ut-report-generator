from lib.with_flask import with_flask
from lib.format_for_create import format_for_create
from lib.get_entities_from_request import entities_for_editing_report

from lib.pivot_table.add_pivot_table_to_report import add_pivot_table_to_report

from flask import request

@with_flask("/create", methods=["POST"])
def create_pivot_table():
    report = entities_for_editing_report(request=request)
    pivot_table = add_pivot_table_to_report(report=report, local_request=request, index=request.json.get('index'))
    report.save()

    return pivot_table.to_dict(), 200
