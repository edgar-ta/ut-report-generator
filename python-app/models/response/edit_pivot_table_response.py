from models.pivot_table.data_filter.self import DataFilter
from models.pivot_table.pivot_data import PivotData

class EditPivotTable_Response:
    def __init__(self, data: PivotData, filters: list[DataFilter]):
        self.data = data
        self.filters = filters

    def to_dict(self):
        return {
            "data": self.data,
            "filters": [f.to_dict() for f in self.filters]
        }
