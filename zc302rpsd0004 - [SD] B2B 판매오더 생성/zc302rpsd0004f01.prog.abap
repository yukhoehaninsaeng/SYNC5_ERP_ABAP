*&---------------------------------------------------------------------*
*& Include          ZC302RPSD0004F01
*&---------------------------------------------------------------------*
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
    CASE 'X'.
      WHEN P_RB1.
        IF SCREEN-GROUP1 = 'PAT'.
          SCREEN-ACTIVE = 0.
        ELSEIF SCREEN-GROUP1 = 'NUM'.
          SCREEN-ACTIVE = 1.
        ENDIF.
      WHEN P_RB2.
        IF SCREEN-GROUP1 = 'PAT'.
          SCREEN-ACTIVE = 1.
        ELSEIF SCREEN-GROUP1 = 'NUM'.
          SCREEN-ACTIVE = 0.
        ENDIF.
    ENDCASE.
    CASE SCREEN-GROUP1.
      WHEN 'ORG'.
        SCREEN-INPUT = 0.
    ENDCASE.

    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BUTTON_CONTROL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BUTTON_CONTROL .
  CASE SSCRFIELDS-UCOMM.
    WHEN 'FC01'.
      PERFORM TEMPLATE_DOWNLOAD.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_FILEPATH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_FILEPATH .
  DATA : LT_FILES  TYPE FILETABLE,
         LS_FILES  LIKE LINE OF LT_FILES,
         LV_FILTER TYPE STRING,
         LV_PATH   TYPE STRING,
         LV_RC     TYPE I.

  " 확장자가 .xlsx인 파일만 필터링
  CONCATENATE CL_GUI_FRONTEND_SERVICES=>FILETYPE_EXCEL
              'Excel 통합 문서(*.XLSX)|*.XLSX|'
              INTO LV_FILTER.

  " 파일 경로 가져오기
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      WINDOW_TITLE            = 'File open'
      FILE_FILTER             = LV_FILTER
      INITIAL_DIRECTORY       = LV_PATH
    CHANGING
      FILE_TABLE              = LT_FILES
      RC                      = LV_RC
    EXCEPTIONS
      FILE_OPEN_DIALOG_FAILED = 1
      CNTL_ERROR              = 2
      ERROR_NO_GUI            = 3
      NOT_SUPPORTED_BY_GUI    = 4
      OTHERS                  = 5.

  CHECK SY-SUBRC EQ 0.
  LS_FILES = VALUE #( LT_FILES[ 1 ] OPTIONAL ).

  " 파일 경로명 Selection Screen에 세팅
  CLEAR P_PATH.
  P_PATH = LS_FILES-FILENAME.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form TEMPLATE_DOWNLOAD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM TEMPLATE_DOWNLOAD .
**********************************************************************
* Create excel upload application form
**********************************************************************
  DATA : LV_FILENAME LIKE RLGRAP-FILENAME,
         LV_MSG(100).

*-- Call windows browser : 다운로드 위치에 대한 경로명 생성
  CLEAR W_PFOLDER.
  PERFORM GET_BROWSER_INFO.

  IF W_PFOLDER IS INITIAL.
    EXIT.
  ENDIF.

  CLEAR LV_FILENAME.
  CONCATENATE W_PFOLDER '\' 'SO_Template' '.XLS' INTO LV_FILENAME. " 다운로드 파일명 세팅해줌

  PERFORM DOWNLOAD_TEMPLATE USING LV_FILENAME. " 템플릿 다운로드

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_BPCODE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4_BPCODE .

  DATA : LT_RETURN LIKE TABLE OF DDSHRETVAL WITH HEADER LINE.

  REFRESH : LT_RETURN.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'BPCODE'
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'P_BP'
      WINDOW_TITLE    = 'BP Code'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = GT_BPCODE
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

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
  CLEAR : GT_BPCODE.

  " Search Help(F4) 를 위한 BP Data 가져오기
  SELECT BPCODE CNAME
    INTO CORRESPONDING FIELDS OF TABLE GT_BPCODE
    FROM ZC302MT0001
    WHERE BPTYPE = 'VD'. " 거래처 구분 : 납품처

  IF GT_BPCODE IS INITIAL.
    MESSAGE S001 WITH TEXT-E18 DISPLAY LIKE 'E'.
  ENDIF.

  " 유통 채널 Search Help(F4) 데이터
  GT_CHNL = VALUE #( ( CHNL = 'DS' CTEXT = '국내유통' )
                     ( CHNL = 'AS' CTEXT = '해외유통' )
                   ).

  " 주문일자 Default값 : 현재 날짜
  P_PDAT = SY-DATUM.

  " Selection Screen의 Application toolbar Button 속성 세팅
  MOVE : 'TEMPLATE'           TO W_FUNCTXT-QUICKINFO,
          ICON_XLS            TO W_FUNCTXT-ICON_ID,
          '템플릿 다운로드'      TO W_FUNCTXT-ICON_TEXT,
          W_FUNCTXT           TO SSCRFIELDS-FUNCTXT_01.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCEL_UPLOAD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCEL_UPLOAD .
  TYPES: TRUXS_T_TEXT_DATA(4096)   TYPE C OCCURS 0.

  DATA: LT_RAW_DATA  TYPE TRUXS_T_TEXT_DATA,
        LT_EXCEL     LIKE TABLE OF ALSMEX_TABLINE WITH HEADER LINE,
        LV_INDEX     LIKE SY-TABIX,
        LV_WAERS     TYPE BKPF-WAERS,
        LV_DMBTR(20).

  FIELD-SYMBOLS:  <FIELD>.

*-- 파일 경로가 없는 경우 에러 메시지 디스플레이
  IF P_PATH IS INITIAL.
    MESSAGE S001 WITH TEXT-E01 DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  CLEAR : GT_EXCEL, GS_EXCEL, LV_INDEX.

*-- Excel 파일 데이터 변환하여 읽어오기
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      FILENAME                = P_PATH
      I_BEGIN_COL             = 1
      I_BEGIN_ROW             = 2
      I_END_COL               = 100
      I_END_ROW               = 50000
    TABLES
      INTERN                  = LT_EXCEL
    EXCEPTIONS
      INCONSISTENT_PARAMETERS = 1
      UPLOAD_OLE              = 2
      OTHERS                  = 3.

  IF SY-SUBRC = 1.
    MESSAGE S001 WITH TEXT-E02 DISPLAY LIKE 'E'.
    STOP.
  ELSEIF SY-SUBRC <> 0.
    MESSAGE S001 WITH TEXT-E03 DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  CHECK NOT ( LT_EXCEL[] IS INITIAL ).

  SORT LT_EXCEL BY ROW COL.

*-- 한 줄씩 ITAB에 append
  LOOP AT LT_EXCEL.

    LV_INDEX = LT_EXCEL-COL.
    ASSIGN COMPONENT LV_INDEX OF STRUCTURE GS_EXCEL TO <FIELD>.
    <FIELD> = LT_EXCEL-VALUE.

    AT END OF ROW.
      " 입력 조건에 맞는 데이터만 필터링
      IF ( GS_EXCEL-BPCODE = P_BP )
          AND ( GS_EXCEL-SORG = P_SORG )
          AND ( GS_EXCEL-PDATE = P_PDAT )
          AND ( GS_EXCEL-CHNL = P_CHNL ).
        APPEND GS_EXCEL TO GT_EXCEL.
        CLEAR GS_EXCEL.
      ENDIF.
    ENDAT.

  ENDLOOP.

*-- 불러온 데이터가 없으면 에러메시지 디스플레이
  IF GT_EXCEL IS INITIAL.
    MESSAGE S001 WITH TEXT-E04 DISPLAY LIKE 'E'.
    STOP.
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
  DATA : LV_S_FCAT(30),
         LV_T_FCAT(30).

  FIELD-SYMBOLS : <FS_FCAT> TYPE LVC_S_FCAT,
                  <FT_FCAT> TYPE LVC_T_FCAT.

  CONCATENATE : 'GS_FCAT_' PV_GUBUN INTO LV_S_FCAT,
                'GT_FCAT_' PV_GUBUN INTO LV_T_FCAT.

  ASSIGN : (LV_S_FCAT) TO <FS_FCAT>,
           (LV_T_FCAT) TO <FT_FCAT>.

  CLEAR : <FS_FCAT>.
  IF ( <FS_FCAT> IS ASSIGNED ) AND ( <FT_FCAT> IS ASSIGNED ).
    <FS_FCAT>-KEY       = PV_KEY.
    <FS_FCAT>-FIELDNAME = PV_FIELD.
    <FS_FCAT>-COLTEXT   = PV_TEXT.
    <FS_FCAT>-JUST      = PV_JUST.
    <FS_FCAT>-EMPHASIZE = PV_EMP.

    CASE PV_FIELD.
      WHEN 'BTN'.
        <FS_FCAT>-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_BUTTON.
      WHEN 'MATNR'.
        <FS_FCAT>-F4AVAILABL = ABAP_TRUE.
      WHEN 'MENGE'.
        <FS_FCAT>-QFIELDNAME = 'MEINS'.
        <FS_FCAT>-REF_TABLE = 'ZC302SDT0004'.
      WHEN 'NETWR'.
        <FS_FCAT>-CFIELDNAME = 'WAERS'.
        <FS_FCAT>-REF_TABLE = 'ZC302SDT0004'.
      WHEN 'SONUM'.
        IF PV_GUBUN = 'PRE_T'.
          <FS_FCAT>-HOTSPOT = ABAP_TRUE.
        ENDIF.
      WHEN 'BTN'.
        <FS_FCAT>-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_BUTTON.
    ENDCASE.
    APPEND <FS_FCAT> TO <FT_FCAT>.
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
FORM CREATE_OBJECT USING PO_CONT TYPE REF TO CL_GUI_CUSTOM_CONTAINER
                         PO_ALV  TYPE REF TO CL_GUI_ALV_GRID
                         PV_CONT_NAME.

*-- 팝업 스크린을 제외한 스크린에서 Top-of-page 디스플레이
  IF SY-DYNNR <> '0101'.
    CREATE OBJECT GO_TOP_CONTAINER
      EXPORTING
        REPID     = SY-CPROG
        DYNNR     = SY-DYNNR
        SIDE      = GO_TOP_CONTAINER->DOCK_AT_TOP
        EXTENSION = 70. " Top of page 높이
  ENDIF.

*-- Container 오브젝트 생성
  CREATE OBJECT PO_CONT
    EXPORTING
      CONTAINER_NAME = PV_CONT_NAME.

*-- ALV Grid 오브젝트 생성
  CREATE OBJECT PO_ALV
    EXPORTING
      I_PARENT = PO_CONT.

*-- Top-of-page 관련
  IF SY-DYNNR <> '0101'.
    CREATE OBJECT GO_DYNDOC_ID
      EXPORTING
        STYLE = 'ALV_GRID'.
  ENDIF.

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
  CLEAR : GS_LAYOUT.

  GS_LAYOUT-ZEBRA      = ABAP_TRUE.
  GS_LAYOUT-CWIDTH_OPT = 'A'.
  GS_LAYOUT-SEL_MODE   = 'D'.
  GS_LAYOUT-STYLEFNAME = 'CELLTAB'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM HANDLE_TOOLBAR  USING    PO_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                              PO_INTERACTIVE.

  PERFORM SET_BUTTON USING : ' '    ' '             ' '        3  ' '   CHANGING PO_OBJECT,
                             'IADD' ICON_INSERT_ROW '아이템 추가' ' ' TEXT-T02 CHANGING PO_OBJECT.
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
  GS_BUTTON-FUNCTION = PV_OKCODE.
  GS_BUTTON-ICON = PV_ICON.
  GS_BUTTON-QUICKINFO = PV_INFO.
  GS_BUTTON-BUTN_TYPE = PV_BTN.
  GS_BUTTON-TEXT = PV_TEXT.
  APPEND GS_BUTTON TO PO_OBJECT->MT_TOOLBAR.

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
  SET HANDLER : LCL_EVENT_HANDLER=>TOOLBAR FOR GO_ALV_ITEM,
                LCL_EVENT_HANDLER=>USER_COMMAND FOR GO_ALV_ITEM,
                LCL_EVENT_HANDLER=>TOP_OF_PAGE FOR GO_ALV_ITEM,
                LCL_EVENT_HANDLER=>BUTTON_CLICK FOR GO_ALV_ITEM,
                LCL_EVENT_HANDLER=>DATA_CHANGE FOR GO_ALV_ITEM,
                LCL_EVENT_HANDLER=>SEARCH_HELP FOR GO_ALV_ITEM.

  CALL METHOD GO_DYNDOC_ID->INITIALIZE_DOCUMENT
    EXPORTING
      BACKGROUND_COLOR = CL_DD_AREA=>COL_TEXTAREA.

  CALL METHOD GO_ALV_ITEM->LIST_PROCESSING_EVENTS
    EXPORTING
      I_EVENT_NAME = 'TOP_OF_PAGE'
      I_DYNDOC_ID  = GO_DYNDOC_ID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_USER_COMMAND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM HANDLE_USER_COMMAND  USING PV_UCOMM.
  CASE PV_UCOMM.
    WHEN 'IADD'.
      " 판매오더 생성이 완료된 경우 수정 불가
      IF GV_IS_SAVE = 'X'.
        MESSAGE S001 WITH TEXT-E05 DISPLAY LIKE 'E'.
      ELSE.
        " 행 추가
        PERFORM INSERT_ITEM.
      ENDIF.
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
  DATA : LS_STYLE TYPE LVC_S_STYL.

  CLEAR : GS_ITEM, LS_STYLE.

**********************************************************************
* 아이템 추가
**********************************************************************
*-- Edit / Display 설정
  " Display mode
  LS_STYLE-FIELDNAME = 'SONUM'.
  LS_STYLE-STYLE = GO_ALV_ITEM->MC_STYLE_DISABLED.
  INSERT LS_STYLE INTO TABLE GS_ITEM-CELLTAB.

  CLEAR : LS_STYLE.
  LS_STYLE-FIELDNAME = 'POSNR'.
  LS_STYLE-STYLE = GO_ALV_ITEM->MC_STYLE_DISABLED.
  INSERT LS_STYLE INTO TABLE GS_ITEM-CELLTAB.

  CLEAR : LS_STYLE.
  LS_STYLE-FIELDNAME = 'MAKTX'.
  LS_STYLE-STYLE = GO_ALV_ITEM->MC_STYLE_DISABLED.
  INSERT LS_STYLE INTO TABLE GS_ITEM-CELLTAB.

  CLEAR : LS_STYLE.
  LS_STYLE-FIELDNAME = 'NETWR'.
  LS_STYLE-STYLE = GO_ALV_ITEM->MC_STYLE_DISABLED.
  INSERT LS_STYLE INTO TABLE GS_ITEM-CELLTAB.

  CLEAR : LS_STYLE.
  LS_STYLE-FIELDNAME = 'WAERS'.
  LS_STYLE-STYLE = GO_ALV_ITEM->MC_STYLE_DISABLED.
  INSERT LS_STYLE INTO TABLE GS_ITEM-CELLTAB.

  " Other fields : Edit mode
  CLEAR : LS_STYLE.
  LS_STYLE-STYLE = GO_ALV_ITEM->MC_STYLE_ENABLED.
  INSERT LS_STYLE INTO TABLE GS_ITEM-CELLTAB.

*-- 기본 데이터 설정
  GS_ITEM-SONUM = GS_HEADER-SONUM.
  GS_ITEM-BTN   = ICON_DELETE.
  GS_ITEM-MEINS = 'EA'.

  APPEND GS_ITEM TO GT_ITEM.

  PERFORM REFRESH_TABLE USING GO_ALV_ITEM.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_BUTTON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_UI_FUNCTIONS
*&---------------------------------------------------------------------*
FORM EXCLUDE_BUTTON  TABLES   PT_UI_FUNCTIONS TYPE UI_FUNCTIONS.
  PT_UI_FUNCTIONS = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND PT_UI_FUNCTIONS TO PT_UI_FUNCTIONS.

  PT_UI_FUNCTIONS = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND PT_UI_FUNCTIONS TO PT_UI_FUNCTIONS.

  PT_UI_FUNCTIONS = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND PT_UI_FUNCTIONS TO PT_UI_FUNCTIONS.

  PT_UI_FUNCTIONS = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND PT_UI_FUNCTIONS TO PT_UI_FUNCTIONS.

  PT_UI_FUNCTIONS = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND PT_UI_FUNCTIONS TO PT_UI_FUNCTIONS.

  PT_UI_FUNCTIONS = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND PT_UI_FUNCTIONS TO PT_UI_FUNCTIONS.

  PT_UI_FUNCTIONS = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND PT_UI_FUNCTIONS TO PT_UI_FUNCTIONS.

  PT_UI_FUNCTIONS = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND PT_UI_FUNCTIONS TO PT_UI_FUNCTIONS.

  PT_UI_FUNCTIONS = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND PT_UI_FUNCTIONS TO PT_UI_FUNCTIONS.

  PT_UI_FUNCTIONS = CL_GUI_ALV_GRID=>MC_FC_REFRESH.
  APPEND PT_UI_FUNCTIONS TO PT_UI_FUNCTIONS.

  PT_UI_FUNCTIONS = CL_GUI_ALV_GRID=>MC_FC_AUF.
  APPEND PT_UI_FUNCTIONS TO PT_UI_FUNCTIONS.

  PT_UI_FUNCTIONS = CL_GUI_ALV_GRID=>MC_FC_AVERAGE.
  APPEND PT_UI_FUNCTIONS TO PT_UI_FUNCTIONS.

  PT_UI_FUNCTIONS = CL_GUI_ALV_GRID=>MC_FC_PRINT.
  APPEND PT_UI_FUNCTIONS TO PT_UI_FUNCTIONS.

  PT_UI_FUNCTIONS = CL_GUI_ALV_GRID=>MC_FC_GRAPH.
  APPEND PT_UI_FUNCTIONS TO PT_UI_FUNCTIONS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_TABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_ALV_ITEM
*&---------------------------------------------------------------------*
FORM REFRESH_TABLE  USING PO_ALV TYPE REF TO CL_GUI_ALV_GRID.

  DATA : LS_STBL TYPE LVC_S_STBL.

  LS_STBL-ROW = ABAP_TRUE.
  LS_STBL-COL = ABAP_TRUE.

  CALL METHOD PO_ALV->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STBL.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  EXIT_200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_200 INPUT.
  CALL METHOD : GO_ALV_PREV->FREE, GO_CONT_PREV->FREE.

  FREE : GO_ALV_PREV, GO_CONT_PREV.

  LEAVE TO SCREEN 0.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_EXCEL_DATA .
  DATA : LV_ANSWER,
         LV_TABIX  TYPE SY-TABIX.

  DATA : LS_ROW TYPE LVC_S_ROW,
         LT_ROW TYPE LVC_T_ROW.

  DATA : LV_TOT_SALE   TYPE ZC302SDT0003-NETWR VALUE 0,
         LV_ITEM_INDEX TYPE ZC302SDT0004-POSNR VALUE '010'.

*--------------------------------------------------------------------*
* 판매오더 생성 이전 작업
*--------------------------------------------------------------------*
*-- 선택한 셀 가져오기
  CALL METHOD GO_ALV_PREV->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW.

*-- 선택된 셀이 없는 경우 에러 메시지 디스플레이
  IF LT_ROW IS INITIAL.
    MESSAGE S001 WITH TEXT-E06 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 저장 컨펌 팝업
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = '판매 오더 생성'
      TEXT_QUESTION         = '선택한 아이템으로 판매 오더를 생성하시겠습니까?'
      TEXT_BUTTON_1         = '예'(001)
      ICON_BUTTON_1         = 'ICON_OKAY'
      TEXT_BUTTON_2         = '아니요'(002)
      ICON_BUTTON_2         = 'ICON_CANCEL'
      DEFAULT_BUTTON        = '1'
      DISPLAY_CANCEL_BUTTON = ' '
    IMPORTING
      ANSWER                = LV_ANSWER.

  IF LV_ANSWER <> '1'.
    MESSAGE S001 WITH TEXT-I01 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*--------------------------------------------------------------------*
* 판매오더 아이템 데이터 세팅
*--------------------------------------------------------------------*
*-- 판매오더 item 데이터 생성
  CLEAR : GT_SAVE.
  LOOP AT LT_ROW INTO LS_ROW.
    CLEAR : GS_EXCEL, GS_MAT.

    " 선택한 셀 데이터 가져오기
    READ TABLE GT_EXCEL INTO GS_EXCEL INDEX LS_ROW-INDEX.

    " 판매오더 item 데이터 세팅
    CLEAR : GS_SAVE.
    MOVE-CORRESPONDING GS_EXCEL TO GS_SAVE.

    READ TABLE GT_MAT INTO GS_MAT WITH KEY MATNR = GS_SAVE-MATNR.

    GS_SAVE-SONUM = GS_HEADER-SONUM.

    GS_SAVE-POSNR = LV_ITEM_INDEX.
    LV_ITEM_INDEX = LV_ITEM_INDEX + 10. " 아이템 번호 10씩 증가

    GS_SAVE-NETWR = GS_MAT-NETWR * GS_SAVE-MENGE.
    LV_TOT_SALE = LV_TOT_SALE + GS_SAVE-NETWR.

    GS_SAVE-WAERS = GS_MAT-WAERS.
    GS_SAVE-ERDAT = SY-DATUM.
    GS_SAVE-ERZET = SY-UZEIT.
    GS_SAVE-ERNAM = SY-UNAME.

    APPEND GS_SAVE TO GT_SAVE.
  ENDLOOP.

*--------------------------------------------------------------------*
* 판매오더 헤더 추가 데이터 세팅
*--------------------------------------------------------------------*
  GS_HEADER-NETWR = LV_TOT_SALE.
  GS_HEADER-WAERS = GS_MAT-WAERS.
  GS_HEADER-ERDAT = SY-DATUM.
  GS_HEADER-ERZET = SY-UZEIT.
  GS_HEADER-ERNAM = SY-UNAME.

*--------------------------------------------------------------------*
* 신규 판매오더 DB Table에 반영
*--------------------------------------------------------------------*
*-- 판매오더 헤더 DB Table에 반영
  MODIFY ZC302SDT0003 FROM GS_HEADER.

  IF SY-SUBRC <> 0.
    MESSAGE S001 WITH TEXT-E07 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ELSE.
    COMMIT WORK AND WAIT.
  ENDIF.

*-- 판매오더 아이템 DB Table에 저장
  MODIFY ZC302SDT0004 FROM TABLE GT_SAVE.

  IF SY-SUBRC = 0.
    MESSAGE S001 WITH TEXT-S01.
    COMMIT WORK AND WAIT.

    GV_IS_SAVE = 'X'. " 판매오더 생성 여부 변경

    " 신규 판매오더 팝업으로 내역 디스플레이
    CALL SCREEN 101 STARTING AT 30 02.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MATERIAL_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_MATERIAL_INFO .
  CLEAR : GT_MAT, GS_MAT.

  SELECT MATNR MAKTX NETWR WAERS
    FROM ZC302MT0007
    INTO TABLE GT_MAT
    WHERE MTART = '03'.

  SORT GT_MAT BY MATNR.

  IF GT_MAT IS INITIAL.
    MESSAGE S001 WITH TEXT-E19 DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_HEADER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_HEADER .
  DATA : LV_INDEX TYPE NUMC08,
         BEGIN OF LS_SONUM,
           SONUM TYPE ZC302SDT0003-SONUM,
         END OF LS_SONUM,
         LT_SONUM LIKE TABLE OF LS_SONUM.

*-- 판매오더번호 채번
  SELECT SONUM
    FROM ZC302SDT0003
    INTO TABLE LT_SONUM
    ORDER BY SONUM DESCENDING.

  READ TABLE LT_SONUM INTO LS_SONUM INDEX 1.
  LV_INDEX = LS_SONUM-SONUM+2(8) + 1.

*-- 판매오더 헤더 정보 세팅
  CLEAR : GS_HEADER.
  GS_HEADER-SONUM = 'SO' && LV_INDEX.
  GS_HEADER-SALE_ORG = P_SORG.
  GS_HEADER-CHANNEL = P_CHNL.
  GS_HEADER-BPCODE = P_BP.
  GS_HEADER-PDATE = P_PDAT.
  GS_HEADER-SDATE = SY-DATUM.
  GS_HEADER-SFLAG = 'N'.

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
  " 영업조직, 유통채널, BP 코드, 주문일자
  PERFORM ADD_ROW USING : LR_DD_TABLE COL_FIELD COL_VALUE '영업조직' P_SORG,
                          LR_DD_TABLE COL_FIELD COL_VALUE '유통채널' P_CHNL,
                          LR_DD_TABLE COL_FIELD COL_VALUE 'BP코드' P_BP,
                          LR_DD_TABLE COL_FIELD COL_VALUE '주문일자' P_PDAT.

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
*&      --> LV_TEMP
*&---------------------------------------------------------------------*
FORM ADD_ROW  USING  PR_DD_TABLE  TYPE REF TO CL_DD_TABLE_ELEMENT
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
      WIDTH = 5.

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
    MESSAGE S001 WITH TEXT-E08 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_SALES_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_DIRECT_INPUT .
  DATA : LV_ANSWER,
         LV_TABIX     TYPE SY-TABIX,
         LV_POSNR     TYPE ZC302SDT0004-POSNR VALUE 10,
         LV_NETWR_SUM TYPE ZC302SDT0003-NETWR VALUE 0.

*--------------------------------------------------------------------*
* 판매오더 생성 이전 작업
*--------------------------------------------------------------------*
*-- 저장 컨펌 팝업
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = '판매 오더 생성'
      TEXT_QUESTION         = '판매 오더를 생성하시겠습니까?'
      TEXT_BUTTON_1         = '예'(001)
      ICON_BUTTON_1         = 'ICON_OKAY'
      TEXT_BUTTON_2         = '아니요'(002)
      ICON_BUTTON_2         = 'ICON_CANCEL'
      DEFAULT_BUTTON        = '1'
      DISPLAY_CANCEL_BUTTON = ' '
    IMPORTING
      ANSWER                = LV_ANSWER.

  IF LV_ANSWER <> '1'.
    MESSAGE S001 WITH TEXT-I01 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 중복 저장 체크
  IF GV_IS_SAVE = 'X'.
    MESSAGE S001 WITH TEXT-E09 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- ALV & ITAB 동기화
  CALL METHOD GO_ALV_ITEM->CHECK_CHANGED_DATA.

*-- 아이템이 입력되지 않은 경우 오류 메시지 디스플레이
  IF GT_ITEM IS INITIAL.
    MESSAGE S001 WITH TEXT-E10 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*--------------------------------------------------------------------*
* 판매오더 아이템 생성 및 헤더 추가 세팅
*--------------------------------------------------------------------*
  CLEAR : GT_SAVE.
  MOVE-CORRESPONDING GT_ITEM TO GT_SAVE.

  IF GT_SAVE IS INITIAL.
    MESSAGE S001 WITH TEXT-E11 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  CLEAR : GS_SAVE.
  LOOP AT GT_SAVE INTO GS_SAVE.
    LV_TABIX = SY-TABIX.

    " 필수 데이터가 입력되지 않은 경우 제외
    IF ( GS_SAVE-MATNR IS INITIAL ) OR ( GS_SAVE-MENGE IS INITIAL ) OR ( GS_SAVE-MEINS IS INITIAL ).
      DELETE GT_SAVE WHERE MATNR = GS_SAVE-MATNR
                      AND  MENGE = GS_SAVE-MENGE
                      AND  MEINS = GS_SAVE-MEINS.
      CONTINUE.
    ENDIF.

    " 판매오더 헤더에 통화 필드
    IF LV_TABIX = 1.
      GS_HEADER-WAERS = GS_SAVE-WAERS.
    ENDIF.

    GS_SAVE-POSNR = LV_POSNR.
    LV_POSNR = LV_POSNR + 10. " 아이템 번호가 10씩 증가함
    LV_NETWR_SUM = LV_NETWR_SUM + GS_SAVE-NETWR.

    " 타임스탬프
    GS_SAVE-ERDAT = SY-DATUM.
    GS_SAVE-ERZET = SY-UZEIT.
    GS_SAVE-ERNAM = SY-UNAME.
    MODIFY GT_SAVE FROM GS_SAVE INDEX LV_TABIX TRANSPORTING POSNR ERDAT ERZET ERNAM.

    CLEAR : GS_SAVE.
  ENDLOOP.

*-- 판매오더 헤더 추가 세팅
  GS_HEADER-NETWR = LV_NETWR_SUM.   " 금액
  GS_HEADER-ERDAT = SY-DATUM.
  GS_HEADER-ERZET = SY-UZEIT.
  GS_HEADER-ERNAM = SY-UNAME.

*-- 유효한 아이템이 하나도 입력되지 않은 경우 오류 메시지 디스플레이
  IF GT_SAVE IS INITIAL.
    MESSAGE S001 WITH TEXT-E12 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*--------------------------------------------------------------------*
* 신규 생성한 판매오더 DB Table에 반영
*--------------------------------------------------------------------*
*-- 판매오더 아이템 DB Table에 반영
  INSERT ZC302SDT0004 FROM TABLE GT_SAVE. "ACCEPTING DUPLICATE KEYS.

*-- 오류가 발생한 경우 에러 메시지 디스플레이 및 롤백 작업
  IF SY-SUBRC <> 0.
    MESSAGE S001 WITH TEXT-E07 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
    EXIT.
  ENDIF.

*-- 판매오더 헤더 DB Table에 반영
  INSERT ZC302SDT0003 FROM GS_HEADER.

*-- 오류가 발생한 경우 에러 메시지 디스플레이 및 롤백 작업
  IF SY-SUBRC <> 0.
    MESSAGE S001 WITH TEXT-E07 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

*--------------------------------------------------------------------*
* 판매오더 생성 이후 작업
*--------------------------------------------------------------------*
  " ALV & ITAB 동기화 리프레시
  IF SY-SUBRC = 0.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE GT_ITEM
      FROM ZC302SDT0004 AS A
        LEFT OUTER JOIN ZC302MT0007 AS B
        ON A~MATNR = B~MATNR
      WHERE SONUM = GS_HEADER-SONUM.

    PERFORM REFRESH_TABLE USING GO_ALV_ITEM.

    " 수정 불가능하도록 모드 변경
    GV_IS_SAVE = 'X'.

    " 저장 성공 메시지 디스플레이 및 생성된 판매오더 내역 팝업으로 디스플레이
    MESSAGE S001 WITH TEXT-S01.
    CALL SCREEN 101 STARTING AT 30 02.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_BUTTON_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ES_COL_ID
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM HANDLE_BUTTON_CLICK  USING    PS_COL_ID
                                   PS_ROW_NO TYPE LVC_S_ROID.
  DATA : LV_ANSWER.

*-- 판매오더 생성이 완료된 경우 수정 불가
  IF GV_IS_SAVE = 'X'.
    MESSAGE S001 WITH TEXT-E05 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 삭제 컨펌 팝업
  PERFORM CONFIRM_POPUP USING '해당 아이템을 삭제하시겠습니까?' CHANGING LV_ANSWER.
  IF LV_ANSWER <> '1'.
    EXIT.
  ENDIF.

*-- itab에서 해당 행 삭제
  DELETE GT_ITEM INDEX PS_ROW_NO-ROW_ID.

*-- ITAB & ALV 동기화
  CALL METHOD GO_ALV_ITEM->REFRESH_TABLE_DISPLAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONFIRM_POPUP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
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
*& Form HANDLE_DATA_CHANGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGE USING PV_MODIFIED
                              PT_GOOD_CELLS TYPE LVC_T_MODI.

  DATA : LS_GOOD_CELLS TYPE LVC_S_MODI.

*-- 변경된 내역이 있는지 확인
  CHECK PV_MODIFIED IS NOT INITIAL.

*-- 변경 대상 필드 확인
  CLEAR : LS_GOOD_CELLS.
  READ TABLE PT_GOOD_CELLS INTO LS_GOOD_CELLS INDEX 1.

  CLEAR : GS_ITEM.
  READ TABLE GT_ITEM INTO GS_ITEM INDEX LS_GOOD_CELLS-ROW_ID.

  CASE LS_GOOD_CELLS-FIELDNAME.
      " 자재코드 입력 -> 자재명 자동 업데이트
    WHEN 'MATNR'.
      CLEAR : GS_MAT.
      READ TABLE GT_MAT INTO GS_MAT WITH KEY MATNR = LS_GOOD_CELLS-VALUE.

      IF GS_ITEM-MENGE IS NOT INITIAL.
        GS_ITEM-NETWR = GS_MAT-NETWR * GS_ITEM-MENGE. " 금액
        GS_ITEM-WAERS = GS_MAT-WAERS.
      ENDIF.

      GS_ITEM-MAKTX = GS_MAT-MAKTX. " 제품명
      MODIFY GT_ITEM FROM GS_ITEM INDEX LS_GOOD_CELLS-ROW_ID TRANSPORTING MAKTX NETWR WAERS.

      " 수량 입력 -> 금액 & 통화 자동 업데이트
    WHEN 'MENGE'.

      " 자재코드가 입력되지 않았다면 에러메시지 디스플레이
      IF GS_ITEM-MATNR IS INITIAL.
        MESSAGE S001 WITH TEXT-E13 DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

      CLEAR : GS_MAT.
      READ TABLE GT_MAT INTO GS_MAT WITH KEY MATNR = GS_ITEM-MATNR.

      GS_ITEM-MENGE = LS_GOOD_CELLS-VALUE.                " 수량
      GS_ITEM-NETWR = GS_MAT-NETWR * LS_GOOD_CELLS-VALUE. " 금액
      GS_ITEM-WAERS = GS_MAT-WAERS.                       " 통화

      MODIFY GT_ITEM FROM GS_ITEM INDEX LS_GOOD_CELLS-ROW_ID.
  ENDCASE.

  PERFORM REFRESH_TABLE USING GO_ALV_ITEM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REGISTER_F4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REGISTER_F4 .

  DATA: LT_F4 TYPE LVC_T_F4 WITH HEADER LINE.
  DATA: LT_F4_DATA TYPE LVC_S_F4.

*-- 자재코드 필드에 Search Help(F4) 설치
  LT_F4_DATA-FIELDNAME = 'MATNR'.
  LT_F4_DATA-REGISTER = 'X' .
  LT_F4_DATA-GETBEFORE = 'X' .
  LT_F4_DATA-CHNGEAFTER  ='X'.
  INSERT LT_F4_DATA INTO TABLE LT_F4.

  CALL METHOD GO_ALV_ITEM->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = LT_F4[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ONF4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_FIELDNAME
*&      --> E_FIELDVALUE
*&      --> ES_ROW_NO
*&      --> ER_EVENT_DATA
*&      --> ET_BAD_CELLS
*&      --> E_DISPLAY
*&---------------------------------------------------------------------*
FORM ONF4  USING  P_FIELDNAME   TYPE  LVC_FNAME
                  P_FIELDVALUE  TYPE  LVC_VALUE
                  PS_ROW_NO     TYPE  LVC_S_ROID
                  PI_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA
                  PT_BAD_CELLS  TYPE  LVC_T_MODI
                  P_DISPLAY     TYPE  CHAR01.

  DATA : LT_RETURN LIKE TABLE OF DDSHRETVAL WITH HEADER LINE.

  DATA : BEGIN OF LS_MAT_F4,
           MATNR TYPE ZC302MT0007-MATNR,
           MAKTX TYPE ZC302MT0007-MAKTX,
         END OF LS_MAT_F4,
         LT_MAT_F4 LIKE TABLE OF LS_MAT_F4.

*-- Get Material Info for Search Help(F4)
  MOVE-CORRESPONDING GT_MAT TO LT_MAT_F4.

*-- 자재코드에 Search Help(F4) 부착
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'MATNR'
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'MATNR'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_MAT_F4
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  PI_EVENT_DATA->M_EVENT_HANDLED = 'X'.

*-- Search Help에서 항목 선택 시 ALV에 선택한 값 들어감
  FIELD-SYMBOLS:  <FS> TYPE LVC_T_MODI.

  DATA: LS_MODI TYPE LVC_S_MODI.

  ASSIGN PI_EVENT_DATA->M_DATA->* TO <FS>.

  READ TABLE LT_RETURN INDEX 1.
  IF SY-SUBRC = 0.
    LS_MODI-ROW_ID    = PS_ROW_NO-ROW_ID.
    LS_MODI-FIELDNAME = P_FIELDNAME.
    LS_MODI-VALUE     = LT_RETURN-FIELDVAL.
    APPEND LS_MODI TO <FS>.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_BROWSER_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_BROWSER_INFO .

  IF W_PFOLDER IS NOT INITIAL.
    W_INITIALFOLDER = W_PFOLDER.
  ELSE.
    CALL METHOD CL_GUI_FRONTEND_SERVICES=>GET_TEMP_DIRECTORY
      CHANGING
        TEMP_DIR = W_INITIALFOLDER.
  ENDIF.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_BROWSE
    EXPORTING
      WINDOW_TITLE    = 'Download path'
      INITIAL_FOLDER  = W_INITIALFOLDER
    CHANGING
      SELECTED_FOLDER = W_PICKEDFOLDER.

  IF SY-SUBRC = 0.
    W_PFOLDER = W_PICKEDFOLDER.
  ELSE.
    MESSAGE I001 WITH TEXT-E14 DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOWNLOAD_TEMPLATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_FILENAME
*&---------------------------------------------------------------------*
FORM DOWNLOAD_TEMPLATE  USING    PV_FILENAME.

  DATA : WWWDATA_ITEM LIKE WWWDATATAB,
         RC           TYPE I.


  GV_FILE = PV_FILENAME.

  CALL FUNCTION 'WS_FILE_DELETE'
    EXPORTING
      FILE   = GV_FILE
    IMPORTING
      RETURN = RC.

  SELECT SINGLE * FROM WWWDATA
    INTO CORRESPONDING FIELDS OF WWWDATA_ITEM
   WHERE OBJID = 'ZC314_XLS_FORM_SO'. " Form name

  CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
    EXPORTING
      KEY         = WWWDATA_ITEM
      DESTINATION = GV_FILE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REGISTER_EVENT_200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REGISTER_EVENT_200 .
  SET HANDLER : LCL_EVENT_HANDLER=>TOP_OF_PAGE  FOR GO_ALV_PREV.

  CALL METHOD GO_DYNDOC_ID->INITIALIZE_DOCUMENT
    EXPORTING
      BACKGROUND_COLOR = CL_DD_AREA=>COL_TEXTAREA.


  CALL METHOD GO_ALV_PREV->LIST_PROCESSING_EVENTS
    EXPORTING
      I_EVENT_NAME = 'TOP_OF_PAGE'
      I_DYNDOC_ID  = GO_DYNDOC_ID.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DUPLICATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_DUPLICATE .

  DATA : LS_ZC302SDT0003 TYPE ZC302SDT0003,
         LV_ANSWER.

*-- 동일 조건의 중복된 판매오더가 기존에 존재하는지 체크
  SELECT SINGLE *
    FROM ZC302SDT0003
    INTO LS_ZC302SDT0003
    WHERE BPCODE = P_BP
      AND CHANNEL = P_CHNL
      AND SALE_ORG = P_SORG
      AND PDATE = P_PDAT
      AND STATUS <> 'R'.

  " 중복된 데이터가 있는 경우
  IF SY-SUBRC = 0.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR              = '판매 오더 생성'
        TEXT_QUESTION         = '동일한 조건으로 생성된 판매오더가 존재합니다.'
        TEXT_BUTTON_1         = '기존 오더 조회'(001)
        ICON_BUTTON_1         = 'ICON_DISPLAY'
        TEXT_BUTTON_2         = '신규 오더 생성'(002)
        ICON_BUTTON_2         = 'ICON_CREATE'
        DEFAULT_BUTTON        = '1'
        DISPLAY_CANCEL_BUTTON = ' '
      IMPORTING
        ANSWER                = LV_ANSWER.

    IF LV_ANSWER = '1'. " 기존 오더 조회
      CALL SCREEN 300.
      STOP.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_BP_NAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_BP_NAME .

  CLEAR : GS_BPCODE.
  READ TABLE GT_BPCODE INTO GS_BPCODE WITH KEY BPCODE = P_BP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_SO_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_SO_SCREEN .

  IF GO_CONT_SO IS NOT BOUND.
    CLEAR : GT_FCAT_PREV.
    PERFORM SET_FCAT USING : 'SO' 'X' 'SONUM' '판매주문번호' 'C' ' ' ,
                             'SO' 'X' 'POSNR' '아이템번호'  'C' ' ' ,
                             'SO' ' ' 'MATNR' '자재코드'   'C' ' ' ,
                             'SO' ' ' 'MAKTX' '자재명'    ' ' 'X' ,
                             'SO' ' ' 'MENGE' '수량'     ' ' ' ' ,
                             'SO' ' ' 'MEINS' '단위'     'C' ' ' ,
                             'SO' ' ' 'NETWR' '금액'     ' ' ' ' ,
                             'SO' ' ' 'WAERS' '통화'     'C' ' ' .

    PERFORM CREATE_OBJECT USING : GO_CONT_SO GO_ALV_SO 'SO_CONT'.

    CALL METHOD GO_ALV_SO->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        I_SAVE          = 'A'
        I_DEFAULT       = 'X'
        IS_LAYOUT       = GS_LAYOUT
      CHANGING
        IT_OUTTAB       = GT_RESULT
        IT_FIELDCATALOG = GT_FCAT_SO.
  ENDIF.

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

*-- 필수 필드를 입력하지 않으면 에러메시지 발생
  IF ( P_BP IS INITIAL ) OR ( P_CHNL IS INITIAL ) OR ( P_SORG IS INITIAL ) OR ( P_PDAT IS INITIAL ).
    MESSAGE S001 WITH TEXT-E16 DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

*-- 유통채널과 매칭되는 BP코드가 입력되었는지 확인
  CASE P_CHNL.
    WHEN 'DS'.
      IF ( P_BP <> 'VD0001' ) AND ( P_BP <> 'VD0002' ) AND ( P_BP <> 'VD0003' ).
        MESSAGE S001 WITH TEXT-E21 DISPLAY LIKE 'E'.
        STOP.
      ENDIF.
    WHEN 'AS'.
      IF ( P_BP <> 'VD0004' ) AND ( P_BP <> 'VD0005' ) AND ( P_BP <> 'VD0006' ) AND
         ( P_BP <> 'VD0007' ) AND ( P_BP <> 'VD0008' ).
        MESSAGE S001 WITH TEXT-E21 DISPLAY LIKE 'E'.
        STOP.
      ENDIF.
  ENDCASE.

*-- 주문일자에 미래 일자 입력 불가
  IF P_PDAT > SY-DATUM.
    MESSAGE S001 WITH TEXT-E17 DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_CHANNEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4_CHANNEL .
  DATA : LT_RETURN LIKE TABLE OF DDSHRETVAL WITH HEADER LINE.

  REFRESH : LT_RETURN.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'CHNL'
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'P_CHNL'
      WINDOW_TITLE    = 'Distribution Channel'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = GT_CHNL
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

*-- 유통채널에 맞는 BP코드 불러오기
  LT_RETURN = VALUE #( LT_RETURN[ 1 ] OPTIONAL ).

  CASE LT_RETURN-FIELDVAL.
    WHEN 'DS'.
      CLEAR : GT_BPCODE.
      SELECT BPCODE CNAME
        FROM ZC302MT0001
        INTO CORRESPONDING FIELDS OF TABLE GT_BPCODE
        WHERE BPCODE IN ( 'VD0001', 'VD0002', 'VD0003' ).
    WHEN 'AS'.
      CLEAR : GT_BPCODE.
      SELECT BPCODE CNAME
        FROM ZC302MT0001
        INTO CORRESPONDING FIELDS OF TABLE GT_BPCODE
        WHERE BPCODE IN ( 'VD0004', 'VD0005', 'VD0006', 'VD0007', 'VD0008' ).
    ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_PRE_SO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_PRE_SO .
  DATA : LV_TABIX TYPE SY-TABIX.

**********************************************************************
* 기존 판매오더 불러오기
**********************************************************************
*-- 판매오더 헤더
  CLEAR : GS_PRE_HEADER, GS_PRE_ITEM, GT_PRE_HEADER, GT_PRE_ITEM.

  SELECT SONUM SALE_ORG CHANNEL BPCODE PDATE NETWR WAERS
         SDATE STATUS APDATE REMARK EMP_NUM
    INTO CORRESPONDING FIELDS OF TABLE GT_PRE_HEADER
  FROM ZC302SDT0003
      WHERE BPCODE = P_BP
    AND CHANNEL = P_CHNL
    AND SALE_ORG = P_SORG
    AND PDATE = P_PDAT.


    CLEAR : GS_PRE_HEADER.
    LOOP AT GT_PRE_HEADER INTO GS_PRE_HEADER.
      LV_TABIX = SY-TABIX.

      " 반려 사유가 있는 경우 반려 사유 상세 버튼
      IF GS_PRE_HEADER-REMARK IS NOT INITIAL.
        GS_PRE_HEADER-BTN = '반려 사유 상세'.
      ENDIF.

      " 결재 상태에 따른 아이콘 세팅
      CASE GS_PRE_HEADER-STATUS.
        WHEN 'A'.
          GS_PRE_HEADER-ICON = ICON_LED_GREEN.
        WHEN 'R'.
          GS_PRE_HEADER-ICON = ICON_LED_RED.
        WHEN ''.
          GS_PRE_HEADER-ICON = ICON_LED_INACTIVE.
      ENDCASE.

      MODIFY GT_PRE_HEADER FROM GS_PRE_HEADER INDEX LV_TABIX TRANSPORTING BTN ICON.

      CLEAR : GS_PRE_HEADER.
    ENDLOOP.

*-- Default : 첫번째 판매오더에 대한 아이템
    GS_PRE_HEADER = VALUE #( GT_PRE_HEADER[ 1 ] ).
    SELECT SONUM POSNR A~MATNR MAKTX A~MENGE A~MEINS A~NETWR A~WAERS
      INTO CORRESPONDING FIELDS OF TABLE GT_PRE_ITEM
      FROM ZC302SDT0004 AS A
      LEFT OUTER JOIN ZC302MT0007 AS B
      ON A~MATNR = B~MATNR
      WHERE SONUM = GS_PRE_HEADER-SONUM.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_SCREEN_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_SCREEN_300 .
  IF GO_PRE_CONT IS NOT BOUND.
    CLEAR : GT_FCAT_PRE_T, GT_FCAT_PRE_B.
    PERFORM SET_FCAT USING : 'PRE_T' 'X' 'SONUM' '판매주문번호' 'C' ' ',
                             'PRE_T' ' ' 'SALE_ORG' '영업조직' 'C' ' ',
                             'PRE_T' ' ' 'CHANNEL' '유통채널' 'C' ' ',
                             'PRE_T' ' ' 'BPCODE' 'BP코드' 'C' ' ',
                             'PRE_T' ' ' 'PDATE' '주문일자' 'C' ' ',
                             'PRE_T' ' ' 'NETWR' '금액' ' ' ' ',
                             'PRE_T' ' ' 'WAERS' '통화' 'C' ' ',
                             'PRE_T' ' ' 'SDATE' '판매오더생성일' ' ' ' ',
                             'PRE_T' ' ' 'ICON' '결재여부' 'C' ' ',
                             'PRE_T' ' ' 'APDATE' '결재일자' 'C' ' ',
                             'PRE_T' ' ' 'BTN' '반려사유' ' ' 'X',
                             'PRE_T' ' ' 'EMP_NUM' '결재자' 'C' ' ',

                             'PRE_B' 'X' 'SONUM' '판매주문번호' 'C' ' ',
                             'PRE_B' 'X' 'POSNR' '아이템번호' 'C' ' ',
                             'PRE_B' ' ' 'MATNR' '자재코드' 'C' ' ',
                             'PRE_B' ' ' 'MAKTX' '자재명' ' ' 'X',
                             'PRE_B' ' ' 'MENGE' '수량' ' ' ' ',
                             'PRE_B' ' ' 'MEINS' '단위' 'C' ' ',
                             'PRE_B' ' ' 'NETWR' '금액' ' ' ' ',
                             'PRE_B' ' ' 'WAERS' '통화' 'C' ' '.

    PERFORM SET_LAYOUT_PRE.

    PERFORM CREATE_OBJECT_PRE.

    SET HANDLER : LCL_EVENT_HANDLER=>HOTSPOT_CLICK FOR GO_PRE_ALV_T,
                  LCL_EVENT_HANDLER=>BUTTON_CLICK_REASON FOR GO_PRE_ALV_T.

    GS_LAYOUT_PRE-GRID_TITLE = '판매오더 Header'.
    GS_LAYOUT_PRE-SMALLTITLE = ABAP_TRUE.
    CALL METHOD GO_PRE_ALV_T->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        I_SAVE          = 'A'
        I_DEFAULT       = 'X'
        IS_LAYOUT       = GS_LAYOUT_PRE
      CHANGING
        IT_OUTTAB       = GT_PRE_HEADER
        IT_FIELDCATALOG = GT_FCAT_PRE_T.

    GS_LAYOUT_PRE-GRID_TITLE = '판매오더 Item'.
    CALL METHOD GO_PRE_ALV_B->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        I_SAVE          = 'A'
        I_DEFAULT       = 'X'
        IS_LAYOUT       = GS_LAYOUT_PRE
      CHANGING
        IT_OUTTAB       = GT_PRE_ITEM
        IT_FIELDCATALOG = GT_FCAT_PRE_B.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_PRE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_PRE .
  CLEAR : GS_LAYOUT_PRE.

  GS_LAYOUT_PRE-ZEBRA = ABAP_TRUE.
  GS_LAYOUT_PRE-SEL_MODE = 'D'.
  GS_LAYOUT_PRE-CWIDTH_OPT = 'A'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT_PRE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT_PRE .
*-- Main Container
  CREATE OBJECT GO_PRE_CONT
    EXPORTING
      SIDE      = GO_PRE_CONT->DOCK_AT_LEFT
      EXTENSION = 5000.

*-- Splitter Container
  CREATE OBJECT GO_PRE_SPLIT
    EXPORTING
      PARENT  = GO_PRE_CONT
      ROWS    = 2
      COLUMNS = 1.

*-- Left Container
  CALL METHOD GO_PRE_SPLIT->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_PRE_CONT_T.

*-- Right Container
  CALL METHOD GO_PRE_SPLIT->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_PRE_CONT_B.

*-- Left ALV Grid
  CREATE OBJECT GO_PRE_ALV_T
    EXPORTING
      I_PARENT = GO_PRE_CONT_T.

*-- Right ALV Grid
  CREATE OBJECT GO_PRE_ALV_B
    EXPORTING
      I_PARENT = GO_PRE_CONT_B.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_COLUMN_ID
*&      --> E_ROW_ID
*&---------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK  USING    PV_COLUMN_ID
                                    PV_ROW_ID.

*-- 선택한 판매오더 Header 정보 읽어오기
  CLEAR : GS_PRE_HEADER.
  READ TABLE GT_PRE_HEADER INTO GS_PRE_HEADER INDEX PV_ROW_ID.

*-- 선택한 판매오더의 아이템 불러오기
  CLEAR : GT_PRE_ITEM.
  SELECT SONUM POSNR A~MATNR MAKTX A~MENGE A~MEINS A~NETWR A~WAERS
    INTO CORRESPONDING FIELDS OF TABLE GT_PRE_ITEM
    FROM ZC302SDT0004 AS A
    LEFT OUTER JOIN ZC302MT0007 AS B
      ON A~MATNR = B~MATNR
    WHERE SONUM = GS_PRE_HEADER-SONUM.

    IF SY-SUBRC <> 0.
      MESSAGE S001 WITH TEXT-E20 DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.

    CALL METHOD : GO_PRE_ALV_B->REFRESH_TABLE_DISPLAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_BUTTON_CLICK_REASON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ES_COL_ID
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM HANDLE_BUTTON_CLICK_REASON  USING    PS_COL_ID TYPE LVC_S_COL
                                          PS_ROW_NO TYPE LVC_S_ROID.
*-- 클릭된 판매오더 헤더 읽어옴
  CLEAR : GS_PRE_HEADER.
  READ TABLE GT_PRE_HEADER INTO GS_PRE_HEADER INDEX PS_ROW_NO-ROW_ID.

  IF GS_PRE_HEADER-REMARK IS INITIAL.
    EXIT.
  ENDIF.

*-- 반려 사유 상세 팝업 디스플레이
  CALL SCREEN 102 STARTING AT 30 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_REASON_POPUP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_REASON_POPUP .
  IF GO_TEXT_CONT IS NOT BOUND.

*-- Container
    CREATE OBJECT GO_TEXT_CONT
      EXPORTING
        CONTAINER_NAME = 'TEXT_CONT'.

*-- Text Editor
    CREATE OBJECT GO_TEXT_EDIT
      EXPORTING
        WORDWRAP_MODE = CL_GUI_TEXTEDIT=>WORDWRAP_AT_WINDOWBORDER
        PARENT        = GO_TEXT_CONT.

*-- Textedit Toolbar
    CALL METHOD GO_TEXT_EDIT->SET_TOOLBAR_MODE
      EXPORTING
        TOOLBAR_MODE = GO_TEXT_EDIT->FALSE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_TEXT .

*-- 줄바꿈 세팅
  CLEAR : GT_CONTENT.
  SPLIT GS_PRE_HEADER-REMARK AT CL_ABAP_CHAR_UTILITIES=>NEWLINE INTO TABLE GT_CONTENT.

*-- 자동 들여쓰기
  CALL METHOD GO_TEXT_EDIT->SET_AUTOINDENT_MODE
    EXPORTING
      AUTO_INDENT            = 1
    EXCEPTIONS
      ERROR_CNTL_CALL_METHOD = 1
      OTHERS                 = 2.

*-- 기존 작성된 내용 삭제
  CALL METHOD GO_TEXT_EDIT->DELETE_TEXT.

*-- Text Editor에 반려사유 세팅
  CALL METHOD GO_TEXT_EDIT->SET_SELECTED_TEXT_AS_R3TABLE
    EXPORTING
      TABLE           = GT_CONTENT
    EXCEPTIONS
      ERROR_DP        = 1
      ERROR_DP_CREATE = 2
      OTHERS          = 3.

*-- Read Mode 세팅
  CALL METHOD GO_TEXT_EDIT->SET_READONLY_MODE
    EXPORTING
      READONLY_MODE = GO_TEXT_EDIT->TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MAKTX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_MAKTX .
  DATA : LS_MAT   TYPE ZC302MT0007,
         LT_MAT   TYPE TABLE OF ZC302MT0007,
         LV_TABIX TYPE SY-TABIX.

*-- 자재명 정보 불러오기
  CLEAR : LS_MAT, LT_MAT.
  SELECT MATNR MAKTX
    INTO CORRESPONDING FIELDS OF TABLE LT_MAT
    FROM ZC302MT0007
    FOR ALL ENTRIES IN GT_SAVE
    WHERE MATNR = GT_SAVE-MATNR.

    IF LT_MAT IS INITIAL.
      MESSAGE S001 WITH TEXT-E22 DISPLAY LIKE 'E'.
    ENDIF.

*-- 자재명 세팅
    CLEAR : GT_RESULT, GS_RESULT.
    MOVE-CORRESPONDING GT_SAVE TO GT_RESULT.

    LOOP AT GT_RESULT INTO GS_RESULT.
      LV_TABIX = SY-TABIX.

      READ TABLE LT_MAT INTO LS_MAT WITH KEY MATNR = GS_RESULT-MATNR.

      IF SY-SUBRC = 0.
        GS_RESULT-MAKTX = LS_MAT-MAKTX.
        MODIFY GT_RESULT FROM GS_RESULT INDEX LV_TABIX TRANSPORTING MAKTX.
      ENDIF.
    ENDLOOP.

ENDFORM.
