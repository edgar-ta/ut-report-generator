from lib.descriptive_error import DescriptiveError

def get_or_panic(object: dict[str, any], key: str, error_message: str, error_code: int = 400) -> any:
    '''
    Tries to get a property from an object or raises an error if it does not exist.
    '''
    if key in object:
        return object[key]
    else:
        raise DescriptiveError(error_code, error_message)
