with F1_Types;
with System;

package Safety_Monitor is

   -- Objeto protegido que actúa como una interrupción de hardware
   protected type Failsafe_Handler is
      pragma Interrupt_Priority (System.Interrupt_Priority'Last);
      
      procedure Alert_Signal (Level : in F1_Types.Alert_Level);
      entry Wait_For_Alert (Level : out F1_Types.Alert_Level);
   private
      Pending   : Boolean := False;
      Sig_Level : F1_Types.Alert_Level := F1_Types.NORMAL;
   end Failsafe_Handler;

   Handler : Failsafe_Handler;

   -- Tarea con prioridad absoluta
   task type Safety_Task is
      pragma Priority (System.Priority'Last);
   end Safety_Task;

   Monitor : Safety_Task;

end Safety_Monitor;