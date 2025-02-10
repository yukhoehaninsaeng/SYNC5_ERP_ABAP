*&---------------------------------------------------------------------*
*& Include          ZC302RPPP0002S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK so1 WITH FRAME TITLE TEXT-s01.

  SELECT-OPTIONS: so_qin FOR zc302ppt0012-qinum,
                  so_pon FOR zc302ppt0012-ponum.

  SELECTION-SCREEN SKIP.

  SELECT-OPTIONS: so_mat FOR zc302ppt0012-matnr NO INTERVALS NO-EXTENSION.

  SELECTION-SCREEN SKIP.

  SELECT-OPTIONS: so_mak FOR zc302ppt0012-qidat.

SELECTION-SCREEN END OF BLOCK so1.
