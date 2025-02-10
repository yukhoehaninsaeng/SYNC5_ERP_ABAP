*&---------------------------------------------------------------------*
*& Include          ZC302RPFI0004S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK pa1 WITH FRAME TITLE TEXT-i01.

  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : pa_rd1 RADIOBUTTON GROUP sbl USER-COMMAND evt  DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (10) FOR FIELD pa_rd1.

    PARAMETERS : pa_rd2 RADIOBUTTON GROUP sbl .
    SELECTION-SCREEN COMMENT (10) FOR FIELD  pa_rd2.

    PARAMETERS : pa_rd3 RADIOBUTTON GROUP sbl.
    SELECTION-SCREEN COMMENT (10) FOR FIELD  pa_rd3.

  SELECTION-SCREEN END OF LINE.


  SELECT-OPTIONS : so_sby FOR zc302fit0003-sbuly NO-EXTENSION NO INTERVALS OBLIGATORY,
                   so_sbd FOR zc302fit0003-sbldt NO-EXTENSION OBLIGATORY,
                   so_mat FOR zc302fit0003-matnr NO-EXTENSION NO INTERVALS.

SELECTION-SCREEN END OF BLOCK pa1.
