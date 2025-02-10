PROCESS BEFORE OUTPUT.
  MODULE status_0100.
  MODULE init_process_control.
  MODULE active_tab.

  CALL SUBSCREEN sub_area INCLUDING sy-repid gv_subscreen.

PROCESS AFTER INPUT.
  CALL SUBSCREEN sub_area.

  MODULE process_tab.
  MODULE exit AT EXIT-COMMAND.
