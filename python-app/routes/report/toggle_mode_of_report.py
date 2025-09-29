from lib.with_flask import with_flask
from lib.get_entities_from_request import entities_for_editing_report

from models.report.visualization_mode import VisualizationMode
from models.response.success_response import SuccessResponse

from flask import request

@with_flask("toggle_mode", methods=["POST"])
def toggle_mode_of_report():
    report = entities_for_editing_report(request=request)
    if report.visualization_mode == VisualizationMode.AS_REPORT:
        report.visualization_mode = VisualizationMode.CHARTS_ONLY
    else:
        report.visualization_mode = VisualizationMode.AS_REPORT
    report.save()

    return SuccessResponse(
        message=f"El modo del reporte ahora es {report.visualization_mode.value}"
    ).to_dict(), 200
