import abc

from pptx import Presentation

from models.image_slide.image_slide_kind import ImageSlideKind

class ImageSlideController():
    @staticmethod
    @abc.abstractmethod
    def kind() -> ImageSlideKind:
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
    def validate_arguments(arguments: dict[str, any]) -> None:
        '''
        Validates the arguments required to render the slide. Raises DescriptiveError if the arguments are wrong
        '''
        pass

    @staticmethod
    @abc.abstractmethod
    def render_slide(presentation: Presentation, arguments: dict[str, any]) -> None:
        '''
        Renders the slide.
        '''
        pass

