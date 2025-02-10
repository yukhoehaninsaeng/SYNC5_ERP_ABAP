*&---------------------------------------------------------------------*
*& Include ZC302RPFI0004TOP                         - Report ZC302RPFI0004
*&---------------------------------------------------------------------*
REPORT zc302rpfi0004 MESSAGE-ID k5.

**********************************************************************
* TABLES
**********************************************************************
TABLES : zc302fit0003.  " 재고 수불부 테이블

**********************************************************************
* Declaration area for NODE
**********************************************************************
TYPES: node_table_type LIKE STANDARD TABLE OF mtreesnode
                       WITH DEFAULT KEY.
DATA: node_table TYPE node_table_type.

**********************************************************************
* Class instance
**********************************************************************
DATA : go_alv_tree    TYPE REF TO cl_gui_simple_tree,
       go_change_menu TYPE REF TO cl_ctmenu.

DATA: go_docking_cont TYPE REF TO cl_gui_docking_container,
      go_base_cont    TYPE REF TO cl_gui_splitter_container,
      go_left_cont    TYPE REF TO cl_gui_container,
      go_right_cont   TYPE REF TO cl_gui_container,
*      go_alv_grid   TYPE REF TO cl_gui_alv_grid,
      go_tree         TYPE REF TO cl_gui_simple_tree.


*-- 일반 ALV
DATA : go_container TYPE REF TO cl_gui_docking_container,
       go_alv_grid  TYPE REF TO cl_gui_alv_grid.

*-- For Top-of-page
DATA : go_top_container TYPE REF TO cl_gui_docking_container,
       go_dyndoc_id     TYPE REF TO cl_dd_document,
       go_html_cntrl    TYPE REF TO cl_gui_html_viewer.

**********************************************************************
* Declaration area for Tree event
**********************************************************************
DATA: events TYPE cntl_simple_events,
      event  TYPE cntl_simple_event.


**********************************************************************
* Internal table and Work area
**********************************************************************
DATA : BEGIN OF gs_body.
         INCLUDE STRUCTURE zc302fit0003.
DATA : END OF gs_body,
gt_body LIKE TABLE OF gs_body.

*DATA : BEGIN OF gs_body,
*
*        matnr TYPE zc302fit0003-matnr,
*        maktx TYPE zc302fit0003-maktx,
*        plant TYPE zc302fit0003-plant,
*        scode TYPE zc302fit0003-scode,
*       END OF gs_body,
*       gt_body LIKE TABLE OF gs_body.



*-- ALV TREE 카테고리 연도->월 로 나눌예정
DATA : BEGIN OF gs_tr_subul,
         sbuly TYPE zc302fit0003-sbuly,
         sbldt TYPE zc302fit0003-sbldt,
       END OF gs_tr_subul,
       gt_tr_subul LIKE TABLE OF gs_tr_subul.


*-- For ALV
DATA : gt_fcat    TYPE lvc_t_fcat,
       gs_fcat    TYPE lvc_s_fcat,
       gs_layout  TYPE lvc_s_layo,
       gs_variant TYPE disvariant.

DATA : gt_ui_functions TYPE ui_functions.


**********************************************************************
* Common variable
**********************************************************************
DATA : gv_okcode  TYPE sy-ucomm,
       gv_cond(2).                  " 라디오버튼 값 받아오는 변수
