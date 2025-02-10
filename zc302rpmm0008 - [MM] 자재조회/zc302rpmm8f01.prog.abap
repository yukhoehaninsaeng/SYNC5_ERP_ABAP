*&---------------------------------------------------------------------*
*& Include          ZC302RPMM8F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form init_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_value .

  CLEAR so_mat.
  so_mat-sign = 'I'.
  so_mat-option = 'EQ'.
  so_mat-low = ''.

  APPEND so_mat.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_base_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_base_data .

  CLEAR gt_body.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_body
    FROM zc302mmt0013 AS a INNER JOIN zc302mt0007 AS b
      ON a~matnr EQ b~matnr
   WHERE a~matnr  IN so_mat
     AND b~bpcode IN so_bpc
     AND scode  IN so_sco
     AND a~mtart  IN so_mta
   ORDER BY a~matnr ASCENDING.

  IF gt_body IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
    STOP.
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
  DATA : lv_variant TYPE disvariant.

  IF go_dock_cont IS NOT BOUND.

    PERFORM set_field_catalog USING : 'X' 'BPCODE'    'ZC302MT0007'  'C' ' ',
                                      'X' 'MATNR'     'ZC302MMT0013' 'C' ' ',
                                      ' ' 'MTART_T'   'ZC302MMT0013' 'C' 'X',
                                      ' ' 'MAKTX'     'ZC302MMT0013' ' ' 'X',
                                      ' ' 'H_RTPTQUA' 'ZC302MMT0013' ' ' ' ',
                                      ' ' 'MEINS'     'ZC302MMT0013' 'C' ' ',
                                      ' ' 'SCODE'     'ZC302MMT0013' 'C' 'X',
                                      ' ' 'SNAME'     'ZC302MMT0013' 'C' 'X',
                                      ' ' 'ADDRESS'   'ZC302MMT0013' ' ' 'X'.


    PERFORM set_layo.
    PERFORM create_object.
    PERFORM exclude_button TABLES gt_ui_functions.

*---------------------------Top-of-page-------------------------------*
    SET HANDLER : lcl_event_handler=>top_of_page  FOR go_alv_grid. " 어떤 ALV에 붙이던 상관없음

    CALL METHOD go_dyndoc_id->initialize_document
      EXPORTING
        background_color = cl_dd_area=>col_textarea.

    CALL METHOD go_alv_grid->list_processing_events
      EXPORTING
        i_event_name = 'TOP_OF_PAGE'
        i_dyndoc_id  = go_dyndoc_id.
*--------------------------------------------------------------------*

    lv_variant-report = sy-repid.
    lv_variant-handle = 'ALV1'.

    CALL METHOD go_alv_grid->set_table_for_first_display
      EXPORTING
        is_variant           = lv_variant
        i_save               = 'A'
        i_default            = 'X'
        is_layout            = gs_layo
        it_toolbar_excluding = gt_ui_functions
      CHANGING
        it_outtab            = gt_body
        it_fieldcatalog      = gt_fcat.

*    PERFORM register_event.

  ELSE.
    CALL METHOD go_alv_grid->refresh_table_display.

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
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_field_catalog  USING pv_key pv_field pv_table pv_just pv_emph.



  gs_fcat-key       = pv_key.
  gs_fcat-fieldname = pv_field.
  gs_fcat-ref_table = pv_table.
  gs_fcat-just      = pv_just.
  gs_fcat-emphasize = pv_emph.

  CASE pv_field.
    WHEN 'MENGE'.
      gs_fcat-qfieldname = 'MEINS'.
    WHEN 'H_RTPTQUA'.
      gs_fcat-qfieldname = 'MEINS'.
    WHEN 'MEINS'.
      gs_fcat-coltext = '단위'.
    WHEN 'MTART_T'.
      gs_fcat-coltext = '자재명'.
  ENDCASE.

  APPEND gs_fcat TO gt_fcat.
  CLEAR gs_fcat.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layo
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layo .

  gs_layo-zebra      = abap_true.
  gs_layo-cwidth_opt = 'A'.
  gs_layo-sel_mode   = 'D'.
  gs_layo-grid_title = '자재 리스트'.
  gs_layo-smalltitle = abap_true.

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

*-- TOP-OF-PAGE : install docking container for top-of-page( 맨위에 오브젝트 생성)
  CREATE OBJECT go_top_cont
    EXPORTING
      repid     = sy-cprog " 현재 프로그램(Function, Class MEthod)을 호출한 프로그램ID
      dynnr     = sy-dynnr " 현재 Screen Number
      side      = go_top_cont->dock_at_top
      extension = 50.


*-- For Docking Container
  CREATE OBJECT go_dock_cont
    EXPORTING
      side      = go_dock_cont->dock_at_left
      extension = 5000.

*-- For ALV
  CREATE OBJECT go_alv_grid
    EXPORTING
      i_parent = go_dock_cont.

*-- TOP-OF-PAGE : CREATE top-document (맨 마지막에 작성)
  CREATE OBJECT go_dyndoc_id
    EXPORTING
      style = 'ALV_GRID'.


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

  CALL METHOD go_alv_grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 1.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_row
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM process_row  USING pv_job.

  CASE pv_job.
    WHEN 'M'.

    WHEN 'E'.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_button
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exclude_button TABLES pt_ui_functions TYPE ui_functions. " ui functions은 table type이라서 structure사용이 불가함.

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
*& Form get_body_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_body_display .

  LOOP AT gt_body INTO gs_body.

    gv_tabix = sy-tabix.

    CASE gs_body-mtart.
      WHEN '01'.
        gs_body-mtart_t = '원자재'.
      WHEN '02'.
        gs_body-mtart_t = '반제품'.
      WHEN '03'.
        gs_body-mtart_t = '원제품'.
    ENDCASE.

    CASE gs_body-sname.
      WHEN '01'.
        gs_body-sname = '원자재창고'.
      WHEN '02'.
        gs_body-sname = '반제품창고'.
      WHEN '03'.
        gs_body-sname = '원제품창고'.
      WHEN '04'.
        gs_body-sname = '폐기창고'.
      WHEN '05'.
        gs_body-sname = '물류센터'.
    ENDCASE.



    MODIFY gt_body FROM gs_body INDEX gv_tabix
                                TRANSPORTING mtart_t sname.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_make_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_make_f4 .
  DATA : lv_tabix TYPE sy-tabix.

*-- BPcode Search help
  CLEAR : gt_bp, gs_bp.
  SELECT DISTINCT bpcode cname
    INTO CORRESPONDING FIELDS OF TABLE gt_bp
    FROM zc302mt0001
   WHERE bpcode LIKE 'PO%'.

  SORT  gt_bp BY bpcode.

*-- Matnr Search help
  CLEAR : gt_mat, gs_mat.
  SELECT matnr maktx
    INTO CORRESPONDING FIELDS OF TABLE gt_mat
    FROM zc302mt0007.

  SORT  gt_mat BY matnr.

*-- Storage Search help
  CLEAR : gt_sco, gs_sco.
  SELECT DISTINCT scode sname
    INTO CORRESPONDING FIELDS OF TABLE gt_sco
    FROM zc302mt0005.

  SORT  gt_sco BY scode.


  LOOP AT gt_sco INTO gs_sco.
    lv_tabix = sy-tabix.

    CASE gs_sco-sname.
      WHEN '01'.
        gs_sco-sname = '원자재창고'.
      WHEN '02'.
        gs_sco-sname = '반제품창고'.
      WHEN '03'.
        gs_sco-sname = '완제품창고'.
      WHEN '04'.
        gs_sco-sname = '폐기창고'.
      WHEN '05'.
        gs_sco-sname = '물류센터'.
    ENDCASE.

    MODIFY gt_sco FROM gs_sco INDEX lv_tabix TRANSPORTING sname.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_f4_bpcode
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_f4_bpcode .
  DATA : lt_return TYPE TABLE OF ddshretval WITH HEADER LINE.

  REFRESH : lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BPCODE'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'SO_BPC'    " Selection Screen Element
      window_title    = 'BP Code' " Description
      value_org       = 'S'
    TABLES
      value_tab       = gt_bp " F4에 뿌려줄 데이터
      return_tab      = lt_return " F4에서 선택된 값에 대한 정보
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_f4-matnr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_f4_matnr .
  DATA : lt_return TYPE TABLE OF ddshretval WITH HEADER LINE.

  REFRESH : lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'MATNR'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'SO_MAT'    " Selection Screen
      window_title    = 'Material Code' " Description
      value_org       = 'S'
    TABLES
      value_tab       = gt_mat " F4에 뿌려줄 데이터
      return_tab      = lt_return " F4에서 선택된 값에 대한 정보
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_f4_scode
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_f4_scode .
  DATA : lt_return TYPE TABLE OF ddshretval WITH HEADER LINE.

  REFRESH : lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'SCODE'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'SO_SCO'    " Selection Screen Element
      window_title    = 'Storage Code' " Description
      value_org       = 'S'
    TABLES
      value_tab       = gt_sco " F4에 뿌려줄 데이터
      return_tab      = lt_return " F4에서 선택된 값에 대한 정보
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
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

*-- 자재코드
  so_mat = VALUE #( so_mat[ 1 ] OPTIONAL ).
  CLEAR : lv_temp.
  IF so_mat-low IS NOT INITIAL.
    lv_temp = so_mat-low.
    IF so_mat-high IS NOT INITIAL.
      CONCATENATE lv_temp ' ~ ' so_mat-high INTO lv_temp.
    ENDIF.
  ELSE.
    lv_temp = '전체'.
  ENDIF.
  PERFORM add_row USING lr_dd_table col_field col_value '자재코드'  lv_temp.

*-- 자재유형
  so_mta = VALUE #( so_mta[ 1 ] OPTIONAL ).
  CLEAR : lv_temp.
  IF so_mta-low IS NOT INITIAL.
    lv_temp = so_mta-low.
    IF so_mta-high IS NOT INITIAL.
      CONCATENATE lv_temp ' ~ ' so_mta-high INTO lv_temp.
    ENDIF.
  ELSE.
    lv_temp = '전체'.
  ENDIF.
  PERFORM add_row USING lr_dd_table col_field col_value '자재유형' lv_temp.

*-- 거래처코드
  so_bpc = VALUE #( so_bpc[ 1 ] OPTIONAL ).
  CLEAR : lv_temp.
  IF so_bpc-low IS NOT INITIAL.
    lv_temp = so_bpc-low.
    IF so_bpc-high IS NOT INITIAL.
      CONCATENATE lv_temp ' ~ ' so_bpc-high INTO lv_temp.
    ENDIF.
  ELSE.
    lv_temp = '전체'.
  ENDIF.
  PERFORM add_row USING lr_dd_table col_field col_value 'BP코드' lv_temp.

*-- 창고코드
  so_sco = VALUE #( so_sco[ 1 ] OPTIONAL ).
  CLEAR : lv_temp.
  IF so_sco-low IS NOT INITIAL.
    lv_temp = so_sco-low.
    IF so_sco-high IS NOT INITIAL.
      CONCATENATE lv_temp ' ~ ' so_sco-high INTO lv_temp.
    ENDIF.
  ELSE.
    lv_temp = '전체'.
  ENDIF.
  PERFORM add_row USING lr_dd_table col_field col_value '창고코드' lv_temp.



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
*&      --> LV_TEMP
*&---------------------------------------------------------------------*
FORM add_row  USING pr_dd_table  TYPE REF TO cl_dd_table_element " 테이블
                    pv_col_field TYPE REF TO cl_dd_area           " column
                    pv_col_value TYPE REF TO cl_dd_area           " Value
                    pv_field                                      " Column에 입력할 값
                    pv_text.                                      " 값에 입력할 값

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


* creating html control object
  IF go_html_cntrl IS INITIAL.
    CREATE OBJECT go_html_cntrl
      EXPORTING
        parent = go_top_cont.
  ENDIF.

* Merge HTML Document : Top of Page의 내용을 HTML로 랜더링
  CALL METHOD go_dyndoc_id->merge_document.
  go_dyndoc_id->html_control = go_html_cntrl.

* Display document
  CALL METHOD go_dyndoc_id->display_document
    EXPORTING
      reuse_control      = 'X'
      parent             = go_top_cont
    EXCEPTIONS
      html_display_error = 1.

  IF sy-subrc NE 0.
    MESSAGE s001(k5) WITH 'Top of page event error' DISPLAY LIKE 'E'.
  ENDIF.


ENDFORM.
