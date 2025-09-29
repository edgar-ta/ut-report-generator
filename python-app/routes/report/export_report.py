from lib.with_flask import with_flask
from lib.file_extension import get_extension_or_panic, get_file_extension
from lib.random_message import random_message, RandomMessageType
from lib.get_entities_from_request import entities_for_editing_report
from lib.directory_definitions import temporary_export_directory_of_report, data_directory_of_report, exported_file_of_report

from control_variables import ZIP_COMPRESSION_LEVEL

from models.report.self import Report
from models.pivot_table.self import PivotTable
from models.response.file_response import FileResponse

from flask import request

import os
import shutil
import zipfile


def export_pivot_table_files(temporary_export_directory: str, pivot_tables: list[PivotTable]):
    unique_data_files = { data_file for pivot_table in pivot_tables for data_file in pivot_table.source.files }

    exported_report = Report.from_root_directory(root_directory=temporary_export_directory)
    data_directory = data_directory_of_report(root_directory=temporary_export_directory)

    files_equivalence = {
        data_file: f"archivo-{i + 1}.{get_extension_or_panic(data_file)}"
        for i, data_file in enumerate(unique_data_files)
    }

    for source, destination in files_equivalence.items():
        shutil.copy(src=source, dst=os.path.join(data_directory, destination))
    
    for pivot_table in pivot_tables:
        exported_pivot_table = exported_report[pivot_table.identifier]
        exported_pivot_table.source.files = [ 
            files_equivalence[data_file]
            for data_file in exported_pivot_table.source.files
        ]

    exported_report.save()

@with_flask("/export", methods=["POST"])
def export_report():
    report = entities_for_editing_report(request=request)
    root_directory = report.root_directory

    temporary_export_directory = temporary_export_directory_of_report(root_directory=root_directory)
    if os.path.exists(temporary_export_directory) and os.path.isdir(temporary_export_directory):
        shutil.rmtree(temporary_export_directory, ignore_errors=True)
    os.makedirs(temporary_export_directory, exist_ok=True)

    for item in os.listdir(root_directory):
        source = os.path.join(root_directory, item)
        destination = os.path.join(temporary_export_directory, item)

        if get_file_extension(source) in [ "zip" ]:
            continue

        if os.path.abspath(source) == os.path.abspath(temporary_export_directory):
            continue

        if os.path.isdir(source):
            shutil.copytree(source, destination, dirs_exist_ok=True)
        else:
            shutil.copy2(source, destination)
    
    export_pivot_table_files(
        temporary_export_directory=temporary_export_directory, 
        pivot_tables=[ slide for slide in report.slides if isinstance(slide, PivotTable) ]
        )

    exported_file = exported_file_of_report(root_directory=root_directory, report_name=report.report_name)
    if os.path.exists(exported_file):
        os.remove(exported_file)

    with zipfile.ZipFile(exported_file, "w", ZIP_COMPRESSION_LEVEL) as zip_file:
        for root, _, files in os.walk(temporary_export_directory):
            for file in files:
                file_path = os.path.join(root, file)
                archive_name = os.path.relpath(file_path, temporary_export_directory)
                zip_file.write(file_path, archive_name)
    
    shutil.rmtree(temporary_export_directory)

    return FileResponse(
        message=random_message(_type=RandomMessageType.EXPORT_SUCCESFUL),
        filepath=exported_file
    ).to_dict(), 200
