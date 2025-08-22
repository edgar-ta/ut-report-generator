from routes.image_slide.edit_image_slide import edit_image_slide

from flask import Blueprint

blueprint = Blueprint("image_slide", __name__, url_prefix="/image_slide")

edit_image_slide(blueprint)
