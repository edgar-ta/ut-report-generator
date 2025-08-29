def ordered_filters(filters_order: list[PivotTableLevel], filters: list[DataFilter]) -> list[DataFilter]:
    find_filter = lambda level: next(_filter for _filter in filters if _filter.level == level)
    return [ find_filter(level) for level in filters_order ]