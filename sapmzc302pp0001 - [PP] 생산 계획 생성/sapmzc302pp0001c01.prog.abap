*&---------------------------------------------------------------------*
*& Include          SAPMZC302PP0001C01
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
                   toolbar       FOR EVENT toolbar OF cl_gui_alv_grid
                               IMPORTING e_object e_interactive,
                   user_command  FOR EVENT user_command OF cl_gui_alv_grid
                               IMPORTING e_ucomm.


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

  METHOD toolbar.
    PERFORM handle_toolbar USING e_object e_interactive.
  ENDMETHOD.

  METHOD user_command.
    PERFORM handle_user_command USING e_ucomm.
  ENDMETHOD.
ENDCLASS.
