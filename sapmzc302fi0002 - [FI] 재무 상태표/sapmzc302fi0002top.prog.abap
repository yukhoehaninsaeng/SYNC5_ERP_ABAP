*&---------------------------------------------------------------------*
*& Include SAPMZC302FI0002TOP                       - Module Pool      SAPMZC302FI0002
*&---------------------------------------------------------------------*
PROGRAM sapmzc302fi0002 MESSAGE-ID k5.

" Class
CLASS cl_gui_column_tree DEFINITION LOAD.
CLASS cl_gui_cfw DEFINITION LOAD.

" Type-pools
TYPE-POOLS vrm.

"Icon
INCLUDE <icon>.

" Class Instance
DATA  : go_tree        TYPE REF TO cl_gui_alv_tree,
        go_container   TYPE REF TO cl_gui_docking_container,
        go_change_menu TYPE REF TO cl_ctmenu.


" Macro
DEFINE _popup_to_confirm.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      text_question               = &1
      text_button_1               = &2(001)
      text_button_2               = &3(002)
      display_cancel_button       = ' '
    IMPORTING
     answer                      = &4
    EXCEPTIONS
     text_not_found              = 1
    OTHERS                      = 2.
END-OF-DEFINITION.


" Work area and Internal table
DATA: BEGIN  OF gs_blsht,
        gjahr       TYPE zc302fit0001-gjahr,
        gjgrp(20), " 계정 그룹
        gjgrp_d(20),
        txt20       TYPE skat-txt20,        " 계정 명
        dmbtr       TYPE bseg-dmbtr,        " 계정 금액
        dmbtr_x     TYPE bseg-dmbtr,        " 계정 금액
        waers       TYPE bkpf-waers,        " 통화
      END OF gs_blsht,
      gt_blsht  LIKE TABLE OF gs_blsht,
      gt_outtab LIKE TABLE OF gs_blsht.

" alv tree
DATA: gs_hierhdr         TYPE treev_hhdr,
      gs_variant         TYPE disvariant,
      gt_list_commentary TYPE slis_t_listheader.

DATA: gt_events TYPE cntl_simple_events,
      gs_event  TYPE cntl_simple_event.

DATA : gt_fcat TYPE lvc_t_fcat,
       gs_fcat TYPE lvc_s_fcat.

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

" Common Variable
DATA: gv_okcode TYPE sy-ucomm,
      gv_fpath  TYPE  rlgrap-filename.
