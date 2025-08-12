import os
import json

def get_metadata(current_report: str) -> dict[str, any]:
    metadata_file = os.path.join(current_report, "metadata.json")
    with open(metadata_file, "r") as file:
        metadata = json.load(file)
    return metadata
