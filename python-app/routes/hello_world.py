from lib.with_flask import with_flask
from lib.random_message import random_message, RandomMessageType

@with_flask("/hello", methods=["POST", "GET"])
def hello_world():
    return { "message": random_message(RandomMessageType.HELLO_PROFESSOR) }, 200
