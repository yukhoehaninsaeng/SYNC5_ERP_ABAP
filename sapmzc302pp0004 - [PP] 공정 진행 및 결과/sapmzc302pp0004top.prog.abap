*&---------------------------------------------------------------------*
*& Include SAPMZC302PP0004TOP                       - Module Pool      SAPMZC302PP0004
*&---------------------------------------------------------------------*
PROGRAM sapmzc302pp0004 MESSAGE-ID k5.

**********************************************************************
*&& TABLES
**********************************************************************
TABLES: zc302ppt0007, zc302ppt0010.

**********************************************************************
*&& Screen Elements
**********************************************************************
RANGES: gr_ponum FOR zc302ppt0007-ponum,
        gr_matnr FOR zc302ppt0007-matnr.

DATA: gv_ponum TYPE zc302ppt0007-ponum,
      gv_matnr TYPE zc302ppt0007-matnr.

**********************************************************************
*&& Class instance
**********************************************************************
DATA: go_container   TYPE REF TO cl_gui_custom_container,
      go_split_cont1 TYPE REF TO cl_gui_splitter_container,
      go_up_cont     TYPE REF TO cl_gui_container,
      go_down_cont   TYPE REF TO cl_guI_container,
      go_split_cont2 TYPE REF TO cl_gui_splitter_container,
      go_left_cont   TYPE REF TO cl_gui_container,
      go_cent_cont   TYPE REF TO cl_gui_container,
      go_right_cont  TYPE REF TO cl_gui_container,
      go_up_grid     TYPE REF TO cl_gui_alv_grid,
      go_left_grid   TYPE REF TO cl_gui_alv_grid,
      go_cent_grid   TYPE REF TO cl_gui_alv_grid,
      go_right_grid  TYPE REF TO cl_gui_alv_grid.

**********************************************************************
*&& Work Area & Internal Table
**********************************************************************
*-- 생산오더
DATA: BEGIN OF gs_order,
        icon    TYPE icon-id.
        INCLUDE STRUCTURE zc302ppt0007.
DATA:   quin(8),
        celltab TYPE lvc_t_styl,
      END OF gs_order,
      gt_order LIKE TABLE OF gs_order.

*-- 공정 진행 로그
DATA: BEGIN OF gs_make,
        icon TYPE icon-id.
        INCLUDE STRUCTURE zc302ppt0010.
DATA: END OF gs_make,
gt_make LIKE TABLE OF gs_make,
  gt_fill LIKE gt_make,
  gs_fill LIKE gs_make,
  gt_pack LIKE gt_make,
  gs_pack LIKE gs_make.

*-- For 공정 진행 로그
DATA: gt_porder_i TYPE TABLE OF zc302ppt0003, " 계획 오더 Item
      gs_porder_i TYPE zc302ppt0003.

DATA: gt_pro_h TYPE TABLE OF ZC302ppt0008,   " 공정 Header
      gs_pro_h TYPE ZC302ppt0008.

DATA: gt_pro_log LIKE gt_make,
      gs_pro_log LIKE gs_make.

*-- 검수 정보
DATA: gt_check TYPE TABLE OF zc302ppt0011,
      gs_check TYPE zc302ppt0011.

*-- 재고관리 업데이트를 위한 계획오더 Item
DATA: gt_porder TYPE TABLE OF zc302ppt0003,
      gs_porder TYPE zc302ppt0003.

*-- 재고관리 테이블
DATA: gt_invman TYPE TABLE OF zc302mmt0013,
      gs_invman TYPE zc302mmt0013.

*-- For Search Help (생산오더번호, 자재코드)
DATA: BEGIN OF gs_ponum,
        ponum TYPE zc302ppt0007-ponum,
        matnr TYPE zc302ppt0007-matnr,
        maktx TYPE zc302ppt0007-maktx,
      END OF gs_ponum,
      gt_ponum LIKE TABLE OF gs_ponum.

DATA: BEGIN OF gs_matnr,
        matnr TYPE zc302mt0007-matnr,
        maktx TYPE zc302mt0007-maktx,
      END OF gs_matnr,
      gt_matnr LIKE TABLE OF gs_matnr.

*-- For ALV
DATA: gt_ufcat   TYPE lvc_t_fcat,
      gs_ufcat   TYPE lvc_s_fcat,
      gt_dfcat   TYPE lvc_t_fcat,
      gs_dfcat   TYPE lvc_s_fcat,
      gs_ulayo   TYPE lvc_s_layo,
      gs_dllayo  TYPE lvc_s_layo,
      gs_dclayo  TYPE lvc_s_layo,
      gs_drlayo  TYPE lvc_s_layo,
      gs_variant TYPE disvariant.

*-- Exclude ALV Toolbar
DATA: gt_ui_functions TYPE ui_functions.

*-- ALV Toolbar 생성
DATA: gs_button TYPE stb_button.

**********************************************************************
*&& Common Variable
**********************************************************************
DATA: gv_okcode TYPE sy-ucomm.

**********************************************************************
*&& Macro
**********************************************************************
DEFINE _get_log.

  CLEAR &1.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE &1
    FROM zc302ppt0010
   WHERE pstep  EQ &2
     AND status EQ '2'.

END-OF-DEFINITION.
DEFINE _make_icon.

  CLEAR &1.
  LOOP AT &2 INTO &1.

    CASE &1-pstep.
      WHEN 'A'.
        &1-icon = icon_physical_sample.
      WHEN 'B'.
        &1-icon = icon_public_files.
      WHEN 'C'.
        &1-icon = icon_packing.
    ENDCASE.

    MODIFY &2 FROM &1 INDEX sy-tabix
                      TRANSPORTING icon.

  ENDLOOP.

END-OF-DEFINITION.
