from lib.file_extension import get_file_extension, without_extension
from lib.descriptive_error import DescriptiveError
from lib.group_name import is_valid_group_name

import os

def validate_file(data_file: list[str]) -> None:
    extension = get_file_extension(filename=data_file)
    if extension is None:
        raise DescriptiveError(http_error_code=400, message="El archivo no tiene una extensión válida")
    
    if extension not in ["xls", "csv", "hdf5"]:
        raise DescriptiveError(http_error_code=400, message="El archivo es de una extensión no válida")
    
    filename = os.path.split(data_file)[-1]
    if not is_valid_group_name(without_extension(filename=filename)):
        raise DescriptiveError(http_error_code=400, message=f"El archivo no cuenta con el nombre de un grupo válido ({filename})")
    
    if not os.path.exists(data_file):
        raise DescriptiveError(http_error_code=400, message="El archivo seleccionado no existe")
