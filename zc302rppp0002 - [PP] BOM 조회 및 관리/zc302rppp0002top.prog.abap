*&---------------------------------------------------------------------*
*& Include ZC302RPPP0003TOP                         - Report ZC302RPPP0003
*&---------------------------------------------------------------------*
REPORT zc302rppp0003 MESSAGE-ID k5.

**********************************************************************
* TABLES
**********************************************************************
TABLES: zc302ppt0004, zc302ppt0005.

**********************************************************************
* Macro
**********************************************************************
*-- 왼쪽
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
*-- 오른쪽
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

" TOP OF PAGE에서 사용할 매크로
DEFINE _set_top.

  CLEAR : &3, &4.
  IF &1 IS NOT INITIAL.
    &2 = &1-low.
    IF &1-high IS NOT INITIAL.
      &3 = '~'.
      &4 = &1-high.
    ENDIF.
  ELSE.
    &2 = '전체'.
  ENDIF.

END-OF-DEFINITION.

**********************************************************************
* Class instance
**********************************************************************
DATA : go_container  TYPE REF TO cl_gui_docking_container,
       go_split_cont TYPE REF TO cl_gui_splitter_container,
       go_left_cont  TYPE REF TO cl_gui_container,
       go_right_cont TYPE REF TO cl_gui_container.

DATA : go_left_grid  TYPE REF TO cl_gui_alv_grid,
       go_right_grid TYPE REF TO cl_gui_alv_grid.

*-- For TOP-OF-PAGE
DATA : go_top_container TYPE REF TO cl_gui_docking_container,
       go_dyndoc_id     TYPE REF TO cl_dd_document,
       go_html_cntrl    TYPE REF TO cl_gui_html_viewer.

**********************************************************************
* Internal table and Work area
**********************************************************************
DATA : BEGIN OF gs_bomhead.
         INCLUDE STRUCTURE zc302ppt0004.
DATA :   celltab TYPE lvc_t_styl,           " 편집
         color   TYPE lvc_t_scol,
       END OF gs_bomhead,
       gt_bomhead LIKE TABLE OF gs_bomhead.

DATA : BEGIN OF gs_bomitem.
         INCLUDE STRUCTURE zc302ppt0005.
DATA :   celltab TYPE lvc_t_styl,
         color   TYPE lvc_t_scol,
       END OF gs_bomitem,
       gt_bomitem LIKE TABLE OF gs_bomitem.

*-- For ALV
DATA : gt_lfcat   TYPE lvc_t_fcat,
       gt_rfcat   TYPE lvc_t_fcat,
       gs_lfcat   TYPE lvc_s_fcat,
       gs_rfcat   TYPE lvc_s_fcat,
       gs_llayout TYPE lvc_s_layo,
       gs_rlayout TYPE lvc_s_layo,
       gs_variant TYPE disvariant.

*-- For search help (BOM ID, 자재코드)
DATA : BEGIN OF gs_bomid,
         bomid TYPE zc302ppt0004-bomid,
         matnr TYPE zc302ppt0004-matnr,
         maktx TYPE zc302ppt0004-maktx,
       END OF gs_bomid,
       gt_bomid LIKE TABLE OF gs_bomid.

DATA : BEGIN OF gs_matnr,
         matnr TYPE zc302mt0007-matnr,  " 자재코드
         maktx TYPE zc302mt0007-maktx,  " 자재명
*         mtart TYPE zc302mt0007-mtart,  " 자재유형
         gewei TYPE zc302mt0007-gewei,  " 단위
         matlt TYPE zc302mt0007-matlt,  " 구매 리드타임
       END OF gs_matnr,
       gt_matnr LIKE TABLE OF gs_matnr.


*-- ITAB For Delete
DATA: gt_left_del  TYPE TABLE OF zc302ppt0004,
      gs_left_del  TYPE zc302ppt0004,
      gt_right_del TYPE TABLE OF zc302ppt0005,
      gs_right_del TYPE zc302ppt0005.

*-- ALV Toolbar 제외
DATA : gt_ui_functions TYPE ui_functions.

*-- ALV Toolbar 생성 (토글, 생성, 수정)
DATA: gs_left_btn  TYPE stb_button,
      gs_right_btn TYPE stb_button.

**********************************************************************
* Common variable
**********************************************************************
DATA : gv_okcode   TYPE sy-ucomm,
       gv_left_md  VALUE 'D',         " 모드
       gv_right_md VALUE 'D'.
