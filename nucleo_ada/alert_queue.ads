with F1_Types;

package Alert_Queue is

   Max_Size : constant Natural := 32;

   type Alert_Entry is record
      Level : F1_Types.Alert_Level;
      Msg   : F1_Types.Alert_String;
   end record;

   type Alert_Array is array (0 .. Max_Size - 1) of Alert_Entry;

   protected Queue is
      procedure Enqueue (Level : in F1_Types.Alert_Level; Msg : in F1_Types.Alert_String);
      
      entry Dequeue (Level : out F1_Types.Alert_Level; Msg : out F1_Types.Alert_String);
      
      function Is_Empty return Boolean;
   private
      -- Variables de estado mutables
      Head, Tail : Natural := 0;
      Count      : Natural := 0;
      Buffer     : Alert_Array;
   end Queue;

end Alert_Queue;