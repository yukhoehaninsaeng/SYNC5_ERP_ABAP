*&---------------------------------------------------------------------*
*& Include          ZC302RPSD0006C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION FINAL.

  PUBLIC SECTION.
    CLASS-METHODS : toolbar_tab2   FOR EVENT toolbar OF cl_gui_alv_grid
                                   IMPORTING e_object e_interactive,
                    toolbar_tab3   FOR EVENT toolbar OF cl_gui_alv_grid
                                   IMPORTING e_object e_interactive,
                    user_command   FOR EVENT user_command OF cl_gui_alv_grid
                                   IMPORTING e_ucomm,
                    top_of_page    FOR EVENT top_of_page OF cl_gui_alv_grid
                                   IMPORTING e_dyndoc_id,
                    hotspot_click  FOR EVENT hotspot_click OF cl_gui_alv_grid
                                   IMPORTING e_row_id e_column_id,
                    hotspot_click2 FOR EVENT hotspot_click OF cl_gui_alv_grid
                                   IMPORTING e_row_id e_column_id.

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

  METHOD toolbar_tab2.
    PERFORM handle_toolbar_tab2 USING e_object e_interactive.
  ENDMETHOD.

  METHOD toolbar_tab3.
    PERFORM handle_toolbar_tab3 USING e_object e_interactive.
  ENDMETHOD.

  METHOD user_command.
    PERFORM handle_user_command USING e_ucomm.  " 피킹버튼, GI버튼
  ENDMETHOD.

  METHOD top_of_page.
    PERFORM event_top_of_page.
  ENDMETHOD.

  METHOD hotspot_click.  " 자재문서번호 HOTSPOT
    PERFORM handle_hotspot_click USING e_row_id e_column_id.
  ENDMETHOD.

  METHOD hotspot_click2. " 판매주문번호 HOTSPOT
    PERFORM handle_hotspot_click2 USING e_row_id e_column_id.
  ENDMETHOD.

ENDCLASS.
