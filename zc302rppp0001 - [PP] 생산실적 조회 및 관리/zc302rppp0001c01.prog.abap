*&---------------------------------------------------------------------*
*& Include          ZC302RPPP0002C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION FINAL.

  PUBLIC SECTION.
    CLASS-METHODS: handle_toolbar FOR EVENT toolbar      OF cl_gui_alv_grid
                                  IMPORTING e_object e_interactive,
                   user_command   FOR EVENT user_command OF cl_gui_alv_grid
                                  IMPORTING e_ucomm,
                   top_of_page    FOR EVENT top_of_page  OF cl_gui_alv_grid
                                  IMPORTING e_dyndoc_id..

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

  METHOD handle_toolbar.
    PERFORM handle_toolbar USING e_object e_interactive.
  ENDMETHOD.

  METHOD user_command.
    PERFORM handle_user_command USING e_ucomm.
  ENDMETHOD.

  METHOD top_of_page.
    PERFORM event_top_of_page.  "top_of_page
  ENDMETHOD.

ENDCLASS.
