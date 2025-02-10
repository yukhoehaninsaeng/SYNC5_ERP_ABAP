*&---------------------------------------------------------------------*
*& Include SAPMZC302FI0005TOP                       - Module Pool      SAPMZC302FI0005
*&---------------------------------------------------------------------*
PROGRAM sapmzc302fi0005 MESSAGE-ID k5.

*--------------------------------------------------------------------*
* Tables
*--------------------------------------------------------------------*
TABLES : zc302fit0005, tbtco.

*--------------------------------------------------------------------*
* Tabstrip Controls
*--------------------------------------------------------------------*
CONTROLS : go_tab TYPE TABSTRIP.

DATA: gv_subscreen TYPE sy-dynnr,
      gv_tab       TYPE sy-ucomm VALUE 'TAB1'.

*--------------------------------------------------------------------*
* Itab and Wa
*--------------------------------------------------------------------*
DATA : gs_body TYPE zc302fit0005,           " 환율 정보
       gt_body TYPE TABLE OF zc302fit0005,
       BEGIN OF gs_log,                     " 배치잡 로그
         jobname        TYPE tbtco-jobname,
         jobcount       TYPE tbtco-jobcount,
         sdluname       TYPE tbtco-sdluname,
         strtdate       TYPE tbtco-strtdate,
         strttime       TYPE tbtco-strttime,
         status         TYPE tbtco-status,
         reldate        TYPE tbtco-reldate,
         reltime        TYPE tbtco-reltime,
         enddate        TYPE tbtco-enddate,
         endtime        TYPE tbtco-endtime,
         periodic       TYPE tbtco-periodic,
         status_des(40),
         color          TYPE lvc_t_scol,
       END OF gs_log,
       gt_log LIKE TABLE OF gs_log.

DATA : gs_usa TYPE zc302fit0005,            " 미국 환율
       gt_usa TYPE TABLE OF zc302fit0005,
       gs_jpn TYPE zc302fit0005,            " 일본 환율
       gt_jpn TYPE TABLE OF zc302fit0005,
       gs_chn TYPE zc302fit0005,            " 중국 환율
       gt_chn TYPE TABLE OF zc302fit0005,
       gs_eur TYPE zc302fit0005,
       gt_eur TYPE TABLE OF zc302fit0005.

" 3번 스크린 차트 데이터
DATA : gt_value_usa    TYPE TABLE OF gprval WITH HEADER LINE,
       gt_value_jpn    TYPE TABLE OF gprval WITH HEADER LINE,
       gt_value_chn    TYPE TABLE OF gprval WITH HEADER LINE,
       gt_value_eur    TYPE TABLE OF gprval WITH HEADER LINE,
       gt_col_text_usa TYPE TABLE OF gprtxt WITH HEADER LINE,
       gt_col_text_jpn TYPE TABLE OF gprtxt WITH HEADER LINE,
       gt_col_text_chn TYPE TABLE OF gprtxt WITH HEADER LINE,
       gt_col_text_eur TYPE TABLE OF gprtxt WITH HEADER LINE.

*--------------------------------------------------------------------*
* Screen Element
*--------------------------------------------------------------------*
DATA : gv_nation  TYPE zc302fit0005-nation,     " 국가
       gv_fcurr   TYPE zc302fit0005-fcurr,       " 기존 통화
       gv_tcurr   TYPE zc302fit0005-tcurr,       " 변환 통화
       gv_edate   TYPE zc302fit0005-edate,       " 환율 적용일
       gv_exrate  TYPE zc302fit0005-exrate,     " 환율
       gv_jobname TYPE tbtco-jobname           " 배치잡 이름
                  VALUE 'ZC302FI_BATCH'.

" 102번 스크린 라디오 버튼
DATA : gv_all, gv_release, gv_ready, gv_active, gv_finish, gv_canceled.

RANGES: gr_nation FOR zc302fit0005-nation,
        gr_fcurr FOR zc302fit0005-fcurr,
        gr_tcurr FOR zc302fit0005-tcurr,
        gr_edate FOR zc302fit0005-edate,
        gr_exrate FOR zc302fit0005-exrate,
        gr_jobname FOR tbtco-jobname.

*--------------------------------------------------------------------*
* Class
*--------------------------------------------------------------------*
" alv
DATA : go_cont_exr TYPE REF TO cl_gui_custom_container, " 환율
       go_grid_exr TYPE REF TO cl_gui_alv_grid,
       go_cont_log TYPE REF TO cl_gui_custom_container, " 배치잡 로그
       go_grid_log TYPE REF TO cl_gui_alv_grid,
       gt_fcat_exr TYPE lvc_t_fcat,
       gt_fcat_log TYPE lvc_t_fcat,
       gs_fcat     TYPE lvc_s_fcat,
       gs_layo     TYPE lvc_s_layo,
       gs_layo2    TYPE lvc_s_layo.

" chart
DATA : go_cont_usa TYPE REF TO cl_gui_custom_container,
       go_cont_chn TYPE REF TO cl_gui_custom_container,
       go_cont_jpn TYPE REF TO cl_gui_custom_container,
       go_cont_eur TYPE REF TO cl_gui_custom_container.

*--------------------------------------------------------------------*
* Common Variable
*--------------------------------------------------------------------*
DATA : gv_okcode TYPE sy-ucomm,
       gv_lines  TYPE sy-dbcnt,
       gv_tabix  TYPE sy-tabix.
