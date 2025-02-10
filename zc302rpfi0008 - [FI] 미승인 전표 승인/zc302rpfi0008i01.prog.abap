*&---------------------------------------------------------------------*
*& Include          ZC302RPFI0008I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  CALL METHOD : go_bot_grid->free, go_top_grid->free, go_left_grid->free,
                go_bot_cont->free, go_top_cont->free, go_left_cont->free,
                go_split2->free, go_right_cont->free, go_split->free,
                go_cont->free.

  FREE : go_bot_grid, go_top_grid, go_left_grid,
         go_bot_cont, go_top_cont, go_left_cont,
         go_right_cont, go_split, go_split2, go_cont.

  LEAVE TO SCREEN 0.

ENDMODULE.
