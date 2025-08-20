from enum import Enum, auto

class FilterFunctionType(Enum):
    FAILED_STUDENTS = auto()
    APPROVED_STUDENTS = auto()
    ALL_STUDENTS = auto()
