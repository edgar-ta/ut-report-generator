from lib.with_flask import with_flask
from lib.get_entities_from_request import entities_for_editing_pivot_table
from lib.get_or_panic import get_or_panic
from lib.group_name import group_name_from_path
from lib.data_frame.validate_file import validate_file
from lib.data_frame.data_frame_io import import_data_frame, export_data_frame
from lib.pivot_table.read_excel import read_excel
from lib.pivot_table.get_clean_data_frame import get_clean_data_frame
from lib.pivot_table.recalculate import recalculate
from lib.directory_definitions import data_file_of_slide
from lib.report.save_slideshow import save_slideshow

from models.response.edit_pivot_table_response import EditPivotTable_Response

from routes.route_map import PIVOT_TABLE

from flask import request

import os
import pandas

@with_flask(PIVOT_TABLE.ADD_FILE.value, methods=["POST"])
def add_file_to_pivot_table():
    root_directory, report, pivot_table = entities_for_editing_pivot_table(request=request)
    _file = get_or_panic(request.json, 'file', 'El archivo de datos no se incluyó en la solicitud')
    if _file in pivot_table.source.files:
        return EditPivotTable_Response(
            data=pivot_table.data,
            filters=pivot_table.filters,
            preview=pivot_table.preview
        ).to_dict(), 200

    validate_file(data_file=_file)
    new_data_frame = read_excel(filename=_file)
    new_data_frame = get_clean_data_frame(data_frame=new_data_frame, group_name=group_name_from_path(file_path=_file))

    old_data_frame = import_data_frame(file_path=pivot_table.source.merged_file, key=pivot_table.identifier)
    new_data_frame = pandas.concat([new_data_frame, old_data_frame])

    pivot_table.source.files.append(_file)

    os.remove(pivot_table.source.merged_file)
    new_merged_file = data_file_of_slide(
        root_directory=root_directory, 
        slide_id=pivot_table.identifier
        )

    export_data_frame(
        data_frame=new_data_frame, 
        file_path=new_merged_file, 
        key=pivot_table.identifier
        )
    pivot_table.source.merged_file = new_merged_file

    recalculate(root_directory=root_directory, pivot_table=pivot_table, preloaded_data_frame=new_data_frame)    

    pivot_table.last_edit = pandas.Timestamp.now()
    save_slideshow(slideshow=report, root_directory=root_directory)

    return EditPivotTable_Response(
        data=pivot_table.data, 
        filters=pivot_table.filters,
        preview=pivot_table.preview
        ).to_dict(), 200
