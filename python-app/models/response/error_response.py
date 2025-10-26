class ErrorResponse():
    def __init__(self, error: str):
        self.error = error
    
    def to_dict(self):
        return { 'error': self.error }