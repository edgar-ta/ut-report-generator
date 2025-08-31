from lib.file_extension import without_extension

import re
import os

def is_valid_group_name(name: str) -> bool:
    return re.match(
        pattern=r'^\w{2}\d{2}\w{2}-\d{2}$',
        string=name
        ) is not None

def group_name_from_path(file_path: str) -> str:
    return without_extension(filename=os.path.split(file_path)[-1])

def inscription_year_of_group(group_name: str):
    return 2000 + int(re.search(pattern=r'(\d{2})$', string=group_name).group(1))
