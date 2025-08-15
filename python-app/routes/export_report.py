from lib.with_app_decorator import with_app
from lib.get_or_panic import get_or_panic
from lib.file_extension import get_extension_or_panic, with_extension
from lib.random_message import random_message, RandomMessageType

from control_variables import EXPORTED_REPORTS_EXTENSION

from models.report import Report

from flask import request

import os
import shutil
import zipfile


@with_app("/export_report", methods=["POST"])
def export_report():
    root_directory = get_or_panic(request.json, "report_directory", "El directorio del reporte debe estar presente")

    report = Report.from_root_directory(root_directory=root_directory)

    os.makedirs(report.export_directory, exist_ok=True)
    for item in os.listdir(root_directory):
        source = os.path.join(root_directory, item)
        destination = os.path.join(report.export_directory, item)

        if os.path.abspath(source) == os.path.abspath(report.export_directory):
            continue

        if os.path.isdir(source):
            shutil.copytree(source, destination, dirs_exist_ok=True)
        else:
            shutil.copy2(source, destination)
    
    unique_data_files = { file for slide in report.slides for file in slide.data_files }

    exported_report = Report.from_root_directory(root_directory=report.export_directory)

    files_equivalence = {
        data_file: os.path.join(exported_report.data_directory, f"archivo-{i + 1}.{get_extension_or_panic(data_file)}") 
        for i, data_file in enumerate(unique_data_files)
    }

    for source, destination in files_equivalence.items():
        shutil.copy(src=source, dst=destination)
    
    for slide in exported_report.slides:
        slide._data_files = [ 
            os.path.relpath(report.export_directory, files_equivalence[data_file]) 
            for data_file in slide._data_files 
        ]

    exported_report.save()

    final_name = report.export_file
    if os.path.exists(final_name):
        os.remove(final_name)

    with zipfile.ZipFile(report.export_file, "w", zipfile.ZIP_DEFLATED) as zip_file:
        for root, _, files in os.walk(report.export_directory):
            for file in files:
                file_path = os.path.join(root, file)
                archive_name = os.path.relpath(file_path, report.export_directory)
                zip_file.write(file_path, archive_name)
    
    shutil.rmtree(report.export_directory)
    os.rename(report.export_file, final_name)

    return {
        "message": random_message(_type=RandomMessageType.EXPORT_SUCCESFUL),
        "output_file": final_name
    }, 200
