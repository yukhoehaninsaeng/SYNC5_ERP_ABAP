*&---------------------------------------------------------------------*
*& Include          ZC302RPFI0009I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  CALL METHOD : go_lbot_grid->free, go_ltop_grid->free,
                go_rbot_grid->free, go_rtop_grid->free,
                go_lbot_cont->free, go_ltop_cont->free,
                go_rbot_cont->free, go_rtop_cont->free,
                go_split->free, go_cont->free.
  FREE : go_lbot_grid, go_ltop_grid, go_rbot_grid, go_rtop_grid,
         go_lbot_cont, go_ltop_cont, go_rbot_cont, go_rtop_cont,
         go_split, go_cont.

  LEAVE TO SCREEN 0.
ENDMODULE.
