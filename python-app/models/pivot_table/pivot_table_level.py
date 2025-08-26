from enum import Enum

class PivotTableLevel(Enum):
    GROUP = "group"
    YEAR = "year"
    SUBJECT = "subject"
    PROFESSOR = "professor"
    UNIT = "unit"
    GRADE_TYPE = "gradeType"
