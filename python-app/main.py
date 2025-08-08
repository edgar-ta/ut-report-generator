from lib.sections.failure_rate.controller import FailureRate_Controller
from lib.section_controller import SlideController
from lib.descriptive_error import DescriptiveError
from lib.check_file_extension import check_file_extension

from flask import Flask, request
from pptx import Presentation as LibrePresentation
from spire.presentation import Presentation as SpirePresentation

import pandas as pd
import uuid
import os
import json
import logging


app = Flask(__name__)
logger = logging.getLogger(__name__)

CURRENT_FILE_PATH = os.path.abspath(__file__)
CURRENT_DIRECTORY_PATH = os.path.dirname(CURRENT_FILE_PATH)
AVAILABLE_SLIDE_TYPES: list[type[SlideController]] = [
    FailureRate_Controller
]

def create_reports_directory() -> str:
    reports_directory = os.path.join(CURRENT_DIRECTORY_PATH, "reports")

    if not os.path.isdir(reports_directory):
        os.mkdir(reports_directory)
    return reports_directory

def render_preview(controller: type[SlideController], current_report: str, arguments: dict[str, str], assets: list[dict[str, str]]) -> str:
    presentation = LibrePresentation()
    controller.render_slide(presentation, arguments, assets)
    pptx_preview_path = os.path.join(current_report, str(uuid.uuid4()) + ".pptx")
    presentation.save(pptx_preview_path)

    spire_presentation = SpirePresentation()
    spire_presentation.LoadFromFile(pptx_preview_path)

    png_preview_path = os.path.join(current_report, "images", str(uuid.uuid4()) + ".png")
    image = spire_presentation.Slides[0].SaveAsImage()
    image.Save(png_preview_path)
    image.Dispose()

    spire_presentation.Dispose()
    os.remove(pptx_preview_path)
        
    return png_preview_path
    

@app.route("/hello", methods=["POST", "GET"])
def hello_world():
    return { "message": "Bienvenido, profesor" }, 200

@app.route("/start_report", methods=["POST"])
# @error_message_decorator("Couldn't start the report", logger)
def start_report():
    data_file = request.json["data_file"]
    check_file_extension(data_file)

    reports_directory = create_reports_directory()
    current_report = os.path.join(reports_directory, str(uuid.uuid4()))

    os.mkdir(current_report)
    os.mkdir(os.path.join(current_report, "images"))

    slide_id = str(uuid.uuid4())

    default_arguments = FailureRate_Controller.default_arguments()
    assets = FailureRate_Controller.build_assets(data_file, current_report, default_arguments)
    preview = render_preview(FailureRate_Controller, current_report, default_arguments, assets)

    creation_date = pd.Timestamp.now().isoformat()
    report_name = "Mi reporte"

    json_metadata = {
        "report_name": report_name,
        "creation_date": creation_date,
        "last_edit": creation_date,
        "slides": [
            {
                "id": slide_id,
                "type": FailureRate_Controller.type_id(),
                "assets": assets,
                "arguments": default_arguments,
                "data_file": data_file,
                "preview": preview
            }
        ]
    }

    with open(os.path.join(current_report, "metadata.json"), "w") as json_file:
        json.dump(json_metadata, json_file, indent=4)
    
    return { 
        "report_directory": current_report,
        "report_name": report_name,
        "assets": assets, 
        "slide_id": slide_id,
        "arguments": default_arguments,
        "preview": preview
    }, 200

@app.route("/edit_slide", methods=["POST"])
def edit_slide():
    current_report = request.json["report_directory"]
    slide_id = request.json["slide_id"]
    arguments = request.json["arguments"]

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

@app.route("/change_slide_data", methods=["POST"])
def change_slide_data():
    data_file = request.json["data_file"]
    check_file_extension(data_file)

    current_report = request.json["report_directory"]
    slide_id = request.json["slide_id"]

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

if __name__ == '__main__':
    logging.basicConfig(filename='logs.log')
    app.run()
