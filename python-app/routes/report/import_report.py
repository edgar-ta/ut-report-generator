from lib.with_app_decorator import with_app
from lib.get_or_panic import get_or_panic
from lib.file_extension import check_file_extension
from lib.directory_definitions import root_directory_of_report

from models.report import Report
from models.frontend.report_record import ReportRecord

from control_variables import ZIP_COMPRESSION_LEVEL

from flask import request

import os
import zipfile

@with_app("/import", methods=["POST"])
def import_report():
    report_file = get_or_panic(object=request.json, key='report_file', error_message='Se esperaba el archivo .zip para importar')
    check_file_extension(filename=report_file, valid_extensions=["zip"])

    with zipfile.ZipFile(file=report_file, mode="r", compression=ZIP_COMPRESSION_LEVEL) as zfile:
        new_root_directory = root_directory_of_report(report_id=Report.new_report_id())
        zfile.extractall(path=new_root_directory)

    report = Report.from_root_directory(root_directory=new_root_directory)
    for slide in report.slides:
        slide._data_files = [ os.path.join(report.data_directory, file) for file in slide._data_files ]
    report.save()

    return ReportRecord.from_report(report=report).to_dict(), 200
