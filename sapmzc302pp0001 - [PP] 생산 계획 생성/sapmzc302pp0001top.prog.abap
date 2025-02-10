*&---------------------------------------------------------------------*
*& Include SAPMZC302PP0001TOP                       - Module Pool      SAPMZC302PP0001
*&---------------------------------------------------------------------*
PROGRAM sapmzc302pp0001 MESSAGE-ID k5.

**********************************************************************
* Screen element
**********************************************************************
*-- SCREEN 100
DATA : gv_spnum   TYPE zc302sdt0001-spnum,
       gv_pyear   TYPE zc302sdt0001-pyear.
*       gv_channel TYPE zc302sdt0001-channel. 지웠다.

*-- SCREEN 101
DATA: gv_emp_num TYPE zc302mt0003-emp_num,
      gv_pldq    TYPE i.      " 얘는 퍼센트로 하드코딩 적어주는거기 떄문

**********************************************************************
* RANGES
**********************************************************************
* 조회 조건
RANGES : gr_spnum FOR zc302sdt0001-spnum,
         gr_pyear FOR zc302sdt0001-pyear.

**********************************************************************
*&& Macro
**********************************************************************
DEFINE _init.

  CLEAR &1.

END-OF-DEFINITION.

**********************************************************************
* Class instance
**********************************************************************
DATA : go_container   TYPE REF TO cl_gui_custom_container,
       go_split_cont1 TYPE REF TO cl_gui_splitter_container,
       go_left_cont   TYPE REF TO cl_gui_container,
       go_right_cont  TYPE REF TO cl_gui_container,
       go_split_cont2 TYPE REF TO cl_gui_splitter_container,
       go_up_cont     TYPE REF TO cl_gui_container,
       go_down_cont   TYPE REF TO cl_gui_container.


DATA : go_up_grid    TYPE REF TO cl_gui_alv_grid,
       go_down_grid  TYPE REF TO cl_gui_alv_grid,
       go_right_grid TYPE REF TO cl_gui_alv_grid.

DATA : go_pop_cont TYPE REF TO cl_gui_custom_container, " Popup
       go_pop_grid TYPE REF TO cl_gui_alv_grid. " Popup

**********************************************************************
* Work area and Internal table
**********************************************************************
*-- 판매계획 Header
DATA: BEGIN OF gs_spheader,
        icon TYPE icon-id.
        INCLUDE STRUCTURE zc302sdt0001.
DATA: END OF gs_spheader,
      gt_spheader LIKE TABLE OF gs_spheader.

*-- 판매계획 Item
DATA : gt_spitem   TYPE TABLE OF zc302sdt0002,
       gs_spitem   TYPE zc302sdt0002.

*-- 생산계획
DATA: BEGIN OF gs_pdplan,
        icon TYPE icon-id.
        INCLUDE STRUCTURE zc302ppt0001.
DATA: END OF gs_pdplan,
      gt_pdplan LIKE TABLE OF gs_pdplan.

*-- 판매계획번호 (Search help 용)
DATA : BEGIN OF gs_spn,
        spnum TYPE zc302sdt0002-spnum,
        matnr TYPE zc302sdt0002-matnr,
        maktx TYPE zc302mt0007-maktx,
       END OF gs_spn,
       gt_spn LIKE TABLE OF gs_spn.




*-- For ALV
DATA : gt_ufcat   TYPE lvc_t_fcat,
       gt_dfcat   TYPE lvc_t_fcat,
       gt_rfcat   TYPE lvc_t_fcat,
       gs_ufcat   TYPE lvc_s_fcat,
       gs_dfcat   TYPE lvc_s_fcat,
       gs_rfcat   TYPE lvc_s_fcat,
       gs_ulayout  TYPE lvc_s_layo,   " 판매계획 Header 레이아웃
       gs_dlayout  TYPE lvc_s_layo,   " 판매계획 Item 레이아웃
       gs_rlayout  TYPE lvc_s_layo,   " 생산계획 레이아웃
       gs_variant TYPE disvariant.

*-- For button
DATA : gs_button TYPE stb_button.

*-- For Popup
DATA : gt_pfcat   TYPE lvc_t_fcat,
       gs_pfcat   TYPE lvc_t_fcat,
       gs_playout TYPE lvc_s_layo.

**********************************************************************
* Common variable
**********************************************************************
DATA : gv_okcode  TYPE sy-ucomm.
