*&---------------------------------------------------------------------*
*& Include          SAPMZC302PP0004F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module GET_DOCUMENT_DATA OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE get_document_data OUTPUT.

  IF go_container IS NOT BOUND.

    " 생산오더 데이터
    PERFORM get_base_data.

    " 공정 Header 데이터
    PERFORM get_for_log_data.

    " 공정진행로그 데이터
    PERFORM get_product_log_data.

    " 재고관리 데이터
    PERFORM get_inv_management_data.

    " 생산오더번호 및 자재코드 F4 데이터
    PERFORM get_srch_help_data.

    " 재고관리 데이터 MEMORY ID로 저장
    IMPORT
      gt_invman TO gt_invman
      FROM MEMORY ID 'INV'.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form get_base_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_base_data .

  PERFORM set_ranges.

  CLEAR gt_order.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_order
    FROM zc302ppt0007
   WHERE ponum IN gr_ponum
     AND matnr IN gr_matnr.

  IF gt_order IS INITIAL.
    MESSAGE s001 WITH '생산오더의 ' TEXT-e01 DISPLAY LIKE 'E'. " 데이터가 존재하지 않습니다.
  ENDIF.

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

    " 필드 카탈로그 설정
    PERFORM set_field_catalog.

    " 레이아웃 설정
    PERFORM set_layout.

    " 객체 생성 (Splitter Container, ALV)
    PERFORM create_object.

    " ALV Toolbar 제거
    PERFORM exclude_toolbar TABLES gt_ui_functions.

    " ALV 세팅
    PERFORM set_alv_grid.

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
      gs_ufcat-coltext    = '상태'.
    WHEN 'RQAMT'.
      gs_ufcat-qfieldname = 'UNIT'.
    WHEN 'QUIN'.
      gs_ufcat-coltext    = '검수상태'.
    WHEN 'EMP_NUM'.
      gs_ufcat-coltext    = '담당자'.
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
    WHEN 'ICON'.
      gs_dfcat-coltext = '상태'.
    WHEN 'PSTEP'.
      gs_dfcat-coltext = '진행단계'.
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

  gs_ulayo  = VALUE #( zebra      = abap_true
                       cwidth_opt = 'A'
                       sel_mode   = 'D'
                       stylefname = 'CELLTAB'
*                       no_toolbar = abap_true
                       grid_title = '생산오더 정보'
                       smalltitle = abap_true ).

  gs_dllayo = VALUE #( zebra      = abap_true
                       cwidth_opt = 'A'
                       sel_mode   = 'D'
                       no_toolbar = abap_true
                       grid_title = '제형 제조'
                       smalltitle = abap_true ).

  gs_dclayo = VALUE #( zebra      = abap_true
                       cwidth_opt = 'A'
                       sel_mode   = 'D'
                       no_toolbar = abap_true
                       grid_title = '충진'
                       smalltitle = abap_true ).

  gs_drlayo = VALUE #( zebra      = abap_true
                       cwidth_opt = 'A'
                       sel_mode   = 'D'
                       no_toolbar = abap_true
                       grid_title = '포장'
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
      rows    = 2  " 2행
      columns = 1. " 1열

  CALL METHOD go_split_cont1->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_up_cont.

  CALL METHOD go_split_cont1->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_down_cont.

  CREATE OBJECT go_split_cont2
    EXPORTING
      parent  = go_down_cont
      rows    = 1  " 1행
      columns = 3. " 3열

  CALL METHOD go_split_cont2->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_left_cont.

  CALL METHOD go_split_cont2->get_container
    EXPORTING
      row       = 1
      column    = 2
    RECEIVING
      container = go_cent_cont.

  CALL METHOD go_split_cont2->get_container
    EXPORTING
      row       = 1
      column    = 3
    RECEIVING
      container = go_right_cont.

*-- ALV 객체 생성
  CREATE OBJECT go_up_grid
    EXPORTING
      i_parent = go_up_cont.

  CREATE OBJECT go_left_grid
    EXPORTING
      i_parent = go_left_cont.

  CREATE OBJECT go_cent_grid
    EXPORTING
      i_parent = go_cent_cont.

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
*& Form set_alv_grid
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_alv_grid .

  SET HANDLER: lcl_event_handler=>toolbar      FOR go_up_grid,
               lcl_event_handler=>button_click FOR go_up_grid,
               lcl_event_handler=>user_command FOR go_up_grid.

  gs_variant = VALUE #( report = sy-repid
                        handle = 'ALV1' ).

  CALL METHOD go_up_grid->set_table_for_first_display
    EXPORTING
      is_variant           = gs_variant
      i_save               = 'A'
      i_default            = 'X'
      is_layout            = gs_ulayo
      it_toolbar_excluding = gt_ui_functions
    CHANGING
      it_outtab            = gt_order
      it_fieldcatalog      = gt_ufcat.

  gs_variant = VALUE #( handle = 'ALV2' ).

  CALL METHOD go_left_grid->set_table_for_first_display
    EXPORTING
      is_variant           = gs_variant
      i_save               = 'A'
      i_default            = 'X'
      is_layout            = gs_dllayo
      it_toolbar_excluding = gt_ui_functions
    CHANGING
      it_outtab            = gt_make
      it_fieldcatalog      = gt_dfcat.

  gs_variant = VALUE #( handle = 'ALV3' ).

  CALL METHOD go_cent_grid->set_table_for_first_display
    EXPORTING
      is_variant           = gs_variant
      i_save               = 'A'
      i_default            = 'X'
      is_layout            = gs_dclayo
      it_toolbar_excluding = gt_ui_functions
    CHANGING
      it_outtab            = gt_fill
      it_fieldcatalog      = gt_dfcat.

  gs_variant = VALUE #( handle = 'ALV4' ).

  CALL METHOD go_right_grid->set_table_for_first_display
    EXPORTING
      is_variant           = gs_variant
      i_save               = 'A'
      i_default            = 'X'
      is_layout            = gs_drlayo
      it_toolbar_excluding = gt_ui_functions
    CHANGING
      it_outtab            = gt_pack
      it_fieldcatalog      = gt_dfcat.

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

*-- Set ALV Toolbar (공정 지시 버튼 생성)
  PERFORM set_toolbar USING: ' '    ' '               ' '  3  ' '      po_object,
                             'PCIS' icon_calculation  ' ' ' ' TEXT-b01 po_object.

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
FORM handle_user_command  USING    pv_ucomm.

  CASE pv_ucomm.
    WHEN 'PCIS'.
      PERFORM process_progress. " 공정지시 버튼 기능
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_field_catalog .

  CLEAR gt_ufcat.
  PERFORM set_up_catalog USING: 'X' 'ICON'    'ZC302PPT0007' 'C' ' ',
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
                                ' ' 'PDDLD'   'ZC302PPT0007' ' ' ' ',
                                ' ' 'QUIN'    ' '            'C' ' '.
  CLEAR gt_dfcat.
  PERFORM set_down_catalog USING: 'X' 'ICON'  ' '            'C' ' ',
                                  'X' 'PONUM' 'ZC302PPT0010' ' ' ' ',
                                  'X' 'PCODE' 'ZC302PPT0010' ' ' ' ',
                                  ' ' 'PSTEP' 'ZC302PPT0010' 'C' ' ',
                                  ' ' 'PPERC' 'ZC302PPT0010' ' ' 'X',
                                  ' ' 'PPSTR' 'ZC302PPT0010' ' ' ' ',
                                  ' ' 'PPEND' 'ZC302PPT0010' ' ' ' '.

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

  CLEAR gs_order.
  LOOP AT gt_order INTO gs_order.

    lv_tabix = sy-tabix.

    PERFORM set_order_icon.

    PERFORM set_btn_style.

    MODIFY gt_order FROM gs_order INDEX lv_tabix
                                  TRANSPORTING icon celltab quin.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_progress
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_progress .

  DATA: lt_row    TYPE lvc_t_row,
        ls_row    TYPE lvc_s_row,
        lv_answer.

*-- 선택된 행 받기
  CALL METHOD go_up_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_row.

  IF lt_row IS INITIAL.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'. " 행을 선택하세요.
    EXIT.
  ENDIF.

*-- 공정을 시작할 것인지 확인
  PERFORM confirm_for_process CHANGING lv_answer.

  IF lv_answer NE '1'.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'. " 공정을 취소하였습니다.
    EXIT.
  ENDIF.

*-- 배치 잡 설정 (Scheduled -> Released)
  IF sy-subrc EQ 0.
    PERFORM set_batch_job.
  ENDIF.

  IF sy-subrc <> 0.
    MESSAGE s001 WITH TEXT-e04 DISPLAY LIKE 'E'. " 배치 잡 등록을 취소하였습니다.
    EXIT.
  ENDIF.

*-- 생산오더번호 별 공정진행 로그 생성 및 저장
  LOOP AT lt_row INTO ls_row.

    " 생산 오더
    gs_order = VALUE #( gt_order[ ls_row-index ] OPTIONAL ).

    " 공정 진행 로그 데이터 생성
    PERFORM set_product_log_data.

    " 공정 진행 로그 데이터 저장
    PERFORM save_product_log_data.

    " 생산 오더 상태 변경
    PERFORM set_status_product_order USING ls_row.

    " 재고관리 업데이트
    PERFORM set_porder_item.

    " 생산오더 DB 저장
    PERFORM save_product_order_data.

  ENDLOOP.

*-- 공정 진행 로그 데이터 전체 조회
  CLEAR gt_pro_log.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_pro_log
    FROM zc302ppt0010.

   " 아이콘 지정
  _make_icon: gs_pro_log gt_pro_log.

*-- 제형 제조 ALV에 데이터를 띄우기 위해 제조 데이터 조회
  CLEAR gt_make.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_make
    FROM zc302ppt0010
   WHERE pstep  EQ 'A'
     AND status EQ '2'.

  " 아이콘 지정
  _make_icon: gs_make gt_make.

  " 생산오더 ALV 새로고침
  PERFORM refresh_up_table.

  " 제조 ALV 새로고침
  PERFORM refresh_make_table.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form confirm_for_process
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM confirm_for_process  CHANGING pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = '공정지시 Dialog'
      text_question         = '공정을 시작하시겠습니까?'
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
*& Form get_for_log_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_for_log_data .

*-- 공정 Header 데이터 설정
  CLEAR gt_pro_h.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_pro_h
    FROM ZC302ppt0008.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_product_log_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_product_log_data .

  " 공정 진행 로그 상태
  " ' ' : 공정 대기
  " '2' : 공정 진행
  " '3' : 공정 완료

  DATA: lv_tabix TYPE sy-tabix.

*-- 공정 Header (자재코드가 같은)
  gs_pro_h = VALUE #( gt_pro_h[ matnr = gs_order-matnr ] OPTIONAL ).

*-- 공정시작일 데이터를 위한 계획오더 Item 데이터 설정 (계획오더번호가 같은)
  CLEAR gt_porder_i.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_porder_i
    FROM zc302ppt0003
   WHERE plordco EQ gs_order-plordco
   ORDER BY mtart DESCENDING ppstr DESCENDING.

  IF gt_porder_i IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'. " 데이터가 존재하지 않습니다.
    STOP.
  ENDIF.

*-- 공정 Item으로 공정 진행 로그 데이터 설정
  CLEAR gt_pro_log.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_pro_log
    FROM zc302ppt0009
   WHERE pcode EQ gs_pro_h-pcode.

  IF gt_pro_log IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'. " 데이터가 존재하지 않습니다.
    STOP.
  ENDIF.

*-- 공정 진행 로그에 생산오더번호 넣기 & 공정 시작일 넣기
  LOOP AT gt_pro_log INTO gs_pro_log.

    lv_tabix = sy-tabix.

    " 생산오더번호 추가
    gs_pro_log-ponum = gs_order-ponum.

    " 공정 시작일 추가
    CLEAR gs_porder_i.
    CASE gs_pro_log-pstep.
      WHEN 'A'.
        READ TABLE gt_porder_i INTO gs_porder_i INDEX 4.
        gs_pro_log-ppstr = gs_porder_i-ppstr.
      WHEN 'B'.
        READ TABLE gt_porder_i INTO gs_porder_i INDEX 3.
        gs_pro_log-ppstr = gs_porder_i-ppstr.
      WHEN 'C'.
        READ TABLE gt_porder_i INTO gs_porder_i INDEX 2.
        gs_pro_log-ppstr = gs_porder_i-ppstr.
    ENDCASE.

    " 공정 진행 로그 상태 변경 (제형 제조만)
    IF gs_pro_log-pstep EQ 'A'.
      gs_pro_log-status = '2'.
    ENDIF.

    MODIFY gt_pro_log FROM gs_pro_log INDEX lv_tabix
                                      TRANSPORTING ponum ppstr status.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_product_log_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_product_log_data .

  DATA: lt_save  TYPE TABLE OF zc302ppt0010,
        ls_save  TYPE zc302ppt0010,
        lv_tabix TYPE sy-tabix.

  MOVE-CORRESPONDING gt_pro_log TO lt_save.

  IF lt_save IS INITIAL.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'. " 저장된 데이터가 없습니다.
    EXIT.
  ENDIF.

  "* Set Time Stamp (계획오더 Item)
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

  " 공정 진행 로그 DB에 저장
  MODIFY zc302ppt0010 FROM TABLE lt_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE s001 WITH TEXT-e06 DISPLAY LIKE 'E'. " 저장을 실패하였습니다.
    ROLLBACK WORK.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_make_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_make_table .

  DATA: ls_stable TYPE lvc_s_stbl.

  ls_stable-row = abap_true.
  ls_stable-col = abap_true.

  CALL METHOD go_left_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stable.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE gv_okcode.
    WHEN 'REFH'. " 새로고침
      PERFORM refresh_data.
    WHEN 'CHK1'. " 조회 버튼
      PERFORM check_select_data.
    WHEN 'INI1'. " 초기화 버튼
      PERFORM reset_select_data.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form refresh_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_data .

  DATA: lo_ran   TYPE REF TO cl_abap_random_int,
        lv_tabix TYPE sy-tabix,
        lv_num   TYPE i.

  " 난수를 5~16사이로 Setting
  lo_ran = cl_abap_random_int=>create( seed = CONV i( sy-uzeit )  " seed는 type이 int이기 때문에 CONV I( )를 사용하여 타입 변환
                                           min  = 5
                                           max  = 16 ).

  " 제품 별로 공정이 이루어진다.
  " gt_make : 제조
  " gt_fill : 충진
  " gt_pack : 포장
  LOOP AT gt_make INTO gs_make.

    lv_tabix = sy-tabix.

    " 충진과 포장 데이터를 가지고 온다.
    READ TABLE gt_pro_log INTO gs_fill WITH KEY ponum = gs_make-ponum
                                                pcode = gs_make-pcode
                                                pstep = 'B'.
    READ TABLE gt_pro_log INTO gs_pack WITH KEY ponum = gs_make-ponum
                                                pcode = gs_make-pcode
                                                pstep = 'C'.

    " 제조의 공정진행률이 100 미만이라면
    IF gs_make-pperc LT 100.

      PERFORM set_make USING lv_tabix CHANGING lv_num lo_ran. " 포장의 공정진행률 랜덤으로 상승

    " 제조의 공정진행률이 100이 되었고 충진의 공정진행률이 100 미만이라면
    ELSEIF ( gs_make-pperc EQ 100 ) AND
           ( gs_fill-pperc LT 100 ).

      PERFORM set_fill CHANGING lv_num lo_ran. " 충진의 공정진행률 랜덤으로 상승

    " 충진의 공정진행률이 100이 되었고 포장의 공정진행률이 100 미만이라면
    ELSEIF ( gs_fill-pperc EQ 100 ) AND
           ( gs_pack-pperc LT 100 ).

      PERFORM set_pack CHANGING lv_num lo_ran. " 포장의 공정진행률 랜덤으로 상승

    " 포장의 공정진행률이 100이 되었다면
    ELSEIF gs_pack-pperc EQ 100.

      PERFORM set_after_process.       " 제조, 충진, 포장 ALV에 지운 후 검수요청 버튼 생성
      PERFORM save_product_order_data. " 생산오더 저장

    ENDIF.

    PERFORM save_product_log_data.     " 공정 진행 로그 전체 저장

  ENDLOOP.

  PERFORM save_inv_manage_data. " 재고관리 업데이트 (원자재, 반제품 수량 감소)
  PERFORM refresh_table.        " 각각 공정이 진행되는 것을 보여주기 위해 refresh

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_status_product_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_status_product_order USING ps_row TYPE lvc_s_row.

  " 생산오더 상태
  " ' ' : 공정 대기
  " '2' : 공정 진행 중
  " '3' : 공정 완료
  " '4' : 검수 요청

  IF sy-subrc EQ 0.

    gs_order-status = '2'.
    gs_order-icon   = icon_businav_objects_outdate.

    MODIFY gt_order FROM gs_order INDEX ps_row-index
                                  TRANSPORTING status icon.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_product_log_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_product_log_data .

  PERFORM get_gt_pro_log.

  _get_log: gt_make 'A', " 제형 제조 데이터 설정 (공정 진행 중인것만)
            gt_fill 'B', " 충진      데이터 설정 (공정 진행 중인것만)
            gt_pack 'C'. " 포장      데이터 설정 (공정 진행 중인것만)

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
*& Form refresh_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_table .

  PERFORM refresh_up_table.
  PERFORM refresh_make_table.
  PERFORM refresh_fill_table.
  PERFORM refresh_pack_table.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_fill_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_fill_table .

  DATA: ls_stable TYPE lvc_s_stbl.

  ls_stable-row = abap_true.
  ls_stable-col = abap_true.

  CALL METHOD go_cent_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stable.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_pack_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_pack_table .

  DATA: ls_stable TYPE lvc_s_stbl.

  ls_stable-row = abap_true.
  ls_stable-col = abap_true.

  CALL METHOD go_right_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stable.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_gt_pro_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_gt_pro_log .

  CLEAR gt_pro_log.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_pro_log
    FROM zc302ppt0010.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_btn_style
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_btn_style .

  DATA: ls_style TYPE lvc_s_styl.

  CLEAR ls_style.

  IF gs_order-status EQ '3'.
    ls_style-fieldname = 'QUIN'.
    ls_style-style     = cl_gui_alv_grid=>mc_style_button.
    ls_style-maxlen    = 10.

    INSERT ls_style INTO TABLE gs_order-celltab.
  ENDIF.

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
      gs_order-quin = '검수요청'.
    WHEN '4'.
      gs_order-icon = icon_display_more.
      gs_order-quin = '요청완료'.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_product_order_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_product_order_data .

  DATA: ls_save TYPE zc302ppt0007.

  MOVE-CORRESPONDING gs_order TO ls_save.

  IF ls_save IS INITIAL.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'. " 저장된 데이터가 없습니다.
    EXIT.
  ENDIF.

  "* Set Time Stamp (계획오더 Item)
  IF ls_save-erdat IS INITIAL.
    ls_save-erdat = sy-datum.
    ls_save-ernam = sy-uname.
    ls_save-erzet = sy-uzeit.
  ELSE.
    ls_save-aedat = sy-datum.
    ls_save-aenam = sy-uname.
    ls_save-aezet = sy-uzeit.
  ENDIF.


  " 공정 진행 로그 DB에 저장
  MODIFY zc302ppt0007 FROM ls_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE s001 WITH TEXT-e06 DISPLAY LIKE 'E'. " 저장을 실패하였습니다.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_button_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ES_COL_ID
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM handle_button_click   USING    ps_col_id TYPE lvc_s_col
                                    ps_row_no TYPE lvc_s_roid.

  DATA: lv_answer.

  CLEAR: gs_order, gs_check.
  READ TABLE gt_order INTO gs_order INDEX ps_row_no-row_id.

  " 품질 검수 할지 확인
  PERFORM confirm_for_check CHANGING lv_answer.

  " 취소 버튼을 누르면 나가기
  IF lv_answer NE '1'.
    MESSAGE s001 WITH TEXT-e08 DISPLAY LIKE 'E'. " 품질 검수를 취소하였습니다.
    EXIT.
  ENDIF.

  " 생산오더 상태를 '4'로 만들어 검수상태를 요청완료로 변경
  gs_order = VALUE #( BASE gs_order
                           status = '4'
                           quin   = '요청완료'
                           icon   = icon_display_more ).
  CLEAR gs_order-celltab.
  MODIFY gt_order FROM gs_order INDEX ps_row_no-row_id
                                TRANSPORTING status quin icon celltab.

  " 생산오더 DB 저장
  PERFORM save_product_order_data.

  " 검수정보 생성을 위한 설정
  PERFORM set_inspection_info_data.

  " 검수정보 DB에 저장
  PERFORM save_inspect_info_data.

  " ALV 새로고침
  PERFORM refresh_up_table.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form confirm_for_check
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM confirm_for_check  CHANGING pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = '품질검수 Dialog'
      text_question         = '품질 검수를 요청하시겠습니까?'
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
*& Form save_inspect_info_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_inspect_info_data .

  DATA: ls_save TYPE zc302ppt0011.

  MOVE-CORRESPONDING gs_check TO ls_save.

  IF ls_save IS INITIAL.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'. " 저장된 데이터가 없습니다.
  ENDIF.

  " Set Time Stamp (검수정보)
  IF ls_save-erdat IS INITIAL.
    ls_save-erdat = sy-datum.
    ls_save-ernam = sy-uname.
    ls_save-erzet = sy-uzeit.
  ELSE.
    ls_save-aedat = sy-datum.
    ls_save-aenam = sy-uname.
    ls_save-aezet = sy-uzeit.
  ENDIF.

  " 계획오더 Header DB에 저장
  MODIFY zc302ppt0011 FROM ls_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE s001 WITH TEXT-e06 DISPLAY LIKE 'E'. " 저장을 실패하였습니다.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_batch_job
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_batch_job .

  DATA: lt_tbtcstep TYPE TABLE OF tbtcstep,
        ls_tbtcstep TYPE tbtcstep.

  DATA: lv_jobcount TYPE btcjobcnt,
        lv_jobname  TYPE btcjob.

  lv_jobname = 'SYNCYOUNG_PPP_BATCH'.

  SELECT SINGLE jobcount
    INTO lv_jobcount
    FROM tbtco
   WHERE jobname EQ lv_jobname    " 자신이 만든 배치잡 이름 설정
     AND status  EQ 'P'.

  CALL FUNCTION 'BP_JOB_MODIFY'
    EXPORTING
      dialog              = 'Y'
      jobcount            = lv_jobcount
      jobname             = lv_jobname   " 자신이 만든 배치잡 이름 설정
      opcode              = 17
    TABLES
      new_steplist        = lt_tbtcstep
    EXCEPTIONS
      job_modify_canceled = 15.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_inspection_info_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_inspection_info_data .

  MOVE-CORRESPONDING gs_order TO gs_check.

  CLEAR: gs_check-emp_num, gs_check-erdat, gs_check-ernam,
         gs_check-erzet,   gs_check-aedat, gs_check-aenam,
         gs_check-aezet.

  SELECT SINGLE ppstr
    INTO gs_check-ppstr
    FROM zc302ppt0010
   WHERE ponum EQ gs_check-ponum
     AND pstep EQ 'A'.

  SELECT SINGLE ppend
    INTO gs_check-ppend
    FROM zc302ppt0010
   WHERE ponum EQ gs_check-ponum
     AND pstep EQ 'C'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_p_log_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_p_log_data .

  DATA: lv_tabix TYPE sy-tabix.

  CLEAR gs_pro_log.
  LOOP AT gt_pro_log INTO gs_pro_log.

    lv_tabix = sy-tabix.

    CASE gs_pro_log-pstep.
      WHEN 'A'.
        gs_pro_log-icon = icon_physical_sample.
      WHEN 'B'.
        gs_pro_log-icon = icon_public_files.
      WHEN 'C'.
        gs_pro_log-icon = icon_packing.
    ENDCASE.

    MODIFY gt_pro_log FROM gs_pro_log INDEX lv_tabix
                                      TRANSPORTING icon.

  ENDLOOP.

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

  REFRESH: gr_ponum, gr_matnr.

  IF gv_ponum IS NOT INITIAL.
    gr_ponum-sign   = 'I'.
    gr_ponum-option = 'EQ'.
    gr_ponum-low    = gv_ponum.
    APPEND gr_ponum.
  ENDIF.

  IF gv_matnr IS NOT INITIAL.
    gr_matnr-sign   = 'I'.
    gr_matnr-option = 'EQ'.
    gr_matnr-low    = gv_matnr.
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

  PERFORM get_base_data.    " 생산오더 데이터 조회
  PERFORM make_display_up.  " 생산오더 데이터 설정
  PERFORM refresh_up_table. " ALV 새로고침

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

  CLEAR: gv_ponum, gv_matnr. " 입력 필드 데이터 클리어

  PERFORM get_base_data.     " 생산오더 데이터 조회
  PERFORM make_display_up.   " 생산오더 데이터 설정
  PERFORM refresh_up_table.  " ALV 새로고침

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_make
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_NUM
*&      <-- LO_RAN
*&---------------------------------------------------------------------*
FORM set_make  USING    pv_tabix
               CHANGING pv_num
                        po_ran TYPE REF TO cl_abap_random_int.

  pv_num = po_ran->get_next( ).

  gs_make-pperc = gs_make-pperc + pv_num.

  IF gs_make-pperc GE 100.
    gs_make-pperc = '100'.
    gs_make-ppend = gs_make-ppstr + '7'.
  ENDIF.

  MODIFY gt_make FROM gs_make INDEX pv_tabix
                              TRANSPORTING pperc ppend.

  " gt_pro_log에 백업
  MODIFY gt_pro_log FROM gs_make TRANSPORTING pperc ppend status
                                        WHERE ponum = gs_make-ponum
                                          AND pcode = gs_make-pcode
                                          AND pstep = gs_make-pstep.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fill
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_NUM
*&      <-- LO_RAN
*&---------------------------------------------------------------------*
FORM set_fill  CHANGING pv_num
                        po_ran TYPE REF TO cl_abap_random_int.

  IF gs_fill-status IS INITIAL.
    gs_fill-status = '2'.
    APPEND gs_fill TO gt_fill.
  ENDIF.

  pv_num = po_ran->get_next( ).

  gs_fill-pperc = gs_fill-pperc + pv_num.

  IF gs_fill-pperc GE 100.
    gs_fill-pperc = '100'.
    gs_fill-ppend = gs_fill-ppstr + '7'.
  ENDIF.

  MODIFY gt_fill FROM gs_fill TRANSPORTING pperc ppend
                                     WHERE ponum = gs_fill-ponum
                                       AND pcode = gs_fill-pcode.

  " gt_pro_log에 백업
  MODIFY gt_pro_log FROM gs_fill TRANSPORTING pperc ppend status
                                        WHERE ponum = gs_fill-ponum
                                          AND pcode = gs_fill-pcode
                                          AND pstep = gs_fill-pstep.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_pack
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_NUM
*&      <-- LO_RAN
*&---------------------------------------------------------------------*
FORM set_pack  CHANGING pv_num
                        po_ran TYPE REF TO cl_abap_random_int.

  IF gs_pack-status IS INITIAL.
    gs_pack-status = '2'.
    APPEND gs_pack TO gt_pack.
  ENDIF.

  pv_num = po_ran->get_next( ).

  gs_pack-pperc = gs_pack-pperc + pv_num.

  IF gs_pack-pperc GE 100.
    gs_pack-pperc = '100'.
    gs_pack-ppend = gs_pack-ppstr + '7'.
  ENDIF.

  MODIFY gt_pack FROM gs_pack TRANSPORTING pperc ppend status
                                     WHERE ponum = gs_pack-ponum
                                       AND pcode = gs_pack-pcode.

  " gt_pro_log에 백업
  MODIFY gt_pro_log FROM gs_pack TRANSPORTING pperc ppend status
                                        WHERE ponum = gs_pack-ponum
                                          AND pcode = gs_pack-pcode
                                          AND pstep = gs_pack-pstep.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_after_process
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_after_process .

  DATA: ls_style TYPE lvc_s_styl.

  " 공정이 완료된 생산오더 레코드를 끌고온다.
  READ TABLE gt_order INTO gs_order WITH KEY ponum = gs_pack-ponum.

  " 공정이 완료되었습니다라고 Message 띄우기
  IF sy-subrc EQ 0.
    MESSAGE i001 WITH gs_order-maktx TEXT-e07. " 의 공정이 완료되었습니다.
  ENDIF.

  " 생산오더 상태를 3으로 바꾸고 품질검수 이름 넣고 icon도 바꾼다.
  gs_order-status = '3'.
  gs_order-quin   = '검수요청'.
  gs_order-icon   = icon_businav_objects_uptodate.

  " quin을 버튼으로 바꾼다.
  CLEAR ls_style.
  ls_style-fieldname = 'QUIN'.
  ls_style-style     = cl_gui_alv_grid=>mc_style_button.
  INSERT ls_style INTO TABLE gs_order-celltab.

  MODIFY gt_order FROM gs_order TRANSPORTING status quin icon celltab
                                       WHERE ponum = gs_pack-ponum.

  " 각각 gt_make, gt_fill, gt_pack에 DELETE 후 gt_pro_log에 백업
  DELETE gt_make WHERE ponum = gs_order-ponum.
  DELETE gt_fill WHERE ponum = gs_order-ponum.
  DELETE gt_pack WHERE ponum = gs_order-ponum.

  gs_pack-status = '3'.

  MODIFY gt_pro_log FROM gs_pack TRANSPORTING status
                                        WHERE ponum = gs_pack-ponum.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_porder_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_porder_item .

  " 계획오더번호가 같은 계획오더 Item의 데이터들 가져온다.
  CLEAR gt_porder.
  SELECT *
    APPENDING CORRESPONDING FIELDS OF TABLE gt_porder
    FROM zc302ppt0003
   WHERE plordco EQ gs_order-plordco
     AND matnr   NOT LIKE 'CP%'.

  " 재고관리 ITAB 업데이트
  LOOP AT gt_porder INTO gs_porder.

    READ TABLE gt_invman INTO gs_invman WITH KEY matnr = gs_porder-matnr.

    gs_invman-h_rtptqua = gs_invman-h_rtptqua - gs_porder-pqua.

    MODIFY gt_invman FROM gs_invman TRANSPORTING h_rtptqua
                                           WHERE matnr = gs_porder-matnr.

  ENDLOOP.

  EXPORT
    gt_invman FROM gt_invman
    TO MEMORY ID 'INV'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_inv_management_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_inv_management_data .

  CLEAR gt_invman.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_invman
    FROM zc302mmt0013
   WHERE scode NOT IN ('ST03', 'ST05').

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_inv_manage_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_inv_manage_data .

  DATA: lt_save TYPE TABLE OF zc302mmt0013,
        ls_save TYPE zc302mmt0013,
        lv_tabix TYPE sy-tabix.

  MOVE-CORRESPONDING gt_invman TO lt_save.

  IF lt_save IS INITIAL.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  "* Set Time Stamp (재고관리 item)
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
  MODIFY zc302mmt0013 FROM TABLE lt_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE s001 WITH TEXT-e06 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_ponum_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_ponum_f4 .

  DATA : lt_return TYPE TABLE OF ddshretval WITH HEADER LINE,
         lt_read   TYPE TABLE OF dynpread WITH HEADER LINE. " (선택)

*-- Execute Search Help(F4)
  REFRESH lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'PONUM'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GV_PONUM'
      window_title    = 'Product order code'
      value_org       = 'S'
    TABLES
      value_tab       = gt_ponum
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

*-- Set value to Dynpro
  REFRESH lt_read.
  lt_read-fieldname = 'GV_PONUM'.
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
*& Form get_srch_help_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_srch_help_data .

  CLEAR gt_ponum.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_ponum
    FROM zc302ppt0007.

  CLEAR gt_matnr.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_matnr
    FROM zc302mt0007
   WHERE mtart EQ '03'.

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
