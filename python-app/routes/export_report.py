from lib.with_app_decorator import with_app
from lib.get_or_panic import get_or_panic
from lib.get_metadata import get_metadata
from lib.section_controller import AVAILABLE_SLIDE_TYPES

from flask import request, jsonify

import os
import shutil
import zipfile
import json
import uuid


@with_app("/export_report", methods=["POST"])
def export_report():
    current_report = get_or_panic(request.json, "report_directory", "El directorio del reporte debe estar presente")
    filename = get_or_panic(request.json, "filename", "El nombre del archivo de salida debe estar presente")

    temporary_directory = os.path.join(current_report, f"temporary-{uuid.uuid4()}")
    if os.path.exists(temporary_directory):
        shutil.rmtree(temporary_directory)
    shutil.copytree(current_report, temporary_directory)

    try:
        metadata = get_metadata(current_report)
        for slide in metadata["slides"]:
            slide_type = slide["type"]
            controller = next((c for c in AVAILABLE_SLIDE_TYPES if c.type_id() == slide_type), None)
            if controller is None:
                raise Exception(f"No se encontró un controlador para el tipo de slide '{slide_type}'")

            arguments = slide["arguments"]
            assets = controller.build_assets(slide["data_file"], temporary_directory, arguments)

            # @todo Este código está mal. El método para renderizar una slide es diferente
            controller.render_slide(None, arguments, assets)

        data_files_dir = os.path.join(temporary_directory, "data-files")
        os.makedirs(data_files_dir, exist_ok=True)

        # @todo Crear un set de los archivos de datos de las slides antes de copiarlos
        for i, slide in enumerate(metadata["slides"], start=1):
            original_data_file = slide["data_file"]

            # @todo Añadir la extensión del archivo original
            new_data_file_name = f"archivo-{i}.json"
            new_data_file_path = os.path.join(data_files_dir, new_data_file_name)

            shutil.copy2(original_data_file, new_data_file_path)
            slide["data_file"] = os.path.relpath(new_data_file_path, temporary_directory)  # Ruta relativa

        # Actualizar las rutas absolutas en el archivo de metadata
        for slide in metadata["slides"]:
            for key, value in slide["arguments"].items():
                if isinstance(value, str) and os.path.isabs(value):
                    slide["arguments"][key] = os.path.relpath(value, temporary_directory)

        # Guardar el archivo de metadata actualizado
        metadata_path = os.path.join(temporary_directory, "metadata.json")
        with open(metadata_path, "w") as metadata_file:
            json.dump(metadata, metadata_file, indent=4)

        # Crear el archivo .zip
        zip_path = os.path.join(current_report, filename)
        with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zipf:
            for root, _, files in os.walk(temporary_directory):
                for file in files:
                    file_path = os.path.join(root, file)
                    arcname = os.path.relpath(file_path, temporary_directory)
                    zipf.write(file_path, arcname)

        # Limpiar la carpeta temporal
        shutil.rmtree(temporary_directory)

        # Responder con éxito
        return jsonify({"message": f"Reporte exportado exitosamente como '{filename}'"}), 200

    except Exception as e:
        # Limpiar la carpeta temporal en caso de error
        shutil.rmtree(temporary_directory, ignore_errors=True)
        return jsonify({"error": str(e)}), 500
