from contextlib import redirect_stdout
from io import StringIO
from flask import Flask, request
import re
import pandas as pd
from process_file import process_file

# Should get the port from an environment variable
PORT = 55_001

app = Flask(__name__)

@app.route("/hello", methods=["POST", "GET"])
def hello_world():
    return "Hello world!"

@app.route("/upload", methods=["POST"])
def upload():
    with open("logs.txt", "a") as logs:
        file_path = request.form["file_path"]
        extension = re.search(r"\.([^\.]+)$", file_path)
        if not extension:
            return "Invalid file path", 400
        extension = extension.group(1).lower()
        if extension not in [ "xls", "xlsx", "csv" ]:
            return "Unsupported file type", 400

        print(f"{extension = }", file=logs)

        data_frame = None
        try:
            data_frame = pd.read_excel(file_path, header=[0, 1, 2, 3, 4])
            print(data_frame, file=logs)
        except FileNotFoundError:
            return "File not found", 404   
        
        try:
            image_url = process_file(data_frame, logs)
            return { "imageUrl": image_url }, 200
        except Exception as e:
            return f"Error processing file: {str(e)}", 500

if __name__ == '__main__':
    app.run(port=PORT)
