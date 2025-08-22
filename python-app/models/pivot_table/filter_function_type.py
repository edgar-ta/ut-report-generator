from typing import Callable
from enum import Enum, auto

class FilterFunctionType(Enum):
    FAILED_STUDENTS = "failedStudents"
    APPROVED_STUDENTS = "approvedStudents"
    ALL_STUDENTS = "allStudents"

    @classmethod
    def function_from_member(cls, member: "FilterFunctionType") -> Callable[[float], bool]:
        match member:
            case FilterFunctionType.FAILED_STUDENTS:
                return lambda x: x < 7
            case FilterFunctionType.APPROVED_STUDENTS:
                return lambda x: x >= 7
            case FilterFunctionType.ALL_STUDENTS:
                return lambda _: True
