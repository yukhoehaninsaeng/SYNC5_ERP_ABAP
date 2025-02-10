*&---------------------------------------------------------------------*
*& Include          ZC302RPPP0004C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION FINAL.

  PUBLIC SECTION.
    CLASS-METHODS: double_click  FOR EVENT double_click OF cl_gui_alv_grid
                                 IMPORTING e_row e_column,
                   left_toolbar  FOR EVENT toolbar      OF cl_gui_alv_grid
                                 IMPORTING e_object e_interactive,
                   right_toolbar FOR EVENT toolbar      OF cl_gui_alv_grid
                                 IMPORTING e_object e_interactive,
                   user_command  FOR EVENT user_command OF cl_gui_alv_grid
                                 IMPORTING e_ucomm,
                   top_of_page   FOR EVENT top_of_page  OF cl_gui_alv_grid
                                 IMPORTING e_dyndoc_id.

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

  METHOD double_click.
    PERFORM handle_double_click USING e_row e_column.
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
    PERFORM event_top_of_page.  "top_of_page
  ENDMETHOD.

ENDCLASS.
