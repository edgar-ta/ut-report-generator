import pandas as pd
from enum import Enum

from models.pivot_table.custom_indexer import CustomIndexer
from models.pivot_table.aggregate_function_type import AggregateFunctionType
from models.pivot_table.filter_function_type import FilterFunctionType
from models.pivot_table.data_source import DataSource
from models.pivot_table.slide_category import SlideCategory

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
            filter_function: FilterFunctionType,
            mode: SlideCategory
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
        self.mode = mode

    def to_dict(self) -> dict:
        print(__file__)
        print("@to_dict")
        print("Hello 1")
        print(f'{self.parameters = }')
        print(f'{self.arguments = }')
        print(f'{repr(self.source) = }')

        my_dict = {
            "name": self.name,
            "identifier": self.identifier,
            "creation_date": self.creation_date.isoformat(),
            "last_edit": self.last_edit.isoformat(),
            "category": self.category.name,
            "preview": self.preview,
            "source": self.source.to_dict(),
            "arguments": [argument.to_dict() for argument in self.arguments],
            "parameters": [parameter.to_dict() for parameter in self.parameters],
            "data": self.data,
            "aggregate_function": self.aggregate_function.name,
            "filter_function": self.filter_function.name,
            "mode": self.mode.name
        }

        print(__file__)
        print("@to_dict")
        print("Hello 2")

        return my_dict
