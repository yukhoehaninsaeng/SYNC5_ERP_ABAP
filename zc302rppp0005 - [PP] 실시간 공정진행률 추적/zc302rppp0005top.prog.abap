*&---------------------------------------------------------------------*
*& Include ZC302RPPP0006TOP                         - Report ZC302RPPP0006
*&---------------------------------------------------------------------*
REPORT zc302rppp0006 MESSAGE-ID k5.

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
*-- 배치잡 기록 조회
DATA: BEGIN OF gs_batch_log,
        jobname   TYPE tbtco-jobname,
        jobcount  TYPE tbtco-jobcount,
        progname  TYPE tbtcp-progname,
        sdluname  TYPE tbtco-sdluname,
        sdlstrtdt TYPE tbtco-sdlstrtdt,
        sdlstrttm TYPE tbtco-sdlstrttm,
        reldate   TYPE tbtco-reldate,
        reltime   TYPE tbtco-reltime,
        strtdate  TYPE tbtco-strtdate,
        strttime  TYPE tbtco-strttime,
        enddate   TYPE tbtco-enddate,
        endtime   TYPE tbtco-endtime,
        status    TYPE tbtco-status,
        rl_status(20),
        color     TYPE lvc_t_scol,
      END OF gs_batch_log,
      gt_batch_log LIKE TABLE OF gs_batch_log.

*-- 생산 오더
DATA: gt_order TYPE TABLE OF zc302ppt0007,
      gs_order TYPE zc302ppt0007.

*-- 공정 진행 로그
DATA: gt_pro_log TYPE TABLE OF ZC302ppt0010,
      gs_pro_log TYPE ZC302ppt0010.

DATA: gt_make TYPE TABLE OF zc302ppt0010,
      gs_make TYPE zc302ppt0010,
      gt_fill TYPE TABLE OF zc302ppt0010,
      gs_fill TYPE zc302ppt0010,
      gt_pack TYPE TABLE OF zc302ppt0010,
      gs_pack TYPE zc302ppt0010.

*-- 재고관리
DATA: gt_invman TYPE TABLE OF zc302mmt0013,
      gs_invman TYPE zc302mmt0013.

*-- For ALV
DATA: gt_fcat    TYPE lvc_t_fcat,
      gs_fcat    TYPE lvc_s_fcat,
      gs_layout  TYPE lvc_s_layo,
      gs_variant TYPE disvariant.

*-- Exclude ALV Toolbar
DATA: gt_ui_functions TYPE ui_functions.

**********************************************************************
*&& Common Variable
**********************************************************************
DATA: gv_okcode TYPE sy-ucomm,
      gv_count  TYPE i.
