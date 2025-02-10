PROCESS BEFORE OUTPUT.
  MODULE status_0100.
  MODULE get_document_data.
  MODULE make_display_body.
  MODULE init_process_control.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.
  MODULE user_command_0100.

PROCESS ON VALUE-REQUEST.
  FIELD gv_plord MODULE get_plordco.
  FIELD gv_matnr MODULE get_material.
