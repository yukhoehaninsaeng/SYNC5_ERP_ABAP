*&---------------------------------------------------------------------*
*& Include ZC302RPPP0002TOP                         - Report ZC302RPPP0002
*&---------------------------------------------------------------------*
REPORT zc302rppp0002 MESSAGE-ID k5.

**********************************************************************
*&& TABLES
**********************************************************************
TABLES: zc302ppt0012.

**********************************************************************
*&& Macro
**********************************************************************
DEFINE _toolbar.

  gs_button-function  = &1.
  gs_button-icon      = &2.
  gs_button-text      = &3.
  gs_button-quickinfo = &4.
  gs_button-disabled  = &5.
  gs_button-butn_type = &6.

  APPEND gs_button TO po_object->mt_toolbar.
  CLEAR gs_button.

END-OF-DEFINITION.
DEFINE _set_top.

  CLEAR: &3, &4.
  IF &1 IS NOT INITIAL.
    &2 = &1-low.
    IF &1-high IS NOT INITIAL.
      &3  = '~'.
      &4 = &1-high.
    ENDIF.
  ELSE.
    &2 = '전체'.
  ENDIF.

END-OF-DEFINITION.
DEFINE _init.

  REFRESH &1.
  CLEAR &1.

END-OF-DEFINITION.

**********************************************************************
*&& Class instance
**********************************************************************
DATA: go_container     TYPE REF TO cl_gui_docking_container,
      go_alv_grid      TYPE REF TO cl_gui_alv_grid,
      go_top_container TYPE REF TO cl_gui_docking_container,
      go_dyndoc_id     TYPE REF TO cl_dd_document,           " TOP-OF-PAGE 구성을 위한 클래스
      go_html_cntrl    TYPE REF TO cl_gui_html_viewer.

**********************************************************************
*&& Work Area & Internal Table
**********************************************************************
DATA: BEGIN OF gs_prpe.
        INCLUDE STRUCTURE zc302ppt0012.
DATA:   celltab TYPE lvc_t_styl,
        color   TYPE lvc_t_scol,
      END OF gs_prpe,
      gt_prpe LIKE TABLE OF gs_prpe.

DATA: gt_fcat   TYPE lvc_t_fcat,
      gs_fcat   TYPE lvc_s_fcat,
      gs_layout TYPE lvc_s_layo,
      gs_variant TYPE disvariant.

*-- For Search Help (품질검수번호, 생산오더번호, 자재코드)
DATA: BEGIN OF gs_qin_pon,
        qinum TYPE zc302ppt0012-qinum,
        ponum TYPE zc302ppt0012-ponum,
        matnr TYPE zc302ppt0012-matnr,
        maktx TYPE zc302ppt0012-maktx,
      END OF gs_qin_pon,
      gt_qin_pon LIKE TABLE OF gs_qin_pon.

*-- ITAB for Delete
DATA: gt_delt TYPE TABLE OF zc302ppt0012,
      gs_delt TYPE zc302ppt0012.

DATA: gt_ui_functions TYPE ui_functions.

*-- ALV Toolbar 생성( 토글, 생성, 수정 )
DATA: gs_button  TYPE stb_button.

**********************************************************************
*&& Common Variable
**********************************************************************
DATA: gv_okcode TYPE sy-ucomm,
      gv_mode   VALUE 'D'.
