import pandas as pd
from enum import Enum

from models.pivot_table.custom_indexer import CustomIndexer
from models.pivot_table.aggregate_function_type import AggregateFunctionType
from models.pivot_table.filter_function_type import FilterFunctionType
from models.pivot_table.data_source import DataSource

class SlideCategory(Enum):
    PIVOT_TABLE = 0
    IMAGE = 1

class PivotTable():
    def __init__(
            self, 
            name: str, 
            identifier: str, 
            creation_date: pd.Timestamp, 
            last_edit: pd.Timestamp,
            preview: str | None,
            source: DataSource,
            arguments: list[CustomIndexer],
            parameters: list[CustomIndexer],
            data: dict,
            aggregate_function: AggregateFunctionType,
            filter_function: FilterFunctionType
            ) -> None:
        self.name = name
        self.identifier = identifier
        self.creation_date = creation_date
        self.last_edit = last_edit
        self.category = SlideCategory.PIVOT_TABLE
        self.preview = preview

        self.source = source
        self.arguments = arguments
        self.parameters = parameters
        self.data = data
        self.aggregate_function = aggregate_function
        self.filter_function = filter_function

    def to_dict(self) -> dict:
        return {
            "name": self.name,
            "identifier": self.identifier,
            "creation_date": self.creation_date.isoformat() if self.creation_date else None,
            "last_edit": self.last_edit.isoformat() if self.last_edit else None,
            "category": self.category.name if hasattr(self.category, "name") else str(self.category),
            "preview": self.preview,
            "source": self.source.to_dict() if hasattr(self.source, "to_dict") else str(self.source),
            "arguments": [a.to_dict() if hasattr(a, "to_dict") else str(a) for a in self.arguments],
            "parameters": [p.to_dict() if hasattr(p, "to_dict") else str(p) for p in self.parameters],
            "data": self.data,
            "aggregate_function": self.aggregate_function.name if hasattr(self.aggregate_function, "name") else str(self.aggregate_function),
            "filter_function": self.filter_function.name if hasattr(self.filter_function, "name") else str(self.filter_function),
        }
