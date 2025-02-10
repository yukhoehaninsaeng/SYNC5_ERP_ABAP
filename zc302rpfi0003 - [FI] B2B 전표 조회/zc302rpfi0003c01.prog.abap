*&---------------------------------------------------------------------*
*& Include          ZC302RPFI0003C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class lcl_event_handler
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION FINAL.
PUBLIC SECTION.
  CLASS-METHODS : top_of_page    FOR EVENT top_of_page  OF cl_gui_alv_grid
                                 IMPORTING e_dyndoc_id.
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

ENDCLASS.
