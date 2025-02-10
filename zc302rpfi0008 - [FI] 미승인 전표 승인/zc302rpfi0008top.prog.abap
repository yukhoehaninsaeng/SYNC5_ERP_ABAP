*&---------------------------------------------------------------------*
*& Include ZC302RPFI0008TOP                         - Report ZC302RPFI0008
*&---------------------------------------------------------------------*
REPORT zc302rpfi0008 MESSAGE-ID k5.

*--------------------------------------------------------------------*
* Table
*--------------------------------------------------------------------*
TABLES : zc302mt0001.

*--------------------------------------------------------------------*
* Class
*--------------------------------------------------------------------*
DATA : go_cont       TYPE REF TO cl_gui_docking_container,
       go_split      TYPE REF TO cl_gui_splitter_container,
       go_split2     TYPE REF TO cl_gui_splitter_container,
       go_left_cont  TYPE REF TO cl_gui_container,
       go_right_cont TYPE REF TO cl_gui_container,
       go_top_cont   TYPE REF TO cl_gui_container,
       go_bot_cont   TYPE REF TO cl_gui_container,
       go_left_grid  TYPE REF TO cl_gui_alv_grid,
       go_top_grid   TYPE REF TO cl_gui_alv_grid,
       go_bot_grid   TYPE REF TO cl_gui_alv_grid.

*--------------------------------------------------------------------*
* Itab and WA
*--------------------------------------------------------------------*
DATA : BEGIN OF gs_body,
         icon TYPE icon-id.
         INCLUDE TYPE zc302fit0004.
DATA : END OF gs_body,
gt_body LIKE TABLE OF gs_body,
  BEGIN OF gs_bseg.
    INCLUDE TYPE zc302fit0002.
DATA : txt50 TYPE zc302mt0006-txt50,
  END OF gs_bseg,
  gs_bkpf TYPE zc302fit0001,
  gt_bkpf TYPE TABLE OF zc302fit0001,
  gt_bseg LIKE TABLE OF gs_bseg.

" alv
DATA : gt_left_fcat TYPE lvc_t_fcat,
       gt_top_fcat  TYPE lvc_t_fcat,
       gt_bot_fcat  TYPE lvc_t_fcat,
       gs_left_fcat TYPE lvc_s_fcat,
       gs_top_fcat  TYPE lvc_s_fcat,
       gs_bot_fcat  TYPE lvc_s_fcat,
       gs_layo_left TYPE lvc_s_layo,
       gs_layo_rtop TYPE lvc_s_layo,
       gs_layo_rbot TYPE lvc_s_layo.

" top of page
DATA : go_top_container TYPE REF TO cl_gui_docking_container,
       go_dyndoc_id     TYPE REF TO cl_dd_document,
       go_html_cntrl    TYPE REF TO cl_gui_html_viewer.

*--------------------------------------------------------------------*
* Common Variable
*--------------------------------------------------------------------*
DATA : gv_lines  TYPE sy-dbcnt,
       gv_tabix  TYPE sy-tabix,
       gv_number TYPE i,
       gv_okcode TYPE sy-ucomm.
