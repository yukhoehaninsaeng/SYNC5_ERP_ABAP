*&---------------------------------------------------------------------*
*& Include          ZC302RPPP0006I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  CALL METHOD: go_alv_grid->free,
               go_container->free.

  FREE: go_alv_grid, go_container.

  LEAVE TO SCREEN 0.

ENDMODULE.
