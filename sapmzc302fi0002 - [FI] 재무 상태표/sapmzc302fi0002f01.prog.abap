*&---------------------------------------------------------------------*
*& Include          SAPMZC302FI0002F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form set_base_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_base_data TABLES pt_excel STRUCTURE alsmex_tabline .

  DATA : ls_excel       TYPE alsmex_tabline,
         lv_gjgrp(20),
         lv_gjgrp_d(20),
         lv_txt20(20),
         lv_dmbtr       TYPE bseg-dmbtr.

  LOOP AT pt_excel INTO ls_excel.
    gs_blsht-gjahr = '2024'.
    CASE ls_excel-col.
      WHEN '0001'.
        IF ls_excel-row = '0010'.
          lv_gjgrp = '자산'.
        ELSEIF ls_excel-row = '0011'.
          lv_gjgrp_d = '유동자산'.
        ELSEIF ls_excel-row = '0014'.
          lv_gjgrp_d = '비유동 자산'.
        ELSEIF ls_excel-row = '0017'.
          lv_gjgrp = '부채'.
        ELSEIF ls_excel-row = '0018'.
          lv_gjgrp_d = '유동 부채'.
        ELSEIF ls_excel-row = '0020'.
          lv_gjgrp_d = '비유동 부채'.
        ELSEIF ls_excel-row = '0021'.
          lv_gjgrp = '자본'.
          lv_gjgrp_d = '자본 세부 항목'.
        ELSEIF ls_excel-row = '0027'.
          lv_gjgrp = '수익'.
          lv_gjgrp_d = '수익 세부 항목'.
        ENDIF.
      WHEN '0002'.
        IF ls_excel-row LT '0011'.
          CONTINUE.
        ENDIF.
        lv_txt20 = ls_excel-value.
      WHEN '0004'.
        IF ls_excel-row LT '0011'.
          CONTINUE.
        ENDIF.
        lv_dmbtr = ls_excel-value.
      WHEN '0005'.
        IF ls_excel-row LT '0011'.
          CONTINUE.
        ENDIF.
        gs_blsht-dmbtr = lv_dmbtr.
        gs_blsht-dmbtr_x = ls_excel-value.
        gs_blsht-gjgrp = lv_gjgrp.
        gs_blsht-gjgrp_d = lv_gjgrp_d.
        gs_blsht-txt20 = lv_txt20.
        gs_blsht-waers = 'KRW'.
        APPEND gs_blsht TO gt_blsht.
        CLEAR : gs_blsht.
    ENDCASE.
  ENDLOOP.
  cl_demo_output=>display( gt_blsht ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_field_catalog  USING pv_field pv_text pv_noout.

  gs_fcat-fieldname = pv_field.
  gs_fcat-coltext   = pv_text.
  gs_fcat-no_out    = pv_noout.

  CASE pv_field.
    WHEN 'DMBTR' OR 'DMBTR_X'.
      gs_fcat-datatype = 'CURR'.
      gs_fcat-cfieldname = 'WAERS'.
      gs_fcat-outputlen = 35.
      gs_fcat-do_sum = abap_true.
    WHEN OTHERS.
      gs_fcat-outputlen = 40.
  ENDCASE.

  APPEND gs_fcat TO gt_fcat.
  CLEAR gs_fcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_display .
  IF go_tree IS NOT BOUND AND
     gt_list_commentary IS INITIAL.

    PERFORM init_tree.
    PERFORM define_hierarchy_header CHANGING gs_hierhdr.
    PERFORM build_comment USING gt_list_commentary.
    PERFORM define_field_catalog.
    PERFORM create_hierarchy.
    PERFORM fill_column_tree.

  ELSE.

    PERFORM init_tree.
    PERFORM define_hierarchy_header CHANGING gs_hierhdr.
    PERFORM define_field_catalog.
    PERFORM create_hierarchy.
    PERFORM fill_column_tree.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_filename
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_filename .
  " upload할 파일을 찾음
  DATA : lt_files  TYPE filetable,
         ls_files  LIKE LINE OF lt_files,
         lv_filter TYPE string,
         lv_path   TYPE string,
         lv_rc     TYPE i.

  CONCATENATE cl_gui_frontend_services=>filetype_excel
              'Excel 통합 문서(*.XLSX)|*.XLSX|'
              INTO lv_filter.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = 'File open'
      file_filter             = lv_filter
      initial_directory       = lv_path
    CHANGING
      file_table              = lt_files
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  CHECK sy-subrc EQ 0.
  ls_files = VALUE #( lt_files[ 1 ] OPTIONAL ).

  gv_fpath = ls_files-filename.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form excel_upload
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM excel_upload .

  TYPES: truxs_t_text_data(4096)   TYPE c OCCURS 0.

  DATA: lt_raw_data  TYPE truxs_t_text_data,
        lt_excel     LIKE TABLE OF alsmex_tabline WITH HEADER LINE,
        lv_index     LIKE sy-tabix,
        lv_waers     TYPE bkpf-waers,
        lv_dmbtr(20).

  FIELD-SYMBOLS:  <field>.

  IF gv_fpath IS INITIAL.
    MESSAGE s001 WITH 'Upload 할 파일을 선택하세요' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  CLEAR : lt_excel, lv_index.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = gv_fpath
      i_begin_col             = 1
      i_begin_row             = 1
      i_end_col               = 100
      i_end_row               = 50000
    TABLES
      intern                  = lt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc = 1.
    MESSAGE s001(k5) WITH TEXT-e01.
    STOP.
  ELSEIF sy-subrc <> 0.
    MESSAGE s001(k5) WITH TEXT-e02.
    STOP.
  ENDIF.

  CHECK NOT ( lt_excel[] IS INITIAL ).

  SORT lt_excel BY row col.
*  cl_demo_output=>display( lt_excel[] ).
  PERFORM set_base_data TABLES lt_excel.

  CALL METHOD go_tree->free.
  CALL METHOD go_container->free.

  CLEAR : go_tree, go_container.

  LEAVE TO SCREEN 0.

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

  IF gt_blsht IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_tree
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_tree .

  CREATE OBJECT go_container
    EXPORTING
      repid     = sy-repid
      dynnr     = sy-dynnr
      side      = go_container->dock_at_left
      extension = 5000.

  CREATE OBJECT go_tree
    EXPORTING
      parent              = go_container
      node_selection_mode = cl_gui_column_tree=>node_sel_mode_multiple
      item_selection      = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form define_hierarchy_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_HIERHDR
*&---------------------------------------------------------------------*
FORM define_hierarchy_header  CHANGING pv_hierhdr TYPE treev_hhdr.

  pv_hierhdr-heading = '계정 과목'.
  pv_hierhdr-tooltip = '계정 과목'.
  pv_hierhdr-width = 50.
  pv_hierhdr-width_pix = space.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_comment
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST_COMMENTARY
*&---------------------------------------------------------------------*
FORM build_comment  USING pt_list_commentary TYPE slis_t_listheader.

  DATA: ls_line TYPE slis_listheader.

  CLEAR ls_line.
  ls_line-typ = 'H'. " High font
  ls_line-info = '(주) SYNCYOUNG 요약 재무상태표'.
  APPEND ls_line TO pt_list_commentary.

  CLEAR ls_line.
  ls_line-typ = 'S'. " Small font
  ls_line-key = '회사 코드: '.
  ls_line-info = '1000 SYNCYOUNG'.
  APPEND ls_line TO pt_list_commentary.

  CLEAR ls_line.
  ls_line-typ = 'S'.
  ls_line-key = '회계연도: '.
  ls_line-info = '2024'.
  APPEND ls_line TO pt_list_commentary.

  gs_variant-report = sy-repid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form define_field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM define_field_catalog .

  CLEAR : gt_fcat, gs_fcat.
  PERFORM set_field_catalog USING : 'TXT20'   '계정 과목'  ' ',
                                    'DMBTR'   '당기 금액'  ' ',
                                    'DMBTR_X' '전기 금액'  ' ',
                                    'WAERS'   '통화'     ' '.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_hierarchy
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_hierarchy .

  CALL METHOD go_tree->set_table_for_first_display
    EXPORTING
      is_variant          = gs_variant
      i_save              = 'A'
      i_default           = 'X'
      is_hierarchy_header = gs_hierhdr
      it_list_commentary  = gt_list_commentary
*     i_logo              = 'ENJOYSAP_LOGO'
      i_background_id     = 'SAP_LOGO_DEMO1'  " 'TRVPICTURE18'
    CHANGING
      it_outtab           = gt_outtab
      it_fieldcatalog     = gt_fcat.

  " Top of page 높이 조정
  CALL METHOD go_tree->set_splitter_row_height
    EXPORTING
      i_height = 20.

  CALL METHOD go_tree->get_registered_events
    IMPORTING
      events = gt_events.

  gs_event-eventid = cl_gui_column_tree=>eventid_item_context_menu_req.
  APPEND gs_event TO gt_events.

  CALL METHOD go_tree->set_registered_events
    EXPORTING
      events = gt_events.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_column_tree
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_column_tree .

  DATA: lv_node_text   TYPE lvc_value,
        lv_gjgrp_key   TYPE lvc_nkey,
        lv_root_key    TYPE lvc_nkey,
        lv_partner_key TYPE lvc_nkey,
        lv_gjgrp_d_key TYPE lvc_nkey,
        lv_txt20_key   TYPE lvc_nkey,
        lt_layout_item TYPE lvc_t_layi,
        ls_layout      TYPE lvc_s_layn,
        lv_sak_start   TYPE lvc_nkey.

  DATA : lt_node_key  TYPE lvc_t_nkey.

*  SORT gt_blsht BY gjahr gjgrp DESCENDING.

  LOOP AT gt_blsht INTO gs_blsht.

    " Root
    ON CHANGE OF gs_blsht-gjgrp.
      CLEAR ls_layout.
*-- 하위에 Level 정보가 더 있다면 Folder 속성 적용 ------------------*
      ls_layout-isfolder = 'X'.
      ls_layout-n_image  = '@06@'.
      ls_layout-exp_image = '@07@'.
*--------------------------------------------------------------------*
      lv_node_text = gs_blsht-gjgrp.

      CALL METHOD go_tree->add_node
        EXPORTING
          i_relat_node_key = lv_root_key
          i_relationship   = cl_gui_column_tree=>relat_last_child
          i_node_text      = lv_node_text
          is_node_layout   = ls_layout
*         is_outtab_line   = gs_blsht
        IMPORTING
          e_new_node_key   = lv_gjgrp_d_key.

      IF lv_sak_start IS INITIAL.
        lv_sak_start = lv_gjgrp_d_key.
      ENDIF.

    ENDON.

    IF lv_sak_start IS NOT INITIAL.
      PERFORM create_item_layouts CHANGING lt_layout_item.
    ENDIF.

    " LEVEL 1
    ON CHANGE OF gs_blsht-gjgrp_d.
      lv_node_text = gs_blsht-gjgrp_d.

      CALL METHOD go_tree->add_node
        EXPORTING
          i_relat_node_key = lv_gjgrp_d_key
          i_relationship   = cl_gui_column_tree=>relat_last_child
          i_node_text      = lv_node_text
          is_node_layout   = ls_layout
        IMPORTING
          e_new_node_key   = lv_txt20_key.

      PERFORM create_item_layouts CHANGING lt_layout_item.
    ENDON.

    " Leaf
    IF lv_txt20_key IS NOT INITIAL.

      lv_node_text = gs_blsht-txt20.

      CALL METHOD go_tree->add_node
        EXPORTING
          i_relat_node_key = lv_txt20_key
          i_relationship   = cl_gui_column_tree=>relat_last_child
          i_node_text      = lv_node_text
          is_outtab_line   = gs_blsht
        IMPORTING
          e_new_node_key   = lv_partner_key.

      PERFORM create_item_layouts CHANGING lt_layout_item.
    ENDIF.

    IF lv_gjgrp_d_key IS NOT INITIAL.
      CALL METHOD go_tree->expand_node
        EXPORTING
          i_node_key       = lv_gjgrp_d_key
          i_expand_subtree = abap_true.
    ENDIF.

  ENDLOOP.

  IF lv_sak_start IS NOT INITIAL.
    CALL METHOD go_tree->expand_node
      EXPORTING
        i_node_key       = lv_sak_start
        i_expand_subtree = abap_true.
  ENDIF.

  CALL METHOD : go_tree->update_calculations,
                go_tree->frontend_update,
                cl_gui_cfw=>flush.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_item_layouts
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_LAYOUT_ITEM
*&---------------------------------------------------------------------*
FORM create_item_layouts  CHANGING pt_item_layout TYPE lvc_t_layi.

  DATA: ls_item_layout TYPE lvc_s_layi.

  CLEAR pt_item_layout.
  LOOP AT gt_fcat INTO gs_fcat.
    CLEAR ls_item_layout.
    IF gs_fcat-no_out EQ space.
      APPEND ls_item_layout TO pt_item_layout.
    ENDIF.
  ENDLOOP.

  CLEAR ls_item_layout.
  ls_item_layout-fieldname = go_tree->c_hierarchy_column_name.
  APPEND ls_item_layout TO pt_item_layout.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form free_tree
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM free_tree .
  CALL METHOD : go_tree->free, go_container->free.
  FREE : go_container, go_tree.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_folder
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_folder .

  DATA: lv_answer(5).

  _popup_to_confirm TEXT-q01 '다운로드' '취소' lv_answer.

  IF lv_answer NE 1 .
    EXIT.
  ENDIF.

  IF pfolder IS NOT INITIAL.
    initialfolder = pfolder.
  ELSE.
    CALL METHOD cl_gui_frontend_services=>get_temp_directory
      CHANGING
        temp_dir             = initialfolder
      EXCEPTIONS
        cntl_error           = 1
        error_no_gui         = 2
        not_supported_by_gui = 3
        OTHERS               = 4.
  ENDIF.

  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title         = '저장할 폴더'
      initial_folder       = initialfolder
    CHANGING
      selected_folder      = pickedfolder
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
  IF sy-subrc = 0.
    pfolder = pickedfolder.
  ELSE.
    MESSAGE TEXT-t03 TYPE 'I' DISPLAY LIKE 'W'.
    EXIT.
  ENDIF.

  IF pfolder IS INITIAL.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form pdf_download
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM pdf_download .

  DATA : lv_rc    TYPE i.

*-- File name
  CLEAR gv_temp_filename.
  CONCATENATE pfolder '\' '요약_재무상태표' '.XLS'
              INTO gv_temp_filename.

  gv_form = 'ZC302_BLSHT'.
  PERFORM download_template   USING gv_form gv_temp_filename.
  PERFORM open_excel_template USING gv_form.
  PERFORM fill_excel_line.

*-- 기본적으로 Sheet 1을 보여주도록 셋팅
  CALL METHOD OF excel 'SHEETS' = sheet EXPORTING #1 = 1.
  CALL METHOD OF sheet 'SELECT' NO FLUSH.

*-- 모두 출력후 맨윗칸으로 커서 이동
  CALL METHOD OF excel 'Cells' = cell
    EXPORTING
      #1 = 1
      #2 = 1.

  CALL METHOD OF cell 'Select' .

  SET PROPERTY OF excel 'VISIBLE' = 1 . "엑셀 데이타를 다 뿌리고나서 보여줌


  PERFORM convert_to_pdf.


  MESSAGE s001 WITH TEXT-s01.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form download_template
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_FORM
*&      --> GV_TEMP_FILENAME
*&---------------------------------------------------------------------*
FORM download_template  USING p_zform p_filename.

  DATA : wwwdata_item LIKE wwwdatatab,
         rc           TYPE i.

  gv_file = p_filename.

  CALL FUNCTION 'WS_FILE_DELETE'
    EXPORTING
      file   = gv_file
    IMPORTING
      return = rc.

  IF rc = 0 OR rc = 1.
  ELSE.
    MESSAGE e001  WITH '임시파일 초기화 실패.'
                       '이전에 Excel에서 자료를 OPEN하였는지 확인.'.
  ENDIF.

  SELECT SINGLE * FROM wwwdata
    INTO CORRESPONDING FIELDS OF wwwdata_item
   WHERE objid = p_zform.

  CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
    EXPORTING
      key         = wwwdata_item
      destination = gv_file.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form open_excel_template
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_FORM
*&---------------------------------------------------------------------*
FORM open_excel_template  USING p_zform.

  IF excel IS INITIAL.
    CREATE OBJECT excel 'EXCEL.APPLICATION'.
  ENDIF.

  IF sy-subrc NE 0.
    MESSAGE i001 WITH sy-msgli.
  ENDIF.

  CALL METHOD OF excel 'WORKBOOKS' = workbook .
  SET PROPERTY OF excel 'VISIBLE' = 0 .

  CALL METHOD OF workbook 'OPEN' EXPORTING #1 = gv_file.

*-- Sheet에대한 설정을 할때 사용된다.











  GET PROPERTY OF : workbook    'Application' = application,
                    application 'ActiveSheet' = activesheet.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_excel_line
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_excel_line .

  DATA : lv_dmbtr   TYPE bseg-dmbtr,
         lv_dmbtr_x TYPE bseg-dmbtr,
         lv_date    TYPE sy-datum.

  lv_date = sy-datum.
  PERFORM fill_cells USING 7 2 lv_date.
  LOOP AT gt_blsht INTO gs_blsht.
    CASE gs_blsht-txt20.
      WHEN '매출채권 및 기타 채권'.
        PERFORM fill_cells USING 11 4 gs_blsht-dmbtr.
        PERFORM fill_cells USING 11 5 gs_blsht-dmbtr_x.
        PERFORM fill_cells USING 11 8 gs_blsht-waers.
      WHEN '재고자산'.
        PERFORM fill_cells USING 12 4 gs_blsht-dmbtr.
        PERFORM fill_cells USING 12 5 gs_blsht-dmbtr_x.
        PERFORM fill_cells USING 12 8 gs_blsht-waers.
      WHEN '기타 유동 자산'.
        PERFORM fill_cells USING 13 4 gs_blsht-dmbtr.
        PERFORM fill_cells USING 13 5 gs_blsht-dmbtr_x.
        PERFORM fill_cells USING 13 8 gs_blsht-waers.
      WHEN '유형 자산'.
        PERFORM fill_cells USING 14 4 gs_blsht-dmbtr.
        PERFORM fill_cells USING 14 5 gs_blsht-dmbtr_x.
        PERFORM fill_cells USING 14 8 gs_blsht-waers.
      WHEN '무형 자산'.
        PERFORM fill_cells USING 15 4 gs_blsht-dmbtr.
        PERFORM fill_cells USING 15 5 gs_blsht-dmbtr_x.
        PERFORM fill_cells USING 15 8 gs_blsht-waers.
      WHEN '기타 비유동 자산'.
        PERFORM fill_cells USING 16 4 gs_blsht-dmbtr.
        PERFORM fill_cells USING 16 5 gs_blsht-dmbtr_x.
        PERFORM fill_cells USING 16 8 gs_blsht-waers.
      WHEN '매입 채무'.
        PERFORM fill_cells USING 18 4 gs_blsht-dmbtr.
        PERFORM fill_cells USING 18 5 gs_blsht-dmbtr_x.
        PERFORM fill_cells USING 18 8 gs_blsht-waers.
      WHEN '기타 유동 부채'.
        PERFORM fill_cells USING 19 4 gs_blsht-dmbtr.
        PERFORM fill_cells USING 19 5 gs_blsht-dmbtr_x.
        PERFORM fill_cells USING 19 8 gs_blsht-waers.
      WHEN '기타 비유동 부채'.
        PERFORM fill_cells USING 20 4 gs_blsht-dmbtr.
        PERFORM fill_cells USING 20 5 gs_blsht-dmbtr_x.
        PERFORM fill_cells USING 20 8 gs_blsht-waers.
      WHEN '자본 잉여금'.
        PERFORM fill_cells USING 22 4 gs_blsht-dmbtr.
        PERFORM fill_cells USING 22 5 gs_blsht-dmbtr_x.
        PERFORM fill_cells USING 22 8 gs_blsht-waers.
      WHEN '이익 잉여금'.
        PERFORM fill_cells USING 23 4 gs_blsht-dmbtr.
        PERFORM fill_cells USING 23 5 gs_blsht-dmbtr_x.
        PERFORM fill_cells USING 23 8 gs_blsht-waers.
      WHEN '기타 포괄 손익 누계액'.
        PERFORM fill_cells USING 24 4 gs_blsht-dmbtr.
        PERFORM fill_cells USING 24 5 gs_blsht-dmbtr_x.
        PERFORM fill_cells USING 24 8 gs_blsht-waers.
      WHEN '기타 자본 항목'.
        PERFORM fill_cells USING 25 4 gs_blsht-dmbtr.
        PERFORM fill_cells USING 25 5 gs_blsht-dmbtr_x.
        PERFORM fill_cells USING 25 8 gs_blsht-waers.
      WHEN '소수 주주 지분'.
        PERFORM fill_cells USING 26 4 gs_blsht-dmbtr.
        PERFORM fill_cells USING 26 5 gs_blsht-dmbtr_x.
        PERFORM fill_cells USING 26 8 gs_blsht-waers.
      WHEN '매출액'.
        PERFORM fill_cells USING 28 4 gs_blsht-dmbtr.
        PERFORM fill_cells USING 28 5 gs_blsht-dmbtr_x.
        PERFORM fill_cells USING 28 8 gs_blsht-waers.
      WHEN '영업 이익'.
        PERFORM fill_cells USING 29 4 gs_blsht-dmbtr.
        PERFORM fill_cells USING 29 5 gs_blsht-dmbtr_x.
        PERFORM fill_cells USING 29 8 gs_blsht-waers.
      WHEN '당기 순이익'.
        PERFORM fill_cells USING 30 4 gs_blsht-dmbtr.
        PERFORM fill_cells USING 30 5 gs_blsht-dmbtr_x.
        PERFORM fill_cells USING 30 8 gs_blsht-waers.
      WHEN '지배 주주 지분 순이익'.
        PERFORM fill_cells USING 31 4 gs_blsht-dmbtr.
        PERFORM fill_cells USING 31 5 gs_blsht-dmbtr_x.
        PERFORM fill_cells USING 31 8 gs_blsht-waers.
      WHEN '소수 주주 지분 순이익'.
        PERFORM fill_cells USING 32 4 gs_blsht-dmbtr.
        PERFORM fill_cells USING 32 5 gs_blsht-dmbtr_x.
        PERFORM fill_cells USING 32 8 gs_blsht-waers.
      WHEN '주당 이익'.
        PERFORM fill_cells USING 33 4 gs_blsht-dmbtr.
        PERFORM fill_cells USING 33 5 gs_blsht-dmbtr_x.
        PERFORM fill_cells USING 33 8 gs_blsht-waers.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form convert_to_pdf
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM convert_to_pdf .

  DATA lv_rc TYPE i.

  CLEAR gv_temp_filename_pdf.
  CONCATENATE pfolder '\' '요약_재무상태표' '.PDF'
              INTO gv_temp_filename_pdf.

  GET PROPERTY OF excel 'Workbooks' = workbook
    EXPORTING #1 = 1.

  CALL METHOD OF workbook 'ExportAsFixedFormat'
    EXPORTING
      #1 = '0'
      #2 = gv_temp_filename_pdf.

  CALL METHOD OF workbook 'Close'
    EXPORTING
      #1 = 0.

  CALL METHOD OF excel 'Quit'.

  CALL METHOD cl_gui_frontend_services=>file_delete
    EXPORTING
      filename = CONV #( gv_temp_filename )
    CHANGING
      rc       = lv_rc.

  CALL METHOD OF workbook 'ExportAsFixedFormat'
    EXPORTING
      #1 = 0
      #2 = gv_temp_filename_pdf.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_cells
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_7
*&      --> P_2
*&      --> LV_DATE
*&---------------------------------------------------------------------*
FORM fill_cells  USING i j val.

  CALL METHOD OF excel 'CELLS' = cell
    EXPORTING
      #1 = i  " 행
      #2 = j. " 열

  SET PROPERTY OF cell 'VALUE' = val.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form template_download
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM template_download .

  DATA : lv_msg(100).

*-- Call windows browser
  CLEAR pfolder.
  PERFORM get_browser_info.

  IF pfolder IS INITIAL.
    EXIT.
  ENDIF.

  gv_form = 'ZC302_BLSHT'.
  PERFORM download_template USING gv_form '요약_재무상태표_템플릿.XLS'.

  MESSAGE s001 WITH TEXT-s02.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_browser_info
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_browser_info .

  IF pfolder IS NOT INITIAL.
    initialfolder = pfolder.
  ELSE.
    CALL METHOD cl_gui_frontend_services=>get_temp_directory
      CHANGING
        temp_dir = initialfolder.
  ENDIF.

  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title    = 'Download path'
      initial_folder  = initialfolder
    CHANGING
      selected_folder = pickedfolder.

  IF sy-subrc = 0.
    pfolder = pickedfolder.
  ELSE.
    MESSAGE i001 WITH TEXT-e05 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

ENDFORM.
