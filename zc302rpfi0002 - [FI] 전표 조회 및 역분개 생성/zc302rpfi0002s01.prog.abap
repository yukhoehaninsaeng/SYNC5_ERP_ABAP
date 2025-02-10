*&---------------------------------------------------------------------*
*& Include          ZC302RPFI0002S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK pa1 WITH FRAME TITLE text-i01.
  PARAMETERS : pa_buk TYPE ZC302FIT0001-bukrs OBLIGATORY MODIF ID buk.  " 회사코드
  SELECTION-SCREEN COMMENT 40(25) pa_butxt MODIF ID but.                " SYNCYOUNG

  PARAMETERS : pa_gja TYPE ZC302FIT0001-gjahr.                  " 회계연도

  SELECT-OPTIONS :  so_bud FOR ZC302FIT0001-budat NO-EXTENSION, " 전기일
                    so_bel FOR ZC302FIT0001-belnr NO-EXTENSION. " 전표번호

SELECTION-SCREEN END OF BLOCK pa1.
