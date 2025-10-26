from lib.report.construct import from_json, find_root_directory

from models.report.self import Report
from models.report.visualization_mode import VisualizationMode
from models.error.descriptive_error import DescriptiveError

from routes.route_map import SLIDESHOW

import pytest
import shutil
import os

def _create_slideshow(client, mode: VisualizationMode, json):
    route = SLIDESHOW.START_AS_REPORT.value if mode == VisualizationMode.AS_REPORT else SLIDESHOW.START_AS_VISUALIZATION.value
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
    generator = _create_slideshow(client=client, mode=VisualizationMode.CHARTS_ONLY, json={
        'data_files': [
            "D:\\college\\cuatrimestre-6\\2025-06-16--estadias\\ut-report-generator\\.logistics-assets\\2025-10-13--data-processing\\ti02sm-23.xls",
            "D:\\college\\cuatrimestre-6\\2025-06-16--estadias\\ut-report-generator\\.logistics-assets\\2025-10-13--data-processing\\ds01sm-24.xls",
            "D:\\college\\cuatrimestre-6\\2025-06-16--estadias\\ut-report-generator\\.logistics-assets\\2025-10-13--data-processing\\ds02sm-24.xls"
        ]
    })
    yield next(generator)
