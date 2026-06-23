with Ada.Text_IO;
with F1_Types; use F1_Types;

package body Threshold_DB is

   -- Nuestra base de datos interna es un arreglo
   DB : F1_Types.Threshold_Map;

   procedure Initialize is
   begin
      -- Cargamos umbrales máximos y mínimos seguros
      DB (F1_Types.ENGINE_TEMP)    := (Upper_Limit => 120.0, Lower_Limit => 80.0);
      DB (F1_Types.TYRE_FL)        := (Upper_Limit => 110.0, Lower_Limit => 70.0);
      DB (F1_Types.TYRE_FR)        := (Upper_Limit => 110.0, Lower_Limit => 70.0);
      DB (F1_Types.TYRE_RL)        := (Upper_Limit => 110.0, Lower_Limit => 70.0);
      DB (F1_Types.TYRE_RR)        := (Upper_Limit => 110.0, Lower_Limit => 70.0);
      DB (F1_Types.BRAKE_PRESSURE) := (Upper_Limit => 150.0, Lower_Limit => 0.0);
      DB (F1_Types.FUEL_FLOW)      := (Upper_Limit => 100.0, Lower_Limit => 0.0);
      DB (F1_Types.G_FORCE)        := (Upper_Limit => 6.0,   Lower_Limit => -6.0);
      DB (F1_Types.GPS_SPEED)      := (Upper_Limit => 360.0, Lower_Limit => 0.0);
      
      Ada.Text_IO.Put_Line ("[Threshold_DB 💾 ] Límites umbrales inicializados y listos.");
   end Initialize;

   function Get_Limit (S : in F1_Types.Sensor_Id) return F1_Types.Threshold_Record is
   begin
      return DB (S);
   end Get_Limit;

   procedure Set_Limit (S : in F1_Types.Sensor_Id; Limit : in F1_Types.Threshold_Record) is
   begin
      DB (S) := Limit;
   end Set_Limit;

end Threshold_DB;