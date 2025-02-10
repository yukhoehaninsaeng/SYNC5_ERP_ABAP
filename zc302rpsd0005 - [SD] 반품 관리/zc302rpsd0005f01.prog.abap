*&---------------------------------------------------------------------*
*& Include          ZC302RPSD0005F01
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

*-- 반품 헤더 데이터 SELECT
  CLEAR gt_refund.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_refund
    FROM zc302sdt0007
   WHERE rfnum IN so_rfnum
     AND sonum IN so_sonum
   ORDER BY rfnum.


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

  DATA : ls_variant TYPE disvariant.

  IF go_container IS NOT BOUND.

    " MAIN ALV 필드카탈로그
    CLEAR : gs_fcat, gt_fcat.
    PERFORM set_field_catalog USING  : 'X' 'RFNUM'    'ZC302SDT0007' 'C',
                                       ' ' 'SONUM'    'ZC302SDT0007' ' ',
                                       ' ' 'REMARK'   'ZC302SDT0007' ' ',
                                       ' ' 'RFDAT'    'ZC302SDT0007' ' ',
                                       ' ' 'RTDAT'    'ZC302SDT0007' ' ',
                                       ' ' 'RCDAT'    'ZC302SDT0007' ' ',
                                       ' ' 'EMP_NUM'  'ZC302SDT0007' ' ',
                                       ' ' 'EXAM_BTN' 'ZC302SDT0007' 'C'.

    " MAIN ALV 레이아웃
    PERFORM set_layout.

    " MAIN ALV, Container, Top-of-page 객체 생성
    PERFORM create_object.

    " MAIN ALV에 적용할 이벤트 설치
    SET HANDLER : lcl_event_handler=>button_click FOR go_alv_grid,
                  lcl_event_handler=>top_of_page  FOR go_alv_grid.

    ls_variant-report = sy-repid.

    CALL METHOD go_dyndoc_id->initialize_document
      EXPORTING
        background_color = cl_dd_area=>col_textarea.

    CALL METHOD go_alv_grid->list_processing_events
      EXPORTING
        i_event_name = 'TOP_OF_PAGE'
        i_dyndoc_id  = go_dyndoc_id.

    CALL METHOD go_alv_grid->set_table_for_first_display
      EXPORTING
        is_variant                    = ls_variant
        i_save                        = 'A'
        i_default                     = 'X'
        is_layout                     = gs_layout
      CHANGING
        it_outtab                     = gt_refund
        it_fieldcatalog               = gt_fcat
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.


  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_field_catalog  USING pv_key pv_field pv_table pv_just.

  CLEAR gs_fcat.
  gs_fcat-key        = pv_key.
  gs_fcat-fieldname  = pv_field.
  gs_fcat-ref_table  = pv_table.
  gs_fcat-just       = pv_just.

  CASE pv_field.
    WHEN 'REMARK'.
      gs_fcat-coltext  = '반품사유'.
    WHEN 'EMP_NUM'.
      gs_fcat-coltext  = '검수자'.
    WHEN 'EXAM_BTN'.
      gs_fcat-coltext = '검수상태'.
  ENDCASE.

  APPEND gs_fcat TO gt_fcat.
  CLEAR gs_fcat.

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

  gs_layout-zebra      = abap_true.    " 얼룩처리
  gs_layout-cwidth_opt = 'A'.          " 열넓이 최적화
  gs_layout-sel_mode   = 'D'.          " 선택모드 => 셀 단위
  gs_layout-stylefname = 'celltab'.    " 편집적용

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

*-- TOP-OF-PAGE 객체 생성
  CREATE OBJECT go_top_container
    EXPORTING
      repid     = sy-cprog
      dynnr     = sy-dynnr
      side      = go_top_container->dock_at_top
      extension = 40.

*-- Container 객체 생성
  CREATE OBJECT go_container
    EXPORTING
      side      = go_container->dock_at_left
      extension = 5000.

*-- ALV 객체 생성
  CREATE OBJECT go_alv_grid
    EXPORTING
      i_parent = go_container.

  CREATE OBJECT go_dyndoc_id
    EXPORTING
      style = 'ALV_GRID'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_display_body
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_body .

  DATA : ls_style TYPE lvc_s_styl,
         lv_cnt   TYPE i.

  LOOP AT gt_refund INTO gs_refund.

    IF gs_refund-rcdat IS INITIAL.
      CLEAR : ls_style.
      ls_style-fieldname = 'EXAM_BTN'.
      ls_style-style =  cl_gui_alv_grid=>mc_style_button.
      INSERT ls_style INTO TABLE gs_refund-celltab.
      gs_refund-exam_btn = '검수대기'.
    ELSE.
      gs_refund-exam_btn = '검수완료'.
    ENDIF.

    MODIFY gt_refund FROM gs_refund TRANSPORTING exam_btn celltab.

  ENDLOOP.

*-- 몇 건의 데이터가 조회되었는지 MESSAGE 뿌리기
  lv_cnt = lines( gt_refund ).

  IF gt_refund IS NOT INITIAL.
    " 건이 조회되었습니다.
    MESSAGE s001 WITH lv_cnt TEXT-i03.
  ELSE.
    " No data found
    MESSAGE s037 DISPLAY LIKE 'E'.
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
FORM handle_button_click  USING ps_col_id TYPE lvc_s_col
                                ps_row_no TYPE lvc_s_roid.

  DATA : lv_tabix TYPE sy-tabix,
         ls_style TYPE lvc_s_styl.


*-- 반품 HEADER ITAB에서 선택한 행 읽어오기
  CLEAR gs_refund.
  READ TABLE gt_refund INTO gs_refund INDEX ps_row_no-row_id.

  IF sy-subrc = 0.
*-- 반품 HEADER의 주문번호 담아오기
    gv_sonum = gs_refund-sonum.
*-- 반품 HEADER의 반품번호 담아오기
    gv_rfnum = gs_refund-rfnum.
  ENDIF.


*-- 반품 ITEM 데이터 SELECT
  CLEAR gt_irefund.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_irefund
    FROM zc302sdt0008
   WHERE rfnum = gv_rfnum.


*- 반품 ITEM ITAB에 ICON과 CELLTAB 속성 적용
  CLEAR gs_irefund.
  LOOP AT gt_irefund INTO gs_irefund.

    lv_tabix = sy-tabix.

*-- ICON
    CASE gs_irefund-chkrs.
      WHEN 'A'.
        gs_irefund-icon = icon_led_green.
      WHEN 'B'.
        gs_irefund-icon = icon_led_red.
      WHEN OTHERS.
        gs_irefund-icon = icon_space.
    ENDCASE.

*-- CELLTAB - 검수결과 편집 가능 (이미 검수가 완료된 건에 대해서는 수정X)
    IF gs_irefund-chkrs IS INITIAL.
      CLEAR : ls_style.
      ls_style-fieldname = 'CHKRS'.
      ls_style-style = cl_gui_alv_grid=>mc_style_enabled.
      INSERT ls_style INTO TABLE gs_irefund-celltab.
    ENDIF.

    MODIFY gt_irefund FROM gs_irefund INDEX lv_tabix
                                      TRANSPORTING icon celltab.


  ENDLOOP.

*-- 반품 ITEM ALV 띄우기 - CALL POPUP SCREEN
  CALL SCREEN 101 STARTING AT 03 05.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_popup
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_popup .

  DATA : ls_variant  TYPE disvariant.

  IF go_pop_cont IS NOT BOUND.

    " 팝업 ALV 필드카탈로그
    CLEAR : gs_pfcat, gt_pfcat.
    PERFORM set_pop_field_catalog USING : 'X' 'ICON'   ' '            'C',
                                          'X' 'RFNUM'  'ZC302SDT0008' 'C',
                                          'X' 'POSNR'  'ZC302SDT0008' 'C',
                                          ' ' 'MATNR'  'ZC302SDT0008' 'C',
                                          ' ' 'MENGE'  'ZC302SDT0008' ' ',
                                          ' ' 'MEINS'  'ZC302SDT0008' ' ',
                                          ' ' 'CHKRS'  'ZC302SDT0008' 'C'.

    " 팝업 ALV 레이아웃
    PERFORM set_pop_layout.
    " 팝업 ALV과 Container 객체 생성
    PERFORM create_pop_object.

    " 불필요한 TOOLBAR 버튼 제거
    PERFORM exclude_button TABLES gt_ui_functions.

    " 팝업 ALV에 적용할 이벤트 설치
    SET HANDLER : lcl_event_handler=>toolbar       FOR go_pop_grid,
                  lcl_event_handler=>user_command  FOR go_pop_grid,
                  lcl_event_handler=>data_change   FOR go_pop_grid.

    ls_variant-report = sy-repid.

    CALL METHOD go_pop_grid->set_table_for_first_display
      EXPORTING
        is_variant                    = ls_variant
        i_save                        = 'A'
        i_default                     = 'X'
        is_layout                     = gs_playout
        it_toolbar_excluding          = gt_ui_functions
      CHANGING
        it_outtab                     = gt_irefund
        it_fieldcatalog               = gt_pfcat
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.

    PERFORM register_event.

  ELSE.
    CALL METHOD go_pop_grid->refresh_table_display.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_pop_field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_pop_field_catalog  USING pv_key pv_field pv_table pv_just.

  CLEAR gs_pfcat.
  gs_pfcat-key        = pv_key.
  gs_pfcat-fieldname  = pv_field.
  gs_pfcat-ref_table  = pv_table.
  gs_pfcat-just       = pv_just.

  CASE pv_field.
    WHEN 'MENGE'.
      gs_pfcat-qfieldname = 'MEINS'.
      gs_pfcat-coltext = '수량'.
    WHEN 'MEINS'.
      gs_pfcat-coltext = '단위'.
    WHEN 'ICON'.
      gs_pfcat-coltext = '상태'.
  ENDCASE.

  APPEND gs_pfcat TO gt_pfcat.
  CLEAR gs_pfcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_pop_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_pop_layout .

  gs_playout-zebra      = abap_true.   " 얼룩처리
  gs_playout-cwidth_opt = 'A'.         " 열넓이 최적화
  gs_playout-sel_mode   = 'D'.         " 선택모드 => 셀 단위
  gs_playout-stylefname = 'CELLTAB'.   " 편집적용

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_pop_object
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_pop_object .

*-- Container 객체 생성
  CREATE OBJECT go_pop_cont
    EXPORTING
      container_name = 'POP_CONT'.

*-- ALV 객체 생성
  CREATE OBJECT go_pop_grid
    EXPORTING
      i_parent = go_pop_cont.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form register_event
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM register_event .

  CALL METHOD go_pop_grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 1.

  CALL METHOD go_pop_grid->register_edit_event
    EXPORTING
      i_event_id = go_pop_grid->mc_evt_modified.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_button
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_UI_FUNCTIONS
*&---------------------------------------------------------------------*
FORM exclude_button  TABLES   pt_ui_functions TYPE ui_functions.

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
*& Form event_top_of_page
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM event_top_of_page .

  DATA : lr_dd_table TYPE REF TO cl_dd_table_element, " 테이블
         col_field   TYPE REF TO cl_dd_area,          " 필드
         col_value   TYPE REF TO cl_dd_area.          " 값

  DATA : lv_text TYPE sdydo_text_element.

  DATA : lv_temp TYPE string.

*-------------------------------------------------------------------
* Top of Page의 레이아웃 세팅
*-------------------------------------------------------------------
*-- Create Table
  CALL METHOD go_dyndoc_id->add_table
    EXPORTING
      no_of_columns = 2
      border        = '0'
    IMPORTING
      table         = lr_dd_table.

*-- Set column(Add Column to Table)
  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_field.

  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_value.

*-------------------------------------------------------------------
* Top of Page 레이아웃에 맞춰 값 세팅
*-------------------------------------------------------------------
*-- 반품번호 & 판매주문번호

  so_rfnum = VALUE #( so_rfnum[ 1 ] OPTIONAL ).
  CLEAR : lv_temp.
  IF so_rfnum-low IS NOT INITIAL.
    lv_temp = so_rfnum-low.
    IF so_rfnum-high IS NOT INITIAL.
      CONCATENATE lv_temp ' ~ ' so_rfnum-high INTO lv_temp.
    ENDIF.
  ELSE.
    lv_temp = '전체'.
  ENDIF.
  PERFORM add_row USING lr_dd_table col_field col_value '반품번호' lv_temp.

  so_sonum = VALUE #( so_sonum[ 1 ] OPTIONAL ).
  CLEAR : lv_temp.
  IF so_sonum-low IS NOT INITIAL.
    lv_temp = so_sonum-low.
    IF so_sonum-high IS NOT INITIAL.
      CONCATENATE lv_temp ' ~ ' so_sonum-high INTO lv_temp.
    ENDIF.
  ELSE.
    lv_temp = '전체'.
  ENDIF.
  PERFORM add_row USING lr_dd_table col_field col_value '판매주문번호' lv_temp.

  PERFORM set_top_of_page.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_row
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LR_DD_TABLE
*&      --> COL_FIELD
*&      --> COL_VALUE
*&      --> P_
*&      --> P_SORG
*&---------------------------------------------------------------------*
*-- 테이블 / Column / Value / 컬럼에 입력할 값 / 값에 입력할 값
FORM add_row  USING pr_dd_table  TYPE REF TO cl_dd_table_element
                    pv_col_field TYPE REF TO cl_dd_area
                    pv_col_value TYPE REF TO cl_dd_area
                    pv_field
                    pv_text.

  DATA : lv_text TYPE sdydo_text_element.

*-- Field에 값  세팅
  lv_text = pv_field.

  CALL METHOD pv_col_field->add_text
    EXPORTING
      text         = lv_text
      sap_emphasis = cl_dd_document=>strong
      sap_color    = cl_dd_document=>list_heading_inv.

  CALL METHOD pv_col_field->add_gap
    EXPORTING
      width = 3.

*-- Value에 값 세팅
  lv_text = pv_text.

  CALL METHOD pv_col_value->add_text
    EXPORTING
      text         = lv_text
      sap_emphasis = cl_dd_document=>heading
      sap_color    = cl_dd_document=>list_negative_inv.

  CALL METHOD pv_col_value->add_gap
    EXPORTING
      width = 3.

  CALL METHOD pr_dd_table->new_row.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_top_of_page
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_top_of_page .

* Creating html control object
  IF go_html_cntrl IS INITIAL.
    CREATE OBJECT go_html_cntrl
      EXPORTING
        parent = go_top_container.
  ENDIF.

* Merge HTML Document : Top of Page의 내용을 HTML로 랜더링
  CALL METHOD go_dyndoc_id->merge_document.
  go_dyndoc_id->html_control = go_html_cntrl.

* Display document
  CALL METHOD go_dyndoc_id->display_document
    EXPORTING
      reuse_control      = 'X'
      parent             = go_top_container
    EXCEPTIONS
      html_display_error = 1.

  IF sy-subrc NE 0.
    MESSAGE s001(k5) WITH 'Top of page event error' DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM handle_toolbar  USING   po_object TYPE REF TO cl_alv_event_toolbar_set
                             pv_interactive.

*-- Set ALV Toolbar
  PERFORM set_toolbar USING : 'SAVE' icon_system_save ' ' ' ' '저장' po_object.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> ICON_SYSTEM_SAVE
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> PO_OBJECT
*&---------------------------------------------------------------------*
FORM set_toolbar  USING   pv_func pv_icon pv_qinfo pv_type pv_text
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
FORM handle_user_command  USING pv_ucomm.

  CASE pv_ucomm.
    WHEN 'SAVE'.
      PERFORM save_refund_item.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_refund_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_refund_item .

*-- 반품 Item 저장용 ITAB을 선언
  DATA : lt_save   TYPE TABLE OF zc302sdt0008,
         ls_save   TYPE zc302sdt0008,
         lv_tabix  TYPE sy-tabix,
         lv_answer,
         lv_result.

*-- ALV의 변경사항을 ITAB에 반영한다.
  CALL METHOD go_pop_grid->check_changed_data.

*-- MOVE DATA
  MOVE-CORRESPONDING gt_irefund TO lt_save.

  IF ( lt_save IS INITIAL ).
    " 저장할 데이터가 없습니다.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 확인 팝업창
  PERFORM confirm CHANGING lv_answer.

*-- 받아온 lv_answer이 1(yes)가 아닐 때 아래 로직 수행X
  IF lv_answer NE '1'.
    MESSAGE w101.
    EXIT.
  ENDIF.

*-- TIMESTAMP 정보 세팅
  LOOP AT lt_save INTO ls_save.
    " 검수결과를 반영했을 경우, 수정정보 세팅
    CHECK ls_save-chkrs  IS NOT INITIAL.

    lv_tabix = sy-tabix.

    ls_save-aedat = sy-datum.
    ls_save-aenam = sy-uname.
    ls_save-aezet = sy-uzeit.

    MODIFY lt_save FROM ls_save INDEX lv_tabix
                                TRANSPORTING aedat aenam aezet.

  ENDLOOP.

*-- 반품 ITEM 데이터 저장
  MODIFY zc302sdt0008 FROM TABLE lt_save.

*-- 성공시 아래 로직 수행
  IF sy-subrc EQ 0.
    " 저장 이후 데이터 처리(자재문서,재고관리,폐기관리,입출금내역 등)
    PERFORM save_after_process CHANGING lv_result.
    " 데이터 처리 결과 성공 시 COMMIT 작업
    IF lv_result IS INITIAL.
      COMMIT WORK AND WAIT.
      " 저장을 성공하였습니다.
      MESSAGE i001 WITH TEXT-i02.
    ELSE.
      ROLLBACK WORK.
      " 데이터 처리에 실패하였습니다.
      MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
    ENDIF.
  ELSE.
    ROLLBACK WORK.
    " 저장을 실패하였습니다.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.
  ENDIF.

*-- 팝업 스크린에서 빠져나오기
  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form confirm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM confirm  CHANGING pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = '반품 검수결과 반영'
      text_question         = '반품 검수결과를 반영하시겠습니까?'
      text_button_1         = 'Yes'(001)
      icon_button_1         = 'ICON_OKAY'
      text_button_2         = 'No'(002)
      icon_button_2         = 'ICON_CANCEL'
      default_button        = '1'
      display_cancel_button = 'X'
    IMPORTING
      answer                = pv_answer.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_after_process
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_RESULT
*&---------------------------------------------------------------------*
FORM save_after_process  CHANGING pv_result.

  DATA: lv_all_checked TYPE abap_bool VALUE abap_true.

  DATA: lv_any_good TYPE abap_bool VALUE abap_false.

  DATA : lt_row TYPE lvc_t_row,
         ls_row TYPE lvc_s_row.

  DATA : lv_bpcode TYPE zc302sdt0003-bpcode.

**********************************************************************
* 필요한 데이터 SELECT
**********************************************************************
*-- 재고관리H 데이터 SELECT
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_stock
    FROM zc302mmt0013
   WHERE scode = 'ST05'.


*-- 재고관리I 데이터 SELECT
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_istock
    FROM zc302mmt0002
   WHERE scode = 'ST05'.

  SORT gt_istock BY matnr bdatu ASCENDING.

*-- 자재마스터 데이터(자재명) SELECT
  SELECT matnr maktx
    INTO CORRESPONDING FIELDS OF TABLE gt_maktx
    FROM zc302mt0007.


*-- 반품 ITEM 과 같은 rfnum 인 반품 Header의 sonum 읽어오기
  LOOP AT gt_irefund INTO gs_irefund.

    READ TABLE gt_refund INTO gs_refund WITH KEY rfnum = gs_irefund-rfnum.

    IF sy-subrc EQ 0.
      DATA(lv_sonum) = gs_refund-sonum.
    ENDIF.

  ENDLOOP.

*-- 판매오더 ITEM 데이터 SELECT
  SELECT sonum matnr waers netwr
    INTO CORRESPONDING FIELDS OF TABLE gt_zc302sdt0004
    FROM zc302sdt0004
   WHERE sonum = lv_sonum.


*-- BPCODE 데이터 SELECT
  SELECT SINGLE cust_num
    INTO gv_bpcode
   FROM zc302sdt0003
  WHERE sonum = lv_sonum.


**********************************************************************
* 모든 반품 Item의 검수결과가 끝난 경우 ITAB 구성
**********************************************************************
  LOOP AT gt_irefund INTO gs_irefund.

    IF gs_irefund-chkrs IS INITIAL.
      MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'.
      lv_all_checked = abap_false.
      EXIT.
    ENDIF.

  ENDLOOP.

  IF lv_all_checked = abap_true.


*-- 정상(A)인 Item이 최소한 1개 이상이면 자재문서 Header 발생
    LOOP AT gt_irefund INTO gs_irefund.
      IF gs_irefund-chkrs = 'A'.
        lv_any_good = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_any_good = abap_true.
      " MM 자재문서 Header 생성 (구분: 입고)
      PERFORM create_mdocument.
    ENDIF.

*-- 검수결과에 따라 로직 구현
    LOOP AT gt_irefund INTO gs_irefund.
      CASE gs_irefund-chkrs.
        WHEN 'A'.  " 검수결과가 정상일때
          " MM 자재문서 Item 생성 (구분: 입고)
          PERFORM create_item_mdocument.
          " MM 재고관리 Header, Item 수량 업데이트(증가)
          PERFORM update_amount.
        WHEN 'B'.  " 검수결과가 불량일때
          " MM 폐기관리 생성
          PERFORM create_discard.
      ENDCASE.
    ENDLOOP.

*-- FI 입출금내역 생성 (구분: 출금)
    PERFORM create_withdraw.

*-- 반품 Header(반품처리일자, 검수자) 업데이트
    PERFORM update_refund_header.

**********************************************************************
* DB 반영
**********************************************************************
*-- 반품 Header DB 업데이트
    MODIFY zc302sdt0007 FROM TABLE gt_zc302sdt0007.


*-- 자재문서DB(H,I) 생성
    MODIFY zc302mmt0011 FROM TABLE gt_mdocu.
    MODIFY zc302mmt0012 FROM TABLE gt_Imdocu.

*-- 재고관리DB(H,I) 업데이트
    MODIFY zc302mmt0013 FROM TABLE gt_stock_upt.
    MODIFY zc302mmt0002 FROM TABLE gt_istock_upt.


*-- 입출금내역 DB 생성
    MODIFY zc302fit0006 FROM gs_withdraw.


*-- 폐기 DB 생성
    MODIFY zc302mmt0001 FROM TABLE gt_discard.

  ENDIF.

*-- 위에 로직 수행 결과
  IF sy-subrc EQ 0.
  ELSE.
    pv_result = abap_true.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_data_change
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM handle_data_change  USING  pv_modified
                                pt_good_cells TYPE lvc_t_modi.

  DATA: ls_good_cells TYPE lvc_s_modi,
        ls_style      TYPE lvc_s_styl.

  " 값이 있는지 체크
  CHECK pv_modified IS NOT INITIAL.

  " 변경된 셀 정보 읽기
  CLEAR ls_good_cells.
  READ TABLE pt_good_cells INTO ls_good_cells INDEX 1. " 첫 번째 변경 정보 읽기

  " gt_irefund에서 해당 행 찾기
  CLEAR gs_irefund.
  READ TABLE gt_irefund INTO gs_irefund INDEX ls_good_cells-row_id.

  IF sy-subrc = 0.

    " 변경된 체크리스트 값에 따라 스타일 설정
    CLEAR : ls_style.

    CASE gs_irefund-chkrs.
      WHEN 'A'.
        gs_irefund-icon = icon_led_green.
      WHEN 'B'.
        gs_irefund-icon = icon_led_red.
      WHEN OTHERS.
        gs_irefund-icon = icon_space.
    ENDCASE.

    " 변경된 내용 다시 테이블에 저장
    MODIFY gt_irefund FROM gs_irefund INDEX ls_good_cells-row_id.

    " ALV 새로 고침
    CALL METHOD go_pop_grid->refresh_table_display.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_mdocument
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_NUMBER
*&---------------------------------------------------------------------*
FORM create_mdocument.

  DATA : lv_number(8) TYPE n.

*-- 자재문서번호 채번
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZC321MMMD'
    IMPORTING
      number      = lv_number.

  CLEAR gs_mdocu.
  gs_mdocu-mblnr = 'MD' && lv_number.  " 자재문서번호
  gs_mdocu-mjahr = sy-datum.           " 자재문서연도
  gs_mdocu-movetype = 'A'.             " 자재이동유형(입고)
  gs_mdocu-rfnum = gs_irefund-rfnum.   " 반품번호

*-- TIMESTAMP 세팅
  gs_mdocu-erdat = sy-datum.
  gs_mdocu-ernam = sy-uname.
  gs_mdocu-erzet = sy-uzeit.

*-- 위에서 구성한 gs_mdocu를 gt_mdocu에 추가
  APPEND gs_mdocu TO gt_mdocu.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_item_mdocument
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_NUMBER
*&      --> GS_IREFUND
*&---------------------------------------------------------------------*
FORM create_item_mdocument.

  gs_imdocu-mblnr    = gs_mdocu-mblnr.            " 자재문서번호
  gs_imdocu-mjahr    = gs_mdocu-mjahr.            " 자재문서연도
  gs_imdocu-matnr    = gs_irefund-matnr.          " 자재코드
  gs_imdocu-scode    = 'ST05'.                    " 창고코드
  gs_imdocu-movetype = gs_mdocu-movetype.         " 자재이동유형
  gs_imdocu-budat    = sy-datum.                  " 입고날짜
  gs_imdocu-menge    = gs_irefund-menge.          " 주문수량
  gs_imdocu-meins    = gs_irefund-meins.          " 단위

*-- 판매오더 데이터 읽어와서 담기
  READ TABLE gt_zc302sdt0004 INTO gs_zc302sdt0004 WITH KEY matnr = gs_irefund-matnr.

  IF sy-subrc EQ 0.
    gs_imdocu-waers    = gs_zc302sdt0004-waers.    " 주문금액
    gs_imdocu-netwr    = gs_zc302sdt0004-netwr.    " 통화
    gs_imdocu-bpcode   = gs_zc302sdt0004-bpcode.   " BP코드
  ENDIF.

*-- 자재코드 데이터 읽어와서 담기
  CLEAR gs_maktx.
  READ TABLE gt_maktx INTO gs_maktx WITH KEY matnr = gs_irefund-matnr.

  IF sy-subrc EQ 0.
    gs_imdocu-maktx = gs_maktx-maktx.         " 자재명
  ENDIF.

*-- 판매주문번호와 매칭되는 BP코드 담기
  gs_imdocu-bpcode = gv_bpcode.

*-- TIMESTAMP 세팅
  gs_imdocu-erdat = sy-datum.
  gs_imdocu-ernam = sy-uname.
  gs_imdocu-erzet = sy-uzeit.

*-- 위에서 구성한 gs_imdocu를 gt_imdocu에 추가
  APPEND gs_imdocu TO gt_imdocu.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_amount
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_STOCK
*&---------------------------------------------------------------------*
FORM update_amount.
**********************************************************************
* 재고관리 HEADER 재고 수량 업데이트 (증가)
**********************************************************************
*-- 재고관리 HEADER 데이터 읽어와서 담기
  CLEAR gs_stock.
  READ TABLE gt_stock INTO gs_stock WITH KEY matnr = gs_irefund-matnr.

  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING gs_stock TO gs_stock_upt.
    " 재고 수량 업데이트 (현재재고 + 주문수량)
    gs_stock_upt-h_rtptqua = gs_stock-h_rtptqua + gs_irefund-menge.
    gs_stock_upt-meins = 'EA'.

    " 수정 정보 업데이트
    gs_stock_upt-aedat = sy-datum.
    gs_stock_upt-aenam = sy-uname.
    gs_stock_upt-aezet = sy-uzeit.

*-- 위에서 구성한 gs_stock_upt를 gt_stock_upt에 추가
    APPEND  gs_stock_upt TO gt_stock_upt.

  ENDIF.


**********************************************************************
* 재고관리 ITEM 재고(자재별 가장 오래된 생산일에 해당) 수량 업데이트 (증가)
**********************************************************************
*-- 재고관리 ITEM 데이터 읽어와서 담기
  READ TABLE gt_istock INTO gs_istock WITH KEY matnr = gs_irefund-matnr
                                      BINARY SEARCH.

  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING gs_istock TO gs_istock_upt.
    " 재고 수량 업데이트 (현재재고 + 주문수량)
    gs_istock_upt-i_rtptqua = gs_istock-i_rtptqua + gs_irefund-menge.
    gs_istock_upt-meins = 'EA'.

    " 수정 정보 업데이트
    gs_istock_upt-aedat = sy-datum.
    gs_istock_upt-aenam = sy-uname.
    gs_istock_upt-aezet = sy-uzeit.

*-- 위에서 구성한 gs_istock_upt를 gt_istock_upt에 추가
    APPEND  gs_istock_upt TO gt_istock_upt.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_withdraw
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_WITHDRAW
*&---------------------------------------------------------------------*
FORM create_withdraw.

  DATA : lv_number(9) TYPE n.

*-- 입출금 내역T 데이터를 구성하기 위해 필요한 ITAB 레이아웃
  DATA : BEGIN OF ls_orderinfo,
           sonum     TYPE zc302sdt0003-sonum,
           cust_num  TYPE zc302mt0002-cust_num,
           cust_name TYPE zc302mt0002-cust_name,
           banka     TYPE zc302mt0002-banka,
           bankn     TYPE zc302mt0002-bankn,
           netwr     TYPE zc302sdt0003-netwr,
           waers     TYPE zc302sdt0003-waers,
         END OF ls_orderinfo,
         lt_orderinfo LIKE TABLE OF ls_orderinfo.

*-- 판매오더H와 회원마스터 데이터 SELECT
  SELECT SINGLE a~sonum b~cust_num b~cust_name
         b~banka b~bankn a~netwr a~waers
    INTO CORRESPONDING FIELDS OF ls_orderinfo
    FROM zc302sdt0003 AS a INNER JOIN zc302mt0002 AS b
                                   ON a~cust_num = b~cust_num
   WHERE a~sonum = gv_sonum.


*-- 입출금내역번호 채번
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZNRC302243'
    IMPORTING
      number      = lv_number.

  CLEAR gs_withdraw.
  gs_withdraw-wdnum = 'W' && lv_number.              " 입출금내역번호
  gs_withdraw-sfnum = gv_rfnum.                      " 참조문서번호 - 반품번호
  gs_withdraw-cust_num = ls_orderinfo-cust_num.      " 회원코드
  gs_withdraw-cust_name = ls_orderinfo-cust_name.    " 회원명
  gs_withdraw-banka = ls_orderinfo-banka.            " 은행명
  gs_withdraw-bankn = ls_orderinfo-bankn.            " 은행계좌
  gs_withdraw-price = ls_orderinfo-netwr.            " 주문금액
  gs_withdraw-waers = ls_orderinfo-waers.            " 통화
  gs_withdraw-dw_flag = 'W'.                         " 입출금 구분 - W:출금
  gs_withdraw-dwdate = sy-datum.                     " 입금 일자
  gs_withdraw-erdat = sy-datum.
  gs_withdraw-ernam = sy-uname.
  gs_withdraw-erzet = sy-uzeit.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_refund_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_REFUND
*&---------------------------------------------------------------------*
FORM update_refund_header.

  LOOP AT gt_refund INTO gs_refund WHERE rfnum = gs_irefund-rfnum.

    gs_refund-emp_num = sy-uname.   " 검수자
    gs_refund-rcdat = sy-datum.     " 반품처리일자

    gs_refund-aedat = sy-datum.
    gs_refund-aenam = sy-uname.
    gs_refund-aezet = sy-uzeit.

    MOVE-CORRESPONDING gs_refund TO gs_zc302sdt0007.

    APPEND gs_zc302sdt0007 TO gt_zc302sdt0007.

*-- 검수완료 표시
    CLEAR: gs_refund-exam_btn, gs_refund-celltab.
    gs_refund-exam_btn = '검수완료'.

    MODIFY gt_refund FROM gs_refund.

  ENDLOOP.

*-- ALV도 바로 갱신
  CALL METHOD go_alv_grid->refresh_table_display.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_discard
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_discard.

  DATA : lv_number(4),          " 폐기번호
         lv_year(2),            " 현재년도
         lv_month(2),           " 현재월
         lv_day(2).             " 현재일

*-- 현재날짜 담기
  lv_year  = sy-datum+2(2).
  lv_month = sy-datum+4(2).
  lv_day   = sy-datum+6(2).

*-- 자재코드에 매칭되는 자재명 읽어오기
  CLEAR gs_maktx.
  READ TABLE gt_maktx INTO gs_maktx WITH KEY matnr = gs_irefund-matnr.

  IF sy-subrc EQ 0.
    gs_discard-maktx = gs_maktx-maktx.
  ENDIF.

*-- 폐기번호 체번
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '02'
      object      = 'ZC302MMDN'
    IMPORTING
      number      = lv_number.

  gs_discard-disnum    = 'DN' && lv_year && lv_month && lv_day && lv_number.   " 대금청구번호
  gs_discard-scode     = 'ST05'.                                               " 창고코드
  gs_discard-matnr     = gs_irefund-matnr.                                     " 자재코드
  gs_discard-disreason = '반품-불량'.                                          " 폐기사유
  gs_discard-dismenge  = gs_irefund-menge.                                     " 폐기량
  gs_discard-meins     = gs_irefund-meins.                                     " 단위
  gs_discard-budat     = sy-datum.                                             " 날짜
  gs_discard-emp_num   = sy-uname.                                             " 사원번호
  gs_discard-status    = 'B'.                                                  " 폐기 처리 상태 : B(대기)
  gs_discard-discost   = gs_irefund-menge * 1.                                 " 폐기비용 : 1건당 100원
  gs_discard-waers     = 'KRW'.                                                " 통화
  gs_discard-bpcode    = gv_bpcode.                                            " BP코드

  gs_discard-erdat     = sy-datum.
  gs_discard-ernam     = sy-uname.
  gs_discard-erzet     = sy-uzeit.

*-- 위에서 구성한 WA를 ITAB에 추가(APPEND)
  APPEND gs_discard TO gt_discard.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_value .

*-- 서치헬프에 담길 반품번호 SELECT
  CLEAR gt_rfnum.
  SELECT rfnum
    INTO CORRESPONDING FIELDS OF TABLE gt_rfnum
    FROM zc302sdt0007
   ORDER BY rfnum.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_rfnum
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_rfnum .

  DATA : lt_return LIKE TABLE OF ddshretval WITH HEADER LINE.

  REFRESH : lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'RFNUM'            " Input에 넣어줄 필드
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'SO_RFNUM-LOW'     " Selection Screen Element
      window_title    = '반품번호'         " Description
      value_org       = 'S'
    TABLES
      value_tab       = gt_rfnum           " F4에 뿌려줄 데이터
      return_tab      = lt_return          " F4에서 선택된 값에 대한 정보
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

*-- 반품번호와 매칭되는 판매주문번호만 SELECT
  READ TABLE lt_return INDEX 1.

  SELECT *
    FROM zc302sdt0007
    INTO CORRESPONDING FIELDS OF TABLE gt_sonum
   WHERE rfnum = lt_return-fieldval.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_sonum
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_sonum .

  DATA : lt_return LIKE TABLE OF ddshretval WITH HEADER LINE.

  REFRESH : lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'SONUM'          " Input에 넣어줄 필드
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'SO_SONUM-LOW'   " Selection Screen Element
      window_title    = '판매주문번호'   " Description
      value_org       = 'S'
    TABLES
      value_tab       = gt_sonum         " F4에 뿌려줄 데이터
      return_tab      = lt_return        " F4에서 선택된 값에 대한 정보
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF lt_return IS INITIAL.
    MESSAGE s001 WITH TEXT-e06 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
