from lib.with_flask import with_flask
from lib.get_entities_from_request import entities_for_editing_slide
from lib.get_or_panic import get_or_panic
from lib.slide.render_preview import render_preview
from lib.slide.delete_preview import delete_preview
from lib.report.save_slideshow import save_slideshow

from models.response.file_response import FileResponse

from routes.route_map import SLIDE

from flask import request
from pandas import Timestamp
from threading import Lock

LOCK = Lock()

@with_flask(SLIDE.RENAME.value, methods=["POST"])
def rename_slide():
    with LOCK:
        root_directory, report, slide = entities_for_editing_slide(request=request) 
        title = get_or_panic(request.json, 'title', 'El nuevo título de la diapositiva no está presente en la solicitud')
        
        slide.title = title
        slide.last_edit = Timestamp.now()

        delete_preview(slide=slide)
        render_preview(root_directory=root_directory, slides=slide)

        save_slideshow(root_directory=root_directory, slideshow=report)

        return FileResponse(
            message='Se renderizó correctamente la diapositiva', 
            filepath=slide.preview
            ).to_dict(), 200
