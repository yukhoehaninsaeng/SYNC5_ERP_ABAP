*&---------------------------------------------------------------------*
*& Include          ZC302RPFI0003S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK sls WITH FRAME TITLE TEXT-i01.

  SELECT-OPTIONS: so_bukrs FOR zc302fit0001-bukrs, " 회사 번호
                  so_gjahr FOR zc302fit0001-gjahr, " 회계 연도
                  so_belnr FOR zc302fit0001-belnr, " 전표 번호
                  so_buzei FOR zc302fit0002-buzei. " 전표 상세 번호

SELECTION-SCREEN END OF BLOCK sls.
