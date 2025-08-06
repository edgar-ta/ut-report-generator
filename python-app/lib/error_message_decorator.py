from lib.descriptive_error import DescriptiveError

def error_message_decorator(global_message: str, logger):
    def decorator(function):
        def decorated_function(*args, **kwargs):
            try:
                return function(*args, **kwargs)
            except DescriptiveError as error:
                error.add_note(global_message)
                logger.error(error)
                return global_message, error.http_error_code
            except Exception as error:
                error.add_note(global_message)
                logger.error(error)
                return global_message, 500
        return decorated_function
    return decorator
