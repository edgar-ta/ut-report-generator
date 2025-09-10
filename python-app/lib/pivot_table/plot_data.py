import matplotlib.pyplot as plt
from typing import Literal

def plot_data(
        data, 
        title: str, 
        kind: Literal["bar"] | Literal["line"],
        x_label: str,
        y_label: str,
        filepath: str
        ):
    """
    Grafica un diccionario simple o doble usando matplotlib con etiquetas de valores.

    :param data: dict[str, float] o dict[str, dict[str, float]]
    :param title: título del gráfico
    :param kind: "bar" o "line"
    """
    plt.figure(figsize=(8, 5))

    # Caso 1: diccionario simple
    if all(isinstance(v, (int, float)) for v in data.values()):
        keys = list(data.keys())
        values = list(data.values())

        if kind == "bar":
            bars = plt.bar(keys, values)
            # Añadir etiquetas en barras
            for bar, value in zip(bars, values):
                plt.text(
                    bar.get_x() + bar.get_width() / 2,
                    bar.get_height(),
                    f"{value:.2f}",
                    ha="center", va="bottom"
                )
        elif kind == "line":
            plt.plot(keys, values, marker="o")
            # Añadir etiquetas en puntos
            for x, y in zip(keys, values):
                plt.text(x, y, f"{y:.2f}", ha="center", va="bottom")
        else:
            raise ValueError("kind debe ser 'bar' o 'line'")

    # Caso 2: diccionario doble
    elif all(isinstance(v, dict) for v in data.values()):
        outer_keys = list(data.keys())       # ej. meses
        inner_keys = list(next(iter(data.values())).keys())  # ej. métricas

        if kind == "bar":
            x = range(len(outer_keys))
            width = 0.8 / len(inner_keys)

            for idx, inner in enumerate(inner_keys):
                values = [data[outer][inner] for outer in outer_keys]
                bars = plt.bar(
                    [i + idx * width for i in x],
                    values,
                    width=width,
                    label=inner
                )
                # Añadir etiquetas en barras
                for bar, value in zip(bars, values):
                    plt.text(
                        bar.get_x() + bar.get_width() / 2,
                        bar.get_height(),
                        f"{value:.2f}",
                        ha="center", va="bottom"
                    )

            plt.xticks([i + 0.4 for i in x], outer_keys)

        elif kind == "line":
            for inner in inner_keys:
                values = [data[outer][inner] for outer in outer_keys]
                plt.plot(outer_keys, values, marker="o", label=inner)
                # Añadir etiquetas en puntos
                for x, y in zip(outer_keys, values):
                    plt.text(x, y, f"{y:.2f}", ha="center", va="bottom")

        plt.legend()

    else:
        raise ValueError("El formato de data no es soportado")

    plt.title(title)
    plt.xlabel(x_label)
    plt.ylabel(y_label)
    plt.tight_layout()
    plt.savefig(filepath)
