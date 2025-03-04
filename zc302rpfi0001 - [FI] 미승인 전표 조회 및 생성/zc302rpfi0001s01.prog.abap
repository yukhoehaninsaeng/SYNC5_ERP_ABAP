*&---------------------------------------------------------------------*
*& Include          ZC302RPFI0001S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK sls WITH FRAME TITLE TEXT-i01.
  " 매입처 매출처 선택 파라미터
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : pa_sell RADIOBUTTON GROUP sb USER-COMMAND btn DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 20(10) TEXT-t01 FOR FIELD pa_sell.
    PARAMETERS : pa_buy RADIOBUTTON GROUP sb.
    SELECTION-SCREEN COMMENT 40(10) TEXT-t02 FOR FIELD pa_buy.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN SKIP.

  SELECTION-SCREEN BEGIN OF BLOCK sls2 WITH FRAME TITLE TEXT-i02.
    " 미승인 전표 발행 여부에 따른 조회 파라미터
    SELECTION-SCREEN BEGIN OF LINE.
      PARAMETERS : pa_all RADIOBUTTON GROUP rb1 USER-COMMAND rb1 DEFAULT 'X'.
      SELECTION-SCREEN COMMENT 10(5) TEXT-t04 FOR FIELD pa_all.
      PARAMETERS : pa_not RADIOBUTTON GROUP rb1.
      SELECTION-SCREEN COMMENT 30(5) TEXT-t05 FOR FIELD pa_not.
      PARAMETERS : pa_yes RADIOBUTTON GROUP rb1.
      SELECTION-SCREEN COMMENT 40(5) TEXT-t06 FOR FIELD pa_yes.
    SELECTION-SCREEN END OF LINE.

    " select options
    SELECT-OPTIONS : so_bpcd FOR zc302sdt0009-bpcode.
  SELECTION-SCREEN END OF BLOCK sls2.



SELECTION-SCREEN END OF BLOCK sls.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_bpcd-low.
  PERFORM on_f4_bpcode_low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_bpcd-high.
  PERFORM on_f4_bpcode_high.
