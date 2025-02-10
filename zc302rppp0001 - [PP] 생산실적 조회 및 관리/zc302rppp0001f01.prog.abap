*&---------------------------------------------------------------------*
*& Include          ZC302RPPP0002F01
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

  CLEAR gt_prpe.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_prpe
    FROM zc302ppt0012
   WHERE qinum IN so_qin
     AND ponum IN so_pon
     AND matnr IN so_mat
     AND qidat IN so_mak.

  IF gt_prpe IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'. " 데이터가 존재하지 않습니다.
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

    CLEAR gt_fcat.
    PERFORM set_field_catalog USING: 'X' 'QINUM'    'ZC302PPT0012' ' ' ' ',
                                     'X' 'PONUM'    'ZC302PPT0012' ' ' ' ',
                                     'X' 'MATNR'    'ZC302PPT0012' ' ' ' ',
                                     ' ' 'MAKTX'    'ZC302PPT0012' ' ' ' ',
                                     ' ' 'PLANT'    'ZC302PPT0012' ' ' ' ',
                                     ' ' 'BOMID'    'ZC302PPT0012' ' ' ' ',
                                     ' ' 'PCODE'    'ZC302PPT0012' ' ' ' ',
                                     ' ' 'EMP_NUM'  'ZC302PPT0012' ' ' ' ',
                                     ' ' 'QIDAT'    'ZC302PPT0012' ' ' ' ',
                                     ' ' 'PQUA'     'ZC302PPT0012' ' ' ' ',
                                     ' ' 'DISMENGE' 'ZC302PPT0012' ' ' ' ',
                                     ' ' 'MENGE'    'ZC302PPT0012' ' ' ' ',
                                     ' ' 'UNIT'     'ZC302PPT0012' ' ' ' ',
                                     ' ' 'MBLNR'    'ZC302PPT0012' ' ' ' ',
                                     ' ' 'MJAHR'    'ZC302PPT0012' ' ' ' '.
    PERFORM set_layout.
    PERFORM create_object.
    PERFORM exclude_toolbar TABLES gt_ui_functions.

    gs_variant = VALUE #( report = sy-repid
                          handle = 'ALV1' ).

    SET HANDLER: lcl_event_handler=>handle_toolbar  FOR go_alv_grid,
                 lcl_event_handler=>user_command    FOR go_alv_grid,
                 lcl_event_handler=>top_of_page     FOR go_alv_grid.

    CALL METHOD go_alv_grid->set_table_for_first_display
      EXPORTING
        is_variant                    = gs_variant
        i_save                        = 'A'
        i_default                     = 'X'
        is_layout                     = gs_layout
        it_toolbar_excluding          = gt_ui_functions
      CHANGING
        it_outtab                     = gt_prpe
        it_fieldcatalog               = gt_fcat.

    PERFORM register_event.

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
*&---------------------------------------------------------------------*
FORM set_field_catalog  USING  pv_key pv_field pv_table pv_just pv_emph.

  gs_fcat = VALUE #( key       = pv_key
                     fieldname = pv_field
                     ref_table = pv_table
                     just      = pv_just
                     emphasize = pv_emph ).

  CASE pv_field.
    WHEN 'EMP_NUM'.
      gs_fcat-coltext = '담당자'.
    WHEN 'UNIT'.
      gs_fcat-coltext = '단위'.
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

  gs_layout = VALUE #( zebra = abap_true
                       cwidth_opt = 'A'
                       sel_mode   = 'D'
                       stylefname = 'CELLTAB'
                       ctab_fname = 'COLOR'
                       grid_title = '생산실적'
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

  CREATE OBJECT go_top_container
    EXPORTING
      repid     = sy-cprog                      " 현재 프로그램(Function, Class Method 등)을 호출한 프로그램의 ID
      dynnr     = sy-dynnr                      " 현재 Screen number
      side      = go_top_container->dock_at_top
      extension = 57.

  CREATE OBJECT go_container
    EXPORTING
      repid     = sy-cprog
      dynnr     = sy-dynnr
      side      = go_container->dock_at_left
      extension = 3000.

  CREATE OBJECT go_alv_grid
    EXPORTING
      i_parent = go_container.

* Create TOP-Document
  CREATE OBJECT go_dyndoc_id
    EXPORTING
      style = 'ALV_GRID'.     " 문서 내에서 텍스트의 스타일을 지정하는 옵션 설정

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
FORM handle_toolbar  USING  po_object TYPE REF TO cl_alv_event_toolbar_set
                              pv_interactive.

  DATA: lv_disabled.

  IF gv_mode EQ 'D'.
    lv_disabled = abap_true.
  ENDIF.

  _toolbar : ' '    ' '                          ' '   ' '                   lv_disabled 3  ,
               'TOGL' icon_toggle_display_change ' '   'Display <-> Change'  ' '         ' ',
               ' '    ' '                        ' '   ' '                   lv_disabled 3  ,
               'IROW' icon_insert_row            '추가' 'Add row'            lv_disabled ' ',
               'DROW' icon_delete_row            '삭제' 'Delete row'         lv_disabled ' '.

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

  DATA: lv_tabix TYPE sy-tabix.

  CLEAR gs_prpe.
  LOOP AT gt_prpe INTO gs_prpe.

    lv_tabix = sy-tabix.

    PERFORM set_style USING: 'QINUM' 'D',
                             'PONUM' 'D',
                             'MATNR' 'D',
                             ' '     'E'.

    PERFORM set_color USING: 'QINUM' 'P',
                             'PONUM' 'P',
                             'MAKTX' 'E',
                             'ENAME' 'E'.

    MODIFY gt_prpe FROM gs_prpe INDEX lv_tabix
                                TRANSPORTING celltab color.

  ENDLOOP.


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

  DATA: ls_stable TYPE lvc_s_stbl.

  ls_stable-row = abap_true.
  ls_stable-col = abap_true.

  CALL METHOD go_alv_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stable.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_style
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_style  USING pv_field pv_mode.

  DATA: ls_style TYPE lvc_s_styl.

  CLEAR ls_style.

  ls_style-fieldname = pv_field.

  CASE pv_mode.
    WHEN 'D'.
      ls_style-style = cl_gui_alv_grid=>mc_style_disabled.
    WHEN 'E'.
      ls_style-style = cl_gui_alv_grid=>mc_style_enabled.
  ENDCASE.

  INSERT ls_style INTO TABLE gs_prpe-celltab.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_color
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_color  USING pv_field pv_mode.

  DATA: ls_scol TYPE lvc_s_scol.

  CLEAR ls_scol.

  ls_scol-fname = pv_field.

  CASE pv_mode.
    WHEN 'P'. " PK
      ls_scol-color-col = 1.
      ls_scol-color-int = 1.
    WHEN 'E'. " emphasize
      ls_scol-color-col = 5.
  ENDCASE.

  INSERT ls_scol INTO TABLE gs_prpe-color.

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
      i_ready_for_input = 0.

  " 문서의 기본 속성(배경색 등)을 설정하는데 사용
  CALL METHOD go_dyndoc_id->initialize_document
    EXPORTING
      background_color = cl_dd_area=>col_textarea. " SAP 시스템에서 정의된 표준 색상으로 지정

  " ALV에서 TOP-OF-PAGE 이번트가 발생할 때 초기화된 동적 문서(go_dynoc_id)를 출력하도록 설정
  CALL METHOD go_alv_grid->list_processing_events
    EXPORTING
      i_event_name = 'TOP_OF_PAGE' " 이벤트 이름 지정
      i_dyndoc_id  = go_dyndoc_id. " 이벤트에서 사용할 동적 문서 객체

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
    WHEN 'IROW'.
      PERFORM process_row USING 'I'.
    WHEN 'DROW'.
      PERFORM process_row USING 'D'.
    WHEN 'TOGL'.
      PERFORM process_row USING 'T'.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_row
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM process_row  USING  pv_job.

  DATA: lt_row TYPE lvc_t_row,
        ls_row TYPE lvc_s_row.

  CASE pv_job.
    WHEN 'I'.

      CLEAR gs_prpe.
      PERFORM set_style USING: ' ' 'E'.

      APPEND gs_prpe TO gt_prpe.

      PERFORM refresh_table.

    WHEN 'D'.

      CALL METHOD go_alv_grid->get_selected_rows
        IMPORTING
          et_index_rows = lt_row.

      IF lt_row IS INITIAL.
        MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'. " 행을 선택하세요.
        EXIT.
      ENDIF.

      SORT lt_row BY index DESCENDING.

      LOOP AT lt_row INTO ls_row.

        CLEAR: gs_prpe, gs_delt.
        READ TABLE gt_prpe INTO gs_prpe INDEX ls_row-index.
        MOVE-CORRESPONDING gs_prpe TO gs_delt.
        APPEND gs_delt TO gt_delt.

        DELETE gt_prpe INDEX ls_row-index.

      ENDLOOP.

      PERFORM refresh_table.

    WHEN 'T'.

      CASE gv_mode.
        WHEN 'E'.
          gv_mode = 'D'.
          CALL METHOD go_alv_grid->set_ready_for_input
            EXPORTING
              i_ready_for_input = 0.
        WHEN 'D'.
          gv_mode = 'E'.
          CALL METHOD go_alv_grid->set_ready_for_input
            EXPORTING
              i_ready_for_input = 1.
      ENDCASE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_data .

*-- For Save
  DATA: lt_save   TYPE TABLE OF zc302ppt0012,
        ls_save   TYPE zc302ppt0012,
        lv_tabix  TYPE sy-tabix,
        lv_answer.

  "* Check data ( ALV -> ITAB )
  CALL METHOD go_alv_grid->check_changed_data.

  "* Move data & Check empty data
  MOVE-CORRESPONDING gt_prpe TO lt_save.

  IF ( lt_save IS INITIAL ) AND
     ( gt_delt IS INITIAL ).
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'. " 저장된 데이터가 없습니다.
    EXIT.
  ENDIF.

  "* Confirm for save
  PERFORM confirm_for_save CHANGING lv_answer.

  IF lv_answer NE '1'.
    MESSAGE s001 WITH TEXT-e04 DISPLAY LIKE 'E'. " 저장이 취소되었습니다.
    EXIT.
  ENDIF.

  "* Set Time Stamp
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

  "* Check Delete data
  IF gt_delt IS NOT INITIAL.
    DELETE zc302ppt0012 FROM TABLE gt_delt.
    CLEAR gt_delt.
  ENDIF.

  "* Save data
  MODIFY zc302ppt0012 FROM TABLE lt_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
    PERFORM make_display_body.
    PERFORM refresh_table.
    MESSAGE s001 WITH TEXT-g01.
  ELSE.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'. " 저장을 실패하였습니다.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form confirm_for_save
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM confirm_for_save  CHANGING pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
     TITLEBAR                    = 'Save Dialog'
     text_question               = '정말로 저장하시겠습니까?'
     TEXT_BUTTON_1               = '네'(001)
     ICON_BUTTON_1               = 'ICON_OKAY'
     TEXT_BUTTON_2               = '아니요'(002)
     ICON_BUTTON_2               = 'ICON_CANCEL'
     DEFAULT_BUTTON              = '1'
     DISPLAY_CANCEL_BUTTON       = space
    IMPORTING
     ANSWER                      = pv_answer.

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

  DATA : lr_dd_table TYPE REF TO cl_dd_table_element, " 동적문서 내에서 테이블 요소를 생성하고 관리하는데 사용
         col_field   TYPE REF TO cl_dd_area,          " 동적문서 내에서 텍스트나 다른 요소들을 구분하여 배치할 수 있는 구조를 제공
         col_field2  TYPE REF TO cl_dd_area,
         col_value   TYPE REF TO cl_dd_area,
         col_value2  TYPE REF TO cl_dd_area.

  DATA : lv_text  TYPE sdydo_text_element,
         lv_wave  TYPE sdydo_text_element,
         lv_text2 TYPE sdydo_text_element.

  CALL METHOD go_dyndoc_id->add_table
    EXPORTING
      no_of_columns = 4
      border        = '0'
    IMPORTING
      table         = lr_dd_table.

*-- Set column
  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_field.

  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_value.

  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_field2.

  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_value2.

  _set_top: so_qin lv_text lv_wave lv_text2.
  PERFORM add_row USING lr_dd_table col_field col_value col_field2 col_value2 '품질검수번호' lv_text lv_wave lv_text2.

  _set_top: so_pon lv_text lv_wave lv_text2.
  PERFORM add_row USING lr_dd_table col_field col_value col_field2 col_value2 '생산오더번호' lv_text lv_wave lv_text2.

  _set_top: so_mat lv_text lv_wave lv_text2.
  PERFORM add_row USING lr_dd_table col_field col_value col_field2 col_value2 '자재코드' lv_text lv_wave lv_text2.

  _set_top: so_mak lv_text lv_wave lv_text2.
  PERFORM add_row USING lr_dd_table col_field col_value col_field2 col_value2 '품질검수일자' lv_text lv_wave lv_text2.

*-- top_of_page 실행 (없으면 dump)
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
*&      --> COL_VALUE2
*&      --> P_
*&      --> LV_TEXT
*&---------------------------------------------------------------------*
FORM add_row  USING pr_dd_table   TYPE REF TO cl_dd_table_element
                    pv_col_field  TYPE REF TO cl_dd_area
                    pv_col_value  TYPE REF TO cl_dd_area
                    pv_col_field2 TYPE REF TO cl_dd_area
                    pv_col_value2 TYPE REF TO cl_dd_area
                    pv_field
                    pv_text
                    pv_field2
                    pv_text2.

  DATA : lv_text TYPE sdydo_text_element.

*-- Field.
  lv_text = pv_field.

  CALL METHOD pv_col_field->add_text
    EXPORTING
      text         = lv_text
      sap_emphasis = cl_dd_document=>strong
      sap_color    = cl_dd_document=>list_heading_inv.

*- Field쪽 gap
  CALL METHOD pv_col_field->add_gap
    EXPORTING
      width = 3.

*-- Value.
  lv_text = pv_text.

  CALL METHOD pv_col_value->add_text
    EXPORTING
      text         = lv_text
      sap_emphasis = cl_dd_document=>heading
      sap_color    = cl_dd_document=>list_negative_inv.

*- Value쪽 gap
  CALL METHOD pv_col_value->add_gap
    EXPORTING
      width = 3.

  """""""""""""
*-- Field2.
  lv_text = pv_field2.

  CALL METHOD pv_col_field2->add_text
    EXPORTING
      text         = lv_text
      sap_emphasis = cl_dd_document=>strong
      sap_color    = cl_dd_document=>list_heading_inv.

*- Field2쪽 gap
  CALL METHOD pv_col_field2->add_gap
    EXPORTING
      width = 3.

*-- Value2.
  lv_text = pv_text2.

  CALL METHOD pv_col_value2->add_text
    EXPORTING
      text         = lv_text
      sap_emphasis = cl_dd_document=>heading
      sap_color    = cl_dd_document=>list_negative_inv.

*- Value2쪽 gap
  CALL METHOD pv_col_value2->add_gap
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

* Creating html control
  IF go_html_cntrl IS INITIAL.
    CREATE OBJECT go_html_cntrl
      EXPORTING
        parent = go_top_container.
  ENDIF.

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
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_init_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_init_value .

  CLEAR gt_qin_pon.
  SELECT qinum ponum matnr maktx
    INTO CORRESPONDING FIELDS OF TABLE gt_qin_pon
    FROM zc302ppt0012.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_qinum
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_qinum  USING  pv_gubun.

  DATA : lt_return LIKE TABLE OF ddshretval WITH HEADER LINE,
         lt_dynp   TYPE TABLE OF dynpread   WITH HEADER LINE,
         lv_field  TYPE help_info-dynprofld.

  CASE pv_gubun.
    WHEN 'LOW'.
      lv_field = 'SO_QIN-LOW'.
    WHEN 'HIGH'.
      lv_field = 'SO_QIN-HIGH'.
  ENDCASE.

  _init lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'QINUM' " ALV 에 박히는 값
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = lv_field
      window_title    = 'Quality inspection code'
      value_org       = 'S'
    TABLES
      value_tab       = gt_qin_pon
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_ponum
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_ponum  USING  pv_gubun.

  DATA : lt_return LIKE TABLE OF ddshretval WITH HEADER LINE,
         lt_dynp   TYPE TABLE OF dynpread   WITH HEADER LINE,
         lv_field  TYPE help_info-dynprofld.

  CASE pv_gubun.
    WHEN 'LOW'.
      lv_field = 'SO_PON-LOW'.
    WHEN 'HIGH'.
      lv_field = 'SO_PON-HIGH'.
  ENDCASE.

  _init lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'PONUM' " ALV 에 박히는 값
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = lv_field
      window_title    = 'Product order code'
      value_org       = 'S'
    TABLES
      value_tab       = gt_qin_pon
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_matnr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_matnr  USING  pv_gubun.

  DATA : lt_return LIKE TABLE OF ddshretval WITH HEADER LINE,
         lt_dynp   TYPE TABLE OF dynpread   WITH HEADER LINE,
         lv_field  TYPE help_info-dynprofld.

  CASE pv_gubun.
    WHEN 'LOW'.
      lv_field = 'SO_MAT-LOW'.
    WHEN 'HIGH'.
      lv_field = 'SO_MAT-HIGH'.
  ENDCASE.

  _init lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'MATNR' " ALV 에 박히는 값
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = lv_field
      window_title    = 'Material code'
      value_org       = 'S'
    TABLES
      value_tab       = gt_qin_pon
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
