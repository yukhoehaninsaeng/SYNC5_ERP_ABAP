PROCESS BEFORE OUTPUT.
  MODULE status_0100.
  MODULE init_process_control.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.

*PROCESS ON VALUE-REQUEST.
*  FIELD gv_matnr MODULE get_header_material.
