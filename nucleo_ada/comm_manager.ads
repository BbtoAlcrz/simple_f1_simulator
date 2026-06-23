with System;

package Comm_Manager is

   -- Tarea activa de baja prioridad para enviar datos por red (Periodo: 20ms)
   task type Comm_Task is
      pragma Priority (System.Priority'Last - 4);
   end Comm_Task;

   -- Instancia del trabajador que se ejecutará en paralelo automáticamente
   Comm_Worker : Comm_Task;

end Comm_Manager;