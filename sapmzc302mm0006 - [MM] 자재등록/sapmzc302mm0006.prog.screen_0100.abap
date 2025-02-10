PROCESS BEFORE OUTPUT.
  MODULE status_0100.
  MODULE get_base_data.
  MODULE init_process_control.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.
  MODULE user_command_0100.

PROCESS ON VALUE-REQUEST.
  FIELD gs_elem-bpcode MODULE get_bpcode. "gs_elem-bpcode에 대해 이벤트 처리 붙임
