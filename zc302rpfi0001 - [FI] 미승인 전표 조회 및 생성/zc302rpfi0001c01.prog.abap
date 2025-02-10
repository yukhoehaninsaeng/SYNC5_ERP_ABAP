*&---------------------------------------------------------------------*
*& Class lcl_event_handler
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION FINAL.
  PUBLIC SECTION.
  CLASS-METHODS : top_of_page    FOR EVENT top_of_page OF cl_gui_alv_grid
                                 IMPORTING e_dyndoc_id,
                  toolbar_imsi   FOR EVENT toolbar OF cl_gui_alv_grid
                                 IMPORTING e_object e_interactive,
                  user_command   FOR EVENT user_command OF cl_gui_alv_grid
                                 IMPORTING e_ucomm.
ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) lcl_event_handler
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

  METHOD top_of_page.
    PERFORM event_top_of_page.
  ENDMETHOD.

  METHOD toolbar_imsi.
    PERFORM handle_toolbar_imsi USING e_object e_interactive.
  ENDMETHOD.

  METHOD user_command.
    PERFORM handle_user_command USING e_ucomm.
  ENDMETHOD.
ENDCLASS.
