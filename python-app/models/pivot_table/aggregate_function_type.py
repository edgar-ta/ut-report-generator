from enum import Enum
from numpy import average

class AggregateFunctionType(Enum):
    COUNT = lambda frame: len(frame)
    AVERAGE = lambda frame: average(frame)
    MIN = lambda frame: min(frame)
    MAX = lambda frame: max(frame)
    
