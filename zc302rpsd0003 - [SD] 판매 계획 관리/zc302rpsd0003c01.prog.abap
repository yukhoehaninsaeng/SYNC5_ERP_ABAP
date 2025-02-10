*&---------------------------------------------------------------------*
*& Include          ZC302RPSD0003C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS HOTSPOT_CLICK FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID E_COLUMN_ID.

    CLASS-METHODS DOUBLE_CLICK FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW E_COLUMN.

    CLASS-METHODS : TOOLBAR FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
      IMPORTING E_OBJECT E_INTERACTIVE.

    CLASS-METHODS USER_COMMAND FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING E_UCOMM.

    CLASS-METHODS : TOP_OF_PAGE FOR EVENT TOP_OF_PAGE OF CL_GUI_ALV_GRID
      IMPORTING E_DYNDOC_ID.

    CLASS-METHODS BUTTON_CLICK FOR EVENT BUTTON_CLICK OF CL_GUI_ALV_GRID
      IMPORTING ES_COL_ID ES_ROW_NO.

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.
  METHOD HOTSPOT_CLICK.
    " 클릭한 판매계획번호에 대한 아이템 정보 디스플레이
    PERFORM HANDLE_HOTSPOT_CLICK USING E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.

  METHOD DOUBLE_CLICK.
    " 더블클릭한 아이템에 대한 수정 팝업 디스플레이
    PERFORM HANDLE_DOUBLE_CLICK USING E_ROW E_COLUMN.
  ENDMETHOD.

  METHOD TOOLBAR.
    " ALV Toolbar에 아이템 추가/삭제 버튼
    PERFORM HANDLE_TOOLBAR USING E_OBJECT E_INTERACTIVE.
  ENDMETHOD.

  METHOD USER_COMMAND.
    " ALV Toolbar 이벤트 구현
    PERFORM HANDLE_USER_COMMAND USING E_UCOMM.
  ENDMETHOD.

  METHOD TOP_OF_PAGE.
    " Top of Page
    PERFORM EVENT_TOP_OF_PAGE.
  ENDMETHOD.

  METHOD BUTTON_CLICK.
    " 수정 버튼 이벤트 구현
    PERFORM HANDLE_BUTTON_CLICK USING ES_COL_ID ES_ROW_NO.
  ENDMETHOD.

ENDCLASS.
