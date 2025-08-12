from lib.with_app_decorator import with_app
from lib.check_file_extension import check_file_extension
from lib.render_preview import render_preview
from lib.sections.failure_rate.controller import FailureRate_Controller

from control_variables import CURRENT_DIRECTORY_PATH

from flask import request

import pandas as pd

import uuid
import os
import json


def create_reports_directory() -> str:
    reports_directory = os.path.join(CURRENT_DIRECTORY_PATH, "reports")

    if not os.path.isdir(reports_directory):
        os.mkdir(reports_directory)
    return reports_directory

@with_app("/start_report", methods=["POST"])
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

    slide_data = {
        "id": slide_id,
        "type": FailureRate_Controller.type_id(),
        "assets": assets,
        "arguments": default_arguments,
        "data_file": data_file,
        "preview": preview
    }

    json_metadata = {
        "report_name": report_name,
        "creation_date": creation_date,
        "last_edit": creation_date,
        "rendered_file": None,
        "slides": [slide_data]
    }

    with open(os.path.join(current_report, "metadata.json"), "w") as json_file:
        json.dump(json_metadata, json_file, indent=4)
    
    return { 
        "report_directory": current_report,
        "report_name": report_name,
        "slides": [slide_data]
    }, 200