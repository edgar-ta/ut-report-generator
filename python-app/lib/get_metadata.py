from lib.directory_definitions import metadata_file_of_report

import json

def get_metadata(root_directory: str) -> dict[str, any]:
    with open(metadata_file_of_report(root_directory=root_directory), "r") as metadata_file:
        metadata = json.loads(metadata_file.read())
    return metadata
