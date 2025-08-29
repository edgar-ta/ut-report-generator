from models.pivot_table.pivot_table_level import PivotTableLevel

def bring_filter_up(filters: list[PivotTableLevel], edited_filter: PivotTableLevel):
    _filters = [ _filter for _filter in filters if _filter is not edited_filter ]
    _filters.insert(0, edited_filter)
    return _filters
