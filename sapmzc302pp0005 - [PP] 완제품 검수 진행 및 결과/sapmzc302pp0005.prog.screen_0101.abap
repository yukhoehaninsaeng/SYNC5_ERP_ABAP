PROCESS BEFORE OUTPUT.
  MODULE status_0101.
  MODULE init_process_control2.

PROCESS AFTER INPUT.
  MODULE exit_pop AT EXIT-COMMAND.
  MODULE user_command_0101.  " 팝업창에서 검수, 취소 눌렀을 때
