*&---------------------------------------------------------------------*
*& Include ZC302RPMM0009TOP                         - Report ZC302RPMM0009
*&---------------------------------------------------------------------*
REPORT zc302rpmm0009 MESSAGE-ID k5.

TABLES : zc302mmt0009, zc302mmt0007.

**********************************************************************
* Macro
**********************************************************************
DEFINE _clear.

  REFRESH &1.
  CLEAR   &2.

END-OF-DEFINITION.

**********************************************************************
* Class
**********************************************************************
DATA: go_dock_cont   TYPE REF TO cl_gui_custom_container,
      go_split_cont  TYPE REF TO cl_gui_splitter_container,
      go_left_cont   TYPE REF TO cl_gui_container,
      go_right_cont  TYPE REF TO cl_gui_container,
      go_split_cont2 TYPE REF TO cl_gui_splitter_container,
      go_up_cont     TYPE REF TO cl_gui_container,
      go_down_cont   TYPE REF TO cl_gui_container,
      go_left_grid   TYPE REF TO cl_gui_alv_grid,
      go_up_grid     TYPE REF TO cl_gui_alv_grid,
      go_down_grid   TYPE REF TO cl_gui_alv_grid.


*-- Top of Page
DATA : go_top_cont   TYPE REF TO cl_gui_custom_container,
       go_dyndoc_id  TYPE REF TO cl_dd_document,
       go_html_cntrl TYPE REF TO cl_gui_html_viewer.

**********************************************************************
* Work Area & Internal
**********************************************************************
*-- ALV1
DATA : gs_po TYPE zc302mmt0007,           " 구매오더
       gt_po TYPE TABLE OF zc302mmt0007.

*-- ALV2
DATA : BEGIN OF gs_body.         " 송장검증
         INCLUDE TYPE zc302mmt0009.
DATA :   icon TYPE icon-id,
       END   OF gs_body,
       gt_body LIKE TABLE OF gs_body.

*-- ALV3
DATA : BEGIN OF gs_body2.         " 송장검증
         INCLUDE TYPE zc302mmt0009.
DATA :   icon TYPE icon-id,
       END   OF gs_body2,
       gt_body2 LIKE TABLE OF gs_body.

DATA : gs_temp TYPE zc302mmt0009,         " 송장검증
       gt_temp TYPE TABLE OF zc302mmt0009.

DATA : gs_qc TYPE zc302mmt0006,           " 품질검수
       gt_qc TYPE TABLE OF zc302mmt0006.

DATA : gs_iv TYPE zc302mmt0010,
       gt_iv TYPE TABLE OF zc302mmt0010.  " 개러채 송잘

*-- employee info
DATA : gs_employee TYPE zc302mt0003,
       gt_employee TYPE TABLE OF zc302mt0003.

DATA : BEGIN OF gs_f4,
         aufnr TYPE zc302mmt0007-aufnr,
       END OF gs_f4,
       gt_f4 LIKE TABLE OF gs_f4.

DATA : gt_fcat1 TYPE lvc_t_fcat,
       gs_fcat1 TYPE lvc_s_fcat,
       gs_layo  TYPE lvc_s_layo.

DATA : gt_fcat2 TYPE lvc_t_fcat,
       gs_fcat2 TYPE lvc_s_fcat,
       gs_layo2 TYPE lvc_s_layo.

DATA : gt_fcat3 TYPE lvc_t_fcat,
       gs_fcat3 TYPE lvc_s_fcat,
       gs_layo3 TYPE lvc_s_layo.

*-- ALV Toolbar 생성
DATA : gs_center_btn TYPE stb_button,
       gs_right_btn  TYPE stb_button.

*-- Exclude ALV Toolbar
DATA : gt_ui_functions TYPE ui_functions.

**********************************************************************
* Common Variable
**********************************************************************
DATA : gv_tabix   TYPE sy-tabix,
       gv_okcode  TYPE sy-ucomm,
       gv_variant TYPE disvariant.

DATA : gv_emp_num  TYPE zc302mt0003-emp_num,
       gv_ename    TYPE zc302mt0003-ename,
       gv_orgtx    TYPE zc302mt0003-orgtx,
       gv_plstx    TYPE zc302mt0003-plstx,
       gv_year(6),
       gv_month(2),
       gv_day(2).
