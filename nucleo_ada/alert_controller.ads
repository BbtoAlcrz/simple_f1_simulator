with F1_Types;
with System;

package Alert_Controller is

   task type Alert_Task is
      pragma Priority (System.Priority'Last - 2);
   end Alert_Task;

   Worker : Alert_Task;

end Alert_Controller;