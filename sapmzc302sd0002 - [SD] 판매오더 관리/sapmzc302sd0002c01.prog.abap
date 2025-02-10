*&---------------------------------------------------------------------*
*& Include          SAPMZC302SD0002C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION FINAL.

  PUBLIC SECTION.
*-- [대기] 탭에서 결재 버튼 클릭 시 발생하는 이벤트
    CLASS-METHODS BUTTON_CLICK FOR EVENT BUTTON_CLICK OF CL_GUI_ALV_GRID
      IMPORTING ES_COL_ID ES_ROW_NO.
*-- [전체] 탭에서 판매주문번호 핫스팟 클릭 시 발생하는 이벤트
    CLASS-METHODS HOTSPOT_CLICK_FST FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID E_COLUMN_ID.
*-- [승인] 탭에서 판매주문번호 핫스팟 클릭 시 발생하는 이벤트
    CLASS-METHODS HOTSPOT_CLICK_APP FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID E_COLUMN_ID.
*-- [반려] 탭에서 판매주문번호 핫스팟 클릭 시 발생하는 이벤트
    CLASS-METHODS HOTSPOT_CLICK_REJ FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID E_COLUMN_ID.
*-- [전체] 탭에서 반려 사유 버튼 클릭 시 발생하는 이벤트
    CLASS-METHODS BUTTON_CLICK_REMARK_FST FOR EVENT BUTTON_CLICK OF CL_GUI_ALV_GRID
      IMPORTING ES_COL_ID ES_ROW_NO.
*-- [반려] 탭에서 반려 사유 버튼 클릭 시 발생하는 이벤트
    CLASS-METHODS BUTTON_CLICK_REMARK_REJ FOR EVENT BUTTON_CLICK OF CL_GUI_ALV_GRID
      IMPORTING ES_COL_ID ES_ROW_NO.

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.

  METHOD BUTTON_CLICK.
    PERFORM HANDLE_BUTTON_CLICK USING ES_COL_ID ES_ROW_NO.
  ENDMETHOD.

  METHOD HOTSPOT_CLICK_FST.
    PERFORM HANDLE_HOTSPOT_CLICK USING GT_SO_HEADER GS_SO_HEADER E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.

  METHOD HOTSPOT_CLICK_APP.
    PERFORM HANDLE_HOTSPOT_CLICK USING GT_SO_APP GS_SO_APP E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.

  METHOD HOTSPOT_CLICK_REJ.
    PERFORM HANDLE_HOTSPOT_CLICK USING GT_SO_REJ GS_SO_REJ E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.

  METHOD BUTTON_CLICK_REMARK_FST.
    PERFORM HANDLE_BUTTON_CLICK_REMARK USING ES_COL_ID ES_ROW_NO 'FST'.
  ENDMETHOD.

  METHOD BUTTON_CLICK_REMARK_REJ.
    PERFORM HANDLE_BUTTON_CLICK_REMARK USING ES_COL_ID ES_ROW_NO 'REJ'.
  ENDMETHOD.

ENDCLASS.
