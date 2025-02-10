*&---------------------------------------------------------------------*
*& Include          SAPMZC302SD0002F01
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
*-- 영업조직 default값 세팅
  GV_SORG = '0001'.

*-- 유통채널 Search Help(F4) 데이터 세팅
  IF GT_CHNL_F4 IS INITIAL.
    GT_CHNL_F4 = VALUE #( ( CHNL = 'OS' CTEXT = '자사몰' )
                          ( CHNL = 'DS' CTEXT = '국내유통' )
                            ( CHNL = 'AS' CTEXT = '해외유통' )
                        ).
  ENDIF.

*-- BP코드 Search Help(F4) 데이터 세팅
  IF GT_BP_F4 IS INITIAL.
    SELECT BPCODE CNAME
      FROM ZC302MT0001
      INTO CORRESPONDING FIELDS OF TABLE GT_BP_F4
      WHERE BPTYPE = 'VD'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CHNL_F4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_CHNL_F4 .
  DATA : LT_RETURN TYPE TABLE OF DDSHRETVAL WITH HEADER LINE.

*-- Execute Search Help(F4)
  REFRESH LT_RETURN.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'CHNL'
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'GV_CHNL'
      WINDOW_TITLE    = 'Distribution channel'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = GT_CHNL_F4
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

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
FORM SET_FCAT  USING PV_GUBUN   " Field Catalog 구분자
                     PV_KEY     " 키필드
                     PV_FIELD   " 필드
                     PV_TEXT    " 헤더 텍스트
                     PV_JUST    " Align
                     PV_EMP     " 강조
                     PV_POS.    " 순서


  DATA : LV_S_FCAT(15),
         LV_T_FCAT(15).

  " 필드 심볼 정의
  FIELD-SYMBOLS : <FS_S_FCAT> TYPE LVC_S_FCAT,
                  <FS_T_FCAT> TYPE LVC_T_FCAT.

  " 필드 심볼에 Assign할 필드 카탈로그
  CONCATENATE 'GS_FCAT_' PV_GUBUN INTO LV_S_FCAT.
  CONCATENATE 'GT_FCAT_' PV_GUBUN INTO LV_T_FCAT.

  " 필드 심볼에 필드 카탈로그 Assign
  ASSIGN (LV_S_FCAT) TO <FS_S_FCAT>.
  ASSIGN (LV_T_FCAT) TO <FS_T_FCAT>.

  " 키필드, 필드, 헤더 텍스트, align, 강조, 순서 세팅
  IF <FS_S_FCAT> IS ASSIGNED.
    CLEAR : <FS_S_FCAT>.
    <FS_S_FCAT>-KEY       = PV_KEY.
    <FS_S_FCAT>-FIELDNAME = PV_FIELD.
    <FS_S_FCAT>-COLTEXT   = PV_TEXT.
    <FS_S_FCAT>-JUST      = PV_JUST.
    <FS_S_FCAT>-EMPHASIZE = PV_EMP.
    <FS_S_FCAT>-COL_POS   = PV_POS.

    " 수량, 금액 필드에 대해서 참조 필드 지정 및 버튼/핫스팟 속성 세팅
    CASE PV_FIELD.
      WHEN 'NETWR'.
        <FS_S_FCAT>-CFIELDNAME = 'WAERS'.
      WHEN 'APP_BTN'.
        <FS_S_FCAT>-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_BUTTON.
      WHEN 'I_RTPTQUA'.
        <FS_S_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'I_RESMAT'.
        <FS_S_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'H_RTPTQUA'.
        <FS_S_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'H_RESMAT'.
        <FS_S_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'AVQTY'.
        <FS_S_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'MENGE'.
        <FS_S_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'SONUM'.
        IF ( PV_GUBUN <> 'DETAIL' ) AND ( PV_GUBUN <> 'PEN' ) AND ( PV_GUBUN <> 'POP' ).
          <FS_S_FCAT>-HOTSPOT = ABAP_TRUE.
        ENDIF.
      WHEN 'REMARK_BTN'.
        <FS_S_FCAT>-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_BUTTON.
    ENDCASE.

    APPEND <FS_S_FCAT> TO <FS_T_FCAT>.
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
  GS_LAYOUT-SEL_MODE   = 'D'.
  GS_LAYOUT-CWIDTH_OPT = 'A'.
  GS_LAYOUT-CTAB_FNAME = 'COLOR'.

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

*-- Container
  CREATE OBJECT PO_CONT
    EXPORTING
      CONTAINER_NAME = PV_CONT_NAME.

*-- ALV Grid
  CREATE OBJECT PO_ALV
    EXPORTING
      I_PARENT = PO_CONT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_SCREEN_101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_SCREEN .
  IF GO_CONT_PEN IS NOT BOUND.

    CLEAR : GT_FCAT_PEN, GT_FCAT_APP, GT_FCAT_REJ.
    PERFORM SET_FCAT USING : 'FST' ' ' 'ICON'       '결재상태'    'C' ' ' '1',   " 전체 오더에 대한 Field Catalog
                             'FST' 'X' 'SONUM'      '판매오더번호'  'C' ' ' '2',
                             'FST' ' ' 'SALE_ORG'   '영업조직'    'C' ' ' '3',
                             'FST' ' ' 'CHANNEL'    '유통채널'    'C' ' ' '4',
                             'FST' ' ' 'BPCODE'     'BP코드'    'C' ' ' '5',
                             'FST' ' ' 'PDATE'      '주문일자'    'C' ' ' '6',
                             'FST' ' ' 'NETWR'      '판매금액'    ' ' ' ' '7',
                             'FST' ' ' 'WAERS'      '통화'       'C' ' ' '8',
                             'FST' ' ' 'SDATE'      '판매오더생성일' 'C' ' ' '9',
                             'FST' ' ' 'REMARK_BTN' '반려사유'     'C' ' ' '10',
                             'FST' ' ' 'APDATE'     '결재일자'     'C' ' ' '11',
                             'FST' ' ' 'EMP_NUM'    '결재자'      'C' ' ' '12',

                             'PEN' ' ' 'ICON'     '결재상태'    'C' ' ' '1',  " 대기 오더에 대한 Field Catalog
                             'PEN' 'X' 'SONUM'    '판매오더번호'  'C' ' ' '2',
                             'PEN' ' ' 'SALE_ORG' '영업조직'    'C' ' ' '3',
                             'PEN' ' ' 'CHANNEL'  '유통채널'    'C' ' ' '4',
                             'PEN' ' ' 'BPCODE'   'BP코드'    'C' ' ' '5',
                             'PEN' ' ' 'PDATE'    '주문일자'    'C' ' ' '6',
                             'PEN' ' ' 'NETWR'    '판매금액'    ' ' ' ' '7',
                             'PEN' ' ' 'WAERS'    '통화'       'C' ' ' '8',
                             'PEN' ' ' 'SDATE'    '판매오더생성일' 'C' ' ' '9',
                             'PEN' ' ' 'APP_BTN'  ' '       'C' ' ' '10',

                             'APP' ' ' 'ICON'     '결재상태'    'C' ' ' '1',  " 승인 오더에 대한 Field Catalog
                             'APP' 'X' 'SONUM'    '판매오더번호'  'C' ' ' '2',
                             'APP' ' ' 'SALE_ORG' '영업조직'    'C' ' ' '3',
                             'APP' ' ' 'CHANNEL'  '유통채널'    'C' ' ' '4',
                             'APP' ' ' 'BPCODE'   'BP코드'    'C' ' ' '5',
                             'APP' ' ' 'PDATE'    '주문일자'    'C' ' ' '6',
                             'APP' ' ' 'NETWR'    '판매금액'    ' ' ' ' '7',
                             'APP' ' ' 'WAERS'    '통화'       'C' ' ' '8',
                             'APP' ' ' 'SDATE'    '판매오더생성일' 'C' ' ' '9',
                             'APP' ' ' 'APDATE'   '결재일자'     'C' ' ' '10',
                             'APP' ' ' 'EMP_NUM' '결재자'      'C' ' ' '11',

                             'REJ' ' ' 'ICON'       '결재상태'    'C' ' ' '1',  " 반려 오더에 대한 Field Catalog
                             'REJ' 'X' 'SONUM'      '판매오더번호'  'C' ' ' '2',
                             'REJ' ' ' 'SALE_ORG'   '영업조직'    'C' ' ' '3',
                             'REJ' ' ' 'CHANNEL'    '유통채널'    'C' ' ' '4',
                             'REJ' ' ' 'BPCODE'     'BP코드'    'C' ' ' '5',
                             'REJ' ' ' 'PDATE'      '주문일자'    'C' ' ' '6',
                             'REJ' ' ' 'NETWR'      '판매금액'    ' ' ' ' '7',
                             'REJ' ' ' 'WAERS'      '통화'       'C' ' ' '8',
                             'REJ' ' ' 'SDATE'      '판매오더생성일' 'C' ' ' '9',
                             'REJ' ' ' 'REMARK_BTN' '반려사유'     'C' ' ' '10',
                             'REJ' ' ' 'APDATE'     '결재일자'     'C' ' ' '11',
                             'REJ' ' ' 'EMP_NUM'    '결재자'      'C' ' ' '12'.

    PERFORM SET_LAYOUT.

*-- 전체/대기/승인/반려 ALV에 대한 컨테이너 & ALV Grid
    PERFORM CREATE_OBJECT USING : GO_CONT_FST GO_ALV_FST 'FST_CONT',
                                  GO_CONT_PEN GO_ALV_PEN 'PEN_CONT',
                                  GO_CONT_APP GO_ALV_APP 'APP_CONT',
                                  GO_CONT_REJ GO_ALV_REJ 'REJ_CONT'.

*-- 버튼/핫스팟 클릭 이벤트 등록
    PERFORM REGISTER_EVENT.

*-- 각 ALV에 ITAB 바인딩
    PERFORM SET_FIRST_DISPLAY USING : GO_ALV_FST GT_SO_HEADER GT_FCAT_FST GS_LAYOUT,
                                      GO_ALV_PEN GT_SO_PEN GT_FCAT_PEN GS_LAYOUT,
                                      GO_ALV_APP GT_SO_APP GT_FCAT_APP GS_LAYOUT,
                                      GO_ALV_REJ GT_SO_REJ GT_FCAT_REJ GS_LAYOUT.


  ELSE.
    CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
      EXPORTING
        NEW_CODE = 'ENTER'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TABLE_FOR_FIRST_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_SO_PEN
*&      --> GS_FCAT_PEN
*&      --> GS_LAYOUT
*&---------------------------------------------------------------------*
FORM SET_FIRST_DISPLAY  USING    PO_ALV TYPE REF TO CL_GUI_ALV_GRID
                                           PT_SO_DATA
                                           PT_FCAT
                                           PS_LAYOUT.

  CALL METHOD PO_ALV->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      I_SAVE          = 'A'
      I_DEFAULT       = 'X'
      IS_LAYOUT       = PS_LAYOUT
    CHANGING
      IT_OUTTAB       = PT_SO_DATA
      IT_FIELDCATALOG = PT_FCAT.

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
  DATA : LV_TABIX   TYPE SY-TABIX,
         LV_GAP     TYPE P,
         LV_TYPE(2).

  IF GT_SO_HEADER IS INITIAL.

*-- 조회조건에 맞는 판매오더 읽어옴
    SELECT SONUM SALE_ORG CHANNEL BPCODE CUST_NUM PDATE
           NETWR WAERS SDATE STATUS APDATE REMARK EMP_NUM SFLAG
           ERDAT ERZET ERNAM AEDAT AEZET AENAM
      FROM ZC302SDT0003
      INTO CORRESPONDING FIELDS OF TABLE GT_SO_HEADER
      WHERE SALE_ORG = GV_SORG
        AND CHANNEL  IN GR_CHNL
        AND BPCODE   IN GR_BPCODE
        AND SDATE    IN GR_DATE.

*-- 판매주문번호로 정렬
    SORT GT_SO_HEADER BY SONUM ASCENDING.

*-- 대기/승인/반려 오더 필터링 & 아이콘/색상 세팅
    CLEAR : GS_SO_HEADER, GT_SO_PEN, GT_SO_APP, GT_SO_REJ.
    LOOP AT GT_SO_HEADER INTO GS_SO_HEADER.
      LV_TABIX = SY-TABIX.

      CASE GS_SO_HEADER-STATUS.
          " >> 결재 대기 오더
        WHEN ''.
          GS_SO_HEADER-ICON = ICON_LED_INACTIVE.

          CLEAR : GS_SO_PEN.
          MOVE-CORRESPONDING GS_SO_HEADER TO GS_SO_PEN.

          " 판매오더 생싱일로부터 5일이 지난 데이터는 빨간색으로 디스플레이(7일 이후에는 자동 반려 처리됨)
          CALL FUNCTION 'SD_DATETIME_DIFFERENCE'
            EXPORTING
              DATE1    = GS_SO_HEADER-SDATE
              TIME1    = '100000'
              DATE2    = SY-DATUM
              TIME2    = '100000'
            IMPORTING
              DATEDIFF = LV_GAP.

          IF LV_GAP > 5.
            PERFORM SET_PEN_COLOR USING : 'ICON', 'SONUM', 'SALE_ORG', 'CHANNEL',
                                          'BPCODE', 'PDATE', 'NETWR', 'WAERS', 'SDATE'.
          ENDIF.

          GS_SO_PEN-APP_BTN = '결재'.

          APPEND GS_SO_PEN TO GT_SO_PEN.
          " >> 결재 승인 오더
        WHEN 'A'.
          GS_SO_HEADER-ICON = ICON_LED_GREEN.
          APPEND GS_SO_HEADER TO GT_SO_APP.
          " >> 결재 반려 오더
        WHEN 'R'.
          GS_SO_HEADER-ICON = ICON_LED_RED.
          GS_SO_HEADER-REMARK_BTN = '반려 사유 상세'.
          APPEND GS_SO_HEADER TO GT_SO_REJ.
      ENDCASE.

      MODIFY GT_SO_HEADER FROM GS_SO_HEADER INDEX LV_TABIX TRANSPORTING ICON REMARK_BTN.
      CLEAR : GS_SO_HEADER.

    ENDLOOP.

    SORT GT_SO_PEN BY SDATE ASCENDING.

*-- 대기/승인/반려 오더 개수
    GV_PEN = LINES( GT_SO_PEN ).
    GV_APP = LINES( GT_SO_APP ).
    GV_REJ = LINES( GT_SO_REJ ).

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RANGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_RANGE .
  REFRESH : GR_CHNL, GR_BPCODE, GR_DATE.

  " 유통채널
  IF GV_CHNL_FROM IS NOT INITIAL.
    GR_CHNL-SIGN   = 'I'.
    GR_CHNL-OPTION = 'EQ'.
    GR_CHNL-LOW    = GV_CHNL_FROM.
    IF GV_CHNL_TO IS NOT INITIAL.
      GR_CHNL-OPTION = 'BT'.
      GR_CHNL-HIGH   = GV_CHNL_TO.
    ENDIF.
    APPEND GR_CHNL.
  ENDIF.

  " BP코드
  IF GV_BPCODE_FROM IS NOT INITIAL.
    GR_BPCODE-SIGN   = 'I'.
    GR_BPCODE-OPTION = 'EQ'.
    GR_BPCODE-LOW    = GV_BPCODE_FROM.
    IF GV_BPCODE_TO IS NOT INITIAL.
      GR_BPCODE-OPTION = 'BT'.
      GR_BPCODE-HIGH   = GV_BPCODE_TO.
    ENDIF.
    APPEND GR_BPCODE.
  ENDIF.

  " 판매오더 생성일
  IF GV_DATE_FROM IS NOT INITIAL.
    GR_DATE-SIGN = 'I'.
    GR_DATE-OPTION = 'EQ'.
    GR_DATE-LOW = GV_DATE_FROM.
    IF GV_DATE_TO IS NOT INITIAL.
      GR_DATE-OPTION = 'BT'.
      GR_DATE-HIGH = GV_DATE_TO.
    ENDIF.
    APPEND GR_DATE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_COLOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_PEN_COLOR  USING PV_FIELD.

  DATA : LS_SCOL  TYPE LVC_S_SCOL.

  CLEAR : LS_SCOL.
  MOVE-CORRESPONDING GS_SO_HEADER TO GS_SO_PEN.
  LS_SCOL-FNAME     = PV_FIELD.
  LS_SCOL-COLOR-COL = 6.
  LS_SCOL-NOKEYCOL  = 'X'.
  INSERT LS_SCOL INTO TABLE GS_SO_PEN-COLOR.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_BUTTON_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_COL_ID
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM HANDLE_BUTTON_CLICK  USING    PS_COL_ID TYPE LVC_S_COL
                                   PS_ROW_NO TYPE LVC_S_ROID.
*-- 해당 행 정보(판매오더 Header) 읽어옴
  CLEAR : GS_SO_PEN.
  READ TABLE GT_SO_PEN INTO GS_SO_PEN INDEX PS_ROW_NO-ROW_ID.

*-- 해당 행을 읽어오는 데 오류가 발생한 경우 에러 메시지 디스플레이
  IF SY-SUBRC <> 0.
    MESSAGE S001 WITH TEXT-E01 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  CALL SCREEN 101 STARTING AT 20 01.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPROVE_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM APPROVE_ORDER .

  DATA : LV_ANSWER,
         LV_POPUP_TEXT(30),
         LV_TABIX_H        TYPE SY-TABIX,
         LV_TABIX_I        TYPE SY-TABIX,
         LV_TABIX          TYPE SY-TABIX,
         LV_REMAIN_QTY     LIKE GS_SO_ITEM-MENGE. " 예약재고로 할당되지 않은 수량

  DATA : LS_SAVE TYPE ZC302SDT0003,
         LT_SAVE TYPE TABLE OF ZC302SDT0003.

*-- OOS인 아이템이 있는 경우 판매 오더 승인 불가
  IF GV_OOS = 'X'.
    MESSAGE I001 WITH TEXT-E02 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 승인 컨펌 팝업
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = '판매 오더 승인'
      TEXT_QUESTION         = '해당 판매 오더를 승인하시겠습니까?'
      TEXT_BUTTON_1         = '예'(001)
      ICON_BUTTON_1         = 'ICON_OKAY'
      TEXT_BUTTON_2         = '아니요'(002)
      ICON_BUTTON_2         = 'ICON_CANCEL'
      DEFAULT_BUTTON        = '1'
      DISPLAY_CANCEL_BUTTON = ' '
    IMPORTING
      ANSWER                = LV_ANSWER.

  IF LV_ANSWER <> '1'.
    EXIT.
  ENDIF.

*--------------------------------------------------------------------*
* 판매오더 헤더 내역 변경
*--------------------------------------------------------------------*
  GS_SO_PEN-STATUS = 'A'.        " 결재 상태
  GS_SO_PEN-APDATE = SY-DATUM.   " 결재 일자
  GS_SO_PEN-EMP_NUM = SY-UNAME.  " 결재자
  GS_SO_PEN-ICON  = ICON_LED_GREEN. " 결재상태

  " Timestamp
  GS_SO_PEN-AEDAT = SY-DATUM.
  GS_SO_PEN-AEZET = SY-UZEIT.
  GS_SO_PEN-AENAM = SY-UNAME.

*--------------------------------------------------------------------*
* 헤더 변경 사항 DB Table & ITAB에 반영
*--------------------------------------------------------------------*
  CLEAR : LS_SAVE, GS_SO_APP, GS_SO_HEADER.
  MOVE-CORRESPONDING GS_SO_PEN TO LS_SAVE.

  " 결재 내역 DB Table에 반영
  MODIFY ZC302SDT0003 FROM LS_SAVE.

  IF SY-SUBRC <> 0.
    MESSAGE S001 WITH TEXT-E03 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ELSE.
    MOVE-CORRESPONDING GS_SO_PEN TO GS_SO_APP.
    " 해당 데이터를 [전체] ITAB에서 수정
    READ TABLE GT_SO_HEADER INTO GS_SO_HEADER WITH KEY SONUM = GS_SO_PEN-SONUM.
    MODIFY GT_SO_HEADER FROM GS_SO_APP INDEX SY-TABIX TRANSPORTING REMARK ICON STATUS APDATE
                                                                   EMP_NUM AEDAT AEZET AENAM.
    " 해당 데이터를 [대기] ITAB에서 삭제
    DELETE GT_SO_PEN WHERE SONUM = GS_SO_PEN-SONUM.
    " 해당 데이터를 [승인] ITAB에 추가
    APPEND GS_SO_APP TO GT_SO_APP.

    "ITAB & ALV 동기화
    CALL METHOD : GO_ALV_FST->REFRESH_TABLE_DISPLAY,
                  GO_ALV_PEN->REFRESH_TABLE_DISPLAY,
                  GO_ALV_APP->REFRESH_TABLE_DISPLAY.

    " 대기 오더 수 감소 & 반려 오더 수 증가
    GV_PEN = GV_PEN - 1.
    GV_APP = GV_APP + 1.

    MESSAGE S001 WITH TEXT-S01.

    COMMIT WORK AND WAIT.
  ENDIF.

*--------------------------------------------------------------------*
* 재고관리 테이블에 예약재고 할당
*--------------------------------------------------------------------*
*-- 생성일이 오래된 재고부터 예약재고 할랑
  CLEAR : GS_DETAIL_QTY, LV_TABIX, GS_QTY.
  LOOP AT GT_SO_ITEM INTO GS_SO_ITEM. " 판매오더 아이템 루프
    LV_REMAIN_QTY = GS_SO_ITEM-MENGE. " 재고 할당이 필요한 수량

    READ TABLE GT_QTY INTO GS_QTY WITH KEY MATNR = GS_SO_ITEM-MATNR
                                           BINARY SEARCH.

    LV_TABIX_H = SY-TABIX. " 재고관리 Header에 대한 인덱스 저장

    " 해당 자재에 대한 재고가 없는 경우 에러메시지 디스플레이 후 다음 ITEM으로 이동
    IF SY-SUBRC <> 0.
      MESSAGE S001 WITH GS_SO_ITEM-MATNR TEXT-E04 DISPLAY LIKE 'E'.
      CONTINUE.
    ENDIF.

    LOOP AT GT_DETAIL_QTY INTO GS_DETAIL_QTY. " 재고관리 ITEM 라인 루프
      LV_TABIX_I = SY-TABIX.
      IF GS_SO_ITEM-MATNR = GS_DETAIL_QTY-MATNR.                             " 해당 아이템과 자재코드가 매칭 되는 재고 라인에 대해서만 로직 수행

        " 가용 재고가 없는 경우 건너뜀
        IF GS_DETAIL_QTY-AVQTY = 0.
          CONTINUE.
        ENDIF.

        IF LV_REMAIN_QTY > GS_DETAIL_QTY-AVQTY.                              " >> 해당 재고 라인의 가용재고가 부족할 때 <<
          GS_DETAIL_QTY-I_RESMAT = GS_DETAIL_QTY-I_RESMAT + GS_DETAIL_QTY-AVQTY. " Item 예약재고 : 가용재고 수량 만큼 할당
          GS_QTY-H_RESMAT = GS_QTY-H_RESMAT + GS_DETAIL_QTY-AVQTY.           " Header 예약재고 : Item 가용재고 수량 만큼 할당
          LV_REMAIN_QTY = LV_REMAIN_QTY - GS_DETAIL_QTY-AVQTY.               " 할당이 필요한 수량 : 예약재고에 할당된 수량 만큼 차감
          GS_QTY-AVQTY = GS_QTY-AVQTY - GS_DETAIL_QTY-AVQTY.                 " Header 가용재고 : 예약재고에 할당된 수량 만큼 차감
          GS_DETAIL_QTY-AVQTY = 0.                                           " Item 가용재고 : 0이 됨

        ELSE.                                                                " >> 해당 재고 라인의 가용재고가 충분할 때 <<
          GS_DETAIL_QTY-I_RESMAT = GS_DETAIL_QTY-I_RESMAT + LV_REMAIN_QTY.   " Item 예약재고 : 할당이 필요한 수량 만큼 재고 할당
          GS_QTY-H_RESMAT = GS_QTY-H_RESMAT + LV_REMAIN_QTY.                 " Header 예약재고 : 할당이 필요한 수량 만큼 재고 할당
          GS_DETAIL_QTY-AVQTY = GS_DETAIL_QTY-AVQTY - LV_REMAIN_QTY.         " Item 가용재고 : 예약재고에 할당된 수량만큼 차감
          GS_QTY-AVQTY = GS_QTY-AVQTY - LV_REMAIN_QTY.                       " Header 가용재고 : 예약재고에 할당된 수량만큼 차감
          LV_REMAIN_QTY = 0.                                                 " 할당이 필요한 수량 : 0이 됨
        ENDIF.

        " Timestamp
        GS_QTY-AEDAT = SY-DATUM.
        GS_QTY-AEZET = SY-UZEIT.
        GS_QTY-AENAM = SY-UNAME.

        GS_DETAIL_QTY-AEDAT = SY-DATUM.
        GS_DETAIL_QTY-AEZET = SY-UZEIT.
        GS_DETAIL_QTY-AENAM = SY-UNAME.

        " 변경된 예약재고, 가용재고, Timestamp ITAB에 반영(재고관리 Item)
        MODIFY GT_DETAIL_QTY FROM GS_DETAIL_QTY INDEX LV_TABIX_I TRANSPORTING I_RESMAT AVQTY AEDAT AEZET AENAM.

        IF LV_REMAIN_QTY = 0. " 할당할 수량이 남아있지 않은 경우 재고 라인 루프 탈출
          " 변경된 예약재고, 가용재고, Timestamp ITAB에 반영(재고관리 Header)
          MODIFY GT_QTY FROM GS_QTY INDEX LV_TABIX_H TRANSPORTING H_RESMAT AVQTY AEDAT AEZET AENAM.
          EXIT.
        ENDIF.

      ENDIF.
      CLEAR : GS_DETAIL_QTY.
    ENDLOOP.

    CLEAR : GS_SO_ITEM.
  ENDLOOP.

*-- 변경된 예약재고 수량 DB Table에 반영
  PERFORM SAVE_QTY_DATA.

*-- 자재코드, 생성일별 자재 ALV 리프레시
  CALL METHOD : GO_ALV_QTY_DAT->REFRESH_TABLE_DISPLAY,
                GO_ALV_QTY_MAT->REFRESH_TABLE_DISPLAY.

  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REJECT_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REJECT_ORDER .
  GV_READ_MODE = ''.
  CALL SCREEN 102 STARTING AT 50 05.
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
    CLEAR : GT_FCAT_POP, GT_FCAT_QTY_MAT, GT_FCAT_QTY_DAT, GT_SORT.
    PERFORM SET_FCAT USING : 'POP' 'X' 'SONUM' '판매주문번호' 'C' ' ' '2',  " Field Catalog for Sales Order Item
                             'POP' 'X' 'POSNR' '아이템번호'  'C' ' ' '3',
                             'POP' ' ' 'MATNR' '자재코드'   'C' ' ' '4',
                             'POP' ' ' 'MAKTX' '자재명'    ' ' 'X' '5',
                             'POP' ' ' 'MENGE' '수량'     ' ' ' ' '6',
                             'POP' ' ' 'MEINS' '단위'     'C' ' ' '7',
                             'POP' ' ' 'NETWR' '금액'     ' ' ' ' '8',
                             'POP' ' ' 'WAERS' '통화'     'C' ' ' '9',
                             'POP' ' ' 'ICON'  '가용여부'   'C' ' ' '1',

                             'QTY_MAT' 'X' 'MATNR'     '자재코드' 'C' ' ' ' ',
                             'QTY_MAT' ' ' 'H_RTPTQUA' '현재재고' ' ' ' ' ' ',
                             'QTY_MAT' ' ' 'H_RESMAT'  '예약재고' ' ' ' ' ' ',
                             'QTY_MAT' ' ' 'AVQTY'     '가용재고' ' ' 'X' ' ',
                             'QTY_MAT' ' ' 'MEINS'     '단위' 'C' ' ' ' ',

                             'QTY_DAT' 'X' 'MATNR'     '자재코드' 'C' ' ' ' ',
                             'QTY_DAT' 'X' 'BDATU'     '생성일' 'C' ' ' ' ',
                             'QTY_DAT' ' ' 'I_RTPTQUA' '현재재고' ' ' ' ' ' ',
                             'QTY_DAT' ' ' 'I_RESMAT'  '예약재고' ' ' ' ' ' ',
                             'QTY_DAT' ' ' 'AVQTY'     '가용재고' ' ' 'X' ' ',
                             'QTY_DAT' ' ' 'MEINS'     '단위' 'C' ' ' ' '.

    PERFORM SET_LAYOUT.
    GS_LAYOUT-GRID_TITLE = '판매오더 Item'.
    GS_LAYOUT-SMALLTITLE = ABAP_TRUE.

    PERFORM SET_QTY_LAYOUT.

    PERFORM SET_SORTING.

    PERFORM CREATE_OBJECT USING : GO_CONT_POP GO_ALV_POP 'POP_CONT'.

    PERFORM CREATE_QTY_OBJECT.

    PERFORM SET_FIRST_DISPLAY USING : GO_ALV_POP GT_SO_ITEM GT_FCAT_POP GS_LAYOUT,
                                      GO_ALV_QTY_MAT GT_QTY GT_FCAT_QTY_MAT GS_LAYOUT_QTY_MAT.

    PERFORM SET_FIRST_DISPLAY_WITH_SORTING USING GO_ALV_QTY_DAT GT_DETAIL_QTY
                                                 GT_FCAT_QTY_DAT GS_LAYOUT_QTY_DAT
                                                 GT_SORT.

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
  SET HANDLER : LCL_EVENT_HANDLER=>BUTTON_CLICK FOR GO_ALV_PEN,
                LCL_EVENT_HANDLER=>HOTSPOT_CLICK_FST FOR GO_ALV_FST,
                LCL_EVENT_HANDLER=>HOTSPOT_CLICK_APP FOR GO_ALV_APP,
                LCL_EVENT_HANDLER=>HOTSPOT_CLICK_REJ FOR GO_ALV_REJ,
                LCL_EVENT_HANDLER=>BUTTON_CLICK_REMARK_FST FOR GO_ALV_FST,
                LCL_EVENT_HANDLER=>BUTTON_CLICK_REMARK_REJ FOR GO_ALV_REJ.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_SCREEN_102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_SCREEN_102 .
  IF GO_CONT_TE IS NOT BOUND.
    PERFORM CREATE_OBJECT_102.
  ENDIF.
  PERFORM SET_TEXT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT_102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT_102 .

*-- Container
  CREATE OBJECT GO_CONT_TE
    EXPORTING
      CONTAINER_NAME = 'TEXT_CONT'.

*-- Text Editor
  CREATE OBJECT GO_TEXT_EDIT
    EXPORTING
      WORDWRAP_MODE = CL_GUI_TEXTEDIT=>WORDWRAP_AT_WINDOWBORDER
      PARENT        = GO_CONT_TE.

*-- Textedit Toolbar
  CALL METHOD GO_TEXT_EDIT->SET_TOOLBAR_MODE
    EXPORTING
      TOOLBAR_MODE = GO_TEXT_EDIT->FALSE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0102 INPUT.
  CASE GV_OKCODE.
    WHEN 'REJT'.
      PERFORM CONFIRM_REJECT_ORDER.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form CONFIRM_REJECT_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CONFIRM_REJECT_ORDER .
  DATA : LS_SAVE      TYPE ZC302SDT0003,
         LV_ANSWER(1).

*-- Text Editor로부터 반려 사유 읽어오기
  CLEAR : GS_CONTENT, GT_CONTENT.
  CALL METHOD GO_TEXT_EDIT->GET_TEXT_AS_R3TABLE
    IMPORTING
      TABLE                  = GT_CONTENT
    EXCEPTIONS
      ERROR_DP               = 1
      ERROR_CNTL_CALL_METHOD = 2
      ERROR_DP_CREATE        = 3
      POTENTIAL_DATA_LOSS    = 4
      OTHERS                 = 5.

*-- 반려 사유가 입력되지 않은 경우 에러 메시지 디스플레이
  IF GT_CONTENT IS INITIAL.
    MESSAGE S001 WITH TEXT-E05 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 승인 반려 팝업
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = '판매 오더 반려'
      TEXT_QUESTION         = '해당 판매 오더를 반려하시겠습니까?'
      TEXT_BUTTON_1         = '예'(001)
      ICON_BUTTON_1         = 'ICON_OKAY'
      TEXT_BUTTON_2         = '아니요'(002)
      ICON_BUTTON_2         = 'ICON_CANCEL'
      DEFAULT_BUTTON        = '1'
      DISPLAY_CANCEL_BUTTON = ' '
    IMPORTING
      ANSWER                = LV_ANSWER.

  IF LV_ANSWER <> '1'.
    EXIT.
  ENDIF.

*--------------------------------------------------------------------*
* 판매오더 헤더 내역 변경
*--------------------------------------------------------------------*
*-- 입력 받은 반려 사유 판매오더 헤더에 입력
  CLEAR : GS_CONTENT.
  LOOP AT GT_CONTENT INTO GS_CONTENT.
    CONCATENATE GS_SO_PEN-REMARK GS_CONTENT-TDLINE
                CL_ABAP_CHAR_UTILITIES=>NEWLINE INTO GS_SO_PEN-REMARK.
    CLEAR : GS_CONTENT.
  ENDLOOP.

*-- 판매오더 내역 변경
  GS_SO_PEN-STATUS = 'R'.        " 결재 상태
  GS_SO_PEN-APDATE = SY-DATUM.   " 결재 일자
  GS_SO_PEN-EMP_NUM = SY-UNAME." 결재자
  " 타임스탬프
  GS_SO_PEN-AEDAT = SY-DATUM.
  GS_SO_PEN-AEZET = SY-UZEIT.
  GS_SO_PEN-AENAM = SY-UNAME.
  GS_SO_PEN-ICON  = ICON_LED_RED.

*--------------------------------------------------------------------*
* 변경 사항 DB Table & ITAB에 반영
*--------------------------------------------------------------------*
  CLEAR : GS_SO_REJ.
  MOVE-CORRESPONDING GS_SO_PEN TO LS_SAVE.
  " 결재 내역 DB Table에 반영
  MODIFY ZC302SDT0003 FROM LS_SAVE.

  IF SY-SUBRC <> 0.
    MESSAGE S001 WITH TEXT-E03 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ELSE.
    MOVE-CORRESPONDING GS_SO_PEN TO GS_SO_REJ.
    GS_SO_REJ-REMARK_BTN = '반려 사유 상세'.
    " 해당 데이터를 [전체] ITAB에서 수정
    READ TABLE GT_SO_HEADER INTO GS_SO_HEADER WITH KEY SONUM = GS_SO_REJ-SONUM.
    MODIFY GT_SO_HEADER FROM GS_SO_REJ INDEX SY-TABIX TRANSPORTING REMARK ICON STATUS APDATE EMP_NUM
                                                                   AEDAT AEZET AENAM REMARK_BTN.
    " 해당 데이터를 [대기] ITAB에서 삭제
    DELETE GT_SO_PEN WHERE SONUM = GS_SO_PEN-SONUM.
    " 해당 데이터를 [반려] ITAB에 추가
    APPEND GS_SO_REJ TO GT_SO_REJ.

    "ITAB & ALV 동기화
    CALL METHOD : GO_ALV_FST->REFRESH_TABLE_DISPLAY,
                  GO_ALV_PEN->REFRESH_TABLE_DISPLAY,
                  GO_ALV_REJ->REFRESH_TABLE_DISPLAY.

    " Text Editor 내용 초기화
    CALL METHOD GO_TEXT_EDIT->DELETE_TEXT.

    " 대기 오더 수 감소 & 반려 오더 수 증가
    GV_PEN = GV_PEN - 1.
    GV_REJ = GV_REJ + 1.

    MESSAGE S001 WITH TEXT-S02.

    COMMIT WORK AND WAIT.

    " 반려 완료 여부 저장(팝업창 닫기 위함)
    GV_CLOSE_OPT = 'X'.

    CALL METHOD : GO_TEXT_EDIT->FREE,
                GO_CONT_TE->FREE.

    FREE : GO_TEXT_EDIT, GO_CONT_TE.

    LEAVE TO SCREEN 0.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEARCH_SO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEARCH_SO .
  CLEAR : GT_SO_HEADER, GS_SO_HEADER, GT_SO_PEN, GS_SO_PEN,
          GT_SO_APP, GS_SO_APP, GT_SO_REJ, GS_SO_REJ.

  PERFORM SET_RANGE.
  PERFORM GET_SO_DATA.

  CALL METHOD : GO_ALV_FST->REFRESH_TABLE_DISPLAY,
              GO_ALV_PEN->REFRESH_TABLE_DISPLAY,
              GO_ALV_REJ->REFRESH_TABLE_DISPLAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_BP_F4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_BP_F4 .
  DATA : LT_RETURN TYPE TABLE OF DDSHRETVAL WITH HEADER LINE.

*-- Execute Search Help(F4)
  REFRESH LT_RETURN.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'BPCODE'
      DYNPPROG        = SY-REPID
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'GV_BPCODE'
      WINDOW_TITLE    = 'Distribution channel'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = GT_BP_F4
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
ENDFORM.
*&---------------------------------------------------------------------*
*& Module GET_DISPLAY_DATA OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE GET_DISPLAY_DATA OUTPUT.
  PERFORM GET_ITEM_AND_QTY.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form GET_ITEM_QTY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ITEM_AND_QTY .
  DATA : LV_TABIX TYPE SY-TABIX.

  CLEAR : GV_OOS, GV_CLOSE_OPT. " OOS 상태 & 반려 완료 여부 초기화

*-- 선택한 판매오더의 아이템 리스트 Select
  CLEAR : GT_SO_ITEM, GS_SO_ITEM.
  SELECT SONUM POSNR A~MATNR MAKTX MENGE MEINS A~NETWR A~WAERS
    INTO CORRESPONDING FIELDS OF TABLE GT_SO_ITEM
    FROM ZC302SDT0004 AS A
      INNER JOIN ZC302MT0007 AS B
      ON A~MATNR = B~MATNR
    WHERE SONUM = GS_SO_PEN-SONUM.

  IF GT_SO_ITEM IS INITIAL.
    MESSAGE S001 WITH TEXT-E01 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  SORT GT_SO_ITEM BY SONUM POSNR ASCENDING.

*– 판매오더 아이템에 대한 재고 데이터 Select
  " 재고관리 Header 데이터 SELECT
  CLEAR : GT_DETAIL_QTY, GS_DETAIL_QTY, GT_QTY, GS_QTY.
  SELECT MATNR SCODE SNAME ADDRESS MAKTX MTART
         H_RTPTQUA H_RESMAT MEINS
         ERDAT ERZET ERNAM AEDAT AEZET AENAM
  INTO CORRESPONDING FIELDS OF TABLE GT_QTY
  FROM ZC302MMT0013
  FOR ALL ENTRIES IN GT_SO_ITEM
  WHERE MATNR = GT_SO_ITEM-MATNR
  AND SCODE = 'ST05'.

  SORT GT_QTY BY MATNR ASCENDING.

  " 재고관리 Item 데이터 SELECT
  SELECT MATNR SCODE BDATU SNAME MAKTX MBLNR
         MTART I_RTPTQUA I_RESMAT MEINS
         ERDAT ERZET ERNAM AEDAT AEZET AENAM
  INTO CORRESPONDING FIELDS OF TABLE GT_DETAIL_QTY
  FROM ZC302MMT0002
  FOR ALL ENTRIES IN GT_SO_ITEM
  WHERE MATNR = GT_SO_ITEM-MATNR
    AND SCODE = 'ST05'
    AND I_RTPTQUA <> 0. " 재고가 0이 아닌 경우

  SORT GT_DETAIL_QTY BY MATNR BDATU ASCENDING.

*-- 판매 오더 Header 가용 재고 계산 : 현재재고 - 예약재고
  CLEAR : LV_TABIX, GS_QTY.
  LOOP AT GT_QTY INTO GS_QTY.
    LV_TABIX = SY-TABIX.

    " 자재코드 별 가용재고 계산
    GS_QTY-AVQTY = GS_QTY-H_RTPTQUA - GS_QTY-H_RESMAT.

    MODIFY GT_QTY FROM GS_QTY INDEX LV_TABIX TRANSPORTING AVQTY.

    CLEAR : GS_QTY.
  ENDLOOP.

*-- 판매 오더 Item 가용 재고 계산 : 현재재고 - 예약재고
  CLEAR : LV_TABIX, GS_DETAIL_QTY.
  LOOP AT GT_DETAIL_QTY INTO GS_DETAIL_QTY.
    LV_TABIX = SY-TABIX.

    "자재코드, 생성일 별 가용재고 계산
    GS_DETAIL_QTY-AVQTY = GS_DETAIL_QTY-I_RTPTQUA - GS_DETAIL_QTY-I_RESMAT.

    MODIFY GT_DETAIL_QTY FROM GS_DETAIL_QTY INDEX LV_TABIX TRANSPORTING AVQTY.

    CLEAR : GS_DETAIL_QTY.
  ENDLOOP.



*-- 판매오더 아이템별 가용 재고에 따른 재고 상태 세팅
  CLEAR : GS_SO_ITEM, LV_TABIX.
  LOOP AT GT_SO_ITEM INTO GS_SO_ITEM.
    LV_TABIX = SY-TABIX.

    CLEAR : GS_QTY.
    READ TABLE GT_QTY INTO GS_QTY WITH KEY MATNR = GS_SO_ITEM-MATNR
                                           BINARY SEARCH.

    " 재고 가용 상태 체크
    IF GS_SO_ITEM-MENGE > GS_QTY-AVQTY.
      GS_SO_ITEM-ICON = ICON_LED_RED.
      IF GV_OOS IS INITIAL.
        GV_OOS = 'X'. " 00S 여부 변경
      ENDIF.
    ELSE.
      GS_SO_ITEM-ICON = ICON_LED_GREEN. " 재고 가용
    ENDIF.

    MODIFY GT_SO_ITEM FROM GS_SO_ITEM INDEX LV_TABIX TRANSPORTING ICON.
    CLEAR : GS_SO_ITEM.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_QTY_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_QTY_LAYOUT .
  CLEAR : GS_LAYOUT_QTY_MAT, GS_LAYOUT_QTY_DAT.

  GS_LAYOUT_QTY_MAT-ZEBRA      = ABAP_TRUE.
  GS_LAYOUT_QTY_MAT-SEL_MODE   = 'D'.
  GS_LAYOUT_QTY_MAT-CWIDTH_OPT = 'A'.
  GS_LAYOUT_QTY_MAT-NO_TOOLBAR = ABAP_TRUE.
  GS_LAYOUT_QTY_MAT-GRID_TITLE = '자재별 재고 현황'.
  GS_LAYOUT_QTY_MAT-SMALLTITLE = ABAP_TRUE.

  GS_LAYOUT_QTY_DAT-ZEBRA      = ABAP_TRUE.
  GS_LAYOUT_QTY_DAT-SEL_MODE   = 'D'.
  GS_LAYOUT_QTY_DAT-CWIDTH_OPT = 'A'.
  GS_LAYOUT_QTY_DAT-NO_TOOLBAR = ABAP_TRUE.
  GS_LAYOUT_QTY_DAT-GRID_TITLE = '자재 & 생성일별 재고 현황'.
  GS_LAYOUT_QTY_DAT-SMALLTITLE = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_QTY_OBJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_QTY_OBJECT .

*-- Main Container
  CREATE OBJECT GO_CONT_QTY
    EXPORTING
      CONTAINER_NAME = 'QTY_CONT'.

*-- Splitter Container
  CREATE OBJECT GO_SPLIT_CONT
    EXPORTING
      PARENT  = GO_CONT_QTY
      ROWS    = 2
      COLUMNS = 1.

*-- Up Container
  CALL METHOD GO_SPLIT_CONT->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONT_QTY_MAT.

*-- Bottom Container
  CALL METHOD GO_SPLIT_CONT->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONT_QTY_DAT.

*-- Up ALV Grid
  CREATE OBJECT GO_ALV_QTY_MAT
    EXPORTING
      I_PARENT = GO_CONT_QTY_MAT.

*-- Buttom ALV Grid
  CREATE OBJECT GO_ALV_QTY_DAT
    EXPORTING
      I_PARENT = GO_CONT_QTY_DAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTING .
*-- 자재코드, 생성일로 정렬
  CLEAR : GS_SORT.
  GS_SORT-SPOS      = 1.
  GS_SORT-FIELDNAME = 'MATNR'.
  GS_SORT-UP        = 'X'.
  APPEND GS_SORT TO GT_SORT.

  CLEAR : GS_SORT.
  GS_SORT-SPOS      = 1.
  GS_SORT-FIELDNAME = 'BDATU'.
  GS_SORT-UP        = 'X'.
  APPEND GS_SORT TO GT_SORT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIRST_DISPLAY_WITH_SORTING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_ALV_QTY_DAT
*&      --> GT_DETAIL_QTY
*&      --> GT_FCAT_QTY_DAT
*&      --> GS_LAYOUT_QTY_DAT
*&---------------------------------------------------------------------*
FORM SET_FIRST_DISPLAY_WITH_SORTING  USING PO_ALV TYPE REF TO CL_GUI_ALV_GRID
                                           PT_SO_DATA
                                           PT_FCAT
                                           PS_LAYOUT
                                           PT_SORT.

  CALL METHOD PO_ALV->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      I_SAVE          = 'A'
      I_DEFAULT       = 'X'
      IS_LAYOUT       = PS_LAYOUT
    CHANGING
      IT_OUTTAB       = PT_SO_DATA
      IT_FIELDCATALOG = PT_FCAT
      IT_SORT         = PT_SORT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_QTY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_QTY_DATA .
  DATA : LS_SAVE_I TYPE ZC302MMT0002,
         LT_SAVE_I TYPE TABLE OF ZC302MMT0002,
         LS_SAVE_H TYPE ZC302MMT0013,
         LT_SAVE_H TYPE TABLE OF ZC302MMT0013.

  MOVE-CORRESPONDING GT_QTY TO LT_SAVE_H.
  MOVE-CORRESPONDING GT_DETAIL_QTY TO LT_SAVE_I.

  MODIFY ZC302MMT0013 FROM TABLE LT_SAVE_H.
  MODIFY ZC302MMT0002 FROM TABLE LT_SAVE_I.

  IF SY-SUBRC = 0.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE S001 WITH TEXT-E06 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module GET_SO_DETAIL OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE GET_SO_DETAIL OUTPUT.
  PERFORM GET_SO_DETAIL.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form GET_SO_DETAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SO_DETAIL .
*-- 선택한 판매오더의 아이템 리스트 Select
  CLEAR : GT_SO_ITEM, GS_SO_ITEM.
  SELECT SONUM POSNR A~MATNR MAKTX MENGE MEINS A~NETWR A~WAERS
    INTO CORRESPONDING FIELDS OF TABLE GT_SO_ITEM
    FROM ZC302SDT0004 AS A
      INNER JOIN ZC302MT0007 AS B
      ON A~MATNR = B~MATNR
    WHERE SONUM = GS_SO_HEADER-SONUM.

  IF GT_SO_ITEM IS INITIAL.
    MESSAGE S001 WITH TEXT-E01 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  SORT GT_SO_ITEM BY SONUM POSNR ASCENDING.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_SCREEN_103
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_SCREEN_103 .
  IF GO_CONT_DETAIL IS NOT BOUND.
    CLEAR : GT_FCAT_DETAIL.
    PERFORM SET_FCAT USING : 'DETAIL' 'X' 'SONUM' '판매주문번호' 'C' ' ' ' ',  " Field Catalog for Sales Order Item
                             'DETAIL' 'X' 'POSNR' '아이템번호'  'C' ' ' ' ',
                             'DETAIL' ' ' 'MATNR' '자재코드'   'C' ' ' ' ',
                             'DETAIL' ' ' 'MAKTX' '자재명'    ' ' 'X' ' ',
                             'DETAIL' ' ' 'MENGE' '수량'     ' ' ' ' ' ',
                             'DETAIL' ' ' 'MEINS' '단위'     'C' ' ' ' ',
                             'DETAIL' ' ' 'NETWR' '금액'     ' ' ' ' ' ',
                             'DETAIL' ' ' 'WAERS' '통화'     'C' ' ' ' '.

    PERFORM SET_LAYOUT.
    GS_LAYOUT-GRID_TITLE = '판매오더 Item'.
    GS_LAYOUT-SMALLTITLE = ABAP_TRUE.

    PERFORM CREATE_OBJECT USING : GO_CONT_DETAIL GO_ALV_DETAIL 'DETAIL_CONT'.


    PERFORM SET_FIRST_DISPLAY USING : GO_ALV_DETAIL GT_SO_ITEM GT_FCAT_DETAIL GS_LAYOUT.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&---------------------------------------------------------------------*
FORM HANDLE_HOTSPOT_CLICK  USING  PT_HEADER LIKE GT_SO_HEADER
                                  PS_HEADER
                                  PV_ROW_ID
                                  PV_COLUMN_ID.

*-- 해당 행 정보(판매오더 Header) 읽어옴
  CLEAR : PS_HEADER.
  READ TABLE PT_HEADER INTO PS_HEADER INDEX PV_ROW_ID.
  MOVE-CORRESPONDING PS_HEADER TO GS_SO_HEADER.

*-- 해당 행을 읽어오는 데 오류가 발생한 경우 에러 메시지 디스플레이
  IF SY-SUBRC <> 0.
    MESSAGE S001 WITH TEXT-E01 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  CALL SCREEN 103 STARTING AT 30 01.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_BUTTON_CLICK_REMARK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ES_COL_ID
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM HANDLE_BUTTON_CLICK_REMARK  USING PS_COL_ID TYPE LVC_S_COL
                                       PS_ROW_NO TYPE LVC_S_ROID
                                       PV_GUBUN.

*-- 클릭된 판매오더 헤더를 읽어옴
  CASE PV_GUBUN.
    WHEN 'FST'.
      CLEAR : GS_SO_HEADER.
      READ TABLE GT_SO_HEADER INTO GS_SO_HEADER INDEX PS_ROW_NO-ROW_ID.

      IF GS_SO_HEADER-REMARK IS INITIAL.
        EXIT.
      ENDIF.

    WHEN 'REJ'.
      CLEAR : GS_SO_REJ.
      READ TABLE GT_SO_REJ INTO GS_SO_REJ INDEX PS_ROW_NO-ROW_ID.

      IF GS_SO_REJ-REMARK IS INITIAL.
        EXIT.
      ENDIF.
  ENDCASE.


*-- 반려사유가 있는 경우 Text Editor로 디스플레이
  GV_READ_MODE = 'X'.
  GV_GUBUN = PV_GUBUN.
  CALL SCREEN 102 STARTING AT 30 2.

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

*-- Read/Edit Mode
  IF GV_READ_MODE = 'X'. " Read Mode
    " 반려 사유 텍스트 불러오기, 줄바꿈 기호를 기준으로 단어 분리
    CLEAR : GT_CONTENT.
    CASE GV_GUBUN.
      WHEN 'FST'.
        SPLIT GS_SO_HEADER-REMARK AT CL_ABAP_CHAR_UTILITIES=>NEWLINE
                             INTO TABLE GT_CONTENT.
      WHEN 'REJ'.
        SPLIT GS_SO_REJ-REMARK AT CL_ABAP_CHAR_UTILITIES=>NEWLINE
                                 INTO TABLE GT_CONTENT.
    ENDCASE.

*-- 자동 들여쓰기
    CALL METHOD GO_TEXT_EDIT->SET_AUTOINDENT_MODE
      EXPORTING
        AUTO_INDENT            = 1
      EXCEPTIONS
        ERROR_CNTL_CALL_METHOD = 1
        OTHERS                 = 2.

*-- 기존 작성된 내용 삭제
    CALL METHOD GO_TEXT_EDIT->DELETE_TEXT.

*-- Set text to Editor
    CALL METHOD GO_TEXT_EDIT->SET_SELECTED_TEXT_AS_R3TABLE
      EXPORTING
        TABLE           = GT_CONTENT
      EXCEPTIONS
        ERROR_DP        = 1
        ERROR_DP_CREATE = 2
        OTHERS          = 3.

    CALL METHOD GO_TEXT_EDIT->SET_READONLY_MODE
      EXPORTING
        READONLY_MODE = GO_TEXT_EDIT->TRUE.
  ELSE.
*-- 기존 작성된 내용 삭제
    CALL METHOD GO_TEXT_EDIT->DELETE_TEXT.

    CALL METHOD GO_TEXT_EDIT->SET_READONLY_MODE
      EXPORTING
        READONLY_MODE = GO_TEXT_EDIT->FALSE.
  ENDIF.

ENDFORM.
