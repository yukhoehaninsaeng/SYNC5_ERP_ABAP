*&---------------------------------------------------------------------*
*& Include          ZC302RPPP0005F01
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

  CLEAR gt_plant.
  SELECT plant pname plloc pltel
         emp_num ename
    INTO CORRESPONDING FIELDS OF TABLE gt_plant
    FROM zc302mt0004
    WHERE plant IN so_plant.

  IF gt_plant IS INITIAL.
    MESSAGE s037 DISPLAY LIKE 'E'.
  ENDIF.

  CLEAR gt_stl.
  SELECT scode sname plant sttel address
         emp_num ename
    INTO CORRESPONDING FIELDS OF TABLE gt_stl
    FROM zc302mt0005
    WHERE scode IN so_scode.

  IF gt_stl IS INITIAL.
    MESSAGE s037 DISPLAY LIKE 'E'.
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

    CLEAR : gt_ufcat, gs_ufcat.
    PERFORM set_up_catalog USING : 'X' 'PLANT'   'ZC302MT0004' ' ' ' ',
                                   ' ' 'PNAME'   'ZC302MT0004' ' ' ' ',
                                   ' ' 'PLLOC'   'ZC302MT0004' ' ' ' ',
                                   ' ' 'PLTEL'   'ZC302MT0004' ' ' ' ',
                                   ' ' 'EMP_NUM' 'ZC302MT0004' ' ' ' ',
                                   ' ' 'ENAME'   'ZC302MT0004' ' ' ' '.

    CLEAR : gt_dfcat, gs_dfcat.
    PERFORM set_down_catalog USING : 'X' 'PLANT'   'ZC302MT0005' ' ' ' ',
                                     'X' 'SCODE'   'ZC302MT0005' ' ' ' ',
                                     ' ' 'SNAME'   'ZC302MT0005' 'C' ' ',
                                     ' ' 'STTEL'   'ZC302MT0005' ' ' ' ',
                                     ' ' 'ADDRESS' 'ZC302MT0005' 'C' ' ',
                                     ' ' 'EMP_NUM' 'ZC302MT0005' ' ' ' ',
                                     ' ' 'ENAME'   'ZC302MT0005' ' ' ' '.

    PERFORM set_layout.
    PERFORM create_object.

    SET HANDLER : lcl_event_handler=>up_toolbar    FOR go_up_grid,
                  lcl_event_handler=>down_toolbar  FOR go_down_grid,
                  lcl_event_handler=>user_command  FOR go_up_grid,
                  lcl_event_handler=>user_command  FOR go_down_grid,
                  lcl_event_handler=>top_of_page   FOR go_up_grid. " 어떤 ALV에 붙이던 상관없음

    gs_variant-report = sy-repid.
    gs_variant-handle = 'ALV1'.

    CALL METHOD go_up_grid->set_table_for_first_display
      EXPORTING
        is_variant      = gs_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_ulayout
      CHANGING
        it_outtab       = gt_plant
        it_fieldcatalog = gt_ufcat.

    gs_variant-handle = 'ALV2'.

    CALL METHOD go_down_grid->set_table_for_first_display
      EXPORTING
        is_variant      = gs_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_dlayout
      CHANGING
        it_outtab       = gt_stl
        it_fieldcatalog = gt_dfcat.


    PERFORM register_event.

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
FORM set_up_catalog  USING pv_key pv_field pv_table pv_just pv_emph.

  gs_ufcat-key       = pv_key.
  gs_ufcat-fieldname = pv_field.
  gs_ufcat-ref_table = pv_table.
  gs_ufcat-just      = pv_just.
  gs_ufcat-emphasize = pv_emph.

  APPEND gs_ufcat TO gt_ufcat.
  CLEAR gs_ufcat.

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
FORM set_down_catalog  USING pv_key pv_field pv_table pv_just pv_emph.

  gs_dfcat-key       = pv_key.
  gs_dfcat-fieldname = pv_field.
  gs_dfcat-ref_table = pv_table.
  gs_dfcat-just      = pv_just.
  gs_dfcat-emphasize = pv_emph.

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

  gs_ulayout = VALUE #( zebra      = abap_true
                        cwidth_opt = 'A'
                        sel_mode   = 'D'
                        stylefname = 'CELLTAB'
                        ctab_fname = 'COLOR'
                        grid_title = '공장 정보'
                        smalltitle = abap_true ).

  gs_dlayout = VALUE #( zebra     = abap_true
                        cwidth_opt = 'A'
                        sel_mode   = 'D'
                        stylefname = 'CELLTAB'
                        ctab_fname = 'COLOR'
                        grid_title = '창고 정보'
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
      rows    = 2     " 행
      columns = 1.    " 열

*-- Assign container
  CALL METHOD go_split_cont->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_up_cont.    " 할당받아서 옵젝 생성

  CALL METHOD go_split_cont->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_down_cont.

**-- Set column width
*  CALL METHOD go_split_cont->set_column_width
*    EXPORTING
*      id    = 1     " Column ID
*      width = 35.

*-- ALV Grid
  CREATE OBJECT go_up_grid
    EXPORTING
      i_parent = go_up_cont.

  CREATE OBJECT go_down_grid
    EXPORTING
      i_parent = go_down_cont.

* Create TOP-Document
  CREATE OBJECT go_dyndoc_id
    EXPORTING
      style = 'ALV_GRID'.

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

  _set_top : so_plant lv_text lv_wave lv_text2.
  PERFORM add_row USING lr_dd_table col_field col_value col_field2 col_value2 '공장코드' lv_text lv_wave lv_text2.

  _set_top: so_scode lv_text lv_wave lv_text2.
  PERFORM add_row USING lr_dd_table col_field col_value col_field2 col_value2 '창고코드' lv_text lv_wave lv_text2.

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

  " 문서의 기본 속성(배경색 등)을 설정하는데 사용
  CALL METHOD go_dyndoc_id->initialize_document
    EXPORTING
      background_color = cl_dd_area=>col_textarea. " SAP 시스템에서 정의된 표준 색상으로 지정

  " ALV에서 TOP-OF-PAGE 이벤트가 발생할 때 초기화된 동적 문서(go_dynoc_id)를 출력하도록 설정
  CALL METHOD go_up_grid->list_processing_events
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

  PERFORM set_up_body.

  PERFORM set_down_body.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_up_body
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_up_body .

  DATA : lv_tabix TYPE sy-tabix.

  CLEAR gs_plant.
  LOOP AT gt_plant INTO gs_plant.

    lv_tabix = sy-tabix.

    PERFORM set_up_style USING: 'PLANT' 'D',
                                ' '     'E'.

    PERFORM set_up_color USING: 'PLANT' 'P',
                                'PNAME' 'E',
                                'PLLOC' 'E2'.

    MODIFY gt_plant FROM gs_plant INDEX lv_tabix
                                  TRANSPORTING celltab color.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_up_style
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_up_style  USING pv_field pv_mode.

  DATA: ls_style TYPE lvc_s_styl.

  CLEAR ls_style.

  ls_style-fieldname = pv_field.

  CASE pv_mode.
    WHEN 'D'.
      ls_style-style = cl_gui_alv_grid=>mc_style_disabled.
    WHEN 'E'.
      ls_style-style = cl_gui_alv_grid=>mc_style_enabled.
  ENDCASE.

  INSERT ls_style INTO TABLE gs_plant-celltab.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_up_color
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_up_color  USING pv_field pv_mode.

  DATA: ls_scol TYPE lvc_s_scol.

  CLEAR ls_scol.

  ls_scol-fname = pv_field.

  CASE pv_mode.
    WHEN 'P'. " PK
      ls_scol-color-col = 1.
      ls_scol-color-int = 1.      " 색상의 강도
    WHEN 'E'. " emphasize
      ls_scol-color-col = 5.
    WHEN 'E2'. " emphasize2
      ls_scol-color-col = 7.
  ENDCASE.

  INSERT ls_scol INTO TABLE gs_plant-color.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_down_body
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_down_body .

  DATA: lv_tabix TYPE sy-tabix.

  CLEAR gs_stl.
  LOOP AT gt_stl INTO gs_stl.

    lv_tabix = sy-tabix.

    PERFORM set_down_style USING: 'PLANT'  'D',
                                  'SCODE'  'D',
                                  ' '      'E'.

    PERFORM set_down_color USING: 'PLANT'    'P',
                                  'SCODE'    'P',
                                  'SNAME'    'E',
                                  'ADDRESS'  'E2'.

    MODIFY gt_stl FROM gs_stl INDEX lv_tabix
                              TRANSPORTING celltab color.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_down_style
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_down_style  USING pv_field pv_mode.

  DATA: ls_style TYPE lvc_s_styl.

  CLEAR ls_style.

  ls_style-fieldname = pv_field.

  CASE pv_mode.
    WHEN 'D'.
      ls_style-style = cl_gui_alv_grid=>mc_style_disabled.
    WHEN 'E'.
      ls_style-style = cl_gui_alv_grid=>mc_style_enabled.
  ENDCASE.

  INSERT ls_style INTO TABLE gs_stl-celltab.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_down_color
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_down_color  USING pv_field pv_mode.

  DATA: ls_scol TYPE lvc_s_scol.

  CLEAR ls_scol.

  ls_scol-fname = pv_field.

  CASE pv_mode.
    WHEN 'P'. " PK
      ls_scol-color-col = 1.
      ls_scol-color-int = 1.
    WHEN 'E'. " emphasize
      ls_scol-color-col = 5.
    WHEN 'E2'.
      ls_scol-color-col = 7.
  ENDCASE.

  INSERT ls_scol INTO TABLE gs_stl-color.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_up_tbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM handle_up_tbar  USING  po_object TYPE REF TO cl_alv_event_toolbar_set
                            pv_interactive.

  DATA: lv_disabled.

  IF gv_up_md EQ 'D'.
    lv_disabled = abap_true.
  ENDIF.

  _up_tbar : ' '    ' '                        ' '   ' '                  lv_disabled 3  ,
             'UTOG' icon_toggle_display_change ' '   'Display <-> Change' ' '         ' ',
             ' '    ' '                        ' '   ' '                  lv_disabled 3  ,
             'UIRO' icon_insert_row            '추가'  'Add row'            lv_disabled ' ',
             'UDRO' icon_delete_row            '삭제'  'Delete row'         lv_disabled ' ',
             ' '    ' '                        ' '   ' '                  lv_disabled 3  ,
             'USAV' icon_system_save           '저장'  'Save'               lv_disabled ' '.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_down_tbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM handle_down_tbar  USING  po_object TYPE REF TO cl_alv_event_toolbar_set
                              pv_interactive.

  DATA: lv_disabled.

  IF gv_down_md EQ 'D'.
    lv_disabled = abap_true.
  ENDIF.

  _down_tbar : ' '    ' '                        ' '   ' '                  lv_disabled 3  ,
               'DTOG' icon_toggle_display_change ' '   'Display <-> Change' ' '         ' ',
               ' '    ' '                        ' '   ' '                  lv_disabled 3  ,
               'DIRO' icon_insert_row            '추가'  'Add row'            lv_disabled ' ',
               'DDRO' icon_delete_row            '삭제'  'Delete row'         lv_disabled ' ',
               ' '    ' '                        ' '   ' '                  lv_disabled 3  ,
               'DSAV' icon_system_save           '저장'  'Save'               lv_disabled ' '.

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
    WHEN 'UIRO'.
      PERFORM process_up_row USING 'I'.
    WHEN 'UDRO'.
      PERFORM process_up_row USING 'D'.
    WHEN 'UTOG'.
      PERFORM process_up_row USING 'T'.
    WHEN 'USAV'.
      PERFORM save_up_data.
    WHEN 'DIRO'.
      PERFORM process_down_row USING 'I'.
    WHEN 'DDRO'.
      PERFORM process_down_row USING 'D'.
    WHEN 'DTOG'.
      PERFORM process_down_row USING 'T'.
    WHEN 'DSAV'.
      PERFORM save_down_data.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_up_row
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM process_up_row  USING pv_job.

  DATA: lt_row TYPE lvc_t_row,
        ls_row TYPE lvc_s_row.

  CASE pv_job.
    WHEN 'I'.           " Insert

      CLEAR gs_plant.
      PERFORM set_up_style USING: ' ' 'E'.   " 편집모드로 들어간다

      APPEND gs_plant TO gt_plant.

      PERFORM refresh_up_table.

    WHEN 'D'.           " Delete

      CALL METHOD go_up_grid->get_selected_rows
        IMPORTING
          et_index_rows = lt_row.

*-- Check selected
      IF lt_row IS INITIAL.
        MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'. " 행을 선택하세요.
        EXIT.
      ENDIF.

*-- 작업중인 index를 잃지 않기위해 내림차순 정렬
      SORT lt_row BY index DESCENDING.

      LOOP AT lt_row INTO ls_row.

*-- 삭제대상 Data를 별도의 ITAB에 저장
        CLEAR: gs_plant, gs_up_del.
        READ TABLE gt_plant INTO gs_plant INDEX ls_row-index.
        MOVE-CORRESPONDING gs_plant TO gs_up_del.
        APPEND gs_up_del TO gt_up_del.

*-- 선택한 행을 ITAB에서 삭제
        DELETE gt_plant INDEX ls_row-index.

      ENDLOOP.

*-- ALV 갱신
      PERFORM refresh_up_table.

    WHEN 'T'.           " 토글 Edit <-> Display

      CASE gv_up_md.
        WHEN 'E'.
          gv_up_md = 'D'.
          CALL METHOD go_up_grid->set_ready_for_input
            EXPORTING
              i_ready_for_input = 0.
        WHEN 'D'.
          gv_up_md = 'E'.
          CALL METHOD go_up_grid->set_ready_for_input
            EXPORTING
              i_ready_for_input = 1.
      ENDCASE.

  ENDCASE.

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
*& Form save_up_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_up_data .

*-- For Save
  DATA: lt_save   TYPE TABLE OF zc302mt0004,
        ls_save   TYPE zc302mt0004,
        lv_tabix  TYPE sy-tabix,
        lv_answer.

  " Check data ( ALV -> ITAB )
  CALL METHOD go_up_grid->check_changed_data.

  " Move data & Check empty data
  MOVE-CORRESPONDING gt_plant TO lt_save.      " 추가한 것들도 gt_plant에 있으니 이걸 lt_save로

  IF ( lt_save     IS INITIAL ) AND
     ( gt_up_del   IS INITIAL ).                 " 임시로 삭제한 데이터 모아놓은 것들
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'. " 저장된 데이터가 없습니다. - 데이터에 변화가 없음
    EXIT.
  ENDIF.

  " Confirm for save
  PERFORM confirm_for_save CHANGING lv_answer.

  IF lv_answer NE '1'.
    MESSAGE s001 WITH TEXT-e04 DISPLAY LIKE 'E'. " 저장이 취소되었습니다.
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
  IF gt_up_del IS NOT INITIAL.
    DELETE zc302mt0004 FROM TABLE gt_up_del.
    CLEAR gt_up_del.
  ENDIF.

  " Save data
  MODIFY zc302mt0004 FROM TABLE lt_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
    PERFORM set_up_body.
    PERFORM refresh_up_table.
    MESSAGE s001 WITH TEXT-e05. " 저장을 성공하였습니다.
  ELSE.
    MESSAGE s001 WITH TEXT-e06 DISPLAY LIKE 'E'. " 저장을 실패하였습니다.
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
*& Form process_down_row
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM process_down_row  USING pv_job.

  DATA: lt_row TYPE lvc_t_row,
        ls_row TYPE lvc_s_row.

  CASE pv_job.
    WHEN 'I'.               " Insert

      CLEAR gs_stl.
      PERFORM set_down_style USING: ' ' 'E'.

      APPEND gs_stl TO gt_stl.

      PERFORM refresh_down_table.

    WHEN 'D'.               " Delete

      CALL METHOD go_down_grid->get_selected_rows
        IMPORTING
          et_index_rows = lt_row.

      IF lt_row IS INITIAL.
        MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'. " 행을 선택하세요.
        EXIT.
      ENDIF.

      SORT lt_row BY index DESCENDING.

      LOOP AT lt_row INTO ls_row.

        CLEAR: gs_stl, gs_down_del.
        READ TABLE gt_stl INTO gs_stl INDEX ls_row-index.
        MOVE-CORRESPONDING gs_stl TO gs_down_del.
        APPEND gs_down_del TO gt_down_del.

        DELETE gt_stl INDEX ls_row-index.

      ENDLOOP.

      PERFORM refresh_down_table.

    WHEN 'T'.               " Display <-> Edit

      CASE gv_down_md.
        WHEN 'E'.
          gv_down_md = 'D'.
          CALL METHOD go_down_grid->set_ready_for_input
            EXPORTING
              i_ready_for_input = 0.
        WHEN 'D'.
          gv_down_md = 'E'.
          CALL METHOD go_down_grid->set_ready_for_input
            EXPORTING
              i_ready_for_input = 1.
      ENDCASE.

  ENDCASE.

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

  ls_stable-row = abap_true.  " 행 고정하겠다
  ls_stable-col = abap_true.  " 열 고정하겠다

  CALL METHOD go_down_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stable.

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

*-- For Save
  DATA: lt_save   TYPE TABLE OF zc302mt0005,
        ls_save   TYPE zc302mt0005,
        lv_tabix  TYPE sy-tabix,
        lv_answer.

  " Check data ( ALV -> ITAB )
  CALL METHOD go_down_grid->check_changed_data.

  " Move data & Check empty data
  MOVE-CORRESPONDING gt_stl TO lt_save.

  IF ( lt_save      IS INITIAL ) AND
     ( gt_down_del  IS INITIAL ).
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'. " 저장된 데이터가 없습니다.
    EXIT.
  ENDIF.

  " Confirm for save
  PERFORM confirm_for_save CHANGING lv_answer.

  IF lv_answer NE '1'.
    MESSAGE s001 WITH TEXT-e04 DISPLAY LIKE 'E'. " 저장이 취소되었습니다.
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
  IF gt_down_del IS NOT INITIAL.
    DELETE zc302mt0005 FROM TABLE gt_down_del.
    CLEAR gt_down_del.
  ENDIF.

  " Save data
  MODIFY zc302mt0005 FROM TABLE lt_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
    PERFORM set_down_body.
    PERFORM refresh_down_table.
    MESSAGE s001 WITH TEXT-e05. " 저장을 성공하였습니다.
  ELSE.
    MESSAGE s001 WITH TEXT-e06 DISPLAY LIKE 'E'. " 저장을 실패하였습니다.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
