class DescriptiveError(Exception):
    def __init__(self, http_error_code: int, message: str):
        self.http_error_code = http_error_code
        self.message = message
        super().__init__()
