import abc

class SectionController():
    @staticmethod
    @abc.abstractmethod
    def type_id() -> str:
        '''
        Returns a unique string to identify the type of section this controller handles. 
        Commonly, it is a descriptive name that matches the class's name
        '''
        pass

    @staticmethod
    @abc.abstractmethod
    def validate_asset_arguments(arguments: dict[str, str]) -> None:
        '''
        Raises DescriptiveError if the arguments required to render the assets for this type of section are not valid.
        '''
        pass

    @staticmethod
    @abc.abstractmethod
    def render_assets(data_file: str, report_directory: str, arguments: dict[str, str]) -> list[tuple[str, str]]:
        '''
        Returns a dict of the assets needed to render this section's slide in a PowerPoint presentation.
        The assets are entries of the form (name, path), where `name` is a local name that's used later 
        in `render_slide`
        '''
        pass
    
    @staticmethod
    @abc.abstractmethod
    def validate_slide_arguments(arguments: dict[str, str], assets: dict[str, str]) -> None:
        '''
        Validates the arguments required to render the slide. Raises DescriptiveError if the arguments are wrong
        '''
        pass

    @staticmethod
    @abc.abstractmethod
    def render_slide(filename: str, arguments: dict[str, str], assets: dict[str, str]) -> None:
        pass

