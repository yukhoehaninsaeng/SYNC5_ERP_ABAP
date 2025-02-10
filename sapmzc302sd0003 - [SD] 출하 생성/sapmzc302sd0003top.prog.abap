*&---------------------------------------------------------------------*
*& Include SAPMZC302SD0003TOP                       - Module Pool      SAPMZC302SD0003
*&---------------------------------------------------------------------*
PROGRAM sapmzc302sd0003 MESSAGE-ID k5.

**********************************************************************
* Screen element
**********************************************************************
*-- For Display Condition
DATA : gv_sale_org TYPE zc302sdt0005-sale_org VALUE '0001',
       gv_channel  TYPE zc302sdt0005-channel,
       gv_bpcode   TYPE zc302sdt0005-bpcode.

RANGES : gr_sale_org FOR zc302sdt0005-sale_org,
         gr_channel  FOR zc302sdt0005-channel,
         gr_bpcode   FOR zc302sdt0005-bpcode.

*-- For Delivery Type Popup
DATA : gv_dtype TYPE zc302sdt0005-dtype,
       gv_dcomp TYPE zc302sdt0005-dcomp.

**********************************************************************
* Class instance
**********************************************************************
DATA : go_container  TYPE REF TO cl_gui_custom_container,
       go_split_cont TYPE REF TO cl_gui_splitter_container,
       go_left_cont  TYPE REF TO cl_gui_container,
       go_right_cont TYPE REF TO cl_gui_container.

DATA : go_left_grid  TYPE REF TO cl_gui_alv_grid,
       go_right_grid TYPE REF TO cl_gui_alv_grid.

*-- For Popup ALV(Order Item)
DATA : go_pop_cont TYPE REF TO cl_gui_custom_container,
       go_pop_grid TYPE REF TO cl_gui_alv_grid.

**********************************************************************
* Internal table and Work area
**********************************************************************
DATA : gt_order TYPE TABLE OF zc302sdt0003,
       gs_order TYPE zc302sdt0003.

DATA : gt_ship TYPE TABLE OF zc302sdt0005,
       gs_ship TYPE zc302sdt0005.

DATA : gt_iorder TYPE TABLE OF zc302sdt0004,
       gs_iorder TYPE zc302sdt0004.

DATA : gt_iship TYPE TABLE OF zc302sdt0006,
       gs_iship TYPE zc302sdt0006.

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


*-- For Popup ALV(Order Item)
DATA : gt_pfcat   TYPE lvc_t_fcat,
       gs_pfcat   TYPE lvc_s_fcat,
       gs_playout TYPE lvc_s_layo.

**********************************************************************
* Common variable
**********************************************************************
DATA : gv_okcode     TYPE sy-ucomm,
       gv_number(10).                " 출하번호 채번
