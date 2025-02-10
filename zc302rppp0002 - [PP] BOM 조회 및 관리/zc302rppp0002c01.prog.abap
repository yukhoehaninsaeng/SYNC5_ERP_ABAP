*&---------------------------------------------------------------------*
*& Include          ZC302RPPP0003C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION FINAL.

  PUBLIC SECTION.
    CLASS-METHODS : hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
                                  IMPORTING e_row_id e_column_id,
                    left_toolbar  FOR EVENT toolbar       OF cl_gui_alv_grid
                                  IMPORTING e_object e_interactive,
                    right_toolbar FOR EVENT toolbar      OF cl_gui_alv_grid
                                  IMPORTING e_object e_interactive,
                    user_command  FOR EVENT user_command OF cl_gui_alv_grid
                                  IMPORTING e_ucomm,
                    top_of_page   FOR EVENT top_of_page OF cl_gui_alv_grid
                                  IMPORTING e_dyndoc_id,
                    search_help   FOR EVENT onf4 OF cl_gui_alv_grid
                                  IMPORTING e_fieldname e_fieldvalue es_row_no er_event_data et_bad_cells e_display,
                    data_change   FOR EVENT data_changed_finished OF cl_gui_alv_grid
                                  IMPORTING e_modified et_good_cells.

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

  METHOD hotspot_click.
    PERFORM handle_hotspot_click USING e_row_id e_column_id.
  ENDMETHOD.

  METHOD left_toolbar.
    PERFORM handle_left_tbar USING e_object e_interactive.
  ENDMETHOD.

  METHOD right_toolbar.
    PERFORM handle_right_tbar USING e_object e_interactive.
  ENDMETHOD.

  METHOD user_command.
    PERFORM handle_user_command USING e_ucomm.
  ENDMETHOD.

  METHOD top_of_page.
    PERFORM event_top_of_page.  " top_of_page
  ENDMETHOD.

  METHOD search_help.
    " 자재코드에 대한 Search Help(F4)
    PERFORM onf4 USING e_fieldname e_fieldvalue es_row_no er_event_data et_bad_cells e_display.
  ENDMETHOD.

  METHOD data_change.
    " 자재코드와 수량 모두 입력 시 자재명, 단위, 구매 리드타임  자동으로 계산
    PERFORM handle_data_change USING e_modified et_good_cells.
  ENDMETHOD.

ENDCLASS.
