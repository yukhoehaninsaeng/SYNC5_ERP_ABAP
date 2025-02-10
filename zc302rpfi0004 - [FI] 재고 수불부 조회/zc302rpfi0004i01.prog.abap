*&---------------------------------------------------------------------*
*& Include          ZC302RPFI0004I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  CALL METHOD : go_alv_grid->free,
                go_tree->free,
                go_left_cont->free,
                go_right_cont->free,
                go_base_cont->free,
                go_container->free.

  FREE : go_alv_grid, go_tree, go_left_cont, go_right_cont,
         go_base_cont, go_container.

  LEAVE TO SCREEN 0.

ENDMODULE.
