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
        jobname       TYPE tbtco-jobname,
        jobcount      TYPE tbtco-jobcount,
        progname      TYPE tbtcp-progname,
        sdluname      TYPE tbtco-sdluname,
        sdlstrtdt     TYPE tbtco-sdlstrtdt,
        sdlstrttm     TYPE tbtco-sdlstrttm,
        reldate       TYPE tbtco-reldate,
        reltime       TYPE tbtco-reltime,
        strtdate      TYPE tbtco-strtdate,
        strttime      TYPE tbtco-strttime,
        enddate       TYPE tbtco-enddate,
        endtime       TYPE tbtco-endtime,
        status        TYPE tbtco-status,
        rl_status(20),
      END OF gs_batch_log,
      gt_batch_log LIKE TABLE OF gs_batch_log.

*-- 검수정보
DATA: gt_qcinfo TYPE TABLE OF zc302ppt0011,   " quality check info
      gs_qcinfo TYPE zc302ppt0011.

*-- 자재문서 Header
DATA: gt_md_header TYPE TABLE OF zc302mmt0011,
      gs_md_header TYPE zc302mmt0011.

*-- 자재문서 Item
DATA: gt_md_item TYPE TABLE OF zc302mmt0012,
      gs_md_item TYPE zc302mmt0012.

*-- 재고관리 테이블 header
DATA: gt_inv_h TYPE TABLE OF zc302mmt0013,      " inventory management
      gs_inv_h TYPE zc302mmt0013.

*-- 재고관리 테이블 item
DATA: gt_inv_i TYPE TABLE OF ZC302MMT0002,
      gs_inv_i TYPE ZC302MMT0002.

*-- 생산실적처리
DATA: gt_pro_per TYPE TABLE OF zc302ppt0012,
      gs_pro_per TYPE zc302ppt0012.

*-- 자재마스터
DATA: gt_mat TYPE TABLE OF zc302mt0007,
      gs_mat TYPE zc302mt0007.

*-- BOM
DATA: gt_bom TYPE TABLE OF zc302ppt0004,
      gs_bom TYPE zc302ppt0004.

*-- 공정 Header
DATA: gt_pcode TYPE TABLE OF zc302ppt0008,
      gs_pcode TYPE zc302ppt0008.

*-- 폐기 업데이트용
DATA: gt_dis TYPE TABLE OF ZC302MMT0001,
      gs_dis TYPE ZC302MMT0001.

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

DATA: gv_rtptqua TYPE zc302mmt0013-h_rtptqua,
      gv_mblnr TYPE zc302mmt0011-mblnr.

" 폐기번호 채번용
DATA: gv_year(6),
      gv_month(2),
      gv_day(2).
