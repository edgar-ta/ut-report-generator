from routes.slide.rename_slide import rename_slide

from flask import Blueprint

blueprint = Blueprint("slide", __name__, url_prefix="/slide")

rename_slide(blueprint)
