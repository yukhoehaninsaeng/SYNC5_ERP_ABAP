PROCESS BEFORE OUTPUT.
 MODULE STATUS_0100.
 MODULE get_document_data.
 MODULE make_display_body.
 MODULE init_process_control.

PROCESS AFTER INPUT.
 MODULE exit AT EXIT-COMMAND.
 MODULE user_command_0100.

PROCESS ON VALUE-REQUEST.
  FIELD gv_spnum MODULE get_spnum. " 판매계획번호 F4 적용
