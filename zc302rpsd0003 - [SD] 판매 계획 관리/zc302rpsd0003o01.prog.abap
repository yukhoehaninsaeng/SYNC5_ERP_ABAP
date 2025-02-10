*&---------------------------------------------------------------------*
*& Include          ZC302RPSD0003O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module INIT_CONTROL_PROCESS OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_PROCESS_CONTROL OUTPUT.
  PERFORM DISPLAY_SCREEN.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0101 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0101 OUTPUT.
  DATA : BEGIN OF LT_MENU OCCURS 0,
         OKCODE(10),
       END OF LT_MENU.

  REFRESH : LT_MENU.
  IF GV_MODE = 'C'.     " 생성 이벤트일 때는 생성 버튼만
    LT_MENU-OKCODE = 'MDFY'.
    APPEND LT_MENU.
  ELSEIF GV_MODE = 'M'. " 수정 이벤트일 떄는 수정 버튼만
    LT_MENU-OKCODE = 'IADD'.
    APPEND LT_MENU.
  ENDIF.

  SET PF-STATUS 'MENU101' EXCLUDING LT_MENU.
  SET TITLEBAR 'TITLE101'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_SCREEN OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_SCREEN OUTPUT.
  PERFORM INIT_SCREEN.
ENDMODULE.
