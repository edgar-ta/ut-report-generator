from lib.with_flask import with_flask
from lib.get_entities_from_request import entities_for_editing_pivot_table
from lib.get_or_panic import get_or_panic
from lib.descriptive_error import DescriptiveError
from lib.group_name import group_name_from_path
from lib.data_frame.validate_file import validate_file
from lib.data_frame.data_frame_io import import_data_frame, export_data_frame
from lib.pivot_table.read_excel import read_excel
from lib.pivot_table.get_clean_data_frame import get_clean_data_frame
from lib.pivot_table.recalculate import recalculate
from lib.pivot_table.plot_pivot_table import plot_from_entities
from lib.directory_definitions import data_file_of_slide

from models.response.edit_pivot_table_response import EditPivotTable_Response

from flask import request

import os
import pandas

@with_flask("/remove_file", methods=["POST"])
def remove_file_from_pivot_table():
    report, pivot_table = entities_for_editing_pivot_table(request=request)
    _file = get_or_panic(request.json, "file", "El archivo no a eliminar no se incluyó en la solicitud")

    if _file not in pivot_table.source.files:
        raise DescriptiveError(http_error_code=400, message=f"El archivo {_file} no está presente en la lista de archivos de la tabla dinámica")

    if len(pivot_table.source.files) == 1:
        raise DescriptiveError(http_error_code=400, message=f"No se puede eliminar el último archivo de la tabla dinámica ({_file})")

    pivot_table.source.files.remove(_file)

    data_frames = []
    for file_path in pivot_table.source.files:
        data_frame = read_excel(filename=file_path)
        data_frame = get_clean_data_frame(
            data_frame=data_frame, 
            group_name=group_name_from_path(file_path=file_path)
            )
        data_frames.append(data_frame)

    new_data_frame = pandas.concat(data_frames)

    # Reemplazamos el archivo mergeado
    if os.path.exists(pivot_table.source.merged_file):
        os.remove(pivot_table.source.merged_file)

    new_merged_file = data_file_of_slide(
        root_directory=report.root_directory,
        slide_id=pivot_table.identifier,
    )
    export_data_frame(
        data_frame=new_data_frame,
        file_path=new_merged_file,
        key=pivot_table.identifier,
    )
    pivot_table.source.merged_file = new_merged_file

    recalculate(report=report, pivot_table=pivot_table, preloaded_data_frame=new_data_frame)

    pivot_table.last_edit = pandas.Timestamp.now()
    report.save()

    return EditPivotTable_Response(
        data=pivot_table.data,
        filters=pivot_table.filters,
        preview=pivot_table.preview
        ).to_dict(), 200
