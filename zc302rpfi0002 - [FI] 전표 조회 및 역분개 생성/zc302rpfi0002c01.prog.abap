*&---------------------------------------------------------------------*
*& Include          ZC302RPFI0002C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class lcl_event_handler
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION FINAL.   " 선언부

  PUBLIC SECTION.
    CLASS-METHODS : top_of_page FOR EVENT top_of_page OF cl_gui_alv_grid
                                IMPORTING e_dyndoc_id.

    CLASS-METHODS : hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
                                  IMPORTING e_row_id e_column_id.

    CLASS-METHODS create_btn_click FOR EVENT button_click OF cl_gui_alv_grid
                                  IMPORTING es_col_id es_row_no.

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) lcl_event_handler
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.     " 구현부

*-- Top-of-page
  METHOD top_of_page.
    PERFORM event_top_of_page.
  ENDMETHOD.

*-- 전표 Item 조회
  METHOD hotspot_click.
    PERFORM handle_hotspot_click USING e_row_id e_column_id.
  ENDMETHOD.

*-- 역분개 생성버튼
  METHOD create_btn_click.
    PERFORM handle_create_btn_click USING es_col_id es_row_no.
  ENDMETHOD.

ENDCLASS.
