from flask import Flask, request
import re
import pandas as pd
from failure_rate import graph_failure_rate
import uuid
import os
import json
import logging

from lib.error_message_decorator import error_message_decorator
from lib.descriptive_error import DescriptiveError

app = Flask(__name__)
logger = logging.getLogger(__name__)

@app.route("/hello", methods=["POST", "GET"])
def hello_world():
    return "Hello world!"

def get_data_frame(filename: str) -> pd.DataFrame:
    try:
        data_frame = pd.read_excel(filename, header=[0, 1, 2, 3, 4])
        return data_frame
    except FileNotFoundError as error:
        raise DescriptiveError(404, f"Couldn't get the data frame with the following path {filename}") from error

def check_file_extension(filename: str) -> None:
    extension = re.search(r"\.([^\.]+)$", filename)
    if not extension:
        raise DescriptiveError(400, "Invalid file path (it doesn't have an extension)")
    extension = extension.group(1).lower()
    if extension not in [ "xls", "xlsx", "csv" ]:
        raise DescriptiveError(400, f"Unsupported file type ({extension})")

def create_reports_directory() -> str:
    file_path = os.path.abspath(__file__)
    current_directory_path = os.path.dirname(file_path)
    reports_directory = os.path.join(current_directory_path, "reports")

    if not os.path.isdir(reports_directory):
        os.mkdir(reports_directory)
    return reports_directory

@app.route("/start_report", methods=["POST"])
@error_message_decorator("Couldn't start the report", logger)
def start_report():
    filename = request.json["filename"]

    check_file_extension(filename)
    data_frame = get_data_frame(filename)

    reports_directory = create_reports_directory()
    directory_name = os.path.join(reports_directory, str(uuid.uuid4()))

    os.mkdir(directory_name)
    os.mkdir(os.path.join(directory_name, "images"))

    image_name = os.path.join(directory_name, "images", str(uuid.uuid4()) + ".png")
    graph_failure_rate(data_frame, image_name)
    section_id = str(uuid.uuid4())

    creation_date = pd.Timestamp.now().isoformat()
    report_name = "Mi reporte"

    json_metadata = {
        "report_name": report_name,
        "creation_date": creation_date,
        "last_edit": creation_date,
        "sections": [
            {
                "id": section_id,
                "type": "failure_rate",
                "images": [ image_name ],
                "data_file": filename
            }
        ]
    }

    with open(os.path.join(directory_name, "metadata.json"), "w") as json_file:
        json.dump(json_metadata, json_file, indent=4)
    
    return { 
        "report_directory": directory_name, 
        "report_name": report_name,
        "image_path": image_name, 
        "section_id": section_id,
    }, 200

if __name__ == '__main__':
    logging.basicConfig(filename='logs.log')
    app.run()
