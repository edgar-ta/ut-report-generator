from lib.with_flask import with_flask
from lib.get_entities_from_request import entities_for_editing_slide
from lib.directory_definitions import base_directory_of_slide
from lib.report.save_slideshow import save_slideshow

from models.response.success_response import SuccessResponse

from routes.route_map import SLIDE

from flask import request
from shutil import rmtree
from pandas import Timestamp

@with_flask(SLIDE.DELETE.value, methods=["POST"])
def delete_slide():
    root_directory, report, slide = entities_for_editing_slide(request=request)
    report.slides = [ _slide for _slide in report.slides if _slide.identifier != slide.identifier ]

    rmtree(base_directory_of_slide(root_directory=root_directory, slide_id=slide.identifier))

    # In an improbable future, this route should also delete the files that are used by the
    # slide (in case it is a pivot table) which are present in the data_directory_of_report

    report.last_edit = Timestamp.now()
    save_slideshow(root_directory=root_directory, slideshow=report)

    return SuccessResponse(
        message='La diapositiva se eliminó correctamente'
        ).to_dict(), 200
