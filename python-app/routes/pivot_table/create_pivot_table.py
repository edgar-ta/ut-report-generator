from lib.with_flask import with_flask
from lib.get_entities_from_request import entities_for_editing_report
from lib.slide.render_preview import render_preview
from lib.report.save_slideshow import save_slideshow
from lib.pivot_table.build_pivot_table import build_pivot_table

from flask import request

@with_flask("/create", methods=["POST"])
def create_pivot_table():
    root_directory, report = entities_for_editing_report(request=request)

    pivot_table = build_pivot_table(root_directory=root_directory, local_request=request)
    render_preview(slides=pivot_table)

    report.slides.append(pivot_table)
    save_slideshow(slideshow=report, root_directory=root_directory)

    return pivot_table.to_dict(), 200
