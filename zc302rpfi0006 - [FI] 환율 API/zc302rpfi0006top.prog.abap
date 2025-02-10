*&---------------------------------------------------------------------*
*& Include ZC302RPFI0006TOP                         - Module Pool      ZC302RPFI0006
*&---------------------------------------------------------------------*
PROGRAM zc302rpfi0006 MESSAGE-ID k5.

*--------------------------------------------------------------------*
* Tables
*--------------------------------------------------------------------*
TABLES : zc302fit0005 . " 환율 테이블

*--------------------------------------------------------------------*
* Type
*--------------------------------------------------------------------*
TYPES: BEGIN OF ts_res,                " api response 타입 선언
         result          TYPE i,       " 조회 결과
         cur_unit        TYPE string,  " 통화코드
         cur_nm          TYPE string,  " 국가/통화명
         ttb             TYPE string,  " 전신환(송금) 받을 때
         tts             TYPE string,  " 전신환(송금) 보낼 때
         deal_bas_r      TYPE string,  " 매매 기준율
         bkpr            TYPE string,  " 장부가격
         yy_efee_r       TYPE string,  " 년환가료율
         ten_dd_efee_r   TYPE string,  " 10일환가료율
         kftc_deal_bas_r TYPE string,  " 서울외국환중개 매매기준율
         kftc_bkpf       TYPE string,  " 서울외국환중개 장부가격
       END OF ts_res.

*--------------------------------------------------------------------*
* Class Instance
*--------------------------------------------------------------------*
DATA : go_container TYPE REF TO cl_gui_docking_container,   " 컨테이너
       go_alv_grid  TYPE REF TO cl_gui_alv_grid.            " alv grid

*--------------------------------------------------------------------*
* Interface
*--------------------------------------------------------------------*
DATA : go_client TYPE REF TO if_http_client.   " interface 참조 변수

*--------------------------------------------------------------------*
* Itab and Wa
*--------------------------------------------------------------------*
DATA : gs_res  TYPE ts_res,          " response 받을 변수 wa
       gt_res  TYPE TABLE OF ts_res, " response 받을 변수 itab
       gs_body TYPE zc302fit0005,
       gt_body TYPE TABLE OF zc302fit0005,
       gs_fcat TYPE lvc_s_fcat,              " alv 용도
       gt_fcat TYPE lvc_t_fcat,
       gs_layo TYPE lvc_s_layo.

" top of page
DATA : go_top_container TYPE REF TO cl_gui_docking_container,
       go_dyndoc_id     TYPE REF TO cl_dd_document,
       go_html_cntrl    TYPE REF TO cl_gui_html_viewer.

*--------------------------------------------------------------------*
* Common Variable
*--------------------------------------------------------------------*
DATA : gv_url      TYPE string,          " url 담을 변수
       gv_date     TYPE sy-datum,        " 날짜를 담을 변수
       gv_message  TYPE string,          " 에러 메시지 담을 변수
       gv_res_json TYPE string,          " json 형태의 response
       gv_okcode   TYPE sy-ucomm,        " okcode 저장하는 변수
       gv_tabix    TYPE sy-tabix,        " 테이블 인덱스 저장하는 변수
       gv_lines    TYPE sy-dbcnt.        " 테이블 행 개수 저장하는 변수
