with F1_Types; use F1_Types;
with Car_ECU;
with Ada.Real_Time; use Ada.Real_Time;

package body Safety_Monitor is

   protected body Failsafe_Handler is
      procedure Alert_Signal (Level : in F1_Types.Alert_Level) is
      begin
         Sig_Level := Level;
         Pending   := True;
      end Alert_Signal;

      entry Wait_For_Alert (Level : out F1_Types.Alert_Level)
         when Pending is
      begin
         Level   := Sig_Level;
         Pending := False;
      end Wait_For_Alert;
   end Failsafe_Handler;

   task body Safety_Task is
      Received_Level : F1_Types.Alert_Level;
   begin
      loop
         -- El hilo se queda trabado acá hasta que Pending sea True
         Handler.Wait_For_Alert (Received_Level);
         
         case Received_Level is
            when CRITICAL =>
               Car_ECU.Set_Power_Limit (0);
               Car_ECU.Disengage_MGU;
            when FAILSAFE =>
               Car_ECU.Emergency_Stop;
            when others =>
               null;
         end case;
      end loop;
   end Safety_Task;

end Safety_Monitor;