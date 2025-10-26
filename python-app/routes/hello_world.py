from lib.with_flask import with_flask
from lib.random_message import random_message, RandomMessageType

from routes.route_map import API_ROUTE

@with_flask(API_ROUTE.HELLO.value, methods=["POST", "GET"])
def hello_world():
    return { "message": random_message(RandomMessageType.HELLO_PROFESSOR) }, 200
