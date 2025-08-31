from lib.descriptive_error import DescriptiveError

from functools import wraps
from flask import Flask, Blueprint

def with_flask(*flask_args, **flask_kwargs):
    def decorator(function):
        @wraps(function)
        def needs_flask(_flask: Flask | Blueprint):
            print(f"Hooking up the app to the '{function.__name__}' route")
            @_flask.route(*flask_args, **flask_kwargs)
            @wraps(function)
            def inner():
                try:
                    return function()
                except Exception as e:
                    print(f"Error ocurred with route of function {function.__name__}:")
                    print(f"{e = }")
                    print(e)
                    if type(e) == DescriptiveError:
                        return {"error": e.message}, e.http_error_code
                    else:
                        return {"error": str(e)}, 500
            return inner
        return needs_flask
    return decorator
