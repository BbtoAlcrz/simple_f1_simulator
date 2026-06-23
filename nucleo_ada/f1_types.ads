with Ada.Real_Time; use Ada.Real_Time;

package F1_Types is

   -- Identificadores de los sensores del monoplaza
   type Sensor_Id is
     (ENGINE_TEMP, TYRE_FL, TYRE_FR, TYRE_RL, TYRE_RR,
      BRAKE_PRESSURE, FUEL_FLOW, G_FORCE, GPS_SPEED);

   type Sensor_Value is new Float;

   -- Estructura para almacenar la telemetría de un sensor
   type TelemetryRecord is record
      Timestamp : Time;
      Sensor    : Sensor_Id;
      Value     : Sensor_Value;
      Valid     : Boolean := False;
   end record;

   type TelemetryArray is array (Sensor_Id) of TelemetryRecord;

   -- Niveles de riesgo del auto
   type Alert_Level is (NORMAL, WARNING, CRITICAL, FAILSAFE);

   -- Rangos permitidos
   type Threshold_Record is record
      Upper_Limit : Sensor_Value;
      Lower_Limit : Sensor_Value;
   end record;

   type Threshold_Map is array (Sensor_Id) of Threshold_Record;

   -- Subtipo para que los strings de alerta tengan tamaño fijo (evita problemas en Ada)
   subtype Alert_String is String (1 .. 64);

   -- Tiempos límite estrictos (Deadlines) en milisegundos
   SENSOR_DEADLINE   : constant Time_Span := Milliseconds (1);
   ALERT_DEADLINE    : constant Time_Span := Milliseconds (5);
   FAILSAFE_DEADLINE : constant Time_Span := Milliseconds (2);
   COMM_PERIOD       : constant Time_Span := Milliseconds (20);

end F1_Types;