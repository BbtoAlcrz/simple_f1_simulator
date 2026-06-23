# 🏎️ F1 Telemetry Simulator - Real-Time Estricto (HIL)

Un simulador distribuido de tipo **Hardware-in-the-Loop (HIL)** diseñado para la adquisición, auditoría y transmisión de telemetría de un monoplaza de Fórmula 1 en tiempo real estricto. El sistema utiliza **Ada** para el núcleo crítico embebido debido a su determinismo y tipado fuerte, y **Python (Tkinter)** para las interfaces asíncronas de visualización y control.

## 📊 Arquitectura del Sistema

El proyecto está dividido en dos capas principales que se comunican mediante sockets UDP locales, garantizando un aislamiento completo entre la lógica de control y la interfaz de usuario.

```text
       ┌────────────────────────────────────────────────────────┐
       │                 NÚCLEO EN ADA (ECU)                    │
       │                                                        │
       │  ┌────────────────┐ 1ms ┌───────────────────────────┐  │
       │  │ Sensor_Task    │◄───►│ Memoria Protegida         │  │
       │  └───────▲────────┘     │ (Data_Lock)               │  │
       │          │              └─────────────▲─────────────┘  │
       │          │ UDP (5000)                 │ 5ms            │
       │          │              ┌─────────────▼─────────────┐  │
       │          │              │ Alert_Task (Auditor)      │  │
       │          │              └─────────────┬─────────────┘  │
       │          │                            │ Alerta Crítica │
       │          │              ┌─────────────▼─────────────┐  │
       │          │              │ Safety_Monitor (Failsafe) │  │
       │          │              └───────────────────────────┘  │
       │          │                                             │
       │  ┌───────▼────────┐     ┌───────────────────────────┐  │
       │  │ Comm_Task      ├────►│ Métricas de Rendimiento   │  │
       │  └───────┬────────┘ 20ms│ (Metrics_DB: TEP/TRP)     │  │
       └───┬──────┼─────────────────────────────────────────────┘
           │      │
           │      └──────────────────────────┐ UDP (5002)
           │ JSON UDP (5001)                 │ (Métricas)
           ▼                                 ▼
┌────────────────────┐            ┌──────────────────────┐
│    VOLANTE F1      │            │     PIT WALL         │
│   (volante.py)     │            │(tablero_ingeniero.py)│
│  Tablero Piloto    │            │  Control Ingeniero   │
└────────────────────┘            └──────────────────────┘
```

### 1. Backend (Ada - Núcleo de Tiempo Real)
Ejecuta de manera concurrente tres hilos activos (*tasks*) con prioridades asignadas por el planificador nativo:
* **`Sensor_Task` (Periodo: 1ms - Prioridad Alta):** Adquiere los paquetes JSON de la red mediante un socket UDP **no bloqueante**. Sella cada lectura con precisión de microsegundos e inicializa el estado ante pérdidas de conectividad.
* **`Alert_Task` (Periodo: 5ms - Prioridad Crítica):** Evalúa los datos contra una base de datos de umbrales pasiva (`Threshold_DB`). Calcula en vivo el **TEP** (Tiempo de espera promedio) y el **TRP** (Tiempo de Retorno promedio) de los datos.
* **`Safety_Monitor` (Interrupción - Prioridad Máxima):** Actúa como un botón de pánico de hardware. Permanece suspendido sin consumir CPU hasta recibir una señal de falla crítica, momento en el cual toma el control y desactiva de inmediato la ECU y el sistema híbrido MGU.
* **`Comm_Task` (Periodo: 20ms - Prioridad Baja):** Serializa el estado de los sensores y las métricas de rendimiento en formato JSON y los distribuye asíncronamente hacia los componentes de la interfaz.

### 2. Frontend (Python - Interfaces de Control)
Diseñado con una estética oscura basada en la paleta *Catppuccin Macchiato* y fuentes monoespaciadas. Utiliza hilos de fondo (`threading`) para evitar el bloqueo del bucle principal de la UI (`mainloop`) durante la escucha de sockets:
* **Muro de Boxes (`tablero_ingeniero.py`):** Panel interactivo que permite al ingeniero de pista inyectar datos de sensores (Flujo de combustible, Fuerza G, Presión de frenos, temperaturas) mediante deslizadores y monitorear el rendimiento del procesador embebido (TEP y TRP en microsegundos).
* **Volante del Piloto (`volante.py`):** Pantalla pasiva que replica el instrumental del monoplaza. Cuenta con alertas visuales inteligentes que tiñen de color rojo únicamente los indicadores de los sensores específicos que han entrado en un rango crítico.

---

## 📂 Estructura del Proyecto

```text
f1_simulador/
│
├── núcleo_ada/               # Código fuente en Ada (Sistemas Críticos)
│   ├── f1_main.adb           # Punto de entrada principal del sistema
│   ├── f1_types.ads          # Definición estricta de tipos de datos y deadlines
│   ├── car_ecu.ads/.adb      # Emulador físico de la unidad de control del vehículo
│   ├── threshold_db.ads/.adb # Almacenamiento pasivo de umbrales de seguridad
│   ├── alert_queue.ads/.adb  # Objeto protegido: Cola circular síncrona de reportes
│   ├── sensor_manager.ads/.adb# Tarea activa: Receptor UDP no bloqueante y parser
│   ├── alert_controller.ads/.adb# Tarea activa: Auditor analítico y calculador de métricas
│   ├── safety_monitor.ads/.adb# Tarea activa: Manejador de interrupción y failsafe
│   ├── metrics_db.ads/.adb   # Objeto protegido: Almacenamiento seguro de TEP/TRP
│   └── comm_manager.ads/.adb # Tarea activa: Transmisor UDP de estado y telemetría
│
└── interfaz_python/          # Tableros visuales independientes (GUI)
    ├── tablero_ingeniero.py  # Panel de inyección de telemetría y métricas del Pit Wall
    └── volante.py            # Panel instrumental del piloto con alertas de fallas
```

---

## 🛠️ Requisitos e Instalación

Este proyecto fue desarrollado y probado en entornos Linux (**Arch Linux**).

### 1. Dependencias del Backend (Compilador Ada)
Se requiere el compilador GNAT (GCC Ada). En distribuciones basadas en Arch se instala mediante:
```bash
sudo pacman -S gcc-ada
```

### 2. Dependencias del Frontend (Python UI)
Las interfaces utilizan la biblioteca gráfica nativa `tkinter`. Debido a la filosofía modular de Arch Linux, el soporte para interfaces Tcl/Tk debe instalarse por separado a nivel de sistema:
```bash
sudo pacman -S tk
```

---

## 🚀 Ejecución del Simulador

Para poner en marcha el entorno Hardware-in-the-Loop distribuido, se deben abrir tres terminales independientes:

### Paso 1: Compilar y correr el núcleo en Ada
Navegá hasta la carpeta del backend, compilá utilizando el gestor GNAT y ejecutá el binario:
```bash
cd núcleo_ada/
gnatmake f1_main.adb
./f1_main
```
El núcleo iniciará en silencio, inicializando los hilos concurrentes y quedando a la espera de datagramas de red.

### Paso 2: Iniciar el Volante del Piloto
En una segunda terminal, lanzá la interfaz pasiva del conductor:
```bash
cd interfaz_python/
python volante.py
```

### Paso 3: Iniciar el Panel del Ingeniero (Pit Wall)
En una tercera terminal, ejecutá el controlador de simulación:
```bash
cd interfaz_python/
python tablero_ingeniero.py
```

---

## 🧪 Pruebas Disponibles

* **Monitoreo Nominal:** Al mover los deslizadores de presión de frenos, fuerza G o temperaturas dentro de los rangos seguros establecidos en `Threshold_DB`, verás cómo los números impactan instantáneamente en el volante del piloto en tiempo real, manteniendo las métricas de espera (TEP) y retorno (TRP) estables en microsegundos.
* **Inyección de Falla Crítica:** Incrementá la temperatura del motor por encima de los `120.0 °C` o el flujo de combustible por encima de los `100.0 KG/H` (o presioná el botón de pánico en el Pit Wall). Verás cómo de manera determinista:
  1. El `Alert_Controller` detecta la anomalía en un ciclo máximo de 5ms.
  2. El `Safety_Monitor` interrumpe la ejecución normal y envía la orden a la ECU.
  3. La consola de Ada imprime la desconexión del sistema híbrido MGU y el corte de potencia a 0%.
  4. La pantalla del piloto se tiñe de rojo fuego, alertando el componente específico en falla.
