*&---------------------------------------------------------------------*
*& Include SAPMZC302MM0006TOP                       - Module Pool      SAPMZC302MM0006
*&---------------------------------------------------------------------*
PROGRAM sapmzc302mm0006 MESSAGE-ID k5.

**********************************************************************
* Class
**********************************************************************
DATA : go_cont     TYPE REF TO cl_gui_custom_container,
       go_alv_grid TYPE REF TO cl_gui_alv_grid.

**********************************************************************
* Screen element
**********************************************************************
*DATA : gv_mat(6),
*       gv_mta TYPE n LENGTH 2,
*       gv_mak(50),
*       gv_wei TYPE zc302mt0007-wegiht,
*       gv_gew TYPE zc302mt0007-gewei,
*       gv_net TYPE zc302mt0007-neter,
*       gv_wea TYPE zc302mt0007-waers,
*       gv_bp  TYPE ZC302MT0007-bpcode.



**********************************************************************
* Work Area & Internal Table
**********************************************************************
DATA : gs_body TYPE zc302mt0007,
       gt_body TYPE TABLE OF zc302mt0007.

DATA: gs_elem TYPE zc302mt0007,
      gt_elem TYPE TABLE OF zc302mt0007.


DATA : gs_fcat TYPE lvc_s_fcat,
       gt_fcat TYPE lvc_t_fcat,
       gs_layo TYPE lvc_s_layo.

DATA : BEGIN OF gs_bp,
         bpcode TYPE zc302mt0001-bpcode,
         cname  TYPE zc302mt0001-cname,
       END OF gs_bp,
       gt_bp LIKE TABLE OF gs_bp.

*-- Exclude ALV Toolbar
DATA : gt_ui_functions TYPE  ui_functions.





**********************************************************************
* Common Variable
**********************************************************************
DATA : gv_okcode TYPE sy-ucomm.
