import re

from lib.descriptive_error import DescriptiveError

from typing import Callable

def get_id_of_report(
        directory: str, 
        on_error: Callable[[str], str] = lambda filename: f"El directorio {filename} no tiene un nombre válido"
        ) -> str:
    '''
    Gets the id at the end of a report's name or throws an error 
    if the directory's name doesn't conform to the appropriate
    format

    Preconditions:
    - It assumes the directory given is the absolute path of a directory
    '''
    _match: re.Match[str] = re.match(pattern=r'\w+(\-\w+)*-(\d{8}-\d{4}-\d{4}-\d{4}-\d{12})', string=directory)
    if _match is None:
        raise DescriptiveError(http_error_code=400, message=on_error(directory))
    
    return _match.group(2)
