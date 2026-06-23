package body Metrics_DB is
   protected body Stats is
      procedure Register_Times (TEP, TRP : Time_Span) is
      begin
         -- Convertimos los Time_Span puros de Ada a microsegundos enteros
         TEP_Microseconds := TEP / Microseconds(1);
         TRP_Microseconds := TRP / Microseconds(1);
      end Register_Times;

      procedure Set_Status (Status : in F1_Types.Alert_Level) is
      begin
         Current_Status := Status;
      end Set_Status;

      function Get_TEP_us return Integer is
      begin
         return TEP_Microseconds;
      end Get_TEP_us;

      function Get_TRP_us return Integer is
      begin
         return TRP_Microseconds;
      end Get_TRP_us;

      function Get_Status return F1_Types.Alert_Level is
      begin
         return Current_Status;
      end Get_Status;
   end Stats;
end Metrics_DB;