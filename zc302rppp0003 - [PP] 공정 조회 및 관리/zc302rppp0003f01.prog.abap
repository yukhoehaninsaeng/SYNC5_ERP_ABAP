*&---------------------------------------------------------------------*
*& Include          ZC302RPPP0004F01
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

  " 공정 Header 데이터 Setting
  CLEAR gt_header.
  SELECT pcode psdtl bomid plant pname matnr
    INTO CORRESPONDING FIELDS OF TABLE gt_header
    FROM zc302ppt0008
   WHERE pcode IN so_pco
     AND bomid IN so_bom.

  IF gt_header IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'. " 데이터가 존재하지 않습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module INIT_PROCESS_CONTROL OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_process_control OUTPUT.

  " ALV Grid 지정
  PERFORM display_screen.

ENDMODULE.
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

    " Field Catalog 지정
    PERFORM set_field_catalog.

    " Layout 지정
    PERFORM set_layout.

    " 객체 생성
    PERFORM create_object.

    " ALV Toolbar 제외
    PERFORM exclude_toolbar TABLES gt_ui_functions.

    SET HANDLER: lcl_event_handler=>double_click  FOR go_left_grid,
                 lcl_event_handler=>left_toolbar  FOR go_left_grid,
                 lcl_event_handler=>right_toolbar FOR go_right_grid,
                 lcl_event_handler=>user_command  FOR go_left_grid,
                 lcl_event_handler=>user_command  FOR go_right_grid,
                 lcl_event_handler=>top_of_page   FOR go_left_grid.

    PERFORM set_alv_grid.

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
FORM set_left_catalog  USING  pv_key pv_field pv_table pv_just pv_emph.

  gs_lfcat = VALUE #( key       = pv_key
                      fieldname = pv_field
                      ref_table = pv_table
                      just      = pv_just
                      emphasize = pv_emph ).

  APPEND gs_lfcat TO gt_lfcat.
  CLEAR gs_lfcat.

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
FORM set_right_catalog  USING  pv_key pv_field pv_table pv_just pv_emph.

  gs_rfcat = VALUE #( key       = pv_key
                      fieldname = pv_field
                      ref_table = pv_table
                      just      = pv_just
                      emphasize = pv_emph ).

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

  gs_llayo  = VALUE #( zebra      = abap_true
                       cwidth_opt = 'A'
                       sel_mode   = 'D'
                       stylefname = 'CELLTAB'
                       ctab_fname = 'COLOR'
                       grid_title = '공정 Header'
                       smalltitle = abap_true ).

  gs_rlayo  = VALUE #( zebra      = abap_true
                       cwidth_opt = 'A'
                       sel_mode   = 'D'
                       stylefname = 'CELLTAB'
                       ctab_fname = 'COLOR'
                       grid_title = '공정 Item'
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
      extension = 38.

  CREATE OBJECT go_container
    EXPORTING
      repid     = sy-cprog
      dynnr     = sy-dynnr
      side      = go_container->dock_at_left
      extension = 3000.

  CREATE OBJECT go_split_cont
    EXPORTING
      parent  = go_container
      rows    = 1  " 1행
      columns = 2. " 2열

  CALL METHOD go_split_cont->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_left_cont.

  CALL METHOD go_split_cont->get_container
    EXPORTING
      row       = 1
      column    = 2
    RECEIVING
      container = go_right_cont.

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
*& Form handle_double_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM handle_double_click  USING pv_row pv_column.

  CLEAR gs_header.
  READ TABLE gt_header INTO gs_header INDEX pv_row.

  " 공정 header의 공정코드에 따른 공정 Item 데이터 Setting
  PERFORM get_sub_data.

  " 공정 Item의 Celltab & Color 지정
  PERFORM set_right_body.

  " 계획오더 Item의 ITAB -> ALV로 새로고침
  PERFORM refresh_right_table.

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
*& Form handle_left_tbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&      --> ENDMETHOD
*&---------------------------------------------------------------------*
FORM handle_left_tbar  USING  po_object TYPE REF TO cl_alv_event_toolbar_set
                              pv_interactive.

  DATA: lv_disabled.

  " 토글 버튼이 Display mode & Change mode일 때 마다 값이 바뀐다.
  IF gv_left_md EQ 'D'.
    lv_disabled = abap_true.
  ENDIF.

  " 왼쪽 ALV Toolbar 생성
  _left_tbar : ' '    ' '                        ' '    ' '                  lv_disabled 3  ,
               'LTOG' icon_toggle_display_change ' '    'Display <-> Change' ' '         ' ',
               ' '    ' '                        ' '    ' '                  lv_disabled 3  ,
               'LIRO' icon_insert_row            '추가' 'Add row'            lv_disabled ' ',
               'LDRO' icon_delete_row            '삭제' 'Delete row'         lv_disabled ' ',
               ' '    ' '                        ' '    ' '                  lv_disabled 3  ,
               'LSAV' icon_system_save           '저장' 'Save'               lv_disabled ' '.

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

  " 토글 버튼이 Display mode & Change mode에 따라 값이 바뀐다.
  IF gv_right_md EQ 'D'.
    lv_disabled = abap_true.
  ENDIF.

  " 오른쪽 ALV Toolbar 지정
  _right_tbar : ' '    ' '                        ' '    ' '                  lv_disabled 3  ,
                'RTOG' icon_toggle_display_change ' '    'Display <-> Change' ' '         ' ',
                ' '    ' '                        ' '    ' '                  lv_disabled 3  ,
                'RIRO' icon_insert_row            '추가' 'Add row'            lv_disabled ' ',
                'RDRO' icon_delete_row            '삭제' 'Delete row'         lv_disabled ' ',
                ' '    ' '                        ' '    ' '                  lv_disabled 3  ,
                'RSAV' icon_system_save           '저장' 'Save'               lv_disabled ' '.

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

  CLEAR gt_lfcat.
  PERFORM set_left_catalog USING: 'X' 'PCODE' 'ZC302PPT0008' ' ' ' ',
                                  ' ' 'PSDTL' 'ZC302PPT0008' ' ' 'X',
                                  ' ' 'BOMID' 'ZC302PPT0008' ' ' ' ',
                                  ' ' 'PLANT' 'ZC302PPT0008' ' ' ' ',
                                  ' ' 'PNAME' 'ZC302PPT0008' ' ' 'X',
                                  ' ' 'MATNR' 'ZC302PPT0008' ' ' ' '.
  CLEAR gt_rfcat.
  PERFORM set_right_catalog USING: 'X' 'PCODE'  'ZC302PPT0009' ' ' ' ',
                                   'X' 'PSTEP'  'ZC302PPT0009' ' ' ' ',
                                   ' ' 'PSTDT'  'ZC302PPT0009' ' ' 'X',
                                   ' ' 'MATMLT' 'ZC302PPT0009' ' ' ' '.

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

  gs_variant = VALUE #( report  = sy-repid
                        handle = 'ALV1' ).

  CALL METHOD go_left_grid->set_table_for_first_display
    EXPORTING
      is_variant           = gs_variant
      i_save               = 'A'
      i_default            = 'X'
      is_layout            = gs_llayo
      it_toolbar_excluding = gt_ui_functions
    CHANGING
      it_outtab            = gt_header
      it_fieldcatalog      = gt_lfcat.

  gs_variant = VALUE #( handle = 'ALV2' ).

  CALL METHOD go_right_grid->set_table_for_first_display
    EXPORTING
      is_variant           = gs_variant
      i_save               = 'A'
      i_default            = 'X'
      is_layout            = gs_rlayo
      it_toolbar_excluding = gt_ui_functions
    CHANGING
      it_outtab            = gt_item
      it_fieldcatalog      = gt_rfcat.

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
    WHEN 'LIRO'.
      PERFORM process_left_row USING 'I'. " 추가
    WHEN 'LDRO'.
      PERFORM process_left_row USING 'D'. " 삭제
    WHEN 'LTOG'.
      PERFORM process_left_row USING 'T'. " 토글버튼
    WHEN 'LSAV'.
      PERFORM save_left_data.
    WHEN 'RIRO'.
      PERFORM process_right_row USING 'I'. " 추가
    WHEN 'RDRO'.
      PERFORM process_right_row USING 'D'. " 삭제
    WHEN 'RTOG'.
      PERFORM process_right_row USING 'T'. " 토글버튼
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
FORM process_left_row  USING  pv_job.

  DATA: lt_row TYPE lvc_t_row,
        ls_row TYPE lvc_s_row.

  CASE pv_job.
    WHEN 'I'.

      CLEAR gs_header.
      PERFORM set_left_style USING: ' ' 'E'.

      APPEND gs_header TO gt_header.

      PERFORM refresh_left_table.

    WHEN 'D'.

      CALL METHOD go_left_grid->get_selected_rows
        IMPORTING
          et_index_rows = lt_row.

      IF lt_row IS INITIAL.
        MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'. " 행을 선택하세요.
        EXIT.
      ENDIF.

      SORT lt_row BY index DESCENDING.

      LOOP AT lt_row INTO ls_row.

        CLEAR: gs_header, gs_left_del.
        READ TABLE gt_header INTO gs_header INDEX ls_row-index.
        MOVE-CORRESPONDING gs_header TO gs_left_del.
        APPEND gs_left_del TO gt_left_del.

        DELETE gt_header INDEX ls_row-index.

      ENDLOOP.

      PERFORM refresh_left_table.

    WHEN 'T'.

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
*& Form make_display_body
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_body .

  " 공정 Header의 Celltab 및 Color 지정
  PERFORM set_left_body.

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

  CLEAR gs_header.
  LOOP AT gt_header INTO gs_header.

    lv_tabix = sy-tabix.

    PERFORM set_left_style USING: 'PCODE' 'D',
                                  ' '     'E'.

    PERFORM set_left_color USING: 'PCODE' 'P',
                                  'PSDTL' 'E',
                                  'PNAME' 'E'.

    MODIFY gt_header FROM gs_header INDEX lv_tabix
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

  INSERT ls_style INTO TABLE gs_header-celltab.

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
      ls_scol-color-int = 1.
    WHEN 'E'. " emphasize
      ls_scol-color-col = 5.
  ENDCASE.

  INSERT ls_scol INTO TABLE gs_header-color.

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

  CLEAR gs_item.
  LOOP AT gt_item INTO gs_item.

    lv_tabix = sy-tabix.

    PERFORM set_right_style USING: 'PCODE' 'D',
                                   'PSTEP' 'D',
                                   ' '     'E'.

    PERFORM set_right_color USING: 'PCODE' 'P',
                                   'PSTEP' 'P',
                                   'PSTDT' 'E'.

    MODIFY gt_item FROM gs_item INDEX lv_tabix
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

  INSERT ls_style INTO TABLE gs_item-celltab.

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

  INSERT ls_scol INTO TABLE gs_item-color.

ENDFORM..
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
      i_ready_for_input = 0.

  CALL METHOD go_right_grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 0.

  " 문서의 기본 속성(배경색 등)을 설정하는데 사용
  CALL METHOD go_dyndoc_id->initialize_document
    EXPORTING
      background_color = cl_dd_area=>col_textarea. " SAP 시스템에서 정의된 표준 색상으로 지정

  " ALV에서 TOP-OF-PAGE 이번트가 발생할 때 초기화된 동적 문서(go_dynoc_id)를 출력하도록 설정
  CALL METHOD go_left_grid->list_processing_events
    EXPORTING
      i_event_name = 'TOP_OF_PAGE' " 이벤트 이름 지정
      i_dyndoc_id  = go_dyndoc_id. " 이벤트에서 사용할 동적 문서 객체

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
    WHEN 'I'.

      CLEAR gs_item.
      PERFORM set_right_style USING: ' ' 'E'.

      APPEND gs_item TO gt_item.

      PERFORM refresh_right_table.

    WHEN 'D'.

      CALL METHOD go_right_grid->get_selected_rows
        IMPORTING
          et_index_rows = lt_row.

      IF lt_row IS INITIAL.
        MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'. " 행을 선택하세요.
        EXIT.
      ENDIF.

      SORT lt_row BY index DESCENDING.

      LOOP AT lt_row INTO ls_row.

        CLEAR: gs_item, gs_right_del.
        READ TABLE gt_item INTO gs_item INDEX ls_row-index.
        MOVE-CORRESPONDING gs_item TO gs_right_del.
        APPEND gs_right_del TO gt_right_del.

        DELETE gt_item INDEX ls_row-index.

      ENDLOOP.

      PERFORM refresh_right_table.

    WHEN 'T'.

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
*& Form get_sub_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_sub_data .

  CLEAR gt_item.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_item
    FROM zc302ppt0009
   WHERE pcode EQ gs_header-pcode.

  IF gt_item IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'. " 데이터가 존재하지 않습니다.
  ENDIF.

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
  DATA: lt_save   TYPE TABLE OF zc302ppt0008,
        ls_save   TYPE zc302ppt0008,
        lv_tabix  TYPE sy-tabix,
        lv_answer.

  "* Check data ( ALV -> ITAB )
  CALL METHOD go_left_grid->check_changed_data.

  "* Move data & Check empty data
  MOVE-CORRESPONDING gt_header TO lt_save.

  IF ( lt_save     IS INITIAL ) AND
     ( gt_left_del IS INITIAL ).
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
  IF gt_left_del IS NOT INITIAL.
    DELETE zc302ppt0008 FROM TABLE gt_left_del.
    CLEAR gt_left_del.
  ENDIF.

  "* Save data
  MODIFY zc302ppt0008 FROM TABLE lt_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
    PERFORM set_left_body.
    PERFORM refresh_left_table.
    MESSAGE s001 WITH TEXT-g01. " 저장을 성공하였습니다.
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
*& Form save_right_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_right_data .

*-- For Save
  DATA: lt_save   TYPE TABLE OF zc302ppt0009,
        ls_save   TYPE zc302ppt0009,
        lv_tabix  TYPE sy-tabix,
        lv_answer.

  "* Check data ( ALV -> ITAB )
  CALL METHOD go_right_grid->check_changed_data.

  "* Move data & Check empty data
  MOVE-CORRESPONDING gt_item TO lt_save.

  IF ( lt_save      IS INITIAL ) AND
     ( gt_right_del IS INITIAL ).
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
  IF gt_right_del IS NOT INITIAL.
    DELETE zc302ppt0009 FROM TABLE gt_right_del.
    CLEAR gt_right_del.
  ENDIF.

  "* Save data
  MODIFY zc302ppt0009 FROM TABLE lt_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
    PERFORM set_right_body.
    PERFORM refresh_right_table.
    MESSAGE s006. " 저장을 성공하였습니다.
  ELSE.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'. " 저장을 실패하였습니다.
    ROLLBACK WORK.
  ENDIF.

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
         col_value   TYPE REF TO cl_dd_area,
         col_field2  TYPE REF TO cl_dd_area,
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

  _set_top: so_pco lv_text lv_wave lv_text2.
  PERFORM add_row USING lr_dd_table col_field col_value col_field2 col_value2 '공정코드' lv_text lv_wave lv_text2.

  _set_top: so_bom lv_text lv_wave lv_text2.
  PERFORM add_row USING lr_dd_table col_field col_value col_field2 col_value2 'BOM ID' lv_text lv_wave lv_text2.

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

  CLEAR gt_pcode.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_pcode
    FROM zc302ppt0008.

  CLEAR gt_bomid.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_bomid
    FROM zc302ppt0004.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_pcode
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_pcode  USING  pv_gubun.

  DATA : lt_return LIKE TABLE OF ddshretval WITH HEADER LINE,
         lt_dynp   TYPE TABLE OF dynpread   WITH HEADER LINE,
         lv_field  TYPE help_info-dynprofld.

  CASE pv_gubun.
    WHEN 'LOW'.
      lv_field = 'SO_PCO-LOW'.
    WHEN 'HIGH'.
      lv_field = 'SO_PCO-HIGH'.
  ENDCASE.

  _init lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'PCODE' " ALV 에 박히는 값
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = lv_field
      window_title    = 'Process code'
      value_org       = 'S'
    TABLES
      value_tab       = gt_pcode
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_bomid
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_bomid  USING  pv_gubun.

  DATA : lt_return LIKE TABLE OF ddshretval WITH HEADER LINE,
         lt_dynp   TYPE TABLE OF dynpread   WITH HEADER LINE,
         lv_field  TYPE help_info-dynprofld.

  CASE pv_gubun.
    WHEN 'LOW'.
      lv_field = 'SO_BOM-LOW'.
    WHEN 'HIGH'.
      lv_field = 'SO_BOM-HIGH'.
  ENDCASE.

  _init lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BOMID' " ALV 에 박히는 값
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = lv_field
      window_title    = 'BOM ID'
      value_org       = 'S'
    TABLES
      value_tab       = gt_bomid
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
