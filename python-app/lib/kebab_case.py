def kebab_case(name: str) -> str:
    name = name.translate(str.maketrans('ÁÉÍÓÚÜáéíóúü', 'AEIOUUaeiouu', '[]()\\/-#$,.-_{}*+=!"%&´¨~`^:;|°¬¿?\''))
    name = name.lower()
    name = "-".join(name.split())
    return name
