*&---------------------------------------------------------------------*
*& Include          ZC302RPMM0009F01
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

  _clear gt_po gs_po.

*-- ALV1
  SELECT aufnr bodat lfdat plordco
    INTO CORRESPONDING FIELDS OF TABLE gt_po
    FROM zc302mmt0007
   WHERE aufnr IN so_au
     AND bodat IN so_bo
     AND stostat EQ 'A'.


  IF gt_po IS INITIAL.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

**
**-- ALV3
*  SELECT *
*     INTO CORRESPONDING FIELDS OF TABLE gt_body2
*     FROM zc302mmt0009
*    WHERE instatus EQ 'A'.

*
*  SORT gt_body BY matnr.




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

  _clear gt_body gs_body.
  IF go_dock_cont IS NOT BOUND.

    PERFORM field_catalog.

    PERFORM create_object.
    PERFORM exclude_botton TABLES gt_ui_functions.

    SET HANDLER : lcl_event_handler=>hotspot_click FOR go_left_grid,
                  lcl_event_handler=>toolbar       FOR go_up_grid,
                  lcl_event_handler=>user_command  FOR go_up_grid,
                  lcl_event_handler=>top_of_page   FOR go_left_grid. " 어떤 ALV에 붙이던 상관없음

    PERFORM set_alv_grid.

    PERFORM register_event. " TOP-OF-PAGE

  ELSE.
    CALL METHOD go_left_grid->refresh_table_display.
    CALL METHOD go_up_grid->refresh_table_display.
    CALL METHOD go_down_grid->refresh_table_display.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM field_catalog .

  PERFORM set_field_catalog USING : '1' 'X' 'AUFNR'     'ZC302MMT0007' 'C' ' ',
                                    '1' ' ' 'PLORDCO'   'ZC302MMT0007' 'C' ' ',
                                    '1' ' ' 'BODAT'     'ZC302MMT0007' 'C' ' ',
                                    '1' ' ' 'LFDAT'     'ZC302MMT0007' 'C' 'X',

                                    '2' 'X' 'ICON'      'ICON'         'C' ' ',
                                    '2' 'X' 'XBLNR'     'ZC302MMT0009' 'C' ' ',
                                    '2' ' ' 'BLDAT'     'ZC302MMT0009' 'C' ' ',
                                    '2' ' ' 'MATNR'     'ZC302MMT0009' 'C' ' ',
                                    '2' ' ' 'MAKTX'     'ZC302MMT0009' ' ' 'X',
                                    '2' ' ' 'MENGE'     'ZC302MMT0009' ' ' ' ',
                                    '2' ' ' 'QIMENGE'   'ZC302MMT0009' ' ' ' ',
                                    '2' ' ' 'MEINS'     'ZC302MMT0009' 'C' ' ',
                                    '2' ' ' 'NETPR'     'ZC302MMT0009' ' ' ' ',
                                    '2' ' ' 'WAERS'     'ZC302MMT0009' 'C' ' ',

                                    '3' 'X' 'ICON'      'ICON'         'C' ' ',
                                    '3' 'X' 'XBLNR'     'ZC302MMT0009' 'C' ' ',
                                    '3' 'X' 'DOCXBN'    'ZC302MMT0009' 'C' ' ',
                                    '3' ' ' 'BLDAT'     'ZC302MMT0009' 'C' ' ',
                                    '3' ' ' 'MATNR'     'ZC302MMT0009' 'C' ' ',
                                    '3' ' ' 'MAKTX'     'ZC302MMT0009' ' ' 'X',
                                    '3' ' ' 'QIMENGE'   'ZC302MMT0009' ' ' ' ',
                                    '3' ' ' 'MEINS'     'ZC302MMT0009' 'C' ' ',
                                    '3' ' ' 'NETWR'     'ZC302MMT0009' ' ' ' ',
                                    '3' ' ' 'WAERS'     'ZC302MMT0009' 'C' ' ',
                                    '3' ' ' 'ENAME'     'ZC302MMT0009' 'C' ' ',
                                    '3' ' ' 'IVFLAG'    'ZC302MMT0009' 'C' ' '.



  PERFORM set_layo.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_field_catalog USING pv_num pv_key pv_field pv_table pv_just pv_emph.

  FIELD-SYMBOLS : <fs_fcat> LIKE gs_fcat1,
                  <ft_fcat> LIKE gt_fcat1.

  DATA : lvc_s_fcat(8), lvc_t_fcat(8).

  CONCATENATE : 'GS_FCAT' pv_num INTO lvc_s_fcat,
                'GT_FCAT' pv_num INTO lvc_t_fcat.
  ASSIGN : (lvc_s_fcat) TO <fs_fcat>,
           (lvc_t_fcat) TO <ft_fcat>.


  <fs_fcat>-key       = pv_key.
  <fs_fcat>-fieldname = pv_field.
  <fs_fcat>-ref_table = pv_table.
  <fs_fcat>-just      = pv_just.
  <fs_fcat>-emphasize = pv_emph.

  CASE pv_field.
    WHEN 'QIMENGE'.
      <fs_fcat>-qfieldname = 'MEINS'.
      <fs_fcat>-coltext = '최종입고수량'.
    WHEN 'MENGE'.
      <fs_fcat>-qfieldname = 'MEINS'.
      <fs_fcat>-coltext = '최초입고수량'.
    WHEN 'NETPR'.
      <fs_fcat>-cfieldname = 'WAERS'.
      <fs_fcat>-coltext = '단가'.
    WHEN 'NETWR'.
      <fs_fcat>-cfieldname = 'WAERS'.
      <fs_fcat>-coltext = '총합계'.
    WHEN 'WAERS'.
      <fs_fcat>-coltext = '통화'.
    WHEN 'MEINS'.
      <fs_fcat>-coltext = '단위'.
    WHEN 'BODAT'.
      <fs_fcat>-coltext = '발주일자'.
    WHEN 'ICON'.
      <fs_fcat>-coltext = '상태'.
    WHEN 'ENAME'.
      <fs_fcat>-coltext = '검수직원'.
    WHEN 'AUFNR'.
      <fs_fcat>-hotspot = abap_true.
  ENDCASE.

  APPEND <fs_fcat> TO <ft_fcat>.
  CLEAR <fs_fcat>.

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
  gs_layo-zebra       = abap_true.
  gs_layo-cwidth_opt  = 'A'.
  gs_layo-sel_mode    = 'D'.
  gs_layo-grid_title  = '구매오더 조회'.
  gs_layo-smalltitle  = abap_true.

  gs_layo2-zebra       = abap_true.
  gs_layo2-cwidth_opt  = 'A'.
  gs_layo2-sel_mode    = 'D'.
  gs_layo2-grid_title  = '입고자재 리스트 조회'.
  gs_layo2-smalltitle  = abap_true.

  gs_layo3-zebra       = abap_true.
  gs_layo3-cwidth_opt  = 'A'.
  gs_layo3-sel_mode    = 'D'.
  gs_layo3-grid_title  = '송장검증 완료 리스트'.
  gs_layo3-smalltitle  = abap_true.

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


  so_au-sign   = 'I'.
  so_au-option = 'BT'.
  so_au-low    = ''.
  so_au-high   = ''.
  APPEND so_au.

  so_bo-sign   = 'I'.
  so_bo-option = 'BT'.
  so_au-low    = ''.
  so_au-high   = ''.
  APPEND so_bo.

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
*-- Top-of-page : Install Docking Container for Top-of-Page( 맨위에 오브젝트 생성)
  CREATE OBJECT go_top_cont
    EXPORTING
      container_name = 'TOP_CONT'.

*-- Main Container
  CREATE OBJECT go_dock_cont
    EXPORTING
      container_name = 'MAIN_CONT'.

*-- Split
  CREATE OBJECT go_split_cont
    EXPORTING
      parent  = go_dock_cont
      rows    = 1
      columns = 2.

*-- Assgin Container
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

  CREATE OBJECT go_split_cont2
    EXPORTING
      parent  = go_right_cont
      rows    = 2
      columns = 1.

  CALL METHOD go_split_cont2->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_up_cont.

  CALL METHOD go_split_cont2->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_down_cont.

  CALL METHOD go_split_cont->set_column_width
    EXPORTING
      id    = 1
      width = 29.


*-- UP, Down ALV
  CREATE OBJECT go_left_grid
    EXPORTING
      i_parent = go_left_cont.

  CREATE OBJECT go_up_grid
    EXPORTING
      i_parent = go_up_cont.

  CREATE OBJECT go_down_grid
    EXPORTING
      i_parent = go_down_cont.

*-- Top-of-page : Create Top-Document (맨 마지막에 작성)
  CREATE OBJECT go_dyndoc_id
    EXPORTING
      style = 'ALV_GRID'.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form event_top_og_page
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM event_top_of_page .

  DATA : lr_dd_table TYPE REF TO cl_dd_table_element, " 테이블
         col_field   TYPE REF TO cl_dd_area,          " 필드
         col_value   TYPE REF TO cl_dd_area,          " 값
         col_gap1    TYPE REF TO cl_dd_area,          " 간격
         col_field2  TYPE REF TO cl_dd_area,          " 사원정보, 부서, 사원번호, 이름
         col_value2  TYPE REF TO cl_dd_area,          " 위의 필드의 값들
         col_value22 TYPE REF TO cl_dd_area,          " 직급
         col_gap2    TYPE REF TO cl_dd_area,          " 간격
         col_icon    TYPE REF TO cl_dd_area,          " 아이콘
         col_field3  TYPE REF TO cl_dd_area.

  DATA : lv_temp  TYPE string,
         lv_temp2 TYPE string.

*-------------------------------------------------------------------
* Top of Page의 레이아웃 세팅
*-------------------------------------------------------------------
*-- Create Table
  CALL METHOD go_dyndoc_id->add_table
    EXPORTING
      no_of_columns = 9
      border        = '0'
    IMPORTING
      table         = lr_dd_table.

*-- Set column(Add Column to Table) "칼럼을 설정해준다  해당 칼럼에 필드명과 값을 담을 예정
  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_field.

  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_value.

  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_gap1.

  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_field2.

  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_value2.

  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_value22.

  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_gap2.

  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_icon.

  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_field3.

*-------------------------------------------------------------------
* Top of Page 레이아웃에 맞춰 값 세팅
*-------------------------------------------------------------------
*-- 사원정보 & 송장검증상태 (타이틀)
  CLEAR: lv_temp, lv_temp2.

  PERFORM add_row USING lr_dd_table col_field  col_value
                                    col_gap1   col_field2
                                    col_value2 col_value22
                                    col_gap2   col_icon
                                    col_field3 '조회조건'     lv_temp
                                    ' '        '사원정보' lv_temp2
                                    ' '        ' '
                                    'CCC'        ' '.


*-- 구매오더 번호 & 부서 & 빨간색 ICON과 상태들

  so_au = VALUE #( so_au[ 1 ] OPTIONAL ).

  CLEAR : lv_temp.
  IF so_au-low IS NOT INITIAL.
    lv_temp = so_au-low.
    IF so_au-high IS NOT INITIAL.
      CONCATENATE lv_temp ' ~ ' so_au-high INTO lv_temp.
    ENDIF.
  ELSE.
    lv_temp = '전체'.
  ENDIF.

  CLEAR lv_temp2.
  lv_temp2 = gv_orgtx.

  PERFORM add_row USING lr_dd_table col_field  col_value
                                    col_gap1   col_field2
                                    col_value2 col_value22
                                    col_gap2   col_icon
                                    col_field3 '구매오더번호'   lv_temp
                                    ' '        '부서'        lv_temp2
                                    ' '        ' '
                                    'YELLOW'   '송장검증 미완료'.

*-- 빌주일자 & 사원번호 & ICON 상태
  so_bo = VALUE #( so_bo[ 1 ] OPTIONAL ).

  CLEAR : lv_temp.
  IF so_bo-low IS NOT INITIAL.
    lv_temp = so_bo-low.
    IF so_bo-high IS NOT INITIAL.
      CONCATENATE lv_temp ' ~ ' so_bo-high INTO lv_temp.
    ENDIF.
  ELSE.
    lv_temp = '전체'.
  ENDIF.

  CLEAR lv_temp2.
  lv_temp2 = gv_emp_num.

  PERFORM add_row USING lr_dd_table col_field  col_value
                                    col_gap1   col_field2
                                    col_value2 col_value22
                                    col_gap2   col_icon
                                    col_field3 '발주'    lv_temp
                                    ' '        '사원번호' lv_temp2
                                    ' '        ' '
                                    'GREEN'    '송장검증 완료'.

*-- 사원이름 및 직급
  CLEAR: lv_temp, lv_temp2.
  lv_temp  = gv_ename.
  lv_temp2 = gv_plstx.
  PERFORM add_row USING lr_dd_table col_field  col_value
                                    col_gap1   col_field2
                                    col_value2 col_value22
                                    col_gap2   col_icon
                                    col_field3 ' '   ' '
                                    ' '        '이름' lv_temp
                                    lv_temp2   ' '
                                    ' '        ' '.

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
FORM add_row  USING pr_dd_table    TYPE REF TO cl_dd_table_element " 테이블
                    pv_col_field   TYPE REF TO cl_dd_area           " column
                    pv_col_value   TYPE REF TO cl_dd_area           " Value
                    pv_col_gap1    TYPE REF TO cl_dd_area           " column
                    pv_col_field2  TYPE REF TO cl_dd_area
                    pv_col_value2  TYPE REF TO cl_dd_area           " column
                    pv_col_value22 TYPE REF TO cl_dd_area
                    pv_col_gap2    TYPE REF TO cl_dd_area           " column
                    pv_col_icon    TYPE REF TO cl_dd_area
                    pv_col_field3  TYPE REF TO cl_dd_area           " column
                    pv_field                                      " Column에 입력할 값
                    pv_text                                       " 값에 입력할 값
                    pv_gap1
                    pv_field2
                    pv_value2
                    pv_value22
                    pv_gap2
                    pv_icon
                    pv_field3.

  DATA : lv_text TYPE sdydo_text_element.

*-- Field에 값  세팅
  lv_text = pv_field.

  IF pv_text IS INITIAL.
    CALL METHOD pv_col_field->add_text
      EXPORTING
        text         = lv_text
        sap_emphasis = cl_dd_document=>strong
        sap_color    = cl_dd_document=>list_key_inv.
  ELSE.
    CALL METHOD pv_col_field->add_text
      EXPORTING
        text         = lv_text
        sap_emphasis = cl_dd_document=>strong
        sap_color    = cl_dd_document=>list_heading_inv.
  ENDIF.

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

*-- 간격 1
  CALL METHOD pv_col_gap1->add_gap
    EXPORTING
      width = 95.

*-- Field2에 값 세팅
  lv_text = pv_field2.

  IF pv_value2 IS INITIAL.
    CALL METHOD pv_col_field2->add_text
      EXPORTING
        text         = lv_text
        sap_emphasis = cl_dd_document=>strong
        sap_color    = cl_dd_document=>list_key_inv.
  ELSE.
    CALL METHOD pv_col_field2->add_text
      EXPORTING
        text         = lv_text
        sap_emphasis = cl_dd_document=>strong
        sap_color    = cl_dd_document=>list_heading_inv.
  ENDIF.

  CALL METHOD pv_col_field2->add_gap
    EXPORTING
      width = 3.

*-- Value2에 값 세팅
  lv_text = pv_value2.

  CALL METHOD pv_col_value2->add_text
    EXPORTING
      text         = lv_text
      sap_emphasis = cl_dd_document=>heading
      sap_color    = cl_dd_document=>list_negative_inv.

  CALL METHOD pv_col_value2->add_gap
    EXPORTING
      width = 3.

*-- Value22에 값 세팅
  lv_text = pv_value22.

  CALL METHOD pv_col_value22->add_text
    EXPORTING
      text         = lv_text
      sap_emphasis = cl_dd_document=>heading
      sap_color    = cl_dd_document=>list_negative_inv.

  CALL METHOD pv_col_value22->add_gap
    EXPORTING
      width = 3.

*-- 간격 2
  CALL METHOD pv_col_gap2->add_gap
    EXPORTING
      width = 95.

*-- ICON 지정
  CASE pv_icon.
    WHEN 'CCC'.
      lv_text = '송장검증상태'.
      IF pv_text IS INITIAL.
        CALL METHOD pv_col_icon->add_text
          EXPORTING
            text         = lv_text
            sap_emphasis = cl_dd_document=>strong
            sap_color    = cl_dd_document=>list_key_inv.
      ELSE.
        CALL METHOD pv_col_icon->add_text
          EXPORTING
            text         = lv_text
            sap_emphasis = cl_dd_document=>strong
            sap_color    = cl_dd_document=>list_heading_inv.
      ENDIF.

      CALL METHOD pv_col_icon->add_gap
        EXPORTING
          width = 2.
    WHEN 'YELLOW'.
      CALL METHOD pv_col_icon->add_gap
        EXPORTING
          width = 7.
      CALL METHOD pv_col_icon->add_icon
        EXPORTING
          sap_icon = 'ICON_LED_YELLOW'.
    WHEN 'GREEN'.
      CALL METHOD pv_col_icon->add_gap
        EXPORTING
          width = 7.
      CALL METHOD pv_col_icon->add_icon
        EXPORTING
          sap_icon = 'ICON_LED_GREEN'.
  ENDCASE.

*-- Field3 지정
  lv_text = pv_field3.

  CALL METHOD pv_col_field3->add_text
    EXPORTING
      text         = lv_text
      sap_emphasis = cl_dd_document=>heading
      sap_color    = cl_dd_document=>list_negative_inv.

  CALL METHOD pv_col_field3->add_gap
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
*&---------------------------------------------------------------------*
*& Form event_hotspot
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&---------------------------------------------------------------------*
FORM event_hotspot_click  USING    pv_row_id
                                    pv_column_id.
  DATA : lv_tabix TYPE sy-tabix.

  CLEAR : gt_body, gt_body2.
  READ TABLE gt_po INTO gs_po INDEX pv_row_id.

*-- Up Grid
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_body
    FROM zc302mmt0009
   WHERE aufnr    EQ gs_po-aufnr
     AND instatus NE 'A'.

  SORT gt_body BY matnr.

  LOOP AT gt_body INTO gs_body.
    lv_tabix = sy-tabix.

    IF gs_body-instatus IS INITIAL.
      gs_body-instatus = 'B'.
    ENDIF.

    CASE gs_body-instatus.
      WHEN 'A'.
        gs_body-icon = icon_led_green.
      WHEN 'B'.
        gs_body-icon = icon_led_yellow.
    ENDCASE.

    MODIFY gt_body FROM gs_body INDEX lv_tabix TRANSPORTING instatus icon.
  ENDLOOP.


  IF gt_body IS INITIAL.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
  ENDIF.


*-- Down Grid
  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE gt_body2
      FROM zc302mmt0009
     WHERE aufnr    EQ gs_po-aufnr
       AND instatus EQ 'A'.

  SORT gt_body2 BY matnr.

  LOOP AT gt_body2 INTO gs_body2.
    lv_tabix = sy-tabix.

    CASE gs_body2-instatus.
      WHEN 'A'.
        gs_body2-icon = icon_led_green.
      WHEN 'B'.
        gs_body2-icon = icon_led_yellow.
    ENDCASE.

    MODIFY gt_body2 FROM gs_body2 INDEX lv_tabix TRANSPORTING instatus icon.
  ENDLOOP.



  CALL METHOD go_up_grid->refresh_table_display.
  CALL METHOD go_down_grid->refresh_table_display.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_botton
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exclude_botton TABLES   pt_ui_functions TYPE ui_functions.

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
*& Form get_make_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_make_display .

  _clear gt_employee gs_employee.
  SELECT SINGLE ename emp_num orgtx plstx
    INTO CORRESPONDING FIELDS OF gs_employee
    FROM zc302mt0003
   WHERE emp_num = sy-uname.

  gv_emp_num = gs_employee-emp_num.
  gv_ename   = gs_employee-ename.
  gv_orgtx   = gs_employee-orgtx.
  gv_plstx   = gs_employee-plstx.


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

  PERFORM set_center_tbar USING : ' '    ' '                          ' '  3 ' '       po_object,
                                  'IV' icon_inspection_characteristic ' ' ' ' TEXT-i02 po_object.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_center_tbar
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
FORM set_center_tbar  USING pv_func pv_icon pv_qinfo pv_type pv_text
                            po_object TYPE REF TO cl_alv_event_toolbar_set.

  CLEAR gs_center_btn.
  gs_center_btn-function  = pv_func.
  gs_center_btn-icon      = pv_icon.
  gs_center_btn-quickinfo = pv_qinfo.
  gs_center_btn-butn_type = pv_type.
  gs_center_btn-text      = pv_text.
  APPEND gs_center_btn TO po_object->mt_toolbar.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_usr_command
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM handle_usr_command  USING    pv_ucomm.
  CASE pv_ucomm.
    WHEN 'IV'.
      PERFORM invoice.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form invoice
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_CHROW
*&---------------------------------------------------------------------*
FORM invoice.

  DATA : lt_index     TYPE lvc_t_row,
         ls_index     TYPE lvc_s_row,
         lv_answer(1).

  CLEAR : lt_index, ls_index, gv_tabix, gs_body2.

  CALL METHOD go_up_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_index.

  IF lines( lt_index ) < 1.
    MESSAGE s001 WITH text-e04 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 거래처 송장을 저장할지 물어봄
  PERFORM confirm_for_invo CHANGING lv_answer.

  IF lv_answer NE '1'.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.  " 송장검증을 취소하였습니다.
    EXIT.
  ENDIF.

  SORT lt_index BY index DESCENDING.

  LOOP AT lt_index INTO ls_index.

    READ TABLE gt_body INTO gs_body INDEX ls_index-index.

    MOVE-CORRESPONDING gs_body TO gs_body2.

*--송장검증문서번호 채번
    PERFORM iv_num.

    gs_body2-instatus = 'A'.
    gs_body2-ivflag   = 'N'.    "전표 미발행
    gs_body2-emp_num  = gv_emp_num.
    gs_body2-ename    = gv_ename.

*-- ALV3에 데이터 추가
    APPEND gs_body2 TO gt_body2.

*-- 선택된 행 ALV2 list에서 삭제
    DELETE gt_body INDEX ls_index-index.

*-- 추가 된 행 임시 itab에 이동 송장검증 테이블에 저장
    PERFORM save_iv.

  ENDLOOP.

  PERFORM change_icon.

  CALL METHOD go_left_grid->refresh_table_display.
  CALL METHOD go_up_grid->refresh_table_display.
  CALL METHOD go_down_grid->refresh_table_display.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form change_icon
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM change_icon .
  DATA : lv_tabix TYPE sy-tabix.

  LOOP AT gt_body2 INTO gs_body2.
    lv_tabix = sy-tabix.

    IF gs_body2-instatus EQ 'A'.
      gs_body2-icon = icon_led_green.
    ENDIF.

    MODIFY gt_body2 FROM gs_body2 INDEX lv_tabix TRANSPORTING icon.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_iv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_iv .

  DATA: ls_save TYPE zc302mmt0009.

  MOVE-CORRESPONDING gs_body2 TO ls_save.

  IF ls_save-erdat IS INITIAL.
    ls_save-erdat = sy-datum.
    ls_save-erzet = sy-uzeit.
    ls_save-ernam = sy-uname.
  ELSE.
    ls_save-aedat = sy-datum.
    ls_save-aezet = sy-uzeit.
    ls_save-aenam = sy-uname.
  ENDIF.

  UPDATE zc302mmt0009 SET docxbn   = ls_save-docxbn
                          instatus = ls_save-instatus
                          ivflag   = ls_save-ivflag
                          emp_num  = ls_save-emp_num
                          ename    = ls_save-ename
                          aedat    = ls_save-aedat
                          aezet    = ls_save-aezet
                          aenam    = ls_save-aenam
                    WHERE bpcode   = ls_save-bpcode
                      AND bldat    = ls_save-bldat
                      AND aufnr    = ls_save-aufnr
                      AND xblnr    = ls_save-xblnr.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
    MESSAGE s001 WITH TEXT-i03.
  ELSE.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
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

  CALL METHOD go_dyndoc_id->initialize_document
    EXPORTING
      background_color = cl_dd_area=>col_textarea.

  CALL METHOD go_left_grid->list_processing_events
    EXPORTING
      i_event_name = 'TOP_OF_PAGE'
      i_dyndoc_id  = go_dyndoc_id.

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

  gv_variant-report = sy-repid.
  gv_variant-handle = 'ALV1'.

  CALL METHOD go_left_grid->set_table_for_first_display
    EXPORTING
      is_variant      = gv_variant
      i_save          = 'A'
      i_default       = 'X'
      is_layout       = gs_layo
    CHANGING
      it_outtab       = gt_po
      it_fieldcatalog = gt_fcat1.

  gv_variant-handle = 'ALV2'.
  CALL METHOD go_up_grid->set_table_for_first_display
    EXPORTING
      is_variant      = gv_variant
      i_save          = 'A'
      i_default       = 'X'
      is_layout       = gs_layo2
    CHANGING
      it_outtab       = gt_body
      it_fieldcatalog = gt_fcat2.

  gv_variant-handle = 'ALV3'.
  CALL METHOD go_down_grid->set_table_for_first_display
    EXPORTING
      is_variant      = gv_variant
      i_save          = 'A'
      i_default       = 'X'
      is_layout       = gs_layo3
    CHANGING
      it_outtab       = gt_body2
      it_fieldcatalog = gt_fcat3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form confirm_for_invo
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM confirm_for_invo  CHANGING pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = '송장검증 Dialog'
      text_question         = '송장검증을 진행하시겠습니까?'
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
*& Form iv_num
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM iv_num .

  DATA : lv_prefix(4) VALUE 'MIVD'.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZC303MMMVD'
    IMPORTING
      number      = gs_body2-docxbn.


  CONCATENATE lv_prefix gs_body2-docxbn INTO gs_body2-docxbn.




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

  CLEAR gt_f4.
  SELECT DISTINCT aufnr
    INTO CORRESPONDING FIELDS OF TABLE gt_f4
    FROM zc302mmt0007
   WHERE stostat = 'A'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_aufnr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_aufnr_low .

  DATA : lt_return LIKE TABLE OF ddshretval WITH HEADER LINE.

  REFRESH : lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'AUFNR'     " Input에 넣어줄 필드
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'SO_AU-LOW'       " Selection Screen Element
      window_title    = '구매오더번호'    " Description
      value_org       = 'S'
    TABLES
      value_tab       = gt_f4        " F4에 뿌려줄 데이터(INITIALIZATION에서 select함)
      return_tab      = lt_return    " F4에서 선택된 값에 대한 정보
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_aufnr_high
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_aufnr_high .

  DATA : lt_return LIKE TABLE OF ddshretval WITH HEADER LINE.

  REFRESH : lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'AUFNR'     " Input에 넣어줄 필드
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'SO_AU-HIGH'       " Selection Screen Element
      window_title    = '구매오더번호'    " Description
      value_org       = 'S'
    TABLES
      value_tab       = gt_f4        " F4에 뿌려줄 데이터(INITIALIZATION에서 select함)
      return_tab      = lt_return    " F4에서 선택된 값에 대한 정보
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.


ENDFORM.
