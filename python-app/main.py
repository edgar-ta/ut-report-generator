from routes.hello_world import hello_world

from routes.slide.edit_slide import edit_slide
from routes.slide.change_slide_data import change_slide_data

from routes.report.start_report import start_report
from routes.report.render_report import render_report
from routes.report.export_report import export_report
from routes.report.recent_reports import recent_reports
from routes.report.get_report import get_report
from routes.report.import_report import import_report

import routes.pivot_table as pivot_table

from flask import Flask, request, jsonify

import logging

app = Flask(__name__)
logger = logging.getLogger(__name__)

hello_world(app)
start_report(app)
edit_slide(app)
change_slide_data(app)
render_report(app)
export_report(app)
recent_reports(app)
get_report(app)
import_report(app)

app.register_blueprint(pivot_table.blueprint)

if __name__ == '__main__':
    logging.basicConfig(filename='logs.log')
    app.run()
