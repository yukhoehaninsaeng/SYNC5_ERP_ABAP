*&---------------------------------------------------------------------*
*& Include ZC302RPFI0002TOP                         - Report ZC302RPFI0002
*&---------------------------------------------------------------------*
REPORT zc302rpfi0002 MESSAGE-ID k5.

**********************************************************************
* TABLES
**********************************************************************
TABLES : zc302fit0001, zc302fit0002.            "전표 Header, Item 테이블


**********************************************************************
* Class instance
**********************************************************************
DATA : go_container  TYPE REF TO cl_gui_docking_container,
       go_split_cont TYPE REF TO cl_gui_splitter_container,
       go_up_cont    TYPE REF TO cl_gui_container,  " CONTAINER - Up
       go_down_cont  TYPE REF TO cl_gui_container,  " CONTAINER - Down
       go_up_grid    TYPE REF TO cl_gui_alv_grid,   " ALV GRID - Up
       go_down_grid  TYPE REF TO cl_gui_alv_grid.   " ALV GRID - Down


*-- For Text-editor *역분개 사유 입력을 위한 변수
DATA : go_text_cont TYPE REF TO cl_gui_custom_container,  " FOR text 입력
       go_text_edit TYPE REF TO cl_gui_textedit,
       go_text_cont2 TYPE REF TO cl_gui_custom_container, " FOR text 조회
       go_text_edit2 TYPE REF TO cl_gui_textedit.


*-- For TOP-of-page
DATA : go_top_container TYPE REF TO cl_gui_docking_container,
       go_dyndoc_id     TYPE REF TO cl_dd_document,
       go_html_cntrl    TYPE REF TO cl_gui_html_viewer.


**********************************************************************
* Internal table and Work area
**********************************************************************
*-- 전표 Header
DATA : BEGIN OF gs_bkpf.
         INCLUDE STRUCTURE zc302fit0001.
DATA :   btn TYPE icon-id,    " 전표 생성 아이콘
       END OF gs_bkpf,
       gt_bkpf LIKE TABLE OF gs_bkpf.

*-- For 신규 역분개 전표 생성
DATA : gs_stblg TYPE zc302fit0001,
       gt_stblg TYPE TABLE OF zc302fit0001.

*-- 전표 Item
DATA : BEGIN OF gs_bseg.
         INCLUDE STRUCTURE zc302fit0002.
DATA :   txt50 TYPE  zc302mt0006-txt50,
       END OF gs_bseg,
       gt_bseg LIKE TABLE OF gs_bseg.

*-- Get 계정과목명
DATA : gs_txt TYPE zc302mt0006,
       gt_txt LIKE TABLE OF gs_txt.


*-- Text editor 임시저장 ITAB
DATA: BEGIN OF gs_content,
        tdline TYPE tdline,
      END OF gs_content,
      gt_content LIKE TABLE OF gs_content.


*-- For F4 (Selection screen)
DATA : BEGIN OF gs_search,
        belnr TYPE ZC302FIT0001-belnr,
       END OF gs_search,
       gt_search like TABLE OF gs_search.


*-- For ALV
DATA : gt_ufcat   TYPE lvc_t_fcat,
       gs_ufcat   TYPE lvc_s_fcat,
       gt_dfcat   TYPE lvc_t_fcat,
       gs_dfcat   TYPE lvc_s_fcat,
       gs_layout  TYPE lvc_s_layo,
       gs_dlayout TYPE lvc_s_layo,
       gs_variant TYPE disvariant,
       gt_sort    TYPE lvc_t_sort,
       gs_sort    TYPE lvc_s_sort.

DATA : gt_ui_functions TYPE ui_functions,
       gs_button TYPE stb_button.


**********************************************************************
* Common variable
**********************************************************************
DATA : gv_okcode TYPE sy-ucomm.

*-- For 역분개 전표 채번
DATA : gv_number(10).

*-- hotspot 선택 행/필드 백업용
DATA : gv_belnr    TYPE zc302fit0001-belnr, "전표번호
       gv_bukrs    TYPE zc302fit0001-belnr, "회사코드
       gv_gjahr    TYPE zc302fit0001-gjahr, "회계연도
       gv_blart    TYPE zc302fit0001-blart, "전표유형
       gv_zisdn    TYPE zc302fit0001-zisdn, "임시문서번호
       gv_zisdd    TYPE zc302fit0001-zisdd, "임시문서일자
       gv_stgrd    TYPE zc302fit0001-stgrd, "역분개번호
       gv_bktxt    TYPE zc302fit0001-bktxt, "전표헤더텍스트
       gv_xref1_hd TYPE zc302fit0001-xref1_hd,  "참조
       gv_waers    TYPE zc302fit0001-waers, "통화
       gv_pre_row  TYPE lvc_s_roid-row_id.

DATA : gv_row_no TYPE lvc_s_roid-row_id.
