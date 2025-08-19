class DataSource():
    def __init__(self, files: list[str], merged_file: str | None) -> None:
        self.files = files
        self.merged_file = merged_file
    