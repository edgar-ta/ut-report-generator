from routes.hello_world import hello_world
from routes.start_report import start_report
from routes.edit_slide import edit_slide
from routes.change_slide_data import change_slide_data
from routes.render_report import render_report
from routes.export_report import export_report
from routes.recent_reports import recent_reports
from routes.get_report import get_report

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

if __name__ == '__main__':
    logging.basicConfig(filename='logs.log')
    app.run()
