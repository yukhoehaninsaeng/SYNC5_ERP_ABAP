PROCESS BEFORE OUTPUT.
  MODULE status_0100.
  MODULE init_process_control.

*-- 활성탭에 따른 서브스크린 번호를 세팅해줌.
  MODULE active_tab.

  CALL SUBSCREEN sub_area INCLUDING sy-repid gv_subscreen.

PROCESS AFTER INPUT.
  CALL SUBSCREEN sub_area.
  MODULE exit AT EXIT-COMMAND.
  MODULE process_tab.
* MODULE USER_COMMAND_0100.
