*&---------------------------------------------------------------------*
*& Include          ZC302RPSD0006S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK pa1 WITH FRAME TITLE TEXT-i01.
  SELECT-OPTIONS : so_dlvn FOR zc302sdt0005-dlvnum   NO-EXTENSION NO INTERVALS,
                   so_sonu FOR zc302sdt0005-sonum    NO-EXTENSION NO INTERVALS,
                   so_sale FOR zc302sdt0005-sale_org NO-EXTENSION NO INTERVALS MODIF ID sal.
*                   so_chan FOR zc302sdt0005-channel  NO-EXTENSION NO INTERVALS.
SELECTION-SCREEN END OF BLOCK pa1.
