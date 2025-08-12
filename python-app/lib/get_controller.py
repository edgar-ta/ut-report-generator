from control_variables import AVAILABLE_SLIDE_CONTROLLERS

def get_controller(slide):
    slide_type = slide["type"]
    controller = next((c for c in AVAILABLE_SLIDE_CONTROLLERS if c.slide_type() == slide_type), None)
    if controller is None:
        raise Exception(f"No se encontró un controlador para el tipo de slide '{slide_type}'")
