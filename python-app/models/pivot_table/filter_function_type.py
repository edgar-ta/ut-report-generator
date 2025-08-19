from enum import Enum

class FilterFunctionType(Enum):
    FAILED_STUDENTS = lambda x: x < 7
    APPROVED_STUDENTS = lambda x: x >= 7
    ALL_STUDENTS = lambda _: True
