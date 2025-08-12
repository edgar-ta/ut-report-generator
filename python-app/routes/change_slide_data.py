from lib.with_app_decorator import with_app
from lib.check_file_extension import check_file_extension
from lib.descriptive_error import DescriptiveError
from lib.render_preview import render_preview
from lib.get_or_panic import get_or_panic

from control_variables import AVAILABLE_SLIDE_TYPES

from flask import request

import pandas as pd

import json
import os

@with_app("/change_slide_data", methods=["POST"])
def change_slide_data():
    data_file = get_or_panic(request.json, "data_file", "El nuevo archivo de datos debe estar presente")
    check_file_extension(data_file)

    current_report = get_or_panic(request.json, "report_directory", "El directorio del reporte debe estar presente")
    slide_id = get_or_panic(request.json, "slide_id", "La id de la diapositiva debe estar presente")

    metadata_file = os.path.join(current_report, "metadata.json")

    with open(metadata_file, "r") as file:
        metadata = json.load(file)

    index, slide = next(((index, slide) for (index, slide) in enumerate(metadata["slides"]) if slide["id"] == slide_id), (None, None))
    if slide is None:
        raise DescriptiveError(404, f"Slide not found in the report metadata. Possibly wrong id ({slide_id})")

    slide_type = slide["type"]
    controller = next((controller for controller in AVAILABLE_SLIDE_TYPES if controller.type_id() == slide_type), None)
    if controller is None:
        raise DescriptiveError(404, f"Slide type '{slide_type}' not found. Possibly wrong section type")
    
    new_assets = controller.build_assets(data_file, current_report, slide["arguments"])
    new_preview = render_preview(controller, current_report, slide["arguments"], new_assets)

    for asset in slide["assets"]:
        if asset["type"] == "image" and os.path.exists(asset["value"]):
            os.remove(asset["value"])
    if os.path.exists(slide["preview"]):
        os.remove(slide["preview"])

    slide["data_file"] = data_file
    slide["preview"] = new_preview
    slide["assets"] = new_assets

    metadata["slides"][index] = slide
    metadata["last_edit"] = pd.Timestamp.now().isoformat()

    with open(metadata_file, "w") as file:
        json.dump(metadata, file, indent=4)    

    return {
        "assets": new_assets,
        "preview": new_preview
    }, 200
