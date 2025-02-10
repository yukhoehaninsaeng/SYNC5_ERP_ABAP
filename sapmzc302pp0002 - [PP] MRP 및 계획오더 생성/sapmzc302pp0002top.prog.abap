*&---------------------------------------------------------------------*
*& Include SAPMZC302PP0002TOP                       - Module Pool      SAPMZC302PP0002
*&---------------------------------------------------------------------*
PROGRAM sapmzc302pp0002 MESSAGE-ID k5.

**********************************************************************
*&& Screen Elements
**********************************************************************
RANGES: gr_pdpcode FOR zc302ppt0001-pdpcode,
        gr_pdpdat  FOR zc302ppt0001-pdpdat.

DATA: gv_pdpcode TYPE zc302ppt0001-pdpcode,
      gv_pdpdat  TYPE zc302ppt0001-pdpdat.

**********************************************************************
*&& Macro
**********************************************************************
DEFINE _init.

  CLEAR &1.

END-OF-DEFINITION.

**********************************************************************
*&& Class instance
**********************************************************************
*-- Screen 100
DATA: go_container   TYPE REF TO cl_gui_custom_container,
      go_split_cont1 TYPE REF TO cl_gui_splitter_container,
      go_left_cont   TYPE REF TO cl_gui_container,
      go_right_cont  TYPE REF TO cl_gui_container,
      go_split_cont2 TYPE REF TO cl_gui_splitter_container,
      go_up_cont     TYPE REF TO cl_gui_container,
      go_down_cont   TYPE REF TO cl_gui_container,
      go_left_grid   TYPE REF TO cl_gui_alv_grid,
      go_up_grid     TYPE REF TO cl_gui_alv_grid,
      go_down_grid   TYPE REF TO cl_gui_alv_grid.

**********************************************************************
*&& Work Area & Internal Table
**********************************************************************
*-- 생산계획
DATA: BEGIN OF gs_plan,
        icon TYPE icon-id.
        INCLUDE STRUCTURE zc302ppt0001.
DATA: END OF gs_plan,
gt_plan LIKE TABLE OF gs_plan.

*-- 계획오더 Header
DATA: BEGIN OF gs_order_h,
        icon TYPE icon-id.
        INCLUDE STRUCTURE zc302ppt0002.
DATA: END OF gs_order_h,
gt_order_h LIKE TABLE OF gs_order_h.

*-- 계획오더 Item
DATA: BEGIN OF gs_order_i,
        mname(3).
        INCLUDE STRUCTURE zc302ppt0003.
DATA:   color    TYPE lvc_t_scol,
      END OF gs_order_i,
      gt_order_i LIKE TABLE OF gs_order_i.

*-- For MRP
DATA: BEGIN OF gs_mrp,
        plordco   TYPE zc302ppt0002-plordco, " 계획오더번호
        bomid     TYPE zc302ppt0005-bomid,   " BOM_ID
        matnr     TYPE zc302ppt0005-matnr,   " 자재코드
        maktx     TYPE zc302mmt0013-maktx,   " 자재명
        mtart     TYPE zc302mmt0013-mtart,   " 자재유형
        bomnum    TYPE zc302ppt0005-bomnum,  " BOM 번호
        h_rtptqua TYPE zc302mmt0013-h_rtptqua, " 현재재고(실시간제품수량)
        pqua      TYPE zc302ppt0001-pqua,    " 계획수량
        quant     TYPE zc302ppt0005-quant,   " 완제품 하나 만드는데 필요한 수량
        rqamt     TYPE zc302ppt0003-rqamt,   " 필요소요량
        unit      TYPE zc302ppt0005-unit,    " 단위
        matlt     TYPE zc302ppt0005-matlt,   " 구매리드타임
        matmlt    TYPE zc302ppt0009-matmlt,  " 생산리드타임
        matod     TYPE zc302ppt0003-matod,   " 구매요청일
        ppstr     TYPE zc302ppt0003-ppstr,   " 공정시작일
        pddld     TYPE zc302ppt0001-pddld,   " 제품납기일
      END OF gs_mrp,
      gt_mrp LIKE TABLE OF gs_mrp.

*-- BOM Header
DATA: gt_bom TYPE TABLE OF zc302ppt0004,      " BOM Header
      gs_bom TYPE zc302ppt0004.

*-- 공정 Header
DATA: gt_product TYPE TABLE OF zc302ppt0008,  " 공정 Header
      gs_product TYPE zc302ppt0008.

*-- 구매 요청
DATA: gt_pureq_h TYPE TABLE OF zc302mmt0004,
      gs_pureq_h TYPE zc302mmt0004,
      gt_pureq_i TYPE TABLE OF zc302mmt0005,
      gs_pureq_i TYPE zc302mmt0005.

*-- 계획오더 Item -> For 현재재고 업데이트
DATA: gt_odi_update LIKE gt_order_i,
      gs_odi_update LIKE gs_order_i.

*-- 재고관리 Header
DATA: gt_inv_man TYPE TABLE OF zc302mmt0013,
      gs_inv_man TYPE zc302mmt0013.

*-- For Search help (생산계획번호)
DATA: BEGIN OF gs_pplan,
        pdpcode TYPE zc302ppt0001-pdpcode,
        matnr   TYPE zc302ppt0001-matnr,
        maktx   TYPE zc302ppt0001-maktx,
      END OF gs_pplan,
      gt_pplan LIKE TABLE OF gs_pplan.

*-- For ALV
DATA: gt_lfcat   TYPE lvc_t_fcat,
      gt_ufcat   TYPE lvc_t_fcat,
      gt_dfcat   TYPE lvc_t_fcat,
      gs_lfcat   TYPE lvc_s_fcat,
      gs_ufcat   TYPE lvc_s_fcat,
      gs_dfcat   TYPE lvc_s_fcat,
      gs_llayo   TYPE lvc_s_layo,
      gs_ulayo   TYPE lvc_s_layo,
      gs_dlayo   TYPE lvc_s_layo,
      gs_variant TYPE disvariant.

*-- Exclude Toolbar
DATA: gt_ui_functions TYPE ui_functions.

*-- ALV Toolbar 생성
DATA: gs_left_btn TYPE stb_button,
      gs_up_btn   TYPE stb_button.

**********************************************************************
*&& Common Variable
**********************************************************************
DATA: gv_okcode TYPE sy-ucomm.

*-- MRP
DATA: gv_pddate    TYPE sy-datum,           " 공정 시작일 및 구매 요청일 계산을 위한 변수
      gv_planamt   TYPE zc302ppt0005-quant, " 계획 수량
      gv_h_rtptqua TYPE zc302mmt0013-h_rtptqua,
      gv_pqua      TYPE zc302ppt0001-pqua.
