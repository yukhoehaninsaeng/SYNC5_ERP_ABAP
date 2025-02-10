*&---------------------------------------------------------------------*
*& Include ZC302RPMM0007TOP                         - Report ZC302RPMM0007
*&---------------------------------------------------------------------*
REPORT zc302rpmm0007 MESSAGE-ID k5.

**********************************************************************
* TABLES 자재문서 HEADER , ITEM
**********************************************************************
TABLES: zc302mmt0011, zc302mmt0012.

**********************************************************************
* Class instance
**********************************************************************
DATA : go_container TYPE REF TO cl_gui_docking_container,
       go_alv_grid  TYPE REF TO cl_gui_alv_grid.

*-- POPUP SCREEN
DATA : go_pop_container TYPE REF TO cl_gui_custom_container,
       go_pop_grid      TYPE REF TO cl_gui_alv_grid.

*-- For Top-of-page
DATA : go_top_container TYPE REF TO cl_gui_docking_container,
       go_dyndoc_id     TYPE REF TO cl_dd_document,
       go_html_cntrl    TYPE REF TO cl_gui_html_viewer.

**********************************************************************
* Internal table and Work area
**********************************************************************
DATA : BEGIN OF gs_doc_mat,
        mblnr    TYPE zc302mmt0011-mblnr,
        mjahr    TYPE zc302mmt0011-mjahr,
        maktx    TYPE zc302mmt0012-maktx,
        vbeln    TYPE zc302mmt0011-vbeln,
        movetype TYPE zc302mmt0011-movetype,
        movetype_t(2),
        aufnr    TYPE zc302mmt0011-aufnr,
        ponum    TYPE zc302mmt0011-ponum,
        rfnum    TYPE zc302mmt0011-rfnum,
  END OF gs_doc_mat,
  gt_doc_mat LIKE TABLE OF gs_doc_mat.

DATA : BEGIN OF gs_doc_item,
        mblnr    TYPE zc302mmt0012-mblnr,
        mjahr    TYPE zc302mmt0012-mjahr,
        matnr    TYPE zc302mmt0012-matnr,
        scode    TYPE zc302mmt0012-scode,
        movetype TYPE zc302mmt0012-movetype,
        budat    TYPE zc302mmt0012-budat,
        menge    TYPE zc302mmt0012-menge,
        meins    TYPE zc302mmt0012-meins,
        waers    TYPE zc302mmt0012-waers,
        netwr    TYPE zc302mmt0012-netwr,
        qinum    TYPE zc302mmt0012-qinum,
        maktx    TYPE zc302mmt0012-maktx,
        bpcode    TYPE zc302mmt0012-bpcode,
    END OF gs_doc_item,
    gt_doc_item LIKE TABLE OF gs_doc_item.

DATA : gt_fcat   TYPE lvc_t_fcat,
       gs_fcat   TYPE lvc_s_fcat,
       gs_layout TYPE lvc_s_layo,
       gt_pfcat   TYPE lvc_t_fcat,
       gs_pfcat   TYPE lvc_s_fcat,
       gs_playout TYPE lvc_s_layo.

*-- search help 자재문서번호 자재문서연도
DATA : BEGIN OF gs_mbl,
        mblnr TYPE zc302mmt0011-mblnr,
       END OF gs_mbl,
       gt_mbl LIKE TABLE OF gs_mbl.

DATA : BEGIN OF gs_mjahr,
         mjahr TYPE zc302mmt0011-mjahr,
       END OF gs_mjahr,
       gt_mjahr LIKE TABLE OF gs_mjahr.

*-- 자재명 끌고오기 위한 마스터
DATA : gt_master TYPE TABLE OF zc302mt0007,
       gs_master TYPE zc302mt0007.

**********************************************************************
* Common variable
**********************************************************************
DATA : gv_okcode  TYPE sy-ucomm,
       gv_tabix   TYPE sy-tabix,
       gv_count   TYPE i,
       gv_variant TYPE disvariant.
