from models.pivot_table.data_filter.self import DataFilter

def get_valid_values(_filter: DataFilter) -> list[str]:
    if _filter.selected_values.__len__() > 0:
        return _filter.selected_values
    return _filter.possible_values
