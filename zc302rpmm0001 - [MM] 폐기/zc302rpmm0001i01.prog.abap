*&---------------------------------------------------------------------*
*& Include          ZC302RPMM0001I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  CALL METHOD : go_bottom_grid->free,
                go_top_grid->free,
                go_bottom_cont->free,
                go_top_cont->free,
                go_splitter_cont->free,
                go_container->free.

  FREE : go_bottom_grid, go_top_grid, go_bottom_cont, go_top_cont,
         go_splitter_cont, go_container.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE gv_okcode.
    WHEN 'DCD'.
      PERFORM discard.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_POP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_pop INPUT.

   CALL METHOD : go_text_cont->free,
                go_text_edit->free.

  FREE : go_text_cont, go_text_edit.

  LEAVE TO SCREEN 0.

ENDMODULE.
