*&---------------------------------------------------------------------*
*& Include ZC302RPSD0006TOP                         - Report ZC302RPSD0006
*&---------------------------------------------------------------------*
REPORT zc302rpsd0006 MESSAGE-ID k5.

**********************************************************************
* TABLES
**********************************************************************
TABLES : zc302sdt0005.

**********************************************************************
* TAB Strip controls
**********************************************************************
CONTROLS go_tab_strip TYPE TABSTRIP.

DATA : gv_subscreen TYPE sy-dynnr VALUE '0110',
       gv_tab       TYPE sy-ucomm.


**********************************************************************
* Class instance
**********************************************************************
*-- For Tabstrip ALV
DATA : go_container TYPE REF TO cl_gui_custom_container,
       go_alv_grid  TYPE REF TO cl_gui_alv_grid.

DATA : go_container2 TYPE REF TO cl_gui_custom_container,
       go_alv_grid2  TYPE REF TO cl_gui_alv_grid.

DATA : go_container3 TYPE REF TO cl_gui_custom_container,
       go_alv_grid3  TYPE REF TO cl_gui_alv_grid.

*-- For Popup ALV - 피킹 Item
DATA : go_pop_cont TYPE REF TO cl_gui_custom_container,
       go_pop_grid TYPE REF TO cl_gui_alv_grid.

*-- For Popup ALV - 자재문서
DATA : go_pop_cont2 TYPE REF TO cl_gui_custom_container,
       go_pop_grid2 TYPE REF TO cl_gui_alv_grid.

*-- For Popup ALV - 판매주문번호
DATA : go_pop_cont3 TYPE REF TO cl_gui_custom_container,
       go_pop_grid3 TYPE REF TO cl_gui_alv_grid.

*-- For Top-of-page
DATA : go_top_container TYPE REF TO cl_gui_docking_container,
       go_dyndoc_id     TYPE REF TO cl_dd_document,
       go_html_cntrl    TYPE REF TO cl_gui_html_viewer.

**********************************************************************
* Internal table and Work area
**********************************************************************
*-- For Tab1
DATA : gt_ship TYPE TABLE OF zc302sdt0005,
       gs_ship TYPE zc302sdt0005.

*-- For Tab2
DATA : gt_ship2 TYPE TABLE OF zc302sdt0005,
       gs_ship2 TYPE zc302sdt0005.

*-- For Tab3
DATA : gt_ship3 TYPE TABLE OF zc302sdt0005,
       gs_ship3 TYPE zc302sdt0005.

*-- For Popup - 피킹 Item
DATA : BEGIN OF gs_iship.
         INCLUDE STRUCTURE zc302sdt0006.
DATA :   celltab TYPE lvc_t_styl,
       END OF gs_iship,
       gt_iship LIKE TABLE OF gs_iship.

*-- For Popup - 자재문서
DATA : gt_mdocu_pop TYPE TABLE OF zc302mmt0012,
       gs_mdocu_pop TYPE zc302mmt0012.

*-- For Popup - 판매주문번호
DATA : gt_iorder_pop TYPE TABLE OF zc302sdt0004,
       gs_iorder_pop TYPE zc302sdt0004.

*-- FOR ALV
DATA : gt_fcat    TYPE lvc_t_fcat,
       gs_fcat    TYPE lvc_s_fcat,
       gt_fcat2   TYPE lvc_t_fcat,
       gs_fcat2   TYPE lvc_s_fcat,
       gt_fcat3   TYPE lvc_t_fcat,
       gs_fcat3   TYPE lvc_s_fcat,
       gs_layout  TYPE lvc_s_layo,
       gs_variant TYPE disvariant.

*-- For Popup - 반품 Item
DATA : gt_pfcat   TYPE lvc_t_fcat,
       gs_pfcat   TYPE lvc_s_fcat,
       gs_playout TYPE lvc_s_layo.

*-- For Popup - 자재문서
DATA : gt_pfcat2   TYPE lvc_t_fcat,
       gs_pfcat2   TYPE lvc_s_fcat,
       gs_playout2 TYPE lvc_s_layo.

*-- For Popup - 판매주문번호
DATA : gt_pfcat3   TYPE lvc_t_fcat,
       gs_pfcat3   TYPE lvc_s_fcat,
       gs_playout3 TYPE lvc_s_layo.

*-- ALV Toolbar
DATA : gs_button TYPE stb_button.

*-- Exclude ALV Toolbar
DATA : gt_ui_functions TYPE ui_functions.

*-- 자재문서 Header / Item
DATA : gt_mdocu  TYPE TABLE OF zc302mmt0011,
       gs_mdocu  TYPE zc302mmt0011,
       gt_imdocu TYPE TABLE OF zc302mmt0012,
       gs_imdocu TYPE zc302mmt0012.

*-- 재고관리 Header / Item
DATA : gt_stock  TYPE TABLE OF zc302mmt0013,
       gs_stock  TYPE zc302mmt0013,
       gt_istock TYPE TABLE OF zc302mmt0002,
       gs_istock TYPE zc302mmt0002.

*-- 판매오더
DATA : BEGIN OF gs_iorder,
         sonum    TYPE zc302sdt0004-sonum,
         matnr    TYPE zc302sdt0004-matnr,
         menge    TYPE zc302sdt0004-menge,
         meins    TYPE zc302sdt0004-meins,
         netwr    TYPE zc302sdt0004-netwr,
         waers    TYPE zc302sdt0004-waers,
         maktx    TYPE zc302mt0007-maktx,
         bpcode   TYPE zc302sdt0003-bpcode,
         cust_num TYPE zc302sdt0003-cust_num,       " 추가
       END OF gs_iorder,
       gt_iorder LIKE TABLE OF gs_iorder.

*-- Search Help로 구성할 데이터 선언
DATA : BEGIN OF gs_dlvnum,                       " 출하번호
         dlvnum TYPE zc302sdt0005-dlvnum,
       END OF gs_dlvnum,
       gt_dlvnum LIKE TABLE OF gs_dlvnum.

DATA : BEGIN OF gs_sonum,                       " 판매주문번호
         sonum TYPE zc302sdt0005-sonum,
       END OF gs_sonum,
       gt_sonum LIKE TABLE OF gs_sonum.

**********************************************************************
* Common variable
**********************************************************************
DATA : gv_okcode TYPE sy-ucomm.
