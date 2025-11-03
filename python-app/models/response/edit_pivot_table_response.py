from models.pivot_table.data_filter.self import DataFilter
from models.pivot_table.pivot_table_data import PivotTableData, pivot_table_data_from_json, pivot_table_data_to_dict

class EditPivotTable_Response:
    def __init__(self, data: PivotTableData, filters: list[DataFilter], preview: str):
        self.data = data
        self.filters = filters
        self.preview = preview

    def to_dict(self):
        return {
            "data": pivot_table_data_to_dict(self.data),
            "filters": [f.to_dict() for f in self.filters],
            "preview": self.preview
        }

    @classmethod
    def from_json(_class, json_data: dict):
        return _class(
            data=pivot_table_data_from_json(json_data["data"]),
            filters=[DataFilter.from_json(f) for f in json_data["filters"]],
            preview=json_data["preview"]
        )
