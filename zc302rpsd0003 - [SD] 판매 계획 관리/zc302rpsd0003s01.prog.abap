*&---------------------------------------------------------------------*
*& Include          ZC302RPSD0003S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-T01.
  PARAMETERS : P_SORG TYPE ZC302SDT0001-SALE_ORG MODIF ID ORG.    " 영업조직
  SELECT-OPTIONS : S_CHNL FOR ZC302SDT0001-CHANNEL NO-EXTENSION,  " 유통채널
                   S_PYEAR FOR ZC302SDT0001-PYEAR NO-EXTENSION,   " 계획연도
                   S_MONTH FOR ZC302SDT0001-PMONTH NO-EXTENSION.  " 계획월
SELECTION-SCREEN END OF BLOCK B1.
