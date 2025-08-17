import random
from enum import Enum
from lib.descriptive_error import DescriptiveError


class RandomMessageType(Enum):
    REPORT_GENERATED = "report_generated"
    HELLO_PROFESSOR = "hello_professor"
    EXPORT_SUCCESFUL = "export_succesful"


_MESSAGES: dict[RandomMessageType, list[str]] = {
    RandomMessageType.REPORT_GENERATED: [
        "El reporte se generó exitosamente",
        "¡Reporte listo! Puedes revisarlo ahora.",
        "Tu reporte fue creado sin problemas."
    ],
    RandomMessageType.HELLO_PROFESSOR: [
        "Hola profesor, ¿cómo está?",
        "¡Buenos días, profesor!",
        "Un gusto verlo, profesor."
    ],
    RandomMessageType.EXPORT_SUCCESFUL: [
        "El reporte se exportó correctamente",
        "La exportación fue exitosa",
        "Tu archivo ya está listo para compartir."
    ]
}

def random_message(_type: RandomMessageType) -> str:
    messages = _MESSAGES.get(_type)
    if not messages:
        raise DescriptiveError(500, f"El tipo de mensaje no se reconoció: {_type}")
    return random.choice(messages)
