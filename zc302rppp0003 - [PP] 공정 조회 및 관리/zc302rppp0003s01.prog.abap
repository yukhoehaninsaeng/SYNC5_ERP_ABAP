*&---------------------------------------------------------------------*
*& Include          ZC302RPPP0004S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK so1 WITH FRAME TITLE TEXT-so1.

  SELECT-OPTIONS: so_pco FOR zc302ppt0008-pcode,
                  so_bom FOR zc302ppt0008-bomid.

SELECTION-SCREEN END OF BLOCK so1.
