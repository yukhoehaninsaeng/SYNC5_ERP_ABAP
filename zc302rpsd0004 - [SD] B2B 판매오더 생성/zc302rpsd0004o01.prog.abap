*&---------------------------------------------------------------------*
*& Include          ZC302RPSD0004O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  DATA : BEGIN OF LT_MENU OCCURS 0,
           OKCODE(10),
         END OF LT_MENU.

*-- 판매오더가 생성된 후에는 저장 버튼 비활성화됨
  IF GV_IS_SAVE = 'X'.
    LT_MENU-OKCODE = 'SAVE'.
    APPEND LT_MENU.
  ENDIF.

  SET PF-STATUS 'MENU100' EXCLUDING LT_MENU.
  SET TITLEBAR 'TITLE100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_PROCESS_CONTROL OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_PROCESS_CONTROL OUTPUT.
  DATA : LS_VARIANT TYPE DISVARIANT.

  IF GO_CONT_ITEM IS NOT BOUND.

    CLEAR : GT_FCAT_ITEM.
    PERFORM SET_FCAT USING : 'ITEM' 'X' 'SONUM' '판매주문번호' 'C' ' ',
                             'ITEM' 'X' 'MATNR' '자재코드'   ' ' ' ',
                             'ITEM' ' ' 'MAKTX' '자재명'    ' ' ' ',
                             'ITEM' ' ' 'MENGE' '수량'     ' ' ' ' ,
                             'ITEM' ' ' 'MEINS' '단위'     ' ' ' ',
                             'ITEM' ' ' 'NETWR' '금액'     ' ' ' ',
                             'ITEM' ' ' 'WAERS' '통화'     ' ' ' ',
                             'ITEM' ' ' 'BTN'   '삭제'     'C' ' '.
    PERFORM SET_LAYOUT.
    GS_LAYOUT-GRID_TITLE = '판매오더 Item'.
    GS_LAYOUT-SMALLTITLE = ABAP_TRUE.

    PERFORM CREATE_OBJECT USING GO_CONT_ITEM GO_ALV_ITEM 'ITEM_CONT'.

    PERFORM REGISTER_EVENT. " 이벤트 등록

    PERFORM REGISTER_F4. " Search Help(F4) 설치

    PERFORM EXCLUDE_BUTTON TABLES GT_UI_FUNCTIONS.

    LS_VARIANT-REPORT = SY-REPID.
    LS_VARIANT-HANDLE = 'ALV1'.

    CALL METHOD GO_ALV_ITEM->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_VARIANT                    = LS_VARIANT
        I_SAVE                        = 'A'
        I_DEFAULT                     = 'X'
        IS_LAYOUT                     = GS_LAYOUT
        IT_TOOLBAR_EXCLUDING          = GT_UI_FUNCTIONS
      CHANGING
        IT_OUTTAB                     = GT_ITEM
        IT_FIELDCATALOG               = GT_FCAT_ITEM.

    CALL METHOD GO_ALV_ITEM->SET_READY_FOR_INPUT
      EXPORTING
        I_READY_FOR_INPUT = 1.

    CALL METHOD GO_ALV_ITEM->REGISTER_EDIT_EVENT
      EXPORTING
        I_EVENT_ID = GO_ALV_ITEM->MC_EVT_MODIFIED.

    " 판매오더 아이템 초기화 : 사용자가 입력한 아이템 개수만큼 행 확보
    DO P_INUM TIMES.
      PERFORM INSERT_ITEM.
    ENDDO.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  CLEAR : LT_MENU.
  IF GV_IS_SAVE = 'X'.
    LT_MENU-OKCODE = 'SAVE'.
    APPEND LT_MENU.
  ENDIF.

  SET PF-STATUS 'MENU200' EXCLUDING LT_MENU.
  SET TITLEBAR 'TITLE200'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_PROCESS_CONTROL_200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_PROCESS_CONTROL_200 OUTPUT.

  IF GO_CONT_PREV IS NOT BOUND.
    CLEAR : GT_FCAT_PREV.
    PERFORM SET_FCAT USING : 'PREV' ' ' 'SORG'   '영업 조직' 'C' 'X',
                             'PREV' ' ' 'CHNL'   '유통 채널' 'C' 'X',
                             'PREV' ' ' 'BPCODE' 'BP 코드' 'C' 'X',
                             'PREV' ' ' 'PDATE'  '주문 일자' 'C' 'X',
                             'PREV' ' ' 'MATNR'  '자재코드'  'C' ' ',
                             'PREV' ' ' 'MENGE'  '수량'    ' ' ' ',
                             'PREV' ' ' 'MEINS'  '단위'    ' ' ' '.

    PERFORM CREATE_OBJECT USING GO_CONT_PREV GO_ALV_PREV 'PREV_CONT'.

    PERFORM SET_LAYOUT.
    GS_LAYOUT-GRID_TITLE = '업로드 데이터 미리보기'.
    GS_LAYOUT-SMALLTITLE = ABAP_TRUE.
    GS_LAYOUT-NO_TOOLBAR = ABAP_TRUE.

    PERFORM REGISTER_EVENT_200.

    LS_VARIANT-REPORT = SY-REPID.
    LS_VARIANT-HANDLE = 'ALV2'.

    CALL METHOD GO_ALV_PREV->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_VARIANT                    = LS_VARIANT
        I_SAVE                        = 'A'
        I_DEFAULT                     = 'X'
        IS_LAYOUT                     = GS_LAYOUT
      CHANGING
        IT_OUTTAB                     = GT_EXCEL
        IT_FIELDCATALOG               = GT_FCAT_PREV.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0101 OUTPUT.
  SET PF-STATUS 'MENU101'.
  SET TITLEBAR 'TITLE101'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_PROCESS_CONTROL_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_PROCESS_CONTROL_0101 OUTPUT.
  PERFORM SET_MAKTX.
  PERFORM DISPLAY_SO_SCREEN.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module GET_PREVIOUS_SO OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE GET_PREVIOUS_SO OUTPUT.
  PERFORM GET_PRE_SO.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_PROCESS_CONTROL_400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_PROCESS_CONTROL_300 OUTPUT.
  PERFORM DISPLAY_SCREEN_300.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.
  SET PF-STATUS 'MENU300'.
  SET TITLEBAR 'TITLE300'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0102 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0102 OUTPUT.
  SET PF-STATUS 'MENU102'.
  SET TITLEBAR 'TITLE102'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_PROCESS_CONTROL_0102 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_PROCESS_CONTROL_0102 OUTPUT.
  PERFORM DISPLAY_REASON_POPUP.
  PERFORM SET_TEXT.
ENDMODULE.
