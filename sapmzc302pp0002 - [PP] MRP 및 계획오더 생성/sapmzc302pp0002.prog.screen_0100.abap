PROCESS BEFORE OUTPUT.
  MODULE status_0100.
  MODULE get_document_data.
  MODULE make_display_body.
  MODULE init_process_control.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.
  MODULE user_command_0100.

PROCESS ON VALUE-REQUEST.
  FIELD gv_pdpcode MODULE get_pdpcode. " 생산계획번호 F4 적용
  FIELD gv_pdpdat  MODULE get_pdpdat.  " 생산계획일자 F4 적용
