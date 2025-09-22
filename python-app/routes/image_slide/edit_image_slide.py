from lib.with_flask import with_flask
from lib.get_or_panic import get_or_panic
from lib.get_entities_from_request import entities_for_editing_image_slide
from lib.descriptive_error import DescriptiveError
from lib.slide.render_preview import render_preview
from lib.slide.delete_preview import delete_preview

from models.response.edit_image_slide_response import EditImageSlide_Response

from flask import request

import pandas

@with_flask("/edit", methods=["POST"])
def edit_image_slide():
    report, image_slide = entities_for_editing_image_slide(request=request)
    parameter_name = get_or_panic(request.json, 'parameter_name', 'El nombre del parámetro a editar no está presente en la solicitud')
    parameter_value = get_or_panic(request.json, 'parameter_value', 'El valor del parámetro a editar no está presente en la solicitud')

    if parameter_name not in image_slide.parameters_dict:
        raise DescriptiveError(http_error_code=400, message='El nombre del parámetro no es válido para la diapostiva a editar')
    
    previous_value = image_slide.parameters_dict[parameter_name]
    image_slide.__setattr__(parameter_name, parameter_value)

    if previous_value != parameter_value:
        delete_preview(slide=image_slide)
        render_preview(root_directory=report.root_directory, slides=image_slide)

        image_slide.last_edit = pandas.Timestamp.now()

    report.save()

    return EditImageSlide_Response(image_slide=image_slide).to_dict(), 200
