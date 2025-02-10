*&---------------------------------------------------------------------*
*& Include          ZC302RPFI0009S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK ss1 WITH FRAME TITLE TEXT-i01.

  SELECTION-SCREEN BEGIN OF LINE.

    PARAMETERS : pa_all RADIOBUTTON GROUP rb1 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 20(10) TEXT-t01 FOR FIELD pa_all.
    PARAMETERS : pa_nall RADIOBUTTON GROUP rb1.
    SELECTION-SCREEN COMMENT 40(10) TEXT-t02 FOR FIELD pa_nall.

  SELECTION-SCREEN END OF LINE.

  SELECT-OPTIONS : so_bpcd FOR zc302mt0001-bpcode,
                   so_date FOR zc302fit0001-budat.

SELECTION-SCREEN END OF BLOCK ss1.
