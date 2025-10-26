class DynamicVariables():
    instance = None

    def __init__(self, application_root_directory: str, executable_directory: str):
        self.application_root_directory = application_root_directory
        self.executable_directory = executable_directory
    
    @staticmethod
    def initialize(application_root_directory: str, executable_directory: str):
        print(f'''Initializing the DynamicVariables instance with: 
{application_root_directory = }
{executable_directory = }
''')
        DynamicVariables.instance = DynamicVariables(
            application_root_directory=application_root_directory,
            executable_directory=executable_directory
        )
    
    def __repr__(self):
        return f'DynamicVariables({self.application_root_directory = }, {self.executable_directory = })'
