with F1_Types;
with System;

package Sensor_Manager is

   -- Tarea activa que se despierta periódicamente
   task type Sensor_Task is
      pragma Priority (System.Priority'Last - 1);
   end Sensor_Task;

   -- Instanciamos el trabajador
   Sensor_Worker : Sensor_Task;

   -- Operación pública para leer el último snapshot válido
   function Read_All_Sensors return F1_Types.TelemetryArray;

end Sensor_Manager;