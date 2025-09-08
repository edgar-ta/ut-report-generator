import pandas as pd

from models.pivot_table.aggregate_function_type import AggregateFunctionType
from models.pivot_table.filter_function_type import FilterFunctionType
from models.pivot_table.pivot_table_level import PivotTableLevel
from models.pivot_table.data_source import DataSource
from models.pivot_table.data_filter.self import DataFilter
from models.slide.slide_category import SlideCategory

class PivotTable():
    def __init__(
            self, 
            name: str, 
            identifier: str, 
            creation_date: pd.Timestamp, 
            last_edit: pd.Timestamp,
            preview: str,
            filters: list[DataFilter],
            filters_order: list[PivotTableLevel],
            source: DataSource,
            data: dict[str, dict[str, float]] | dict[str, float],
            aggregate_function: AggregateFunctionType,
            filter_function: FilterFunctionType,
            mode: SlideCategory
            ) -> None:
        
        self.name = name
        self.identifier = identifier
        self.creation_date = creation_date
        self.last_edit = last_edit
        self.preview = preview
        self.category = SlideCategory.PIVOT_TABLE

        self.filters = filters
        self.filters_order = filters_order
        self.source = source
        self.data = data
        self.aggregate_function = aggregate_function
        self.filter_function = filter_function
        self.mode = mode

    def to_dict(self) -> dict:
        return {
            "name": self.name,
            "identifier": self.identifier,
            "creation_date": self.creation_date.isoformat(),
            "last_edit": self.last_edit.isoformat(),
            "preview": self.preview,
            "category": self.category.value,

            "filters": [f.to_dict() for f in self.filters],
            "filters_order": [ level.value for level in self.filters_order ],
            "source": self.source.to_dict(),
            "data": self.data,
            "aggregate_function": self.aggregate_function.value,
            "filter_function": self.filter_function.value,
            "mode": self.mode.value
        }
    
    @staticmethod
    def from_no_preview(
        name: str, 
        identifier: str, 
        creation_date: pd.Timestamp, 
        last_edit: pd.Timestamp,
        filters: list[DataFilter],
        filters_order: list[PivotTableLevel],
        source: DataSource,
        data: dict[str, dict[str, float]] | dict[str, float],
        aggregate_function: AggregateFunctionType,
        filter_function: FilterFunctionType,
        mode: SlideCategory
        ):
        # preview = 
        pass

    @classmethod
    def from_json(cls, json_data: dict[str, any]) -> "PivotTable":
        filters = [
            DataFilter.from_json(f) 
            for f in json_data.get("filters", [])
        ]

        raw_data = json_data.get("data", {})
        if not isinstance(raw_data, dict):
            raise ValueError("Expected 'data' to be a dictionary")

        if raw_data and isinstance(next(iter(raw_data.values())), dict):
            data: dict[str, dict[str, float]] = {
                k: {ik: float(iv) for ik, iv in v.items()}
                for k, v in raw_data.items()
            }
        else:
            data: dict[str, float] = {
                k: float(v) for k, v in raw_data.items()
            }

        return cls(
            name=json_data["name"],
            identifier=json_data["identifier"],
            creation_date=pd.Timestamp(json_data["creation_date"]),
            last_edit=pd.Timestamp(json_data["last_edit"]),
            preview=json_data.get("preview"),

            filters=filters,
            filters_order=[ PivotTableLevel(level) for level in json_data.get("filters_order", []) ],
            source=DataSource.from_json(json_data["source"]),
            data=data,
            aggregate_function=AggregateFunctionType(json_data["aggregate_function"]),
            filter_function=FilterFunctionType(json_data["filter_function"]),
            mode=SlideCategory(json_data["mode"])
        )
