*&---------------------------------------------------------------------*
*& Include ZC302RPFI0009TOP                         - Report ZC302RPFI0009
*&---------------------------------------------------------------------*
REPORT zc302rpfi0009 MESSAGE-ID k5.

*--------------------------------------------------------------------*
* Table
*--------------------------------------------------------------------*
TABLES : zc302mt0001,zc302fit0001.

*--------------------------------------------------------------------*
* Class
*--------------------------------------------------------------------*
DATA : go_cont      TYPE REF TO cl_gui_docking_container,
       go_split     TYPE REF TO cl_gui_splitter_container,
       go_ltop_cont TYPE REF TO cl_gui_container,
       go_lbot_cont TYPE REF TO cl_gui_container,
       go_rtop_cont TYPE REF TO cl_gui_container,
       go_rbot_cont TYPE REF TO cl_gui_container,
       go_ltop_grid TYPE REF TO cl_gui_alv_grid,
       go_lbot_grid TYPE REF TO cl_gui_alv_grid,
       go_rtop_grid TYPE REF TO cl_gui_alv_grid,
       go_rbot_grid TYPE REF TO cl_gui_alv_grid.

*--------------------------------------------------------------------*
* Itab and WA
*--------------------------------------------------------------------*
DATA : BEGIN OF gs_body,            " 전표 header 담을 테이블
         icon TYPE icon-id.
         INCLUDE TYPE zc302fit0001.
DATA : END OF gs_body,
gt_body LIKE TABLE OF gs_body,
  BEGIN OF gs_item.               " 전표 item 담을 테이블
    INCLUDE TYPE zc302fit0002.
DATA : txt50 TYPE zc302mt0006-txt50,
  END OF gs_item,
  gt_item LIKE TABLE OF gs_item,
  gs_bkpf TYPE zc302fit0001,          " 새로 생성된 전표 header
  gt_bkpf TYPE TABLE OF zc302fit0001, " 테이블
  gs_bseg TYPE zc302fit0002,
  gt_bseg TYPE TABLE OF zc302fit0002.

" alv
DATA : gt_ltop_fcat TYPE lvc_t_fcat,
       gt_lbot_fcat TYPE lvc_t_fcat,
       gt_rtop_fcat TYPE lvc_t_fcat,
       gt_rbot_fcat TYPE lvc_t_fcat,
       gs_ltop_fcat TYPE lvc_s_fcat,
       gs_lbot_fcat TYPE lvc_s_fcat,
       gs_rtop_fcat TYPE lvc_s_fcat,
       gs_rbot_fcat TYPE lvc_s_fcat,
       gs_layo_ltop TYPE lvc_s_layo,
       gs_layo_lbot TYPE lvc_s_layo,
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
