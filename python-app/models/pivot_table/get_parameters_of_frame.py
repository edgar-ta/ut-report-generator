from lib.unique_list import unique_list

from models.pivot_table.custom_indexer import CustomIndexer
from models.pivot_table.cross_section import cross_section

import pandas

def get_parameters_of_frame(frame: pandas.DataFrame, indexers: list[CustomIndexer]):
    result = {}
    for indexer in indexers:
        result[indexer.level] = unique_list(frame.index.get_level_values(level=indexer.level))

        if indexer == indexers[-1]: break
        frame = cross_section(data_frame=frame, key=indexer.values, level=indexer.level)
    return result
