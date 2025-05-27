import re
import pandas as pd

def leer_resultados_flujo_cargas(filepath):
    with open(filepath, encoding="latin1") as f:
        lines = f.readlines()

    # Helper to extract a table between two markers
    def extract_table(start_marker, end_marker=None):
        start, end = None, None
        for i, line in enumerate(lines):
            if start_marker in line:
                start = i
            if start is not None and end_marker and end_marker in line and i > start:
                end = i
                break
        if start is None:
            return []
        if end is None:
            end = len(lines)
        # Collect table lines, skipping headers and separators
        table_lines = []
        for line in lines[start:end]:
            if (line.strip() == "" or "-" in line or any(x in line for x in ["Nudo", "Línea", "Trafo"])):
                continue
            table_lines.append(line.strip())
        return table_lines

    # 1. RESULTADOS DEL FLUJO DE CARGAS
    cargas_lines = extract_table(
        "---------- RESULTADOS DEL FLUJO DE CARGAS ----------",
        "---------- FLUJOS DE POTENCIAS POR LAS LINEAS ----------"
    )
    cargas_data = [l.split() for l in cargas_lines if l]
    cargas_cols = ["Nudo", "Limite", "Tension", "Angulo", "Pgen", "Qgen", "Pcarga", "Qcarga", "Qcomp"]
    df_cargas = pd.DataFrame(cargas_data, columns=cargas_cols)

    # Buscar pérdidas de activa
    perdidas_activa = None
    for line in lines:
        match = re.search(r"Pérdidas de activa=\s*([\d\.\-Ee]+)", line)
        if match:
            perdidas_activa = float(match.group(1))
            break

    # 2. FLUJOS DE POTENCIAS POR LAS LINEAS
    lineas_lines = extract_table(
        "---------- FLUJOS DE POTENCIAS POR LAS LINEAS ----------",
        "---------- FLUJOS DE POTENCIAS POR LOS TRAFOS ----------"
    )
    lineas_data = [l.split() for l in lineas_lines if l]
    lineas_cols = ["Linea", "NudoA", "NudoB", "P_A_B", "Q_A_B", "P_B_A", "Q_B_A"]
    df_lineas = pd.DataFrame(lineas_data, columns=lineas_cols)

    # 3. FLUJOS DE POTENCIAS POR LOS TRAFOS
    trafos_lines = extract_table(
        "---------- FLUJOS DE POTENCIAS POR LOS TRAFOS ----------"
    )
    # Remove possible trailing lines after the table
    trafos_data = []
    for l in trafos_lines:
        if l.startswith("Trafo") or l.startswith("Primario") or l.startswith("Secundario") or l.startswith("-"):
            continue
        if l:
            trafos_data.append(l.split())
    trafos_cols = ["Trafo", "Primario", "Secundario", "P_Prim", "Q_Prim", "P_Secun", "Q_Secun"]
    df_trafos = pd.DataFrame(trafos_data, columns=trafos_cols)

    return df_cargas, df_lineas, df_trafos, perdidas_activa

def U_arg(filepath, nudo_num):
    """
    Extrae la tensión y el ángulo del nudo indicado (por número) de la tabla de resultados de flujo de cargas.
    nudo_num: int (por ejemplo, 1 para Nudo1)
    """
    nudo_str = f"Nudo{nudo_num}"
    with open(filepath, encoding="latin1") as f:
        lines = f.readlines()
    # Buscar el inicio de la tabla de resultados
    start = None
    for i, line in enumerate(lines):
        if "---------- RESULTADOS DEL FLUJO DE CARGAS ----------" in line:
            start = i
            break
    if start is None:
        raise ValueError("No se encontró la tabla de resultados.")
    # Buscar la línea que contiene el nudo deseado
    for line in lines[start:]:
        if re.match(rf"\s*{nudo_str}\b", line):
            partes = line.split()
            tension = float(partes[2])
            angulo = float(partes[3])
            return tension, angulo
    raise ValueError(f"No se encontró el nudo {nudo_str} en la tabla.")


def extraer_P_BA_linea(filepath, numero_linea=1):
    """
    Extrae el valor de P(B->A) para la línea indicada (por ejemplo, Linea1, Linea2, ...) 
    de la sección de flujos de potencias por las líneas.

    Parámetros:
        filepath: ruta al archivo de texto
        numero_linea: número de la línea (entero, por defecto 1)
    """
    with open(filepath, encoding="latin1") as f:
        lines = f.readlines()
    # Buscar el inicio de la sección de líneas
    start = None
    for i, line in enumerate(lines):
        if "---------- FLUJOS DE POTENCIAS POR LAS LINEAS ----------" in line:
            start = i
            break
    if start is None:
        raise ValueError("No se encontró la sección de flujos de líneas.")
    # Buscar la línea correspondiente
    linea_str = f"Linea{numero_linea}"
    for line in lines[start:]:
        if line.strip().startswith(linea_str):
            partes = line.split()
            if len(partes) >= 7:
                # P(B->A) es la sexta columna (índice 5)
                return float(partes[5])
            else:
                raise ValueError(f"Formato inesperado en la fila de {linea_str}.")
    raise ValueError(f"No se encontró {linea_str} en la sección de flujos de líneas.")

def extraer_potencia_linea(filepath, numero_linea, columna):
    """
    Extrae el valor de la columna indicada para la línea especificada en la sección de flujos de potencias por las líneas.
    columna: índice de columna (entero, 0-based)
    """
    with open(filepath, encoding="latin1") as f:
        lines = f.readlines()
    # Buscar el inicio de la sección de líneas
    start = None
    for i, line in enumerate(lines):
        if "---------- FLUJOS DE POTENCIAS POR LAS LINEAS ----------" in line:
            start = i
            break
    if start is None:
        raise ValueError("No se encontró la sección de flujos de líneas.")
    linea_str = f"Linea{numero_linea}"
    for line in lines[start:]:
        if line.strip().startswith(linea_str):
            partes = line.split()
            if len(partes) > columna:
                return float(partes[columna])
            else:
                raise ValueError(f"Formato inesperado en la fila de {linea_str}.")
    raise ValueError(f"No se encontró {linea_str} en la sección de flujos de líneas.")


# def extraer_P_Prim_trafos(filepath):
#     """
#     Extrae los valores de P(Prim.) para Trafo1 y Trafo2 usando pandas.
#     Devuelve una tupla: (P_Prim_Trafo1, P_Prim_Trafo2)
#     """
#     _, _, df_trafos, _ = leer_resultados_flujo_cargas(filepath)
#     try:
#         p_prim_1 = float(df_trafos.loc[df_trafos['Trafo'] == 'Trafo1', 'P_Prim'].values[0])
#     except Exception:
#         p_prim_1 = float('nan')
#     try:
#         p_prim_2 = float(df_trafos.loc[df_trafos['Trafo'] == 'Trafo2', 'P_Prim'].values[0])
#     except Exception:
#         p_prim_2 = float('nan')
#     return p_prim_1, p_prim_2

def extraer_potencia_trafo(filepath, numero_trafo, columna):
    """
    Extrae el valor de la columna indicada para el trafo especificado en la sección de flujos de potencias por los trafos.
    columna: índice de columna (entero, 0-based)
    """
    with open(filepath, encoding="latin1") as f:
        lines = f.readlines()
    # Buscar el inicio de la sección de trafos
    start = None
    for i, line in enumerate(lines):
        if "---------- FLUJOS DE POTENCIAS POR LOS TRAFOS ----------" in line:
            start = i
            break
    if start is None:
        raise ValueError("No se encontró la sección de flujos de trafos.")
    trafo_str = f"Trafo{numero_trafo}"
    for line in lines[start:]:
        if line.strip().startswith(trafo_str):
            partes = line.split()
            if len(partes) > columna:
                return float(partes[columna])
            else:
                raise ValueError(f"Formato inesperado en la fila de {trafo_str}.")
    raise ValueError(f"No se encontró {trafo_str} en la sección de flujos de trafos.")