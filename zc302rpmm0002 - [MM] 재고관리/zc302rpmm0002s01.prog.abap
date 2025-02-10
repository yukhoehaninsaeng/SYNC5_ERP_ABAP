*&---------------------------------------------------------------------*
*& Include          ZC302RPMM0002S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK pa1 WITH FRAME TITLE TEXT-i01.
  SELECT-OPTIONS : so_type FOR zc302mmt0002-mtart NO INTERVALS NO-EXTENSION
                                                  MODIF ID TP ,
                   so_mat FOR zc302mmt0002-matnr NO INTERVALS NO-EXTENSION,
                   so_scode FOR zc302mmt0002-scode NO INTERVALS NO-EXTENSION.
SELECTION-SCREEN END OF BLOCK pa1.
