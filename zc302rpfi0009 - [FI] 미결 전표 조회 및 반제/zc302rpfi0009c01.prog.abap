*&---------------------------------------------------------------------*
*& Include          ZC302RPFI0009C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class lcl_event_handler
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS : toolbar FOR EVENT toolbar OF cl_gui_alv_grid
                            IMPORTING e_object e_interactive,
                    user_command FOR EVENT user_command OF cl_gui_alv_grid
                                 IMPORTING e_ucomm,
                    hotspot FOR EVENT hotspot_click OF cl_gui_alv_grid
                            IMPORTING e_row_id e_column_id,
                    top_of_page FOR EVENT  top_of_page OF cl_gui_alv_grid
                                IMPORTING e_dyndoc_id.
ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) lcl_event_handler
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

  METHOD toolbar.
    PERFORM handle_toolbar USING e_object e_interactive.
  ENDMETHOD.

  METHOD user_command.
    PERFORM handle_user_command USING e_ucomm.
  ENDMETHOD.

  METHOD hotspot.
    PERFORM handle_hotspot USING e_row_id e_column_id.
  ENDMETHOD.

  METHOD top_of_page.
    PERFORM event_top_of_page.
  ENDMETHOD.

ENDCLASS.
