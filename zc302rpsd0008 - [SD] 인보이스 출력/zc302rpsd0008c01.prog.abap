*&---------------------------------------------------------------------*
*& Include          ZC302RPSD0008C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS : TOP_OF_PAGE FOR EVENT TOP_OF_PAGE OF CL_GUI_ALV_GRID
      IMPORTING E_DYNDOC_ID.

    CLASS-METHODS : HOTSPOT_CLICK FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID E_COLUMN_ID.

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.
  METHOD TOP_OF_PAGE.
    PERFORM EVENT_TOP_OF_PAGE.
  ENDMETHOD.

  METHOD HOTSPOT_CLICK.
    " 판매오더 헤더의 판매오더번호 클릭시 아이템 정보 팝업창으로 디스플레이
    PERFORM HANDLE_HOTSPOT_CLICK USING E_ROW_ID E_COLUMN_ID.
  ENDMETHOD.
ENDCLASS.
