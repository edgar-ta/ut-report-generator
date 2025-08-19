import pandas as pd
from enum import Enum
from models.pivot_table.custom_indexer import CustomIndexer

class SlideCategory(Enum):
    PIVOT_TABLE = 0
    IMAGE = 1

class DataSource():
    def __init__(self, files: list[str], merged_file: str | None) -> None:
        self.files = files
        self.merged_file = merged_file

class PivotTable():
    def __init__(
            self, 
            name: str, 
            identifier: str, 
            creation_date: pd.Timestamp, 
            last_edit: pd.Timestamp,
            data_source: DataSource,
            arguments: list[CustomIndexer],
            parameters: list[CustomIndexer],
            data: dict,
            preview: str | None
            ) -> None:
        self.name = name
        self.identifier = identifier
        self.creation_date = creation_date
        self.last_edit = last_edit
        self.category = SlideCategory.PIVOT_TABLE
        self.preview = preview

        self.source = data_source
        self.arguments = arguments
        self.parameters = parameters
        self.data = data
        self.aggregate_function
