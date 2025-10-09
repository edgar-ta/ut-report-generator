from lib.with_flask import with_flask
from lib.get_or_panic import get_or_panic

from models.report.self import Report

from flask import request

@with_flask("/create", methods=["POST"])
def create_image_slide():
    return "Not implemented yet", 500
