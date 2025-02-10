*&---------------------------------------------------------------------*
*& Include          SAPMZC302SD0002I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_CHNL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_CHNL INPUT.
  PERFORM GET_CHNL_F4.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CASE GV_OKCODE.
    WHEN 'SRCH'.  " 조회 버튼 클릭 시 핸들링
      PERFORM SEARCH_SO.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PROCESS_TAB  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PROCESS_TAB INPUT.
  IF GV_OKCODE(3) EQ 'TAB'.
    GV_TAB = GV_OKCODE.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_POPUP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_POPUP INPUT.

  CALL METHOD : GO_ALV_POP->FREE, GO_CONT_POP->FREE,
                GO_ALV_QTY_MAT->FREE, GO_ALV_QTY_DAT->FREE,
                GO_CONT_QTY_MAT->FREE, GO_CONT_QTY_DAT->FREE,
                GO_SPLIT_CONT->FREE, GO_CONT_QTY->FREE.

  FREE : GO_ALV_POP, GO_CONT_POP, GO_ALV_QTY_MAT, GO_ALV_QTY_DAT,
         GO_CONT_QTY_MAT, GO_CONT_QTY_DAT, GO_SPLIT_CONT, GO_CONT_QTY.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0101 INPUT.
  CASE GV_OKCODE.
    WHEN 'APPR'.
      PERFORM APPROVE_ORDER.
    WHEN 'RJCT'.
      PERFORM REJECT_ORDER.
      IF GV_CLOSE_OPT = 'X'.
        LEAVE TO SCREEN 0.
      ENDIF.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_TD_POPUP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_TD_POPUP INPUT.
  CALL METHOD : GO_TEXT_EDIT->FREE,
                GO_CONT_TE->FREE.

  FREE : GO_TEXT_EDIT, GO_CONT_TE.

  LEAVE TO SCREEN 0.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_BP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_BP INPUT.
  PERFORM GET_BP_F4.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_103  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_103 INPUT.
  CALL METHOD : GO_ALV_DETAIL->FREE, GO_CONT_DETAIL->FREE.

  FREE : GO_ALV_DETAIL, GO_CONT_DETAIL.

  LEAVE TO SCREEN 0.
ENDMODULE.
