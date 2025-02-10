*&---------------------------------------------------------------------*
*& Include SAPMZC302MM0002TOP                       - Module Pool      SAPMZC302MM0002
*&---------------------------------------------------------------------*
PROGRAM sapmzc302mm0002 MESSAGE-ID k5.


**********************************************************************
* class
**********************************************************************
DATA : go_cont       TYPE REF TO cl_gui_custom_container,
       go_split_cont TYPE REF TO cl_gui_splitter_container,
       go_left_cont  TYPE REF TO cl_gui_container,          " Left Container
       go_right_cont TYPE REF TO cl_gui_container,          " Right Container
       go_alv_grid   TYPE REF TO cl_gui_alv_grid,           " Left Grid
       go_right_grid TYPE REF TO cl_gui_alv_grid.           " Right Grid

DATA : go_split2_cont TYPE REF TO cl_gui_splitter_container, " Right Split
       go_up_cont     TYPE REF TO cl_gui_container,          " UP Container
       go_down_cont   TYPE REF TO cl_gui_container,          " Down Container
       go_up_grid     TYPE REF TO cl_gui_alv_grid,           " Up Grid
       go_down_grid   TYPE REF TO cl_gui_alv_grid.           " Down Grid

DATA : go_popup_cont  TYPE REF TO cl_gui_custom_container,
       go_split_cont3 TYPE REF TO cl_gui_splitter_container, " POPUP SPLIT
       go_up_cont2    TYPE REF TO cl_gui_container,          " POPUP ALV UP Container
       go_up_grid2    TYPE REF TO cl_gui_alv_grid,           " POPUP ALV Up Grid
       go_down_cont2  TYPE REF TO cl_gui_container,          " POPUP ALV Down Cont
       go_down_grid2  TYPE REF TO cl_gui_alv_grid.           " POPUP ALV Down Grid


**********************************************************************
* Screen element
**********************************************************************

DATA : gv_lowdate  TYPE zc302mmt0004-bedat,
       gv_highdate TYPE zc302mmt0004-bedat,
       gv_lro      TYPE zc302mmt0004-banfn,
       gv_hro      TYPE zc302mmt0004-banfn.

**********************************************************************
* RANGES
**********************************************************************
RANGES : gr_bedat FOR zc302mmt0004-bedat,
         gr_banfn FOR zc302mmt0004-banfn.

**********************************************************************
* Work Area & Internal table
**********************************************************************
*-- Request Material
DATA : BEGIN OF gs_body,
*         aufnr   TYPE zc302mmt0007-aufnr,
         icon    TYPE icon-id,
         banfn   TYPE zc302mmt0004-banfn,
         plordco TYPE zc302mmt0004-plordco,
         bedat   TYPE zc302mmt0004-bedat,
         bedar   TYPE zc302mmt0004-bedar,
         meins   TYPE zc302mmt0004-meins,
         matnr   TYPE zc302mmt0004-matnr,
         maktx   TYPE zc302mmt0005-maktx,
         rstatus TYPE zc302mmt0004-rstatus,
         matlt   TYPE zc302mt0007-matlt,
       END OF gs_body,
       gt_body LIKE TABLE OF gs_body.

*-- Search Help
DATA : BEGIN OF gs_pr,
         banfn TYPE zc302mmt0004-banfn,
       END OF gs_pr,
       gt_pr LIKE TABLE OF gs_pr.

DATA : gt_popup_body LIKE gt_body,
       gs_popup_body LIKE gs_body.

DATA : gs_table_body TYPE zc302mmt0004,
       gt_table_body TYPE TABLE OF zc302mmt0004.

DATA : gs_material TYPE zc302mt0007,
       gt_material TYPE TABLE OF zc302mt0007.

DATA : BEGIN OF gs_body2,
         matnr   TYPE zc302mmt0005-matnr,
         banfn   TYPE zc302mmt0005-banfn,
         plordco TYPE zc302mmt0005-plordco,
         maktx   TYPE zc302mmt0005-maktx,
         menge   TYPE zc302mmt0005-menge,
         meins   TYPE zc302mmt0005-meins,
         waers   TYPE zc302mmt0005-waers,
         netwr   TYPE zc302mmt0005-netwr,
         matlt   TYPE zc302mt0007-matlt,

       END OF gs_body2,
       gt_body2 LIKE TABLE OF gs_body2.


*-- For ALV
DATA : gt_fcat1 TYPE lvc_t_fcat,     " 자재구매요청 H
       gs_fcat1 TYPE lvc_s_fcat,     " 자재구매요청 H
       gs_layo  TYPE lvc_s_layo.     " 자재구매요청 H

DATA : gt_fcat2 TYPE lvc_t_fcat,     " 구매오더생성 H
       gs_fcat2 TYPE lvc_s_fcat,     " 구매오더생성 H
       gs_layo2 TYPE lvc_s_layo.

DATA : gt_fcat3 TYPE lvc_t_fcat,     " 구매오더생성 I
       gs_fcat3 TYPE lvc_s_fcat,     " 구매오더생성 I
       gs_layo3 TYPE lvc_s_layo.

*-- Popup ALV
DATA : gt_pfcat1 TYPE lvc_t_fcat,     " 자재구매요청 H
       gs_pfcat1 TYPE lvc_s_fcat,     " 자재구매요청 H
       gt_pfcat2 TYPE lvc_t_fcat,     " 자재구매요청 I
       gs_pfcat2 TYPE lvc_s_fcat,     " 자재구매요청 I
       gs_playo1 TYPE lvc_s_layo,
       gs_playo2 TYPE lvc_s_layo.

*-- Purchase order Header
DATA : BEGIN OF gs_sub_hdata,
         aufnr    TYPE zc302mmt0007-aufnr,              " 구매오더번호
         banfn    TYPE zc302mmt0007-banfn,              " 구매요청번호
         emp_num  TYPE zc302mmt0007-emp_num,            " 사원번호 직원마스터에서 가져와야됨
         ename    TYPE zc302mmt0007-ename,              " 직원이름 read table
         bedat    TYPE zc302mmt0007-bedat,              " 구매요청일자
         netwr    TYPE zc302mmt0007-netwr,              " 총 매입금액
         bodat    TYPE zc302mmt0007-bodat,              " 발주일자
         plordco  TYPE zc302mmt0007-plordco,            " 계획오더번호
         waers    TYPE zc302mmt0007-waers,              " 통화
         lfdat    TYPE zc302mmt0007-lfdat,              " 입고완료일
         stostat  TYPE zc302mmt0007-stostat,            " 입고상태
         icon_sub TYPE icon-id,
       END OF gs_sub_hdata,
       gt_sub_hdata LIKE TABLE OF gs_sub_hdata.

DATA : gs_temp_hdata TYPE zc302mmt0007,
       gt_temp_hdata TYPE TABLE OF zc302mmt0007.

*-- Purchase order Item
DATA : BEGIN OF gs_sub_idata,
         aufnr   TYPE zc302mmt0008-aufnr,
         banfn   TYPE zc302mmt0008-banfn,
         plordco TYPE zc302mmt0008-plordco,
         bpcode  TYPE zc302mmt0008-bpcode,
         matnr   TYPE zc302mmt0008-matnr,
         maktx   TYPE zc302mmt0008-maktx,
         menge   TYPE zc302mmt0008-menge,
         meins   TYPE zc302mmt0008-meins,
         netwr   TYPE zc302mmt0008-netwr,
         waers   TYPE zc302mmt0008-waers,
         matlt   TYPE zc302mt0007-matlt,
         devsta  TYPE zc302mmt0008-devsta,
         eindt   TYPE zc302mmt0008-eindt,
         lfdat   TYPE zc302mmt0008-lfdat,              " 입고완료일
         icon_i  TYPE icon-id,
       END OF gs_sub_idata,
       gt_sub_idata LIKE TABLE OF gs_sub_idata.

DATA : gs_temp_idata TYPE zc302mmt0008,
       gt_temp_idata TYPE TABLE OF zc302mmt0008.

DATA : gs_qc TYPE zc302mmt0006,
       gt_qc TYPE TABLE OF zc302mmt0006.

*-- ALV Toolbar 생성
DATA : gs_po_btn TYPE stb_button.

*-- Exclude ALV Toolbar
DATA : gt_ui_functions TYPE  ui_functions.

**********************************************************************
* Common Variable
**********************************************************************
DATA : gv_okcode TYPE sy-ucomm,
       gv_tabix  TYPE sy-tabix,
       gv_chrow.

DATA : gv_delivery_date TYPE sy-datum.


**---임시 쓰레기통
* aufnr   TYPE zc302mmt0007-aufnr,  "구매오더번호
*         banfn   TYPE zc302mmt0004-banfn,  "구매요청번호
*         emp_num TYPE zc302mmt0007-emp_num,
*         emp_ap  TYPE zc302mmt0007-emp_ap,
*         bedat   TYPE zc302mmt0007-bedat,
*         menge   TYPE zc302mmt0008-menge,
*         meins   TYPE zc302mmt0008-meins,
*         pelnh   TYPE zc302mmt0008-peinh, " 단가
*         netwr   TYPE zc302mmt0007-netwr,  " 총매입금액
*         waers   TYPE zc302mmt0007-waers,
