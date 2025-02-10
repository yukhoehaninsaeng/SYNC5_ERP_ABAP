*&---------------------------------------------------------------------*
*& Include          ZC302RPFI0008S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK ss1 WITH FRAME TITLE TEXT-i01.

  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : pa_all  RADIOBUTTON GROUP rb1 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 10(10) TEXT-t01 FOR FIELD pa_all.
    PARAMETERS : pa_nall RADIOBUTTON GROUP rb1.
    SELECTION-SCREEN : COMMENT 25(10) TEXT-t02 FOR FIELD pa_nall.
  SELECTION-SCREEN END OF LINE.

  SELECT-OPTIONS : so_bpcde FOR zc302mt0001-bpcode.

SELECTION-SCREEN END OF BLOCK ss1.
