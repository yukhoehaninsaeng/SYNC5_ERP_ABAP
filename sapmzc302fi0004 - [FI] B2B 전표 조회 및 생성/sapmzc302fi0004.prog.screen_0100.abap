PROCESS BEFORE OUTPUT.
 MODULE status_0100.
 MODULE init_process_control.

PROCESS AFTER INPUT.
 MODULE exit AT EXIT-COMMAND.
 MODULE user_command_0100.

PROCESS ON VALUE-REQUEST.
 FIELD gv_blart MODULE on_blart_f4.
 FIELD gv_pernr MODULE on_pernr_f4.
 FIELD gv_waers MODULE on_waers_f4.
 FIELD gv_bpcode MODULE on_bpcode_f4.
 FIELD gv_hkont MODULE on_hkont_f4.
