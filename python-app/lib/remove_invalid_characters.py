def remove_invalid_characters(string: str) -> str:
    '''
    Removes characters that aren't allowed in the name of a file or directory
    by the file system
    '''
    return string.translate(str.maketrans('', '', '[]()\\/-#$,.-_{}*+="%&´¨~`^:;|°¬¿?\'¡!'))
