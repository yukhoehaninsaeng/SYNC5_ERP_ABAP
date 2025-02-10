*&---------------------------------------------------------------------*
*& Include          SAPMZC302PP0004I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  CALL METHOD: go_right_grid->free,
               go_cent_grid->free,
               go_left_grid->free,
               go_up_grid->free,
               go_right_cont->free,
               go_cent_cont->free,
               go_left_cont->free,
               go_split_cont2->free,
               go_down_cont->free,
               go_up_cont->free,
               go_split_cont1->free,
               go_container->free.

  FREE: go_right_grid, go_cent_grid, go_left_grid, go_up_grid,
        go_right_cont, go_cent_cont, go_left_cont, go_split_cont2,
        go_down_cont, go_up_cont, go_split_cont1, go_container.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_PONUM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_ponum INPUT.

  PERFORM get_ponum_f4.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_MATERIAL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_material INPUT.

  PERFORM get_material_f4.

ENDMODULE.
