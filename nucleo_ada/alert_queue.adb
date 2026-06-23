package body Alert_Queue is
   protected body Queue is

      procedure Enqueue (Level : in F1_Types.Alert_Level; Msg : in F1_Types.Alert_String) is
      begin
         if Count < Max_Size then
            Buffer (Tail) := (Level, Msg);
            Tail := (Tail + 1) mod Max_Size;
            Count := Count + 1;
         end if;
      end Enqueue;

      -- La tarea que llame a Dequeue se quedará "dormida"
      -- automáticamente si Count es 0, sin consumir CPU.
      entry Dequeue (Level : out F1_Types.Alert_Level; Msg : out F1_Types.Alert_String)
         when Count > 0 is
      begin
         Level := Buffer (Head).Level;
         Msg   := Buffer (Head).Msg;
         Head  := (Head + 1) mod Max_Size;
         Count := Count - 1;
      end Dequeue;

      function Is_Empty return Boolean is
      begin
         return Count = 0;
      end Is_Empty;

   end Queue;
end Alert_Queue;