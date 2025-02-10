*&---------------------------------------------------------------------*
*& Include ZC302RPMM0002TOP                         - Report ZC302RPMM0002
*&---------------------------------------------------------------------*
REPORT zc302rpmm0002 MESSAGE-ID k5.

**********************************************************************
* TABLES
**********************************************************************
TABLES : zc302mmt0002.

**********************************************************************
* CLASS INSTANCE
**********************************************************************
DATA : go_container       TYPE REF TO cl_gui_custom_container,
       go_split_container TYPE REF TO cl_gui_splitter_container,
       go_left_container  TYPE REF TO cl_gui_container,
       go_right_container TYPE REF TO cl_gui_container,
       go_left_grid       TYPE REF TO cl_gui_alv_grid,
       go_right_grid      TYPE REF TO cl_gui_alv_grid.

*-- For Top-of-page
DATA : go_top_container TYPE REF TO cl_gui_docking_container,
       go_dyndoc_id     TYPE REF TO cl_dd_document,
       go_html_cntrl    TYPE REF TO cl_gui_html_viewer.

**********************************************************************
* Internal table and Work area
**********************************************************************
DATA : BEGIN OF gs_header,
          matnr     TYPE zc302mmt0013-matnr,     " 자재코드
          scode     TYPE zc302mmt0013-scode,     " 창고코드
          sname     TYPE zc302mmt0013-sname,     " 창고명
          sname_t(10),                            " 창고명
          address   TYPE zc302mmt0013-address,   " 창고 소재지
          maktx     TYPE zc302mmt0013-maktx,     " 자재명
          mtart     TYPE zc302mmt0013-mtart,     " 자재유형
          mtart_t(3),                            " 자재유형 텍스트
          h_rtptqua TYPE zc302mmt0013-h_rtptqua, " 현재재고
          h_resmat  TYPE zc302mmt0013-h_resmat,  " 예약재고
          meins     TYPE zc302mmt0013-meins,     " 단위
          icon      TYPE icon-id,                " 아이콘
          color     TYPE lvc_t_scol,
      END OF gs_header,
      gt_header LIKE TABLE OF gs_header.

DATA : BEGIN OF gs_item,
         matnr     TYPE zc302mmt0002-matnr,     " 자재코드
         scode     TYPE zc302mmt0002-scode,     " 창고코드
         bdatu     TYPE zc302mmt0002-bdatu,     " 생성일
         sname     TYPE zc302mmt0002-sname,     " 창고명
         maktx     TYPE zc302mmt0002-maktx,     " 자재명
         mtart     TYPE zc302mmt0002-mtart,     " 자재유형
         mtart_t(3),                            " 자재유형 텍스트
         i_rtptqua TYPE zc302mmt0002-i_rtptqua, " 수량
         i_resmat  TYPE zc302mmt0002-i_resmat,  " 예약재고
         meins     TYPE zc302mmt0002-meins,     " 단위
         icon      TYPE icon-id,                " 아이콘
      END OF gs_item,
      gt_item  LIKE TABLE OF gs_item.

DATA : gt_fcat    TYPE lvc_t_fcat,
       gs_fcat    TYPE lvc_s_fcat,
       gt_ifcat   TYPE lvc_t_fcat,
       gs_ifcat   TYPE lvc_s_fcat,
       gs_layout  TYPE lvc_s_layo,
       gs_rlayout TYPE lvc_s_layo.

*-- search help
DATA : BEGIN OF gs_mtart,
        mtart TYPE zc302mt0007-mtart,        " 자재유형 텍스트
        mtart_t(5),
      END OF gs_mtart,
      gt_mtart LIKE TABLE OF gs_mtart.


DATA : BEGIN OF gs_matnr,
        matnr TYPE zc302mt0007-matnr,
        maktx TYPE zc302mt0007-maktx,
      END OF gs_matnr,
      gt_matnr LIKE TABLE OF gs_matnr.

DATA : BEGIN OF gs_scode,
        scode   TYPE zc302mt0005-scode,
        sname   TYPE zc302mt0005-sname,
        address TYPE zc302mt0005-address,
      END OF gs_scode,
      gt_scode LIKE TABLE OF gs_scode.

**********************************************************************
* common variable
**********************************************************************
DATA : gv_okcode  TYPE sy-ucomm,
       gv_tabix   TYPE sy-tabix,
       gv_count   TYPE i,
       gv_variant TYPE disvariant,
       gv_search TYPE zc302mt0007-mtart.
