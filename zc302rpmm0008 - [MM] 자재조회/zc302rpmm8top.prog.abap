*&---------------------------------------------------------------------*
*& Include ZC302RPMM8TOP                            - Report ZC302RPMM8
*&---------------------------------------------------------------------*
REPORT zc302rpmm8 MESSAGE-ID k5.


**********************************************************************
* Tables
**********************************************************************
TABLES : zc302mmt0013, zc302mt0007.

*-- Top of Page
DATA : go_top_cont   TYPE REF TO cl_gui_docking_container,
       go_dyndoc_id  TYPE REF TO cl_dd_document,
       go_html_cntrl TYPE REF TO cl_gui_html_viewer.

**********************************************************************
* Class Instance
**********************************************************************
DATA : go_dock_cont TYPE REF TO cl_gui_docking_container,
       go_alv_grid  TYPE REF TO cl_gui_alv_grid.

**********************************************************************
* Internal table & Work Area
**********************************************************************
DATA : BEGIN OF gs_body,
         matnr      TYPE zc302mmt0013-matnr,
         bpcode     TYPE zc302mt0007-bpcode,
         scode      TYPE zc302mmt0013-scode,
         sname      TYPE zc302mmt0013-sname,
         address    TYPE zc302mmt0013-address,
         maktx      TYPE zc302mmt0013-maktx,
         mtart_t(3),
         mtart      TYPE zc302mmt0013-mtart,
         h_rtptqua  TYPE zc302mmt0013-h_rtptqua,
         meins      TYPE zc302mmt0013-meins,
         celltab    TYPE lvc_t_styl,
       END OF gs_body,
       gt_body LIKE TABLE OF gs_body.

DATA : BEGIN OF gs_mat,
         matnr TYPE zc302mt0007-matnr,
         maktx TYPE zc302mt0007-maktx,
       END OF gs_mat,
       gt_mat LIKE TABLE OF gs_mat.

DATA : BEGIN OF gs_sco,
         scode TYPE zc302mt0005-scode,
         sname TYPE zc302mt0005-sname,
       END OF gs_sco,
       gt_sco LIKE TABLE OF gs_sco.

DATA : BEGIN OF gs_bp,
         bpcode TYPE zc302mt0001-bpcode,
         cname  TYPE zc302mt0001-cname,
       END OF gs_bp,
       gt_bp LIKE TABLE OF gs_bp.

DATA : gt_fcat TYPE lvc_t_fcat,
       gs_fcat TYPE lvc_s_fcat,
       gs_layo TYPE lvc_s_layo.

*-- Exclude ALV Toolbar
DATA : gt_ui_functions TYPE ui_functions.

**********************************************************************
* Common variable
**********************************************************************
DATA : gv_okcode TYPE sy-ucomm,
       gv_mode   VALUE 'E',
       gv_tabix  TYPE sy-tabix.
