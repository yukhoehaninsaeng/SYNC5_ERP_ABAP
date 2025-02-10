*&---------------------------------------------------------------------*
*& Include ZC302RPMM0004TOP                         - Report ZC302RPMM0004
*&---------------------------------------------------------------------*
REPORT zc302rpmm0004 MESSAGE-ID k5.

**********************************************************************
* Tables
**********************************************************************
TABLES : zc302mmt0010.

**********************************************************************
* Macro
**********************************************************************
DEFINE _clear.

  REFRESH &1.
  CLEAR &2.

END-OF-DEFINITION.
DEFINE _currency.  " 송장파일 업로드로 가져온 파일 currency field  단위 설정을 위해 사용

  CALL FUNCTION 'CURRENCY_AMOUNT_IDOC_TO_SAP'
    EXPORTING
      currency    = &1
      idoc_amount = &2
    IMPORTING
      sap_amount  = &3.

END-OF-DEFINITION.

**********************************************************************
* Class
**********************************************************************
DATA : go_alv_grid TYPE REF TO cl_gui_alv_grid,
       go_cont     TYPE REF TO cl_gui_custom_container.

**********************************************************************
* Workarea & Internal table
**********************************************************************
DATA : BEGIN OF gs_body.
         INCLUDE TYPE zc302mmt0010.
DATA :   cname   TYPE zc302mt0001-cname,   " 회사명
*         maktx   TYPE zc302mt0007-maktx,   " 자재명
         aufnr   TYPE zc302mmt0009-aufnr,
         plordco TYPE zc302mmt0006-plordco,
       END OF gs_body,
       gt_body LIKE TABLE OF gs_body.

DATA : BEGIN OF gs_excel,
         xblnr  TYPE zc302mmt0010-xblnr,  " 송장번호
         bldat  TYPE zc302mmt0010-bldat,  " 송장일자
         bpcode TYPE zc302mmt0010-bpcode,
         cname  TYPE zc302mt0001-cname,   " 회사명
         matnr  TYPE zc302mmt0010-matnr,  " 자재코드
         maktx  TYPE zc302mt0007-maktx,   " 자재명
         menge  TYPE zc302mmt0010-menge,  " 수량
         meins  TYPE zc302mmt0010-meins,  " 단위
         netpr  TYPE zc302mmt0010-netpr,  " 단가
         netwr  TYPE zc302mmt0010-netwr,  " 총 비용
         waers  TYPE zc302mmt0010-waers,  " 통화
       END OF gs_excel,
       gt_excel LIKE TABLE OF gs_excel.

DATA : gs_com TYPE zc302mmt0010,
       gt_com LIKE TABLE OF gs_com.

DATA : gs_material TYPE zc302mt0007,
       gt_material TYPE TABLE OF zc302mt0007.

*-- 품질검수정보
DATA : gs_qc TYPE zc302mmt0006,
       gt_qc TYPE TABLE OF zc302mmt0006.

*-- 구매오더 Item
DATA : gs_po TYPE zc302mmt0008,
       gt_po TYPE TABLE OF zc302mmt0008.

*-- 거래처정보
DATA : gs_bp TYPE zc302mt0001,
       gt_bp TYPE TABLE OF zc302mt0001.

*-- 송장검증
DATA : gs_iv TYPE zc302mmt0009,
       gt_iv TYPE TABLE OF zc302mmt0009.

DATA : gt_fcat TYPE lvc_t_fcat,
       gs_fcat TYPE lvc_s_fcat,
       gs_layo TYPE lvc_s_layo.

*-- Exclude ALV Toolbar
DATA : gt_ui_functions TYPE ui_functions.

**********************************************************************
* Common variable
**********************************************************************
DATA : gv_okcode  TYPE sy-ucomm,
       gv_tabix   TYPE sy-tabix,
       gv_variant TYPE disvariant,
       gv_count   TYPE i,
       gv_file    LIKE rlgrap-filename.

DATA : gv_aufnr   TYPE zc302mmt0006-aufnr,
       gv_plordco TYPE zc302mmt0006-plordco,
       gv_bldat   TYPE zc302mmt0006-bldat,
       gv_netwr   TYPE zc302mmt0010-netwr,
       gv_waers   TYPE zc302mmt0010-waers VALUE 'KRW'.

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
