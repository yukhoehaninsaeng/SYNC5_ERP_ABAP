*&---------------------------------------------------------------------*
*& Include          SAPMZC302FI0003I01
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
                go_split_cont->Free,
                go_container->free.

  FREE : go_left_grid, go_right_grid,
         go_left_cont, go_right_cont,
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
    WHEN 'SRCH'.
      PERFORM get_data_base.
      PERFORM make_display_body.
      CALL METHOD go_left_grid->refresh_table_display.
  ENDCASE.

ENDMODULE.
