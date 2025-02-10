*&---------------------------------------------------------------------*
*& Include          ZC302RPMM0007S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK pa1 WITH FRAME TITLE TEXT-i01.
  SELECT-OPTIONS : so_mbl FOR zc302mmt0011-mblnr NO INTERVALS NO-EXTENSION,
*                   so_mjahr FOR zc302mmt0011-mjahr NO INTERVALS NO-EXTENSION,
                   so_move FOR zc302mmt0011-movetype NO INTERVALS NO-EXTENSION.
SELECTION-SCREEN END OF BLOCK PA1.
