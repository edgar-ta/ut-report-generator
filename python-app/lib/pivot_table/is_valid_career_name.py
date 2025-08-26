import re

def is_valid_career_name(filename: str) -> bool:
    return re.match(pattern=r'\w+-\d\d', string=filename) is not None
