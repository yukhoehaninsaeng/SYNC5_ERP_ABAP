PROCESS BEFORE OUTPUT.
  MODULE status_0101.

PROCESS AFTER INPUT.
  MODULE pop_exit AT EXIT-COMMAND.
  MODULE user_command_0101.

PROCESS ON VALUE-REQUEST.
  FIELD gv_dtype MODULE f4_dtype.
  FIELD gv_dcomp MODULE f4_dcomp.
