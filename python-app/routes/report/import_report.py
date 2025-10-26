from lib.with_flask import with_flask
from lib.get_or_panic import get_or_panic
from lib.file_extension import check_file_extension
from lib.directory_definitions import root_directory_of_report
from lib.report.construct import from_root_directory
from lib.report.save_slideshow import save_slideshow

from constants.control_variables import ZIP_COMPRESSION_LEVEL

from routes.route_map import SLIDESHOW

from flask import request
from uuid import uuid4

import os
import zipfile

@with_flask(SLIDESHOW.IMPORT.value, methods=["POST"])
def import_report():
    report_file = get_or_panic(object=request.json, key='report_file', error_message='Se esperaba el archivo .zip para importar')
    check_file_extension(filename=report_file, valid_extensions=["zip"])

    with zipfile.ZipFile(file=report_file, mode="r", compression=ZIP_COMPRESSION_LEVEL) as zfile:
        new_root_directory = root_directory_of_report(report_id=str(uuid4()))
        zfile.extractall(path=new_root_directory)

    report = from_root_directory(root_directory=new_root_directory)
    for slide in report.slides:
        slide._data_files = [ os.path.join(report.data_directory, file) for file in slide._data_files ]
    
    save_slideshow(root_directory=new_root_directory, slideshow=report)

    return report.to_dict(), 200
