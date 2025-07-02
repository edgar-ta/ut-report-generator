import pandas as pd
import matplotlib.pyplot as plt
import dataframe_image as dfi

# Ruta de entrada y salida
archivo_entrada = 'data.xls'
archivo_salida = 'data-converted.xlsx'

# Cargar el archivo .xls
xls = pd.ExcelFile(archivo_entrada, engine='xlrd')

# Escribir cada hoja en el nuevo archivo .xlsx
with pd.ExcelWriter(archivo_salida, engine='openpyxl') as writer:
    for nombre_hoja in xls.sheet_names:
        df = xls.parse(nombre_hoja)
        df.to_excel(writer, sheet_name=nombre_hoja, index=False)

print(f"Conversión completada. Archivo guardado como: {archivo_salida}")

# Cargar archivo con 4 encabezados
df = pd.read_excel(archivo_salida, header=[0, 1, 2, 3])

print("DF IS THIS")
print(df)

# Separar columnas de identificación: primeras tres columnas
columnas_id = df.columns[:3]
df_id = df[columnas_id]
df_notas = df.drop(columns=columnas_id)

# Reorganizar el DataFrame a formato largo
df_largo = df_notas.stack(level=[0, 1, 2, 3]).reset_index()
df_largo.columns = ['Fila', 'MateriaRaw', 'Materia', 'Unidad', 'Profesor', 'Valor']

# Agregar datos del alumno
df_largo['Nombre'] = df_id[columnas_id[2]].iloc[df_largo['Fila']].reset_index(drop=True)
df_largo['Expediente'] = df_id[columnas_id[1]].iloc[df_largo['Fila']].reset_index(drop=True)

# Elegir unidad a analizar
unidad_deseada = 'U1'
df_u = df_largo[df_largo['Unidad'] == unidad_deseada].copy()

# Criterio de reprobación
def es_reprobado(valor):
    try:
        nota = float(valor)
        return (-1 * nota) < 6  # invertir y comparar
    except:
        return str(valor).strip().upper() in ['R', 'E', 'NA', 'NP', 'NR']

# Aplicar criterio
df_u['Reprobado'] = df_u['Valor'].apply(es_reprobado)

# Contar reprobados por materia
conteo = df_u[df_u['Reprobado']]['Materia'].value_counts().sort_values(ascending=False)

# Graficar
plt.figure(figsize=(10, 6))
conteo.plot(kind='bar', color='firebrick')
plt.title(f"Alumnos reprobados por materia ({unidad_deseada})")
plt.xlabel("Materia")
plt.ylabel("Número de alumnos reprobados")
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
plt.savefig("reprobados_por_materia.png")
plt.close()
print("✅ Gráfico guardado como 'reprobados_por_materia.png'")

# Tabla como imagen
df_tabla = conteo.reset_index()
df_tabla.columns = ['Materia', 'Reprobados']
dfi.export(df_tabla, 'tabla_reprobados_por_materia.png')
print("✅ Tabla guardada como 'tabla_reprobados_por_materia.png'")