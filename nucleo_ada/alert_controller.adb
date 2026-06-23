with F1_Types; use F1_Types;
with Ada.Real_Time; use Ada.Real_Time;
with Sensor_Manager;
with Threshold_DB;
with Alert_Queue;
with Safety_Monitor;
with Metrics_DB;

package body Alert_Controller is

   task body Alert_Task is
      Next_Activation : Time;
      Data            : F1_Types.TelemetryArray;
      Threshold       : F1_Types.Threshold_Record;
      Msg_Buffer      : Alert_String := (others => ' ');
      
      Wakeup_Time     : Time;
      Finish_Time     : Time;
      Falla_Detectada : Boolean;
   begin
      -- Se le da medio segundo al programa para que inicialice
      -- la base de datos de umbrales y los sensores hagan su primera lectura
      delay 0.5;
      Next_Activation := Clock;

      loop
         Next_Activation := Next_Activation + F1_Types.ALERT_DEADLINE;
         
         Wakeup_Time := Clock;
         Data := Sensor_Manager.Read_All_Sensors;
         Falla_Detectada := False;
         
         for S in F1_Types.Sensor_Id loop
            if Data(S).Valid then
               Threshold := Threshold_DB.Get_Limit (S);
               
               if Data(S).Value > Threshold.Upper_Limit 
                  or else Data(S).Value < Threshold.Lower_Limit 
               then
                  Falla_Detectada := True;
                  Msg_Buffer(1..18) := "THRESHOLD_EXCEEDED";
                  Alert_Queue.Queue.Enqueue (CRITICAL, Msg_Buffer);
                  Safety_Monitor.Handler.Alert_Signal (CRITICAL);
               end if;
            end if;
         end loop;
         
         if Falla_Detectada then
            Metrics_DB.Stats.Set_Status (CRITICAL);
         else
            Metrics_DB.Stats.Set_Status (NORMAL);
         end if;
         
         Finish_Time := Clock;
         
         -- Solo restamos tiempos si el dato ya es válido y existe en memoria
         if Data(F1_Types.ENGINE_TEMP).Valid then
            Metrics_DB.Stats.Register_Times
              (TEP => Wakeup_Time - Data(F1_Types.ENGINE_TEMP).Timestamp,
               TRP => Finish_Time - Data(F1_Types.ENGINE_TEMP).Timestamp);
         end if;
         
         delay until Next_Activation;
      end loop;
   end Alert_Task;

end Alert_Controller;