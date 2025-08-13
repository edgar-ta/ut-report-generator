import re
from lib.descriptive_error import DescriptiveError

def get_file_extension(filename: str) -> str:
    extension = re.search(r"\.([^\.]+)$", filename)
    if extension is None:
        raise DescriptiveError(400, f"Invalid file name (it doesn't have an extension): {filename}")

    extension = extension.group(1).lower()
    return extension

def check_file_extension(filename: str, valid_extensions = [ "xls", "xlsx", "csv" ]) -> None:
    if (extension := get_file_extension(filename=filename)) not in valid_extensions:
        raise DescriptiveError(400, f"Unsupported file type ({extension})")

def with_extension(filename: str, extension: str) -> str:
    return re.sub(r"\.([^\.]+)$", f".{extension}", filename)
    
