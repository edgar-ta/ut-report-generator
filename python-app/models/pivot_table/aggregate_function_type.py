from enum import Enum, auto
from numpy import average

from typing import Callable

import pandas

class AggregateFunctionType(Enum):
    COUNT = "count"
    AVERAGE = "average"
    MIN = "min"
    MAX = "max"

    @classmethod
    def function_from_member(cls, member: "AggregateFunctionType") -> Callable[[pandas.Series], float]:
        match member:
            case AggregateFunctionType.COUNT:
                return lambda values: values.size
            case AggregateFunctionType.AVERAGE:
                return lambda values: values.mean()
            case AggregateFunctionType.MIN:
                return lambda values: values.min()
            case AggregateFunctionType.MAX:
                return lambda values: values.max()

def aggregate_function_to_spanish(function_type: AggregateFunctionType) -> str:
    match function_type:
        case AggregateFunctionType.COUNT:
            return "Conteo"
        case AggregateFunctionType.AVERAGE:
            return "Promedio"
        case AggregateFunctionType.MIN:
            return "Mínimo"
        case AggregateFunctionType.MAX:
            return "Máximo"
        case _:
            raise ValueError(f"Tipo de función desconocido: {function_type}")
