*&---------------------------------------------------------------------*
*& Include ZC302RPMM0005TOP                         - Report ZC302RPMM0005
*&---------------------------------------------------------------------*
REPORT zc302rpmm0005 MESSAGE-ID k5 .

**********************************************************************
* CLASS INSTANCE
**********************************************************************
DATA : go_container TYPE REF TO cl_gui_custom_container,
       go_alv_grid  TYPE REF TO cl_gui_alv_grid.

**********************************************************************
* INTERNAL TABLE AND WORK AREA
**********************************************************************
*-- FOR alv

DATA : BEGIN OF gs_inventory,
        matnr     TYPE zc302mmt0013-matnr,     " 자재코드
        scode     TYPE zc302mmt0013-scode,     " 창고코드
        maktx     TYPE zc302mmt0013-maktx,     " 자재명
        mtart     TYPE zc302mmt0013-mtart,     " 자재유형
        sname     TYPE zc302mmt0013-sname,     " 창고명
        address   TYPE zc302mmt0013-address,   " 소재지
        h_rtptqua TYPE zc302mmt0013-h_rtptqua, " 헤더 테스트
*        h_resmat TYPE zc302mmt0013-h_resmat, " 헤더 테스트
        meins     TYPE zc302mmt0013-meins,     " 단위
      END OF gs_inventory,
      gt_inventory LIKE TABLE OF gs_inventory.

DATA : gt_header TYPE TABLE OF zc302mmt0013,
       gs_header TYPE zc302mmt0013.
DATA : gt_item TYPE TABLE OF zc302mmt0002,
       gs_item TYPE zc302mmt0002.

*-- FOR Read table
DATA : gt_venm TYPE TABLE OF zc302mt0007,
       gs_venm TYPE zc302mt0007.
DATA : gt_st TYPE TABLE OF zc302mt0005,
       gs_st TYPE zc302mt0005.


*-- For ALV Layout
DATA : gt_fcat    TYPE lvc_t_fcat,
       gs_fcat    TYPE lvc_s_fcat,
       gs_layout  TYPE lvc_s_layo,
       gs_variant TYPE disvariant.

DATA : BEGIN OF gs_excel,
        matnr     TYPE zc302mmt0013-matnr,     " 자재코드
        scode     TYPE zc302mmt0013-scode,     " 창고코드
        maktx     TYPE zc302mmt0013-maktx,     " 자재명
        mtart     TYPE zc302mmt0013-mtart,     " 자재유형
        sname     TYPE zc302mmt0013-sname,     " 창고명
        address   TYPE zc302mmt0013-address,   " 소재지
        h_rtptqua TYPE zc302mmt0013-h_rtptqua, " 헤더 테스트
*        h_resmat TYPE zc302mmt0013-h_resmat, " 헤더 테스트
        meins     TYPE zc302mmt0013-meins,     " 단위
      END OF gs_excel,
      gt_excel LIKE TABLE OF gs_excel.

*--입고현황 (자재문서에 저장되는)
DATA : BEGIN OF gs_mt_doc,
        mblnr    TYPE zc302mmt0011-mblnr,       " 자재문서번호
        matnr    TYPE zc302mmt0012-matnr,       " 자재코드
        mjahr    TYPE zc302mmt0011-mjahr,       " 자재문서연도
        maktx    TYPE zc302mmt0012-maktx,       " 자재명
        scode    TYPE zc302mmt0012-scode,       " 창고코드
        menge    TYPE zc302mmt0012-menge,       " 출고수량
        meins    TYPE zc302mmt0012-meins,       " 단위
        budat    TYPE zc302mmt0012-budat,       " 날짜
        netwr    TYPE zc302mmt0007-netwr,       " 단가
        waers    TYPE ZC302mmt0012-waers,       " 통화
        movetype    TYPE zc302mmt0012-movetype, " 이동유형
    END OF gs_mt_doc,
    gt_mt_doc LIKE TABLE OF gs_mt_doc.


**********************************************************************
* COMMON VARIABLES 엑셀 폼 ZC321_XLS_FORM_MM
**********************************************************************
DATA : gv_okcode  TYPE sy-ucomm,
       gv_tabix   TYPE sy-tabix,
       gv_count   TYPE i,
       gv_variant TYPE disvariant,
       gv_file    LIKE rlgrap-filename.

*-- For file path
DATA : w_pickedfolder  TYPE string,
       w_initialfolder TYPE string,
       w_fullinfo      TYPE string,
       w_pfolder       TYPE rlgrap-filename, "MEMORY ID mfolder
*-- For screen button
       w_functxt       TYPE smp_dyntxt,
       it_files        TYPE filetable,
       st_files        LIKE LINE OF it_files,
       w_rc            TYPE i,
       w_dir           TYPE string.
