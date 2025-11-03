from routes.image_slide.edit_image_slide import edit_image_slide
from routes.image_slide.create_image_slide import create_image_slide

from flask import Blueprint

blueprint = Blueprint("image_slide", __name__, url_prefix="")

edit_image_slide(blueprint)
create_image_slide(blueprint)
