from lib.with_flask import with_flask
from lib.get_entities_from_request import entities_for_editing_report
from lib.report.compile_slides import compile_slides
from lib.directory_definitions import compiled_file_of_report

from models.response.file_response import FileResponse

from flask import request

@with_flask("/compile", methods=["POST"])
def compile_report():
    report = entities_for_editing_report(request=request)

    filepath = compiled_file_of_report(root_directory=report.root_directory, report_name=report.report_name)
    compile_slides(
        slides=report.slides, 
        filepath=filepath
        )
    
    report.save()
    return FileResponse(
        message='El reporte fue compilado de forma correcta',
        filepath=filepath
    ).to_dict(), 200
