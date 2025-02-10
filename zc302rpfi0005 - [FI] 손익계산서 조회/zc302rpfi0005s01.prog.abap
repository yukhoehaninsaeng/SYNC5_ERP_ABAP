*&---------------------------------------------------------------------*
*& Include          ZC302RPFI0005S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK pa1 WITH FRAME TITLE TEXT-i01.
  PARAMETERS : pa_buk TYPE zc302fit0002-bukrs MODIF ID buk.
  SELECTION-SCREEN COMMENT 40(25) pa_butxt MODIF ID but.

  PARAMETERS : pa_gja TYPE zc302fit0002-gjahr.
  SELECT-OPTIONS : so_mon FOR zc302fit0001-budat+5(2) NO-EXTENSION.

*  SELECT-OPTIONS : so_dat FOR zc302fit0001-budat+5(2) NO-EXTENSION.

SELECTION-SCREEN END OF BLOCK pa1.
PARAMETERS pa_check AS CHECKBOX.
