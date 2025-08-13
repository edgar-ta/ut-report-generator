from lib.with_app_decorator import with_app
from lib.get_or_panic import get_or_panic

from models.report import Report

from flask import request


@with_app("/edit_slide", methods=["POST"])
def edit_slide():
    root_directory = get_or_panic(request.json, "report_directory", "El directorio del reporte debe estar presente")
    slide_id = get_or_panic(request.json, "slide_id", "La id de la diapositiva debe estar presente")
    arguments = get_or_panic(request.json, "arguments", "La lista de argumentos debe estar presente")

    report = Report.from_root_directory(root_directory=root_directory)
    slide = report[slide_id]
    print("Hello 1")

    slide.arguments = arguments

    print("Hello 1.1")
    slide.clear_old_assets()
    new_assets = slide.build_new_assets()
    new_preview = slide.build_new_preview()

    print("Hello 2")
    report.save()
    print("Hello 3")

    return {
        "assets": [ asset.to_dict() for asset in new_assets ],
        "preview": new_preview
    }
