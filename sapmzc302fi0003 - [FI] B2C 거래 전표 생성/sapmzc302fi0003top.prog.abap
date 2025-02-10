*&---------------------------------------------------------------------*
*& Include SAPMZC302FI0003TOP                       - Module Pool      SAPMZC302FI0003
*&---------------------------------------------------------------------*
PROGRAM sapmzc302fi0003 MESSAGE-ID k5.

**********************************************************************
* TABLES
**********************************************************************
TABLES : zc302fit0001,zc302fit0006, zc302sdt0003, zc302sdt0004,
         zc302sdt0007, zc302sdt0008.

**********************************************************************
* Screen element (Internal table and Work area)
**********************************************************************
DATA : gv_dat_fr   TYPE zc302fit0006-dwdate,
       gv_dat_to   TYPE zc302fit0006-dwdate,
       gv_bukrs    TYPE zc302fit0001-bukrs,
       gv_rfnum    TYPE zc302fit0006-sfnum,
       gv_bel_flag TYPE zc302fit0006-bel_flag,
       gv_dwflag   TYPE zc302fit0006-dw_flag.


**********************************************************************
* Ranges
**********************************************************************
RANGES : gr_bukrs FOR zc302fit0001-bukrs,
         gr_rfnum FOR zc302fit0006-sfnum,
         gr_pdate FOR zc302fit0006-dwdate,
         gr_bel_flag FOR zc302fit0006-bel_flag,
         gr_dwflag FOR zc302fit0006-dw_flag.


**********************************************************************
* Class instance
**********************************************************************
DATA : go_container        TYPE REF TO cl_gui_custom_container,
       go_split_cont       TYPE REF TO cl_gui_splitter_container,
       go_right_split_cont TYPE REF TO cl_gui_splitter_container,   "new
       go_left_cont        TYPE REF TO cl_gui_container,
       go_right_cont       TYPE REF TO cl_gui_container,
       go_up_cont          TYPE REF TO cl_gui_container,     "new
       go_down_cont        TYPE REF TO cl_gui_container.   "new


DATA : go_left_grid   TYPE REF TO cl_gui_alv_grid,
       go_right_grid  TYPE REF TO cl_gui_alv_grid,
       go_rigntd_grid TYPE REF TO cl_gui_alv_grid.  "new

**********************************************************************
* Internal table and Work area
**********************************************************************
DATA : BEGIN OF gs_body.
         INCLUDE TYPE zc302fit0006.             " 입출금내역 테이블
DATA :   bukrs    TYPE zc302fit0001-bukrs,
         belnr    TYPE zc302fit0001-belnr,
         icon     TYPE icon-id,
         btn      TYPE icon-id,
*         celltab TYPE lvc_t_styl,
         bank(6),
         xref1_hd TYPE zc302fit0001-xref1_hd,
       END OF gs_body,
       gt_body LIKE TABLE OF gs_body.


*** 판매/ 반품 오더 아이템
*-- For Right up grid  " 판매
DATA : BEGIN OF gs_sdata,
         sonum    TYPE zc302sdt0003-sonum,        " 판매오더I
         cust_num TYPE  zc302sdt0003-cust_num,    " 회원코드
         pdate    TYPE zc302sdt0003-pdate,        " 판매일자
         netwr    TYPE zc302sdt0003-netwr,        " 주문금액
         waers    TYPE zc302sdt0003-waers,        " 통화
         sdate    TYPE zc302sdt0003-sdate,        " 판매오더생성일
         posnr    TYPE zc302sdt0004-posnr,        " 아이템번호
         matnr    TYPE zc302sdt0004-matnr,        " 자재코드
         menge    TYPE zc302sdt0004-menge,        " 수량
         meins    TYPE zc302sdt0004-meins,        " 통화
       END OF gs_sdata,
       gt_sdata LIKE TABLE OF gs_sdata.

*-- For Rignt up grid " 반품
DATA : BEGIN OF gs_fdata,
         rfnum  TYPE zc302sdt0007-rfnum,
         sonum  TYPE zc302sdt0007-sonum,
         rcdat  TYPE zc302sdt0007-rcdat,
         posnr  TYPE zc302sdt0008-posnr,
         matnr  TYPE zc302sdt0008-matnr,
         menge  TYPE zc302sdt0008-menge,
         meins  TYPE zc302sdt0008-meins,
         remark TYPE zc302sdt0008-remark,
         chkrs  TYPE zc302sdt0008-chkrs,
         pdate  TYPE zc302sdt0003-pdate,
         netwr  TYPE zc302sdt0003-netwr,
         waers  TYPE zc302sdt0003-waers,
       END OF gs_fdata,
       gt_fdata LIKE TABLE OF gs_fdata.

*-- " 전표 헤더
DATA : BEGIN OF gs_bkpf.
         INCLUDE STRUCTURE zc302fit0001.   " 회계전표H
DATA : END OF gs_bkpf,
gt_bkpf LIKE TABLE OF gs_bkpf.

*-- " 전표 아이템
DATA : BEGIN OF gs_bseg.
         INCLUDE STRUCTURE zc302fit0002.   " 회계전표I
DATA :   txt50 TYPE zc302mt0006-txt50,
       END OF gs_bseg,
       gt_bseg LIKE TABLE OF gs_bseg.

DATA : gs_txt TYPE zc302mt0006,
       gt_txt LIKE TABLE OF gs_txt.



*-- For ALV
DATA : gt_lfcat   TYPE lvc_t_fcat,
       gs_lfcat   TYPE lvc_s_fcat,
       gs_layout  TYPE lvc_s_layo,
       gs_layout2 TYPE lvc_s_layo.

DATA : gt_rfcat  TYPE lvc_t_fcat,
       gs_rfcat  TYPE lvc_s_fcat,
       gt_rfcat2 TYPE lvc_t_fcat,
       gs_rfcat2 TYPE lvc_s_fcat.

*-- POPUP SCREEN
DATA : go_pop_cont TYPE REF TO cl_gui_custom_container,
       go_pop_grid TYPE REF TO cl_gui_alv_grid.

DATA : gt_pfcat   TYPE lvc_t_fcat,
       gs_pfcat   TYPE lvc_s_fcat,
       gs_playout TYPE lvc_s_layo,
       gs_sort    TYPE lvc_s_sort,
       gt_sort    TYPE lvc_t_sort.

*-- Exclude ALV Toolbar
DATA : gt_ui_functions TYPE  ui_functions.
DATA : gs_variant TYPE disvariant.


*-- seach help
DATA : BEGIN OF gs_sfnum,
         sfnum TYPE zc302fit0006-sfnum,
       END OF gs_sfnum,
       gt_sfnum LIKE TABLE OF gs_sfnum.



**********************************************************************
* Common variable
**********************************************************************
DATA :gv_okcode TYPE sy-ucomm.

*-- 고객별 입금/출금 정보 백업을 위한 변수
DATA :  gv_pre_row TYPE lvc_s_roid-row_id.

DATA : gv_arbel(10),
       gv_apbel(10),
       gv_belflag TYPE zc302fit0006-bel_flag.
