*&---------------------------------------------------------------------*
*& Include          ZC302RPPP0005S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK pa1 WITH FRAME TITLE TEXT-t01.
  SELECT-OPTIONS : so_plant FOR ZC302MT0004-plant,
                   so_scode  FOR ZC302MT0005-scode.
SELECTION-SCREEN END OF BLOCK pa1.
