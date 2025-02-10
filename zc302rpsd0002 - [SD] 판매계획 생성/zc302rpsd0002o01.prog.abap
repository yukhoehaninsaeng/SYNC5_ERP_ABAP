*&---------------------------------------------------------------------*
*& Include          ZC302RPSD0002O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  DATA : BEGIN OF LT_MENU OCCURS 0,
    OKCODE(20),
    END OF LT_MENU.

  REFRESH : LT_MENU.
  IF GV_SAVED = 'X'.
    LT_MENU-OKCODE = 'SAVE'.
    APPEND LT_MENU.
  ENDIF.

  SET PF-STATUS 'MENU100' EXCLUDING LT_MENU.
  SET TITLEBAR 'TITLE100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_PROCESS_CONTROL OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_PROCESS_CONTROL OUTPUT.
  PERFORM DISPLAY_SCREEN.
ENDMODULE.
