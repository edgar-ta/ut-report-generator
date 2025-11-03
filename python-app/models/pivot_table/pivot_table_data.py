from models.pivot_table.pivot_table_level import PivotTableLevel

ColorType = str

class PseudoFilter():
    def __init__(self, level: PivotTableLevel, values: str):
        self.level = level
        self.values = values
    
    def to_dict(self):
        return {
            'level': self.level,
            'values': self.values
        }

class PivotTableRod():
    def __init__(self, key: str, value: float, index: int, color: ColorType, missing: bool):
        self.key = key
        self.value = value
        self.index = index
        self.missing = missing
        self.color = color
    
    def to_dict(self):
        return {
            'key': self.key,
            'value': self.value,
            'missing': self.missing,
            'index': self.index,
            'color': self.color,
        }

class PivotTableRodGroup():
    def __init__(self, key: str, rods: list[PivotTableRod], index: int):
        self.key = key
        self.rods = rods
        self.index = index
    
    def to_dict(self):
        return {
            'key': self.key,
            'rods': [ rod.to_dict() for rod in self.rods ],
            'index': self.index
        }

PivotTableData = list[PivotTableRod] | list[PivotTableRodGroup]

def pivot_table_data_from_json(json) -> PivotTableData:
    if isinstance(json, list):
        if json and isinstance(json[0], dict) and 'key' in json[0] and 'rods' in json[0] and 'index' in json[0]:
            return [
                PivotTableRodGroup(
                    key=item['key'],
                    rods=[PivotTableRod(**rod) for rod in item['rods']],
                    index=item['index']
                )
                for item in json
            ]
        else:
            # Asume que es una lista de PivotTableRod
            return [PivotTableRod(**item) for item in json]
    raise ValueError("Formato de datos de tabla dinámica no reconocido")

def pivot_table_data_to_dict(data: PivotTableData) -> list[dict]:
    return [ datum.to_dict() for datum in data ]
