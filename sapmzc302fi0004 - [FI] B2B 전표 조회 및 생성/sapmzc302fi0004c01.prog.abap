*&---------------------------------------------------------------------*
*& Include          SAPMZC302FI0004C01
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
                  modify_value for event data_changed_finished
                               of cl_gui_alv_grid
                               IMPORTING e_modified et_good_cells,
                  onf4    for event onf4 of cl_gui_alv_grid
                          IMPORTING e_fieldname e_fieldvalue es_row_no
                                    er_event_data et_bad_cells e_display.

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

  METHOD modify_value.
    perform handle_modify_value using e_modified et_good_cells.
  ENDMETHOD.

  METHOD onf4.
    perform handle_onf4 using e_fieldname e_fieldvalue es_row_no
                              er_event_data et_bad_cells e_display.
  ENDMETHOD.

ENDCLASS.
