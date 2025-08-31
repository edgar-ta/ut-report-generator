from lib.descriptive_error import DescriptiveError
from lib.group_name import inscription_year_of_group

from models.pivot_table.pivot_table_level import PivotTableLevel

from typing import Literal

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

import re
import matplotlib
import textwrap

matplotlib.use("Agg")

NUMBER_HEADER = "NO."
EXPEDIENTE_HEADER = "EXPEDIENTE"
NAME_HEADER = "NOMBRE"

LEFT_COLUMN_HEADERS = [ NUMBER_HEADER, EXPEDIENTE_HEADER, NAME_HEADER ]
UNIT_TYPES = [  "Letra", "Número" ]

def create_unit_name(index: int) -> str:
    return f"Unidad {index + 1}"

def get_grades_statistics(
    dirty_subjects: list,
    dirty_professors: list,
    dirty_units: list    
    ) -> tuple[list[str], list[str], list[int], int]:

    subject_names = [ subject for subject in dirty_subjects if type(subject) == str ]
    professor_names = [ professor for professor in dirty_professors if type(professor) == str ]
    units_list = [ unit for unit in dirty_units if type(unit) == str ]

    units_per_subject = get_units_per_subject(units_list)
    max_units = max(units_per_subject)
    
    return (subject_names, professor_names, units_per_subject, max_units)

def get_units_per_subject(units_list: list[str]) -> list[int]:
    units_per_subject = []
    current_index = 0

    for unit in units_list:
        unit_index = int(re.search(r"(\d)", unit).group(1))
        if unit_index == current_index + 1:
            current_index += 1
        elif unit_index < current_index:
            units_per_subject.append(current_index)
            current_index = 1
    
    units_per_subject.append(current_index)
    return units_per_subject

def create_clean_index(group_name: str, subject_names: list[str], professor_names: list[str], units_per_subject: list[int]) -> pd.MultiIndex:
    year = inscription_year_of_group(group_name=group_name)
    grades_header = [ 
        (group_name, str(year), subject, professor, f"Unidad {index + 1}", grade_type) 
        for subject, professor, units_count in zip(subject_names, professor_names, units_per_subject)
            for index in range(units_count)
                for grade_type in UNIT_TYPES
    ]
    header_levels = len(grades_header[0])
    header_names = [ 
        PivotTableLevel.GROUP.value,
        PivotTableLevel.YEAR.value,
        PivotTableLevel.SUBJECT.value,
        PivotTableLevel.PROFESSOR.value,
        PivotTableLevel.UNIT.value,
        PivotTableLevel.GRADE_TYPE.value,
        ]
    if len(header_names) != header_levels:
        raise DescriptiveError(http_error_code=500, message=f"El arreglo de nombres para los niveles del data frame no tiene el número de valores necesarios. Se esperaba {header_levels}, pero se obtuvieron {len(header_names)}")
    return pd.MultiIndex.from_arrays(list(zip(*grades_header)), names=header_names)

def get_clean_data_frame(data_frame: pd.DataFrame, group_name: str) -> pd.DataFrame:
    dirty_subjects = data_frame.iloc[0].to_list()
    dirty_professors = data_frame.iloc[2].to_list()
    dirty_units = data_frame.iloc[3].to_list()

    subject_names, professor_names, units_per_subject, max_units = get_grades_statistics(
        dirty_subjects=dirty_subjects,
        dirty_professors=dirty_professors,
        dirty_units=dirty_units
        )

    clean_index = create_clean_index(
        group_name=group_name, 
        subject_names=subject_names, 
        professor_names=professor_names, 
        units_per_subject=units_per_subject
        )
    
    data_frame = data_frame.iloc[4:]
    data_frame.columns = clean_index

    data_frame = data_frame.T
    data_frame = data_frame.xs(key="Número", level=PivotTableLevel.GRADE_TYPE.value)
    data_frame = data_frame.map(func=lambda value: abs(value))

    return data_frame

def graph_failure_rate(grades: pd.DataFrame, image_name: str):
    def wrap_text(text, width):
        return "\n".join(textwrap.wrap(text, width))

    grades_per_professor = pd.DataFrame({
        "Estudiantes Reprobados": grades[grades < 7].count(axis=1),
    })

    ax = grades_per_professor.plot.bar(legend=False, figsize=(10, 6), color="skyblue")

    ax.set_xticks(range(len(grades_per_professor)))
    ax.set_xticklabels(
        [
            f"{wrap_text(subject, 25).capitalize()}\n\n{wrap_text(professor, 15).title()}"  # Wrap long names
            for subject, professor in grades_per_professor.index
        ],
        rotation=0,
        fontsize=10,
        ha="center",
    )

    max_value = grades_per_professor["Estudiantes Reprobados"].max()
    y_max = max(10, (max_value + 4) // 5 * 5)  # Closest multiple of 5 or 10
    ax.set_ylim(0, y_max)
    ax.yaxis.set_major_locator(plt.MultipleLocator(1 if y_max <= 10 else 5))  # Integer ticks

    ax.set_title("Tasa de Reprobación por Materia y Profesor", fontsize=14, pad=20)
    ax.set_xlabel("Materias y Profesores", fontsize=12)
    ax.set_ylabel("Número de Estudiantes Reprobados", fontsize=12)

    ax.set_facecolor("none")
    ax.figure.set_facecolor("none")

    plt.tight_layout(pad=1)

    plt.savefig(image_name, transparent=True)
    plt.close()

if __name__ == '__main__':
    # Example usage

    data_frame = None
    file_path = r"D:\college\cuatrimestre-6\2025-06-16--estadias\ut-report-generator\source\.logistics-assets\data-converted.xlsx"
    try:
        data_frame = pd.read_excel(file_path, header=[0, 1, 2, 3, 4])
    except FileNotFoundError:
        raise "File not found"
     
    try:
        graph_failure_rate(data_frame, None)
    except Exception as e:
        raise f"Error processing file: {str(e)}"
