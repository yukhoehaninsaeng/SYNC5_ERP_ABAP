*&---------------------------------------------------------------------*
*& Include          ZC302RPSD0005C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION FINAL.

  PUBLIC SECTION.

    CLASS-METHODS : button_click FOR EVENT button_click OF cl_gui_alv_grid
                                 IMPORTING es_col_id es_row_no,
                    toolbar      FOR EVENT toolbar OF cl_gui_alv_grid
                                 IMPORTING e_object e_interactive,
                    user_command FOR EVENT user_command OF cl_gui_alv_grid
                                 IMPORTING e_ucomm,
                    top_of_page  FOR EVENT top_of_page OF cl_gui_alv_grid
                                 IMPORTING e_dyndoc_id,
                    data_change  FOR EVENT data_changed_finished OF cl_gui_alv_grid
                                 IMPORTING e_modified et_good_cells.


ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

  METHOD button_click.  " 검수버튼
    PERFORM handle_button_click USING es_col_id es_row_no.
  ENDMETHOD.

  METHOD toolbar.       " TOOLBAR에 저장버튼 생성
    PERFORM handle_toolbar USING e_object e_interactive.
  ENDMETHOD.

  METHOD user_command.  " 저장버튼
    PERFORM handle_user_command USING e_ucomm.
  ENDMETHOD.

  METHOD top_of_page.   " TOP-OF-PAGE
    PERFORM event_top_of_page.
  ENDMETHOD.

  METHOD data_change.   " DATA_CHANGE
    PERFORM handle_data_change USING e_modified et_good_cells.
  ENDMETHOD.

ENDCLASS.
