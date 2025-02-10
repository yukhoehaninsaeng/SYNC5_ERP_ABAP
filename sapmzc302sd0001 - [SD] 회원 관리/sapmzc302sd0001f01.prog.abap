*&---------------------------------------------------------------------*
*& Include          SAPMZC302SD0001F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form DISPLAY_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_SCREEN .
  IF GO_CONTAINER IS NOT BOUND.
    PERFORM SET_ALV.

    PERFORM CREATE_OBJECT.

    CALL METHOD GO_ALV_GRID->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        I_SAVE          = 'A'
        I_DEFAULT       = 'X'
        IS_LAYOUT       = GS_LAYOUT
      CHANGING
        IT_OUTTAB       = GT_MAIN
        IT_FIELDCATALOG = GT_FCAT.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ALV .
  CLEAR : GT_FCAT, GS_LAYOUT.

  PERFORM SET_FCAT USING : 'X' 'CUST_NUM'   '회원 번호' 'C' ' ',
                           ' ' 'CUST_NAME'  '회원명'   ' ' ' ',
                           ' ' 'USER_ID'    '아이디'   ' ' ' ',
                           ' ' 'ADRNR'      '주소'    ' ' ' ',
                           ' ' 'ADR_DETAIL' '상세주소'  ' ' ' ',
                           ' ' 'PSTLZ'      '우편번호'  'C' ' ',
                           ' ' 'TELNR'      '전화번호'  'C' ' ',
                           ' ' 'EMAIL'      '이메일'   'C' ' ',
                           ' ' 'BANKA'      '은행명'   'C' ' ',
                           ' ' 'BANKN'      '계좌번호'  ' ' ' '.

  PERFORM SET_LAYOUT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT .
  CREATE OBJECT GO_CONTAINER
    EXPORTING
      CONTAINER_NAME = 'MAIN_CONT'.

  CREATE OBJECT GO_ALV_GRID
    EXPORTING
      I_PARENT = GO_CONTAINER.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_FCAT  USING PV_KEY
                     PV_FIELD
                     PV_COLTEXT
                     PV_JUST
                     PV_EMPHASIZE.

  CLEAR : GS_FCAT.
  GS_FCAT-KEY       = PV_KEY.
  GS_FCAT-FIELDNAME = PV_FIELD.
  GS_FCAT-COLTEXT   = PV_COLTEXT.
  GS_FCAT-JUST      = PV_JUST.
  GS_FCAT-EMPHASIZE = PV_EMPHASIZE.

  APPEND GS_FCAT TO GT_FCAT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT .
  GS_LAYOUT-ZEBRA      = ABAP_TRUE.
  GS_LAYOUT-CWIDTH_OPT = 'A'.
  GS_LAYOUT-SEL_MODE   = 'D'.
  GS_LAYOUT-GRID_TITLE = '회원 리스트'.
  GS_LAYOUT-SMALLTITLE = ABAP_TRUE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CUST_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_CUST_DATA .
  DATA : LV_PATTERN TYPE STRING.

*-- 검색 조건 세팅
  CLEAR : GR_CUSNUM, GR_CUSNUM[].

  " 회원 번호
  IF GV_CUSNUM_FROM IS NOT INITIAL.
    GR_CUSNUM-SIGN = 'I'.
    GR_CUSNUM-OPTION = 'EQ'.
    GR_CUSNUM-LOW = GV_CUSNUM_FROM.
    IF GV_CUSNUM_TO IS NOT INITIAL.
      GR_CUSNUM-OPTION = 'BT'.
      GR_CUSNUM-HIGH = GV_CUSNUM_TO.
    ENDIF.
    APPEND GR_CUSNUM.
  ENDIF.

  " 회원명 패턴 세팅
  CONCATENATE '%' GV_CUSNAME '%' INTO LV_PATTERN.

*-- Get Customer Data
  CLEAR : GT_MAIN.
  SELECT CUST_NUM CUST_NAME USER_ID ADRNR ADR_DETAIL
         PSTLZ TELNR EMAIL BANKA BANKN
    INTO CORRESPONDING FIELDS OF TABLE GT_MAIN
    FROM ZC302MT0002
    WHERE CUST_NUM  IN GR_CUSNUM
      AND CUST_NAME LIKE LV_PATTERN.

  GV_NUM = LINES( GT_MAIN ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CUST_F4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_CUST_F4 .
*-- 회원번호 필드에 대한 Search Help 데이터 불러오기
  CLEAR : GT_CUST_F4.
  SELECT CUST_NUM CUST_NAME
    FROM ZC302MT0002
    INTO CORRESPONDING FIELDS OF TABLE GT_CUST_F4.

*-- 데이터 불러오기 실패 시 에러 메시지 디스플레이
  IF SY-SUBRC <> 0.
    MESSAGE S001 WITH TEXT-E01 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .
*-- 전체 회원 데이터 가져오기
  IF GT_MAIN IS INITIAL.
    PERFORM GET_CUST_DATA.
    GV_TOTAL = LINES( GT_MAIN ).
  ENDIF.

*-- 회원 번호 Search Help 데이터
  IF GT_CUST_F4 IS INITIAL.
    PERFORM GET_CUST_F4.
  ENDIF.
ENDFORM.
