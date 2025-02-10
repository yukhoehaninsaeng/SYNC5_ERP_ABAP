PROCESS BEFORE OUTPUT.
  MODULE status_0100.
  MODULE init_get_base_data.
  MODULE init_process_control.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.
  MODULE user_command_0100.

PROCESS ON VALUE-REQUEST.
  FIELD gv_bpcode   MODULE get_bpcode.
  FIELD gv_channel  MODULE get_channel.
