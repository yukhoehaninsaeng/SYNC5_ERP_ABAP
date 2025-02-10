*&---------------------------------------------------------------------*
*& Include          ZC302RPFI0004C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS: handle_node_double_click FOR EVENT node_double_click
                                            OF cl_gui_simple_tree
                                            IMPORTING node_key.

    CLASS-METHODS : top_of_page FOR EVENT top_of_page OF cl_gui_alv_grid
                                IMPORTING e_dyndoc_id.

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation)
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

  METHOD handle_node_double_click.

    PERFORM search_clicked_node_info USING node_key.

      IF lines( gt_body ) GT 0.
        CALL METHOD go_alv_grid->refresh_table_display.
      ELSE.
        MESSAGE i001 WITH TEXT-e01.
      ENDIF.

  ENDMETHOD.                    "handle_node_double_click

  METHOD top_of_page.
    PERFORM event_top_of_page.
  ENDMETHOD.

ENDCLASS.
