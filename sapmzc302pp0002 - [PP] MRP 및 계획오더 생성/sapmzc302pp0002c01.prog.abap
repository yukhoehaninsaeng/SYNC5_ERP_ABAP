*&---------------------------------------------------------------------*
*& Include          SAPMZC302PP0002C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION FINAL.

  PUBLIC SECTION.
    CLASS-METHODS : toolbar_left  FOR EVENT toolbar OF cl_gui_alv_grid
                                  IMPORTING e_object e_interactive,
                    toolbar_up    FOR EVENT toolbar OF cl_gui_alv_grid
                                  IMPORTING e_object e_interactive,
                    user_command  FOR EVENT user_command OF cl_gui_alv_grid
                                  IMPORTING e_ucomm,
                    hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
                                  IMPORTING e_row_id e_column_id.

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

  METHOD toolbar_left.
    PERFORM handle_left_tbar USING e_object e_interactive. " 왼쪽 ALV Toolbar 설정
  ENDMETHOD.

  METHOD toolbar_up.
    PERFORM handle_up_tbar USING e_object e_interactive. " 오른쪽 ALV Toolbar 설정
  ENDMETHOD.

  METHOD user_command.
    PERFORM handle_user_command USING e_ucomm. " ALV Toolbar 기능 구현
  ENDMETHOD.

  METHOD hotspot_click.
    PERFORM handle_hotspot_click USING e_row_id e_column_id. " Hotspot click 기능 구현
  ENDMETHOD.

ENDCLASS.
