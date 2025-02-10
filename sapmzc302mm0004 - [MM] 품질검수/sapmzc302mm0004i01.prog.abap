*&---------------------------------------------------------------------*
*& Include          SAPMZC302MM0004I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE gv_okcode.
    WHEN 'SH'.      " 검색 조회
      PERFORM search_data.
  ENDCASE.

  PERFORM refresh_table.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  CALL METHOD : go_alv_grid->free,
                go_cont->free.

  FREE : go_cont, go_alv_grid.

  LEAVE TO SCREEN 0.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0101 INPUT.

  CASE gv_okcode.
    WHEN 'DISR'. "폐기 사유 text editor
      PERFORM input_disreason.
    WHEN 'QCC'.   " 검수확인

      IF gv_dismenge > 0 AND gs_body-disreason IS INITIAL.  " 폐기수량 존재하는데 폐기사유를 입력 안했을때 오류메세지
        PERFORM save_error_message.
      ELSE. " 그외 조건을 통과하면 데이터 저장하기 위한 로직
        PERFORM input_data.

      ENDIF.
    WHEN 'QCCAN'. " 검수취소
      PERFORM qccan.
    WHEN OTHERS.
      PERFORM set_final_quan.
  ENDCASE.

  PERFORM refresh_table.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_POPUP1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_popup1 INPUT.

  PERFORM exit_popup.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0102 INPUT.
  CASE gv_okcode.
    WHEN 'OK'.
      PERFORM disreason_save.
    WHEN 'CANC'.
      PERFORM exit_popup.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_POPUP2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_popup2 INPUT.

  CALL METHOD : go_text_cont2->free,
                go_text_edit2->free.

  FREE : go_text_cont2, go_text_edit2.

  LEAVE TO SCREEN 0.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_AUFNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_aufnr_low INPUT.

  PERFORM get_aufnr_f4.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_AUFNR_HIGH  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_aufnr_high INPUT.

  PERFORM get_aufnr_f4_2.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CALC_MENGE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE calc_menge INPUT.

ENDMODULE.
