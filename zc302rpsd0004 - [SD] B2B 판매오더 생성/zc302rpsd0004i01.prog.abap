*&---------------------------------------------------------------------*
*& Include          ZC302RPSD0004I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.
  CALL METHOD : GO_ALV_ITEM->FREE, GO_CONT_ITEM->FREE.

  FREE : GO_ALV_ITEM, GO_CONT_ITEM.

  LEAVE TO SCREEN 0.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  CASE GV_OKCODE.
    WHEN 'SAVE'.
      PERFORM SAVE_EXCEL_DATA.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CASE GV_OKCODE.
    WHEN 'SAVE'.
      PERFORM SAVE_DIRECT_INPUT.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0101 INPUT.
  CALL METHOD : GO_ALV_SO->FREE, GO_CONT_SO->FREE.

  FREE : GO_ALV_SO, GO_CONT_SO.

  LEAVE TO SCREEN 0.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_300 INPUT.
  CALL METHOD : GO_PRE_ALV_T->FREE, GO_PRE_ALV_B->FREE,
                GO_PRE_CONT_T->FREE, GO_PRE_CONT_B->FREE,
                GO_PRE_SPLIT->FREE, GO_PRE_CONT->FREE.

  FREE : GO_PRE_ALV_T, GO_PRE_ALV_B, GO_PRE_CONT_T, GO_PRE_CONT_B, GO_PRE_SPLIT, GO_PRE_CONT.

  LEAVE TO SCREEN 0.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_TD_POPUP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_TD_POPUP INPUT.
  CALL METHOD : GO_TEXT_EDIT->FREE,
  GO_TEXT_CONT->FREE.

  FREE : GO_TEXT_EDIT, GO_TEXT_CONT.

  LEAVE TO SCREEN 0.
ENDMODULE.
