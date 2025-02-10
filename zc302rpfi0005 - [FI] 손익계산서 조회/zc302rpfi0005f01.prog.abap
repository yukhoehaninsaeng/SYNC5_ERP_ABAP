*&---------------------------------------------------------------------*
*& Include          ZC302RPFI0005F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form set_init_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_init_value .

  pa_buk = '1000'.
  pa_gja = '2024'.

  CLEAR so_mon.
  so_mon-sign = 'I'.
  so_mon-option = 'EQ'.
  so_mon-low = '01'.
  so_mon-high = '06'.
  APPEND so_mon.

  pa_butxt = 'SYNCYOUNG'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_selection_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_selection_screen .

  LOOP AT SCREEN.

    CASE screen-group1.
      WHEN 'BUK'.
        screen-input = 0.
        MODIFY SCREEN.
    ENDCASE.

  ENDLOOP.


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

*-- 손익계산서 -  전표 item data
  CLEAR : gs_body.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_body
    FROM zc302fit0008
    ORDER BY  saknr ASCENDING.


  IF gt_body IS INITIAL.
    MESSAGE s001 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  PERFORM set_total_rate.

*  cl_demo_output=>display( gt_body ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET PF-STATUS 'MENU100'.
  SET TITLEBAR 'TITLE100'.

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
*
*  IF go_container IS NOT BOUND.
*
*    CLEAR gs_fcat.
*    PERFORM set_fieldcat USING : ' ' 'HKONT' '계정과목명' 'C' ' ' '1'.
*    PERFORM set_layout.
*    PERFORM exclude_button TABLES gt_ui_functions.
*    PERFORM create_object_.
*
*    gs_variant = sy-repid.
*    gs_variant = 'ALV1'.
*
*    CALL METHOD go_alv_grid->set_table_for_first_display
*      EXPORTING
*        is_variant           = gs_variant
*        i_save               = 'A'
*        i_default            = 'X'
*        is_layout            = gs_layout
*        it_toolbar_excluding = gt_ui_functions
*      CHANGING
*        it_outtab            = gt_body
*        it_fieldcatalog      = gt_fcat.
*
*
*
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_fieldcat  USING   pv_key pv_field pv_table pv_just pv_emph pv_pos.

  gs_fcat-key = pv_key.
  gs_fcat-fieldname = pv_field.
  gs_fcat-coltext = pv_table.
  gs_fcat-just = pv_just.
  gs_fcat-emphasize = pv_emph.
  gs_fcat-col_pos = pv_pos.

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

  gs_layout-zebra      = 'X'.
  gs_layout-cwidth_opt = 'A'.
  gs_layout-sel_mode   = 'D'.


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
*& Form create_object_
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_object_ .

  CREATE OBJECT go_container
    EXPORTING
      side      = go_container->dock_at_left
      extension = 5000.


  CREATE OBJECT go_alv_grid
    EXPORTING
      i_parent = go_container.


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
      side      = go_container->dock_at_bottom
      extension = 5000.

  CREATE OBJECT go_tree
    EXPORTING
      parent              = go_container
      node_selection_mode = cl_gui_column_tree=>node_sel_mode_multiple
      item_selection      = 'X'
      no_html_header      = pa_check.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form define_hierarchy_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_HIERHDR
*&---------------------------------------------------------------------*
FORM define_hierarchy_header   CHANGING pv_hierhdr TYPE treev_hhdr.

  pv_hierhdr-heading = '계정과목'.
  pv_hierhdr-tooltip = '계정과목'.
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
  ls_line-info = '(주) SYNCYOUNG 손익계산서' .
  APPEND ls_line TO pt_list_commentary.

  CLEAR ls_line.
  ls_line-typ = 'S'. " Small font
  ls_line-key = '회사코드 : '.
  ls_line-info = '1000  SYNCYOUNG'.
  APPEND ls_line TO pt_list_commentary.

  CLEAR ls_line.
  ls_line-typ = 'S'.
  ls_line-key = '회계연도 : '.
  ls_line-info = pa_gja.
  APPEND ls_line TO pt_list_commentary.

  CLEAR ls_line.
  ls_line-typ = 'S'.
  ls_line-key = '회계월 : '.
  ls_line-info = so_mon-low && '　~　' && so_mon-high.
  APPEND ls_line TO pt_list_commentary.


*  CLEAR ls_line.
*  ls_line-typ = 'A'. " Italic font
*  ls_line-info = 'SYNC-5 Class 3'.
*  APPEND ls_line TO pt_list_commentary.

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
  PERFORM set_field_catalog USING : "'HKONT' '계정과목'  ' ',
                                    'CPRICE' '당기'   ' ',
                                    'PPRICE' '전기'  ' ',
                                    'WAERS' '통화'  ' ',
                                    'TORAT' '전년대비증감률' ' '.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_field_catalog   USING pv_field pv_text pv_noout.

  gs_fcat-fieldname = pv_field.
  gs_fcat-coltext   = pv_text.
  gs_fcat-no_out    = pv_noout.

  CASE pv_field.
    WHEN 'CPRICE' OR 'PPRICE'.
      gs_fcat-cfieldname = 'WAERS'.
      gs_fcat-outputlen = 35.
      gs_fcat-do_sum    = abap_true.
      gs_fcat-ref_table = 'ZC302FIT0008'.
    WHEN 'TORAT'.
      gs_fcat-outputlen = 20.
  ENDCASE.

  APPEND gs_fcat TO gt_fcat.
  CLEAR gs_fcat.

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
*     i_logo              = gv_logo
      i_background_id     = '' " 'SIWB_WALLPAPER'  " 'TRVPICTURE18'
    CHANGING
      it_outtab           = gt_outtab
      it_fieldcatalog     = gt_fcat.

*-- Top of page 높이 조정
  CALL METHOD go_tree->set_splitter_row_height
    EXPORTING
      i_height = 22.

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
        lv_root_key    TYPE lvc_nkey,  "루트? 노드키
        lv_sonik_key   TYPE lvc_nkey, "계정그룹 노드키
        lv_gjctg_key   TYPE lvc_nkey, "계정분류 노드키
        lv_gjdet_key   TYPE lvc_nkey, "계정분류 노드키
        lv_body_key    TYPE lvc_nkey,  "노트키
        lt_layout_item TYPE lvc_t_layi, "
        ls_layout      TYPE lvc_s_layn,
        lv_sonik_start TYPE lvc_nkey,
        lv_txt_key     TYPE lvc_nkey.

  DATA : lt_node_key  TYPE lvc_t_nkey.

  SORT gt_body BY gjctg saknr.

  LOOP AT gt_body INTO gs_body.
    " 당기순이익 (1번)
    ON CHANGE OF gs_body-sonik.
      CLEAR ls_layout.
*-- 하위에 Level 정보가 더 있다면 Folder 속성 적용 ------------------*
      ls_layout-isfolder = 'X'.
      ls_layout-n_image  = '@FN@'.
      ls_layout-exp_image = '@FO@'.

*--------------------------------------------------------------------*
      lv_node_text =  gs_body-sonik.

      CALL METHOD go_tree->add_node
        EXPORTING
          i_relat_node_key = lv_root_key
          i_relationship   = cl_gui_column_tree=>relat_last_child
          i_node_text      = lv_node_text
          is_node_layout   = ls_layout
*         is_outtab_line   = gs_body
        IMPORTING
          e_new_node_key   = lv_sonik_key.

      IF lv_sonik_start IS INITIAL .
        lv_sonik_start = lv_sonik_key.
      ENDIF.
    ENDON.

*    IF lv_sonik_key IS NOT INITIAL .
    PERFORM create_item_layouts CHANGING lt_layout_item.
*    ENDIF.
*--------------------------------------------------------------------*
    "계정카테고리 (2번)
    ON CHANGE OF gs_body-gjctg.
      lv_node_text =  gs_body-gjctg.


      CALL METHOD go_tree->add_node
        EXPORTING
          i_relat_node_key = lv_sonik_key
          i_relationship   = cl_gui_column_tree=>relat_last_child
          i_node_text      = lv_node_text
          is_node_layout   = ls_layout
        IMPORTING
          e_new_node_key   = lv_gjctg_key.
    ENDON.

    IF lv_gjctg_key IS NOT INITIAL .
      PERFORM create_item_layouts CHANGING lt_layout_item.
    ENDIF.
*--------------------------------------------------------------------*
    "계정소분류 (3번)
    IF gs_body-gjdet IS NOT INITIAL.


      ON CHANGE OF gs_body-gjdet.
        lv_node_text =  gs_body-gjdet.

        CALL METHOD go_tree->add_node
          EXPORTING
            i_relat_node_key = lv_gjctg_key
            i_relationship   = cl_gui_column_tree=>relat_last_child
            i_node_text      = lv_node_text
            is_node_layout   = ls_layout
          IMPORTING
            e_new_node_key   = lv_gjdet_key.
      ENDON.

*    IF lv_gjdet_key IS NOT INITIAL .
      PERFORM create_item_layouts CHANGING lt_layout_item.
*    ENDIF.
*--------------------------------------------------------------------*

*-- 최하위 노드
*    ON CHANGE OF gs_body-saknr.
      lv_node_text = gs_body-saknr && '　' && gs_body-txt50.

      CALL METHOD go_tree->add_node
        EXPORTING
          i_relat_node_key = lv_gjdet_key
          i_relationship   = cl_gui_column_tree=>relat_last_child
          i_node_text      = lv_node_text
          is_outtab_line   = gs_body
        IMPORTING
          e_new_node_key   = lv_txt_key.
*          e_new_node_key   = lv_gjctg_key.

*    ENDON.
      PERFORM create_item_layouts CHANGING lt_layout_item.
*

      CALL METHOD go_tree->expand_node
        EXPORTING
          i_node_key       = lv_sonik_key
          i_expand_subtree = abap_true.
**********************************************************************
    ELSE.
*        ON CHANGE OF gs_body-gjdet.
*      lv_node_text =  gs_body-gjdet.
*
*      CALL METHOD go_tree->add_node
*        EXPORTING
*          i_relat_node_key = lv_gjctg_key
*          i_relationship   = cl_gui_column_tree=>relat_last_child
*          i_node_text      = lv_node_text
*          is_node_layout   = ls_layout
*        IMPORTING
*          e_new_node_key   = lv_gjdet_key.
*    ENDON.
*
**    IF lv_gjdet_key IS NOT INITIAL .
*      PERFORM create_item_layouts CHANGING lt_layout_item.
**    ENDIF.
*--------------------------------------------------------------------*

*-- 최하위 노드
*    ON CHANGE OF gs_body-saknr.
      lv_node_text = gs_body-saknr && '　' && gs_body-txt50.

      CALL METHOD go_tree->add_node
        EXPORTING
          i_relat_node_key = lv_gjctg_key
          i_relationship   = cl_gui_column_tree=>relat_last_child
          i_node_text      = lv_node_text
          is_outtab_line   = gs_body
        IMPORTING
          e_new_node_key   = lv_txt_key.
*          e_new_node_key   = lv_gjctg_key.

*    ENDON.
      PERFORM create_item_layouts CHANGING lt_layout_item.
*

      CALL METHOD go_tree->expand_node
        EXPORTING
          i_node_key       = lv_sonik_key
          i_expand_subtree = abap_true.
    ENDIF.

  ENDLOOP.


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
FORM create_item_layouts   CHANGING pt_item_layout TYPE lvc_t_layi.

  DATA: ls_item_layout TYPE lvc_s_layi.

  CLEAR pt_item_layout.
  LOOP AT gt_fcat INTO gs_fcat.
    CLEAR ls_item_layout.
    IF gs_fcat-no_out EQ space.
      ls_item_layout-fieldname = gs_fcat-fieldname.
      APPEND ls_item_layout TO pt_item_layout.
    ENDIF.
  ENDLOOP.

  CLEAR ls_item_layout.
  ls_item_layout-fieldname = go_tree->c_hierarchy_column_name.
  APPEND ls_item_layout TO pt_item_layout.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_gtbody
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_gtbody  USING  p_bukrs p_gjahr p_gjgrp  p_saknr  p_gjblu
                        p_txt50 p_cprice p_pprice p_waers.
*"   bukrs ghahr  gjgrp saknr     gjblu   txt50      cprice      pprice      waers
*  CLEAR: gs_body.
*  gs_body-bukrs = p_bukrs.
*  gs_body-gjgrp = p_gjgrp.
*  gs_body-saknr = p_saknr.
*  gs_body-gjblu = p_gjblu.
*  gs_body-txt50 = p_txt50.
*  gs_body-cprice = p_cprice.
*  gs_body-pprice = p_pprice.
*  gs_body-waers = p_waers.
*  APPEND gs_body TO gt_body.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_total_rate
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_total_rate .

  DATA : lv_tabix TYPE sy-tabix.
  DATA : lv_num(7) TYPE p DECIMALS 4.

  LOOP AT gt_body INTO gs_body.
    lv_tabix = sy-tabix.

*-- 차액금액 계산         당기 - 전기 / 전기
    lv_num =  ( gs_body-cprice -  gs_body-pprice ) / gs_body-pprice.
    gs_body-torat =  lv_num * 100.

    MODIFY gt_body FROM gs_body INDEX lv_tabix
                                TRANSPORTING  torat.

  ENDLOOP.
* cl_demo_output=>DISPLAY( gt_body ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form excel_job
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM excel_job .

  DATA : lt_roid   TYPE lvc_t_roid,
         ls_roid   TYPE lvc_s_roid,
         lv_line   TYPE i,
         lv_answer.

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

  DATA: lv_answer.

  PERFORM confirm  CHANGING lv_answer.

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
*& Form confirm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PV_ANSWER
*&---------------------------------------------------------------------*
FORM confirm   CHANGING pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'PDF 다운'
      text_question         = '손익계산서 PDF를 다운로드 하시겠습니까?'
      text_button_1         = 'YES'(001)
      icon_button_1         = 'ICON_OKAY'
      text_button_2         = 'NO'(002)
      icon_button_2         = 'ICON_CANCEL'
      default_button        = '1'
      display_cancel_button = ''
    IMPORTING
      answer                = pv_answer.
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

  DATA : lv_rc  TYPE i.

*-- File name
  CLEAR gv_temp_filename.
  CONCATENATE pfolder '\' '손익계산서' '.XLS'
              INTO gv_temp_filename.

  gv_form = 'ZC306_SONIK_PDF'.
  PERFORM download_template   USING gv_form gv_temp_filename.
  PERFORM open_excel_template USING gv_form.
  PERFORM fill_excel_line.   " 셀에 값 넣기

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
FORM download_template  USING   p_zform p_filename.

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
FORM open_excel_template  USING    p_zform.

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
  DATA : lv_cprice(20),
         lv_pprice(20).

  LOOP AT gt_body INTO gs_body.

*-- 금액필드 통화키로 바꿔주고 선언한 변수에 넣어준다
    CLEAR : lv_cprice, lv_pprice.
    WRITE : gs_body-cprice CURRENCY gs_body-waers TO lv_cprice,
            gs_body-pprice CURRENCY gs_body-waers TO lv_pprice.

*-- '-' 부호 앞으로 뺴기
    PERFORM sign_front CHANGING lv_cprice lv_pprice.

    CASE gs_body-txt50.
      WHEN '제품매출'.
        PERFORM fill_cells USING 7 3 lv_cprice.
        PERFORM fill_cells USING 7 4 lv_pprice.
      WHEN '제품매출원가'.
        PERFORM fill_cells USING 9 3 lv_cprice.
        PERFORM fill_cells USING 9 4 lv_pprice.
      WHEN '급여'.
        PERFORM fill_cells USING 12 3 lv_cprice.
        PERFORM fill_cells USING 12 4 lv_pprice.
      WHEN '퇴직급여'.
        PERFORM fill_cells USING 13 3 lv_cprice.
        PERFORM fill_cells USING 13 4 lv_pprice.
      WHEN '복리후생비'.
        PERFORM fill_cells USING 14 3 lv_cprice.
        PERFORM fill_cells USING 14 4 lv_pprice.
      WHEN '접대비'.
        PERFORM fill_cells USING 15 3 lv_cprice.
        PERFORM fill_cells USING 15 4 lv_pprice.
      WHEN '통신비'.
        PERFORM fill_cells USING 16 3 lv_cprice.
        PERFORM fill_cells USING 16 4 lv_pprice.
      WHEN '수도광열비'.
        PERFORM fill_cells USING 17 3 lv_cprice.
        PERFORM fill_cells USING 17 4 lv_pprice.
      WHEN '세금과공과'.
        PERFORM fill_cells USING 18 3 lv_cprice.
        PERFORM fill_cells USING 18 4 lv_pprice.
      WHEN '감가상각비'.
        PERFORM fill_cells USING 19 3 lv_cprice.
        PERFORM fill_cells USING 19 4 lv_pprice.
      WHEN '수선비'.
        PERFORM fill_cells USING 20 3 lv_cprice.
        PERFORM fill_cells USING 20 4 lv_pprice.
      WHEN '보험료'.
        PERFORM fill_cells USING 21 3 lv_cprice.
        PERFORM fill_cells USING 21 4 lv_pprice.
      WHEN '차량유지비'.
        PERFORM fill_cells USING 22 3 lv_cprice.
        PERFORM fill_cells USING 22 4 lv_pprice.
      WHEN '운반비'.
        PERFORM fill_cells USING 23 3 lv_cprice.
        PERFORM fill_cells USING 23 4 lv_pprice.
      WHEN '교육훈련비'.
        PERFORM fill_cells USING 24 3 lv_cprice.
        PERFORM fill_cells USING 24 4 lv_pprice.
      WHEN '소모품비'.
        PERFORM fill_cells USING 25 3 lv_cprice.
        PERFORM fill_cells USING 25 4 lv_pprice.
      WHEN '광고선전비'.
        PERFORM fill_cells USING 26 3 lv_cprice.
        PERFORM fill_cells USING 26 4 lv_pprice.
      WHEN '잡비'.
        PERFORM fill_cells USING 27 3 lv_cprice.
        PERFORM fill_cells USING 27 4 lv_pprice.
      WHEN '배당금수익'.
        PERFORM fill_cells USING 29 3 lv_cprice.
        PERFORM fill_cells USING 29 4 lv_pprice.
      WHEN '수수료수익'.
        PERFORM fill_cells USING 30 3 lv_cprice.
        PERFORM fill_cells USING 30 4 lv_pprice.
      WHEN '임대료'.
        PERFORM fill_cells USING 31 3 lv_cprice.
        PERFORM fill_cells USING 31 4 lv_pprice.
      WHEN '외환차익'.
        PERFORM fill_cells USING 32 3 lv_cprice.
        PERFORM fill_cells USING 32 4 lv_pprice.
      WHEN '외화환산이익'.
        PERFORM fill_cells USING 33 3 lv_cprice.
        PERFORM fill_cells USING 33 4 lv_pprice.
      WHEN '잡이익'.
        PERFORM fill_cells USING 34 3 lv_cprice.
        PERFORM fill_cells USING 34 4 lv_pprice.
      WHEN '법인세비용'.
        PERFORM fill_cells USING 41 3 lv_cprice.
        PERFORM fill_cells USING 41 4 lv_pprice.
      WHEN '외환차손'.
        PERFORM fill_cells USING 36 3 lv_cprice.
        PERFORM fill_cells USING 36 4 lv_pprice.
      WHEN '외화환산손실'.
        PERFORM fill_cells USING 37 3 lv_cprice.
        PERFORM fill_cells USING 37 4 lv_pprice.
      WHEN '재고자산감모손실'.
        PERFORM fill_cells USING 38 3 lv_cprice.
        PERFORM fill_cells USING 38 4 lv_pprice.
      WHEN '유형자산처분손실'.
        PERFORM fill_cells USING 39 3 lv_cprice.
        PERFORM fill_cells USING 39 4 lv_pprice.

      WHEN '잡손실'.
        PERFORM fill_cells USING 40 3 lv_cprice.
        PERFORM fill_cells USING 40 4 lv_pprice.

    ENDCASE.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_cells
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_11
*&      --> P_4
*&      --> GS_BLSHT_CPRICE
*&---------------------------------------------------------------------*
FORM fill_cells  USING    i j val.

  CALL METHOD OF excel 'CELLS' = cell
    EXPORTING
      #1 = i  " 행
      #2 = j. " 열

  SET PROPERTY OF cell 'VALUE' = val.

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
  CONCATENATE pfolder '\' '손익계산서' '.PDF'
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
*& Form sign_front
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CPRICE
*&      <-- LV_PPRICE
*&---------------------------------------------------------------------*
FORM sign_front  CHANGING pv_cprice
                          pv_pprice.

" '-' 부호 앞으로 뺴기
  CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
    CHANGING
      value = pv_cprice.  "값넣을때 CHAR 만 가능

  CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
    CHANGING
      value = pv_pprice.



ENDFORM.
