*&---------------------------------------------------------------------*
*& Include ZC302RPFI0001TOP                         - Report ZC302RPFI0001
*&---------------------------------------------------------------------*
REPORT zc302rpfi0001 MESSAGE-ID k5.

*--------------------------------------------------------------------*
* Tables
*--------------------------------------------------------------------*
TABLES: zc302sdt0009.

*--------------------------------------------------------------------*
* Itab and Work Area
*--------------------------------------------------------------------*
DATA: gs_body TYPE zc302fit0004,         " 임시 전표 데이터 담을 용도
      gt_body TYPE TABLE OF zc302fit0004,
      BEGIN OF gs_billing.
        INCLUDE TYPE zc302sdt0009.
DATA:   icon TYPE icon-id,
      END OF gs_billing,                 " billing 데이터 담을 용도
      gt_billing LIKE TABLE OF gs_billing,
      BEGIN OF gs_songjang.
        INCLUDE TYPE zc302mmt0009.       " 송장 검증 데이터 담을 용도
DATA:   icon TYPE icon-id,
      END OF gs_songjang,
      gt_songjang LIKE TABLE OF gs_songjang.
*--------------------------------------------------------------------*
* Field Symbol
*--------------------------------------------------------------------*
FIELD-SYMBOLS : <fs_itab>     TYPE STANDARD TABLE,
                <fs_wa>       TYPE any,
                <fs_icon>     TYPE icon-id,
                <fs_bpcode>   LIKE gs_billing-bpcode,      " bp code
                <fs_waers>    LIKE gs_billing-waers,        " 통화
                <fs_ivflag>   LIKE gs_billing-ivflag,      " 전표 발행 여부
                <fs_docno>    LIKE gs_billing-bilnum,       " 임시 전표 번호
                <fs_net_cash> LIKE gs_billing-netwr,     " 총액
                <fs_sptyp>    LIKE gs_body-sptyp,
                <fs_aedat>    LIKE gs_body-aedat,
                <fs_aezet>    LIKE gs_body-aezet,
                <fs_aenam>    LIKE gs_body-aenam.
*--------------------------------------------------------------------*
* Class Instance
*--------------------------------------------------------------------*
DATA : go_container       TYPE REF TO cl_gui_docking_container,
       go_split_container TYPE REF TO cl_gui_splitter_container,
       go_left_container  TYPE REF TO cl_gui_container,
       go_right_container TYPE REF TO cl_gui_container,
       go_left_grid       TYPE REF TO cl_gui_alv_grid,
       go_right_grid      TYPE REF TO cl_gui_alv_grid,
       " top of page 변수
       go_top_container   TYPE REF TO cl_gui_docking_container,
       go_dyndoc_id       TYPE REF TO cl_dd_document,
       go_html_cntrl      TYPE REF TO cl_gui_html_viewer.

DATA : gs_fcat_left  TYPE lvc_s_fcat,
       gt_fcat_left  TYPE lvc_t_fcat,
       gs_fcat_right TYPE lvc_s_fcat,
       gt_fcat_right TYPE lvc_t_fcat,
       gs_layo       TYPE lvc_s_layo,
       gs_variant    TYPE disvariant,
       gs_stable     TYPE lvc_s_stbl.

" toolbar menu
DATA : gs_button TYPE stb_button.

*--------------------------------------------------------------------*
* Common Variable
*--------------------------------------------------------------------*
DATA : gv_okcode   TYPE sy-ucomm,
       gv_tabix    TYPE sy-tabix,
       gv_lines    TYPE i,
       gv_mode(4),
       gv_tax_rate TYPE p LENGTH 5
                   DECIMALS 2 VALUE '1.1'. " 부가 가치세 계산
