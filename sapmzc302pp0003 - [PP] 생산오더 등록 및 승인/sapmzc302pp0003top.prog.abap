*&---------------------------------------------------------------------*
*& Include SAPMZC302PP0003TOP                       - Module Pool      SAPMZC302PP0003
*&---------------------------------------------------------------------*
PROGRAM sapmzc302pp0003 MESSAGE-ID k5.

**********************************************************************
*&& TABLES
**********************************************************************
TABLES: zc302ppt0002, zc302ppt0003, zc302ppt0007.

**********************************************************************
*&& Screen elements
**********************************************************************
RANGES: gr_plord FOR zc302ppt0002-plordco,
        gr_matnr FOR zc302ppt0002-matnr.

DATA: gv_plord TYPE zc302ppt0002-plordco,
      gv_matnr TYPE zc302ppt0002-matnr.

DATA: gv_emp_num TYPE zc302mt0003-emp_num,
      gv_ename   TYPE zc302mt0003-ename.

**********************************************************************
*&& Macro
**********************************************************************
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

**********************************************************************
*&& Class instance
**********************************************************************
DATA: go_container   TYPE REF TO cl_gui_custom_container,
      go_split_cont1 TYPE REF TO cl_gui_splitter_container,
      go_left_cont   TYPE REF TO cl_gui_container,
      go_split_cont2 TYPE REF TO cl_gui_splitter_container,
      go_up_cont     TYPE REF TO cl_gui_container,
      go_down_cont   TYPE REF TO cl_gui_container,
      go_right_cont  TYPE REF TO cl_gui_container,
      go_up_grid     TYPE REF TO cl_gui_alv_grid,
      go_down_grid   TYPE REF TO cl_gui_alv_grid,
      go_right_grid  TYPE REF TO cl_gui_alv_grid.

**********************************************************************
*&& Work Area & Internal Table
**********************************************************************
*-- 계획오더 Header
DATA: BEGIN OF gs_plan_h,
        icon TYPE icon-id.
        INCLUDE STRUCTURE zc302ppt0002.
DATA: END OF gs_plan_h,
gt_plan_h LIKE TABLE OF gs_plan_h.

*-- 계획오더 Item
DATA: BEGIN OF gs_plan_i,
        mname(3).
        INCLUDE STRUCTURE zc302ppt0003.
DATA:   color    TYPE lvc_t_scol,
      END OF gs_plan_i,
      gt_plan_i LIKE TABLE OF gs_plan_i.

*-- 계획오더 Item 업데이트
DATA: gt_odi_update LIKE gt_plan_i,
      gs_odi_update LIKE gs_plan_i.

DATA: gt_inv_man TYPE TABLE OF zc302mmt0013,
      gs_inv_man TYPE zc302mmt0013.

*-- 생산오더
DATA: BEGIN OF gs_order,
        icon TYPE icon-id.
        INCLUDE STRUCTURE zc302ppt0007.
DATA: END OF gs_order,
gt_order LIKE TABLE OF gs_order.

*-- For Srch Help IN Screen 100 (계획오더번호, 자재코드)
DATA: BEGIN OF gs_plord,
        plordco TYPE zc302ppt0002-plordco,
        matnr   TYPE zc302ppt0003-matnr,
        maktx   TYPE zc302ppt0003-maktx,
      END OF gs_plord,
      gt_plord LIKE TABLE OF gs_plord.

DATA: BEGIN OF gs_matnr,
        matnr TYPE zc302mt0007-matnr,
        maktx TYPE zc302mt0007-maktx,
      END OF gs_matnr,
      gt_matnr LIKE TABLE OF gs_matnr.

*-- For Srch Help IN Screen 101 (사원번호, 사원명)
DATA: BEGIN OF gs_emp,
        emp_num TYPE zc302mt0003-emp_num,
        ename   TYPE zc302mt0003-ename,
      END OF gs_emp,
      gt_emp LIKE TABLE OF gs_emp.

*-- For ALV
DATA: gt_ufcat   TYPE lvc_t_fcat,
      gs_ufcat   TYPE lvc_s_fcat,
      gt_dfcat   TYPE lvc_t_fcat,
      gs_dfcat   TYPE lvc_s_fcat,
      gt_rfcat   TYPE lvc_t_fcat,
      gs_rfcat   TYPE lvc_s_fcat,
      gs_ulayo   TYPE lvc_s_layo,
      gs_dlayo   TYPE lvc_s_layo,
      gs_rlayo   TYPE lvc_s_layo,
      gs_variant TYPE disvariant.

*-- Exclude ALV Toolbar
DATA: gt_ui_functions TYPE ui_functions.

*-- ALV Toolbar 생성
DATA: gs_button TYPE stb_button.

**********************************************************************
*&& Common Variable
**********************************************************************
DATA: gv_okcode TYPE sy-ucomm.
