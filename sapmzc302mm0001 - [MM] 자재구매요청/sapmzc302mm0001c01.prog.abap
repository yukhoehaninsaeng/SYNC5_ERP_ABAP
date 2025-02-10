*&---------------------------------------------------------------------*
*& Include          SAPMZC302MM0001C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION FINAL.

  PUBLIC SECTION.
*-- 구매요청 Header hotspot
  CLASS-METHODS hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
                                                      IMPORTING e_row_id e_column_id.

*-- 구매요청 버튼
  CLASS-METHODS : toolbar FOR EVENT toolbar OF cl_gui_alv_grid
                          IMPORTING e_object e_interactive,
              user_command FOR EVENT user_command OF cl_gui_alv_grid
                           IMPORTING e_ucomm.

*-- 반려사유 버튼
  CLASS-METHODS : button_click FOR EVENT button_click OF cl_gui_alv_grid
                               IMPORTING es_col_id es_row_no.

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

*-- 구매요청 Header hotspot
  METHOD hotspot_click.
    PERFORM handle_hotspot_click USING e_row_id e_column_id.
  ENDMETHOD.

*-- 구매요청 버튼
  METHOD toolbar.
    PERFORM handle_toolbar USING e_object e_interactive.
  ENDMETHOD.

*-- 검수 버튼
  METHOD button_click.
    PERFORM handle_button_click USING es_col_id es_row_no.
  ENDMETHOD.

  METHOD user_command.
    PERFORM handle_user_command USING e_ucomm.
  ENDMETHOD.


ENDCLASS.
