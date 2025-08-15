import abc

from pptx import Presentation

from models.slide_type import SlideType
from models.asset import Asset

class SlideController():
    @staticmethod
    @abc.abstractmethod
    def slide_type() -> SlideType:
        '''
        Returns a unique string to identify the type of section this controller handles. 
        Commonly, it is a descriptive name that matches the class's name
        '''
        pass

    @staticmethod
    @abc.abstractmethod
    def default_arguments() -> dict[str, any]:
        '''
        Returns a dict with the default arguments needed to render this section's slide in a PowerPoint presentation.
        The contents of the dict are assumed to be valid arguments for the `render_slide` method, thus they are not 
        checked against this class's `validate_arguments` method. 
        '''
        pass

    @staticmethod
    @abc.abstractmethod
    def build_assets(data_files: list[str], base_directory: str, arguments: dict[str, str]) -> list[Asset]:
        '''
        Returns a dict of the assets needed to render this section's slide in a PowerPoint presentation.
        The assets are entries of the form (name, value, type), where `name` is a local name that's used later 
        in `render_slide`

        :param base_directory The directory where the image assets are going to be placed
        '''
        pass
    
    @staticmethod
    @abc.abstractmethod
    def validate_arguments(arguments: dict[str, any], assets: dict[str, str]) -> None:
        '''
        Validates the arguments required to render the slide. Raises DescriptiveError if the arguments are wrong
        '''
        pass

    @staticmethod
    @abc.abstractmethod
    def render_slide(presentation: Presentation, arguments: dict[str, any], assets: list[dict[str, str]]) -> None:
        '''
        Renders the slide.
        '''
        pass

