*&---------------------------------------------------------------------*
*& Include          ZC302RPSD0008F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INIT_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_VALUE .

*-- BP 코드 Search Help(F4) 데이터
  SELECT BPCODE CNAME
    INTO CORRESPONDING FIELDS OF TABLE GT_BP_F4
    FROM ZC302MT0001
    WHERE BPTYPE = 'VD'.

  IF GT_BP_F4 IS INITIAL.
    MESSAGE S001 WITH TEXT-E10 DISPLAY LIKE 'E'.
  ENDIF.

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
      WHEN 'TXT'.
        SCREEN-INTENSIFIED = '1'.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BP_F4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BP_F4 .
  DATA : LT_RETURN TYPE TABLE OF DDSHRETVAL WITH HEADER LINE,
         LT_READ   TYPE TABLE OF DYNPREAD WITH HEADER LINE.

*-- BP 코드에 Search Help(F4) 설치
  REFRESH : LT_RETURN.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'BPCODE'
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'P_BPCODE'
      WINDOW_TITLE    = 'BP 코드'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = GT_BP_F4
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

*-- BP 코드 선택 시 BP 코드명 우측에 디스플레이
  LT_RETURN = VALUE #( LT_RETURN[ 1 ] OPTIONAL ).

  READ TABLE GT_BP_F4 INTO GS_BP_F4 WITH KEY BPCODE = LT_RETURN-FIELDVAL.

  REFRESH : LT_READ.
  LT_READ-FIELDNAME = 'P_BPCODE'.
  LT_READ-FIELDVALUE = LT_RETURN-FIELDVAL.
  APPEND LT_READ.
  LT_READ-FIELDNAME = 'TXT_BP'.
  LT_READ-FIELDVALUE = GS_BP_F4-CNAME.
  APPEND LT_READ.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      DYNAME               = SY-REPID
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = LT_READ
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      UNDEFIND_ERROR       = 7
      OTHERS               = 8.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SO_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SO_DATA .

*-- BP 코드와 매칭되는 SO Header 데이터 SELECT
  CLEAR : GT_HEADER.
  SELECT A~SONUM A~SALE_ORG A~CHANNEL A~BPCODE PDATE A~NETWR A~WAERS SDATE
    INTO CORRESPONDING FIELDS OF TABLE GT_HEADER
    FROM ZC302SDT0003 AS A
    INNER JOIN ZC302SDT0005 AS B
      ON A~SONUM = B~SONUM
    WHERE A~BPCODE = P_BPCODE
      AND STATUS = 'A'  " 승인된 판매오더
      AND GIFLAG = 'Y'. " GI 처리 된 판매오더

  IF GT_HEADER IS INITIAL.
    MESSAGE S001 WITH TEXT-E01 TEXT-E09 DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

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
  IF GO_CONT IS NOT BOUND.
    CLEAR : GT_FCAT, GS_LAYOUT.
*-- 판매오더 헤더  ALV 필드 카탈로그 세팅
    PERFORM SET_FCAT USING : 'X' 'SONUM'    '판매주문번호'  'C' ' ',
                             ' ' 'SALE_ORG' '영업조직'     'C' ' ',
                             ' ' 'CHANNEL'  '유통채널'     'C' ' ',
                             ' ' 'BPCODE'   'BP코드'      'C' 'X',
                             ' ' 'PDATE'    '주문일자'     'C' 'X',
                             ' ' 'NETWR'    '총액'        ' ' ' ',
                             ' ' 'WAERS'    '통화'        'C' ' ',
                             ' ' 'SDATE'    '판매오더 생성일' 'C' ' '.
*-- ALV Layout 세팅
    GS_LAYOUT = VALUE #( ZEBRA = 'X' CWIDTH_OPT = 'A' SEL_MODE = 'D' GRID_TITLE = '판매오더 리스트' SMALLTITLE = ABAP_TRUE ).

    PERFORM CREATE_OBJECT.

    PERFORM REGISTER_EVENT.

    CALL METHOD GO_ALV->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        I_SAVE          = 'A'
        I_DEFAULT       = 'X'
        IS_LAYOUT       = GS_LAYOUT
      CHANGING
        IT_OUTTAB       = GT_HEADER
        IT_FIELDCATALOG = GT_FCAT.

  ENDIF.

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

*-- Top-of-page : Install Docking Container for Top-of-page
  CREATE OBJECT GO_TOP_CONTAINER
    EXPORTING
      REPID     = SY-CPROG
      DYNNR     = SY-DYNNR
      SIDE      = GO_TOP_CONTAINER->DOCK_AT_TOP
      EXTENSION = 35.

*-- Container
  CREATE OBJECT GO_CONT
    EXPORTING
      SIDE      = GO_CONT->DOCK_AT_LEFT
      EXTENSION = 5000.

*-- ALV Grid
  CREATE OBJECT GO_ALV
    EXPORTING
      I_PARENT = GO_CONT.

*-- Top-of-page : Create TOP-Document
  CREATE OBJECT GO_DYNDOC_ID
    EXPORTING
      STYLE = 'ALV_GRID'.

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

*-------------------------------------------------------------------
* Top of Page의 레이아웃 세팅
*-------------------------------------------------------------------
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

*-------------------------------------------------------------------
* Top of Page 레이아웃에 맞춰 값 세팅
*-------------------------------------------------------------------
*-- BP 코드
  PERFORM ADD_ROW USING LR_DD_TABLE COL_FIELD COL_VALUE 'BP 코드' P_BPCODE.

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
*&      --> P_BPCODE
*&---------------------------------------------------------------------*
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

* Creating html control object
  IF GO_HTML_CNTRL IS INITIAL.
    CREATE OBJECT GO_HTML_CNTRL
      EXPORTING
        PARENT = GO_TOP_CONTAINER.
  ENDIF.

* Merge HTML Document : Top of Page의 내용을 HTML로 랜더링
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
    MESSAGE S001 WITH TEXT-E02 DISPLAY LIKE 'E'.
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
*&---------------------------------------------------------------------*
FORM SET_FCAT  USING PV_KEY
                     PV_FIELD
                     PV_TEXT
                     PV_JUST
                     PV_EMP.

  CLEAR : GS_FCAT.
  GS_FCAT-KEY       = PV_KEY.
  GS_FCAT-FIELDNAME = PV_FIELD.
  GS_FCAT-COLTEXT   = PV_TEXT.
  GS_FCAT-JUST      = PV_JUST.
  GS_FCAT-EMPHASIZE = PV_EMP.

  CASE PV_FIELD.
    WHEN 'NETWR'.
      GS_FCAT-CFIELDNAME = 'WAERS'.
    WHEN 'SONUM'.
      GS_FCAT-HOTSPOT = ABAP_TRUE.
  ENDCASE.

  APPEND GS_FCAT TO GT_FCAT.

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
  SET HANDLER : LCL_EVENT_HANDLER=>TOP_OF_PAGE  FOR GO_ALV,
                LCL_EVENT_HANDLER=>HOTSPOT_CLICK FOR GO_ALV.

  CALL METHOD GO_DYNDOC_ID->INITIALIZE_DOCUMENT
    EXPORTING
      BACKGROUND_COLOR = CL_DD_AREA=>COL_TEXTAREA.

  CALL METHOD GO_ALV->LIST_PROCESSING_EVENTS
    EXPORTING
      I_EVENT_NAME = 'TOP_OF_PAGE'
      I_DYNDOC_ID  = GO_DYNDOC_ID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_EXCEL_INVOICE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRINT_INVOICE .
  DATA : LT_ROID   TYPE LVC_T_ROID,
         LS_ROID   TYPE LVC_S_ROID,
         LV_LINE   TYPE I,
         LV_ANSWER.

*-- 송장 다운로드 컨펌 팝업
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TEXT_QUESTION         = '인보이스를 출력하시겠습니까?'
      TEXT_BUTTON_1         = '예'(001)
      TEXT_BUTTON_2         = '아니요'(002)
      DISPLAY_CANCEL_BUTTON = ' '
    IMPORTING
      ANSWER                = LV_ANSWER
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.

  IF LV_ANSWER NE '1'.
    EXIT.
  ENDIF.

**********************************************************************
* 선택 행 데이터 가져오기
**********************************************************************
*-- 선택행 정보를 가져온다.
  CALL METHOD GO_ALV->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_ROID.

*-- 선택행 없으면 오류메시지
  IF LT_ROID IS INITIAL.
    MESSAGE S001 WITH TEXT-E03 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 1건만 선택 가능하도록 체크
  LV_LINE = LINES( LT_ROID ).

  IF LV_LINE GT 1.
    MESSAGE S001 WITH TEXT-E04 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 선택행의 판매오더 헤더 정보 발췌
  LS_ROID = VALUE #( LT_ROID[ 1 ] OPTIONAL ).
  GS_HEADER = VALUE #( GT_HEADER[ LS_ROID-ROW_ID ] OPTIONAL ).

*-- 판매 오더 아이템 정보 발췌
  PERFORM GET_ITEM.

**********************************************************************
* Open file save window
**********************************************************************
*-- 파일 저장 경로 선택을 위한 OBJFILE 객체 생성
  IF OBJFILE IS INITIAL.
    TRY .
        CREATE OBJECT OBJFILE.
    ENDTRY.
  ENDIF.

*-- 초기 폴더 설정
  IF PFOLDER IS NOT INITIAL.
    INITIALFOLDER = PFOLDER.
  ELSE.
    " 임시 폴더 경로를 INITIALFOLDER에 설정
    OBJFILE->GET_TEMP_DIRECTORY( CHANGING TEMP_DIR = INITIALFOLDER
                                 EXCEPTIONS CNTL_ERROR = 1
                                           ERROR_NO_GUI = 2
                                           NOT_SUPPORTED_BY_GUI = 3 ).
  ENDIF.

*-- 폴더 선택 창 열기 : 사용자가 선택한 폴더는 PICKEDFOLDER에 저장됨
  OBJFILE->DIRECTORY_BROWSE( EXPORTING INITIAL_FOLDER = INITIALFOLDER
                             CHANGING SELECTED_FOLDER = PICKEDFOLDER
                             EXCEPTIONS CNTL_ERROR = 1
                                        ERROR_NO_GUI = 2
                                        NOT_SUPPORTED_BY_GUI = 3 ).

*-- 폴더가 선택되었는지 확인 및 해당 폴더 경로 PFOLDER에 저장
  IF SY-SUBRC = 0.
    PFOLDER = PICKEDFOLDER.
  ELSE.
    MESSAGE S001 WITH TEXT-E05 'I' DISPLAY LIKE 'W'.
    EXIT.
  ENDIF.

  IF PFOLDER IS INITIAL.
    EXIT.
  ENDIF.

*-- OBJFILE 객체 해제
  CALL METHOD OBJFILE->FREE.
  FREE OBJFILE.

*-- Excel 다운로드
  PERFORM DOWNLOAD_EXCEL.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUM_ID
*&---------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK  USING    PV_ROW_ID
                                    PV_COLUM_ID.

*-- 핫스팟 이벤트가 발생한 판매오더 헤더 정보 가져오기
  CLEAR : GS_HEADER.
  READ TABLE GT_HEADER INTO GS_HEADER INDEX PV_ROW_ID.

*-- 해당 판매오더에 대한 아이템 정보 가져오기
  CLEAR : GT_ITEM.
  SELECT SONUM POSNR A~MATNR MAKTX MENGE MEINS B~NETWR AS NETWR_MAT B~WAERS
    INTO CORRESPONDING FIELDS OF TABLE GT_ITEM
    FROM ZC302SDT0004 AS A
    LEFT OUTER JOIN ZC302MT0007 AS B
      ON A~MATNR = B~MATNR
    WHERE SONUM = GS_HEADER-SONUM.

  IF SY-SUBRC <> 0.
    MESSAGE I001 WITH TEXT-E06 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 아이템 정보 팝업창으로 디스플레이
  CALL SCREEN 200 STARTING AT 03 05.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_POPUP_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_POPUP_SCREEN .

  IF GO_CONT_POP IS NOT BOUND.
*-- 판매오더 아이템 ALV 필드 카탈로그 세팅
    CLEAR : GT_FCAT_POP.
    PERFORM SET_FCAT_POP USING : 'X' 'SONUM' '판매주문번호' 'C' ' ',
                                 'X' 'POSNR' '아이템번호' 'C' ' ',
                                 ' ' 'MATNR' '자재코드' 'C' ' ',
                                 ' ' 'MAKTX' '자재명' ' ' 'X',
                                 ' ' 'MENGE' '수량' ' ' ' ',
                                 ' ' 'MEINS' '단위' 'C' ' ',
                                 ' ' 'NETWR_MAT' '단가' ' ' ' ',
                                 ' ' 'WAERS' '통화' 'C' ' '.

    PERFORM CREATE_OBJECT_POP.

    CALL METHOD GO_ALV_POP->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        I_SAVE          = 'A'
        I_DEFAULT       = 'X'
        IS_LAYOUT       = GS_LAYOUT
      CHANGING
        IT_OUTTAB       = GT_ITEM
        IT_FIELDCATALOG = GT_FCAT_POP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT_POP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT_POP .
  CREATE OBJECT GO_CONT_POP
    EXPORTING
      CONTAINER_NAME = 'POP_CONT'.

  CREATE OBJECT GO_ALV_POP
    EXPORTING
      I_PARENT = GO_CONT_POP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT_POP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_FCAT_POP USING PV_KEY
                     PV_FIELD
                     PV_TEXT
                     PV_JUST
                     PV_EMP.

  CLEAR : GS_FCAT_POP.
  GS_FCAT_POP-KEY       = PV_KEY.
  GS_FCAT_POP-FIELDNAME = PV_FIELD.
  GS_FCAT_POP-COLTEXT   = PV_TEXT.
  GS_FCAT_POP-JUST      = PV_JUST.
  GS_FCAT_POP-EMPHASIZE = PV_EMP.

  CASE PV_FIELD.
    WHEN 'MENGE'.
      GS_FCAT_POP-QFIELDNAME = 'MEINS'.
    WHEN 'NETWR'.
      GS_FCAT_POP-CFIELDNAME = 'WAERS'.
    WHEN 'NETWR_MAT'.
      GS_FCAT_POP-CFIELDNAME = 'WAERS'.
  ENDCASE.

  APPEND GS_FCAT_POP TO GT_FCAT_POP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOWNLOAD_EXCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DOWNLOAD_EXCEL .

  DATA : LV_RC  TYPE I.

*-- 저장할 파일 이름 지정
  CLEAR GV_TEMP_FILENAME.
  CONCATENATE PFOLDER '\' GS_HEADER-SONUM '.XLS' " 파일명 Document#로 지정
              INTO GV_TEMP_FILENAME.

  GV_FORM = 'ZC314_INVOICE_FORM'.
  PERFORM DOWNLOAD_TEMPLATE   USING GV_FORM GV_TEMP_FILENAME.  " SNRO에 업로드한 템플릿 불러오기
  PERFORM OPEN_EXCEL_TEMPLATE USING GV_FORM.                   " Excel 객체 생성 및 속성 세팅
  PERFORM FILL_EXCEL_LINE.                                     " 템플릿에 데이터 채워넣기

*-- 기본적으로 Sheet 1을 보여주도록 셋팅
  CALL METHOD OF EXCEL 'SHEETS' = SHEET EXPORTING #1 = 1.
  CALL METHOD OF SHEET 'SELECT' NO FLUSH.

*-- 모두 출력후 맨윗칸으로 커서 이동
  CALL METHOD OF EXCEL 'Cells' = CELL
    EXPORTING
      #1 = 1
      #2 = 1.

  CALL METHOD OF CELL 'Select' .

  SET PROPERTY OF EXCEL 'VISIBLE' = 1 . "엑셀 데이타를 다 뿌리고나서 보여줌

*-- PDF로 변환
  IF GV_PDF = 'X'.
    PERFORM CONVERT_TO_PDF.
  ENDIF.

  MESSAGE S001 WITH TEXT-S01.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOWNLOAD_TEMPLATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_FORM
*&      --> GV_TEMP_FILENAME
*&---------------------------------------------------------------------*
FORM DOWNLOAD_TEMPLATE  USING P_ZFORM P_FILENAME.

  DATA : WWWDATA_ITEM LIKE WWWDATATAB,
         RC           TYPE I.

  GV_FILE = P_FILENAME.

  CALL FUNCTION 'WS_FILE_DELETE'
    EXPORTING
      FILE   = GV_FILE
    IMPORTING
      RETURN = RC.

  IF RC = 0 OR RC = 1.
  ELSE.
    MESSAGE E001  WITH TEXT-E07 TEXT-E08.
  ENDIF.

  SELECT SINGLE * FROM WWWDATA
    INTO CORRESPONDING FIELDS OF WWWDATA_ITEM
   WHERE OBJID = P_ZFORM.

  CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
    EXPORTING
      KEY         = WWWDATA_ITEM
      DESTINATION = GV_FILE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form OPEN_EXCEL_TEMPLATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_FORM
*&---------------------------------------------------------------------*
FORM OPEN_EXCEL_TEMPLATE  USING P_ZFORM.

*-- Excel 객체 생성
  IF EXCEL IS INITIAL.
    CREATE OBJECT EXCEL 'EXCEL.APPLICATION'.
  ENDIF.

*-- 객체 생성 확인
  IF SY-SUBRC NE 0.
    MESSAGE I001 WITH SY-MSGLI.
  ENDIF.

  CALL METHOD OF EXCEL 'WORKBOOKS' = WORKBOOK . " WORKBOOK 객체(Excel 파일을 열기 위한 객체) 가져옴
  SET PROPERTY OF EXCEL 'VISIBLE' = 0 .         " Excel 애플리케이션 창이 보이지 않도록 함(데이터 처리를 위한 코드가 실행되는 동안 Excel 창을 숨김)

*-- 생성한 Excel 파일 열기
  CALL METHOD OF WORKBOOK 'OPEN' EXPORTING #1 = GV_FILE. " Visible 설정과 관계없이 지정한 파일을 백그라운드에서 여는 역할

*-- Sheet에대한 설정을 할때 사용된다.
  GET PROPERTY OF : WORKBOOK    'Application' = APPLICATION,  " WORKBOOK 객체의 Application 속성을 가져옴
                    APPLICATION 'ActiveSheet' = ACTIVESHEET.  " APPLICATION 객체의 현재 활성화된 시트를 가져옴

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_EXCEL_LINE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FILL_EXCEL_LINE .

  DATA : LV_BELNR      TYPE BKPF-BELNR,
         LV_LINE       TYPE I,
         LV_AMOUNT(20),
         LV_DATE(10).

**********************************************************************
* Write Document header
**********************************************************************
*-- 판매오더번호
  CLEAR LV_DATE.
  PERFORM FILL_CELLS USING 5 2 GS_HEADER-SONUM.

*-- 주문자
  PERFORM FILL_CELLS USING 6 2 GS_HEADER-BPCODE.

*-- 주문일자
  PERFORM FILL_CELLS USING 7 2 GS_HEADER-PDATE.

*-- 총 금액
  WRITE GS_HEADER-NETWR CURRENCY GS_HEADER-WAERS TO LV_AMOUNT.
  PERFORM FILL_CELLS USING 5 7 LV_AMOUNT.

*-- 통화
  PERFORM FILL_CELLS USING 6 7 GS_HEADER-WAERS.

**********************************************************************
* Write Line item
**********************************************************************

  LV_LINE = 10.

  LOOP AT GT_ITEM INTO GS_ITEM.

    CLEAR : LV_AMOUNT.
    WRITE GS_ITEM-NETWR_MAT CURRENCY GS_ITEM-WAERS TO LV_AMOUNT.

    PERFORM FILL_CELLS USING LV_LINE  1 GS_ITEM-MATNR.  " 자재코드
    PERFORM FILL_CELLS USING LV_LINE  2 GS_ITEM-MAKTX. " 자재명
    PERFORM FILL_CELLS USING LV_LINE  5 GS_ITEM-MENGE.  " 수량
    PERFORM FILL_CELLS USING LV_LINE  6 GS_ITEM-MEINS.  " 단위
    PERFORM FILL_CELLS USING LV_LINE  7 LV_AMOUNT.      " 단가
    PERFORM FILL_CELLS USING LV_LINE  8 GS_ITEM-WAERS.  " 통화

    LV_LINE += 1.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_CELLS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_8
*&      --> P_3
*&      --> LV_DATE
*&---------------------------------------------------------------------*
FORM FILL_CELLS  USING I J VAL. " 입력할 행, 입력할 열, 입력할 값

  CALL METHOD OF EXCEL 'CELLS' = CELL
    EXPORTING
      #1 = I  " 행
      #2 = J. " 열

  SET PROPERTY OF CELL 'VALUE' = VAL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ITEM .

  CLEAR : GT_ITEM.
  SELECT A~SONUM A~POSNR A~MATNR B~MAKTX A~MENGE A~MEINS
         A~NETWR A~WAERS B~NETWR AS NETWR_MAT
    INTO CORRESPONDING FIELDS OF TABLE GT_ITEM
    FROM ZC302SDT0004 AS A
    LEFT OUTER JOIN ZC302MT0007 AS B
      ON A~MATNR = B~MATNR
    WHERE SONUM = GS_HEADER-SONUM.

  IF SY-SUBRC <> 0.
    MESSAGE S001 WITH TEXT-E06 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERT_TO_PDF
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CONVERT_TO_PDF .
  DATA LV_RC TYPE I.

*-- PDF 파일 이름 지정
  CLEAR GV_TEMP_FILENAME_PDF.
  CONCATENATE PFOLDER '\' GS_HEADER-SONUM '.PDF'
              INTO GV_TEMP_FILENAME_PDF.

*-- WORKBOOK 객체 가져오기
  GET PROPERTY OF EXCEL 'Workbooks' = WORKBOOK
    EXPORTING #1 = 1.

*-- PDF 형식으로 변환
  CALL METHOD OF WORKBOOK 'ExportAsFixedFormat'
    EXPORTING
      #1 = '0'  " 0 : PDF 형식
      #2 = GV_TEMP_FILENAME_PDF.

*-- WORKBOOK 닫기
  CALL METHOD OF WORKBOOK 'Close'
    EXPORTING
      #1 = 0.

*-- Excel 애플리케이션 종료
  CALL METHOD OF EXCEL 'Quit'.

*-- 기존 Excel 파일 삭제
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_DELETE
    EXPORTING
      FILENAME = CONV #( GV_TEMP_FILENAME )
    CHANGING
      RC       = LV_RC.
ENDFORM.
