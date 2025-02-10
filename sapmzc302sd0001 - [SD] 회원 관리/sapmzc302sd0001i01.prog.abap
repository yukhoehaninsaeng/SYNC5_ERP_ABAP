*&---------------------------------------------------------------------*
*& Include          SAPMZC302SD0001I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.
  CALL METHOD : GO_ALV_GRID->FREE,
                GO_CONTAINER->FREE.

  FREE : GO_ALV_GRID, GO_CONTAINER.

  LEAVE TO SCREEN 0.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CASE GV_OKCODE.
    WHEN 'SRCH'.
      PERFORM GET_CUST_DATA.
  ENDCASE.
  CALL METHOD GO_ALV_GRID->REFRESH_TABLE_DISPLAY.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_CUST_F4  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_CUST_F4 INPUT.
  DATA : LT_RETURN TYPE TABLE OF DDSHRETVAL WITH HEADER LINE.

*-- Execute Search Help(F4)
  REFRESH LT_RETURN.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'CUST_NUM'
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'GV_CUSNUM_FROM'
      WINDOW_TITLE    = 'Customer Number'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = GT_CUST_F4
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
ENDMODULE.
