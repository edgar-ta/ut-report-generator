from models.report.self import Report

from lib.with_app_decorator import with_app
from lib.get_or_panic import get_or_panic

from uuid import uuid4
from flask import request

@with_app("/change_slide_data", methods=["POST"])
def change_slide_data():
    data_files = get_or_panic(request.json, "data_files", "La nueva colección de archivos debe estar presente")
    base_directory = get_or_panic(request.json, "report_directory", "El directorio del reporte debe estar presente")
    slide_id = get_or_panic(request.json, "slide_id", "La id de la diapositiva debe estar presente")

    report = Report.from_root_directory(base_directory)
    slide = report[slide_id]

    slide.data_files = data_files

    slide.clear_old_assets()
    new_assets = slide.build_new_assets()
    new_preview = slide.build_new_preview()

    report.save()

    return {
        "assets": [ asset.to_dict() for asset in new_assets],
        "preview": new_preview,
        "key": str(uuid4())
    }, 200
