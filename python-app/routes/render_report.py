from lib.with_app_decorator import with_app
from lib.descriptive_error import DescriptiveError
from lib.get_or_panic import get_or_panic
from lib.random_message import random_message, RandomMessageType

from control_variables import AVAILABLE_SLIDE_CONTROLLERS

from flask import request
from pptx import Presentation

import pandas as pd
import os
import json


@with_app("/render_report", methods=["POST"])
def render_report():
    output_file = get_or_panic(request.json, "output_file", "El nombre del archivo debe estar presente")
    current_report = get_or_panic(request.json, "report_directory", "El directorio del reporte debe estar presente")

    valid_extensions = [".pptx"]
    if not any(output_file.endswith(ext) for ext in valid_extensions):
        raise DescriptiveError(400, f"Invalid file extension. Allowed extensions are: {', '.join(valid_extensions)}")

    if os.path.exists(output_file):
        raise DescriptiveError(400, f"The file '{output_file}' already exists. Please choose a different name.")

    metadata_file = os.path.join(current_report, "metadata.json")
    if not os.path.exists(metadata_file):
        raise DescriptiveError(404, "Metadata file not found.")

    with open(metadata_file, "r") as file:
        metadata = json.load(file)

    presentation = Presentation()

    for slide_metadata in metadata["slides"]:
        slide_type = slide_metadata["type"]
        controller = next((controller for controller in AVAILABLE_SLIDE_CONTROLLERS if controller.slide_type() == slide_type), None)
        if controller is None:
            raise DescriptiveError(404, f"Controller for slide type '{slide_type}' not found.")

        arguments = slide_metadata["arguments"]
        assets = controller.build_assets(slide_metadata["data_file"], current_report, arguments)

        controller.render_slide(presentation, arguments, assets)

    metadata["output_file"] = output_file
    metadata["last_edit"] = pd.Timestamp.now().isoformat()

    with open(metadata_file, "w") as file:
        json.dump(metadata, file, indent=4)

    if os.path.exists(output_file):
        os.remove(output_file)
    presentation.save(output_file)

    return {"message": random_message(RandomMessageType.REPORT_GENERATED), "output_file": output_file }, 200
