*&---------------------------------------------------------------------*
*& Include          SAPMZC302SD0003O01
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
*& Module STATUS_0101 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0101 OUTPUT.
  SET PF-STATUS 'MENU101'.
  SET TITLEBAR 'TITLE101'.
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
*& Module INIT_POPUP_CONTROL OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_popup_control OUTPUT.

  PERFORM display_popup.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_GET_BASE_DATA OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_get_base_data OUTPUT.

  PERFORM get_base_data.

ENDMODULE.
