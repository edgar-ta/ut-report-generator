from constants.dynamic_variables import DynamicVariables
from logging.handlers import RotatingFileHandler

from flask import Flask

import logging
import os

def setup_logging():
    # Asegura que exista la carpeta logs
    logs_directory = os.path.join(DynamicVariables.instance.application_root_directory, "logs")
    os.makedirs(logs_directory, exist_ok=True)

    log_file = os.path.join(logs_directory, "logs.log")

    # Configura el logger raíz de Flask
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    # 🔹 Handler para consola
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    console_format = logging.Formatter("[%(asctime)s] [%(levelname)s] %(message)s", "%Y-%m-%d %H:%M:%S")
    console_handler.setFormatter(console_format)

    # 🔹 Handler para archivo (rotativo, máximo 1MB por archivo)
    file_handler = RotatingFileHandler(log_file, maxBytes=1_000_000, backupCount=5, encoding="utf-8")
    file_handler.setLevel(logging.INFO)
    file_handler.setFormatter(console_format)

    # Elimina handlers previos (para evitar logs duplicados si se recarga Flask)
    if logger.hasHandlers():
        logger.handlers.clear()

    # Añade los dos handlers
    logger.addHandler(console_handler)
    logger.addHandler(file_handler)
