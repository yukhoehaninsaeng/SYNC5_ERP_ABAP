*&---------------------------------------------------------------------*
*& Include ZC302RPMM0001TOP                         - Report ZC302RPMM0001
*&---------------------------------------------------------------------*
REPORT zc302rpmm0001 MESSAGE-ID k5.

**********************************************************************
* TABLES
**********************************************************************
TABLES : zc302mmt0001.

**********************************************************************
* Class instance
**********************************************************************
DATA: go_container      TYPE REF TO cl_gui_custom_container,
      go_splitter_cont  TYPE REF TO cl_gui_splitter_container,
      go_top_cont       TYPE REF TO cl_gui_container,
      go_bottom_cont    TYPE REF TO cl_gui_container,
      go_top_grid       TYPE REF TO cl_gui_alv_grid, " 폐기 신청 리스트 alv
      go_bottom_grid    TYPE REF TO cl_gui_alv_grid. " 폐기 처리완료 리스트 alv

*-- For Top-of-page
DATA : go_top_container TYPE REF TO cl_gui_docking_container,
       go_dyndoc_id     TYPE REF TO cl_dd_document,
       go_html_cntrl    TYPE REF TO cl_gui_html_viewer.

**********************************************************************
* Internal table and work area
**********************************************************************
*-- TOP
DATA : BEGIN OF gs_discard,
        disnum    TYPE zc302mmt0001-disnum,    " 폐기번호
        scode     TYPE zc302mmt0001-scode,     " 창고코드
        matnr     TYPE zc302mmt0001-matnr,     " 자재코드
        qinum     TYPE zc302mmt0001-qinum,     " 품질검수번호
        maktx     TYPE zc302mmt0001-maktx,     " 자재명
        disreason TYPE zc302mmt0001-disreason, " 폐기사유
        disreason_t(2),
        dismenge  TYPE zc302mmt0001-dismenge,  " 폐기량
        meins     TYPE zc302mmt0001-meins,     " 단위
        budat     TYPE zc302mmt0001-budat,     " 폐기일자
        emp_num   TYPE zc302mmt0001-emp_num,   " 사원번호
        discost   TYPE zc302mmt0001-discost,   " 폐기비용
        waers     TYPE zc302mmt0001-waers,     " 폐기비용
        bpcode     TYPE zc302mmt0001-bpcode,     " bpcode
        status    TYPE zc302mmt0001-status,    " 상태
        celltab  TYPE lvc_t_styl,
  END OF gs_discard,
  gt_discard LIKE TABLE OF gs_discard.

*-- BOTTOM
DATA : BEGIN OF gs_discard_bottom,
        disnum    TYPE zc302mmt0001-disnum,    " 폐기번호
        scode     TYPE zc302mmt0001-scode,     " 창고코드
        matnr     TYPE zc302mmt0001-matnr,     " 자재코드
        qinum     TYPE zc302mmt0001-qinum,     " 품질검수번호
        maktx     TYPE zc302mmt0001-maktx,     " 자재명
        disreason TYPE zc302mmt0001-disreason, " 폐기사유
        dismenge  TYPE zc302mmt0001-dismenge,  " 폐기량
        meins     TYPE zc302mmt0001-meins,     " 단위
        budat     TYPE zc302mmt0001-budat,     " 폐기일자
        budat2    TYPE d,                        " 폐기처리 상태
        emp_num   TYPE zc302mmt0001-emp_num,   " 사원번호
        discost   TYPE zc302mmt0001-discost,   " 폐기비용
        bpcode     TYPE zc302mmt0001-bpcode,     " bpcode
        waers     TYPE zc302mmt0001-waers,     " 통화
        status    TYPE zc302mmt0001-status,    " 처리상태
        status_text(5),
  END OF gs_discard_bottom,
  gt_discard_bottom LIKE TABLE OF gs_discard_bottom.

DATA : gt_fcat    TYPE lvc_t_fcat, " top alv
       gs_fcat    TYPE lvc_s_fcat,
       gs_layout  TYPE lvc_s_layo,
       gt_bfcat   TYPE lvc_t_fcat, " bottom alv
       gs_bfcat   TYPE lvc_s_fcat,
       gs_blayout TYPE lvc_s_layo.

*-- alv toolbar
DATA : gs_button TYPE stb_button.


*-- text editor
DATA : go_text_cont  TYPE REF TO cl_gui_custom_container,
       go_text_edit  TYPE REF TO cl_gui_textedit.
DATA : BEGIN OF gs_content,
         tdline TYPE tdline,
       END OF gs_content,
       gt_content LIKE TABLE OF gs_content.

**********************************************************************
* common variable
**********************************************************************
DATA : gv_okcode  TYPE sy-ucomm,
       gv_tabix   TYPE sy-tabix,
       gv_count   TYPE i,
       gv_variant TYPE disvariant,
       gv_mode(2).

DATA : gv_disreason TYPE zc302mmt0001-disreason.
