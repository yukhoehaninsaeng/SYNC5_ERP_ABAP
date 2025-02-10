*&---------------------------------------------------------------------*
*& Include          SAPMZC302PP0002F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get-base_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_base_data .

  PERFORM get_left_data.

  PERFORM get_up_data.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_screen .

  IF go_container IS NOT BOUND.

    CLEAR gt_lfcat.
    PERFORM set_left_catalog USING: 'X' 'ICON'    'ZC302PPT0001' 'C' ' ',
                                    'X' 'PDPCODE' 'ZC302PPT0001' ' ' ' ',
                                    'X' 'MATNR'   'ZC302PPT0001' ' ' ' ',
                                    ' ' 'MAKTX'   'ZC302PPT0001' ' ' 'X',
                                    ' ' 'PQUA'    'ZC302PPT0001' ' ' ' ',
                                    ' ' 'UNIT'    'ZC302PPT0001' ' ' ' ',
                                    ' ' 'EMP_NUM' 'ZC302PPT0001' ' ' ' ',
                                    ' ' 'PDPDAT'  'ZC302PPT0001' ' ' ' ',
                                    ' ' 'PDDLD'   'ZC302PPT0001' ' ' ' '.
    CLEAR gt_ufcat.
    PERFORM set_up_catalog USING:   'X' 'ICON'    ' '            'C' ' ',
                                    'X' 'PLORDCO' 'ZC302PPT0002' ' ' ' ',
                                    'X' 'PDPCODE' 'ZC302PPT0002' ' ' ' ',
                                    'X' 'MATNR'   'ZC302PPT0002' ' ' ' ',
                                    ' ' 'MAKTX'   'ZC302PPT0002' ' ' 'X',
                                    ' ' 'EMP_NUM' 'ZC302PPT0002' ' ' ' ',
                                    ' ' 'PDPDAT'  'ZC302PPT0002' ' ' ' ',
                                    ' ' 'PDDLD'   'ZC302PPT0002' ' ' ' '.
    CLEAR gt_dfcat.
    PERFORM set_down_catalog USING: 'X' 'PLORDCO'   'ZC302PPT0003' ' ' ' ',
                                    'X' 'MATNR'     'ZC302PPT0003' ' ' ' ',
                                    ' ' 'MAKTX'     'ZC302PPT0003' ' ' 'X',
                                    ' ' 'MNAME'     'ZC302PPT0003' 'C' ' ',
                                    ' ' 'H_RTPTQUA' 'ZC302PPT0003' ' ' ' ',
                                    ' ' 'PQUA'      'ZC302PPT0003' ' ' ' ',
                                    ' ' 'RQAMT'     'ZC302PPT0003' ' ' ' ',
                                    ' ' 'UNIT'      'ZC302PPT0003' ' ' ' ',
                                    ' ' 'MATOD'     'ZC302PPT0003' ' ' ' ',
                                    ' ' 'PPSTR'     'ZC302PPT0003' ' ' ' '.
    PERFORM set_layout.
    PERFORM create_object.
    PERFORM exclude_toolbar TABLES gt_ui_functions.

    SET HANDLER: lcl_event_handler=>toolbar_left  FOR go_left_grid,
                 lcl_event_handler=>toolbar_up    FOR go_up_grid,
                 lcl_event_handler=>user_command  FOR go_left_grid,
                 lcl_event_handler=>user_command  FOR go_up_grid,
                 lcl_event_handler=>hotspot_click FOR go_up_grid.

    PERFORM call_alv_grid.

  ELSE.
    CLEAR gv_okcode.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_left_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_left_catalog  USING pv_key pv_field pv_table pv_just pv_emph.

  gs_lfcat = VALUE #( key = pv_key
                      fieldname = pv_field
                      ref_table = pv_table
                      just      = pv_just
                      emphasize = pv_emph ).

  CASE pv_field.
    WHEN 'UNIT'.
      gs_lfcat-coltext = '단위'.
    WHEN 'PQUA'.
      gs_lfcat-qfieldname = 'UNIT'.
    WHEN 'ICON'.
      gs_lfcat-coltext = '상태'.
    WHEN 'EMP_NUM'.
      gs_lfcat-coltext = '담당자'.
  ENDCASE.

  APPEND gs_lfcat TO gt_lfcat.
  CLEAR gs_lfcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_up_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_up_catalog  USING pv_key pv_field pv_table pv_just pv_emph.

  gs_ufcat = VALUE #( key = pv_key
                      fieldname = pv_field
                      ref_table = pv_table
                      just      = pv_just
                      emphasize = pv_emph ).

  CASE pv_field.
    WHEN 'ICON'.
      gs_ufcat-coltext = '상태'.
    WHEN 'PLORDCO'.
      gs_ufcat-hotspot = abap_true.
    WHEN 'EMP_NUM'.
      gs_ufcat-coltext = '담당자'.
  ENDCASE.

  APPEND gs_ufcat TO gt_ufcat.
  CLEAR gs_ufcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_down_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_down_catalog  USING pv_key pv_field pv_table pv_just pv_emph.

  gs_dfcat = VALUE #( key = pv_key
                      fieldname = pv_field
                      ref_table = pv_table
                      just      = pv_just
                      emphasize = pv_emph ).

  CASE pv_field.
    WHEN 'UNIT'.
      gs_dfcat-coltext    = '단위'.
    WHEN 'PQUA' OR 'H_RTPTQUA' OR 'RQAMT'.
      gs_dfcat-qfieldname = 'UNIT'.
    WHEN 'EMP_NUM'.
      gs_dfcat-coltext    = '담당자'.
    WHEN 'MNAME'.
      gs_dfcat-coltext    = '자재유형'.
  ENDCASE.

  APPEND gs_dfcat TO gt_dfcat.
  CLEAR gs_dfcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout .

  gs_llayo  = VALUE #( zebra      = 'X'
                       cwidth_opt = 'A'
                       sel_mode   = 'D'
                       grid_title = '생산계획'
                       smalltitle = abap_true ).

  gs_ulayo  = VALUE #( zebra      = 'X'
                       cwidth_opt = 'A'
                       sel_mode   = 'D'
                       grid_title = '계획오더 Header'
                       smalltitle = abap_true ).

  gs_dlayo  = VALUE #( zebra      = 'X'
                       cwidth_opt = 'A'
                       sel_mode   = 'D'
                       grid_title = '계획오더 Item'
                       ctab_fname = 'COLOR'
                       smalltitle = abap_true ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_object
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_object .

  CREATE OBJECT go_container
    EXPORTING
      container_name = 'MAIN_CONT'.

  CREATE OBJECT go_split_cont1
    EXPORTING
      parent  = go_container
      rows    = 1  " 1행
      columns = 2. " 2열

  CALL METHOD go_split_cont1->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_left_cont.

  CREATE OBJECT go_left_grid
    EXPORTING
      i_parent = go_left_cont.

  CALL METHOD go_split_cont1->get_container
    EXPORTING
      row       = 1
      column    = 2
    RECEIVING
      container = go_right_cont.

  CREATE OBJECT go_split_cont2
    EXPORTING
      parent  = go_right_cont
      rows    = 2
      columns = 1.

  CALL METHOD go_split_cont2->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_up_cont.

  CALL METHOD go_split_cont2->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_down_cont.

  CREATE OBJECT go_up_grid
    EXPORTING
      i_parent = go_up_cont.

  CREATE OBJECT go_down_grid
    EXPORTING
      i_parent = go_down_cont.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_UI_FUNCTIONS
*&---------------------------------------------------------------------*
FORM exclude_toolbar  TABLES   pt_ui_functions TYPE ui_functions.

  pt_ui_functions = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND pt_ui_functions.
  pt_ui_functions = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND pt_ui_functions.
  pt_ui_functions = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND pt_ui_functions.
  pt_ui_functions = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND pt_ui_functions.
  pt_ui_functions = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND pt_ui_functions.
  pt_ui_functions = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND pt_ui_functions.
  pt_ui_functions = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND pt_ui_functions.
  pt_ui_functions = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND pt_ui_functions.
  pt_ui_functions = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND pt_ui_functions.
  pt_ui_functions = cl_gui_alv_grid=>mc_fc_refresh.
  APPEND pt_ui_functions.
  pt_ui_functions = cl_gui_alv_grid=>mc_fc_auf.
  APPEND pt_ui_functions.
  pt_ui_functions = cl_gui_alv_grid=>mc_fc_average.
  APPEND pt_ui_functions.
  pt_ui_functions = cl_gui_alv_grid=>mc_fc_print.
  APPEND pt_ui_functions.
  pt_ui_functions = cl_gui_alv_grid=>mc_fc_graph.
  APPEND pt_ui_functions.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_ranges
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_ranges .

  REFRESH: gr_pdpcode, gr_pdpdat.

  IF gv_pdpcode IS NOT INITIAL.
    gr_pdpcode-sign   = 'I'.
    gr_pdpcode-option = 'EQ'.
    gr_pdpcode-low   = gv_pdpcode.
    APPEND gr_pdpcode.
  ENDIF.

  IF gv_pdpdat IS NOT INITIAL.
    gr_pdpdat-sign   = 'I'.
    gr_pdpdat-option = 'EQ'.
    gr_pdpdat-low   = gv_pdpdat.
    APPEND gr_pdpdat.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_select_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_select_data .

  " 생산계획 데이터 Setting
  PERFORM get_product_plan_data.

  " 생산계획 아이콘 지정
  PERFORM make_display_left.

  " ITAB -> ALV로 새로고침
  PERFORM refresh_left_table.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_left_table .

  DATA: ls_stable TYPE lvc_s_stbl.

  ls_stable-row = abap_true.
  ls_stable-col = abap_true.

  CALL METHOD go_left_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stable.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form reset_select_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM reset_select_data .

  " 입력필드 초기화
  CLEAR: gv_pdpcode, gv_pdpdat.

  " 생산계획 데이터 Setting
  PERFORM get_left_data.

  " 생산계획 아이콘 지정
  PERFORM make_display_left.

  " ITAB -> ALV로 새로고침
  PERFORM refresh_left_table.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM handle_left_tbar  USING po_object TYPE REF TO cl_alv_event_toolbar_set
                           pv_interactive.

*-- Set ALV Toolbar
  PERFORM set_left_tbar USING: ' '    ' '               ' '  3  ' '           po_object,
                               'MRPC' icon_calculation  ' ' ' ' ' MRP 계산'   po_object.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_3
*&      --> P_
*&      --> PO_OBJECT
*&---------------------------------------------------------------------*
FORM set_left_tbar  USING  pv_func pv_icon pv_qinfo pv_type pv_text
                         po_object TYPE REF TO cl_alv_event_toolbar_set.

  CLEAR gs_left_btn.
  gs_left_btn-function  = pv_func.
  gs_left_btn-icon      = pv_icon.
  gs_left_btn-quickinfo = pv_qinfo.
  gs_left_btn-butn_type = pv_type.
  gs_left_btn-text      = pv_text.
  APPEND gs_left_btn TO po_object->mt_toolbar.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_user_command
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM handle_user_command  USING  pv_ucomm.

  CASE pv_ucomm.
    WHEN 'MRPC'.
      PERFORM calculate_mrp.    " MRP 계산
    WHEN 'PREQ'.
      PERFORM purchase_request. " 구매요청
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form calculate_mrp
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM calculate_mrp .

  DATA: lt_row    TYPE lvc_t_row,
        ls_row    TYPE lvc_s_row,
        lv_answer.

*-- 선택된 행 받기
  CALL METHOD go_left_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_row.

  IF lt_row IS INITIAL.
    MESSAGE s001 WITH TEXT-e04 DISPLAY LIKE 'E'. " 행을 선택하세요.
    EXIT.
  ENDIF.

*-- MRP 계산을 수행할 것인지 확인
  PERFORM confirm_for_mrp CHANGING lv_answer.

  IF lv_answer NE '1'.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'.  " 계산을 취소하였습니다.
    EXIT.
  ENDIF.

*-- 상태 체크로 MRP 계산 여부를 판단
  LOOP AT lt_row INTO ls_row.

    CLEAR gs_plan.
    READ TABLE gt_plan INTO gs_plan INDEX ls_row-index.

    IF ( gs_plan-status EQ 'M' ) OR
       ( gs_plan-status EQ 'X' ).
      MESSAGE i001 WITH TEXT-e12 DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

  ENDLOOP.

*-- MRP 계산 중 (퍼포먼스)
  PERFORM progress_indicator.

*-- MRP 계산 후 계획오더 생성 확인
  PERFORM confirm_for_comp CHANGING lv_answer.

  IF lv_answer NE '1'.
    MESSAGE s001 WITH TEXT-e06 DISPLAY LIKE 'E'. " 계획오더 생성을 취소하였습니다.
    EXIT.
  ENDIF.

*-- MRP 계산 및 계획오더번호 채번 및 DB 저장

  " BOM Header 및 공정 Header 데이터 Setting
  PERFORM get_mrp_base_data.

  LOOP AT lt_row INTO ls_row.

    CLEAR: gs_plan, gs_order_h.
    READ TABLE gt_plan INTO gs_plan INDEX ls_row-index.

    " MRP를 계산을 위한 ITAB 생성
    PERFORM get_mrp_sub_data.

    " MRP 계산
    PERFORM set_mrp_calc_data.

    " 만약 필요소요량이 0보다 크다면 MRP 계산 없이 넘어간다.
    IF gv_h_rtptqua GE gv_pqua.
      MESSAGE i001 WITH TEXT-e07 gs_plan-pdpcode TEXT-e08. " 생산계획번호 &의 자재가 충분하므로 계획오더를 생성하지 않겠습니다.
      PERFORM make_display_pplan USING ls_row.
      PERFORM save_product_plan.
      CONTINUE.
    ENDIF.

    " 계획오더번호 채번
    PERFORM get_po_seq.

    " 생산계획 상태 변경 및 저장
    PERFORM make_display_pplan USING ls_row.
    PERFORM save_product_plan.

    " DB 저장
    PERFORM save_plod_data.

  ENDLOOP.

  " 생산계획 & 계획오더 Item 아이콘 지정
  PERFORM make_display_left.
  PERFORM make_display_up.

  " ITAB -> ALV로 새로고침
  PERFORM refresh_left_table.
  PERFORM refresh_up_table.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form confirm_for_mrp
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM confirm_for_mrp  CHANGING pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'MRP Dialog'
      text_question         = 'MRP 계산을 하시겠습니까?'
      text_button_1         = '네'(001)
      icon_button_1         = 'ICON_OKAY'
      text_button_2         = '아니요'(002)
      icon_button_2         = 'ICON_CANCEL'
      default_button        = '1'
      display_cancel_button = space
    IMPORTING
      answer                = pv_answer.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form confirm_for_comp
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM confirm_for_comp  CHANGING pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Complete Dialog'
      text_question         = '자재소요량 계산이 완료되었습니다. MRP 확정 및 계획 오더를 생성하시겠습니까?'
      text_button_1         = '네'(001)
      icon_button_1         = 'ICON_OKAY'
      text_button_2         = '아니요'(002)
      icon_button_2         = 'ICON_CANCEL'
      default_button        = '1'
      display_cancel_button = space
    IMPORTING
      answer                = pv_answer.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_display_up
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_up .

  DATA: lv_tabix TYPE sy-tabix.

  LOOP AT gt_order_h INTO gs_order_h.

    lv_tabix = sy-tabix.

    PERFORM set_icon_up.

    MODIFY gt_order_h FROM gs_order_h INDEX lv_tabix
                                      TRANSPORTING icon.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_icon_up
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_icon_up .

  CASE gs_order_h-insst.
    WHEN '01'.
      gs_order_h-icon = icon_datatypes_orphan.
    WHEN '02'.
      gs_order_h-icon = icon_datatypes_outdate.
    WHEN '03'.
      gs_order_h-icon = icon_datatypes_uptodate.
    WHEN '04'.
      gs_order_h-icon = icon_mapped_relation.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_up_tbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM handle_up_tbar  USING po_object TYPE REF TO cl_alv_event_toolbar_set
                           pv_interactive.

*-- Set ALV Toolbar
  PERFORM set_up_tbar USING: ' '    ' '             ' '  3  ' '        po_object,
                             'PREQ' icon_transport  ' ' ' ' TEXT-b02   po_object.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_up_tbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_3
*&      --> P_
*&      --> PO_OBJECT
*&---------------------------------------------------------------------*
FORM set_up_tbar  USING  pv_func pv_icon pv_qinfo pv_type pv_text
                         po_object TYPE REF TO cl_alv_event_toolbar_set.

  CLEAR gs_up_btn.
  gs_up_btn-function  = pv_func.
  gs_up_btn-icon      = pv_icon.
  gs_up_btn-quickinfo = pv_qinfo.
  gs_up_btn-butn_type = pv_type.
  gs_up_btn-text      = pv_text.
  APPEND gs_up_btn TO po_object->mt_toolbar.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_up_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_up_table .

  DATA: ls_stable TYPE lvc_s_stbl.

  ls_stable-row = abap_true.
  ls_stable-col = abap_true.

  CALL METHOD go_up_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stable.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form mrp_base_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_mrp_base_data .

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_bom
    FROM zc302ppt0004.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_product
    FROM zc302ppt0008.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_mrp_calc_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_mrp_sub_data .

*-- BOM header에서 bom_id를 가지고 온다.
  READ TABLE gt_bom INTO gs_bom WITH KEY matnr = gs_plan-matnr.

*-- 공정 header에서 공정코드를 가지고 온다.
  READ TABLE gt_product INTO gs_product WITH KEY matnr = gs_plan-matnr.

*-- BOM item을 기준으로 재고관리, 공정 Item, 생산계획을 조인하여 MRP 계산을 위한 테이블을 만든다.
  CLEAR gt_mrp.
  SELECT DISTINCT pdpcode bomid a~matnr b~maktx b~mtart a~bomnum b~h_rtptqua
                  d~pqua quant a~unit c~matmlt matlt d~pddld
    INTO CORRESPONDING FIELDS OF TABLE gt_mrp
    FROM zc302ppt0005 AS a INNER JOIN zc302mmt0013 AS b
      ON a~matnr EQ b~matnr
     AND b~scode NE 'ST05'
                           LEFT OUTER JOIN zc302ppt0009 AS c
      ON a~bomnum EQ c~bomnum
     AND c~pcode  EQ gs_product-pcode
                           LEFT OUTER JOIN zc302ppt0001 AS d
      ON a~matnr   EQ d~matnr
     AND d~pdpcode EQ gs_plan-pdpcode
   WHERE bomid EQ gs_bom-bomid
   ORDER BY a~bomnum b~maktx ASCENDING.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_mrp_calc_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_mrp_calc_data .

  gv_pddate = gs_plan-pddld - '4'.                  " 제품 납기일 - 검수 및 입고

  DATA: lv_cpro_need TYPE zc302ppt0003-rqamt,
        lv_tabix     TYPE sy-tabix.

  LOOP AT gt_mrp INTO gs_mrp.

    lv_tabix = sy-tabix.

* -- BOM 번호에 따라 계산
    CASE gs_mrp-bomnum.
      WHEN '0'.
        lv_cpro_need = gs_mrp-h_rtptqua - gs_mrp-pqua. " 필요 소요량 계산

        gs_mrp-rqamt = abs( lv_cpro_need ).             " 필요 소요량 Setting

        gv_h_rtptqua = gs_mrp-h_rtptqua.                " 현재재고 Setting
        gv_pqua      = gs_mrp-pqua.                     " 계획수량 Setting

        " 현재재고 > 계획수량 => 나간다.
        IF gv_h_rtptqua GE gv_pqua.
          EXIT.
        ENDIF.
      WHEN '1'.
        gs_mrp-ppstr = gv_pddate - gs_mrp-matmlt.         " 공정 시작일 계산
        gs_mrp-pqua = abs( lv_cpro_need ) * gs_mrp-quant. " 계획수량 계산
        gs_mrp-rqamt = gs_mrp-h_rtptqua - gs_mrp-pqua.    " 필요 소요량 계산

        IF gs_mrp-rqamt LT 0.
          gs_mrp-matod = gs_mrp-ppstr - gs_mrp-matlt.     " 구매 요청일 계산
        ENDIF.

        gv_pddate = gs_mrp-ppstr.
      WHEN '2'.
        gs_mrp-ppstr = gv_pddate - gs_mrp-matmlt.          " 공정 시작일 계산
        gs_mrp-pqua  = abs( lv_cpro_need ) * gs_mrp-quant. " 계획수량 계산
        gs_mrp-rqamt = gs_mrp-h_rtptqua - gs_mrp-pqua.     " 필요 소요량 계산

        IF gs_mrp-rqamt LT 0.
          gs_mrp-matod = gs_mrp-ppstr - gs_mrp-matlt.      " 구매 요청일 계산
        ENDIF.
    ENDCASE.

    MODIFY gt_mrp FROM gs_mrp INDEX lv_tabix
                              TRANSPORTING pqua ppstr matod rqamt.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_po_seq
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_po_seq .

  DATA: lv_tabix     TYPE sy-tabix,
        lv_number(3).

  MOVE-CORRESPONDING gs_plan TO gs_order_h.

  CLEAR: gs_order_h-erdat, gs_order_h-erzet, gs_order_h-ernam.

  " 계획오더번호 채번
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZC302PNON'
    IMPORTING
      number      = lv_number.

  CONCATENATE 'PMN' gs_plan-pdpcode+3(4) lv_number INTO DATA(lv_ponum).

  " gs_order_h에 채번한 것 추가
  gs_order_h-plordco = lv_ponum.

  " gs_order_h에 구매요청 상태 추가
  gs_order_h-insst = '01'.

  APPEND gs_order_h TO gt_order_h.

  " gt_mrp에 채번한 것 추가
  LOOP AT gt_mrp INTO gs_mrp.

    lv_tabix = sy-tabix.

    gs_mrp-plordco = lv_ponum.

    MODIFY gt_mrp FROM gs_mrp INDEX sy-tabix
                              TRANSPORTING plordco.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_plod_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_plod_data .

  DATA: lt_save_i TYPE TABLE OF zc302ppt0003,
        ls_save_i TYPE zc302ppt0003,
        ls_save_h TYPE zc302ppt0002,
        lv_tabix  TYPE sy-tabix.

  MOVE-CORRESPONDING gs_order_h TO ls_save_h.
  MOVE-CORRESPONDING gt_mrp TO lt_save_i.

  IF lt_save_i IS INITIAL.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.  " 저장된 데이터가 없습니다.
  ENDIF.

  " Set Time Stamp (계획오더 Header)
  IF ls_save_h-erdat IS INITIAL.
    ls_save_h-erdat = sy-datum.
    ls_save_h-ernam = sy-uname.
    ls_save_h-erzet = sy-uzeit.
  ELSE.
    ls_save_h-aedat = sy-datum.
    ls_save_h-aenam = sy-uname.
    ls_save_h-aezet = sy-uzeit.
  ENDIF.

  "* Set Time Stamp (계획오더 Item)
  LOOP AT lt_save_i INTO ls_save_i.

    lv_tabix = sy-tabix.

    IF ls_save_i-erdat IS INITIAL.
      ls_save_i-erdat = sy-datum.
      ls_save_i-ernam = sy-uname.
      ls_save_i-erzet = sy-uzeit.
    ELSE.
      ls_save_i-aedat = sy-datum.
      ls_save_i-aenam = sy-uname.
      ls_save_i-aezet = sy-uzeit.
    ENDIF.

    MODIFY lt_save_i FROM ls_save_i INDEX lv_tabix
                                    TRANSPORTING erdat ernam erzet
                                                 aedat aenam aezet.

  ENDLOOP.

  " 계획오더 Header DB에 저장
  MODIFY zc302ppt0002 FROM ls_save_h.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
*    MESSAGE s001 WITH TEXT-g01. " 저장이 완료되었습니다.
  ELSE.
    MESSAGE s000 WITH TEXT-e03 DISPLAY LIKE 'E'. " 저장에 실패하였습니다.
    ROLLBACK WORK.
  ENDIF.

  " 계획오더 Item DB에 저장 (MRP)
  MODIFY zc302ppt0003 FROM TABLE lt_save_i.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
*    MESSAGE s001 WITH TEXT-g01. " 저장이 완료되었습니다.
  ELSE.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'. " 저장에 실패하였습니다.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_hotspot_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&---------------------------------------------------------------------*
FORM handle_hotspot_click  USING  pv_row_id pv_column_id.

  CLEAR gs_order_h.
  READ TABLE gt_order_h INTO gs_order_h INDEX pv_row_id.

  PERFORM get_order_i_data USING gs_order_h-plordco.

  PERFORM make_display_down.

  PERFORM refresh_down_table.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_order_i_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_ORDER_H_PLORDCO
*&---------------------------------------------------------------------*
FORM get_order_i_data  USING  pv_plordco.

  CLEAR gt_order_i.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_order_i
    FROM zc302ppt0003
   WHERE plordco EQ pv_plordco
   ORDER BY mtart DESCENDING.

  IF gt_order_i IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'. " 데이터가 존재하지 않습니다.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_down_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_down_table .

  DATA: ls_stable TYPE lvc_s_stbl.

  ls_stable-row = abap_true.
  ls_stable-col = abap_true.

  CALL METHOD go_down_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stable.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_display_down
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_down.

  DATA: lv_tabix     TYPE sy-tabix.

  CLEAR gs_order_i.
  LOOP AT gt_order_i INTO gs_order_i.

    lv_tabix = sy-tabix.

    PERFORM set_product_type.

    PERFORM set_down_style.

    IF ( gs_order_i-rqamt GE 0     ) AND
       ( gs_order_i-matnr NP 'CP*' ).
      gs_order_i-rqamt = 0.
    ENDIF.

    MODIFY gt_order_i FROM gs_order_i INDEX lv_tabix
                                      TRANSPORTING mname color rqamt.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_down_style
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> GS_ORDER_I_RQAMT
*&---------------------------------------------------------------------*
FORM set_down_style.

  DATA: ls_scol TYPE lvc_s_scol.

  " 필요소요량 Color 지정
  CLEAR ls_scol.
  ls_scol-fname = 'RQAMT'.

  IF gs_order_i-rqamt GE 0.
    ls_scol-color-col = 5.
    ls_scol-color-int = 1.
    IF gs_order_i-mtart EQ '03'.
      ls_scol-color-col = 3.
      ls_scol-color-int = 1.
    ENDIF.
  ELSE.
    ls_scol-color-col = 6.
    ls_scol-color-int = 1.
    IF gs_order_i-mtart EQ '03'.
      ls_scol-color-col = 3.
      ls_scol-color-int = 1.
    ENDIF.
  ENDIF.

  INSERT ls_scol INTO TABLE gs_order_i-color.

  " 제품 이름 Color 지정
  CLEAR ls_scol.
  ls_scol-fname = 'MNAME'.

  CASE gs_order_i-mtart.
    WHEN '03'.
      ls_scol-color-col = 6.
      ls_scol-color-inv = 1.
    WHEN '02'.
      ls_scol-color-col = 7.
      ls_scol-color-inv = 1.
    WHEN '01'.
      ls_scol-color-col = 3.
      ls_scol-color-inv = 1.
  ENDCASE.

  INSERT ls_scol INTO TABLE gs_order_i-color.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_left_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_left_data .

  PERFORM set_ranges.

  CLEAR gt_plan.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_plan
    FROM zc302ppt0001
   WHERE pdpcode IN gr_pdpcode
     AND pdpdat  IN gr_pdpdat
   ORDER BY pdpcode.

  IF gt_plan IS INITIAL.
    MESSAGE s001 WITH '생산계획의 ' TEXT-e01 DISPLAY LIKE 'E'.   " 데이터가 존재하지 않습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_up_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_up_data .

  CLEAR gt_order_h.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_order_h
    FROM zc302ppt0002
   ORDER BY plordco.

  IF gt_order_h IS INITIAL.
    MESSAGE s001 WITH '계획오더 Header의 ' TEXT-e01 DISPLAY LIKE 'E'.  " 데이터가 없습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_down_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_down_data .

  " 계획오더 Item 및 재고관리 데이터 Setting
  PERFORM get_down_data.

  " 계획오더 Item 데이터의 현재재고를 업데이트 후 필요소요량 계산
  PERFORM calc_req_amt.

  " 계획오더 Item DB 테이블에 업데이트
  PERFORM save_down_data.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_down_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_down_data .

  " 계획오더 Item DB의 데이터를 가져온다.
  CLEAR gt_odi_update.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_odi_update
    FROM zc302ppt0003
   WHERE matnr NOT LIKE 'CP%'
   ORDER BY plordco mtart DESCENDING.

  " 재고관리 DB의 데이터를 가져온다.
  CLEAR gt_inv_man.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_inv_man
    FROM zc302mmt0013
   WHERE matnr NOT LIKE 'CP%'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form calc_req_amt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM calc_req_amt .

  DATA: lv_cpro_need TYPE zc302ppt0003-rqamt,
        lv_tabix     TYPE sy-tabix.

  LOOP AT gt_odi_update INTO gs_odi_update.

    lv_tabix = sy-tabix.

    READ TABLE gt_inv_man INTO gs_inv_man WITH KEY matnr = gs_odi_update-matnr.

    " 현재재고 업데이트
    gs_odi_update-h_rtptqua = gs_inv_man-h_rtptqua.

    " 필요소요량 계산
    gs_odi_update-rqamt = gs_odi_update-h_rtptqua - gs_odi_update-pqua.

    IF gs_odi_update-rqamt GE 0.
      gs_odi_update-rqamt = 0.
    ENDIF.

    MODIFY gt_odi_update FROM gs_odi_update INDEX lv_tabix
                                            TRANSPORTING h_rtptqua rqamt.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_down_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_down_data .

  DATA: lt_save_i TYPE TABLE OF zc302ppt0003,
        ls_save_i TYPE zc302ppt0003,
        lv_tabix  TYPE sy-tabix.

  MOVE-CORRESPONDING gt_odi_update TO lt_save_i.

  "* Set Time Stamp (계획오더 Item)
  LOOP AT lt_save_i INTO ls_save_i.

    lv_tabix = sy-tabix.

    IF ls_save_i-erdat IS INITIAL.
      ls_save_i-erdat = sy-datum.
      ls_save_i-ernam = sy-uname.
      ls_save_i-erzet = sy-uzeit.
    ELSE.
      ls_save_i-aedat = sy-datum.
      ls_save_i-aenam = sy-uname.
      ls_save_i-aezet = sy-uzeit.
    ENDIF.

    MODIFY lt_save_i FROM ls_save_i INDEX lv_tabix
                                    TRANSPORTING erdat ernam erzet
                                                 aedat aenam aezet.

  ENDLOOP.

  " 계획오더 Item DB에 저장 (MRP)
  MODIFY zc302ppt0003 FROM TABLE lt_save_i.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form purchase_request
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM purchase_request .

  DATA: lt_row    TYPE lvc_t_row,
        ls_row    TYPE lvc_s_row,
        lv_answer.

*-- 선택된 행 받기
  CALL METHOD go_up_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_row.

  IF lt_row IS INITIAL.
    MESSAGE s001 WITH TEXT-e04 DISPLAY LIKE 'E'.  " 행을 선택하세요.
    EXIT.
  ENDIF.

*-- 자재 구매를 요청할 것인지 확인
  PERFORM confirm_for_pre CHANGING lv_answer.

  IF lv_answer NE '1'.
    MESSAGE s001 WITH TEXT-e09 DISPLAY LIKE 'E'. " 자재 구매 요청을 취소하였습니다.
    EXIT.
  ENDIF.

*-- 구매요청이 완료된 건은 요청 못하게 한다.
  LOOP AT lt_row INTO ls_row.

    CLEAR gs_order_h.
    READ TABLE gt_order_h INTO gs_order_h INDEX ls_row-index.

    IF ( gs_order_h-insst EQ '02' ) OR
       ( gs_order_h-insst EQ '03' ).
      MESSAGE i001 WITH TEXT-e11 DISPLAY LIKE 'E'. " gs_order_h-maktx는 이미 구매요청이 완료되었습니다.
      RETURN.
    ENDIF.

  ENDLOOP.

*-- 구매요청 Hedaer & Internal Table에 채번 및 저장
  LOOP AT lt_row INTO ls_row.

    CLEAR gs_order_h.
    READ TABLE gt_order_h INTO gs_order_h INDEX ls_row-index.

    " 계획오더 Header와 Item의 데이터를 가지고 온다.
    PERFORM get_plan_order_i_data.

    " 구매 요청 Header와 Item의 데이터를 설정한다.
    PERFORM get_pur_req_data.

    " 구매요청번호 채번
    PERFORM get_pr_seq.

    " 구매요청 Header와 Item DB에 저장
    PERFORM save_pureq_data.

    " 계획오더 Header 상태 변경
    IF sy-subrc EQ 0.
      PERFORM change_porder_h_status USING ls_row-index.
    ENDIF.

    IF sy-subrc EQ 0.
      MESSAGE s001 WITH TEXT-g02. " 자재구매를 성공적으로 요청하였습니다.
    ENDIF.

  ENDLOOP.

  " ITAB -> ALV로 새로고침
  PERFORM refresh_up_table.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form confirm_for_pre
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM confirm_for_pre  CHANGING pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = '구매요청 Dialog'
      text_question         = '자재 구매를 요청하시겠습니까?'
      text_button_1         = '네'(001)
      icon_button_1         = 'ICON_OKAY'
      text_button_2         = '아니요'(002)
      icon_button_2         = 'ICON_CANCEL'
      default_button        = '1'
      display_cancel_button = space
    IMPORTING
      answer                = pv_answer.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_plan_order_i_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_plan_order_i_data.

*-- 구매요청 Header 추가를 위한 데이터
  CLEAR gs_order_i.
  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF gs_order_i
    FROM zc302ppt0003
   WHERE plordco EQ gs_order_h-plordco
     AND mtart   EQ '03'.

*-- 구매요청 Item 추가를 위한 데이터
  CLEAR gt_order_i.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_order_i
    FROM zc302ppt0003
   WHERE plordco EQ gs_order_h-plordco
     AND mtart NE '03'
     AND rqamt LT 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_pur_req_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_pur_req_data .

*-- 구매요청 Header 추가를 위한 데이터
  MOVE-CORRESPONDING gs_order_i TO gs_pureq_h.

  _init: gs_pureq_h-erdat,
         gs_pureq_h-ernam,
         gs_pureq_h-erzet,
         gs_pureq_h-aedat,
         gs_pureq_h-aenam,
         gs_pureq_h-aezet.

  gs_pureq_h-bedat   = sy-datum.
  gs_pureq_h-bedar   = abs( gs_order_i-rqamt ).
  gs_pureq_h-meins   = gs_order_i-unit.

*-- 구매요청 Item 추가를 위한 데이터
  CLEAR gt_pureq_i.
  SELECT a~matnr plordco a~maktx b~netwr b~waers
    INTO CORRESPONDING FIELDS OF TABLE gt_pureq_i
    FROM zc302ppt0003 AS a INNER JOIN zc302mt0007 AS b
      ON a~matnr EQ b~matnr
   WHERE plordco EQ gs_order_h-plordco
     AND a~mtart NE '03'
     AND rqamt   LT 0.

  PERFORM make_display_pureq.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_display_pureq
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_pureq .

  DATA: lv_tabix TYPE sy-tabix.

  LOOP AT gt_pureq_i INTO gs_pureq_i.

    lv_tabix = sy-tabix.

    READ TABLE gt_order_i INTO gs_order_i WITH KEY matnr = gs_pureq_i-matnr.

    IF sy-subrc EQ 0.
      gs_pureq_i-menge   = abs( gs_order_i-rqamt ) + 20.  " 구매요청수량
      gs_pureq_i-bedat   = gs_order_i-matod.              " 희망구매요청일자
      gs_pureq_i-meins   = gs_order_i-unit.               " 단위
    ENDIF.

    MODIFY gt_pureq_i FROM gs_pureq_i INDEX lv_tabix
                                      TRANSPORTING menge bedat meins.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_pr_seq
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_pr_seq .

  DATA: lv_tabix     TYPE sy-tabix,
        lv_number(4).

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZC302MMPR'
    IMPORTING
      number      = lv_number.

  CONCATENATE 'PR' gs_pureq_h-plordco+3(4) lv_number INTO DATA(lv_prnum).

  gs_pureq_h-banfn = lv_prnum.

  LOOP AT gt_pureq_i INTO gs_pureq_i.

    lv_tabix = sy-tabix.

    gs_pureq_i-banfn = lv_prnum.

    MODIFY gt_pureq_i FROM gs_pureq_i INDEX sy-tabix
                                      TRANSPORTING banfn.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_pureq_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_pureq_data .

  DATA: lt_save_i TYPE TABLE OF zc302mmt0005,
        ls_save_i TYPE zc302mmt0005,
        ls_save_h TYPE zc302mmt0004,
        lv_tabix  TYPE sy-tabix.

  MOVE-CORRESPONDING gs_pureq_h TO ls_save_h.
  MOVE-CORRESPONDING gt_pureq_i TO lt_save_i.

  IF ( ls_save_h IS INITIAL ) OR
     ( lt_save_i IS INITIAL ).
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'. " 저장된 데이터가 없습니다.
    EXIT.
  ENDIF.

  " Set Time Stamp (계획오더 Header)
  IF ls_save_h-erdat IS INITIAL.
    ls_save_h-erdat = sy-datum.
    ls_save_h-ernam = sy-uname.
    ls_save_h-erzet = sy-uzeit.
  ELSE.
    ls_save_h-aedat = sy-datum.
    ls_save_h-aenam = sy-uname.
    ls_save_h-aezet = sy-uzeit.
  ENDIF.

  "* Set Time Stamp (계획오더 Item)
  LOOP AT lt_save_i INTO ls_save_i.

    lv_tabix = sy-tabix.

    IF ls_save_i-erdat IS INITIAL.
      ls_save_i-erdat = sy-datum.
      ls_save_i-ernam = sy-uname.
      ls_save_i-erzet = sy-uzeit.
    ELSE.
      ls_save_i-aedat = sy-datum.
      ls_save_i-aenam = sy-uname.
      ls_save_i-aezet = sy-uzeit.
    ENDIF.

    MODIFY lt_save_i FROM ls_save_i INDEX lv_tabix
                                    TRANSPORTING erdat ernam erzet
                                                 aedat aenam aezet.

  ENDLOOP.

  " 구매요청 Header DB에 저장
  MODIFY zc302mmt0004 FROM ls_save_h.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
    MESSAGE s001 WITH TEXT-g01.  " 저장이 완료되었습니다.
  ELSE.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'. " 저장을 실패하였습니다.
    ROLLBACK WORK.
  ENDIF.

  " 구매요청 Item DB에 저장
  MODIFY zc302mmt0005 FROM TABLE lt_save_i.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
    MESSAGE s001 WITH TEXT-g01. " 저장이 완료되었습니다.
  ELSE.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'. " 저장을 실패하였습니다.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form change_porder_h_status
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM change_porder_h_status USING pv_index.

  DATA: ls_save TYPE zc302ppt0002.

  " 입고 상태와 아이콘 변경
  gs_order_h-insst = '02'.
  gs_order_h-icon  = icon_datatypes_outdate.

  MODIFY gt_order_h FROM gs_order_h INDEX pv_index
                                    TRANSPORTING insst icon.

  " 변경한 데이터 Update
  MOVE-CORRESPONDING gs_order_h TO ls_save.

  IF ls_save IS INITIAL.
    MESSAGE s000 WITH TEXT-e06 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  IF ls_save-erdat IS INITIAL.
    ls_save-erdat = sy-datum.
    ls_save-ernam = sy-uname.
    ls_save-erzet = sy-uzeit.
  ELSE.
    ls_save-aedat = sy-datum.
    ls_save-aenam = sy-uname.
    ls_save-aezet = sy-uzeit.
  ENDIF.

  MODIFY zc302ppt0002 FROM ls_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
    MESSAGE s006. " 저장이 완료되었습니다.
  ELSE.
    MESSAGE s000 WITH TEXT-e03 DISPLAY LIKE 'E'. " 저장을 실패하였습니다.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form progress_indicator
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM progress_indicator .

  DATA: lv_percentage TYPE i.

  lv_percentage = 20.

  DO 4 TIMES.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = lv_percentage      " indicator에 진행률(%)
        text       = '계산중입니다..'.  " 텍스트 표시

    WAIT UP TO 1 SECONDS.

    lv_percentage += 20.

  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_product_plan
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_product_plan .

  DATA: ls_save TYPE zc302ppt0001.

  MOVE-CORRESPONDING gs_plan TO ls_save.

  " Set Time Stamp (생산계획)
  IF ls_save-erdat IS INITIAL.
    ls_save-erdat = sy-datum.
    ls_save-ernam = sy-uname.
    ls_save-erzet = sy-uzeit.
  ELSE.
    ls_save-aedat = sy-datum.
    ls_save-aenam = sy-uname.
    ls_save-aezet = sy-uzeit.
  ENDIF.

  " 생산계획 DB에 저장
  MODIFY zc302ppt0001 FROM ls_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.  " 저장에 실패하였습니다.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_product_plan_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_product_plan_data .

  " Select-options 기능
  PERFORM set_ranges.

  CLEAR gt_plan.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_plan
    FROM zc302ppt0001
   WHERE pdpcode IN gr_pdpcode
     AND pdpdat  IN gr_pdpdat
   ORDER BY pdpcode.

  IF gt_plan IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.   " 데이터가 없습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_display_left
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_left .

  DATA: lv_tabix TYPE sy-tabix.

  LOOP AT gt_plan INTO gs_plan.

    lv_tabix = sy-tabix.

    PERFORM set_icon_left.

    MODIFY gt_plan FROM gs_plan INDEX lv_tabix
                                TRANSPORTING icon.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_icon_left
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_icon_left .

  CASE gs_plan-status.
    WHEN space.
      gs_plan-icon = icon_closed_folder_orphaned.
    WHEN 'M'.
      gs_plan-icon = icon_wd_model_node.
    WHEN 'X'.
      gs_plan-icon = icon_closed_folder_uptodate.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_up_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_up_data .

  DATA: lv_tabix TYPE sy-tabix.

  LOOP AT gt_order_h INTO gs_order_h.

    lv_tabix = sy-tabix.

    SELECT SINGLE COUNT(*)
      INTO @DATA(lv_num)
      FROM zc302ppt0003
     WHERE plordco EQ @gs_order_h-plordco
       AND matnr   NOT LIKE 'CP%'
       AND rqamt   GE 0.

    IF lv_num EQ 8.
      gs_order_h-insst = '03'.
      gs_order_h-icon = icon_datatypes_uptodate.
      MODIFY gt_order_h FROM gs_order_h INDEX lv_tabix
                                        TRANSPORTING insst icon.
    ENDIF.

  ENDLOOP.

  PERFORM save_plan_order.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_plan_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_plan_order .

  DATA : lt_save  TYPE TABLE OF zc302ppt0002,
         ls_save  TYPE zc302ppt0002,
         lv_tabix TYPE sy-tabix.

  MOVE-CORRESPONDING gt_order_h TO lt_save.

  "* Set Time Stamp (생산실적처리)
  LOOP AT lt_save INTO ls_save.

    lv_tabix = sy-tabix.

    IF ls_save-erdat IS INITIAL.
      ls_save-erdat = sy-datum.
      ls_save-ernam = sy-uname.
      ls_save-erzet = sy-uzeit.
    ELSE.
      ls_save-aedat = sy-datum.
      ls_save-aenam = sy-uname.
      ls_save-aezet = sy-uzeit.
    ENDIF.

    MODIFY lt_save FROM ls_save INDEX lv_tabix
                                TRANSPORTING erdat ernam erzet
                                             aedat aenam aezet.

  ENDLOOP.

  " DB에 저장
  MODIFY zc302ppt0002 FROM TABLE lt_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_product_type
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_product_type .

  CASE gs_order_i-mtart.
    WHEN '03'.
      gs_order_i-mname = '완제품'.
    WHEN '02'.
      gs_order_i-mname = '반제품'.
    WHEN '01'.
      gs_order_i-mname = '원자재'.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_srchelp_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_srchelp_data .

  CLEAR gt_pplan.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_pplan
    FROM zc302ppt0001.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_pdpcode
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_pdpcode_f4 .

  DATA : lt_return TYPE TABLE OF ddshretval WITH HEADER LINE,
         lt_read   TYPE TABLE OF dynpread WITH HEADER LINE. " (선택)

  IF lines( gt_pplan ) EQ 0.
    MESSAGE s001 WITH TEXT-e13 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- Execute Search Help(F4)
  REFRESH lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'PDPCODE'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GV_PDPCODE'
      window_title    = 'Product plan code'
      value_org       = 'S'
    TABLES
      value_tab       = gt_pplan
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

*----------------------------------------------------------------------------
* F4에서 선택 시 자재명까지 자동으로 바인딩되도록 하고 싶은 경우에만 추가(선택)
*----------------------------------------------------------------------------
*-- Get description
  lt_return = VALUE #( lt_return[ 1 ] OPTIONAL ).

*-- Set value to Dynpro
  REFRESH lt_read.
  lt_read-fieldname = 'GV_PDPCODE'.
  lt_read-fieldvalue = lt_return-fieldval.
  APPEND lt_read.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-repid
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = lt_read
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_pdpdat_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_pdpdat_f4 .

  DATA : lv_date TYPE sy-datum,
         lt_read TYPE TABLE OF dynpread WITH HEADER LINE.

*-- 날짜 데이터 입력을 위한 Search Help(F4) 설치
  CALL FUNCTION 'F4_DATE'
    EXPORTING
      date_for_first_month = sy-datum
    IMPORTING
      select_date          = lv_date.

*-- 선택한 날짜 입력 컴포넌트에 입력
  REFRESH : lt_read.
  lt_read-fieldname  = 'GV_PDPDAT'.
  lt_read-fieldvalue = lv_date.
  APPEND lt_read.

*-- lv_date가 00000000로 뜬다면 입력필드 클리어
  IF lv_date EQ '00000000'.
    REFRESH lt_read.
  ENDIF.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-repid
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = lt_read
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_display_pplan
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_pplan USING ps_row TYPE lvc_s_row.

  IF gv_h_rtptqua GE gv_pqua.
    gs_plan-status = 'M'.
  ELSE.
    gs_plan-status = 'X'.
  ENDIF.

  MODIFY gt_plan FROM gs_plan INDEX ps_row-index
                              TRANSPORTING status.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_alv_grid
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_alv_grid .

  gs_variant = VALUE #( report = sy-repid
                        handle = 'ALV1' ).

  CALL METHOD go_left_grid->set_table_for_first_display
    EXPORTING
      is_variant           = gs_variant
      i_save               = 'A'
      i_default            = 'X'
      is_layout            = gs_llayo
      it_toolbar_excluding = gt_ui_functions
    CHANGING
      it_outtab            = gt_plan
      it_fieldcatalog      = gt_lfcat.

  gs_variant = VALUE #( BASE gs_variant
                        handle = 'ALV2' ).

  CALL METHOD go_up_grid->set_table_for_first_display
    EXPORTING
      is_variant           = gs_variant
      i_save               = 'A'
      i_default            = 'X'
      is_layout            = gs_ulayo
      it_toolbar_excluding = gt_ui_functions
    CHANGING
      it_outtab            = gt_order_h
      it_fieldcatalog      = gt_ufcat.

  gs_variant = VALUE #( BASE gs_variant
                        handle = 'ALV3' ).

  CALL METHOD go_down_grid->set_table_for_first_display
    EXPORTING
      is_variant           = gs_variant
      i_save               = 'A'
      i_default            = 'X'
      is_layout            = gs_dlayo
      it_toolbar_excluding = gt_ui_functions
    CHANGING
      it_outtab            = gt_order_i
      it_fieldcatalog      = gt_dfcat.

ENDFORM.
