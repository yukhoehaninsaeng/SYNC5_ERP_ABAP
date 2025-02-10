*&---------------------------------------------------------------------*
*& Include SAPMZC302FI0004TOP                       - Module Pool      SAPMZC302FI0004
*&---------------------------------------------------------------------*
PROGRAM sapmzc302fi0004 MESSAGE-ID k5.

*--------------------------------------------------------------------*
* Tables
*--------------------------------------------------------------------*
TABLES : zc302fit0001.

*--------------------------------------------------------------------*
* Screen Element
*--------------------------------------------------------------------*
DATA: gv_bukrs  TYPE zc302fit0001-bukrs VALUE '1000', " 회사 코드
      gv_gjahr  TYPE zc302fit0001-gjahr VALUE '2024', " 회계 연도
      gv_blart  TYPE zc302fit0001-blart, " 전표 유형
      gv_bldat  TYPE zc302fit0001-bldat, " 전표 증빙일
      gv_bktxt  TYPE zc302fit0001-bktxt, " 전표 헤더 텍스트
      gv_budat  TYPE zc302fit0001-budat, " 전표 전기일
      gv_belnr  TYPE zc302fit0001-belnr, " 전표 번호 ( 채번 )
      gv_pernr  TYPE zc302fit0001-emp_num, " 담당자
      gv_buzei  TYPE zc302fit0002-buzei VALUE '001', " 전표 상세 번호
      gv_koart  TYPE zc302fit0002-koart VALUE 'S',   " 계정 유형
      gv_shkzg  TYPE zc302fit0002-shkzg,  "차/대 지시자
      gv_price  TYPE zc302fit0002-price,  " 금액
      gv_waers  TYPE zc302fit0002-waers VALUE 'KRW',  " 통화
      gv_bpcode TYPE zc302fit0002-bpcode, " bpcode
      gv_hkont  TYPE zc302fit0002-hkont,   " 계정 번호
      gv_augbl  TYPE zc302fit0002-augbl,   " 반제 전표 번호
      gv_augdt  TYPE zc302fit0002-augdt.   " 반제 일자

" popup screen element
DATA : gv_pop_bukrs      TYPE zc302fit0001-bukrs,
       gv_pop_gjahr      TYPE zc302fit0001-gjahr,
       gv_pop_belnr_low  TYPE zc302fit0001-belnr,
       gv_pop_belnr_high TYPE zc302fit0001-belnr.

RANGES : gr_bukrs FOR zc302fit0001-bukrs,
         gr_gjahr FOR zc302fit0001-gjahr,
         gr_belnr FOR zc302fit0001-belnr.

*--------------------------------------------------------------------*
* Itab and Wa
*--------------------------------------------------------------------*
DATA : gs_header TYPE zc302fit0001,
       gt_header TYPE TABLE OF zc302fit0001,
       BEGIN OF gs_item.
         INCLUDE TYPE zc302fit0002.
DATA : txt50   TYPE skat-txt50,
         celltab TYPE lvc_t_styl,
       END OF gs_item,
       gt_item         LIKE TABLE OF gs_item,
       " 툴 바에 붙일 버튼
       gs_button       TYPE stb_button,
       " 툴 바에서 제외할 버튼
       gt_ui_functions TYPE ui_functions.

" search help
DATA : BEGIN OF gs_sh_saknr,
         saknr  TYPE ska1-saknr,
         txt50  TYPE skat-txt50,
         bpcode TYPE zc302mt0006-bpcode,
       END OF gs_sh_saknr,
       gt_sh_saknr LIKE TABLE OF gs_sh_saknr,
       BEGIN OF gs_sh_waers,
         fcurr  TYPE zc302fit0005-fcurr,
         nation TYPE zc302fit0005-nation,
       END OF gs_sh_waers,
       gt_sh_waers LIKE TABLE OF gs_sh_waers,
       BEGIN OF gs_sh_shkzg,
         indicator(1),
         description(50),
       END OF gs_sh_shkzg,
       gt_sh_shkzg LIKE TABLE OF gs_sh_shkzg.

*--------------------------------------------------------------------*
* Class
*--------------------------------------------------------------------*
DATA : go_container       TYPE REF TO cl_gui_custom_container,
       go_split_container TYPE REF TO cl_gui_splitter_container,
       go_container_up    TYPE REF TO cl_gui_container,
       go_container_down  TYPE REF TO cl_gui_container,
       go_up_grid         TYPE REF TO cl_gui_alv_grid,
       go_down_grid       TYPE REF TO cl_gui_alv_grid.

" FCAT, LAYOUT
DATA : gs_h_fcat     TYPE lvc_s_fcat,
       gt_h_fcat     TYPE lvc_t_fcat,
       gs_i_fcat     TYPE lvc_s_fcat,
       gt_i_fcat     TYPE lvc_t_fcat,
       gs_layo       TYPE lvc_s_layo,
       gv_up_title   TYPE lvc_title VALUE '전표 Header',
       gv_down_title TYPE lvc_title VALUE '전표 개별 항목'.

*--------------------------------------------------------------------*
* Common Values
*--------------------------------------------------------------------*
DATA : gv_okcode     TYPE sy-ucomm,
       gv_number(10),
       gv_mode(1)    VALUE 'D',
       gv_s_sum      TYPE zc302fit0002-price,
       gv_h_sum      TYPE zc302fit0002-price.
