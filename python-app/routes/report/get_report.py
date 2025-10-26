from lib.with_flask import with_flask
from lib.get_entities_from_request import entities_for_editing_report

from routes.route_map import SLIDESHOW

from flask import request
from pandas import Timestamp

import os

@with_flask(SLIDESHOW.GET.value, methods=["POST"])
def get_report():
    root_directory, report = entities_for_editing_report(request=request)

    now = Timestamp.now().to_pydatetime().timestamp()
    os.utime(root_directory, (now, now))

    return report.to_dict(), 200
