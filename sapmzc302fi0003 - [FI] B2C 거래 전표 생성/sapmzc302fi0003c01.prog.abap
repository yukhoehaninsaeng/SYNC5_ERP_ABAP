*&---------------------------------------------------------------------*
*& Include          SAPMZC302FI0003C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION FINAL.

  PUBLIC SECTION.
    CLASS-METHODS hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
                                    IMPORTING e_row_id e_column_id.
    CLASS-METHODS create_btn_click FOR EVENT button_click OF cl_gui_alv_grid
                                    IMPORTING es_col_id es_row_no.
    CLASS-METHODS double_click FOR EVENT double_click OF cl_gui_alv_grid
                                    IMPORTING e_row e_column.
ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

*-- 판매오더 아이템 조회
  METHOD hotspot_click.
    PERFORM handle_hotspot_click USING e_row_id e_column_id.
  ENDMETHOD.

*-- 버튼 클릭으로 전표 생성
  METHOD create_btn_click.
    PERFORM handle_create_btn_click USING es_col_id es_row_no.
  ENDMETHOD.

*-- 전표 상세내역 확인
  METHOD double_click.
    PERFORM handle_double_click USING e_row e_column.
  ENDMETHOD.
ENDCLASS.
