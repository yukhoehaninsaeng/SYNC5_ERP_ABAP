*&---------------------------------------------------------------------*
*& Include          ZC302RPSD0003F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_SALES_PLAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SALES_PLAN .
  DATA : LV_LINE  TYPE I,
         LV_NUM   TYPE I,
         LV_TABIX TYPE SY-TABIX.

*-- 판매계획 헤더 리스트(GT_HEADER) 가져오기
  CLEAR : GT_HEADER, GS_HEADER, GT_ITEM, GS_ITEM.
  SELECT SPNUM SALE_ORG CHANNEL PYEAR PMONTH MENGE MEINS TOSAL WAERS STATUS
         DATUM ERDAT ERZET ERNAM AEDAT AEZET AENAM
    FROM ZC302SDT0001
    INTO CORRESPONDING FIELDS OF TABLE GT_HEADER
    WHERE SALE_ORG = P_SORG
      AND CHANNEL  IN S_CHNL
      AND PYEAR    IN S_PYEAR
      AND PMONTH   IN S_MONTH.

  " 판매계획번호 순으로 정렬
  SORT GT_HEADER BY SPNUM ASCENDING.

  " 불러온 판매계획 데이터가 없으면 에러메시지 디스플레이
  IF GT_HEADER IS INITIAL.
    MESSAGE S001 WITH TEXT-E08 DISPLAY LIKE 'E'.
    STOP.
  ELSE.
    LV_NUM = LINES( GT_HEADER ).
    MESSAGE S001 WITH LV_NUM TEXT-E09. " 불러온 판매계획 개수 디스플레이
  ENDIF.

*-- 첫번째 판매계획에 대한 아이템 리스트(GS_ITEM)를 Default로 가져옴
  READ TABLE GT_HEADER INTO GS_HEADER INDEX 1.
  GV_HINDEX = 1.

  SELECT SPNUM POSNR A~MATNR MAT~MAKTX MENGE MEINS A~NETWR A~WAERS
         A~ERDAT A~ERZET A~ERNAM A~AEDAT A~AEZET A~AENAM
    FROM ZC302SDT0002 AS A
      INNER JOIN ZC302MT0007 AS MAT
        ON A~MATNR = MAT~MATNR
    INTO CORRESPONDING FIELDS OF TABLE GT_ITEM
    WHERE SPNUM = GS_HEADER-SPNUM " 첫번째 판매계획번호에 대한 아이템
      AND DFLAG <> 'X'.           " 삭제 플래그가 없는 데이터

*-- 마지막 아이템 정보를 읽어옴(아이템 추가 시 SPNUM, POSNR 입력 위함)
  CLEAR : GV_SPNUM, GV_POSNR.

  LV_LINE = LINES( GT_ITEM ).
  READ TABLE GT_ITEM INTO GS_ITEM INDEX LV_LINE.

  " 데이터 추가 시 판매계획번호(SPNUM), 아이템번호(POSNR) 세팅
  GV_SPNUM = GS_ITEM-SPNUM.
  GV_POSNR = GS_ITEM-POSNR + 10.
  CLEAR : GS_ITEM.

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
    CLEAR : GS_LAYOUT, GT_FCAT_L, GT_FCAT_R.
    " Field Catalog 세팅(L - 판매계획 Header, R - 판매계획 Item)
    PERFORM SET_FCAT USING : 'L' 'X' 'SPNUM'    '판매계획번호'  'C' ' ',
                             'L' ' ' 'SALE_ORG' '영업조직'    'C' ' ',
                             'L' ' ' 'CHANNEL'  '유통채널'    'C' ' ',
                             'L' ' ' 'PYEAR'    '계획연도'    'C' 'X',
                             'L' ' ' 'PMONTH'   '계획월'     'C' 'X',
                             'L' ' ' 'MENGE'    '총계획수량'   ' ' ' ',
                             'L' ' ' 'MEINS'    '단위'       ' ' ' ',
                             'L' ' ' 'TOSAL'    '총판매금액'   ' ' ' ',
                             'L' ' ' 'WAERS'    '통화'      ' ' ' ',
                             'L' ' ' 'DATUM'    '생성일자'    ' ' ' ',
                             'R' 'X' 'SPNUM'    '판매계획번호'  'C' ' ',
                             'R' 'X' 'POSNR'    '아이템번호'   'C' ' ',
                             'R' 'X' 'MATNR'    '자재코드'    'C' ' ',
                             'R' ' ' 'MAKTX'    '자재명'     ' ' 'X',
                             'R' ' ' 'MENGE'    '수량'      ' ' ' ',
                             'R' ' ' 'MEINS'    '단위'      ' ' ' ',
                             'R' ' ' 'NETWR'    '금액'      ' ' ' ',
                             'R' ' ' 'WAERS'    '통화'      ' ' ' '.
*                             'R' ' ' 'MDFY_BTN' '수정'      'C' ' '.
    " ALV 레이아웃 세팅
    PERFORM SET_LAYOUT.

    " 인스턴스 생성
    PERFORM CREATE_OBJECT.

    " 이벤트 설치
    PERFORM INSTALL_EVENT.

    " Variant(변형) 속성 세팅
    LS_VARIANT-REPORT = SY-REPID.
    LS_VARIANT-HANDLE = 'ALV1'.

    " 판매계획 Header ALV에 데이터 붙이기
    CALL METHOD GO_ALV_L->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        I_SAVE          = 'A'
        I_DEFAULT       = 'X'
        IS_LAYOUT       = GS_LAYOUT
        IS_VARIANT      = LS_VARIANT
      CHANGING
        IT_OUTTAB       = GT_HEADER
        IT_FIELDCATALOG = GT_FCAT_L.

    " 판매계획 Item ALV에 데이터 붙이기
    LS_VARIANT-HANDLE = 'ALV2'.
    GS_LAYOUT_ITEM-GRID_TITLE = '판매계획 Item :　' && GS_HEADER-SPNUM.
    CALL METHOD GO_ALV_R->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        I_SAVE          = 'A'
        I_DEFAULT       = 'X'
        IS_LAYOUT       = GS_LAYOUT_ITEM
        IS_VARIANT      = LS_VARIANT
      CHANGING
        IT_OUTTAB       = GT_ITEM
        IT_FIELDCATALOG = GT_FCAT_R.
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
FORM SET_FCAT  USING PV_GUBUN
                     PV_KEY
                     PV_FIELD
                     PV_TEXT
                     PV_JUST
                     PV_EMP.


  DATA : LV_S_FCAT(9),
         LV_T_FCAT(9).

*-- 필드 심볼 선언
  FIELD-SYMBOLS : <FS_S_FCAT> LIKE GS_FCAT_L,
                  <FS_T_FCAT> LIKE GT_FCAT_L.

*-- 필드 심볼로 assign할 텍스트 세팅
  CONCATENATE 'GS_FCAT_' PV_GUBUN INTO LV_S_FCAT.
  CONCATENATE 'GT_FCAT_' PV_GUBUN INTO LV_T_FCAT.

*-- 필드 심볼 assign
  ASSIGN (LV_S_FCAT) TO <FS_S_FCAT>.
  ASSIGN (LV_T_FCAT) TO <FS_T_FCAT>.

*-- 필드 카탈로그 세팅
  IF <FS_S_FCAT> IS ASSIGNED.
    CLEAR : <FS_S_FCAT>.
    <FS_S_FCAT>-KEY = PV_KEY.
    <FS_S_FCAT>-FIELDNAME = PV_FIELD.
    <FS_S_FCAT>-COLTEXT = PV_TEXT.
    <FS_S_FCAT>-JUST = PV_JUST.
    <FS_S_FCAT>-EMPHASIZE = PV_EMP.

    " 참조 필드 및 핫스팟 속성 세팅
    CASE PV_FIELD.
      WHEN 'MENGE'.
        <FS_S_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'NETWR'.
        <FS_S_FCAT>-CFIELDNAME = 'WAERS'.
      WHEN 'TOSAL'.
        <FS_S_FCAT>-CFIELDNAME = 'WAERS'.
      WHEN 'SPNUM'.
        IF PV_GUBUN = 'L'.
          <FS_S_FCAT>-HOTSPOT = ABAP_TRUE.
        ENDIF.
    ENDCASE.

    APPEND <FS_S_FCAT> TO <FS_T_FCAT>.
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
      EXTENSION = 70.

*-- Main Container
  CREATE OBJECT GO_CONT
    EXPORTING
      CONTAINER_NAME = 'MAIN_CONT'.

*-- Splitter Container
  CREATE OBJECT GO_SPLIT
    EXPORTING
      PARENT  = GO_CONT
      ROWS    = 1
      COLUMNS = 2.

*-- Left Container
  CALL METHOD GO_SPLIT->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONT_L.

*-- Right Container
  CALL METHOD GO_SPLIT->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 2
    RECEIVING
      CONTAINER = GO_CONT_R.

*-- Left ALV Grid
  CREATE OBJECT GO_ALV_L
    EXPORTING
      I_PARENT = GO_CONT_L.

*-- Right ALV Grid
  CREATE OBJECT GO_ALV_R
    EXPORTING
      I_PARENT = GO_CONT_R.

*-- Top-of-page : Create TOP-Document
  CREATE OBJECT GO_DYNDOC_ID
    EXPORTING
      STYLE = 'ALV_GRID'.
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
  GS_LAYOUT-GRID_TITLE = '판매계획 Header'.
  GS_LAYOUT-SMALLTITLE = ABAP_TRUE.

  GS_LAYOUT_ITEM-ZEBRA      = ABAP_TRUE.
  GS_LAYOUT_ITEM-CWIDTH_OPT = 'A'.
  GS_LAYOUT_ITEM-SEL_MODE   = 'D'.
  GS_LAYOUT_ITEM-SMALLTITLE = ABAP_TRUE.
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
*-- 영업조직 Default값 세팅
  P_SORG = '0001'.

*-- 자재코드 Search Help(F4) 데이터
  CLEAR : GS_MAT, GT_MAT.
  SELECT MATNR MAKTX NETWR AS NETWR WAERS
    INTO CORRESPONDING FIELDS OF TABLE GT_MAT
    FROM ZC302MT0007
    WHERE MTART = '03'.

  IF SY-SUBRC <> 0.
    MESSAGE S001 WITH TEXT-E01 DISPLAY LIKE 'E'.
    EXIT.
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
      WHEN 'ORG'. " 영업조직 필드 입력 비활성화
        SCREEN-INPUT = 0.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&---------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK  USING PV_ROW_ID
                                 PV_COLUMN_ID.

  DATA : LV_ANSWER,
         LV_LINE   TYPE I,
         LV_TABIX  TYPE SY-TABIX.

  DATA : LS_VARIANT TYPE DISVARIANT,
         LS_ITEM    LIKE GS_ITEM.

*-- 이전에 선택한 판매계획에서 수정 사항이 있는 경우, 수정 사항 저장 컨펌 팝업 디스플레이
  IF ( GS_ITEM IS NOT INITIAL ) OR ( GT_DELT IS NOT INITIAL ).
    PERFORM CONFIRM_POPUP USING '수정 사항을 저장하시겠습니까?' CHANGING LV_ANSWER.

    IF LV_ANSWER = '1'.
      PERFORM SAVE_ITEM.
    ENDIF.
    CLEAR : GS_ITEM, GT_DELT.
  ENDIF.

*-- 핫스팟 클릭 이벤트 발생 시 로직
  " 이벤트가 발생한 판매계획 Header 정보를 읽어옴
  CLEAR : GS_HEADER.
  READ TABLE GT_HEADER INTO GS_HEADER INDEX PV_ROW_ID.
  GV_HINDEX = PV_ROW_ID.

  " 이벤트가 발생한 판매계획에 대한 Item 정보를 읽어옴
  CLEAR : GT_ITEM.
  SELECT SPNUM POSNR A~MATNR MAT~MAKTX MENGE MEINS A~NETWR A~WAERS
         A~ERDAT A~ERZET A~ERNAM A~AEDAT A~AEZET A~AENAM
    FROM ZC302SDT0002 AS A
      INNER JOIN ZC302MT0007 AS MAT
        ON A~MATNR = MAT~MATNR
    INTO CORRESPONDING FIELDS OF TABLE GT_ITEM
    WHERE SPNUM = GS_HEADER-SPNUM
      AND DFLAG <> 'X'.

  " 아이템 정보를 읽어오지 못하면 에러 메시지 디스플레이
  IF SY-SUBRC <> 0.
    MESSAGE S001 WITH TEXT-E02 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  " 마지막 아이템 정보를 읽어옴(아이템 추가 시 SPNUM, POSNR 입력 위함)
  CLEAR : LS_ITEM, GV_SPNUM, GV_POSNR.
  LV_LINE = LINES( GT_ITEM ).
  READ TABLE GT_ITEM INTO LS_ITEM INDEX LV_LINE.

  GV_SPNUM = LS_ITEM-SPNUM.
  GV_POSNR = LS_ITEM-POSNR + 10.

  " 판매계획 Item에 대한 ALV title 변경
  GS_LAYOUT_ITEM-GRID_TITLE = '판매계획 Item :　' && GS_HEADER-SPNUM.

  LS_VARIANT-REPORT = SY-REPID.
  LS_VARIANT-HANDLE = 'ALV2'.

  CALL METHOD GO_ALV_R->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      I_SAVE          = 'A'
      I_DEFAULT       = 'X'
      IS_LAYOUT       = GS_LAYOUT_ITEM
      IS_VARIANT      = LS_VARIANT
    CHANGING
      IT_OUTTAB       = GT_ITEM
      IT_FIELDCATALOG = GT_FCAT_R.

  CALL METHOD GO_ALV_R->REFRESH_TABLE_DISPLAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INSTALL_EVENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INSTALL_EVENT .
  SET HANDLER : LCL_EVENT_HANDLER=>HOTSPOT_CLICK FOR GO_ALV_L,
                LCL_EVENT_HANDLER=>DOUBLE_CLICK FOR GO_ALV_R,
                LCL_EVENT_HANDLER=>TOOLBAR FOR GO_ALV_R,
                LCL_EVENT_HANDLER=>USER_COMMAND FOR GO_ALV_R,
                LCL_EVENT_HANDLER=>TOP_OF_PAGE  FOR GO_ALV_L.

  CALL METHOD GO_DYNDOC_ID->INITIALIZE_DOCUMENT
    EXPORTING
      BACKGROUND_COLOR = CL_DD_AREA=>COL_TEXTAREA.

  CALL METHOD GO_ALV_L->LIST_PROCESSING_EVENTS
    EXPORTING
      I_EVENT_NAME = 'TOP_OF_PAGE'
      I_DYNDOC_ID  = GO_DYNDOC_ID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM HANDLE_TOOLBAR  USING PO_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                           PO_INTERACTIVE.
  CLEAR : GS_BUTTON.

*-- 생산 계획이 생성된 판매 계획인 경우 수정이 불가능하도록 함
  IF GS_HEADER-STATUS <> 'X'.
    PERFORM SET_BUTTON USING : ''     ''               ''           3  ' '      CHANGING PO_OBJECT,
                               'IROW' ICON_INSERT_ROW  'Insert row' '' TEXT-T02 CHANGING PO_OBJECT,
                               'DROW' ICON_DELETE_ROW  'Delete row' '' TEXT-T03 CHANGING PO_OBJECT,
                               ''     ''               ''           3  ' '      CHANGING PO_OBJECT,
                               'SAVE' ICON_SYSTEM_SAVE 'Save items' '' TEXT-T04 CHANGING PO_OBJECT.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BUTTON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_3
*&      --> P_
*&      <-- PO_OBJECT
*&---------------------------------------------------------------------*
FORM SET_BUTTON  USING PV_OKCODE
                       PV_ICON
                       PV_INFO
                       PV_BTN
                       PV_TEXT
                 CHANGING PO_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.

  CLEAR : GS_BUTTON.
  GS_BUTTON-FUNCTION    = PV_OKCODE.
  GS_BUTTON-ICON        = PV_ICON.
  GS_BUTTON-QUICKINFO   = PV_INFO.
  GS_BUTTON-BUTN_TYPE   = PV_BTN.
  GS_BUTTON-TEXT        = PV_TEXT.

  APPEND GS_BUTTON TO PO_OBJECT->MT_TOOLBAR.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_USER_COMMAND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM HANDLE_USER_COMMAND USING PV_UCOMM.
  CASE PV_UCOMM.
    WHEN 'IROW'.  " 아이템 추가
      PERFORM INSERT_ITEM.
    WHEN 'DROW'.  " 아이템 삭제
      PERFORM DELETE_ITEM.
    WHEN 'SAVE'.  " 저장
      PERFORM SAVE_ITEM.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form INSERT_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INSERT_ITEM .
  CLEAR : GV_MATNR, GV_MAKTX, GV_MENGE, GV_MEINS, GV_NETWR, GV_WAERS.

*-- 추가 모드로 팝업창 열기
  GV_MODE = 'C'.
  CALL SCREEN 101 STARTING AT 60 05.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DELETE_ITEM .
  DATA : LS_ROW TYPE LVC_S_ROW,
         LT_ROW TYPE LVC_T_ROW.

  DATA : LV_ANSWER.

*-- 삭제 컨펌 팝업
  PERFORM CONFIRM_POPUP USING '해당 아이템을 삭제하시겠습니까?' CHANGING LV_ANSWER.
  IF LV_ANSWER <> '1'.
    EXIT.
  ENDIF.

*-- 선택된 행의 인덱스 정보를 가져옴
  CALL METHOD GO_ALV_R->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

*-- 선택된 행이 없는 경우 에러 메시지 디스플레이
  IF LT_ROW IS INITIAL.
    MESSAGE S001 WITH TEXT-E03 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 삭제 플래그 표시 및 백업 & itab에서 해당 행 삭제
  SORT LT_ROW BY INDEX DESCENDING.

  LOOP AT LT_ROW INTO LS_ROW.
    " 삭제 데이터에 삭제 플래그 & Timestamp 표시하여 백업
    READ TABLE GT_ITEM INTO GS_DELT INDEX LS_ROW-INDEX.
    GS_DELT-DFLAG = 'X'.
    GS_DELT-AEDAT = SY-DATUM.
    GS_DELT-AEZET = SY-UZEIT.
    GS_DELT-AENAM = SY-UNAME.
    APPEND GS_DELT TO GT_DELT.

    " ITAB에서 해당 행 삭제
    DELETE GT_ITEM INDEX LS_ROW-INDEX.
  ENDLOOP.

*-- ITAB & ALV 동기화
  CALL METHOD GO_ALV_R->REFRESH_TABLE_DISPLAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ADD_ITEM .
*-- 입력이 모두 이루어진 경우에만 아이템 생성 진행
  IF GV_MATNR IS INITIAL OR GV_MENGE IS INITIAL OR GV_MEINS IS INITIAL.
    MESSAGE S001 WITH TEXT-E04 DISPLAY LIKE 'E'.
  ELSE.
    CLEAR : GS_ITEM.
    GS_ITEM-SPNUM = GV_SPNUM.
    GS_ITEM-POSNR = GV_POSNR.
    GV_POSNR = GV_POSNR + 10.
    GS_ITEM-MATNR = GV_MATNR.
    GS_ITEM-MAKTX = GV_MAKTX.
    GS_ITEM-MENGE = GV_MENGE.
    GS_ITEM-MEINS = GV_MEINS.
    GS_ITEM-NETWR = GS_MAT-NETWR * GV_MENGE.
    GS_ITEM-WAERS = GS_MAT-WAERS.
    GS_ITEM-ERDAT = SY-DATUM.
    GS_ITEM-ERZET = SY-UZEIT.
    GS_ITEM-ERNAM = SY-UNAME.
    APPEND GS_ITEM TO GT_ITEM.

    CALL METHOD GO_ALV_R->REFRESH_TABLE_DISPLAY.

    LEAVE TO SCREEN 0.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_ITEM .

*-- 자재 단가 정보 가져옴
  CLEAR : GS_MAT.
  READ TABLE GT_MAT INTO GS_MAT WITH KEY MATNR = GV_MATNR.

*-- 수정된 데이터 ITAB에 저장
  GS_ITEM-MATNR = GV_MATNR.
  GS_ITEM-MAKTX = GV_MAKTX.
  GS_ITEM-MENGE = GV_MENGE.
  GS_ITEM-MEINS = GV_MEINS.
  GS_ITEM-NETWR = GS_MAT-NETWR * GV_MENGE.
  GS_ITEM-WAERS = GS_MAT-WAERS.
  GS_ITEM-AEDAT = SY-DATUM.
  GS_ITEM-AEZET = SY-UZEIT.
  GS_ITEM-AENAM = SY-UNAME.

  MODIFY GT_ITEM FROM GS_ITEM INDEX GV_ITEM_INDEX TRANSPORTING MATNR MAKTX MENGE MEINS NETWR WAERS
                                                              AEDAT AEZET AENAM.

  CALL METHOD GO_ALV_R->REFRESH_TABLE_DISPLAY.

  LEAVE TO SCREEN 0.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM HANDLE_DOUBLE_CLICK  USING    PV_ROW
                                   PV_COLUMN.

*-- 생산 계획이 생성된 판매 계획인 경우 수정이 불가능하도록 함
  IF GS_HEADER-STATUS <> 'X'.
    CLEAR : GS_ITEM.

    " 아이템 데이터 행 인덱스 저장
    GV_ITEM_INDEX = PV_ROW.

    " 해당 행의 데이터 읽어옴
    READ TABLE GT_ITEM INTO GS_ITEM INDEX PV_ROW.

    " 아이템을 읽어오지 못하면 에러 메시지 디스플레이
    IF GS_ITEM IS INITIAL.
      MESSAGE S001 WITH TEXT-E02 DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.

    " 자재코드, 자재명, 수량, 단위 데이터 세팅
    GV_MATNR = GS_ITEM-MATNR.
    GV_MAKTX = GS_ITEM-MAKTX.
    GV_MENGE = GS_ITEM-MENGE.
    GV_MEINS = GS_ITEM-MEINS.

    " 수정 모드로 팝업 띄우기
    GV_MODE = 'M'.
    CALL SCREEN 101 STARTING AT 60 05.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_ITEM .
  DATA : LV_ANSWER,
         LT_SAVE   TYPE TABLE OF ZC302SDT0002,
         LS_SAVE   TYPE ZC302SDT0002,
         LV_TABIX  TYPE SY-TABIX.

  DATA : LV_MENGE TYPE ZC302SDT0001-MENGE VALUE 0,
         LV_TOSAL TYPE ZC302SDT0001-TOSAL VALUE 0.

*-- 저장 컨펌 팝업
  PERFORM CONFIRM_POPUP USING '아이템 변경 사항을 저장하시겠습니까?' CHANGING LV_ANSWER.
  IF LV_ANSWER <> '1'.
    EXIT.
  ENDIF.

**********************************************************************
* 판매 계획 Item 업데이트
**********************************************************************
*-- 저장 대상 데이터 테이블 레이아웃에 맞게 옮김
  MOVE-CORRESPONDING GT_ITEM TO LT_SAVE.

*-- 수정 사항이 없는 경우 에러 메시지 디스플레이
  IF ( LT_SAVE IS INITIAL ) AND ( GT_DELT IS INITIAL ).
    MESSAGE S001 WITH TEXT-E05 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 수정 내용(추가 또는 수정) DB에 반영
  MODIFY ZC302SDT0002 FROM TABLE LT_SAVE.

*-- 수정 내용(삭제) DB에 반영(삭제 플래그 표시)
  MODIFY ZC302SDT0002 FROM TABLE GT_DELT.


*-- DB 변경 결과에 대한 메시지 디스플레이
  IF SY-SUBRC = 0.
    MESSAGE S001 WITH TEXT-S01.

    CALL METHOD GO_ALV_R->REFRESH_TABLE_DISPLAY.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE S001 WITH '판매계획 아이템 ' TEXT-E06 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

**********************************************************************
* 판매 계획 Header 업데이트
**********************************************************************
*-- 판매계획 Header 업데이트(총 계획 수량, 총 판매 가격)
  LOOP AT GT_ITEM INTO GS_ITEM.
    LV_MENGE = LV_MENGE + GS_ITEM-MENGE.
    LV_TOSAL = LV_TOSAL + GS_ITEM-NETWR.
  ENDLOOP.

  " Timestamp
  GS_HEADER-MENGE = LV_MENGE.
  GS_HEADER-TOSAL = LV_TOSAL.
  GS_HEADER-AEDAT = SY-DATUM.
  GS_HEADER-AEZET = SY-UZEIT.
  GS_HEADER-AENAM = SY-UNAME.

  MODIFY GT_HEADER FROM GS_HEADER INDEX GV_HINDEX TRANSPORTING MENGE TOSAL.
  MODIFY ZC302SDT0001 FROM GS_HEADER.

  IF SY-SUBRC <> 0.
    MESSAGE S001 WITH '판매계획 헤더 ' TEXT-E06 DISPLAY LIKE 'E'.
    EXIT.
  ELSE.
    MESSAGE S001 WITH TEXT-S01.
  ENDIF.

  CLEAR : GS_ITEM, GT_DELT.

  CALL METHOD GO_ALV_L->REFRESH_TABLE_DISPLAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_material_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_MATERIAL_F4 .

  DATA : BEGIN OF LS_MAT_F4,
           MATNR TYPE ZC302MT0007-MATNR,
           MAKTX TYPE ZC302MT0007-MAKTX,
         END OF LS_MAT_F4,
         LT_MAT_F4 LIKE TABLE OF LS_MAT_F4.

  DATA : LT_RETURN TYPE TABLE OF DDSHRETVAL WITH HEADER LINE,
         LT_READ   TYPE TABLE OF DYNPREAD WITH HEADER LINE.

*-- Get Material Info for Search Help(F4)
  MOVE-CORRESPONDING GT_MAT TO LT_MAT_F4.

*-- Execute F4 Help
  REFRESH LT_RETURN.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'MATNR'
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'GV_MATNR'
      WINDOW_TITLE    = 'Material code'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_MAT_F4
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

*-- Get description
  LT_RETURN = VALUE #( LT_RETURN[ 1 ] OPTIONAL ).

  CLEAR : GS_MAT.
  READ TABLE GT_MAT INTO GS_MAT WITH KEY MATNR = LT_RETURN-FIELDVAL.
  GV_MAKTX = GS_MAT-MAKTX.

*-- Set value to Dynpro
  REFRESH LT_READ.
  LT_READ-FIELDNAME = 'GV_MATNR'.
  LT_READ-FIELDVALUE = LT_RETURN-FIELDVAL.
  APPEND LT_READ.
  LT_READ-FIELDNAME = 'GV_MAKTX'.
  LT_READ-FIELDVALUE = GS_MAT-MAKTX.
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

*-- 영업조직 & 유통채널
  PERFORM ADD_ROW USING LR_DD_TABLE COL_FIELD COL_VALUE '영업조직' P_SORG.

  S_CHNL = VALUE #( S_CHNL[ 1 ] OPTIONAL ).
  CLEAR : LV_TEMP.
  IF S_CHNL-LOW IS NOT INITIAL.
    LV_TEMP = S_CHNL-LOW.
    IF S_CHNL-HIGH IS NOT INITIAL.
      CONCATENATE LV_TEMP ' ~ ' S_CHNL-HIGH INTO LV_TEMP.
    ENDIF.
  ELSE.
    LV_TEMP = '전체'.
  ENDIF.
  PERFORM ADD_ROW USING LR_DD_TABLE COL_FIELD COL_VALUE '유통채널' LV_TEMP.

*-- 계획연도 & 계획월
  S_PYEAR = VALUE #( S_PYEAR[ 1 ] OPTIONAL ).
  CLEAR : LV_TEMP.
  IF S_PYEAR-LOW IS NOT INITIAL.
    LV_TEMP = S_PYEAR-LOW && '년'.
    IF S_PYEAR-HIGH IS NOT INITIAL.
      CONCATENATE LV_TEMP ' ~ ' S_PYEAR-HIGH '년' INTO LV_TEMP.
    ENDIF.
  ELSE.
    LV_TEMP = '전체'.
  ENDIF.
  PERFORM ADD_ROW USING LR_DD_TABLE COL_FIELD COL_VALUE '계획연도' LV_TEMP.

  S_MONTH = VALUE #( S_MONTH[ 1 ] OPTIONAL ).
  CLEAR : LV_TEMP.
  IF S_MONTH-LOW IS NOT INITIAL.
    LV_TEMP = S_MONTH-LOW && '월'.
    IF S_MONTH-HIGH IS NOT INITIAL.
      CONCATENATE LV_TEMP ' ~ ' S_MONTH-HIGH '월' INTO LV_TEMP.
    ENDIF.
  ELSE.
    LV_TEMP = '전체'.
  ENDIF.
  PERFORM ADD_ROW USING LR_DD_TABLE COL_FIELD COL_VALUE '계획월'  LV_TEMP.

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
*&      --> LV_TEXT
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
    MESSAGE S001 WITH TEXT-E07 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONFIRM_SAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM CONFIRM_POPUP  USING PV_TEXT CHANGING PV_ANSWER.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = 'Confirm Popup'
      TEXT_QUESTION         = PV_TEXT
      TEXT_BUTTON_1         = '예'(001)
      ICON_BUTTON_1         = 'ICON_OKAY'
      TEXT_BUTTON_2         = '아니오'(002)
      ICON_BUTTON_2         = 'ICON_CANCEL'
      DEFAULT_BUTTON        = '1'
      DISPLAY_CANCEL_BUTTON = ' '
    IMPORTING
      ANSWER                = PV_ANSWER.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_SCREEN .

*-- 단위 필드에 Default값 세팅
  GV_MEINS = 'EA'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_BUTTON_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ES_COL_ID
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM HANDLE_BUTTON_CLICK  USING PS_COL_ID TYPE LVC_S_COL
                                PS_ROW_NO TYPE LVC_S_ROID.

*-- 생산 계획이 생성된 판매 계획인 경우 수정이 불가능하도록 함
  IF GS_HEADER-STATUS <> 'X'.
    CLEAR : GS_ITEM.

    " 아이템 데이터 행 인덱스 저장
    GV_ITEM_INDEX = PS_ROW_NO-ROW_ID.

    " 해당 행의 데이터 읽어옴
    READ TABLE GT_ITEM INTO GS_ITEM INDEX GV_ITEM_INDEX.

    " 아이템을 읽어오지 못하면 에러 메시지 디스플레이
    IF GS_ITEM IS INITIAL.
      MESSAGE S001 WITH TEXT-E02 DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.

    " 자재코드, 자재명, 수량, 단위 데이터 세팅
    GV_MATNR = GS_ITEM-MATNR.
    GV_MAKTX = GS_ITEM-MAKTX.
    GV_MENGE = GS_ITEM-MENGE.
    GV_MEINS = GS_ITEM-MEINS.

    " 수정 모드로 팝업 띄우기
    GV_MODE = 'M'.
    CALL SCREEN 101 STARTING AT 60 05.
  ENDIF.

ENDFORM.
