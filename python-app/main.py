from flask import Flask, request
import re
import pandas as pd
from failure_rate import graph_failure_rate
from lib.sections.failure_rate.controller import FailureRate_Controller
from lib.section_controller import SectionController
from lib.asset_dict import asset_dict
import uuid
import os
import json
import logging

from lib.error_message_decorator import error_message_decorator
from lib.descriptive_error import DescriptiveError

app = Flask(__name__)
logger = logging.getLogger(__name__)

CURRENT_FILE_PATH = os.path.abspath(__file__)
CURRENT_DIRECTORY_PATH = os.path.dirname(CURRENT_FILE_PATH)
AVAILABLE_SECTION_TYPES: list[type[SectionController]] = [
    FailureRate_Controller
]

def create_reports_directory() -> str:
    reports_directory = os.path.join(CURRENT_DIRECTORY_PATH, "reports")

    if not os.path.isdir(reports_directory):
        os.mkdir(reports_directory)
    return reports_directory

@app.route("/hello", methods=["POST", "GET"])
def hello_world():
    return { "message": "Bienvenido, profesor" }, 200

@app.route("/start_report", methods=["POST"])
# @error_message_decorator("Couldn't start the report", logger)
def start_report():
    data_file = request.json["data_file"]

    reports_directory = create_reports_directory()
    current_report = os.path.join(reports_directory, str(uuid.uuid4()))

    os.mkdir(current_report)
    os.mkdir(os.path.join(current_report, "images"))

    section_id = str(uuid.uuid4())

    assets = FailureRate_Controller.render_assets(data_file, current_report, { "unit": 1 })

    default_arguments = { "unit": 1, "show_delayed_teachers": False }

    creation_date = pd.Timestamp.now().isoformat()
    report_name = "Mi reporte"

    json_metadata = {
        "report_name": report_name,
        "creation_date": creation_date,
        "last_edit": creation_date,
        "sections": [
            {
                "id": section_id,
                "type": FailureRate_Controller.type_id(),
                "assets": assets,
                "arguments": default_arguments,
                "data_file": data_file
            }
        ]
    }

    with open(os.path.join(current_report, "metadata.json"), "w") as json_file:
        json.dump(json_metadata, json_file, indent=4)
    
    return { 
        "report_directory": current_report,
        "report_name": report_name,
        "assets": assets, 
        "section_id": section_id,
        "arguments": default_arguments
    }, 200

@app.route("/edit_section", methods=["POST"])
# @error_message_decorator("Couldn't edit the report's section", logger)
def edit_section():
    current_report = request.json["report_directory"]
    section_id = request.json["section_id"]
    arguments = request.json["arguments"]

    metadata_file = os.path.join(current_report, "metadata.json")
    with open(metadata_file, "r") as file:
        metadata = json.load(file)
    
    index, section = next(((index, section) for (index, section) in enumerate(metadata["sections"]) if section["id"] == section_id), (None, None))
    if section is None:
        raise DescriptiveError(404, f"Section not found in the report metadata. Possibly wrong id ({section_id})")
    
    section_type = section["type"]
    controller = next((controller for controller in AVAILABLE_SECTION_TYPES if controller.type_id() == section_type), None)
    if controller is None:
        raise DescriptiveError(404, f"Section type '{section_type}' not found. Possibly wrong section type")
    
    controller.validate_asset_arguments(arguments)
    assets = controller.obtain_assets(section["data_file"], current_report, arguments)

    for asset in section["assets"]:
        if os.path.exists(asset["path"]):
            os.remove(asset["path"])
    
    section["assets"] = assets
    section["arguments"] = { **section["arguments"], **arguments }

    metadata["sections"][index] = section
    metadata["last_edit"] = pd.Timestamp.now().isoformat()

    with open(metadata_file, "w") as file:
        json.dump(metadata, file, indent=4)
    
    return "Section edited successfully", 200

if __name__ == '__main__':
    logging.basicConfig(filename='logs.log')
    app.run()
