import tkinter as tk
import socket
import threading
import json

UDP_IP = "127.0.0.1"
UDP_PORT = 5001

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((UDP_IP, UDP_PORT))

BG_COLOR = "#1e1e2e"
PANEL_BG = "#313244"
TEXT_COLOR = "#cdd6f4"
GREEN = "#a6e3a1"
RED = "#f38ba8"
YELLOW = "#f9e2af"

FONT_TITLE = ("Cascadia Code", 12)
FONT_DATA = ("Cascadia Code", 26, "bold")
FONT_ALERT = ("Cascadia Code", 16, "bold")

def actualizar_tablero(datos):
    temp = datos.get('ENGINE_TEMP', 0.0)
    speed = datos.get('SPEED', 0)
    fuel = datos.get('FUEL_FLOW', 0.0)
    brakes = datos.get('BRAKE_PRESSURE', 0.0)
    g_force = datos.get('G_FORCE', 0.0)
    tyre = datos.get('TYRE_FL', 0.0) # Tomamos el FL como referencia visual

    lbl_fuel_val.config(text=f"{fuel:.1f} KG/H")
    lbl_speed_val.config(text=f"{speed:.0f} KM/H")
    lbl_temp_val.config(text=f"{temp:.1f} °C")
    lbl_brakes_val.config(text=f"{brakes:.1f} BAR")
    lbl_tyres_val.config(text=f"{tyre:.1f} °C")
    lbl_g_val.config(text=f"{g_force:.1f} G")

    # Reseteo de colores
    for lbl in [lbl_fuel_val, lbl_speed_val, lbl_temp_val, lbl_brakes_val, lbl_tyres_val, lbl_g_val]:
        lbl.config(fg=TEXT_COLOR)

    estado = datos.get("STATUS", "NORMAL")
    if estado == "CRITICAL":
        frame_alerta.config(bg=RED)
        lbl_alerta.config(text="¡MGU OFFLINE - FALLA CRÍTICA!", bg=RED, fg="#11111b")
        
        # Color inteligente basado en tu Threshold_DB
        if temp > 120.0 or temp < 80.0: lbl_temp_val.config(fg=RED)
        if fuel > 100.0: lbl_fuel_val.config(fg=RED)
        if brakes > 150.0: lbl_brakes_val.config(fg=RED)
        if tyre > 110.0 or tyre < 70.0: lbl_tyres_val.config(fg=RED)
        if g_force > 6.0 or g_force < -6.0: lbl_g_val.config(fg=RED)
    else:
        frame_alerta.config(bg=BG_COLOR)
        lbl_alerta.config(text="SISTEMA NOMINAL", bg=BG_COLOR, fg=GREEN)

def escuchar_red():
    while True:
        try:
            data, _ = sock.recvfrom(1024)
            datos = json.loads(data.decode('utf-8').strip())
            root.after(0, actualizar_tablero, datos)
        except Exception: pass

root = tk.Tk()
root.title("Volante F1 - Piloto")
root.geometry("800x400")
root.configure(bg=BG_COLOR)

frame_alerta = tk.Frame(root, bg=BG_COLOR, pady=10)
frame_alerta.pack(fill="x")
lbl_alerta = tk.Label(frame_alerta, text="ESPERANDO TELEMETRÍA...", font=FONT_ALERT, bg=BG_COLOR, fg=YELLOW)
lbl_alerta.pack()

frame_medidores = tk.Frame(root, bg=BG_COLOR)
frame_medidores.pack(expand=True, fill="both", padx=10, pady=10)
for i in range(3): frame_medidores.columnconfigure(i, weight=1)

def crear_panel(row, col, titulo):
    p = tk.Frame(frame_medidores, bg=PANEL_BG, bd=2, relief="ridge")
    p.grid(row=row, column=col, padx=5, pady=5, sticky="nsew")
    tk.Label(p, text=titulo, font=FONT_TITLE, bg=PANEL_BG, fg=TEXT_COLOR).pack(pady=5)
    lbl = tk.Label(p, text="---", font=FONT_DATA, bg=PANEL_BG, fg=TEXT_COLOR)
    lbl.pack(expand=True)
    return lbl

# Fila 0
lbl_fuel_val = crear_panel(0, 0, "COMBUSTIBLE")
lbl_speed_val = crear_panel(0, 1, "VELOCIDAD")
lbl_temp_val = crear_panel(0, 2, "TEMP MOTOR")
# Fila 1
lbl_brakes_val = crear_panel(1, 0, "PRESIÓN FRENOS")
lbl_tyres_val = crear_panel(1, 1, "TEMP NEUMÁTICOS")
lbl_g_val = crear_panel(1, 2, "FUERZA G")

threading.Thread(target=escuchar_red, daemon=True).start()
root.mainloop()