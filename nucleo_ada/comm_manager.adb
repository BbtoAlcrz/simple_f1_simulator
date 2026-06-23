with F1_Types; use F1_Types;
with Ada.Real_Time; use Ada.Real_Time;
with GNAT.Sockets;  use GNAT.Sockets;
with Ada.Streams;   use Ada.Streams;
with Sensor_Manager;
with Metrics_DB;

package body Comm_Manager is

   task body Comm_Task is
      Next_Tx : Time := Clock;
      Packet  : F1_Types.TelemetryArray;
      
      Sock       : Socket_Type;
      Addr_Vol   : Sock_Addr_Type; -- Volante Piloto
      Addr_Ing   : Sock_Addr_Type; -- Pit Wall Ingeniero
      
      -- Funciones para armar los JSON a mano (Ada no tiene parser nativo simple)
      function Armar_JSON_Volante return String is
         Stat : String := (if Metrics_DB.Stats.Get_Status = NORMAL then """NORMAL""" else """CRITICAL""");
         
         -- Mini función de ayuda para no escribir tanto texto
         function F (S : F1_Types.Sensor_Id) return String is
         begin
            return Float'Image(Float(Packet(S).Value));
         end F;
      begin
         return "{""ENGINE_TEMP"":" & F(ENGINE_TEMP) &
                ",""SPEED"":" & F(GPS_SPEED) &
                ",""FUEL_FLOW"":" & F(FUEL_FLOW) &
                ",""TYRE_FL"":" & F(TYRE_FL) &
                ",""TYRE_FR"":" & F(TYRE_FR) &
                ",""TYRE_RL"":" & F(TYRE_RL) &
                ",""TYRE_RR"":" & F(TYRE_RR) &
                ",""BRAKE_PRESSURE"":" & F(BRAKE_PRESSURE) &
                ",""G_FORCE"":" & F(G_FORCE) &
                ",""STATUS"":" & Stat & "}";
      end Armar_JSON_Volante;

      function Armar_JSON_Ingeniero return String is
      begin
         return "{""TEP"":" & Integer'Image(Metrics_DB.Stats.Get_TEP_us) &
                ",""TRP"":" & Integer'Image(Metrics_DB.Stats.Get_TRP_us) & "}";
      end Armar_JSON_Ingeniero;
      
   begin
      -- Inicializar sockets
      Initialize;
      Create_Socket (Sock, Family_Inet, Socket_Datagram);
      
      Addr_Vol.Addr := Addresses (Get_Host_By_Name ("127.0.0.1"), 1);
      Addr_Vol.Port := 5001;
      
      Addr_Ing.Addr := Addresses (Get_Host_By_Name ("127.0.0.1"), 1);
      Addr_Ing.Port := 5002;

      loop
         Next_Tx := Next_Tx + F1_Types.COMM_PERIOD;
         Packet  := Sensor_Manager.Read_All_Sensors;
         
         -- Enviamos los paquetes por UDP asincrónicamente
         declare
            Vol_Msg : constant String := Armar_JSON_Volante;
            Ing_Msg : constant String := Armar_JSON_Ingeniero;
            Vol_Arr : Stream_Element_Array (1 .. Vol_Msg'Length);
            Ing_Arr : Stream_Element_Array (1 .. Ing_Msg'Length);
            Last    : Stream_Element_Offset;
         begin
            for I in Vol_Msg'Range loop Vol_Arr(Stream_Element_Offset(I)) := Character'Pos(Vol_Msg(I)); end loop;
            for I in Ing_Msg'Range loop Ing_Arr(Stream_Element_Offset(I)) := Character'Pos(Ing_Msg(I)); end loop;
            
            Send_Socket (Sock, Vol_Arr, Last, Addr_Vol);
            Send_Socket (Sock, Ing_Arr, Last, Addr_Ing);
         end;
         
         delay until Next_Tx;
      end loop;
   end Comm_Task;

end Comm_Manager;