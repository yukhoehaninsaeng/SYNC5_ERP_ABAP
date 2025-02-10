*&---------------------------------------------------------------------*
*& Include ZC302RPFI0005TOP                         - Report ZC302RPFI0005
*&---------------------------------------------------------------------*
REPORT zc302rpfi0005 MESSAGE-ID k5.


CLASS cl_gui_column_tree DEFINITION LOAD.
CLASS cl_gui_cfw DEFINITION LOAD.

**********************************************************************
* ICON
**********************************************************************
INCLUDE <icon>.


**********************************************************************
* Tables
**********************************************************************
TABLES : zc302mt0006,  zc302fit0001, zc302fit0002. "계정마스터, 전표 ITEM


**********************************************************************
* Class instance
**********************************************************************
DATA: go_tree        TYPE REF TO cl_gui_alv_tree,
      go_change_menu TYPE REF TO cl_ctmenu.


**********************************************************************
* Class instance
**********************************************************************
DATA: go_container  TYPE REF TO cl_gui_docking_container,
      go_base_cont  TYPE REF TO cl_gui_splitter_container,
      go_left_cont  TYPE REF TO cl_gui_container,
      go_right_cont TYPE REF TO cl_gui_container,
      go_alv_grid   TYPE REF TO cl_gui_alv_grid.

**********************************************************************
* Declaration area for Tree event
**********************************************************************
DATA: events TYPE cntl_simple_events,
      event  TYPE cntl_simple_event.



**********************************************************************
* Internal table and Work area
**********************************************************************
DATA : gs_outtab TYPE zc302fit0008,
       gt_outtab TYPE TABLE OF zc302fit0008.

DATA : BEGIN OF gs_body.
         INCLUDE STRUCTURE zc302fit0008.
DATA :
       END OF gs_body,
       gt_body LIKE TABLE OF gs_body.



*-- For ALV
DATA : gt_fcat    TYPE lvc_t_fcat,
       gs_fcat    TYPE lvc_s_fcat,
       gs_layout  TYPE lvc_s_layo,
       gs_variant TYPE disvariant.

DATA: gs_hierhdr         TYPE treev_hhdr,
      gt_list_commentary TYPE slis_t_listheader.


DATA: gt_events TYPE cntl_simple_events,
      gs_event  TYPE cntl_simple_event.

DATA : gt_ui_functions TYPE ui_functions.


**-- For PDF
*DATA: BEGIN  OF gs_blsht,
*        txt50(20),
*        GJCTG  TYPE zc302fit0008-gjctg,
*        gjdet  TYPE zc302fit0008-gjdet,
*        cprice TYPE zc302fit0008-cprice,
*        pprice TYPE zc302fit0008-PPRICE,
*        waers       TYPE bkpf-waers,        " 통화
*      END OF gs_blsht,
*      gt_blsht  LIKE TABLE OF gs_blsht.


"file browser
DATA : pickedfolder  TYPE string,
       initialfolder TYPE string,
       pfolder       TYPE rlgrap-filename. "MEMORY ID mfolder.

" pdf downloa
DATA: gv_tot_page   LIKE sy-pagno,          " Total page
      gv_percent(3) TYPE n,                 " Reading percent
      gv_file       LIKE rlgrap-filename .  " File name

DATA : gv_temp_filename     LIKE rlgrap-filename,
       gv_temp_filename_pdf LIKE rlgrap-filename,
       gv_form(40).

DATA: excel       TYPE ole2_object,
      workbook    TYPE ole2_object,
      books       TYPE ole2_object,
      book        TYPE ole2_object,
      sheets      TYPE ole2_object,
      sheet       TYPE ole2_object,
      activesheet TYPE ole2_object,
      application TYPE ole2_object,
      pagesetup   TYPE ole2_object,
      cells       TYPE ole2_object,
      cell        TYPE ole2_object,
      row         TYPE ole2_object,
      buffer      TYPE ole2_object,
      font        TYPE ole2_object,
      range       TYPE ole2_object,  " Range
      borders     TYPE ole2_object.

DATA: cell1 TYPE ole2_object,
      cell2 TYPE ole2_object.


**********************************************************************
* Common variable
**********************************************************************
DATA : gv_okcode TYPE sy-ucomm,
       save_ok   TYPE sy-ucomm.
