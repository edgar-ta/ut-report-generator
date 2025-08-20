from routes.slide.edit_slide import edit_slide

from flask import Blueprint

blueprint = Blueprint("image_slide", __name__, url_prefix="/image_slide")

edit_slide(blueprint)
