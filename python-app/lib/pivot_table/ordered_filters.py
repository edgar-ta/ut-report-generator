from models.pivot_table.pivot_table_level import PivotTableLevel
from models.pivot_table.data_filter.self import DataFilter

def find_filter(level: PivotTableLevel, filters: list[DataFilter]):
    return next(_filter for _filter in filters if _filter.level == level)

def ordered_filters(filters_order: list[PivotTableLevel], filters: list[DataFilter]) -> list[DataFilter]:
    return [ find_filter(level=level, filters=filters) for level in filters_order ]
