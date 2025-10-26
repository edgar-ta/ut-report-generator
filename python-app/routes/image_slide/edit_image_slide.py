from lib.with_flask import with_flask
from lib.get_or_panic import get_or_panic
from lib.get_entities_from_request import entities_for_editing_image_slide
from lib.slide.render_preview import render_preview
from lib.slide.delete_preview import delete_preview
from lib.report.save_slideshow import save_slideshow

from models.error.descriptive_error import DescriptiveError
from models.response.edit_image_slide_response import EditImageSlide_Response

from routes.route_map import IMAGE_SLIDE

from flask import request

import pandas

@with_flask(IMAGE_SLIDE.EDIT.value, methods=["POST"])
def edit_image_slide():
    root_directory, report, image_slide = entities_for_editing_image_slide(request=request)
    parameter_name = get_or_panic(request.json, 'parameter_name', 'El nombre del parámetro a editar no está presente en la solicitud')
    parameter_value = get_or_panic(request.json, 'parameter_value', 'El valor del parámetro a editar no está presente en la solicitud')

    if parameter_name not in image_slide.parameters_dict:
        raise DescriptiveError(http_error_code=400, message='El nombre del parámetro no es válido para la diapostiva a editar')
    
    previous_value = image_slide.parameters_dict[parameter_name]
    image_slide.__setattr__(parameter_name, parameter_value)

    if previous_value != parameter_value:
        delete_preview(slide=image_slide)
        render_preview(root_directory=root_directory, slides=image_slide)

        image_slide.last_edit = pandas.Timestamp.now()

    save_slideshow(slideshow=report, root_directory=root_directory)

    return EditImageSlide_Response(preview=image_slide.preview).to_dict(), 200
