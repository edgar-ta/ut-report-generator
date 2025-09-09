class SuccessResponse():
    def __init__(self, message: str):
        self.message = message
    
    def to_dict(self) -> dict:
        return { "message": self.message }
    