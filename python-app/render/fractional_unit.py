class FractionalUnit():
    def __init__(self, count: int):
        if count <= 0 or not isinstance(count, int):
            raise ValueError("La fracción tiene que ser un entero positivo")
        self.count = count