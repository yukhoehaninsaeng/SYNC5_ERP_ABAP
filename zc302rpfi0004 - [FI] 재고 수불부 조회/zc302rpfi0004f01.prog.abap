*&---------------------------------------------------------------------*
*& Include          ZC302RPFI0004F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_CONDITION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_condition .

  DATA : lv_month TYPE sy-datum.

  IF so_sbd-high IS NOT INITIAL.
    lv_month = so_sbd-high.
    so_sbd-low+6(2) = '01'.
  ELSE.
    lv_month = so_sbd-low.
  ENDIF.

*-- 입력된 날짜의 말일자를 얻어옴
  CALL FUNCTION 'DATE_GET_MONTH_LASTDAY'
    EXPORTING
      i_date = lv_month
    IMPORTING
      e_date = lv_month.

  IF so_sbd-high IS NOT INITIAL.
    so_sbd-high = lv_month.
    so_sbd-low+6(2) = '01'.
  ELSE.
    so_sbd-low = lv_month.
  ENDIF.

  MODIFY so_sbd INDEX 1.

  LOOP AT SCREEN .

    CLEAR : gv_cond.
    CASE 'X'.  " 전체조회
      WHEN pa_rd1.
        gv_cond = ''.
      WHEN pa_rd2 . " 원자재/반제품
        gv_cond = '01'.
      WHEN pa_rd3.  " 완제품
        gv_cond = '03'.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_base_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM get_base_data.



  IF gv_cond = ' '.
    SELECT *
*           SBULY SBLDT a~MATNR b~MAKTX PLANT SCODE MEINS a~WAERS BASE_STOCK BASE_PRICE
*           PROD_STOCK PROD_PRICE INPUT_STOCK INPUT_PRICE
    INTO CORRESPONDING FIELDS OF TABLE gt_body
    FROM zc302fit0003 AS a INNER JOIN zc302mt0007 AS b
       ON a~matnr EQ b~matnr
      AND a~maktx EQ b~maktx
     WHERE sbldt IN so_sbd
      AND sbuly IN so_sby
      AND a~matnr IN so_mat
 ORDER BY a~mtart ASCENDING.

  ELSEIF gv_cond = '01'.
    SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_body
    FROM zc302fit0003
    WHERE mtart IN ( '01', '02' )
      AND sbldt IN so_sbd
      AND sbuly IN so_sby
      AND matnr IN so_mat
 ORDER BY mtart ASCENDING.

  ELSEIF gv_cond = '03'.
    SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_body
    FROM zc302fit0003
    WHERE mtart EQ '03'
      AND sbldt IN so_sbd
      AND sbuly IN so_sby
      AND matnr IN so_mat.

  ENDIF.

*  IF gt_body IS INITIAL.
*    MESSAGE i001 WITH '수불부 조회는 매월 말일 기준으로만 제공됩니다.'
*                      '마감일이 지난 달로 조회바랍니다.' DISPLAY LIKE 'E'.
*    STOP.
*
*  ENDIF.

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

*  IF go_container IS NOT BOUND.
  IF go_left_cont IS NOT BOUND.

    PERFORM create_object_.
    PERFORM register_tree_event.
    PERFORM buiild_node.


    CALL METHOD go_tree->add_nodes
      EXPORTING
        table_structure_name = 'MTREESNODE'
        node_table           = node_table.

    CALL METHOD go_tree->expand_node
      EXPORTING
        node_key = 'ROOT'.



    SET HANDLER : lcl_event_handler=>top_of_page  FOR go_alv_grid.

    CLEAR : gt_fcat.
    CASE gv_cond.
      WHEN ' '.  " 전체조회
        PERFORM set_fcat USING : 'X' 'SBULY' '자재문서 연도' 'C' ' ' '1',
                                 'X' 'SBLDT' '수불 문서 일자' 'C' ' ' '2',
                                 ' ' 'MTART' '자재유형'      'C' 'X' '3',
                                 'X' 'MATNR' '자재 코드' 'C' ' ' '4',
                                 ' ' 'MAKTX' '자재명'   'C' ' ' '5',
                                 ' ' 'PLANT' '공장코드' 'C' ' ' '7',
                                 ' ' 'SCODE' '창고코드' 'C' ' ' '8',
                                 ' ' 'MEINS' '단위'     'C' ' ' '9',
                                 ' ' 'BASE_STOCK' '기초 수량' 'C' ' ' '10',
                                 ' ' 'BASE_PRICE' '기초 금액' 'C' ' ' '11',
                                 ' ' 'PURC_STOCK' '구매수량' 'C' ' ' '12',
                                 ' ' 'PURC_PRICE' '구매금액' 'C' ' ' '13',
                                 ' ' 'STOR_STOCK' '입고수량' 'C' ' ' '14',
                                 ' ' 'STOR_PRICE' '입고금액' 'C' ' ' '15',
                                 ' ' 'INPUT_STOCK' '투입 수량' 'C' ' ' '16',
                                 ' ' 'INPUT_PRICE' '투입 금액' 'C' ' ' '17',
                                 ' ' 'PROD_STOCK' '생산 수량' 'C' ' ' '18',
                                 ' ' 'PROD_PRICE' '생산 금액' 'C' ' ' '19',
                                 ' ' 'RETR_STOCK' '출고수량' 'C' ' ' '20',
                                 ' ' 'RETR_PRICE' '출고금액' 'C' ' ' '21',
                                 ' ' 'SOLD_STOCK' '판매수량' 'C' ' ' '22',
                                 ' ' 'SOLD_STOCK' '판매수량' 'C' ' ' '23',
                                 ' ' 'CLOS_STOCK' '기말재고' 'C' ' ' '24',
                                 ' ' 'CLOS_PRICE' '기말금액' 'C' ' ' '25'.
      WHEN '01'.  " 원자재/반제품 조회
        PERFORM set_fcat USING : 'X' 'SBULY' '자재문서 연도' 'C' ' ' '1',
                                 'X' 'SBLDT' '수불 문서 일자' 'C' ' ' '2',
                                 ' ' 'MTART' '자재유형'      'C' 'X' '3',
                                 'X' 'MATNR' '자재 코드' 'C' ' ' '4',
                                 ' ' 'MAKTX' '자재명'   'C' ' ' '5',
                                 ' ' 'PLANT' '공장 코드' 'C' ' ' '6',
                                 ' ' 'SCODE' '창고 코드' 'C' ' ' '7',
                                 ' ' 'BASE_STOCK' '기초 수량' 'C' ' ' '8',
                                 ' ' 'BASE_PRICE' '기초 금액' 'C' ' ' '9',
                                 ' ' 'PURC_STOCK' '구매수량' 'C' ' ' '10',
                                 ' ' 'PURC_PRICE' '구매금액' 'C' ' ' '11',
                                 ' ' 'STOR_STOCK' '입고수량' 'C' ' ' '12',
                                 ' ' 'STOR_PRICE' '입고금액' 'C' ' ' '13',
                                 ' ' 'INPUT_STOCK' '투입 수량' 'C' ' ' '14',
                                 ' ' 'INPUT_PRICE' '투입 금액' 'C' ' ' '15',
                                 ' ' 'PROD_STOCK' '생산 수량' 'C' ' ' '16',
                                 ' ' 'PROD_PRICE' '생산 금액' 'C' ' ' '17',
                                 ' ' 'RETR_STOCK' '출고수량' 'C' ' ' '18',
                                 ' ' 'RETR_PRICE' '출고금액' 'C' ' ' '19',
                                 ' ' 'CLOS_STOCK' '기말재고' 'C' ' ' '20',
                                 ' ' 'CLOS_PRICE' '기말금액' 'C' ' ' '21'.
      WHEN '03'.  " 완제품 조회
        PERFORM set_fcat USING : 'X' 'SBULY' '자재문서 연도' 'C' ' ' '1',
                                 'X' 'SBLDT' '수불 문서 일자' 'C' ' ' '2',
                                 'X' 'MATNR' '자재 코드' 'C' ' ' '3',
                                 ' ' 'MAKTX' '자재명'   'C' ' ' '4',
                                 ' ' 'SCODE' '창고 코드' 'C' ' ' '5',
                                 ' ' 'BASE_STOCK' '기초 수량' 'C' ' ' '6',
                                 ' ' 'BASE_PRICE' '기초 금액' 'C' ' ' '7',
                                 ' ' 'PURC_STOCK' '구매수량' 'C' ' ' '8',
                                 ' ' 'PURC_PRICE' '구매금액' 'C' ' ' '9',
                                 ' ' 'STOR_STOCK' '입고수량' 'C' ' ' '10',
                                 ' ' 'STOR_PRICE' '입고금액' 'C' ' ' '11',
                                 ' ' 'INPUT_STOCK' '투입 수량' 'C' ' ' '12',
                                 ' ' 'INPUT_PRICE' '투입 금액' 'C' ' ' '13',
                                 ' ' 'PROD_STOCK' '생산 수량' 'C' ' ' '14',
                                 ' ' 'PROD_PRICE' '생산 금액' 'C' ' ' '15',
                                 ' ' 'RETR_STOCK' '출고수량' 'C' ' ' '16',
                                 ' ' 'RETR_PRICE' '출고금액' 'C' ' ' '17',
                                 ' ' 'SOLD_STOCK' '판매수량' 'C' ' ' '18',
                                 ' ' 'SOLD_STOCK' '판매수량' 'C' ' ' '19',
                                 ' ' 'CLOS_STOCK' '기말재고' 'C' ' ' '20',
                                 ' ' 'CLOS_PRICE' '기말금액' 'C' ' ' '21'.
    ENDCASE.

    PERFORM set_layout.
*    PERFORM create_object.
    PERFORM exclude_button TABLES gt_ui_functions.

    CALL METHOD go_dyndoc_id->initialize_document
      EXPORTING
        background_color = cl_dd_area=>col_textarea.

    CALL METHOD go_alv_grid->list_processing_events
      EXPORTING
        i_event_name = 'TOP_OF_PAGE'
        i_dyndoc_id  = go_dyndoc_id.


    CALL METHOD go_alv_grid->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        i_save               = 'A'
        i_default            = 'X'
        is_layout            = gs_layout
        it_toolbar_excluding = gt_ui_functions
      CHANGING
        it_outtab            = gt_body
        it_fieldcatalog      = gt_fcat.


  ENDIF.

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
*
*  CREATE OBJECT go_container
*    EXPORTING
*      repid     = sy-repid
*      dynnr     = sy-dynnr
*      side      = go_container->dock_at_left
*      extension = 5000.
*
*  CREATE OBJECT go_alv_tree
*    EXPORTING
*      parent              = go_container
*      node_selection_mode = cl_gui_column_tree=>node_sel_mode_multiple
*      hide_selection      = 'X'.
**    no_html_header              =

ENDFORM.
*&---------------------------------------------------------------------*
*& Form define_hierarchy_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GS_HIERHDR
*&---------------------------------------------------------------------*
FORM define_hierarchy_header  CHANGING pv_hierhdr TYPE treev_hhdr.

*  pv_hierhdr-heading = '월별 수불 문서'.
*  pv_hierhdr-tooltip = '월별 수불 문서'.
*  pv_hierhdr-width = 35.
*  pv_hierhdr-width_pix = space.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_comment
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_LIST_COMMENTARY
*&---------------------------------------------------------------------*
FORM build_comment  USING    pt_list_commentary TYPE slis_t_listheader.
*
*  DATA : ls_line TYPE slis_listheader.
*
*  CLEAR ls_line.
*  ls_line-typ = 'H'.
*  ls_line-info = '재고 수불 조회'.  " High font
*  APPEND ls_line TO pt_list_commentary.
*
*  CLEAR ls_line.
*  ls_line-typ = 'S'. " Small font
*  ls_line-key = 'Current date : '.
*  ls_line-info = sy-datum.
*  APPEND ls_line TO pt_list_commentary.
*
*  CLEAR ls_line.
*  ls_line-typ = 'S'.
*  ls_line-key = '수불 유형 : '.
*  ls_line-info = gv_cond.
*  APPEND ls_line TO pt_list_commentary.
*
**    CLEAR ls_line.
**  ls_line-typ = 'A'. " Italic font
**  ls_line-info = 'SYNC-5 Class 3'.
**  APPEND ls_line TO pt_list_commentary.
*
*  gs_variant-report = sy-repid.

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
*
*  CLEAR : gt_fcat, gs_fcat.
**  PERFORM set_field_catalog USING : 'BU_GROUP'   'Group'  'X',
*                                    'NAME_ORG1'  'Name'   'X',
*                                    'CRUSR'      'Crusr'  ' ',
*                                    'CRDAT'      'Date'   ' ',
*                                    'CHUSR'      'Chusr'  ' ',
*                                    'TD_SWITCH'  'Switch' ' '.

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
FORM set_field_catalog  USING   pv_field pv_text pv_noout.

*  gs_fcat-fieldname = pv_field.
*  gs_fcat-coltext   = pv_text.
*  gs_fcat-no_out    = pv_noout.
*
*  APPEND gs_fcat TO gt_fcat.
*  CLEAR gs_fcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_fcat  USING  pv_key pv_field pv_table pv_just pv_emph pv_pos.

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
      side      = go_container->dock_at_left
      extension = 5000.

  CREATE OBJECT go_alv_grid
    EXPORTING
      i_parent = go_container.


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
*& Form fill_tree_info
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_tree_info .

  SELECT DISTINCT sbuly sbldt INTO TABLE gt_tr_subul
    FROM zc302fit0003
    WHERE sbuly IN so_sby
     AND  sbldt IN so_sbd.

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

*-- Top-of-page : Install Docking Container for Top-of-page(!!맨위에!! 생성)
  CREATE OBJECT go_top_container
    EXPORTING
      repid     = sy-cprog
      dynnr     = sy-dynnr
      side      = go_top_container->dock_at_top
      extension = 45. " Top of page 높이


  CREATE OBJECT go_container
    EXPORTING
      repid     = sy-repid
      dynnr     = sy-dynnr
      side      = cl_gui_docking_container=>dock_at_left
      extension = 5000.

  CREATE OBJECT go_base_cont
    EXPORTING
      parent  = go_container
      rows    = 1
      columns = 2.

  CALL METHOD go_base_cont->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_left_cont.

  CALL METHOD go_base_cont->get_container
    EXPORTING
      row       = 1
      column    = 2
    RECEIVING
      container = go_right_cont.

  CALL METHOD go_base_cont->set_column_width
    EXPORTING
      id    = 1
      width = 20.

  CREATE OBJECT go_tree
    EXPORTING
      parent              = go_left_cont
      node_selection_mode = cl_gui_simple_tree=>node_sel_mode_single.

  CREATE OBJECT go_alv_grid
    EXPORTING
      i_parent = go_right_cont.

*-- TOP-OF-PAGE : CREATE top-Document(!!!맨마지막에!! 작성)
  CREATE OBJECT go_dyndoc_id
    EXPORTING
      style = 'ALV_GRID'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form register_tree_event
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM register_tree_event .

  event-eventid = cl_gui_simple_tree=>eventid_node_double_click.
  event-appl_event = 'X'.
  APPEND event TO events.

  CALL METHOD go_tree->set_registered_events
    EXPORTING
      events                    = events
    EXCEPTIONS
      cntl_error                = 1
      cntl_system_error         = 2
      illegal_event_combination = 3
      OTHERS                    = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  SET HANDLER lcl_event_handler=>handle_node_double_click FOR go_tree.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form buiild_node
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM buiild_node .
  DATA: node     TYPE mtreesnode,
        lv_sbuly TYPE zc302fit0003-sbuly,
        lv_text  TYPE zc302fit0003-sbldt.

  node-node_key   = 'ROOT'.
  node-text       = '월별 수불부'.
  node-isfolder   = 'X'.
*  node-n_image    = '@06@'.   " 접은 이미지
*  node-exp_image  = '@07@'.   " 펼친 이미지
  node-n_image    = '@04@'.   " 접은 이미지
  node-exp_image  = '@05@'.   " 펼친 이미지
  APPEND node TO node_table.
  CLEAR node.

  SORT gt_tr_subul BY sbldt ASCENDING.

  LOOP AT gt_tr_subul INTO gs_tr_subul .
*--------------------------------------------------------------------*
    ON CHANGE OF gs_tr_subul-sbuly. " 폴더가 많아질수록 해당로직 이용
      MOVE gs_tr_subul-sbuly TO lv_sbuly.

      SELECT SINGLE sbuly INTO lv_sbuly
        FROM zc302fit0003
        WHERE sbuly EQ lv_sbuly.

      node-node_key  = gs_tr_subul-sbuly.
      node-relatkey  = 'ROOT'.
      node-isfolder  = 'X'.
*      node-n_image   = '@06@'.
*      node-exp_image = '@07@'.
      node-n_image   = '@04@'. " 접은 이미지
      node-exp_image = '@05@'. " 펼친 이미지
      node-text = lv_sbuly.
      APPEND node TO node_table.
      CLEAR node.
    ENDON.

    ON CHANGE OF gs_tr_subul-sbldt.
*      MOVE gs_tr_subul-sbuly TO lv_.
*
*      SELECT SINGLE sbuly INTO lv_sbuly
*        FROM zc302fit0003
*        WHERE sbuly EQ lv_sbuly.

      node-node_key  = gs_tr_subul-sbldt.
      node-relatkey  =  lv_sbuly.
      node-isfolder  = ' '.
*      node-n_image   = '@06@'.
*      node-exp_image = '@07@'.
*      node-n_image   = '@04@'. " 접은 이미지
*      node-exp_image = '@05@'. " 펼친 이미지
      node-text = gs_tr_subul-sbldt+4(2) && '월'.
      APPEND node TO node_table.
      CLEAR node.
    ENDON.
*--------------------------------------------------------------------*
*    node-node_key = gs_tr_subul-sbldt.
*    node-text = gs_tr_subul-sbldt.
*    node-relatkey = gs_tr_subul-sbldt.
*    node-isfolder = ' '.
*    APPEND node TO node_table.
    CLEAR: node, gs_tr_subul.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form search_clicked_node_info
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> NODE_KEY
*&---------------------------------------------------------------------*
FORM search_clicked_node_info  USING    pv_node_key.

  CLEAR gt_body.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_body
    FROM zc302fit0003
    WHERE sbuly IN so_sby
    AND   sbldt EQ pv_node_key.

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

  CLEAR so_sby.
  so_sby-sign = 'I'.
  so_sby-option = 'EQ'.
  so_sby-low = '2024'.
  APPEND so_sby.

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
*

*-------------------------------------------------------------------
* Top of Page 레이아웃에 맞춰 값 세팅
*-------------------------------------------------------------------
*-- 전체조회
  PERFORM add_row USING lr_dd_table col_field col_value '수불유형' gv_cond.


*-- 수불일자
  so_sbd = VALUE #( so_sbd[ 1 ] OPTIONAL ).
  CLEAR : lv_temp.
  IF so_sbd-low IS NOT INITIAL.
    lv_temp = so_sbd-low.
    IF so_sbd-high IS NOT INITIAL.
      CONCATENATE lv_temp ' ~ ' so_sbd-high INTO lv_temp.
    ENDIF.
  ELSE.
    lv_temp = '전체'.
  ENDIF.
  PERFORM add_row USING lr_dd_table col_field col_value '수불일자' lv_temp.


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
  PERFORM add_row USING lr_dd_table col_field col_value '자재코드' lv_temp.


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
*&      --> PA_RD1
*&---------------------------------------------------------------------*
FORM add_row  USING  pr_dd_table  TYPE REF TO cl_dd_table_element
                     pv_col_field TYPE REF TO cl_dd_area
                     pv_col_value TYPE REF TO cl_dd_area
                     pv_field
                     pv_text.

  CASE gv_cond.
    WHEN ''.
      pv_text = '전체조회'.
    WHEN '01'.
      pv_text = '원자재/반제품'.
    WHEN '03'.
      pv_text = '완제품'.
  ENDCASE.

  DATA : lv_text TYPE sdydo_text_element.

*-- Field에 값 세팅
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

  CALL METHOD pv_col_field->add_gap
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
