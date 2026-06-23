with Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
with Ada.Streams;   use Ada.Streams;
with GNAT.Sockets;  use GNAT.Sockets;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;
with F1_Types;      use F1_Types;

package body Sensor_Manager is

   Current_Data : F1_Types.TelemetryArray;

   protected Data_Lock is
      procedure Write (Data : in F1_Types.TelemetryArray);
      function Read return F1_Types.TelemetryArray;
   private
      Stored : F1_Types.TelemetryArray;
   end Data_Lock;

   protected body Data_Lock is
      procedure Write (Data : in F1_Types.TelemetryArray) is
      begin
         Stored := Data;
      end Write;

      function Read return F1_Types.TelemetryArray is
      begin
         return Stored;
      end Read;
   end Data_Lock;

   task body Sensor_Task is
      Next_Activation : Time := Clock;
      Snapshot        : F1_Types.TelemetryArray;
      
      Sock     : Socket_Type;
      Address  : Sock_Addr_Type;
      -- Agrandamos buffer a 256 bytes para lectura del JSON
      Data_Arr : Stream_Element_Array (1 .. 256);
      Last     : Stream_Element_Offset;
      From     : Sock_Addr_Type;
      Req      : Request_Type;
      
      function Extraer_Valor (JSON : String; Clave : String) return Float is
         Idx : Natural := Index (JSON, Clave);
         Start_Pos, End_Pos : Natural;
      begin
         if Idx > 0 then
            Start_Pos := Idx + Clave'Length;
            End_Pos := Index (JSON (Start_Pos .. JSON'Last), ",");
            if End_Pos = 0 then End_Pos := Index (JSON (Start_Pos .. JSON'Last), "}"); end if;
            return Float'Value (JSON (Start_Pos .. End_Pos - 1));
         end if;
         return 0.0;
      exception
         when others => return 0.0;
      end Extraer_Valor;

   begin
      Initialize;
      Create_Socket (Sock, Family_Inet, Socket_Datagram);
      Address.Addr := Addresses (Get_Host_By_Name ("127.0.0.1"), 1);
      Address.Port := 5000;
      Bind_Socket (Sock, Address);
      Req := (Name => Non_Blocking_IO, Enabled => True);
      Control_Socket (Sock, Req);
      
      Ada.Text_IO.Put_Line ("[Sensor_Manager 📡 ] Escuchando telemetría en UDP 5000...");

      for S in F1_Types.Sensor_Id loop
         Snapshot(S).Sensor := S;
         Snapshot(S).Valid  := True;
         Snapshot(S).Value  := (if S = F1_Types.G_FORCE then 0.0 else 90.0);
         Snapshot(S).Timestamp := Clock;
      end loop;

      loop
         Next_Activation := Next_Activation + F1_Types.SENSOR_DEADLINE;
         
         begin
            Receive_Socket (Sock, Data_Arr, Last, From);
            declare
               Msg : String (1 .. Natural(Last));
            begin
               for I in 1 .. Natural(Last) loop
                  Msg(I) := Character'Val(Data_Arr(Stream_Element_Offset(I)));
               end loop;
               
               -- TODOS los sensores del JSON
               Snapshot(ENGINE_TEMP).Value := F1_Types.Sensor_Value(Extraer_Valor(Msg, """ENGINE_TEMP"":"));
               Snapshot(GPS_SPEED).Value   := F1_Types.Sensor_Value(Extraer_Valor(Msg, """SPEED"":"));
               Snapshot(FUEL_FLOW).Value   := F1_Types.Sensor_Value(Extraer_Valor(Msg, """FUEL_FLOW"":"));
               Snapshot(TYRE_FL).Value     := F1_Types.Sensor_Value(Extraer_Valor(Msg, """TYRE_FL"":"));
               Snapshot(TYRE_FR).Value     := F1_Types.Sensor_Value(Extraer_Valor(Msg, """TYRE_FR"":"));
               Snapshot(TYRE_RL).Value     := F1_Types.Sensor_Value(Extraer_Valor(Msg, """TYRE_RL"":"));
               Snapshot(TYRE_RR).Value     := F1_Types.Sensor_Value(Extraer_Valor(Msg, """TYRE_RR"":"));
               Snapshot(BRAKE_PRESSURE).Value := F1_Types.Sensor_Value(Extraer_Valor(Msg, """BRAKE_PRESSURE"":"));
               Snapshot(G_FORCE).Value     := F1_Types.Sensor_Value(Extraer_Valor(Msg, """G_FORCE"":"));
            end;
         exception
            when Socket_Error => null; 
         end;

         for S in F1_Types.Sensor_Id loop
            Snapshot(S).Timestamp := Clock;
         end loop;

         Data_Lock.Write (Snapshot);
         delay until Next_Activation;
      end loop;
   end Sensor_Task;

   function Read_All_Sensors return F1_Types.TelemetryArray is
   begin
      return Data_Lock.Read;
   end Read_All_Sensors;

end Sensor_Manager;