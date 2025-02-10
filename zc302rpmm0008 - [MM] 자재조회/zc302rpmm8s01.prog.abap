*&---------------------------------------------------------------------*
*& Include          ZC302RPMM8S01
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK pa1 WITH FRAME TITLE TEXT-i01.

  SELECT-OPTIONS: so_mat FOR zc302mmt0013-matnr,
                  so_bpc FOR zc302mt0007-bpcode,
                  so_sco FOR zc302mmt0013-scode,
                  so_mta FOR zc302mmt0013-mtart NO INTERVALS NO-EXTENSION.

 SELECTION-SCREEN END OF BLOCK  pa1.
