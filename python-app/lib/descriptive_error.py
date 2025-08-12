class DescriptiveError(Exception):
    def __init__(self, http_error_code: int, message: str):
        self.http_error_code = http_error_code
        self.message = message
        super().__init__()
    
    def __str__(self):
        return f'''
---ERROR
|STATUS: 
|{self.http_error_code}
|
|MESSAGE:
{"\n".join([ f'|{line}' for line in self.message.split("\n")])}
---
'''
