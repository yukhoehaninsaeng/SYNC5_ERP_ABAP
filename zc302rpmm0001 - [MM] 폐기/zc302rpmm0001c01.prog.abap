*&---------------------------------------------------------------------*
*& Class LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION FINAL.

  PUBLIC SECTION.
*-- TOP OF PAGE
  CLASS-METHODS : top_of_page FOR EVENT top_of_page OF cl_gui_alv_grid
      IMPORTING e_dyndoc_id.

*-- TOOLBAR
  CLASS-METHODS : toolbar FOR EVENT toolbar OF cl_gui_alv_grid
                        IMPORTING e_object e_interactive,
                user_command FOR EVENT USER_COMMAND OF cl_gui_alv_grid
                            IMPORTING e_ucomm.

*-- 폐기사유 조회 버튼
  CLASS-METHODS : button_click FOR EVENT button_click OF cl_gui_alv_grid
                               IMPORTING es_col_id es_row_no.

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

  METHOD top_of_page.
    PERFORM event_top_of_page.
  ENDMETHOD.

  METHOD toolbar.
    PERFORM handle_toolbar USING e_object e_interactive.
  ENDMETHOD.

  METHOD user_command.
    PERFORM handle_user_command USING e_ucomm.
  ENDMETHOD.

  METHOD button_click.
    PERFORM handle_button_click USING es_col_id es_row_no.
  ENDMETHOD.

ENDCLASS.
