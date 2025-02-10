*&---------------------------------------------------------------------*
*& Include          ZC302RPPP0003I01
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

  FREE : go_left_grid, go_right_grid, go_left_cont,
         go_right_cont, go_split_cont, go_container.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_HEADER_MATERIAL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*MODULE get_header_material INPUT.
*
*  PERFORM get_header_material_f4.
*
*ENDMODULE.
