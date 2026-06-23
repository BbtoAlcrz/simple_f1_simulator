with Ada.Text_IO;

package body Car_ECU is

   procedure Set_Power_Limit (Limit : in Integer) is
   begin
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("[ECU🚨] ALERTA Límite de potencia configurado en: " & Integer'Image(Limit) & "%");
   end Set_Power_Limit;

   procedure Disengage_MGU is
   begin
      Ada.Text_IO.Put_Line ("[ECU ⚡ ] Desconectando el sistema híbrido MGU (Recuperación de Energía).");
   end Disengage_MGU;

   procedure Emergency_Stop is
   begin
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("[ECU 🛑 ] PARADA DE EMERGENCIA CRÍTICA INICIADA");
   end Emergency_Stop;

end Car_ECU;