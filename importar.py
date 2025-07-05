import flet as ft
import pandas as pd

def main(page: ft.Page):
    page.title = "Calificaciones de Alumnos"
    page.vertical_alignment = ft.CrossAxisAlignment.START
    page.horizontal_alignment = ft.CrossAxisAlignment.CENTER
    page.window_width = 1400  # Ajusta el ancho de la ventana
    page.window_height = 800  # Ajusta la altura de la ventana
    page.scroll = ft.ScrollMode.ADAPTIVE

    excel_file = "CalificacionesCorrecto.xlsx"

    try:
        # Leemos el archivo completo sin encabezados para tener control total
        df_raw = pd.read_excel(excel_file, sheet_name=0, header=None)

    except FileNotFoundError:
        page.add(ft.Text(f"Error: El archivo '{excel_file}' no se encontró.", color="red"))
        page.update()
        return
    except Exception as e:
        page.add(ft.Text(f"Error al leer el archivo Excel: {e}", color="red"))
        page.update()
        return

    # --- 1. Procesar y aplanar los encabezados dinámicamente ---
    final_column_names = ["NO.", "EXPEDIENTE", "NOMBRE"] # Nombres iniciales fijos

    # Guardar los encabezados de materia (fila 0) y profesor (fila 1)
    header_materias = df_raw.iloc[0]
    header_profesores = df_raw.iloc[1]

    # Columnas de datos reales comienzan desde la 2 (index 2)
    current_materia_name = ""
    current_profesor_name = ""
    
    profesor_cols_indices = [idx for idx, val in enumerate(header_profesores) if pd.notna(val)]
    # Añadimos el final del DataFrame como un "marcador" para el último profesor
    profesor_cols_indices.append(df_raw.shape[1]) 

    unidades = df_raw.iloc[2]
    for i in range(len(profesor_cols_indices) - 1):
        start_col = profesor_cols_indices[i]
        end_col = profesor_cols_indices[i+1]
        
        current_profesor = str(header_profesores.iloc[start_col]).strip()
        current_materia = str(header_materias.iloc[start_col]).strip()
    
        # Las columnas de unidades para este profesor van desde 'start_col' hasta 'end_col - 1'  
        contador = start_col 
        unit_number=0
        while (contador<end_col):
            if pd.notna(unidades[contador]):
                calif_type="(Alfa)"
                unit_number += 1;
            else:
                calif_type="(Num)"
            
            column_name = f"{current_materia} - {current_profesor} - U{unit_number} {calif_type}"
            final_column_names.append(column_name)
            contador +=1 


    # Reajustar el DataFrame con los nuevos encabezados
    if len(final_column_names) == df_raw.shape[1]:
        df_raw.columns = final_column_names
        # Los datos reales comienzan desde la fila 2 (índice 2)
        df = df_raw.iloc[2:].reset_index(drop=True)
    else:
        page.add(ft.Text(f"Error al procesar los encabezados. Número de columnas esperado: {df_raw.shape[1]}, generado: {len(final_column_names)}", color="red"))
        page.update()
        return

    # --- 2. Crear DataColumns para Flet ---
    columns_flet = []
    for col_name in df.columns:
        columns_flet.append(
            ft.DataColumn(
                ft.Text(col_name, weight=ft.FontWeight.BOLD, width=150),
                tooltip=col_name # Añadir tooltip para ver el nombre completo si es muy largo
            )
        )

    # --- 3. Crear DataRows para Flet ---
    data_rows_flet = []
    for index, row in df.iterrows():
        cells = []
        for col in df.columns:
            cell_value = str(row[col]) if pd.notna(row[col]) else ""
            cells.append(ft.DataCell(ft.Text(cell_value)))
        data_rows_flet.append(ft.DataRow(cells=cells))

    # --- 4. Construir la tabla Flet ---
    data_table = ft.DataTable(
        columns=columns_flet,
        rows=data_rows_flet,
        data_row_min_height=40,
        show_bottom_border=True,
        horizontal_lines=ft.BorderSide(1, ft.Colors.BLACK12),
        vertical_lines=ft.BorderSide(1, ft.Colors.BLACK12),
        border=ft.BorderSide(1, ft.Colors.BLACK45),
        column_spacing=10,
        divider_thickness=1,
        # Si la tabla es muy ancha, DataColumnHeader permite desplazamiento horizontal
    )

    page.add(
        ft.Container(
            content=ft.Column(
                [
                    ft.Text("Calificaciones de Alumnos", size=24, weight=ft.FontWeight.BOLD),
                    ft.Divider(),
                    ft.ResponsiveRow(
                        [
                            ft.Row(
                                [
                                    ft.Column(
                                        [data_table],
                                        col=12,
                                        # Para tablas muy anchas, el scroll en la columna es lo más efectivo
                                        scroll=ft.ScrollMode.ADAPTIVE,
                                    )
                                ],
                                scroll=ft.ScrollMode.ADAPTIVE
                            )
                        ]
                    )
                ],
                horizontal_alignment=ft.CrossAxisAlignment.START,
            ),
            padding=ft.padding.all(20),
            expand=True 
            
        )
    )
    page.update()

if __name__ == "__main__":
    ft.app(target=main)
