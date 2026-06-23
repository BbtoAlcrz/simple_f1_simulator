with F1_Types;

package Threshold_DB is
   procedure Initialize;
   
   function Get_Limit (S : in F1_Types.Sensor_Id) return F1_Types.Threshold_Record;
   
   procedure Set_Limit (S : in F1_Types.Sensor_Id; Limit : in F1_Types.Threshold_Record);
end Threshold_DB;