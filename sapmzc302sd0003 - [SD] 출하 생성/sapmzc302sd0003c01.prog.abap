*&---------------------------------------------------------------------*
*& Include          SAPMZC302SD0003C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION FINAL.

  PUBLIC SECTION.
    CLASS-METHODS : toolbar        FOR EVENT toolbar OF cl_gui_alv_grid
                                   IMPORTING e_object e_interactive,
                    toolbar_right  FOR EVENT toolbar OF cl_gui_alv_grid
                                   IMPORTING e_object e_interactive,
                    user_command   FOR EVENT user_command OF cl_gui_alv_grid
                                   IMPORTING e_ucomm,
                    hotspot_click  FOR EVENT hotspot_click OF cl_gui_alv_grid
                                   IMPORTING e_row_id e_column_id.

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

  METHOD toolbar.
    PERFORM handle_toolbar USING e_object e_interactive.
  ENDMETHOD.

  METHOD toolbar_right.
    PERFORM handle_toolbar_right USING e_object e_interactive.
  ENDMETHOD.

  METHOD user_command.
    PERFORM handle_user_command USING e_ucomm.
  ENDMETHOD.

  METHOD hotspot_click.
    PERFORM handle_hotspot_click USING e_row_id e_column_id.
  ENDMETHOD.

ENDCLASS.
