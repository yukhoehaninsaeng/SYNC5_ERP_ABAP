*&---------------------------------------------------------------------*
*& Include          SAPMZC302PP0004C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION FINAL.

  PUBLIC SECTION.
    CLASS-METHODS : toolbar       FOR EVENT toolbar OF cl_gui_alv_grid
                                  IMPORTING e_object e_interactive,
                    button_click  FOR EVENT button_click OF cl_gui_alv_grid
                                  IMPORTING es_col_id es_row_no,
                    user_command  FOR EVENT user_command OF cl_gui_alv_grid
                                  IMPORTING e_ucomm.

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

  METHOD toolbar.
    PERFORM handle_toolbar USING e_object e_interactive.   " ALV Toolbar 생성
  ENDMETHOD.

  METHOD button_click.
    PERFORM handle_button_click USING es_col_id es_row_no. " 필드 Button 기능 구현
  ENDMETHOD.

  METHOD user_command.
    PERFORM handle_user_command USING e_ucomm.  " ALV Toolbar 기능 구현
  ENDMETHOD.

ENDCLASS.
