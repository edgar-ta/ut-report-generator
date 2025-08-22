import pandas as pd
from enum import Enum

from models.pivot_table.custom_indexer import CustomIndexer
from models.pivot_table.aggregate_function_type import AggregateFunctionType
from models.pivot_table.filter_function_type import FilterFunctionType
from models.pivot_table.data_source import DataSource

from models.slide_category import SlideCategory

class PivotTable():
    def __init__(
            self, 
            name: str, 
            identifier: str, 
            creation_date: pd.Timestamp, 
            last_edit: pd.Timestamp,
            preview: str | None,
            arguments: list[CustomIndexer],
            source: DataSource,
            parameters: list[CustomIndexer],
            data: dict,
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

        self.arguments = arguments
        self.source = source
        self.parameters = parameters
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
            "category": self.category.value,
            "preview": self.preview,
            "source": self.source.to_dict(),
            "arguments": [argument.to_dict() for argument in self.arguments],
            "parameters": [parameter.to_dict() for parameter in self.parameters],
            "data": self.data,
            "aggregate_function": self.aggregate_function.value,
            "filter_function": self.filter_function.value,
            "mode": self.mode.value
        }

    @classmethod
    def from_json(cls, json_data: dict[str, any]) -> "PivotTable":
        return cls(
            name=json_data["name"],
            identifier=json_data["identifier"],
            creation_date=pd.Timestamp(json_data["creation_date"]),
            last_edit=pd.Timestamp(json_data["last_edit"]),
            preview=json_data.get("preview"),
            arguments=[CustomIndexer.from_json(arg) for arg in json_data.get("arguments", [])],
            source=DataSource.from_json(json_data["source"]),
            parameters=[CustomIndexer.from_json(param) for param in json_data.get("parameters", [])],
            data=json_data.get("data", {}),
            aggregate_function=AggregateFunctionType(json_data["aggregate_function"]),
            filter_function=FilterFunctionType(json_data["filter_function"]),
            mode=SlideCategory(json_data["mode"])
        )
