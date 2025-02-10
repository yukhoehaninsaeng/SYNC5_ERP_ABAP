PROCESS BEFORE OUTPUT.
  MODULE status_0101.
  MODULE modify_screen.
  MODULE check_menge.
  MODULE disreason_input.

*
PROCESS AFTER INPUT.
  MODULE exit_popup AT EXIT-COMMAND.
  MODULE user_command_0101.
*
*PROCESS ON VALUE-REQUEST.
*  FIELD gv_dismenge MODULE CALC_MENGE.
