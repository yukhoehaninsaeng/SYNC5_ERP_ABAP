PROCESS BEFORE OUTPUT.
 MODULE status_0100.
 MODULE get_data_base.
 MODULE init_process_control.
*
PROCESS AFTER INPUT.
 MODULE exit AT EXIT-COMMAND.
 MODULE user_command_0100.

PROCESS ON VALUE-REQUEST.
   FIELD GV_MATNR MODULE GET_MATERIAL.
