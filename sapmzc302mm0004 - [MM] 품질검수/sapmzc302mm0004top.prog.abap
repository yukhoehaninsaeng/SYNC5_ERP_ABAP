*&---------------------------------------------------------------------*
*& Include SAPMZC302MM0004TOP                       - Module Pool      SAPMZC302MM0004
*&---------------------------------------------------------------------*
PROGRAM sapmzc302mm0004 MESSAGE-ID k5.

TABLES : zc302mmt0006.

***********************************************************************
** Macro
***********************************************************************
DEFINE _clear.

  REFRESH &1.
  CLEAR &2.

END-OF-DEFINITION.

**********************************************************************
* class
**********************************************************************
*-- Main Screen
DATA : go_cont       TYPE REF TO cl_gui_custom_container,
       go_split_cont TYPE REF TO cl_gui_splitter_container,
       go_up_cont    TYPE REF TO cl_gui_container,
       go_down_cont  TYPE REF TO cl_gui_container,
       go_alv_grid   TYPE REF TO cl_gui_alv_grid,            " UP Grid
       go_down_grid  TYPE REF TO cl_gui_alv_grid.            " Down Grid

*-- Popup Screen
DATA : go_pop_cont TYPE REF TO cl_gui_custom_container,
       go_pop_gird TYPE REF TO cl_gui_alv_grid.

*-- text editor
DATA : go_text_cont  TYPE REF TO cl_gui_custom_container,
       go_text_edit  TYPE REF TO cl_gui_textedit,
       go_text_cont2 TYPE REF TO cl_gui_custom_container,
       go_text_edit2 TYPE REF TO cl_gui_textedit.

**********************************************************************
* Internal table & Work Area
**********************************************************************
DATA : BEGIN OF gs_body,
         aufnr      TYPE zc302mmt0006-aufnr,         " 구매오더번호
         plordco    TYPE zc302mmt0006-plordco,       " 계획오더본호
         qinum      TYPE zc302mmt0006-qinum,         " 품질검수번호
         qstat      TYPE zc302mmt0006-qstat,         " 검수상태
         matnr      TYPE zc302mmt0006-matnr,         " 자재코드
         maktx      TYPE zc302mmt0006-maktx,         " 자재명
         mblnr      TYPE zc302mmt0006-mblnr,         " 입출고번호 -채번
         disnum     TYPE zc302mmt0006-disnum,        " 폐기번호
         hbldat     TYPE zc302mmt0006-hbldat,        " 희망송장일자
         bldat      TYPE zc302mmt0006-bldat,         " 송장일자
         xblnr      TYPE zc302mmt0006-xblnr,         " 송장번호 -채번
         bpcode     TYPE zc302mmt0006-bpcode,        " bp코드
         emp_num    TYPE zc302mmt0006-emp_num,       " 사원번호
         ename      TYPE zc302mmt0006-ename,         " 사원이름
         scode      TYPE zc302mmt0006-scode,         " 창고코드
         menge      TYPE zc302mmt0006-menge,         " 수량
         qimenge    TYPE zc302mmt0006-qimenge,       " 최종입고수량
         disreason  TYPE zc302mmt0006-disreason,     " 폐기사유
         dismenge   TYPE zc302mmt0006-dismenge,      " 폐기량
         faulper    TYPE zc302mmt0006-faulper,       " 불량률
         meins      TYPE zc302mmt0006-meins,         " 단위
         hbudat     TYPE zc302mmt0006-hbudat,        " 희망입고일자
         budat      TYPE zc302mmt0006-budat,         " 입고날짜`
         hpastrterm TYPE zc302mmt0006-hpastrterm,    " 희망 검수일
         pastrterm  TYPE zc302mmt0006-pastrterm,     " 검수일
         status     TYPE zc302mmt0006-status,        " 폐기상태
         matlt      TYPE zc302mt0007-matlt,
         icon       TYPE icon-id,
         color      TYPE lvc_t_scol,
         celltab    TYPE lvc_t_styl,
       END OF gs_body,
       gt_body LIKE TABLE OF gs_body.

DATA : gt_body2 LIKE gt_body,
       gs_body2 LIKE gs_body.

DATA: BEGIN OF gs_polow,
        aufnr TYPE zc302mmt0006-aufnr,
      END OF gs_polow,
      gt_polow LIKE TABLE OF gs_polow.

*-- 구매오더 아이템
DATA : gs_po TYPE zc302mmt0008,
       gt_po TYPE TABLE OF zc302mmt0008.
*-- 자재 마스터
DATA : gs_material TYPE zc302mt0007,
       gt_material TYPE TABLE OF zc302mt0007.
*-- 품질검수 임시 ITAB
DATA : gs_temp_body TYPE zc302mmt0006,
       gt_temp_body TYPE TABLE OF zc302mmt0006.
*-- 폐기
DATA : gs_dis TYPE zc302mmt0001,
       gt_dis TYPE TABLE OF zc302mmt0001.
*-- 자재문서
DATA : gs_mdh TYPE zc302mmt0011,
       gt_mdh TYPE TABLE OF zc302mmt0011.
DATA : gs_mdi TYPE zc302mmt0012,
       gt_mdi TYPE TABLE OF zc302mmt0012.
*-- 재고관리
DATA : gs_mwh TYPE zc302mmt0013,
       gt_mwh TYPE TABLE OF zc302mmt0013.
DATA : gs_mwi TYPE zc302mmt0002,
       gt_mwi TYPE TABLE OF zc302mmt0002.
*-- 창고
DATA : gs_ww TYPE zc302mt0005,
       gt_ww TYPE TABLE OF zc302mt0005.
*-- employee info
DATA : gs_employee TYPE zc302mt0003,
       gt_employee TYPE TABLE OF zc302mt0003.
*-- UP ALV
DATA : gt_fcat TYPE lvc_t_fcat,
       gs_fcat TYPE lvc_s_fcat,
       gs_layo TYPE lvc_s_layo.
*-- Down ALV
DATA : gt_fcat2 TYPE lvc_t_fcat,
       gs_fcat2 TYPE lvc_s_fcat,
       gs_layo2 TYPE lvc_s_layo.
*-- Popup ALV
DATA : gt_pfcat TYPE lvc_t_fcat,
       gs_pfcat TYPE lvc_s_fcat,
       gs_playo TYPE lvc_s_layo,
       gs_style TYPE lvc_s_styl.

*-- ALV Toolbar 생성
DATA : gs_center_btn TYPE stb_button,
       gs_qc_btn     TYPE stb_button.

DATA : BEGIN OF gs_content,
         tdline TYPE tdline,
       END OF gs_content,
       gt_content LIKE TABLE OF gs_content.


**********************************************************************
* Common Variable
**********************************************************************
DATA : gv_tabix     TYPE sy-tabix,
       gv_okcode    TYPE sy-ucomm,
       gv_variant   TYPE disvariant,
       gv_status(3).                 " 검수진행일 때와 검수확인일 때 Text Editor 불러오는거 달라짐

**********************************************************************
* Screen element
**********************************************************************
DATA : gv_po_high      TYPE zc302mmt0006-aufnr,
       gv_po_low       TYPE zc302mmt0006-aufnr,
       gv_date_low     TYPE zc302mmt0006-budat,
       gv_date_high    TYPE zc302mmt0006-budat,
       gv_ch_low       TYPE zc302mmt0006-pastrterm,
       gv_ch_high      TYPE zc302mmt0006-pastrterm,
       gv_com_total    TYPE i,
       gv_incom_total  TYPE i,
       gv_dissum_total TYPE i,
       gv_chrow.

*-- POPUP Screen field
DATA : gv_po_num     TYPE zc302mmt0006-aufnr,     " 구매오더번호
       gv_income_num TYPE zc302mmt0006-xblnr,     " 송장번호
       gv_matnr      TYPE zc302mmt0006-matnr,     " 자재코드
       gv_maktx      TYPE zc302mmt0006-maktx,     " 자재명
       gv_menge      TYPE zc302mmt0006-menge,     " 입고수량
       gv_meins      TYPE zc302mmt0006-meins,     " 단위
       gv_dismenge   TYPE zc302mmt0006-dismenge,  " 폐기수량
       gv_qimenge    TYPE zc302mmt0006-qimenge,   " 최종입고수량
       gv_disreason  TYPE zc302mmt0006-disreason, " 폐기사유
       gv_qc_date    TYPE zc302mmt0006-pastrterm, " 검수일
       gv_emp        TYPE zc302mmt0006-ename,     " 직원성명
       gv_emp_num    TYPE sy-uname,               " 직원번호
       gv_emp2       TYPE zc302mmt0006-ename,     " 직원성명
       gv_emp_num2   TYPE sy-uname,
       gv_plstx      TYPE zc302mt0003-plstx,      " 직급
       gv_orgtx      TYPE zc302mt0003-orgtx,      " 부서명
       gv_qinum      TYPE zc302mmt0006-qinum,
       gv_pastrterm  TYPE zc302mmt0006-pastrterm.

DATA : gv_total_menge TYPE zc302mmt0006-menge,
       gv_answer.

*-- 채번관련 변수
DATA : gv_year(6),
       gv_month(2),
       gv_day(2).

DATA : gv_row TYPE lvc_s_row-index.

**********************************************************************
* RANGES
**********************************************************************
RANGES : gr_aufnr     FOR zc302mmt0006-aufnr,
         gr_budat     FOR zc302mmt0006-budat,
         gr_pastrterm FOR zc302mmt0006-pastrterm.
