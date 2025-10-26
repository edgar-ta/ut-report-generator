from spire.presentation.common import *
from spire.presentation import *

def playground():
    path = r'D:\college\cuatrimestre-6\2025-06-16--estadias\ut-report-generator\.logistics-assets\2025-10-13--pptx-rendering\example-presentation.pptx'

    presentation = Presentation()
    presentation.LoadFromFile(path)

    for i, slide in enumerate(presentation.Slides):
        print(f"Rendering image index {i}")
        image = slide.SaveAsImage()
        image.Save(f"Slide_{i}.png")
        image.Dispose()
        print(f"Successfully rendered image index {i}")

if __name__ == '__main__':
    print("Starting the playground")
    playground()
    print("Successfully finished the playground")
