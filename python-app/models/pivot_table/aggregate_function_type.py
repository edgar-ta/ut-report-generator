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
