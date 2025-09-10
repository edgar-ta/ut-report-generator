from enum import Enum

class PivotTableLevel(Enum):
    GROUP = "group"
    YEAR = "year"
    SUBJECT = "subject"
    PROFESSOR = "professor"
    UNIT = "unit"
    GRADE_TYPE = "gradeType"

def level_to_spanish(level: PivotTableLevel):
    match level:
        case PivotTableLevel.GROUP:
            return "Grupo"
        case PivotTableLevel.SUBJECT:
            return "Materia"
        case PivotTableLevel.PROFESSOR:
            return "Profesor"
        case PivotTableLevel.UNIT:
            return "Unidad"
        case PivotTableLevel.GRADE_TYPE:
            return "Tipo de calificación"
        case _:
            raise ValueError(f"Nivel desconocido: {level}")
