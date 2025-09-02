# UT Report Generator

![Imagen de encabezado que muestra el logo de la UTSJR](readme-assets/header.png)

Ésta es una aplicación interna de la UTSJR cuyo objetivo final es automatizar la generación de reportes del desempeño
de los alumnos que solicita la Secretaría Académica a los profesores tutores de grupo.

Se trata de un proyecto desarrollado en conjunto por Edgar Trejo Avila y el profesor [Gregorio Rodríguez Miranda](https://github.com/GoyoRodMir).

## Tecnologías Utilizadas

* **Dart** para el desarrollo de la UI
* **Matplotlib** y **Pandas** para la generación de gráficos
* **python-pptx** para la generación automática de presentaciones
* **flask** para ejecutar el código del backend

![Imagen de pie de página que muestra los logos de las instituciones con las que está asociada la UTSJR](readme-assets/footer.png)

## Compilación

### Windows

1. Compilar el programa de Python usando PyInstaller
2. Compilar el programa de Flutter usando flutter build windows --release
3. Compilar el script de InnoSetup (el que sí funciona)
