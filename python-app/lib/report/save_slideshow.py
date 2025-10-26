from lib.directory_definitions import metadata_file_of_report

from models.report.self import Report

import json

def save_slideshow(slideshow: Report, root_directory: str):
    last_edits = [] 

    if len(slideshow.slides) > 0:
        last_edits.extend([ slide.last_edit for slide in slideshow.slides ])

    last_edits.append(slideshow.last_edit)
    
    slideshow.last_edit = max(last_edits)
    metadata_file = metadata_file_of_report(root_directory=root_directory)

    with open(metadata_file, "w") as json_file:
        json.dump(slideshow.to_dict(), json_file, indent=4)
