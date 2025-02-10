*&---------------------------------------------------------------------*
*& Include SAPMZC302MM0003TOP                       - Module Pool      SAPMZC302MM0003
*&---------------------------------------------------------------------*
PROGRAM sapmzc302mm0003 MESSAGE-ID k5.

**********************************************************************
* TABLES
**********************************************************************
TABLES : zc302mmt0002.

**********************************************************************
* macro
**********************************************************************
DEFINE _clear.

  REFRESH &1.
  CLEAR &2.

END-OF-DEFINITION.

**********************************************************************
* CLASS INSTANCE
**********************************************************************
DATA : go_container  TYPE REF TO cl_gui_custom_container,
       go_split_cont TYPE REF TO cl_gui_splitter_container,
       go_up_cont    TYPE REF TO cl_gui_container,
       go_down_cont  TYPE REF TO cl_gui_container,
       go_up_grid    TYPE REF TO cl_gui_alv_grid,
       go_down_grid  TYPE REF TO cl_gui_alv_grid.

DATA : go_pop_container TYPE REF TO cl_gui_custom_container,
       go_pop_grid      TYPE REF TO cl_gui_alv_grid.

**********************************************************************
* internal table and work
**********************************************************************
DATA : BEGIN OF gs_export,
        matnr     TYPE zc302mmt0013-matnr,     " 자재코드
        scode     TYPE zc302mmt0013-scode,     " 창고코드
        maktx     TYPE zc302mmt0013-maktx,     " 자재명
        sname     TYPE zc302mmt0013-sname,     " 창고명
        address   TYPE zc302mmt0013-address,   " 소재지
        mtart     TYPE zc302mmt0013-mtart,     " 자재유형
        h_rtptqua TYPE zc302mmt0013-h_rtptqua, " 실시간제품수량
        h_resmat  TYPE zc302mmt0013-h_resmat,  " 요청수량
        i_rtptqua  TYPE zc302mmt0002-i_rtptqua,  " 아이템
        meins     TYPE zc302mmt0013-meins,     " 단위
      END OF gs_export,
      gt_export LIKE TABLE OF gs_export.

DATA : BEGIN OF gs_export_bottom,
        matnr     TYPE zc302mmt0013-matnr,     " 자재코드
        scode     TYPE zc302mmt0013-scode,     " 창고코드
        maktx     TYPE zc302mmt0013-maktx,     " 자재명
        sname     TYPE zc302mmt0013-sname,     " 창고명
        address   TYPE zc302mmt0013-address,   " 소재지
        mtart     TYPE zc302mmt0013-mtart,     " 자재유형
        h_rtptqua TYPE zc302mmt0013-h_rtptqua, " 실시간제품수량
        h_resmat  TYPE zc302mmt0013-h_resmat,  " 요청수량
        meins     TYPE zc302mmt0013-meins,     " 단위
      END OF gs_export_bottom,
      gt_export_bottom LIKE TABLE OF gs_export_bottom.

*--출고현황 (자재문서에 저장되는)
DATA : BEGIN OF gs_mt_doc,
        mblnr    TYPE zc302mmt0011-mblnr,    " 자재문서번호
        matnr    TYPE zc302mmt0012-matnr,    " 자재코드
        mjahr    TYPE zc302mmt0011-mjahr,    " 자재문서연도
        maktx    TYPE zc302mmt0012-maktx,    " 자재명
        scode    TYPE zc302mmt0012-scode,    " 창고코드
        menge    TYPE zc302mmt0012-menge,    " 출고수량
        meins    TYPE zc302mmt0012-meins,    " 단위
        budat    TYPE zc302mmt0012-budat,    " 날짜
        netwr    TYPE zc302mmt0007-netwr,    " 단가
        waers    TYPE ZC302mmt0012-waers,    " 통화
        movetype TYPE zc302mmt0012-movetype, " 이동유형
    END OF gs_mt_doc,
    gt_mt_doc LIKE TABLE OF gs_mt_doc.

DATA : BEGIN OF gs_qt,
        matnr TYPE zc302mmt0013-matnr,
        h_rtptqua TYPE zc302mmt0013-h_rtptqua,
       END OF gs_qt,
       gt_qt LIKE TABLE OF gs_qt.

*-- 자재마스터
DATA: BEGIN OF gs_mt_master,
        matnr TYPE zc302mt0007-matnr, "자재코드
        mtart TYPE zc302mt0007-mtart, "자재유형
        netwr TYPE zc302mt0007-netwr, "단가
        waers TYPE zc302mt0007-waers, "통화
        maktx TYPE zc302mt0007-maktx, "자재명
      END OF gs_mt_master,
      gt_mt_master LIKE TABLE OF gs_mt_master.


DATA : gt_tfcat   TYPE lvc_t_fcat,
       gs_tfcat   TYPE lvc_s_fcat,
       gs_tlayout TYPE lvc_s_layo,
       gt_bfcat   TYPE lvc_t_fcat,
       gs_bfcat   TYPE lvc_s_fcat,
       gs_blayout TYPE lvc_s_layo,
       gt_pfcat   TYPE lvc_t_fcat,
       gs_pfcat   TYPE lvc_s_fcat,
       gs_playout TYPE lvc_s_layo.

*-- alv toolbar
DATA : gs_button TYPE stb_button.

**********************************************************************
* common variable
**********************************************************************
DATA : gv_okcode  TYPE sy-ucomm,
       gv_tabix   TYPE sy-tabix,
       gv_count   TYPE i,
       gv_variant TYPE disvariant.

*-- screen painter 라디오버튼, 수량
DATA : radio_total(1)  TYPE c,
       radio1(1)  TYPE c,
       radio2(1)  TYPE c,
       gv_rtptqua TYPE i,
       gv_im      TYPE i,
       gv_ex      TYPE i.
