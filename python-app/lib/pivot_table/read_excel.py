from lib.descriptive_error import DescriptiveError
from lib.file_extension import get_file_extension

import pandas
import re

def filter_columns(name: str) -> bool:
    index = int(re.search(pattern=r'(\d+)$', string=name).group(1))
    if index < 3:
        return False
    return True

# @todo 
# This function might be made async so many Excel files can
# be read quickly
def read_excel(filename: str) -> pandas.DataFrame:
    match get_file_extension(filename=filename):
        case "xls" | "xlsx":
            return pandas.read_excel(filename, usecols=filter_columns)
        case "csv":
            return pandas.read_csv(filename, usecols=filter_columns)
