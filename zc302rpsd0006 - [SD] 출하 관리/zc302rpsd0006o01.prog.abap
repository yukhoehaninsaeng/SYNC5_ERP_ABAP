*&---------------------------------------------------------------------*
*& Include          ZC302RPSD0006O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'MENU100'.
  SET TITLEBAR 'TITLE100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_PROCESS_CONTROL OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_process_control OUTPUT.

  PERFORM display_screen.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module ACTIVE_TAB OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE active_tab OUTPUT.

*-- 선택탭 활성화
  IF gv_tab IS INITIAL.
    go_tab_strip-activetab = 'TAB1'.
  ELSE.
    go_tab_strip-activetab = gv_tab.
  ENDIF.

*-- 활성탭에 해당하는 Subscreen 번호 세팅
  CASE gv_tab.
    WHEN 'TAB1'.
      gv_subscreen = '0110'.
    WHEN 'TAB2'.
      gv_subscreen = '0120'.
    WHEN 'TAB3'.
      gv_subscreen = '0130'.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0101 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0101 OUTPUT.
  SET PF-STATUS 'MENU101'.
  SET TITLEBAR 'TITLE101'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_POPUP_CONTROL OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_popup_control OUTPUT.

  PERFORM display_popup.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0102 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0102 OUTPUT.
  SET PF-STATUS 'MENU102'.
  SET TITLEBAR 'TITLE102'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_POPUP2_CONTROL OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_popup2_control OUTPUT.

  PERFORM display_popup2.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0103 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0103 OUTPUT.
  SET PF-STATUS 'MENU103'.
  SET TITLEBAR 'TITLE103'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_POPUP3_CONTROL OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_popup3_control OUTPUT.

  PERFORM display_popup3.

ENDMODULE.
