import tkinter as tk
import socket
import threading
import json

sock_envio = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
ADA_IP = "127.0.0.1"
ADA_PORT = 5000

sock_recepcion = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock_recepcion.bind(("127.0.0.1", 5002))

BG_COLOR = "#24273a"
PANEL_BG = "#363a4f"
TEXT_COLOR = "#cad3f5"
ACCENT_BLUE = "#8aadf4"
ACCENT_RED = "#ed8796"
ACCENT_GREEN = "#a6da95"

FONT_TITLE = ("Cascadia Code", 12, "bold")
FONT_NORMAL = ("Cascadia Code", 10)
FONT_METRIC = ("Cascadia Code", 16, "bold")

def enviar_estado(*args):
    datos = {
        "ENGINE_TEMP": float(slider_temp.get()),
        "SPEED": float(slider_speed.get()),
        "FUEL_FLOW": float(slider_fuel.get()),
        "TYRE_FL": float(slider_tyres.get()),
        "TYRE_FR": float(slider_tyres.get()),
        "TYRE_RL": float(slider_tyres.get()),
        "TYRE_RR": float(slider_tyres.get()),
        "BRAKE_PRESSURE": float(slider_brakes.get()),
        "G_FORCE": float(slider_g.get())
    }
    # Rellenamos a 256 bytes para coincidir con el nuevo buffer de Ada
    mensaje = json.dumps(datos).ljust(256) 
    sock_envio.sendto(mensaje.encode('utf-8'), (ADA_IP, ADA_PORT))

def forzar_falla():
    slider_temp.set(150.0)
    enviar_estado()

def escuchar_metricas():
    while True:
        try:
            data, _ = sock_recepcion.recvfrom(1024)
            metricas = json.loads(data.decode('utf-8').strip())
            root.after(0, actualizar_metricas_gui, metricas)
        except Exception: pass

def actualizar_metricas_gui(metricas):
    lbl_tep_val.config(text=f"{metricas.get('TEP', 0)} microsegundos")
    lbl_trp_val.config(text=f"{metricas.get('TRP', 0)} microsegundos")

root = tk.Tk()
root.title("Pit Wall - Control de Ingeniero")
root.geometry("500x650")
root.configure(bg=BG_COLOR)

frame_controles = tk.Frame(root, bg=BG_COLOR)
frame_controles.pack(fill="x", padx=20, pady=5)
tk.Label(frame_controles, text="SIMULADOR DE SENSORES", font=FONT_TITLE, bg=BG_COLOR, fg=ACCENT_BLUE).pack(pady=5)

# Sliders agrupados
def crear_slider(texto, min_val, max_val, default):
    tk.Label(frame_controles, text=texto, font=FONT_NORMAL, bg=BG_COLOR, fg=TEXT_COLOR).pack()
    s = tk.Scale(frame_controles, from_=min_val, to_=max_val, orient="horizontal", bg=BG_COLOR, fg=TEXT_COLOR, highlightthickness=0, length=400, command=enviar_estado, resolution=0.5)
    s.set(default)
    s.pack()
    return s

slider_fuel = crear_slider("Flujo Combustible (KG/H)", 0.0, 120.0, 90.0)
slider_speed = crear_slider("Velocidad (KM/H)", 0.0, 350.0, 200.0)
slider_temp = crear_slider("Temp Motor (°C)", 50.0, 160.0, 90.0)
slider_tyres = crear_slider("Temp Neumáticos (°C)", 50.0, 130.0, 90.0)
slider_brakes = crear_slider("Presión Frenos (Bar)", 0.0, 180.0, 50.0)
slider_g = crear_slider("Fuerza G", -8.0, 8.0, 0.0)

tk.Button(root, text=" SIMULAR FALLA CRÍTICA ", font=FONT_TITLE, bg=ACCENT_RED, fg="#11111b", relief="flat", command=forzar_falla).pack(pady=10)

frame_metricas = tk.Frame(root, bg=PANEL_BG, bd=2, relief="ridge", pady=10)
frame_metricas.pack(fill="x", padx=20, pady=5)
tk.Label(frame_metricas, text="MÉTRICAS DE TIEMPO REAL ESTRICTO", font=FONT_TITLE, bg=PANEL_BG, fg=ACCENT_GREEN).pack()

grid_metricas = tk.Frame(frame_metricas, bg=PANEL_BG)
grid_metricas.pack(pady=5)
tk.Label(grid_metricas, text="TEP (Espera Promedio):", font=FONT_NORMAL, bg=PANEL_BG, fg=TEXT_COLOR).grid(row=0, column=0, padx=10, sticky="e")
lbl_tep_val = tk.Label(grid_metricas, text="--- microsegundos", font=FONT_METRIC, bg=PANEL_BG, fg=TEXT_COLOR)
lbl_tep_val.grid(row=0, column=1, sticky="w")
tk.Label(grid_metricas, text="TRP (Retorno Promedio):", font=FONT_NORMAL, bg=PANEL_BG, fg=TEXT_COLOR).grid(row=1, column=0, padx=10, sticky="e")
lbl_trp_val = tk.Label(grid_metricas, text="--- microsegundos", font=FONT_METRIC, bg=PANEL_BG, fg=TEXT_COLOR)
lbl_trp_val.grid(row=1, column=1, sticky="w")

threading.Thread(target=escuchar_metricas, daemon=True).start()
root.mainloop()