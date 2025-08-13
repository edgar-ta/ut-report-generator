from lib.descriptive_error import DescriptiveError

from enum import Enum

class RandomMessageType(Enum):
    REPORT_GENERATED = "report_generated"
    HELLO_PROFESSOR = "hello_professor"
    EXPORT_SUCCESFUL = "export_succesful"

def random_message(_type: RandomMessageType) -> str:
    if _type == RandomMessageType.REPORT_GENERATED:
        return "El reporte se generó exitosamente"
    elif _type == RandomMessageType.HELLO_PROFESSOR:
        return "Hola profesor, ¿cómo está?"
    elif _type == RandomMessageType.EXPORT_SUCCESFUL:
        return "El reporte se exportó correctamente"
    else:
        raise DescriptiveError(500, "El tipo de mensaje no se reconoció")
