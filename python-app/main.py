from routes.hello_world import hello_world

import routes.pivot_table as pivot_table
import routes.image_slide as image_slide
import routes.report as report

from flask import Flask, request, jsonify
from typing import TypeVar

import logging
import sys

app = Flask(__name__)
logger = logging.getLogger(__name__)

hello_world(app)

app.register_blueprint(report.blueprint)
app.register_blueprint(pivot_table.blueprint)
app.register_blueprint(image_slide.blueprint)

T = TypeVar("T")
def item_or(_list: list[T], index: int, default: T) -> T:
    try:
        return _list[index]
    except IndexError:
        return default

if __name__ == '__main__':
    mode = item_or(_list=sys.argv, index=1, default="dev")
    port = int(item_or(_list=sys.argv, index=2, default="5000"))

    if mode == "dev":
        logging.basicConfig(filename='logs.log')
        app.run(port=port)
    elif mode == "release":
        from waitress import serve
        serve(app=app, port=port)
