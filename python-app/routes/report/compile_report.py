from lib.with_flask import with_flask
from lib.get_entities_from_request import entities_for_editing_report
from lib.report.compile_slides import compile_slides
from lib.report.get_preview_of_report import get_preview_of_report
from lib.directory_definitions import compiled_file_of_report
from lib.report.save_slideshow import save_slideshow

from models.response.file_response import FileResponse

from routes.route_map import SLIDESHOW

from flask import request

@with_flask(SLIDESHOW.COMPILE.value, methods=["POST"])
def compile_report():
    root_directory, report = entities_for_editing_report(request=request)

    filepath = compiled_file_of_report(root_directory=root_directory, report_name=report.report_name)
    compile_slides(
        slides=report.slides, 
        filepath=filepath
        )
    
    save_slideshow(root_directory=root_directory, slideshow=report)
    return FileResponse(
        message='El reporte fue compilado de forma correcta',
        filepath=filepath,
        preview=get_preview_of_report(report=report)
    ).to_dict(), 200
