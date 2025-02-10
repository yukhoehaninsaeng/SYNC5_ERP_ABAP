*&---------------------------------------------------------------------*
*& Include          ZC302RPPP0005C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION FINAL.

  PUBLIC SECTION.
    CLASS-METHODS : up_toolbar    FOR EVENT toolbar       OF cl_gui_alv_grid
                                  IMPORTING e_object e_interactive,
                    down_toolbar  FOR EVENT toolbar      OF cl_gui_alv_grid
                                  IMPORTING e_object e_interactive,
                    user_command  FOR EVENT user_command OF cl_gui_alv_grid
                                  IMPORTING e_ucomm,
                    top_of_page   FOR EVENT top_of_page OF cl_gui_alv_grid
                                  IMPORTING e_dyndoc_id .

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

  METHOD up_toolbar.
    PERFORM handle_up_tbar USING e_object e_interactive.
  ENDMETHOD.

  METHOD down_toolbar.
    PERFORM handle_down_tbar USING e_object e_interactive.
  ENDMETHOD.

  METHOD user_command.
    PERFORM handle_user_command USING e_ucomm.
  ENDMETHOD.

  METHOD top_of_page.
    PERFORM event_top_of_page.  "top_of_page
  ENDMETHOD.

ENDCLASS.
