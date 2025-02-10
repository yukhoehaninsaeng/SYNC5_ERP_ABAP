*&---------------------------------------------------------------------*
*& Include          ZC302RPMM0009I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  CALL METHOD : go_html_cntrl->free,
                go_top_cont->free,
                go_down_grid->free,
                go_down_cont->free,
                go_up_grid->free,
                go_up_cont->free,
                go_dock_cont->free.

  FREE : go_html_cntrl, go_top_cont, go_down_grid, go_down_cont,
         go_up_grid, go_up_cont, go_dock_cont.

  LEAVE TO SCREEN 0.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

ENDMODULE.
