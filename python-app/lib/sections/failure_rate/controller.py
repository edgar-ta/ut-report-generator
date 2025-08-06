from lib.section_controller import SectionController
from lib.descriptive_error import DescriptiveError
from lib.sections.failure_rate.source import read_excel, check_file_extension, get_clean_data_frame, create_unit_name, graph_failure_rate
import re
import os
import uuid

class FailureRate_Controller(SectionController):
    @staticmethod
    def type_id() -> str:
        return "failure_rate"


    @staticmethod
    def validate_asset_arguments(arguments):
        unit = arguments["unit"]
        
        if unit > 5:
            raise DescriptiveError(400, "No subject has more than 5 units")


    @staticmethod
    def render_assets(data_file: str, report_directory: str, arguments: dict[str, str]) -> list[tuple[str, str]]:
        check_file_extension(data_file)
        data_frame = read_excel(data_file)
        data_frame = get_clean_data_frame(data_frame)

        unit = arguments["unit"]
        grades = data_frame.xs(create_unit_name(unit, "Número"), level="unit").map(lambda value: abs(value))

        # subjects_without_grades = grades[(grades == 0).all(axis=1)]
        subjects_with_grades = grades[(grades != 0).any(axis=1)]

        main_chart_path = os.path.join(report_directory, "images", str(uuid.uuid4()) + ".png")
        graph_failure_rate(subjects_with_grades, main_chart_path)

        return [ ("main-chart", main_chart_path) ]
    

    @staticmethod
    def validate_slide_arguments(arguments, assets):
        show_delayed_teachers = arguments["show_delayed_teachers"]
        if show_delayed_teachers not in [ "true", "false" ]:
            raise DescriptiveError(400, f"Invalid value for 'show_delayed_teachers'. Expected 'true' or 'false', found {show_delayed_teachers}")
        
        if not assets["main-chart"]:
            raise DescriptiveError(500, "The main chart asset is required to render the slide")
        
        if not assets["table"]:
            raise DescriptiveError(500, "The table asset is required to render the slide")


    @staticmethod
    def render_slide(filename: str, assets: dict[str, str], arguments: dict[str, str]) -> None:
        print("Without implementation yet")
        return super().render_slide(assets)
