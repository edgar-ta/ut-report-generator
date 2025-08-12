from lib.descriptive_error import DescriptiveError

from functools import wraps

def with_app(*flask_args, **flask_kwargs):
    def decorator(function):
        @wraps(function)
        def needs_app(app):
            print(f"Hooking up the app to the '{function.__name__}' route")
            @app.route(*flask_args, **flask_kwargs)
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
        return needs_app
    return decorator
