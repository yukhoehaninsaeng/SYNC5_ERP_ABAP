*&---------------------------------------------------------------------*
*& Include ZC302RPSD0005TOP                         - Report ZC302RPSD0005
*&---------------------------------------------------------------------*
REPORT zc302rpsd0005 MESSAGE-ID k5.

**********************************************************************
* TABLES
**********************************************************************
TABLES : zc302sdt0007.

**********************************************************************
* Class instance
**********************************************************************
*-- For Main ALV
DATA : go_container TYPE REF TO cl_gui_docking_container,
       go_alv_grid  TYPE REF TO cl_gui_alv_grid.

*-- For Popup ALV
DATA : go_pop_cont TYPE REF TO cl_gui_custom_container,
       go_pop_grid TYPE REF TO cl_gui_alv_grid.

*-- For Top-of-page
DATA : go_top_container TYPE REF TO cl_gui_docking_container,
       go_dyndoc_id     TYPE REF TO cl_dd_document,
       go_html_cntrl    TYPE REF TO cl_gui_html_viewer.

**********************************************************************
* Internal table and Work area
**********************************************************************
*-- For Main ALV (반품H)
DATA : BEGIN OF gs_refund.
         INCLUDE STRUCTURE zc302sdt0007.
DATA :   exam_btn(5),  " 검수버튼
         celltab     TYPE lvc_t_styl.
DATA : END OF gs_refund,
gt_refund LIKE TABLE OF gs_refund.

DATA : gt_fcat   TYPE lvc_t_fcat,
       gs_fcat   TYPE lvc_s_fcat,
       gs_layout TYPE lvc_s_layo.

*-- For Popup ALV (반품I)
DATA : BEGIN OF gs_irefund,
         icon    TYPE icon-id,
         celltab TYPE lvc_t_styl.
         INCLUDE STRUCTURE zc302sdt0008.
DATA : END OF gs_irefund,
gt_irefund LIKE TABLE OF gs_irefund.

DATA : gt_pfcat   TYPE lvc_t_fcat,
       gs_pfcat   TYPE lvc_s_fcat,
       gs_playout TYPE lvc_s_layo.

*-- For 자재문서(H,I)
DATA : gt_mdocu  TYPE TABLE OF zc302mmt0011,
       gs_mdocu  TYPE zc302mmt0011,
       gt_imdocu TYPE TABLE OF zc302mmt0012,
       gs_imdocu TYPE zc302mmt0012.

*-- For 재고관리(H,I)
DATA : gt_stock  TYPE TABLE OF zc302mmt0013,
       gs_stock  TYPE zc302mmt0013,
       gt_istock TYPE TABLE OF zc302mmt0002,
       gs_istock TYPE zc302mmt0002.

DATA : gt_stock_upt TYPE TABLE OF zc302mmt0013,
       gs_stock_upt TYPE zc302mmt0013.

DATA: gt_istock_upt TYPE TABLE OF zc302mmt0002,
      gs_istock_upt TYPE zc302mmt0002.

*-- For 입출금내역
DATA : gt_withdraw TYPE TABLE OF zc302fit0006,
       gs_withdraw TYPE zc302fit0006.

*-- For 자재마스터
DATA : gt_maktx TYPE TABLE OF zc302mt0007,
       gs_maktx TYPE zc302mt0007.

*-- For 판매오더I
DATA : BEGIN OF gs_zc302sdt0004,
         sonum  TYPE zc302sdt0004-sonum,
         matnr  TYPE zc302sdt0004-matnr,
         waers  TYPE zc302sdt0004-waers,
         netwr  TYPE zc302sdt0004-netwr,
         bpcode TYPE zc302sdt0003-bpcode,
       END OF gs_zc302sdt0004,
       gt_zc302sdt0004 LIKE TABLE OF gs_zc302sdt0004.


*-- For 반품H
DATA : gt_zc302sdt0007 TYPE TABLE OF zc302sdt0007,
       gs_zc302sdt0007 TYPE zc302sdt0007.

*-- For 폐기
DATA : gt_discard TYPE TABLE OF zc302mmt0001,
       gs_discard TYPE zc302mmt0001.

*-- Exclude ALV Toolbar
DATA : gt_ui_functions TYPE ui_functions.

*-- ALV Toolbar
DATA : gs_button TYPE stb_button.

*-- For Search Help
DATA : BEGIN OF gs_rfnum,
         rfnum TYPE zc302sdt0007-rfnum,
       END OF gs_rfnum,
       gt_rfnum LIKE TABLE OF gs_rfnum.

DATA : BEGIN OF gs_sonum,
         sonum TYPE zc302sdt0007-sonum,
       END OF gs_sonum,
       gt_sonum LIKE TABLE OF gs_sonum.

**********************************************************************
* Common Variable
**********************************************************************
DATA : gv_okcode  TYPE sy-ucomm,
       gv_sonum   TYPE zc302sdt0007-sonum,   " 판매주문번호
       gv_rfnum   TYPE zc302sdt0007-rfnum,   " 반품번호
       gv_flag(1),
       gv_bpcode  TYPE zc302sdt0003-bpcode.
