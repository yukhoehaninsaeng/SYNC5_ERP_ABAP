*&---------------------------------------------------------------------*
*& Include          ZC302RPPP0003S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK pa1 WITH FRAME TITLE TEXT-t01.
  SELECT-OPTIONS : so_BOMID FOR zc302ppt0004-bomid,
                   so_matnr  FOR zc302ppt0004-matnr.
SELECTION-SCREEN END OF BLOCK pa1.
