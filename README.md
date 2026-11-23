# UT Report Generator

![Imagen de encabezado que muestra el logo de la UTSJR](readme-assets/header.png)

Esta es una aplicación interna de la UTSJR cuyo objetivo final es automatizar la generación de reportes del desempeño
de los grupos que Secretaría Académica a los tutores de grupo.

Se trata de un proyecto desarrollado en conjunto por Edgar Trejo Avila y el profesor [Gregorio Rodríguez Miranda](https://github.com/GoyoRodMir), con la mentoría de la doctora Brenda Juárez Santiago.

![Demostración de uso de la aplicación](readme-assets/usage-demo.gif)

## Tecnologías Utilizadas

* **Dart** como marco de trabajo para desarrollar el frontend
* **Matplotlib** y **Pandas** para la manipulación de datos y generación de gráficos
* **python-pptx** para la generación de archivos de PowerPoint
* **Flask** como marco de trabajo para desarrollar el backend

## Ejecución en Modo Desarrollo

1. Configurar variables de entorno
```sh
# Archivo .env
RUNNING_MODE=development
IS_TESTING_MODE=false
```

2. Ejecutar el servidor de Python
```ps1
cd python-app
python -m venv venv
./venv/Scripts/Activate.ps1
pip install -r requirements.txt
python main.py
```

3. Ejecutar la aplicación de Flutter en Windows
```ps1
# Desde la carpeta raíz del proyecto
flutter run -d windows
```

## Compilación

### Windows

**Requisitos Previos**
* Python 3.10 o superior
* PyInstaller instalado 
* InnoSetup (versión 6 o superior) instalado y en el PATH del sistema

**Pasos a Seguir**
1. Compilar el programa de Python usando PyInstaller
```ps1
cd python-app
pyinstaller --onefile main.py
```

2. Compilar el programa de Flutter
```ps1
# Desde la carpeta raíz del proyecto
flutter build windows --release
```

3. Compilar el script de InnoSetup
```ps1
# Desde la carpeta raíz del proyecto
iscc compilation-script.iss
```

4. El ejecutable final está disponible en `.logistics-assets/UT Report Generator.exe`

## Cómo Contribuir al Proyecto

1. Hacer un fork del repositorio y crear una rama usando el prefijo `feat/`, `fix/` o `doc/` según corresponda
2. Realizar cambios de manera modular y con mensajes de commit semánticos
3. Comprobar que:
   1. La aplicación Flutter compila y se ejecuta sin errores.
   2. El servidor Python levanta correctamente y pasa las pruebas definidas en `python-app/testing`.
   3. No se modifican archivos de configuración global a menos que sea
estrictamente necesario.
4. Llenar el formato de la PR y enviarla

![Imagen de pie de página que muestra los logos de las instituciones con las que está asociada la UTSJR](readme-assets/footer.png)
