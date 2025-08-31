from models.pivot_table.data_filter.self import DataFilter

def is_valid_filter(_filter: DataFilter) -> bool:
    return _filter.selected_values.__len__() > 0 or _filter.possible_values.__len__() > 0
