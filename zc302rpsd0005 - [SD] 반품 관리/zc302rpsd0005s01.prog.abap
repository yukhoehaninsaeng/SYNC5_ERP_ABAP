*&---------------------------------------------------------------------*
*& Include          ZC302RPSD0005S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK pa1 WITH FRAME TITLE TEXT-i01.
  SELECT-OPTIONS : so_rfnum FOR zc302sdt0007-rfnum NO-EXTENSION NO INTERVALS,
                   so_sonum FOR zc302sdt0007-sonum NO-EXTENSION NO INTERVALS.
SELECTION-SCREEN END OF BLOCK pa1.
