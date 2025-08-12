from lib.with_app_decorator import with_app
from lib.random_message import random_message, RandomMessageType

@with_app("/hello", methods=["POST", "GET"])
def hello_world():
    return { "message": random_message(RandomMessageType.HELLO_PROFESSOR) }, 200
