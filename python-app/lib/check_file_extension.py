import re
from lib.descriptive_error import DescriptiveError


def check_file_extension(filename: str, valid_extensions = [ "xls", "xlsx", "csv" ]) -> None:
    extension = re.search(r"\.([^\.]+)$", filename)
    if not extension:
        raise DescriptiveError(400, "Invalid file path (it doesn't have an extension)")
    extension = extension.group(1).lower()
    if extension not in valid_extensions:
        raise DescriptiveError(400, f"Unsupported file type ({extension})")
