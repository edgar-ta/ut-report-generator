import pandas
import os

def import_data_frame(file_path: str, key: str) -> pandas.DataFrame:
    return pandas.read_hdf(path_or_buf=file_path, key=key)

def export_data_frame(data_frame: pandas.DataFrame, file_path: str, key: str) -> None:
    data_frame.to_hdf(path_or_buf=file_path, key=key, format='table', mode='w')
