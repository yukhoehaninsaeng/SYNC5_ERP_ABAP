*&---------------------------------------------------------------------*
*& Include          ZC302RPSD0002F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CREATE_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_PLAN.
  DATA : LV_DATE_FR  TYPE ZC302SDT0003-SDATE,
         LV_DATE_TO  TYPE ZC302SDT0003-SDATE,
         LV_SPNUM    TYPE ZC302SDT0001-SPNUM,
         LV_INDEX    TYPE NUMC3,
         LV_PRE_YEAR TYPE ZC302SDT0001-PYEAR.

  DATA : BEGIN OF LS_SPNUM,
           SPNUM TYPE ZC302SDT0001-SPNUM,
         END OF LS_SPNUM,
         LT_SPNUM         LIKE TABLE OF LS_SPNUM,
         LV_CONDITION(11).

  " 이전 년도 해당 월 판매오더 자재별 수량
  DATA : BEGIN OF LS_SALE,
           MATNR TYPE ZC302SDDBV0001-MATNR,
           MENGE TYPE ZC302SDDBV0001-MENGE,
           MEINS TYPE ZC302SDDBV0001-MEINS,
         END OF LS_SALE,
         LT_SALE LIKE TABLE OF LS_SALE.

  " 완제품 단가 & 통화
  DATA : BEGIN OF LS_MAT,
           MATNR TYPE ZC302MT0007-MATNR,
           MAKTX TYPE ZC302MT0007-MAKTX,
           NETWR TYPE ZC302MT0007-NETWR,
           WAERS TYPE ZC302MT0007-WAERS,
         END OF LS_MAT,
         LT_MAT LIKE TABLE OF LS_MAT.

  DATA : LV_QTY_SUM TYPE I VALUE 0,  " 계획 총 수량
         LV_CKY_SUM TYPE I VALUE 0.  " 계획 총 금액

**********************************************************************
* 판매 계획 재생성 -> 기존 판매 계획 삭제
**********************************************************************
  IF GV_ANSWER = '2'.
    " 기존 판매 계획 번호
    SELECT SINGLE SPNUM
      FROM ZC302SDT0001
      INTO GV_PRE_SPNUM
      WHERE SALE_ORG = P_SORG
        AND CHANNEL  = P_CHAN
        AND PYEAR    = P_YEAR
        AND PMONTH   = P_MONTH.
  ENDIF.

**********************************************************************
* 판매 계획 Header 기본 정보 기입
**********************************************************************
  CLEAR : GS_PLAN, GT_PLAN.

*-- 판매계획번호 채번
  LV_CONDITION = 'SPN' && P_YEAR && '%'. " 찾을 패턴 구성 : SPN + 현재연도 + % / 연도마다 뒷 3자리가 001, 002, ...로 증가

  " 해당 패턴으로 이루어진(SPN + 현재년도로 시작하는) 판매계획번호를 매칭하여 가져옴
  SELECT SPNUM
    FROM ZC302SDT0001
    INTO CORRESPONDING FIELDS OF TABLE LT_SPNUM
    WHERE SPNUM LIKE LV_CONDITION.

  IF LT_SPNUM IS INITIAL.
    " 기존 데이터에 'SPN + 현재년도'로 시작하는 데이터가 없는 경우(해당 연도에 처음으로 생성하는 판매계획인 경우)
    LV_INDEX = '001'.
  ELSE.
    " 기존 데이터 중 가장 큰 판매계획 번호를 읽어옴
    SORT LT_SPNUM BY SPNUM DESCENDING.
    READ TABLE LT_SPNUM INTO LV_SPNUM INDEX 1.
    " 1을 더함
    LV_INDEX = LV_SPNUM+7(3) + 1.
  ENDIF.

  " 새로운 판매계획번호 생성
  GS_PLAN-SPNUM = 'SPN' && P_YEAR && LV_INDEX.

  " 영업조직, 유통채널, 계획년도, 계획월, 판매계획일자
  GS_PLAN-SALE_ORG = P_SORG.
  GS_PLAN-CHANNEL  = P_CHAN.
  GS_PLAN-PYEAR    = P_YEAR.
  GS_PLAN-PMONTH   = P_MONTH.
  GS_PLAN-DATUM    = SY-DATUM.

  " Timestamp
  GS_PLAN-ERDAT = SY-DATUM.
  GS_PLAN-ERZET = SY-UZEIT.
  GS_PLAN-ERNAM = SY-UNAME.

**********************************************************************
* 이전 연도/월 판매오더 데이터 가져옴
**********************************************************************
  LV_PRE_YEAR = P_YEAR - 1. " 이전 연도

  CONCATENATE LV_PRE_YEAR P_MONTH '01' INTO LV_DATE_FR.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = LV_DATE_FR
    IMPORTING
      LAST_DAY_OF_MONTH = LV_DATE_TO.

  " 이전 년도 해당 월 판매오더 : 자재별 총 판매 수량(자재코드, 수량, 단위)
  CLEAR : LT_SALE.
  SELECT MATNR
         SUM( MENGE ) AS MENGE
         MEINS
    INTO CORRESPONDING FIELDS OF TABLE LT_SALE
    FROM ZC302SDDBV0001
    WHERE SALE_ORG = P_SORG     " 영업 조직
      AND CHANNEL  = P_CHAN     " 유통채널
      AND STATUS   = 'A'        " 승인여부(승인)
      AND PDATE BETWEEN LV_DATE_FR AND LV_DATE_TO " 판매오더생성일
    GROUP BY MATNR MEINS.

**********************************************************************
* 판매 계획 Item 생성
**********************************************************************
  " 완제품 단가 불러옴(자재코드, 단가, 단위)
  CLEAR : LS_MAT, LT_MAT.
  SELECT MATNR MAKTX NETWR WAERS
    FROM ZC302MT0007
    INTO CORRESPONDING FIELDS OF TABLE LT_MAT
    WHERE MTART = '03'. " 완제품

  SORT LT_MAT BY MATNR.

  CLEAR : LS_SALE.
  LOOP AT LT_SALE INTO LS_SALE.
    CLEAR : GS_ITEM.
    " 판매계획번호, 아이템번호
    GS_ITEM-SPNUM = GS_PLAN-SPNUM.
    GS_ITEM-POSNR = GV_ITEM_NUM.
    GV_ITEM_NUM = GV_ITEM_NUM + 10.

    " 자재코드, 판매수량, 단위
    GS_ITEM-MATNR = LS_SALE-MATNR.
    GS_ITEM-MENGE = LS_SALE-MENGE.
    GS_ITEM-MEINS = LS_SALE-MEINS.
    LV_QTY_SUM = LV_QTY_SUM + GS_ITEM-MENGE. " 총계획수량

    " 총 판매금액, 통화
    READ TABLE LT_MAT INTO LS_MAT WITH KEY MATNR = LS_SALE-MATNR
                                           BINARY SEARCH.
    IF SY-SUBRC = 0.
      GS_ITEM-MAKTX = LS_MAT-MAKTX.
      GS_ITEM-NETWR = LS_MAT-NETWR * GS_ITEM-MENGE. " 단가 * 수량
      GS_ITEM-WAERS = LS_MAT-WAERS.
      LV_CKY_SUM = LV_CKY_SUM + GS_ITEM-NETWR.
    ENDIF.

    " Timestamp
    GS_ITEM-ERDAT = SY-DATUM.
    GS_ITEM-ERZET = SY-UZEIT.
    GS_ITEM-ERNAM = SY-UNAME.

    APPEND GS_ITEM TO GT_ITEM.

    CLEAR : LS_SALE.
  ENDLOOP.

  GS_PLAN-MENGE = LV_QTY_SUM.
  GS_PLAN-MEINS = 'EA'.
  GS_PLAN-TOSAL = LV_CKY_SUM.
  GS_PLAN-WAERS = GS_ITEM-WAERS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_VALUE .
  P_SORG  = '0001'.
  P_YEAR  = SY-DATUM(4).
  P_MONTH = SY-DATUM+4(2).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_SCREEN .
  LOOP AT SCREEN.
    CASE SCREEN-GROUP1.
      WHEN 'ORG'.
        SCREEN-INPUT = 0.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_SCREEN .
  DATA : LS_VARIANT TYPE DISVARIANT.

  IF GO_CONT IS NOT BOUND.
    CLEAR : GS_LAYOUT, GT_FCAT, GT_FCAT.
    PERFORM SET_FCAT USING : 'X' 'SPNUM'    '판매계획번호'  'C' ' ',
                             'X' 'POSNR'    '아이템번호'   'C' ' ',
                             ' ' 'MATNR'    '자재코드'    'C' ' ',
                             ' ' 'MAKTX'    '자재명'     ' ' 'X',
                             ' ' 'MENGE'    '수량'      ' ' ' ',
                             ' ' 'MEINS'    '단위'      ' ' ' ',
                             ' ' 'NETWR'    '금액'      ' ' ' ',
                             ' ' 'WAERS'    '통화'      ' ' ' '.
    PERFORM SET_LAYOUT.

    PERFORM CREATE_OBJECT.

    PERFORM REGISTER_EVENT.

    LS_VARIANT-REPORT = SY-REPID.
    LS_VARIANT-HANDLE = 'ALV1'.

    CALL METHOD GO_ALV->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        I_SAVE          = 'A'
        I_DEFAULT       = 'X'
        IS_LAYOUT       = GS_LAYOUT
        IS_VARIANT      = LS_VARIANT
      CHANGING
        IT_OUTTAB       = GT_ITEM
        IT_FIELDCATALOG = GT_FCAT.
  ENDIF.

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
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_FCAT  USING PV_KEY
                     PV_FIELD
                     PV_TEXT
                     PV_JUST
                     PV_EMP.
  CLEAR : GS_FCAT.
  GS_FCAT-KEY = PV_KEY.
  GS_FCAT-FIELDNAME = PV_FIELD.
  GS_FCAT-COLTEXT = PV_TEXT.
  GS_FCAT-JUST = PV_JUST.
  GS_FCAT-EMPHASIZE = PV_EMP.

  CASE PV_FIELD.
    WHEN 'MENGE'.
      GS_FCAT-QFIELDNAME = 'MEINS'.
    WHEN 'NETWR'.
      GS_FCAT-CFIELDNAME = 'WAERS'.
  ENDCASE.

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
FORM SET_LAYOUT.
  GS_LAYOUT-ZEBRA      = ABAP_TRUE.
  GS_LAYOUT-CWIDTH_OPT = 'A'.
  GS_LAYOUT-SEL_MODE   = 'D'.
  GS_LAYOUT-GRID_TITLE = '판매계획 Item'.
  GS_LAYOUT-SMALLTITLE = ABAP_TRUE.
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
*-- Top-of-page : Install Docking Container for Top-of-page(맨위에 오브젝트 생성)
  CREATE OBJECT GO_TOP_CONTAINER
    EXPORTING
      REPID     = SY-CPROG
      DYNNR     = SY-DYNNR
      SIDE      = GO_TOP_CONTAINER->DOCK_AT_TOP
      EXTENSION = 70. " Top of page 높이

*-- Container
  CREATE OBJECT GO_CONT
    EXPORTING
      CONTAINER_NAME = 'MAIN_CONT'.

*-- ALV Grid
  CREATE OBJECT GO_ALV
    EXPORTING
      I_PARENT = GO_CONT.

*-- Top-of-page : Create TOP-Document(맨 마지막에 작성)
  CREATE OBJECT GO_DYNDOC_ID
    EXPORTING
      STYLE = 'ALV_GRID'.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.
  CALL METHOD : GO_ALV->FREE,
                GO_CONT->FREE.

  FREE : GO_ALV, GO_CONT.

  LEAVE TO SCREEN 0.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SAVE_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_PLAN .
  DATA : LT_ITEM   TYPE TABLE OF ZC302SDT0002,
         PV_ANSWER.

  " 저장 컨펌 팝업
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = '판매계획 생성'
      TEXT_QUESTION         = '해당 판매계획을 생성하시겠습니까?'
      TEXT_BUTTON_1         = '예'(001)
      ICON_BUTTON_1         = 'ICON_OKAY'
      TEXT_BUTTON_2         = '아니오'(002)
      ICON_BUTTON_2         = 'ICON_CANCEL'
      DEFAULT_BUTTON        = '1'
      DISPLAY_CANCEL_BUTTON = ' '
    IMPORTING
      ANSWER                = PV_ANSWER.

  IF PV_ANSWER <> '1'.
    MESSAGE S001 WITH TEXT-I01 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  " 판매 계획을 재생성하는 경우 -> 기존 판매계획 Header & Item 삭제
  IF GV_ANSWER = '2'.
    DELETE FROM ZC302SDT0001 WHERE SPNUM = GV_PRE_SPNUM.
    DELETE FROM ZC302SDT0002 WHERE SPNUM = GV_PRE_SPNUM.

    IF SY-SUBRC <> 0.
      MESSAGE S001 WITH TEXT-E01 DISPLAY LIKE 'E'.
      EXIT.
      CLEAR : GV_ANSWER.
    ENDIF.
  ENDIF.

  " 판매 계획 Header 저장
  INSERT INTO ZC302SDT0001 VALUES GS_PLAN.

  IF SY-SUBRC = 0.
    " 판매 계획 Item 저장
    MOVE-CORRESPONDING GT_ITEM TO LT_ITEM.

    INSERT ZC302SDT0002 FROM TABLE LT_ITEM.

    IF SY-SUBRC = 0.
      MESSAGE S001 WITH TEXT-S01.
      GV_SAVED = 'X'.
      COMMIT WORK AND WAIT.
    ELSE.
      MESSAGE S001 WITH TEXT-E02 DISPLAY LIKE 'E'.
      ROLLBACK WORK.
    ENDIF.
  ELSE.
    MESSAGE S001 WITH TEXT-E02 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RANGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LR_CHANNEL
*&      --> LR_YEAR
*&      --> LR_MONTH
*&---------------------------------------------------------------------*
FORM SET_RANGE.

  REFRESH : GR_CHANNEL, GR_YEAR, GR_MONTH.
  IF P_CHAN IS NOT INITIAL.
    GR_CHANNEL-SIGN = 'I'.
    GR_CHANNEL-OPTION = 'EQ'.
    GR_CHANNEL-LOW = P_CHAN.
    APPEND GR_CHANNEL.
  ENDIF.

  IF P_YEAR IS NOT INITIAL.
    GR_YEAR-SIGN = 'I'.
    GR_YEAR-OPTION = 'EQ'.
    GR_YEAR-LOW = P_YEAR.
    APPEND GR_YEAR.
  ENDIF.

  IF P_MONTH IS NOT INITIAL.
    GR_MONTH-SIGN = 'I'.
    GR_MONTH-OPTION = 'EQ'.
    GR_MONTH-LOW = P_MONTH.
    APPEND GR_MONTH.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DUPLICATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_DUPLICATION .
  " 중복 체크(동일 영업조직/유통채널/연도/월에 대한 판매계획이 존재하는지 확인)
  SELECT SPNUM
    FROM ZC302SDT0001
    INTO TABLE @DATA(LT_TEMP)
    WHERE SALE_ORG = @P_SORG
      AND CHANNEL  = @P_CHAN
      AND PYEAR    = @P_YEAR
      AND PMONTH   = @P_MONTH.

  IF LT_TEMP IS NOT INITIAL.
    CLEAR : GV_ANSWER.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR              = '판매 계획'
        TEXT_QUESTION         = '입력 조건에 해당하는 판매 계획이 이미 존재합니다.'
        TEXT_BUTTON_1         = '조회'(001)
        ICON_BUTTON_1         = 'ICON_DISPLAY'
        TEXT_BUTTON_2         = '재생성'(002)
        ICON_BUTTON_2         = 'ICON_CREATE'
        DEFAULT_BUTTON        = '1'
        DISPLAY_CANCEL_BUTTON = 'X'
      IMPORTING
        ANSWER                = GV_ANSWER.

    IF GV_ANSWER = '1'. " 기존 판매계획 조회
      PERFORM SET_RANGE.
      SUBMIT ZC302RPSD0003 WITH P_SORG = P_SORG
                           WITH S_CHNL IN GR_CHANNEL
                           WITH S_PYEAR IN GR_YEAR
                           WITH S_MONTH IN GR_MONTH.
    ELSEIF GV_ANSWER <> '2'.
      STOP.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EVENT_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EVENT_TOP_OF_PAGE .
  DATA : LR_DD_TABLE TYPE REF TO CL_DD_TABLE_ELEMENT, " 테이블
         COL_FIELD   TYPE REF TO CL_DD_AREA,          " 필드
         COL_VALUE   TYPE REF TO CL_DD_AREA.          " 값

  DATA : LV_TEXT TYPE SDYDO_TEXT_ELEMENT.

  DATA : LV_TEMP TYPE STRING.

*-- Create Table
  CALL METHOD GO_DYNDOC_ID->ADD_TABLE
    EXPORTING
      NO_OF_COLUMNS = 2
      BORDER        = '0'
    IMPORTING
      TABLE         = LR_DD_TABLE.

*-- Set column(Add Column to Table)
  CALL METHOD LR_DD_TABLE->ADD_COLUMN
    IMPORTING
      COLUMN = COL_FIELD.

  CALL METHOD LR_DD_TABLE->ADD_COLUMN
    IMPORTING
      COLUMN = COL_VALUE.

*-- 영업 조직 & 유통 채널
  PERFORM ADD_ROW USING LR_DD_TABLE COL_FIELD COL_VALUE '영업조직' P_SORG.
  PERFORM ADD_ROW USING LR_DD_TABLE COL_FIELD COL_VALUE '유통채널' P_CHAN.
  PERFORM ADD_ROW USING LR_DD_TABLE COL_FIELD COL_VALUE '계획연도' P_YEAR.
  PERFORM ADD_ROW USING LR_DD_TABLE COL_FIELD COL_VALUE '계획월'  P_MONTH.

  PERFORM SET_TOP_OF_PAGE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_ROW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LR_DD_TABLE
*&      --> COL_FIELD
*&      --> COL_VALUE
*&      --> P_
*&      --> P_SORG
*&---------------------------------------------------------------------*
*-- 테이블 / Column / Value / 컬럼에 입력할 값 / 값에 입력할 값
FORM ADD_ROW  USING PR_DD_TABLE  TYPE REF TO CL_DD_TABLE_ELEMENT
                    PV_COL_FIELD TYPE REF TO CL_DD_AREA
                    PV_COL_VALUE TYPE REF TO CL_DD_AREA
                    PV_FIELD
                    PV_TEXT.

  DATA : LV_TEXT TYPE SDYDO_TEXT_ELEMENT.

*-- Field에 값  세팅
  LV_TEXT = PV_FIELD.

  CALL METHOD PV_COL_FIELD->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_EMPHASIS = CL_DD_DOCUMENT=>STRONG
      SAP_COLOR    = CL_DD_DOCUMENT=>LIST_HEADING_INV.

  CALL METHOD PV_COL_FIELD->ADD_GAP
    EXPORTING
      WIDTH = 3.

*-- Value에 값 세팅
  LV_TEXT = PV_TEXT.

  CALL METHOD PV_COL_VALUE->ADD_TEXT
    EXPORTING
      TEXT         = LV_TEXT
      SAP_EMPHASIS = CL_DD_DOCUMENT=>HEADING
      SAP_COLOR    = CL_DD_DOCUMENT=>LIST_NEGATIVE_INV.

  CALL METHOD PV_COL_VALUE->ADD_GAP
    EXPORTING
      WIDTH = 3.

  CALL METHOD PR_DD_TABLE->NEW_ROW.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_TOP_OF_PAGE .

* Creating html control
  IF GO_HTML_CNTRL IS INITIAL.
    CREATE OBJECT GO_HTML_CNTRL
      EXPORTING
        PARENT = GO_TOP_CONTAINER.
  ENDIF.

  CALL METHOD GO_DYNDOC_ID->MERGE_DOCUMENT.
  GO_DYNDOC_ID->HTML_CONTROL = GO_HTML_CNTRL.

* Display document
  CALL METHOD GO_DYNDOC_ID->DISPLAY_DOCUMENT
    EXPORTING
      REUSE_CONTROL      = 'X'
      PARENT             = GO_TOP_CONTAINER
    EXCEPTIONS
      HTML_DISPLAY_ERROR = 1.

  IF SY-SUBRC NE 0.
    MESSAGE S001 WITH TEXT-E03 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REGISTER_EVENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REGISTER_EVENT .
  SET HANDLER : LCL_EVENT_HANDLER=>TOP_OF_PAGE  FOR GO_ALV.

  CALL METHOD GO_DYNDOC_ID->INITIALIZE_DOCUMENT
    EXPORTING
      BACKGROUND_COLOR = CL_DD_AREA=>COL_TEXTAREA.

  CALL METHOD GO_ALV->LIST_PROCESSING_EVENTS
    EXPORTING
      I_EVENT_NAME = 'TOP_OF_PAGE'
      I_DYNDOC_ID  = GO_DYNDOC_ID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_INPUT .
*-- 과거의 연도, 월로 판매계획 생성 불가
  IF ( P_YEAR < SY-DATUM(4) ) OR ( ( P_YEAR = SY-DATUM(4) ) AND  ( P_MONTH < SY-DATUM+4(2) ) ).
    MESSAGE S001 WITH TEXT-E04 DISPLAY LIKE 'E'.
    STOP.
  ENDIF.
ENDFORM.
