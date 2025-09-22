class ImageSlideParameter():
    def __init__(self, value: str, readable_name: str, _type: str):
        self.value = value
        self.readable_name = readable_name
        self.type = _type
    
    def to_dict(self) -> dict[str, any]:
        return {
            'value': self.value,
            'readable_name': self.readable_name,
            'type': self.type
        }
