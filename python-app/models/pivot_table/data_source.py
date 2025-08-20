from types import SimpleNamespace

class DataSource(SimpleNamespace):
    def __init__(self, files: list[str], merged_file: str | None) -> None:
        self.files = files
        self.merged_file = merged_file
    
    def to_dict(self) -> dict:
        return {
            "files": self.files,
            "merged_file": self.merged_file
        }

    @classmethod
    def from_json(cls, json_data: dict[str, any]) -> "DataSource":
        return cls(
            files=json_data.get("files", []),
            merged_file=json_data.get("merged_file")
        )
