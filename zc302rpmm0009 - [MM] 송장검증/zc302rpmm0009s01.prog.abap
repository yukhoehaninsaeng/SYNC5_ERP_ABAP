*&---------------------------------------------------------------------*
*& Include          ZC302RPMM0009S01
*&---------------------------------------------------------------------*


SELECTION-SCREEN BEGIN OF BLOCK pa1 WITH FRAME TITLE TEXT-i01.

  SELECT-OPTIONS : so_au FOR zc302mmt0007-aufnr,    " 구매오더번호
                   so_bo FOR zc302mmt0007-bodat.    " 발주일자

SELECTION-SCREEN END OF BLOCK pa1.
