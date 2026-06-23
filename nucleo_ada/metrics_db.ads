with F1_Types;
with Ada.Real_Time; use Ada.Real_Time;

package Metrics_DB is
   protected Stats is
      -- Guarda el Tiempo de espera promedio (TEP) y Tiempo de Retorno promedio (TRP)
      procedure Register_Times (TEP, TRP : Time_Span);
      procedure Set_Status (Status : in F1_Types.Alert_Level);
      
      function Get_TEP_us return Integer;
      function Get_TRP_us return Integer;
      function Get_Status return F1_Types.Alert_Level;
   private
      TEP_Microseconds : Integer := 0;
      TRP_Microseconds : Integer := 0;
      Current_Status   : F1_Types.Alert_Level := F1_Types.NORMAL;
   end Stats;
end Metrics_DB;