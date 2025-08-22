from lib.unique_list import unique_list

from models.pivot_table.custom_indexer import CustomIndexer
from lib.cross_section import cross_section

import pandas

def get_parameters_of_frame(frame: pandas.DataFrame, indexers: list[CustomIndexer]) -> list[CustomIndexer]:
    result_indexers = []
    for indexer in indexers:
        result_indexer = CustomIndexer(
            level=indexer.level,
            values=unique_list(frame.index.get_level_values(level=indexer.level.value))
        )
        result_indexers.append(result_indexer)

        if indexer == indexers[-1]: break
        frame = cross_section(data_frame=frame, key=indexer.values, level=indexer.level.value)
    
    return result_indexers
