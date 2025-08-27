import pandas

def lenient_cross_section(data_frame: pandas.DataFrame, key: list[str], level: str) -> pandas.DataFrame:
    try:
        return cross_section(data_frame=data_frame, key=key, level=level)
    except KeyError as e:
        print(e)
        new_frame = pandas.DataFrame(index=data_frame.index)
        return new_frame

def cross_section(data_frame: pandas.DataFrame, key: list[str], level: str) -> pandas.DataFrame:
    match key:
        case []:
            return data_frame
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
