from collections import OrderedDict
from collections.abc import Iterable
from typing import TypeVar, List

T = TypeVar('T')

def unique_list(original_iterable: Iterable[T]) -> List[T]:
    '''Return a list with unique elements, preserving the order in which the unique elements are found in the iterable.'''
    return list(OrderedDict.fromkeys(original_iterable))
