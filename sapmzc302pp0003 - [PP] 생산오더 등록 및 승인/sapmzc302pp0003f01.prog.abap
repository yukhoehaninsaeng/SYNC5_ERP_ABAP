*&---------------------------------------------------------------------*
*& Include          SAPMZC302PP0003F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_base_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_base_data .

  PERFORM select_zc302ppt0002.

  PERFORM select_zc302ppt0007.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_zc302ppt0002
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_zc302ppt0002 .

  PERFORM set_ranges.

*-- 계획오더 Header
  CLEAR gt_plan_h.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_plan_h
    FROM zc302ppt0002
   WHERE plordco IN gr_plord
     AND matnr   IN gr_matnr.

  IF gt_plan_h IS INITIAL.
    MESSAGE s001 WITH '계획오더 Header의 ' TEXT-e01 DISPLAY LIKE 'E'. " 데이터가 존재하지 않습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_zc302ppt0007
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_zc302ppt0007 .

  CLEAR gt_order.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_order
    FROM zc302ppt0007.

  IF gt_order IS INITIAL.
    MESSAGE s001 WITH '생산오더의' TEXT-e01 DISPLAY LIKE 'E'. " 데이터가 존재하지 않습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_srch_help_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_srch_help_data .

  CLEAR gt_plord.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_plord
    FROM zc302ppt0002.

  CLEAR gt_matnr.
  SELECT matnr maktx
    INTO CORRESPONDING FIELDS OF TABLE gt_matnr
    FROM zc302mt0007
   WHERE mtart EQ '03'.

  CLEAR gt_emp.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_emp
    FROM zc302mt0003.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_display_body
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_up .

  DATA: lv_tabix TYPE sy-tabix.

  LOOP AT gt_plan_h INTO gs_plan_h.

    lv_tabix = sy-tabix.

    PERFORM set_icon_up.

    MODIFY gt_plan_h FROM gs_plan_h INDEX lv_tabix
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

  CASE gs_plan_h-insst.
    WHEN '01'.
      gs_plan_h-icon = icon_datatypes_orphan.
    WHEN '02'.
      gs_plan_h-icon = icon_datatypes_outdate.
    WHEN '03'.
      gs_plan_h-icon = icon_datatypes_uptodate.
    WHEN '04'.
      gs_plan_h-icon = icon_mapped_relation.
  ENDCASE.

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

    CLEAR gt_ufcat.
    PERFORM set_up_catalog USING: 'X' 'ICON'    'ZC302PPT0002' 'C' ' ',
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
    CLEAR gt_rfcat.
    PERFORM set_right_catalog USING: 'X' 'ICON'    ' '            'C' ' ',
                                     'X' 'PONUM'   'ZC302PPT0007' ' ' ' ',
                                     'X' 'PLORDCO' 'ZC302PPT0007' ' ' ' ',
                                     'X' 'MATNR'   'ZC302PPT0007' ' ' ' ',
                                     ' ' 'MAKTX'   'ZC302PPT0007' ' ' 'X',
                                     ' ' 'RQAMT'   'ZC302PPT0007' ' ' ' ',
                                     ' ' 'UNIT'    'ZC302PPT0007' ' ' ' ',
                                     ' ' 'PLANT'   'ZC302PPT0007' ' ' ' ',
                                     ' ' 'SCODE'   'ZC302PPT0007' ' ' ' ',
                                     ' ' 'EMP_NUM' 'ZC302PPT0007' ' ' ' ',
                                     ' ' 'PDRDAT'  'ZC302PPT0007' ' ' ' ',
                                     ' ' 'PDDLD'   'ZC302PPT0007' ' ' ' '.
    PERFORM set_layout.
    PERFORM create_object.
    PERFORM exclude_toolbar TABLES gt_ui_functions.

    gs_variant = VALUE #( report = sy-repid
                          handle = 'ALV1' ).

    SET HANDLER : lcl_event_handler=>toolbar       FOR go_up_grid,
                  lcl_event_handler=>user_command  FOR go_up_grid,
                  lcl_event_handler=>hotspot_click FOR go_up_grid.

    CALL METHOD go_up_grid->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        i_save               = 'A'
        i_default            = 'X'
        is_layout            = gs_ulayo
        it_toolbar_excluding = gt_ui_functions
      CHANGING
        it_outtab            = gt_plan_h
        it_fieldcatalog      = gt_ufcat.

    gs_variant = VALUE #( handle = 'ALV2' ).

    CALL METHOD go_down_grid->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        i_save               = 'A'
        i_default            = 'X'
        is_layout            = gs_dlayo
        it_toolbar_excluding = gt_ui_functions
      CHANGING
        it_outtab            = gt_plan_i
        it_fieldcatalog      = gt_dfcat.

    gs_variant = VALUE #( handle = 'ALV3' ).

    CALL METHOD go_right_grid->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        i_save               = 'A'
        i_default            = 'X'
        is_layout            = gs_rlayo
        it_toolbar_excluding = gt_ui_functions
      CHANGING
        it_outtab            = gt_order
        it_fieldcatalog      = gt_rfcat.

  ELSE.
    CLEAR gv_okcode.
  ENDIF.

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

  gs_ufcat = VALUE #( key       = pv_key
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

  gs_dfcat = VALUE #( key       = pv_key
                      fieldname = pv_field
                      ref_table = pv_table
                      just      = pv_just
                      emphasize = pv_emph ).

  CASE pv_field.
    WHEN 'UNIT'.
      gs_dfcat-coltext = '단위'.
    WHEN 'PQUA' OR 'H_RTPTQUA' OR 'RQAMT'.
      gs_dfcat-qfieldname = 'UNIT'.
    WHEN 'MNAME'.
      gs_dfcat-coltext = '자재유형'.
  ENDCASE.

  APPEND gs_dfcat TO gt_dfcat.
  CLEAR gs_dfcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_right_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_right_catalog  USING pv_key pv_field pv_table pv_just pv_emph.

  gs_rfcat = VALUE #( key       = pv_key
                      fieldname = pv_field
                      ref_table = pv_table
                      just      = pv_just
                      emphasize = pv_emph ).

  CASE pv_field.
    WHEN 'RQAMT'.
      gs_rfcat-qfieldname = 'UNIT'.
    WHEN 'ICON'.
      gs_rfcat-coltext = '상태'.
    WHEN 'UNIT'.
      gs_rfcat-coltext = '단위'.
    WHEN 'EMP_NUM'.
      gs_rfcat-coltext = '담당자'.
  ENDCASE.

  APPEND gs_rfcat TO gt_rfcat.
  CLEAR gs_rfcat.

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

  gs_rlayo  = VALUE #( zebra      = 'X'
                       cwidth_opt = 'A'
                       sel_mode   = 'D'
                       grid_title = '생산오더 정보'
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

  CALL METHOD go_split_cont1->get_container
    EXPORTING
      row       = 1
      column    = 2
    RECEIVING
      container = go_right_cont.

  CREATE OBJECT go_split_cont2
    EXPORTING
      parent  = go_left_cont
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

  CREATE OBJECT go_right_grid
    EXPORTING
      i_parent = go_right_cont.

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
*& Form handle_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM handle_toolbar  USING po_object TYPE REF TO cl_alv_event_toolbar_set
                           pv_interactive.

*-- Set ALV Toolbar
  PERFORM set_toolbar USING: ' '    ' '               ' '  3  ' '      po_object,
                             'PORG' icon_system_okay  ' ' ' ' TEXT-b01 po_object.

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
FORM set_toolbar  USING  pv_func pv_icon pv_qinfo pv_type pv_text
                         po_object TYPE REF TO cl_alv_event_toolbar_set.

  CLEAR gs_button.
  gs_button-function  = pv_func.
  gs_button-icon      = pv_icon.
  gs_button-quickinfo = pv_qinfo.
  gs_button-butn_type = pv_type.
  gs_button-text      = pv_text.
  APPEND gs_button TO po_object->mt_toolbar.

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
    WHEN 'PORG'.
      PERFORM product_order_seq.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form product_order_seq
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM product_order_seq .

  DATA: lt_row    TYPE lvc_t_row,
        ls_row    TYPE lvc_s_row,
        lv_ponum  TYPE zc302ppt0003-plordco,
        lv_answer.

*-- 선택된 행 받기
  CALL METHOD go_up_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_row.

  IF lt_row IS INITIAL.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'. " 행을 선택하세요.
    EXIT.
  ENDIF.

*-- 생산 오더를 등록할 것인지 확인
  PERFORM confirm_for_por CHANGING lv_answer.

  IF lv_answer NE '1'.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'. " 생산오더 등록을 취소하였습니다.
    EXIT.
  ENDIF.

*-- 계획오더 상태가 입고 완료가 아닌 경우 패쓰!!
  LOOP AT lt_row INTO ls_row.

    CLEAR gs_plan_h.
    READ TABLE gt_plan_h INTO gs_plan_h INDEX ls_row-index.

    IF ( gs_plan_h-insst EQ '01' ) OR
       ( gs_plan_h-insst EQ '02' ) .
      MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'. " 선택한 계획오더 중 입고가 완료되지 않은 계획오더가 있기에 다시 선택해주세요.
      RETURN.
    ENDIF.

  ENDLOOP.

*-- 생산오더 생성 및 계획오더 상태 변경
  LOOP AT lt_row INTO ls_row.

    CLEAR gs_plan_h.
    READ TABLE gt_plan_h INTO gs_plan_h INDEX ls_row-index.

    " 계획오더번호를 변수에 담는다.
    lv_ponum = gs_plan_h-plordco.

    PERFORM make_display_plan_order USING ls_row-index.


    " 생산오더 데이터를 JOIN을 통해 설정한다.
    PERFORM get_product_order_data USING lv_ponum.

    " 공장코드, 창고코드, 생산오더일자를 추가 & 담당자를 추가한다.
    PERFORM make_display_product_order.

    " 팝업창을 통해 오더승인날짜 및 담당자를 확인한다.
    IF gv_emp_num IS INITIAL.
      CALL SCREEN 101 STARTING AT 03 05
                      ENDING   AT 35 09.
    ENDIF.

    " 만약 사원번호의 데이터가 없다면 EXIT 한다.
    IF gv_emp_num IS INITIAL.
      MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'. " 생산오더 등록을 취소하였습니다.
      RETURN.
    ELSE.
      gs_order-emp_num = gv_emp_num.
    ENDIF.

    " 생산오더번호 채번 및 아이콘 지정
    PERFORM make_display_porder.

  ENDLOOP.

  " 계획오더 DB 및 생산오더 DB에 저장 & ITAB refresh
  PERFORM save_plan_order_h.
  PERFORM save_product_order.
  PERFORM refresh_right_table.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_product_order_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_PONUM
*&---------------------------------------------------------------------*
FORM get_product_order_data USING pv_ponum.

  CLEAR gs_order.
  SELECT SINGLE a~plordco, a~matnr, a~maktx, abs( rqamt ) AS rqamt,
                unit, ppstr, a~pddld
    INTO CORRESPONDING FIELDS OF @gs_order
    FROM zc302ppt0002 AS a INNER JOIN zc302ppt0003 AS b
      ON a~plordco EQ b~plordco
     AND a~matnr   EQ b~matnr
   WHERE a~plordco EQ @pv_ponum.

  IF gs_order IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.  " 데이터가 존재하지 않습니다.
    STOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_display_product_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_product_order .

  gs_order-plant  = 'PLN1'.
  gs_order-scode  = 'ST03'.
  gs_order-pdrdat = sy-datum.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_po_number_range
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_porder .

  DATA: lv_number(3).

  " 생산오더번호 채번
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZC302PONR'
    IMPORTING
      number      = lv_number.

  CONCATENATE 'PON' gs_order-plordco+3(4) lv_number INTO DATA(lv_ponum).

  gs_order-ponum = lv_ponum.

  " 아이콘 지정
  gs_order-icon  = icon_businav_objects_orphan.

  APPEND gs_order TO gt_order.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_product_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_product_order .

  DATA: lt_save  TYPE TABLE OF zc302ppt0007,
        ls_save  TYPE zc302ppt0007,
        lv_tabix TYPE sy-tabix.

  MOVE-CORRESPONDING gt_order TO lt_save.

  IF lt_save IS INITIAL.
    MESSAGE s001 WITH TEXT-e04 DISPLAY LIKE 'E'. " 저장된 데이터가 없습니다.
    EXIT.
  ENDIF.

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

  MODIFY zc302ppt0007 FROM TABLE lt_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'. " 저장을 실패하였습니다.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_right_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_right_table .

  DATA: ls_stable TYPE lvc_s_stbl.

  ls_stable-row = abap_true.
  ls_stable-col = abap_true.

  CALL METHOD go_right_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stable.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form confirm_for_por
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM confirm_for_por  CHANGING pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = '생산오더 Dialog'
      text_question         = '계획오더를 생산오더로 등록하시겠습니까?'
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
*& Form make_display_po_uc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_po_uc .

  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_employee_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_employee_f4 .

  DATA : lt_return TYPE TABLE OF ddshretval WITH HEADER LINE,
         lt_read   TYPE TABLE OF dynpread WITH HEADER LINE.

*-- Execute Search Help(F4)
  REFRESH lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'EMP_NUM'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GV_EMP_NUM'
      window_title    = 'Employee code'
      value_org       = 'S'
    TABLES
      value_tab       = gt_emp
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

*-- Get description
  lt_return = VALUE #( lt_return[ 1 ] OPTIONAL ).

  CLEAR : gs_emp.
  READ TABLE gt_emp INTO gs_emp WITH KEY emp_num = lt_return-fieldval.
  gv_ename = gs_emp-ename.

*-- Set value to Dynpro
  REFRESH lt_read.
  lt_read-fieldname = 'GV_EMP_NUM'.
  lt_read-fieldvalue = lt_return-fieldval.
  APPEND lt_read.
  lt_read-fieldname = 'GV_ENAME'.
  lt_read-fieldvalue = gs_emp-ename.
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
*& Form handle_hotspot_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&---------------------------------------------------------------------*
FORM handle_hotspot_click  USING   pv_row_id pv_column_id.

  CLEAR gs_plan_h.
  READ TABLE gt_plan_h INTO gs_plan_h INDEX pv_row_id.

  PERFORM get_order_i_data USING gs_plan_h-plordco.

  PERFORM make_display_order_i.

  PERFORM refresh_down_table.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_order_i_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_PLAN_H_PLORDCO
*&---------------------------------------------------------------------*
FORM get_order_i_data  USING  pv_plordco.

  CLEAR gt_plan_i.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_plan_i
    FROM zc302ppt0003
   WHERE plordco EQ pv_plordco
   ORDER BY mtart DESCENDING maktx DESCENDING.

  IF gt_plan_i IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'. " 데이터가 존재하지 않습니다.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_display_order_i
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_order_i .

  DATA: lv_tabix     TYPE sy-tabix.

  CLEAR gs_plan_i.
  LOOP AT gt_plan_i INTO gs_plan_i.

    lv_tabix = sy-tabix.

    PERFORM set_product_name.

    PERFORM set_order_i_style.

    MODIFY gt_plan_i FROM gs_plan_i INDEX lv_tabix
                                    TRANSPORTING mname color.

  ENDLOOP.

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
*& Form set_order_i_style
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_order_i_style .

  DATA: ls_scol   TYPE lvc_s_scol.

  " 필요소요량 Color 지정
  CLEAR ls_scol.
  ls_scol-fname = 'RQAMT'.

  IF gs_plan_i-rqamt GE 0.
    ls_scol-color-col = 5.
    ls_scol-color-int = 1.
    IF gs_plan_i-mtart EQ '03'.
      ls_scol-color-col = 3.
      ls_scol-color-int = 1.
    ENDIF.
  ELSE.
    ls_scol-color-col = 6.
    ls_scol-color-int = 1.
    IF gs_plan_i-mtart EQ '03'.
      ls_scol-color-col = 3.
      ls_scol-color-int = 1.
    ENDIF.
  ENDIF.

  INSERT ls_scol INTO TABLE gs_plan_i-color.

  " 제품 이름 Color 지정
  CLEAR ls_scol.
  ls_scol-fname = 'MNAME'.

  CASE gs_plan_i-mtart.
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

  INSERT ls_scol INTO TABLE gs_plan_i-color.

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

  REFRESH: gr_plord, gr_matnr.

  IF gv_plord IS NOT INITIAL.
    gr_plord-sign   = 'I'.
    gr_plord-option = 'EQ'.
    gr_plord-low   = gv_plord.
    APPEND gr_plord.
  ENDIF.

  IF gv_matnr IS NOT INITIAL.
    gr_matnr-sign   = 'I'.
    gr_matnr-option = 'EQ'.
    gr_matnr-low   = gv_matnr.
    APPEND gr_matnr.
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

  PERFORM select_zc302ppt0002.
  PERFORM make_display_up.
  PERFORM refresh_up_table.

  CLEAR gt_plan_i.
  PERFORM refresh_down_table.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_left_table
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
*& Form reset_select_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM reset_select_data .

  CLEAR: gv_plord, gv_matnr.

  PERFORM check_select_data.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_display_right
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_right .

  DATA: lv_tabix TYPE sy-tabix.

  CLEAR gs_order.
  LOOP AT gt_order INTO gs_order.

    lv_tabix = sy-tabix.

    PERFORM set_order_icon.

    MODIFY gt_order FROM gs_order INDEX lv_tabix
                                  TRANSPORTING icon.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_order_icon
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_order_icon .

  CASE gs_order-status.
    WHEN space.
      gs_order-icon = icon_businav_objects_orphan.
    WHEN '2'.
      gs_order-icon = icon_businav_objects_outdate.
    WHEN '3'.
      gs_order-icon = icon_businav_objects_uptodate.
    WHEN '4'.
      gs_order-icon = icon_display_more.
  ENDCASE.

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

  PERFORM get_down_data.

  PERFORM calc_req_amt.

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
    MESSAGE s000 WITH TEXT-e04 DISPLAY LIKE 'E'.  " 저장을 실패하였습니다.
    ROLLBACK WORK.
  ENDIF.
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

  LOOP AT gt_plan_h INTO gs_plan_h.

    lv_tabix = sy-tabix.

    SELECT SINGLE COUNT(*)
      INTO @DATA(lv_num)
      FROM zc302ppt0003
     WHERE plordco EQ @gs_plan_h-plordco
       AND matnr   NOT LIKE 'CP%'
       AND rqamt   GE 0.

    IF lv_num EQ 8.
      gs_plan_h-insst = '03'.
      gs_plan_h-icon = icon_datatypes_uptodate.
      MODIFY gt_plan_h FROM gs_plan_h INDEX lv_tabix
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

  MOVE-CORRESPONDING gt_plan_h TO lt_save.

  IF lt_save IS INITIAL.
    EXIT.
  ENDIF.

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
    MESSAGE s001 WITH TEXT-e04 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_product_name
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_product_name .

  CASE gs_plan_i-mtart.
    WHEN '03'.
      gs_plan_i-mname = '완제품'.
    WHEN '02'.
      gs_plan_i-mname = '반제품'.
    WHEN '01'.
      gs_plan_i-mname = '원자재'.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_plordco_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_plordco_f4 .

  DATA : lt_return TYPE TABLE OF ddshretval WITH HEADER LINE,
         lt_read   TYPE TABLE OF dynpread WITH HEADER LINE. " (선택)

*-- Execute Search Help(F4)
  REFRESH lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'PLORDCO'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GV_PLORD'
      window_title    = 'Plan order code'
      value_org       = 'S'
    TABLES
      value_tab       = gt_plord
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

*----------------------------------------------------------------------------
* F4에서 선택 시 자재명까지 자동으로 바인딩되도록 하고 싶은 경우에만 추가(선택)
*----------------------------------------------------------------------------
*-- Get description
*  lt_return = VALUE #( lt_return[ 1 ] OPTIONAL ).
*
*  CLEAR : gs_mat.
*  READ TABLE gt_mat INTO gs_mat WITH KEY matnr = lt_return-fieldval.
*  gv_maktx = gs_mat-maktx.

*-- Set value to Dynpro
  REFRESH lt_read.
  lt_read-fieldname = 'GV_PLORD'.
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
*& Form get_material_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_material_f4 .

  DATA : lt_return TYPE TABLE OF ddshretval WITH HEADER LINE,
         lt_read   TYPE TABLE OF dynpread WITH HEADER LINE. " (선택)

*-- Execute Search Help(F4)
  REFRESH lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'MATNR'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GV_MATNR'
      window_title    = 'Material code'
      value_org       = 'S'
    TABLES
      value_tab       = gt_matnr
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

*-- Set value to Dynpro
  REFRESH lt_read.
  lt_read-fieldname = 'GV_MATNR'.
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
*& Form make_display_emp
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_emp .

  gv_emp_num = sy-uname.

  READ TABLE gt_emp INTO gs_emp WITH KEY emp_num = gv_emp_num.

  gv_ename = gs_emp-ename.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_display_plan_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_plan_order USING pv_index.

  gs_plan_h-insst = '04'.
  gs_plan_h-icon  = icon_mapped_relation.

  MODIFY gt_plan_h FROM gs_plan_h INDEX pv_index
                                  TRANSPORTING insst icon.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_plan_order_h
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_plan_order_h .

  DATA : lt_save  TYPE TABLE OF zc302ppt0002,
         ls_save  TYPE zc302ppt0002,
         lv_tabix TYPE sy-tabix.

  MOVE-CORRESPONDING gt_plan_h TO lt_save.

  IF lt_save IS INITIAL.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  "* Set Time Stamp (생산실적처리)
  LOOP AT lt_save INTO ls_save.

    lv_tabix = sy-tabix.

    IF ls_save-erdat IS INITIAL.
      ls_save-erdat = sy-datum.
      ls_save-ernam = sy-uname.
      ls_save-erzet = sy-uzeit.
    ELSE.
      IF ls_save-insst EQ '04'.
        ls_save-aedat = sy-datum.
        ls_save-aenam = sy-uname.
        ls_save-aezet = sy-uzeit.
      ENDIF.
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
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
