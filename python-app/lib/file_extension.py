import re
from lib.descriptive_error import DescriptiveError

def get_file_extension(filename: str) -> str | None:
    extension = re.search(r"\.([^\.]+)$", filename)
    if extension is None:
        return None
    
    extension = extension.group(1).lower()
    return extension

def get_extension_or_panic(filename: str) -> str:
    extension = get_file_extension(filename=filename)
    if extension is None:
        raise DescriptiveError(400, f"Invalid file name (it doesn't have an extension): {filename}")

    return extension

def check_file_extension(filename: str, valid_extensions = [ "xls", "xlsx", "csv" ]) -> None:
    if (extension := get_extension_or_panic(filename=filename)) not in valid_extensions:
        raise DescriptiveError(400, f"Unsupported file type ({extension})")

def with_extension(filename: str, extension: str) -> str:
    return re.sub(r"\.([^\.]+)$", f".{extension}", filename)
    
def has_extension(filename: str, extension: str) -> bool:
    '''
    :param extension | The file extension (without the leading period)
    '''
    return (actual_extension := get_file_extension(filename=filename)) is not None and actual_extension == extension
