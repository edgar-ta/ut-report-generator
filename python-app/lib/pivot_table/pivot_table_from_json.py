from lib.slide.slide_from_json import slide_from_json

from models.pivot_table.self import PivotTable
from models.pivot_table.aggregate_function_type import AggregateFunctionType
from models.pivot_table.filter_function_type import FilterFunctionType
from models.pivot_table.pivot_table_level import PivotTableLevel
from models.pivot_table.data_source import DataSource
from models.pivot_table.data_filter.self import DataFilter

def pivot_table_from_json(json: dict[str, any]) -> PivotTable:
    slide = slide_from_json(json=json)

    filters = [
        DataFilter.from_json(f) 
        for f in json.get("filters", [])
    ]

    raw_data = json.get("data", {})
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

    return PivotTable(
        **slide,
        bare_preview=json['bare_preview'],
        filters=filters,
        filters_order=[ PivotTableLevel(level) for level in json.get("filters_order", []) ],
        source=DataSource.from_json(json["source"]),
        data=data,
        aggregate_function=AggregateFunctionType(json["aggregate_function"]),
        filter_function=FilterFunctionType(json["filter_function"]),
    )
