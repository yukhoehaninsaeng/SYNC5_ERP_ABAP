*&---------------------------------------------------------------------*
*& Include          ZC302RPPP0005I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  CALL METHOD : go_up_grid->free,
                go_down_grid->free,
                go_up_cont->free,
                go_down_cont->free,
                go_split_cont->free,
                go_container->free.

  FREE : go_up_grid, go_down_grid, go_up_cont,
         go_down_cont, go_split_cont, go_container.

  LEAVE TO SCREEN 0.

ENDMODULE.
