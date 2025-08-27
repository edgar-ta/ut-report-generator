import pandas

def flatten_to_series(obj: pandas.DataFrame | pandas.Series) -> pandas.Series:
    if isinstance(obj, pandas.DataFrame):
        return pandas.Series(obj.values.flatten())
    elif isinstance(obj, pandas.Series):
        return obj.copy()
    else:
        raise TypeError("Expected a pandas DataFrame or Series")
    