from lib.descriptive_error import DescriptiveError
from lib.unique_list import unique_list
from io import TextIOWrapper
import pandas as pd
import re
from typing import Literal
import matplotlib.pyplot as plt
import time

NUMBER_HEADER = "NO."
EXPEDIENTE_HEADER = "EXPEDIENTE"
NAME_HEADER = "NOMBRE"

LEFT_COLUMN_HEADERS = [ NUMBER_HEADER, EXPEDIENTE_HEADER, NAME_HEADER ]
UNIT_TYPES = [  "Letra", "Número" ]

def read_excel(filename: str) -> pd.DataFrame:
    try:
        data_frame = pd.read_excel(filename, header=[0, 1, 2, 3, 4])
        return data_frame
    except FileNotFoundError as error:
        raise DescriptiveError(404, f"Couldn't get the data frame with the following path {filename}") from error

def check_file_extension(filename: str) -> None:
    extension = re.search(r"\.([^\.]+)$", filename)
    if not extension:
        raise DescriptiveError(400, "Invalid file path (it doesn't have an extension)")
    extension = extension.group(1).lower()
    if extension not in [ "xls", "xlsx", "csv" ]:
        raise DescriptiveError(400, f"Unsupported file type ({extension})")

def create_unit_name(index: int, type: Literal["Letra"] | Literal["Número"]) -> str:
    return f"U{index} - {type}"

def get_grades_statistics(index: pd.Index) -> tuple[list[str], list[str], list[int], int]:
    subject_names = unique_list( name for name in index.get_level_values(1) if not re.search(r"Unnamed", name) )
    professor_names = unique_list( name for name in index.get_level_values(3) if not re.search(r"Unnamed", name) )

    units_list = [ name for name in index.get_level_values(4) if re.match(r"U\d", name) ]
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

def create_clean_index(subject_names: list[str], professor_names: list[str], units_per_subject: list[int]) -> pd.MultiIndex:
    units_part = [ 
        (subject, professor, f"U{index + 1} - {grade_type}") 
        for subject, professor, units_count in zip(subject_names, professor_names, units_per_subject)
            for index in range(units_count)
                for grade_type in UNIT_TYPES
    ]

    left_part = [ tuple([header] * 3) for header in LEFT_COLUMN_HEADERS ]
    left_part.extend(units_part)

    return pd.MultiIndex.from_arrays(list(zip(*left_part)), names=["subject", "professor", "unit"])

def get_clean_data_frame(data_frame: pd.DataFrame) -> pd.DataFrame:
    subject_names, professor_names, units_per_subject, max_units = get_grades_statistics(data_frame.columns)

    clean_index = create_clean_index(subject_names, professor_names, units_per_subject)
    data_frame.columns = clean_index

    data_frame = data_frame.T

    return data_frame

def graph_failure_rate(grades: pd.DataFrame, image_name: str):
    grades_per_professor = pd.DataFrame({
        "Estudiantes Reprobados": grades[grades < 7].count(axis=1),
    })

    grades_per_professor.plot.bar()
    plt.savefig(image_name)

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

