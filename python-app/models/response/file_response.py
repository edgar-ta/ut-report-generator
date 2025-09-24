from models.response.success_response import SuccessResponse

class FileResponse(SuccessResponse):
    def __init__(self, message, filepath: str):
        super().__init__(message)
        self.filepath = filepath
    
    def to_dict(self) -> dict[str, any]:
        return {
            **super().to_dict(),
            'filepath': self.filepath
        }
