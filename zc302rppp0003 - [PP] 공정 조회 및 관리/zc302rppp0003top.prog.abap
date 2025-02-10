*&---------------------------------------------------------------------*
*& Include ZC302RPPP0004TOP                         - Module Pool      ZC302RPPP0004
*&---------------------------------------------------------------------*
PROGRAM zc302rppp0004 MESSAGE-ID k5.

**********************************************************************
*&& TABLES
**********************************************************************
TABLES: zc302ppt0008, zc302ppt0009.

**********************************************************************
*&& Macro
**********************************************************************
DEFINE _left_tbar.

  gs_left_btn-function  = &1.
  gs_left_btn-icon      = &2.
  gs_left_btn-text      = &3.
  gs_left_btn-quickinfo = &4.
  gs_left_btn-disabled  = &5.
  gs_left_btn-butn_type = &6.

  APPEND gs_left_btn TO po_object->mt_toolbar.
  CLEAR gs_left_btn.

END-OF-DEFINITION.
DEFINE _right_tbar.

  gs_right_btn-function  = &1.
  gs_right_btn-icon      = &2.
  gs_right_btn-text      = &3.
  gs_right_btn-quickinfo = &4.
  gs_right_btn-disabled  = &5.
  gs_right_btn-butn_type = &6.

  APPEND gs_right_btn TO po_object->mt_toolbar.
  CLEAR gs_right_btn.

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
DATA: go_container  TYPE REF TO cl_gui_docking_container,
      go_split_cont TYPE REF TO cl_gui_splitter_container,
      go_left_cont  TYPE REF TO cl_gui_container,
      go_right_cont TYPE REF TO cl_gui_container.

DATA: go_left_grid  TYPE REF TO cl_gui_alv_grid,
      go_right_grid TYPE REF TO cl_gui_alv_grid.

DATA: go_top_container TYPE REF TO cl_gui_docking_container,
      go_dyndoc_id     TYPE REF TO cl_dd_document,           " TOP-OF-PAGE 구성을 위한 클래스
      go_html_cntrl    TYPE REF TO cl_gui_html_viewer.

**********************************************************************
*&& Work Area & Internal Table
**********************************************************************
DATA: BEGIN OF gs_header.
        INCLUDE STRUCTURE zc302ppt0008.
DATA:   celltab TYPE lvc_t_styl,
        color   TYPE lvc_t_scol,
      END OF gs_header,
      gt_header LIKE TABLE OF gs_header.

DATA: BEGIN OF gs_item.
        INCLUDE STRUCTURE zc302ppt0009.
DATA:   celltab TYPE lvc_t_styl,
        color   TYPE lvc_t_scol,
      END OF gs_item,
      gt_item LIKE TABLE OF gs_item.

DATA: gt_lfcat   TYPE lvc_t_fcat,
      gt_rfcat   TYPE lvc_t_fcat,
      gs_lfcat   TYPE lvc_s_fcat,
      gs_rfcat   TYPE lvc_s_fcat,
      gs_llayo   TYPE lvc_s_layo,
      gs_rlayo   TYPE lvc_s_layo,
      gs_variant TYPE disvariant.

*-- For Search Help (공정코드, BOM ID)
DATA: BEGIN OF gs_pcode,
        pcode TYPE zc302ppt0008-pcode,
        psdtl TYPE zc302ppt0008-psdtl,
        matnr TYPE zc302ppt0008-matnr,
      END OF gs_pcode,
      gt_pcode LIKE TABLE OF gs_pcode.

DATA: BEGIN OF gs_bomid,
        bomid TYPE zc302ppt0004-bomid,
        matnr TYPE zc302ppt0004-matnr,
        maktx TYPE zc302ppt0004-maktx,
      END OF gs_bomid,
      gt_bomid LIKE TABLE OF gs_bomid.

*-- ITAB for Delete
DATA: gt_left_del  TYPE TABLE OF zc302ppt0008,
      gs_left_del  TYPE zc302ppt0008,
      gt_right_del TYPE TABLE OF zc302ppt0009,
      gs_right_del TYPE zc302ppt0009.

*-- ALV Toolbar 제외
DATA: gt_ui_functions TYPE ui_functions.

*-- ALV Toolbar 생성( 토글, 생성, 수정 )
DATA: gs_left_btn  TYPE stb_button,
      gs_right_btn TYPE stb_button.

**********************************************************************
*&& Common Variable
**********************************************************************
DATA: gv_okcode   TYPE sy-ucomm,
      gv_left_md  VALUE 'D',
      gv_right_md VALUE 'D'.
