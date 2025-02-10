*&---------------------------------------------------------------------*
*& Include          SAPMZC302PP0005I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  CALL METHOD : go_alv_grid->free,
                go_container->free.

  FREE : go_alv_grid, go_container.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_POP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_pop INPUT.

  CALL METHOD : go_text_edit->free,
                go_pop_cont->free.

  FREE : go_text_edit, go_pop_cont.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0101 INPUT.

  CASE gv_okcode.
    WHEN 'CHK1'.
      PERFORM make_check_data.
    WHEN 'CAN1'.
      CLEAR gv_okcode.
      CALL METHOD go_text_edit->delete_text.    " text editor 클리어
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
      PERFORM calc_menge.     " 스페이스바 눌렀을 때 반응
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE gv_okcode.
    WHEN 'CHK1'.
      PERFORM get_range_data.
    WHEN 'INI1'.
      PERFORM reset_select_data.
    WHEN 'RDBT'.
      PERFORM get_data.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_POP2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_pop2 INPUT.

  CALL METHOD : go_text_edit2->free,
                go_pop_cont2->free.

  FREE : go_text_edit2, go_pop_cont2.

  LEAVE TO SCREEN 0.

ENDMODULE.
