from routes.hello_world import hello_world

import routes.pivot_table as pivot_table
import routes.image_slide as image_slide
import routes.report as report

from flask import Flask, request, jsonify

import logging

app = Flask(__name__)
logger = logging.getLogger(__name__)

hello_world(app)

app.register_blueprint(report.blueprint)
app.register_blueprint(pivot_table.blueprint)
app.register_blueprint(image_slide.blueprint)

if __name__ == '__main__':
    logging.basicConfig(filename='logs.log')
    app.run()
