PROCESS BEFORE OUTPUT.
  MODULE STATUS_0100.
  MODULE INIT_DATA.
  MODULE INIT_PROCESS_CONTROL.

PROCESS AFTER INPUT.
  MODULE EXIT AT EXIT-COMMAND.
  MODULE USER_COMMAND_0100.

PROCESS ON VALUE-REQUEST.
    FIELD GV_CUSNUM_FROM MODULE GET_CUST_F4.
    FIELD GV_CUSNUM_TO   MODULE GET_CUST_F4.
