*&---------------------------------------------------------------------*
*& Include          SAPMZC302MM0004C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS : toolbar      FOR EVENT toolbar OF cl_gui_alv_grid
                                 IMPORTING e_object e_interactive,
                    toolbar2     FOR EVENT toolbar OF cl_gui_alv_grid
                                 IMPORTING e_object e_interactive,
                    user_command FOR EVENT user_command OF cl_gui_alv_grid
                                 IMPORTING e_ucomm.
ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

  METHOD toolbar.    " 검수진행 버튼
    PERFORM handle_toolbar USING e_object e_interactive.
  ENDMETHOD.
  METHOD toolbar2.   " 검수확인 버튼
    PERFORM handle_toolbar2 USING e_object e_interactive.
  ENDMETHOD.
  METHOD user_command.
    PERFORM handle_user_command USING e_ucomm.
  ENDMETHOD.

ENDCLASS.
