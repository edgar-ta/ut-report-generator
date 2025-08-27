from models.pivot_table.pivot_table_level import PivotTableLevel
from models.pivot_table.data_filter.selection_mode import SelectionMode
from models.pivot_table.data_filter.charting_mode import ChartingMode

class DataFilter:
    def __init__(
        self,
        level: PivotTableLevel,
        selected_values: list[str],
        possible_values: list[str],
        selection_mode: SelectionMode,
        charting_mode: ChartingMode,
    ):
        self.level = level
        self.selected_values = selected_values
        self.possible_values = possible_values
        self.selection_mode = selection_mode
        self.charting_mode = charting_mode

    def to_dict(self) -> dict[str, any]:
        """
        Serializa la instancia a un diccionario (listo para JSON).
        """
        return {
            "level": self.level.value,
            "selected_values": self.selected_values,
            "possible_values": self.possible_values,
            "selection_mode": self.selection_mode.value,
            "charting_mode": self.charting_mode.value,
        }

    @classmethod
    def from_json(cls, json: dict) -> "DataFilter":
        """
        Crea una instancia de DataFilter desde un diccionario JSON.
        """
        return cls(
            level=PivotTableLevel(json["level"]),
            selected_values=list(json.get("selected_values", [])),
            possible_values=list(json.get("possible_values", [])),
            selection_mode=SelectionMode(json["selection_mode"]),
            charting_mode=ChartingMode(json["charting_mode"]),
        )
