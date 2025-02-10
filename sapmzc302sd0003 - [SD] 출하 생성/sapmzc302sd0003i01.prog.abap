*&---------------------------------------------------------------------*
*& Include          SAPMZC302SD0003I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  CALL METHOD : go_left_grid->free,
                go_right_grid->free,
                go_left_cont->free,
                go_right_cont->free,
                go_split_cont->free,
                go_container->free.

  FREE : go_left_grid, go_right_grid, go_left_cont, go_right_cont,
         go_split_cont, go_container.

  LEAVE TO SCREEN 0.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE gv_okcode.
    WHEN 'SEAR'.      " 조회번튼
      PERFORM get_base_data.
      CALL METHOD go_left_grid->refresh_table_display.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  POP_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pop_exit INPUT.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0101 INPUT.

*-- 운송업체가 빈 값이면 저장 불가
  IF gv_dcomp IS INITIAL OR gv_dtype IS INITIAL.
    MESSAGE s001 WITH '운송업체를 선택해주세요.' DISPLAY LIKE 'E'.
    EXIT.
  ELSE.
    CASE gv_okcode.
      WHEN 'CONF'.       " 운송유형 확인 버튼
        PERFORM process_confirm.
    ENDCASE.
  ENDIF.



ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_DTYPE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_dtype INPUT.

  PERFORM f4_dtype.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_DCOMP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_dcomp INPUT.

  PERFORM f4_dcomp.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_POP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_pop INPUT.

  CALL METHOD : go_pop_grid->free,
                go_pop_cont->free.

  FREE : go_pop_grid, go_pop_cont.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_BPCODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_bpcode INPUT.

  PERFORM get_bpcode_f4.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_CHANNEL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_channel INPUT.

  PERFORM get_channel_f4.

ENDMODULE.
