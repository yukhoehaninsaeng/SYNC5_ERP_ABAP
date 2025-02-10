PROCESS BEFORE OUTPUT.
  MODULE status_0100.
  MODULE get_qc_data.

  MODULE init_process_control.

*
PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.
  MODULE user_command_0100.

PROCESS ON VALUE-REQUEST.
  FIELD gv_po_low   MODULE get_aufnr_low.
  FIELD gv_po_high  MODULE get_aufnr_high.
