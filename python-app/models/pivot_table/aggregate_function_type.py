from enum import Enum, auto
from numpy import average

class AggregateFunctionType(Enum):
    COUNT = auto()
    AVERAGE = auto()
    MIN = auto()
    MAX = auto()
