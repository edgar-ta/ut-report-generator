from lib.with_app_decorator import with_app
from lib.descriptive_error import DescriptiveError
from lib.render_preview import render_preview
from lib.get_or_panic import get_or_panic

from control_variables import AVAILABLE_SLIDE_CONTROLLERS

from flask import request

import pandas as pd

import os
import json

@with_app("/edit_slide", methods=["POST"])
def edit_slide():
    current_report = get_or_panic(request.json, "report_directory", "El directorio del reporte debe estar presente")
    slide_id = get_or_panic(request.json, "slide_id", "La id de la diapositiva debe estar presente")
    arguments = get_or_panic(request.json, "arguments", "La lista de argumentos debe estar presente")

    metadata_file = os.path.join(current_report, "metadata.json")
    with open(metadata_file, "r") as file:
        metadata = json.load(file)
    
    index, slide = next(((index, slide) for (index, slide) in enumerate(metadata["slides"]) if slide["id"] == slide_id), (None, None))
    if slide is None:
        raise DescriptiveError(404, f"Slide not found in the report metadata. Possibly wrong id ({slide_id})")
    
    slide_type = slide["type"]
    controller = next((controller for controller in AVAILABLE_SLIDE_CONTROLLERS if controller.slide_type() == slide_type), None)
    if controller is None:
        raise DescriptiveError(500, f"Slide type '{slide_type}' not found. Possibly wrong section type")
    
    controller.validate_arguments(arguments)
    new_assets = controller.build_assets(slide["data_file"], current_report, arguments)
    new_preview = render_preview(controller, current_report, arguments, new_assets)

    for asset in slide["assets"]:
        if asset["type"] == "image" and os.path.exists(asset["value"]):
            os.remove(asset["value"])
    if os.path.exists(slide["preview"]):
        os.remove(slide["preview"])

    slide["preview"] = new_preview
    slide["assets"] = new_assets
    slide["arguments"] = { **slide["arguments"], **arguments }

    metadata["slides"][index] = slide
    metadata["last_edit"] = pd.Timestamp.now().isoformat()

    with open(metadata_file, "w") as file:
        json.dump(metadata, file, indent=4)
    
    return {
        "assets": new_assets,
        "preview": new_preview
    }, 200