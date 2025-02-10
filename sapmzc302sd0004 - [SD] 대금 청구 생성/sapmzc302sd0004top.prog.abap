*&---------------------------------------------------------------------*
*& Include SAPMZC302SD0004TOP                       - Module Pool      SAPMZC302SD0004
*&---------------------------------------------------------------------*
PROGRAM sapmzc302sd0004 MESSAGE-ID k5.

**********************************************************************
* Screen element
**********************************************************************
DATA : gv_dlvnum   TYPE zc302sdt0005-dlvnum,
       gv_sale_org TYPE zc302sdt0005-sale_org VALUE '0001',
       gv_channel  TYPE zc302sdt0005-channel,
       gv_bpcode   TYPE zc302sdt0005-bpcode.

RANGES : gr_dlvnum   FOR zc302sdt0005-dlvnum,
         gr_sale_org FOR zc302sdt0005-sale_org,
         gr_channel  FOR zc302sdt0005-channel,
         gr_bpcode   FOR zc302sdt0005-bpcode.

**********************************************************************
* Class instance
**********************************************************************
DATA : go_container  TYPE REF TO cl_gui_custom_container,
       go_split_cont TYPE REF TO cl_gui_splitter_container,
       go_left_cont  TYPE REF TO cl_gui_container,
       go_right_cont TYPE REF TO cl_gui_container.

DATA : go_left_grid  TYPE REF TO cl_gui_alv_grid,
       go_right_grid TYPE REF TO cl_gui_alv_grid.

**********************************************************************
* Internal table and Work area
**********************************************************************
DATA : gt_ship TYPE TABLE OF zc302sdt0005,
       gs_ship TYPE zc302sdt0005.

DATA : gt_billing TYPE TABLE OF zc302sdt0009,
       gs_billing TYPE zc302sdt0009.

*-- FOR ALV
DATA : gt_lfcat   TYPE lvc_t_fcat,
       gs_lfcat   TYPE lvc_s_fcat,
       gt_rfcat   TYPE lvc_t_fcat,
       gs_rfcat   TYPE lvc_s_fcat,
       gs_llayout TYPE lvc_s_layo,
       gs_rlayout TYPE lvc_s_layo,
       gs_variant TYPE disvariant.

*-- ALV Toolbar
DATA : gs_button TYPE stb_button.

**********************************************************************
* Common variable
**********************************************************************
DATA : gv_okcode    TYPE sy-ucomm,
       gv_number(4).              " 대금청구번호
