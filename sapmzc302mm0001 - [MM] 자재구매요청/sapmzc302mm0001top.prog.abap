*&---------------------------------------------------------------------*
*& Include SAPMZC302MM0001TOP                       - Module Pool      SAPMZC302MM0001
*&---------------------------------------------------------------------*
PROGRAM sapmzc302mm0001 MESSAGE-ID k5.

**********************************************************************
* TABLES
**********************************************************************
TABLES : zc302mmt0004, zc302mmt0005.

**********************************************************************
* Class instance
**********************************************************************
DATA : go_container      TYPE REF TO cl_gui_custom_container,
       go_split_cont1    TYPE REF TO cl_gui_splitter_container,
       go_top_cont       TYPE REF TO cl_gui_container,
       go_bottom_cont    TYPE REF TO cl_gui_container,
       go_split_cont2    TYPE REF TO cl_gui_splitter_container,
       go_up_cont        TYPE REF TO cl_gui_container,
       go_down_cont      TYPE REF TO cl_gui_container,
       go_bottom_grid    TYPE REF TO cl_gui_alv_grid,
       go_top_left_grid  TYPE REF TO cl_gui_alv_grid,
       go_top_right_grid TYPE REF TO cl_gui_alv_grid.

*-- popup screen
DATA : go_popup_container TYPE REF TO cl_gui_custom_container,
       go_popup_grid      TYPE REF TO cl_gui_alv_grid.

*-- text editor
DATA : go_text_cont  TYPE REF TO cl_gui_custom_container,
       go_text_edit  TYPE REF TO cl_gui_textedit,
       go_text_cont2 TYPE REF TO cl_gui_custom_container,
       go_text_edit2 TYPE REF TO cl_gui_textedit.
DATA : BEGIN OF gs_content,
         tdline TYPE tdline,
       END OF gs_content,
       gt_content LIKE TABLE OF gs_content.

*-- Search help
DATA : BEGIN OF gs_mat,
          matnr TYPE ZC302MT0007-matnr,
          maktx TYPE ZC302MT0007-maktx,
       END OF gs_mat,
       gt_mat LIKE TABLE OF gs_mat.

**********************************************************************
* Internal table and work area
**********************************************************************
*-- 구매요청 승인
DATA: BEGIN OF gs_mpr_total,
        icon    TYPE icon-id.
                INCLUDE STRUCTURE zc302mmt0005.
DATA:   rstatus TYPE zc302mmt0004-rstatus,
        celltab TYPE lvc_t_styl,
      END OF gs_mpr_total,
      gt_mpr_total LIKE TABLE OF gs_mpr_total.

*-- 구매요청 헤더
DATA : BEGIN OF gs_mpr_h,
         banfn   TYPE zc302mmt0004-banfn,   " 구매요청번호
         plordco TYPE zc302mmt0004-plordco, " 계획오더번호
         bedat   TYPE zc302mmt0004-bedat,   " 구매요청일자
         bedar   TYPE zc302mmt0004-bedar,   " 수요량
         meins   TYPE zc302mmt0004-meins,   " 단위
         matnr   TYPE zc302mmt0004-matnr,   " 자재코드
         maktx   TYPE zc302mmt0004-maktx,   " 자재명
         rstatus TYPE zc302mmt0004-rstatus, " 승인 및 반려 상태
       END OF gs_mpr_h,
       gt_mpr_h LIKE TABLE OF gs_mpr_h.

*-- 구매요청 아이템
DATA : BEGIN OF gs_mpr_i,
         banfn   TYPE zc302mmt0005-banfn,   " 구매요청번호
         plordco TYPE zc302mmt0005-plordco, " 계획오더번호
         matnr   TYPE zc302mmt0005-matnr,   " 자재코드
         maktx   TYPE zc302mmt0005-maktx,   " 자재명
         menge   TYPE zc302mmt0005-menge,   " 수량
         meins   TYPE zc302mmt0005-meins,   " 단위
         bedat   TYPE zc302mmt0005-bedat,   " 구매요청일자
         netwr   TYPE zc302mmt0005-netwr,   " 금액
         waers   TYPE zc302mmt0005-waers,   " 통화
         remark  TYPE zc302mmt0005-remark,  " 반려사유
       END OF gs_mpr_i,
       gt_mpr_i LIKE TABLE OF gs_mpr_i.

*-- top
DATA : gt_tfcat   TYPE lvc_t_fcat,
       gs_tfcat   TYPE lvc_s_fcat,
       gs_tlayout TYPE lvc_s_layo.

*-- down
DATA : gt_dfcat   TYPE lvc_t_fcat,
       gs_dfcat   TYPE lvc_s_fcat,
       gs_dlayout TYPE lvc_s_layo.

*--top right
DATA : gt_trfcat   TYPE lvc_t_fcat,
       gs_trfcat   TYPE lvc_s_fcat,
       gs_trlayout TYPE lvc_s_layo.

*--popup
DATA : gt_pfcat   TYPE lvc_t_fcat,
       gs_pfcat   TYPE lvc_s_fcat,
       gs_playout TYPE lvc_s_layo.

*-- btn
DATA : gs_button TYPE stb_button.

**********************************************************************
* Common variable
**********************************************************************
DATA :   gv_okcode  TYPE sy-ucomm,
         gv_tabix   TYPE sy-tabix,
         gv_count   TYPE i,
         gv_variant TYPE disvariant,
         gv_index   TYPE i.

*-- screen painter input
DATA :   gv_bedat  TYPE zc302mmt0004-bedat,
         gv_bedat2 TYPE zc302mmt0004-bedat,
         gv_matnr  TYPE zc302mmt0004-matnr,
         gv_remark TYPE zc302mmt0005-remark.
RANGES : gr_bedat FOR zc302mmt0004-bedat,
         gr_matnr FOR zc302mmt0004-matnr.
