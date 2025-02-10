PROCESS BEFORE OUTPUT.
  MODULE status_0100.
  module set_init_value.
  MODULE init_process_control.


PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.
  MODULE user_command_0100.

*PROCESS ON VALUE-REQUEST.
*  FIELD gv_bpco   MODULE get_bpcode.
