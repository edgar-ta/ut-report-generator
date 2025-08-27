from lib.unique_list import unique_list

from models.pivot_table.custom_indexer import CustomIndexer
from lib.data_frame.cross_section import cross_section

import pandas

def get_parameters_of_frame(frame: pandas.DataFrame, arguments: list[CustomIndexer]) -> tuple[list[CustomIndexer], list[CustomIndexer]]:
    '''
    This function gets the available values for each level in the pivot table taking into
    consideration the current selection of the user, which is given in the `arguments` argument. 

    The function also generates a version of `arguments` that's a list of indexers with valid
    values for their respective levels. In case a `CustomIndexer` argument has values that don't 
    correspond to its level, a new `CustomIndexer` is created with the array of values that are
    present both in the original `CustomIndexer` and the appropriate level; if said array is empty,
    all of the values of the level are passed to the `CustomIndexer` instead. Otherwise, the 
    new indexer receives the values of the original one, and in any case the resulting indexer is
    added to a list which is returned at the end along with the parameters of the data frame.
    '''
    parameters = []
    valid_arguments = []

    for argument in arguments:
        parameters_of_level = unique_list(frame.index.get_level_values(level=argument.level.value))
        parameter = CustomIndexer(
            level=argument.level,
            values=parameters_of_level
            )
        parameters.append(parameter)

        argument_values = set(argument.values)
        parameter_values = set(parameter.values)
        argument_values = argument_values & parameter_values

        if len(argument_values) == 0:
            argument_values = parameter_values
        
        valid_argument = CustomIndexer(
            level=argument.level,
            values=list(argument_values)
            )
        valid_arguments.append(valid_argument)

        if argument == arguments[-1]: break

        frame = cross_section(
            data_frame=frame, 
            key=valid_argument.values, 
            level=argument.level.value
            )
    
    return (parameters, valid_arguments)
