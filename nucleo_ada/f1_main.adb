with Ada.Text_IO;
with F1_Types;
with Car_ECU;
with Threshold_DB;
with Sensor_Manager;
with Safety_Monitor;
with Alert_Controller;
with Metrics_DB;
with Comm_Manager;

procedure F1_Main is
begin
   Ada.Text_IO.Put_Line ("🏎️ [Sistema F1] Inicializando módulos del monoplaza...");
   
   Threshold_DB.Initialize;
   
   Ada.Text_IO.Put_Line ("✅ [Sistema F1] Sistema en ejecución. Presioná Ctrl+C para salir.");
   
   loop
      delay 1.0; 
   end loop;
end F1_Main;