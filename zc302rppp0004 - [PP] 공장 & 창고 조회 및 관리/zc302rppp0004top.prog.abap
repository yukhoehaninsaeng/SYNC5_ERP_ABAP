*&---------------------------------------------------------------------*
*& Include ZC302RPPP0005TOP                         - Report ZC302RPPP0005
*&---------------------------------------------------------------------*
REPORT zc302rppp0005 MESSAGE-ID k5.

**********************************************************************
* TABLES
**********************************************************************
TABLES : zc302mt0004, zc302mt0005.

**********************************************************************
* Macro
**********************************************************************
*-- 공장
DEFINE _up_tbar.

  gs_up_btn-function  = &1.
  gs_up_btn-icon      = &2.
  gs_up_btn-text      = &3.
  gs_up_btn-quickinfo = &4.
  gs_up_btn-disabled  = &5.
  gs_up_btn-butn_type = &6.

  APPEND gs_up_btn TO po_object->mt_toolbar.
  CLEAR gs_up_btn.

END-OF-DEFINITION.

*-- 창고
DEFINE _down_tbar.

  gs_down_btn-function  = &1.
  gs_down_btn-icon      = &2.
  gs_down_btn-text      = &3.
  gs_down_btn-quickinfo = &4.
  gs_down_btn-disabled  = &5.
  gs_down_btn-butn_type = &6.

  APPEND gs_down_btn TO po_object->mt_toolbar.
  CLEAR gs_down_btn.

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
       go_up_cont    TYPE REF TO cl_gui_container,
       go_down_cont  TYPE REF TO cl_gui_container.

DATA : go_up_grid   TYPE REF TO cl_gui_alv_grid,
       go_down_grid TYPE REF TO cl_gui_alv_grid.

*-- For TOP-OF-PAGE
DATA : go_top_container TYPE REF TO cl_gui_docking_container,
       go_dyndoc_id     TYPE REF TO cl_dd_document,
       go_html_cntrl    TYPE REF TO cl_gui_html_viewer.

**********************************************************************
* Internal table and Work area
**********************************************************************
DATA : BEGIN OF gs_plant.
         INCLUDE STRUCTURE zc302mt0004.
DATA :   celltab TYPE lvc_t_styl,
         color   TYPE lvc_t_scol,
       END OF gs_plant,
       gt_plant LIKE TABLE OF gs_plant.

DATA : BEGIN OF gs_stl.
         INCLUDE STRUCTURE zc302mt0005.
DATA :   celltab TYPE lvc_t_styl,
         color   TYPE lvc_t_scol,
       END OF gs_stl,
       gt_stl LIKE TABLE OF gs_stl.


*-- For ALV
DATA : gt_ufcat   TYPE lvc_t_fcat,
       gt_dfcat   TYPE lvc_t_fcat,
       gs_ufcat   TYPE lvc_s_fcat,
       gs_dfcat   TYPE lvc_s_fcat,
       gs_ulayout TYPE lvc_s_layo,
       gs_dlayout TYPE lvc_s_layo,
       gs_variant TYPE disvariant.

*-- ITAB For Delete
DATA: gt_up_del   TYPE TABLE OF zc302mt0004,
      gs_up_del   TYPE zc302mt0004,
      gt_down_del TYPE TABLE OF zc302mt0005,
      gs_down_del TYPE zc302mt0005.

*-- ALV Toolbar 제외
DATA : gt_ui_functions TYPE ui_functions.

*-- ALV Toolbar 생성 (토글, 생성, 수정)
DATA : gs_up_btn   TYPE stb_button,
       gs_down_btn TYPE stb_button.

**********************************************************************
* Common variable
**********************************************************************
DATA : gv_okcode  TYPE sy-ucomm,
       gv_up_md   VALUE 'D',         " 모드
       gv_down_md VALUE 'D'.
