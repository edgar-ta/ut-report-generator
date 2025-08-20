from routes.slide.edit_slide import edit_slide

from flask import Blueprint

blueprint = Blueprint("slide", __name__, url_prefix="/slide")

edit_slide(blueprint)
