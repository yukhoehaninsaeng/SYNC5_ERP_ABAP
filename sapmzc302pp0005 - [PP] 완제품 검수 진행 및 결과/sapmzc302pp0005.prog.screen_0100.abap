PROCESS BEFORE OUTPUT.
  MODULE status_0100.
  MODULE get_document_data.
  MODULE make_display_icon.
  MODULE init_process_control.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.
  MODULE user_command_0100.   " 조회, 초기화 버튼
