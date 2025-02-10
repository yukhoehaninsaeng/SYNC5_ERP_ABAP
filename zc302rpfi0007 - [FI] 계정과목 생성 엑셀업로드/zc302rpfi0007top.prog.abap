*&---------------------------------------------------------------------*
*& Include ZC302RPFI0007TOP                         - Report ZC302RPFI0007
*&---------------------------------------------------------------------*
REPORT ZC302RPFI0007 MESSAGE-ID K5.


**********************************************************************
* Screen element
**********************************************************************
*DATA : gv_buk   TYPE zc302mt0006-bukrs,  "screen200
*       gv_kto   TYPE zc302mt0006-ktopl,
*       gv_sak   TYPE zc302mt0006-saknr,
*       gv_txt   TYPE zc302mt0006-txt50,
*       gv_fla   TYPE zc302mt0006-gl_flag,
*       gv_bpco  TYPE zc302mt0006-bpcode,
*       gv_gjgr  TYPE zc302mt0006-gjgrp,
*       gv_gjgr2 TYPE zc302mt0006-gjgrp.

**********************************************************************
* class instance
**********************************************************************
DATA : go_container2 TYPE REF TO cl_gui_custom_container,
       go_popcont    TYPE REF TO cl_gui_custom_container,
       go_alv_grid2  TYPE REF TO cl_gui_alv_grid,
       go_pop_grid   TYPE REF TO cl_gui_alv_grid.


**********************************************************************
* Internal table and work area
**********************************************************************
DATA : BEGIN OF gs_gldata.
         INCLUDE STRUCTURE zc302mt0006.
DATA : END OF gs_gldata,
gt_gldata LIKE TABLE OF gs_gldata.

*-- Excel 파일 양식
DATA : BEGIN OF gs_excel,
         bukrs   TYPE zc302mt0006-bukrs,
         ktopl   TYPE zc302mt0006-ktopl,     "계정과목표
         saknr   TYPE zc302mt0006-saknr,     "계정과목코드
         txt50   TYPE zc302mt0006-txt50,     "계정과목명
         gjgrp   TYPE zc302mt0006-gjgrp,     "계정그룹
         gl_flag TYPE zc302mt0006-gl_flag, "계정유형
         bpcode  TYPE zc302mt0006-bpcode,   "거래처코드
       END OF gs_excel,
       gt_excel LIKE TABLE OF gs_excel.

DATA : gs_popbody TYPE zc302mt0006,
       gt_popbody TYPE TABLE OF zc302mt0006.


*-- For ALV
DATA : gt_fcat1  TYPE lvc_t_fcat,
       gs_fcat1  TYPE lvc_s_fcat,
       gt_fcat2  TYPE lvc_t_fcat,
       gs_fcat2  TYPE lvc_s_fcat,
       gs_layout TYPE lvc_s_layo,
       gs_sort   TYPE lvc_s_sort,
       gt_sort   TYPE lvc_t_sort.

DATA : gs_variant      TYPE disvariant,
       gt_ui_functions TYPE ui_functions.

*-- For POPUP
DATA : gt_pfcat   TYPE lvc_t_fcat,
       gs_pfcat   TYPE lvc_s_fcat,
       gs_playout TYPE lvc_s_layo.

*-- For delete
DATA : gt_delt TYPE TABLE OF zc302mt0006,
       gs_delt TYPE zc302mt0006.

*-- For alvtoolbar button
DATA : gs_button TYPE stb_button.


*-- BPCODE F4
DATA : BEGIN OF gs_bpcode,
         bpcode TYPE zc302mt0001-bpcode,
         cname  TYPE zc302mt0001-cname,
       END OF gs_bpcode,
       gt_bpcode LIKE TABLE OF gs_bpcode.

**********************************************************************
* Common variable
**********************************************************************
DATA : gv_okcode TYPE sy-ucomm,
       gv_okpop  TYPE sy-ucomm,
       gv_mode   VALUE 'D'.

*-- For excel upload
DATA: gv_number(7),
      gv_docno(10).

DATA : gv_file TYPE rlgrap-filename.

DATA : w_pickedfolder  TYPE string,
       w_initialfolder TYPE string,
       w_fullinfo      TYPE string ,
       w_pfolder       TYPE rlgrap-filename.

*-- For 1000 screen application toolbar button
DATA : w_functxt TYPE smp_dyntxt,
       it_files  TYPE filetable,
       st_files  LIKE LINE OF it_files,
       w_rc      TYPE i,
       w_dir     TYPE string.
