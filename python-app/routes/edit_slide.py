from lib.with_app_decorator import with_app
from lib.get_or_panic import get_or_panic

from models.report import Report

from flask import request
from uuid import uuid4


@with_app("/edit_slide", methods=["POST"])
def edit_slide():
    root_directory = get_or_panic(request.json, "report_directory", "El directorio del reporte debe estar presente")
    slide_id = get_or_panic(request.json, "slide_id", "La id de la diapositiva debe estar presente")
    arguments = get_or_panic(request.json, "arguments", "La lista de argumentos debe estar presente")

    report = Report.from_root_directory(root_directory=root_directory)
    slide = report[slide_id]

    slide.arguments = arguments

    print(f"1. {slide.is_up2date = }")
    slide.clear_old_assets()
    print(f"1.1 {slide.is_up2date = }")
    new_assets = slide.build_new_assets()
    print(f"1.2 {slide.is_up2date = }")
    new_preview = slide.build_new_preview()
    print(f"2. {slide.is_up2date = }")

    report.save()

    return {
        "assets": [ asset.to_dict() for asset in new_assets ],
        "preview": new_preview,
        "key": str(uuid4())
    }
