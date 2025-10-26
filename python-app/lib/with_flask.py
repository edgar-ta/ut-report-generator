from models.error.descriptive_error import DescriptiveError
from models.response.error_response import ErrorResponse

from functools import wraps
from flask import Flask, Blueprint, current_app

def with_flask(*flask_args, **flask_kwargs):
    def decorator(function):
        @wraps(function)
        def needs_flask(_flask: Flask | Blueprint):
            @_flask.route(*flask_args, **flask_kwargs)
            @wraps(function)
            def inner():
                current_app.logger.info(f"Procesando una solicitud en la ruta de la función {function.__name__}")
                try:
                    response, status = function()
                    match status // 100:
                        case 2:
                            current_app.logger.info(f"La solicitud fue exitosa")
                        case 4:
                            current_app.logger.info("La solicitud tuvo un error por parte del cliente")
                        case 5:
                            current_app.logger.info("La solicitud tuvo un error por parte del servidor")
                    current_app.logger.info(f"El resultado fue éste\n{response}")

                    return response, status
                except Exception as e:
                    current_app.logger.error(f"Un error ocurrió con la ruta de la función {function.__name__}")
                    current_app.logger.error(f"{e = }")
                    if type(e) == DescriptiveError:
                        current_app.logger.error(e.message)
                        return ErrorResponse(error=e.message).to_dict(), e.http_error_code
                    else:
                        return ErrorResponse(error=str(e)).to_dict(), 500
            return inner
        return needs_flask
    return decorator
