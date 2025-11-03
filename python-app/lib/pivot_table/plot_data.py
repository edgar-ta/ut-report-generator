import matplotlib.pyplot as plt

from models.pivot_table.pivot_table_data import PivotTableData, PivotTableRod, PivotTableRodGroup

from typing import Literal

def plot_data(
        data: PivotTableData, 
        title: str, 
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

    if all(isinstance(datum, PivotTableRod) for datum in data):
        keys = [ datum.key for datum in data ]
        values = [ datum.value for datum in data ]

        bars = plt.bar(keys, values)
        for bar, value in zip(bars, values):
            plt.text(
                bar.get_x() + bar.get_width() / 2,
                bar.get_height(),
                f"{value:.2f}",
                ha="center", va="bottom"
            )

    elif all(isinstance(datum, PivotTableRodGroup) for datum in data):
        data.sort(key=lambda datum: datum.index)
        for group in data:
            group.rods.sort(key=lambda rod: rod.index)
        
        outer_keys = [ datum.key for datum in data ]
        inner_keys = [ rod.key for rod in data[0].rods ]

        x = range(len(outer_keys))
        width = 0.8 / len(inner_keys)

        for index, inner_key in enumerate(inner_keys):
            values = [ rod.value for datum in data for rod in datum.rods if rod.key == inner_key ]

            # values = [data[outer][inner_key] for outer in outer_keys]
            bars = plt.bar(
                [i + index * width for i in x],
                values,
                width=width,
                label=inner_key
            )
            
            for bar, value in zip(bars, values):
                plt.text(
                    bar.get_x() + bar.get_width() / 2,
                    bar.get_height(),
                    f"{value:.2f}",
                    ha="center", va="bottom"
                )

        plt.xticks([i + 0.4 for i in x], outer_keys)
        plt.legend()

    else:
        raise ValueError("El formato de data no es soportado")

    plt.title(title)
    plt.xlabel(x_label)
    plt.ylabel(y_label)
    plt.tight_layout()
    plt.savefig(filepath)
