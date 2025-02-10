*&---------------------------------------------------------------------*
*& Include          ZC302RPPP0003F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_bom_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_bom_data .

  CLEAR gt_bomhead.
  SELECT bomid plant matnr maktx mitem
    INTO CORRESPONDING FIELDS OF TABLE gt_bomhead
    FROM zc302ppt0004
    WHERE bomid IN so_bomid
      AND matnr IN so_matnr.

  IF gt_bomhead IS INITIAL.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.
  ENDIF.

**-- 자재코드 Search Help(F4) 데이터
*  CLEAR : gt_matnr, gs_matnr.
*  SELECT matnr maktx gewei matlt
*    FROM zc302mt0007
*    INTO CORRESPONDING FIELDS OF TABLE gt_matnr.

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

    CLEAR : gt_lfcat, gs_lfcat.
    PERFORM set_left_catalog USING : 'X' 'BOMID' 'ZC302PPT0004' ' ' ' ',
                                     ' ' 'PLANT' 'ZC302PPT0004' ' ' ' ',
                                     ' ' 'MATNR' 'ZC302PPT0004' ' ' ' ',
                                     ' ' 'MAKTX' 'ZC302PPT0004' ' ' ' ',
                                     ' ' 'MITEM' 'ZC302PPT0004' ' ' ' '.

    CLEAR : gt_rfcat, gs_rfcat.
    PERFORM set_right_catalog USING : 'X' 'BOMID'  'ZC302PPT0005' ' ' ' ',
                                      'X' 'BOMNUM' 'ZC302PPT0005' 'C' ' ',
                                      'X' 'MATNR'  'ZC302PPT0005' ' ' ' ',
                                      ' ' 'MAKTX'  'ZC302PPT0005' ' ' ' ',
                                      ' ' 'MITEM'  'ZC302PPT0005' 'C' ' ',
                                      ' ' 'QUANT'  'ZC302PPT0005' ' ' ' ',
                                      ' ' 'UNIT'   'ZC302PPT0005' ' ' ' ',
                                      ' ' 'MATLT'  'ZC302PPT0005' 'C' ' '.

    PERFORM set_layout.
    PERFORM create_object.
    PERFORM exclude_toolbar TABLES gt_ui_functions.

    SET HANDLER : lcl_event_handler=>hotspot_click FOR go_left_grid,
                  lcl_event_handler=>left_toolbar  FOR go_left_grid,
                  lcl_event_handler=>right_toolbar FOR go_right_grid,
                  lcl_event_handler=>user_command  FOR go_left_grid,
                  lcl_event_handler=>user_command  FOR go_right_grid,
                  lcl_event_handler=>top_of_page   FOR go_left_grid, " 어떤 ALV에 붙이던 상관없음
                  lcl_event_handler=>search_help   FOR go_left_grid,
                  lcl_event_handler=>search_help   FOR go_right_grid,
                  lcl_event_handler=>data_change   FOR go_left_grid,
                  lcl_event_handler=>data_change   FOR go_right_grid.

    gs_variant-report = sy-repid.
    gs_variant-handle = 'ALV1'.

    CALL METHOD go_left_grid->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        i_save               = 'A'
        i_default            = 'X'
        is_layout            = gs_llayout
        it_toolbar_excluding = gt_ui_functions
      CHANGING
        it_outtab            = gt_bomhead
        it_fieldcatalog      = gt_lfcat.

    gs_variant-handle = 'ALV2'.

    CALL METHOD go_right_grid->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        i_save               = 'A'
        i_default            = 'X'
        is_layout            = gs_rlayout
        it_toolbar_excluding = gt_ui_functions
      CHANGING
        it_outtab            = gt_bomitem
        it_fieldcatalog      = gt_rfcat.

    PERFORM register_event.
    " f4 field register missed
    perform register_f4_field.

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

  gs_lfcat-key       = pv_key.
  gs_lfcat-fieldname = pv_field.
  gs_lfcat-ref_table = pv_table.
  gs_lfcat-just      = pv_just.
  gs_lfcat-emphasize = pv_emph.

*-- BOMID에 hotspot event를 설치
  CASE pv_field.
    WHEN 'BOMID'.
      gs_lfcat-hotspot = abap_true.
    WHEN 'MATNR'.
      gs_lfcat-f4availabl = abap_true.
  ENDCASE.

  APPEND gs_lfcat TO gt_lfcat.
  CLEAR gs_lfcat.

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

*-- 왼쪽 layout - bom header
  gs_llayout-zebra      = abap_true.
  gs_llayout-cwidth_opt = 'A'.
  gs_llayout-sel_mode   = 'D'.
  gs_llayout-stylefname = 'CELLTAB'.
  gs_llayout-ctab_fname = 'COLOR'.
  gs_llayout-grid_title = 'BOM Header'.
  gs_llayout-smalltitle = abap_true.

*-- 오른쪽 layout - bom item
  gs_rlayout-zebra      = abap_true.
  gs_rlayout-cwidth_opt = 'A'.
  gs_rlayout-sel_mode   = 'D'.
  gs_rlayout-stylefname = 'CELLTAB'.
  gs_rlayout-ctab_fname = 'COLOR'.
  gs_rlayout-grid_title = 'BOM Item'.
  gs_rlayout-smalltitle = abap_true.

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

*-- Top-of-page : Install Docking Container for Top-of-page
  CREATE OBJECT go_top_container
    EXPORTING
      repid     = sy-cprog
      dynnr     = sy-dynnr
      side      = go_top_container->dock_at_top
      extension = 40. " Top of page 높이

*-- Main container
  CREATE OBJECT go_container
    EXPORTING
      side      = go_container->dock_at_left
      extension = 5000.

*-- Splitter container
  CREATE OBJECT go_split_cont
    EXPORTING
      parent  = go_container
      rows    = 1     " 행
      columns = 2.    " 열

*-- Assign container
  CALL METHOD go_split_cont->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_left_cont.    " 할당받아서 옵젝 생성

  CALL METHOD go_split_cont->get_container
    EXPORTING
      row       = 1
      column    = 2
    RECEIVING
      container = go_right_cont.

**-- Set column width
*  CALL METHOD go_split_cont->set_column_width
*    EXPORTING
*      id    = 1     " Column ID
*      width = 35.

*-- ALV Grid
  CREATE OBJECT go_left_grid
    EXPORTING
      i_parent = go_left_cont.

  CREATE OBJECT go_right_grid
    EXPORTING
      i_parent = go_right_cont.

* Create TOP-Document
  CREATE OBJECT go_dyndoc_id
    EXPORTING
      style = 'ALV_GRID'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_hotspot_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&---------------------------------------------------------------------*
FORM handle_hotspot_click  USING    pv_row_id
                                    pv_column_id.

*-- 이벤트가 발생한 행의 데이터를 읽는다.
  CLEAR gs_bomhead.
  READ TABLE gt_bomhead INTO gs_bomhead INDEX pv_row_id.

*-- 선택한 행의 상세 데이터를 조회
  CLEAR gt_bomitem.
  SELECT bomid bomnum matnr maktx mitem
         quant unit matlt
    INTO CORRESPONDING FIELDS OF TABLE gt_bomitem
    FROM zc302ppt0005
    WHERE bomid = gs_bomhead-bomid.

  IF gt_bomitem IS INITIAL.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'. " 데이터가 존재하지 않습니다.
  ENDIF.

*-- 여기서 다시 한번 칼라와 편집 해줘야함
  PERFORM set_right_body.

*-- Refresh Right grid
  PERFORM refresh_right_table.

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

  gs_rfcat-key       = pv_key.
  gs_rfcat-fieldname = pv_field.
  gs_rfcat-ref_table = pv_table.
  gs_rfcat-just      = pv_just.
  gs_rfcat-emphasize = pv_emph.

  CASE pv_field.
    WHEN 'QUANT'.
      gs_rfcat-qfieldname = 'UNIT'.
    WHEN 'MATNR'.
      gs_rfcat-f4availabl = abap_true.
  ENDCASE.

  APPEND gs_rfcat TO gt_rfcat.
  CLEAR gs_rfcat.

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

  DATA : lr_dd_table TYPE REF TO cl_dd_table_element, " 테이블 - 동적문서 내에서 테이블 요소를 생성하고 관리하는데 사용
         col_field   TYPE REF TO cl_dd_area,          " 필드 - 동적문서 내에서 텍스트나 다른 요소들을 구분하여 배치할 수 있는 구조를 제공
         col_value   TYPE REF TO cl_dd_area,          " 값
         col_field2  TYPE REF TO cl_dd_area,
         col_value2  TYPE REF TO cl_dd_area.

  DATA : lv_text  TYPE sdydo_text_element,
         lv_wave  TYPE sdydo_text_element,
         lv_text2 TYPE sdydo_text_element.



*  Top of Page의 레이아웃 세팅


*-- Create Table
  CALL METHOD go_dyndoc_id->add_table
    EXPORTING
      no_of_columns = 4
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

  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_field2.

  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_value2.


  " Top of Page 레이아웃에 맞춰 값 세팅 - 매크로 활용

  _set_top : so_bomid lv_text lv_wave lv_text2.
  PERFORM add_row USING lr_dd_table col_field col_value col_field2 col_value2 'BOM ID' lv_text lv_wave lv_text2.

  _set_top: so_matnr lv_text lv_wave lv_text2.
  PERFORM add_row USING lr_dd_table col_field col_value col_field2 col_value2 '자재코드' lv_text lv_wave lv_text2.

*-- TOP OF PAGE 실행 - 없으면 덤프
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
*&      --> COL_FIELD2
*&      --> COL_VALUE2
*&      --> P_
*&      --> LV_TEXT
*&      --> LV_WAVE
*&      --> LV_TEXT2
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

* Creating html control object
  IF go_html_cntrl IS INITIAL.
    CREATE OBJECT go_html_cntrl
      EXPORTING
        parent = go_top_container.
  ENDIF.

* Merge HTML Document : Top of Page 의 내용을 HTML로 랜더링
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
*& Form register_event
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM register_event .

  CALL METHOD go_left_grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 0. " 1 : ON, 0 : OFF

  CALL METHOD go_right_grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 0. " 1 : ON, 0 : OFF

  " 문서의 기본 속성(배경색 등)을 설정하는데 사용
  CALL METHOD go_dyndoc_id->initialize_document
    EXPORTING
      background_color = cl_dd_area=>col_textarea. " SAP 시스템에서 정의된 표준 색상으로 지정

  " ALV에서 TOP-OF-PAGE 이벤트가 발생할 때 초기화된 동적 문서(go_dynoc_id)를 출력하도록 설정
  CALL METHOD go_left_grid->list_processing_events
    EXPORTING
      i_event_name = 'TOP_OF_PAGE' " 이벤트 이름 지정
      i_dyndoc_id  = go_dyndoc_id. " 이벤트에서 사용할 동적 문서 객체

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_display_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_data .

  PERFORM set_left_body.

  PERFORM set_right_body.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_left_body
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_left_body .

  DATA: lv_tabix TYPE sy-tabix.

  CLEAR gs_bomhead.
  LOOP AT gt_bomhead INTO gs_bomhead.

    lv_tabix = sy-tabix.

    PERFORM set_left_style USING: 'BOMID' 'D',
                                  ' '     'E'.

    PERFORM set_left_color USING: 'BOMID' 'P',
                                  'MAKTX' 'E'.

    MODIFY gt_bomhead FROM gs_bomhead INDEX lv_tabix
                                      TRANSPORTING celltab color.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_left_style
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_left_style  USING pv_field pv_mode.

  DATA: ls_style TYPE lvc_s_styl.

  CLEAR ls_style.

  ls_style-fieldname = pv_field.

  CASE pv_mode.
    WHEN 'D'.
      ls_style-style = cl_gui_alv_grid=>mc_style_disabled.
    WHEN 'E'.
      ls_style-style = cl_gui_alv_grid=>mc_style_enabled.
  ENDCASE.

  INSERT ls_style INTO TABLE gs_bomhead-celltab.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_left_color
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_left_color  USING pv_field pv_mode.

  DATA: ls_scol TYPE lvc_s_scol.

  CLEAR ls_scol.

  ls_scol-fname = pv_field.

  CASE pv_mode.
    WHEN 'P'. " PK
      ls_scol-color-col = 1.
      ls_scol-color-int = 1.      " 색상의 강도
    WHEN 'E'. " emphasize
      ls_scol-color-col = 5.
  ENDCASE.

  INSERT ls_scol INTO TABLE gs_bomhead-color.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_right_body
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_right_body .

  DATA: lv_tabix TYPE sy-tabix.

  CLEAR gs_bomitem.
  LOOP AT gt_bomitem INTO gs_bomitem.

    lv_tabix = sy-tabix.

    PERFORM set_right_style USING: 'BOMID'  'D',
                                   'BOMNUM' 'D',
                                   'MATNR'  'D',
                                   ' '      'E'.

    PERFORM set_right_color USING: 'BOMID'  'P',
                                   'BOMNUM' 'P',
                                   'MATNR'  'P',
                                   'MAKTX'  'E'.

    MODIFY gt_bomitem FROM gs_bomitem INDEX lv_tabix
                                TRANSPORTING celltab color.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_right_style
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_right_style  USING pv_field pv_mode.

  DATA: ls_style TYPE lvc_s_styl.

  CLEAR ls_style.

  ls_style-fieldname = pv_field.

  CASE pv_mode.
    WHEN 'D'.
      ls_style-style = cl_gui_alv_grid=>mc_style_disabled.
    WHEN 'E'.
      ls_style-style = cl_gui_alv_grid=>mc_style_enabled.
  ENDCASE.

  INSERT ls_style INTO TABLE gs_bomitem-celltab.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_right_color
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_right_color  USING pv_field pv_mode.

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

  INSERT ls_scol INTO TABLE gs_bomitem-color.

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

  ls_stable-row = abap_true.  " 행 고정하겠다
  ls_stable-col = abap_true.  " 열 고정하겠다

  CALL METHOD go_right_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stable.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_left_tbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM handle_left_tbar  USING po_object TYPE REF TO cl_alv_event_toolbar_set
                              pv_interactive.

  DATA: lv_disabled.

  IF gv_left_md EQ 'D'.
    lv_disabled = abap_true.
  ENDIF.

  _left_tbar : ' '    ' '                        ' '    ' '                  lv_disabled 3  ,
               'LTOG' icon_toggle_display_change ' '    'Display <-> Change' ' '         ' ',
               ' '    ' '                        ' '    ' '                  lv_disabled 3  ,
               'LIRO' icon_insert_row            '추가'   'Add row'            lv_disabled ' ',
               'LDRO' icon_delete_row            '삭제'   'Delete row'         lv_disabled ' ',
               ' '    ' '                        ' '     ' '                 lv_disabled 3  ,
               'LSAV' icon_system_save           '저장'   'Save'               lv_disabled ' '.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_right_tbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM handle_right_tbar  USING  po_object TYPE REF TO cl_alv_event_toolbar_set
                               pv_interactive.

  DATA: lv_disabled.

  IF gv_right_md EQ 'D'.
    lv_disabled = abap_true.
  ENDIF.

  _right_tbar : ' '    ' '                        ' '    ' '                  lv_disabled 3  ,
                'RTOG' icon_toggle_display_change ' '    'Display <-> Change' ' '         ' ',
                ' '    ' '                        ' '    ' '                  lv_disabled 3  ,
                'RIRO' icon_insert_row            '추가'   'Add row'            lv_disabled ' ',
                'RDRO' icon_delete_row            '삭제'   'Delete row'         lv_disabled ' ',
                ' '    ' '                        ' '     ' '                 lv_disabled 3  ,
                'RSAV' icon_system_save           '저장'   'Save'               lv_disabled ' '.

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
    WHEN 'LIRO'.
      PERFORM process_left_row USING 'I'.
    WHEN 'LDRO'.
      PERFORM process_left_row USING 'D'.
    WHEN 'LTOG'.
      PERFORM process_left_row USING 'T'.
    WHEN 'LSAV'.
      PERFORM save_left_data.
    WHEN 'RIRO'.
      PERFORM process_right_row USING 'I'.
    WHEN 'RDRO'.
      PERFORM process_right_row USING 'D'.
    WHEN 'RTOG'.
      PERFORM process_right_row USING 'T'.
    WHEN 'RSAV'.
      PERFORM save_right_data.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_left_row
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM process_left_row  USING pv_job.

  DATA: lt_row TYPE lvc_t_row,
        ls_row TYPE lvc_s_row.

  CASE pv_job.
    WHEN 'I'.           " Insert

      CLEAR gs_bomhead.
      PERFORM set_left_style USING: ' ' 'E'.   " 편집모드로 들어간다

      APPEND gs_bomhead TO gt_bomhead.

      PERFORM refresh_left_table.

    WHEN 'D'.           " Delete

      CALL METHOD go_left_grid->get_selected_rows
        IMPORTING
          et_index_rows = lt_row.

*-- Check selected
      IF lt_row IS INITIAL.
        MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'. " 행을 선택하세요.
        EXIT.
      ENDIF.

*-- 작업중인 index를 잃지 않기위해 내림차순 정렬
      SORT lt_row BY index DESCENDING.

      LOOP AT lt_row INTO ls_row.

*-- 삭제대상 Data를 별도의 ITAB에 저장
        CLEAR: gs_bomhead, gs_left_del.
        READ TABLE gt_bomhead INTO gs_bomhead INDEX ls_row-index.

        " 저장 버튼을 눌렀을 때 DB에 반영시키기 위한 Internal Table (BOM Header)
        MOVE-CORRESPONDING gs_bomhead TO gs_left_del.
        APPEND gs_left_del TO gt_left_del.

        " 저장 버튼을 눌렀을 때 DB에 반영시키기 위한 Internal Table (BOM Item)
        SELECT *
          INTO CORRESPONDING FIELDS OF TABLE gt_right_del
          FROM zc302ppt0005
         WHERE bomid EQ gs_bomhead-bomid.

*-- 선택한 행을 ITAB에서 삭제
        DELETE gt_bomhead INDEX ls_row-index.
        DELETE gt_bomitem WHERE bomid = gs_bomhead-bomid.

      ENDLOOP.

*-- ALV 갱신
      PERFORM refresh_left_table.
      PERFORM refresh_right_table.

    WHEN 'T'.           " 토글 Edit <-> Display

      CASE gv_left_md.
        WHEN 'E'.
          gv_left_md = 'D'.
          CALL METHOD go_left_grid->set_ready_for_input
            EXPORTING
              i_ready_for_input = 0.
        WHEN 'D'.
          gv_left_md = 'E'.
          CALL METHOD go_left_grid->set_ready_for_input
            EXPORTING
              i_ready_for_input = 1.
      ENDCASE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_left_table
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
*& Form save_left_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_left_data .

*-- For Save
  DATA: lt_save   TYPE TABLE OF zc302ppt0004,
        ls_save   TYPE zc302ppt0004,
        lv_tabix  TYPE sy-tabix,
        lv_answer.

  " Check data ( ALV -> ITAB )
  CALL METHOD go_left_grid->check_changed_data.

  " Move data & Check empty data
  MOVE-CORRESPONDING gt_bomhead TO lt_save.      " 추가한 것들도 gt_bomhead에 있으니 이걸 lt_save로

  IF ( lt_save     IS INITIAL ) AND
     ( gt_left_del IS INITIAL ).                 " 임시로 삭제한 데이터 모아놓은 것들
    MESSAGE s001 WITH TEXT-e04 DISPLAY LIKE 'E'. " 저장된 데이터가 없습니다. - 데이터에 변화가 없음
    EXIT.
  ENDIF.

  " Confirm for save
  PERFORM confirm_for_save CHANGING lv_answer.

  IF lv_answer NE '1'.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'. " 저장이 취소되었습니다.
    EXIT.
  ENDIF.

  " Set Time Stamp
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

  " Check Delete data (BOM Header)
  IF gt_left_del IS NOT INITIAL.
    DELETE zc302ppt0004 FROM TABLE gt_left_del.
    CLEAR gt_left_del.
  ENDIF.

  " Check Delete data (BOM Item)
  IF gt_right_del IS NOT INITIAL.
    DELETE zc302ppt0005 FROM TABLE gt_right_del.
    CLEAR gt_right_del.
  ENDIF.

  " Save data
  MODIFY zc302ppt0004 FROM TABLE lt_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
    PERFORM set_left_body.
    PERFORM refresh_left_table.
    MESSAGE s001 WITH TEXT-e06. " 저장을 성공하였습니다.
  ELSE.
    MESSAGE s001 WITH TEXT-e07 DISPLAY LIKE 'E'. " 저장을 실패하였습니다.
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
      titlebar              = 'Save Dialog'
      text_question         = '정말로 저장하시겠습니까?'
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
*& Form process_right_row
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM process_right_row  USING  pv_job.

  DATA: lt_row TYPE lvc_t_row,
        ls_row TYPE lvc_s_row.

  CASE pv_job.
    WHEN 'I'.               " Insert

      CLEAR gs_bomitem.
      PERFORM set_right_style USING: ' ' 'E'.

*-- 기본 데이터 설정
      gs_bomitem-bomid = gs_bomhead-bomid.

      APPEND gs_bomitem TO gt_bomitem.

      PERFORM refresh_right_table.

    WHEN 'D'.               " Delete

      CALL METHOD go_right_grid->get_selected_rows
        IMPORTING
          et_index_rows = lt_row.

      IF lt_row IS INITIAL.
        MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'. " 행을 선택하세요.
        EXIT.
      ENDIF.

      SORT lt_row BY index DESCENDING.

      LOOP AT lt_row INTO ls_row.

        CLEAR: gs_bomitem, gs_right_del.
        READ TABLE gt_bomitem INTO gs_bomitem INDEX ls_row-index.
        MOVE-CORRESPONDING gs_bomitem TO gs_right_del.
        APPEND gs_right_del TO gt_right_del.

        DELETE gt_bomitem INDEX ls_row-index.

      ENDLOOP.

      PERFORM refresh_right_table.

    WHEN 'T'.               " Display <-> Edit

      CASE gv_right_md.
        WHEN 'E'.
          gv_right_md = 'D'.
          CALL METHOD go_right_grid->set_ready_for_input
            EXPORTING
              i_ready_for_input = 0.
        WHEN 'D'.
          gv_right_md = 'E'.
          CALL METHOD go_right_grid->set_ready_for_input
            EXPORTING
              i_ready_for_input = 1.
      ENDCASE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_right_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_right_data .

*-- For Save
  DATA: lt_save   TYPE TABLE OF zc302ppt0005,
        ls_save   TYPE zc302ppt0005,
        lv_tabix  TYPE sy-tabix,
        lv_answer.

  " Check data ( ALV -> ITAB )
  CALL METHOD go_right_grid->check_changed_data.

  " Move data & Check empty data
  MOVE-CORRESPONDING gt_bomitem TO lt_save.

  IF ( lt_save      IS INITIAL ) AND
     ( gt_right_del IS INITIAL ).
    MESSAGE s001 WITH TEXT-e04 DISPLAY LIKE 'E'. " 저장된 데이터가 없습니다.
    EXIT.
  ENDIF.

  " Confirm for save
  PERFORM confirm_for_save CHANGING lv_answer.

  IF lv_answer NE '1'.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'. " 저장이 취소되었습니다.
    EXIT.
  ENDIF.

  " Set Time Stamp
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

  " Check Delete data
  IF gt_right_del IS NOT INITIAL.
    DELETE zc302ppt0005 FROM TABLE gt_right_del.
    CLEAR gt_right_del.
  ENDIF.

  " Save data
  MODIFY zc302ppt0005 FROM TABLE lt_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
    PERFORM set_right_body.
    PERFORM refresh_right_table.
    MESSAGE s001 WITH TEXT-e06. " 저장을 성공하였습니다.
  ELSE.
    MESSAGE s001 WITH TEXT-e07 DISPLAY LIKE 'E'. " 저장을 실패하였습니다.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_UI_FUNCTIONS
*&---------------------------------------------------------------------*
FORM exclude_toolbar  TABLES pt_ui_functions TYPE ui_functions.

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
*& Form set_init_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_init_value .

  CLEAR gt_bomid.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_bomid
    FROM zc302ppt0004.

  CLEAR gt_matnr.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_matnr
    FROM zc302mt0007.

**-- Header 자재코드 Search Help(F4) 데이터
*  CLEAR : gs_matnr, gt_matnr.
*  SELECT matnr maktx gewei
*    INTO CORRESPONDING FIELDS OF TABLE gt_matnr
*    FROM zc302mt0007
*    WHERE mtart = '03'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_bomid
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_bomid  USING pv_gubun.

  DATA : lt_return LIKE TABLE OF ddshretval WITH HEADER LINE,
         lt_dynp   TYPE TABLE OF dynpread   WITH HEADER LINE,
         lv_field  TYPE help_info-dynprofld.

  CASE pv_gubun.
    WHEN 'LOW'.
      lv_field = 'SO_BOMID-LOW'.
    WHEN 'HIGH'.
      lv_field = 'SO_BOMID-HIGH'.
  ENDCASE.

  REFRESH : lt_return.
  CLEAR : lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BOMID'    " 선택한 값이 해당 필드에 반환
      dynpprog        = sy-repid   " 현재 프로그램 ID
      dynpnr          = sy-dynnr   " 현재 화면 번호
      dynprofield     = lv_field   " 헬프를 호출할 필드 (so_bomid)
      window_title    = 'BOM ID'   " f4 헬프 윈도우의 제목
      value_org       = 'S'        " 값의 원본을 SAP 데이터베이스로 지정
    TABLES
      value_tab       = gt_bomid   " 사용자가 선택할 수 있는 값 목록
      return_tab      = lt_return  " 사용자가 선택한 값 반환할 테이블
    EXCEPTIONS
      parameter_error = 1       " 파라미터 오류 발생하면 예외 코드 1
      no_values_found = 2       " 값 찾지 못했을 때 예외 코드 2
      OTHERS          = 3.      " 기타 오류 발생하면 예외 코드 3


ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_matnr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_matnr  USING pv_gubun.

  DATA : lt_return LIKE TABLE OF ddshretval WITH HEADER LINE,
         lt_dynp   TYPE TABLE OF dynpread   WITH HEADER LINE,
         lv_field  TYPE help_info-dynprofld.

  CASE pv_gubun.
    WHEN 'LOW'.
      lv_field = 'SO_MATNR-LOW'.
    WHEN 'HIGH'.
      lv_field = 'SO_MATNR-HIGH'.
  ENDCASE.

  REFRESH : lt_return.
  CLEAR : lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'MATNR'       " ALV 에 박히는 값 (input에 넣어줄 필드)
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = lv_field        " Selection screen element
      window_title    = 'MATNR'
      value_org       = 'S'
    TABLES
      value_tab       = gt_matnr      " F4에 뿌려줄 데이터 (initialiazation서 select)
      return_tab      = lt_return     " F4에서 선택된 값에 대한 정보
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_header_material_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*FORM get_header_material_f4 .
*
*  DATA : BEGIN OF ls_mat_f4,
*           matnr TYPE zc302mt0007-matnr,
*           maktx TYPE zc302mt0007-maktx,
*         END OF ls_mat_f4,
*         lt_mat_f4 LIKE TABLE OF ls_mat_f4.
*
*  DATA : lt_return TYPE TABLE OF ddshretval WITH HEADER LINE,
*         lt_read   TYPE TABLE OF dynpread WITH HEADER LINE.
*
**-- Get Material Info for Search Help(F4)
*  MOVE-CORRESPONDING gt_matnr TO lt_mat_f4.
*
**-- Execute F4 Help
*  REFRESH lt_return.
*  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*    EXPORTING
*      retfield        = 'MATNR'
*      dynpprog        = sy-repid
*      dynpnr          = sy-dynnr
*      dynprofield     = 'GV_MATNR'
*      window_title    = 'Material code'
*    TABLES
*      value_tab       = lt_mat_f4
*      return_tab      = lt_return
*    EXCEPTIONS
*      parameter_error = 1
*      no_values_found = 2
*      OTHERS          = 3.
*
**-- Get description
*  lt_return = VALUE #( lt_return[ 1 ] OPTIONAL ).
*
*  CLEAR : gs_matnr.
*  READ TABLE gt_matnr INTO gs_matnr WITH KEY matnr = lt_return-fieldval.
*  gv_maktx = gs_matnr-maktx.
*
**-- Set value to Dynpro
*  REFRESH lt_read.
*  lt_read-fieldname = 'GV_MATNR'.
*  lt_read-fieldvalue = lt_return-fieldval.
*  APPEND lt_read.
*  lt_read-fieldname = 'GV_MAKTX'.
*  lt_read-fieldvalue = gs_matnr-maktx.
*  APPEND lt_read.
*
*  CALL FUNCTION 'DYNP_VALUES_UPDATE'
*    EXPORTING
*      dyname               = sy-repid
*      dynumb               = sy-dynnr
*    TABLES
*      dynpfields           = lt_read
*    EXCEPTIONS
*      invalid_abapworkarea = 1
*      invalid_dynprofield  = 2
*      invalid_dynproname   = 3
*      invalid_dynpronummer = 4
*      invalid_request      = 5
*      no_fielddescription  = 6
*      undefind_error       = 7
*      OTHERS               = 8.
*
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form onf4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_FIELDNAME
*&      --> E_FIELDVALUE
*&      --> ES_ROW_NO
*&      --> ER_EVENT_DATA
*&      --> ET_BAD_CELLS
*&      --> E_DISPLAY
*&---------------------------------------------------------------------*
FORM onf4  USING  p_fieldname   TYPE  lvc_fname
                  p_fieldvalue  TYPE  lvc_value
                  ps_row_no     TYPE  lvc_s_roid
                  pi_event_data TYPE REF TO cl_alv_event_data
                  pt_bad_cells  TYPE  lvc_t_modi
                  p_display     TYPE  char01.

  DATA : lt_return LIKE TABLE OF ddshretval WITH HEADER LINE,
         window_title(30),
         l_row type p,
         lv_field TYPE dfies-fieldname,
         lv_text  TYPE help_info-dynprofld,
         lv_flag.

  DATA : BEGIN OF ls_mat_f4,
           matnr TYPE zc302mt0007-matnr,
           maktx TYPE zc302mt0007-maktx,
         END OF ls_mat_f4,
         lt_mat_f4 LIKE TABLE OF ls_mat_f4.

*-- Get Material Info for Search Help(F4)
*  MOVE-CORRESPONDING gt_matnr TO lt_mat_f4.
  SELECT * FROM zc302mt0007
    INTO CORRESPONDING FIELDS OF TABLE lt_mat_f4.

    IF lt_mat_f4 IS INITIAL.
      MESSAGE s001 WITH 'F4 ERROR'.
      EXIT.
    ENDIF.

    " add code / set f4 help
    CASE p_fieldname.
      WHEN 'MATNR'.
        window_title ='MATERIAL CODE'.
        lv_field = 'MATNR'.
        lv_text = 'MAKTX'.
    ENDCASE.

*-- 자재코드에 Search Help(F4) 부착
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = lv_field
        dynpprog        = sy-repid
        dynpnr          = sy-dynnr
        dynprofield     = 'MATNR'
        window_title    = window_title
        value_org       = 'S'
      TABLES
        value_tab       = lt_mat_f4
        return_tab      = lt_return
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.

    pi_event_data->m_event_handled = 'X'.

*-- Search Help에서 항목 선택 시 ALV에 선택한 값 들어감
    FIELD-SYMBOLS:  <fs> TYPE lvc_t_modi.

    DATA: ls_modi TYPE lvc_s_modi.

    ASSIGN pi_event_data->m_data->* TO <fs>.

    READ TABLE lt_return INDEX 1.
    IF sy-subrc = 0.
      ls_modi-row_id    = ps_row_no-row_id.
      ls_modi-fieldname = p_fieldname.
      ls_modi-value     = lt_return-fieldval.
      APPEND ls_modi TO <fs>.
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
FORM handle_data_change  USING pv_modified
                              pt_good_cells TYPE lvc_t_modi.

  DATA : ls_good_cells TYPE lvc_s_modi.

*-- 변경된 내역이 있는지 확인
  CHECK pv_modified IS NOT INITIAL.

*-- 변경 대상 필드 확인
  CLEAR : ls_good_cells.
  READ TABLE pt_good_cells INTO ls_good_cells INDEX 1.

  CLEAR : gs_bomhead.
  READ TABLE gt_bomhead INTO gs_bomhead INDEX ls_good_cells-row_id.

  CASE ls_good_cells-fieldname.
      " 자재코드 입력 -> 자재명 자동 업데이트
    WHEN 'MATNR'.
      CLEAR : gs_matnr.
      READ TABLE gt_matnr INTO gs_matnr WITH KEY matnr = ls_good_cells-value.

      gs_bomhead-maktx = gs_matnr-maktx.   " 제품명
*      gs_bomitem-mtart = gs_matnr-mtart.   " 자재유형
*      gs_bomhead-unit  = gs_matnr-gewei. " 단위
*      gs_bomhead-matlt = gs_matnr-matlt.   " 구매 리드타임

      MODIFY gt_bomhead FROM gs_bomhead INDEX ls_good_cells-row_id TRANSPORTING maktx.

  ENDCASE.

*** 오른쪽 item 부분
  CLEAR : gs_bomitem.
  READ TABLE gt_bomitem INTO gs_bomitem INDEX ls_good_cells-row_id.

  CASE ls_good_cells-fieldname.
      " 자재코드 입력 -> 자재명 자동 업데이트
    WHEN 'MATNR'.
      CLEAR : gs_matnr.
      READ TABLE gt_matnr INTO gs_matnr WITH KEY matnr = ls_good_cells-value.

      gs_bomitem-maktx = gs_matnr-maktx.   " 제품명
*      gs_bomitem-mtart = gs_matnr-mtart.   " 자재유형
*      gs_bomhead-unit  = gs_matnr-gewei. " 단위
*      gs_bomhead-matlt = gs_matnr-matlt.   " 구매 리드타임

      MODIFY gt_bomitem FROM gs_bomitem INDEX ls_good_cells-row_id TRANSPORTING maktx.


*      " 수량 입력 -> 금액 & 통화 자동 업데이트
*    WHEN 'MENGE'.
*
*      " 자재코드가 입력되지 않았다면 에러메시지 디스플레이
*      IF gs_bomitem-matnr IS INITIAL.
*        MESSAGE s001 WITH TEXT-e13 DISPLAY LIKE 'E'.
*        EXIT.
*      ENDIF.
*
*      CLEAR : gs_mat.
*      READ TABLE gt_mat INTO gs_mat WITH KEY matnr = gs_item-matnr.
*
*      gs_item-menge = ls_good_cells-value.                " 수량
*      gs_item-netwr = gs_mat-netwr * ls_good_cells-value. " 금액
*      gs_item-waers = gs_mat-waers.                       " 통화
*
*      MODIFY gt_item FROM gs_item INDEX ls_good_cells-row_id.
  ENDCASE.

  PERFORM refresh_left_table.
  PERFORM refresh_right_table.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form register_f4_field
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM register_f4_field .
  data : lt_f4 type lvc_t_f4 with HEADER LINE,
         lt_f4_data type lvc_s_f4.

  lt_f4_data-fieldname = 'MATNR'.
  lt_f4_data-register = 'X' .
  lt_f4_data-getbefore = 'X' .
  lt_f4_data-chngeafter  ='X'.
  INSERT lt_f4_data INTO TABLE lt_f4.

  CALL METHOD go_left_grid->register_f4_for_fields
    EXPORTING
      it_f4 = lt_f4[].

  CALL METHOD go_right_grid->register_f4_for_fields
    EXPORTING
      it_f4 = lt_f4[].

ENDFORM.
