PROCESS BEFORE OUTPUT.
  MODULE status_0100.
  MODULE get_data.
  MODULE make_display.
  MODULE init_process_control.
*
PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.
  MODULE user_command_0100.


*-- Search help
PROCESS ON VALUE-REQUEST.
  FIELD gv_lro  MODULE get_aufnr_low.
  FIELD gv_hro  MODULE get_aufnr_high.
