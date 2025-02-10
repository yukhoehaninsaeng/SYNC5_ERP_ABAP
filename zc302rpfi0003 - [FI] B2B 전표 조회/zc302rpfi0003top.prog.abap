*&---------------------------------------------------------------------*
*& Include ZC302RPFI0003TOP                         - Report ZC302RPFI0003
*&---------------------------------------------------------------------*
REPORT zc302rpfi0003 MESSAGE-ID k5.

*--------------------------------------------------------------------*
* Tables
*--------------------------------------------------------------------*
TABLES : zc302fit0004, zc302fit0001, zc302fit0002. "임시 전표, 전표 헤더, 전표 아이템

*--------------------------------------------------------------------*
* Internal Table and Work Area
*--------------------------------------------------------------------*
DATA : BEGIN OF gs_body.
        INCLUDE TYPE zc302fiv0001.
DATA :  txt50 TYPE skat-txt50,
       END OF gs_body,
       gt_body LIKE TABLE OF gs_body,
       gs_text TYPE zc302mt0006,
       gt_text TYPE TABLE OF zc302mt0006.

*--------------------------------------------------------------------*
* Class Instance
*--------------------------------------------------------------------*
DATA : go_container TYPE REF TO cl_gui_docking_container,
       go_alv_grid TYPE REF TO cl_gui_alv_grid,
       gs_fcat TYPE lvc_s_fcat,
       gt_fcat TYPE lvc_t_fcat,
       gs_layo TYPE lvc_s_layo.

" Top of Page
DATA : go_top_cont TYPE REF TO cl_gui_docking_container,
       go_dyndoc_id TYPE REF TO cl_dd_document,
       go_html_cntrl TYPE REF TO cl_gui_html_viewer.

*--------------------------------------------------------------------*
* Common Value
*--------------------------------------------------------------------*
DATA : gv_lines TYPE sy-dbcnt,
       gv_tabix TYPE sy-tabix.
