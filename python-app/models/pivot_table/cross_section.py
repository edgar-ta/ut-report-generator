import pandas

def cross_section(data_frame: pandas.DataFrame, key: list[str] | None, level: str) -> pandas.DataFrame:
    if key is None:
        return data_frame
    match key:
        case [key]:
            return data_frame.xs(key=key, level=level)
        case _:
            equivalent_index = data_frame.index.names.index(level)
            return data_frame.loc[
                tuple(
                    key
                    if i == equivalent_index
                    else slice(None)
                    for i in range(len(data_frame.index.names))
                ),
                :
            ]
