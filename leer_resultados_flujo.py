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

def U1_arg1(filepath):
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

    # Buscar la línea que contiene "Nudo1"
    for line in lines[start:]:
        if re.match(r"\s*Nudo1\b", line):
            # Separar por espacios y extraer los valores
            partes = line.split()
            # partes[2] = Tensión, partes[3] = Ángulo
            tension = float(partes[2])
            angulo = float(partes[3])
            return tension, angulo

    raise ValueError("No se encontró el nudo Nudo1 en la tabla.")