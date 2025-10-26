from lib.report.construct import from_json, find_root_directory

from models.report.self import Report
from models.report.visualization_mode import VisualizationMode
from models.error.descriptive_error import DescriptiveError

import pytest
import shutil
import os

def _create_slideshow(client, mode: VisualizationMode, json):
    route = "/report/start_with_image_slide" if mode == VisualizationMode.AS_REPORT else "/report/start_with_pivot_table"
    assertion_message = "No se pudo crear un reporte para usar en el testeo" if mode == VisualizationMode.AS_REPORT else "No se pudo crear una visualización para usar en el testeo"

    response = client.post(route, json=json)
    assert response.status_code == 200, assertion_message
    slideshow = from_json(response.get_json())
    
    yield slideshow
    try:
        directory = find_root_directory(slideshow.identifier)
        shutil.rmtree(directory)    
    except DescriptiveError:
        pass

@pytest.fixture
def created_report(client):
    generator = _create_slideshow(client=client, mode=VisualizationMode.AS_REPORT, json={})
    yield next(generator)

@pytest.fixture
def created_visualization(client):
    generator = _create_slideshow(client=client, mode=VisualizationMode.CHARTS_ONLY, json={})
    yield next(generator)
