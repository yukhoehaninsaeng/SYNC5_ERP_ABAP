*&---------------------------------------------------------------------*
*& Include          ZC302RPFI0005O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module INIT_PROCESS_CONTROL OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_process_control OUTPUT.
  IF go_tree IS NOT BOUND.

    PERFORM init_tree.
    PERFORM define_hierarchy_header CHANGING gs_hierhdr.
    PERFORM build_comment USING gt_list_commentary.
    PERFORM define_field_catalog.
    PERFORM create_hierarchy.
    PERFORM fill_column_tree.

  ENDIF.
ENDMODULE.
