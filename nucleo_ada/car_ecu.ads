package Car_ECU is

   -- Define la interfaz de control que el sistema de tiempo real puede tocar
   procedure Set_Power_Limit (Limit : in Integer);
   procedure Disengage_MGU;
   procedure Emergency_Stop;

end Car_ECU;