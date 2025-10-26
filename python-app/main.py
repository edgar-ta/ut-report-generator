from constants.asset_variables import validate_assets
from constants.dynamic_variables import DynamicVariables
from logs.setup import setup_logging
from routes.hello_world import hello_world
from testing.playground import playground

import routes.slide as slide
import routes.pivot_table as pivot_table
import routes.image_slide as image_slide
import routes.report as report

from flask import Flask, request, jsonify
from typing import TypeVar
from dotenv import load_dotenv
from enum import Enum

import sys
import os

app = Flask(__name__)

hello_world(app)

app.register_blueprint(report.blueprint)
app.register_blueprint(pivot_table.blueprint)
app.register_blueprint(image_slide.blueprint)
app.register_blueprint(slide.blueprint)

T = TypeVar("T")
def item_or(_list: list[T], index: int, default: T) -> T:
    if index >= len(_list): return default
    return _list[index]

class RunningMode(Enum):
    DEVELOPMENT_MODE = "dev"
    RELEASE_MODE = "release"
    PLAYGROUND_MODE = "playground"
    NONE = "none"

DynamicVariables.initialize(
    application_root_directory=item_or(_list=sys.argv, index=3, default=os.path.dirname(__file__)),
    executable_directory=os.path.dirname(__file__))
setup_logging()
validate_assets()
load_dotenv()

def _get_running_mode() -> RunningMode:
    if __name__ != '__main__': return RunningMode.NONE
    running_mode = item_or(_list=sys.argv, index=1, default="dev")
    running_mode = RunningMode(running_mode)
    return running_mode

running_mode = _get_running_mode()

match running_mode:
    case RunningMode.RELEASE_MODE:
        from waitress import serve

        port = int(sys.argv[2])
        serve(app=app, port=port)

    case RunningMode.DEVELOPMENT_MODE:
        print("Running in dev mode")
        app.run(debug=True)

    case RunningMode.PLAYGROUND_MODE:
        print("Running the playground")
        playground()
