*&---------------------------------------------------------------------*
*& Include          ZC302RPMM0007F01
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

  PERFORM get_header_data.

  PERFORM movetype_text.

  gv_count = lines( gt_doc_mat ).
  MESSAGE s001 WITH gv_count TEXT-s01.


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
    CLEAR : gt_fcat,  gs_fcat.
    PERFORM set_field_catalog USING : 'X' 'MBLNR'      'ZC302MMT0011' 'C' ' ',
                                      'X' 'MJAHR'      'ZC302MMT0011' 'C' ' ',
*                                     ' ' 'MAKTX'      'ZC302MMT0012' 'C' 'X',
                                      ' ' 'VBELN'      'ZC302MMT0011' 'C' ' ',
                                      ' ' 'MOVETYPE_T' 'ZC302MMT0011' 'C' ' ',
*                                     ' ' 'MOVETYPE'   'ZC302MMT0011' 'C' ' ',
                                      ' ' 'AUFNR'      'ZC302MMT0011' 'C' ' ',
                                      ' ' 'PONUM'      'ZC302MMT0011' 'C' ' ',
                                      ' ' 'RFNUM'      'ZC302MMT0011' 'C' ' '.
    PERFORM set_layout.
    PERFORM create_object.
    SET HANDLER : lcl_event_handler=>top_of_page  FOR go_alv_grid,
                  lcl_event_handler=>hotspot_click FOR go_alv_grid.

    gv_variant-report = sy-repid.
    gv_variant-handle = 'ALV1'.


  CALL METHOD go_alv_grid->set_table_for_first_display
    EXPORTING
      is_variant                    = gv_variant
      i_save                        = 'A'
      i_default                     = 'X'
      is_layout                     = gs_layout
    CHANGING
      it_outtab                     = gt_doc_mat
      it_fieldcatalog               = gt_fcat.

  CALL METHOD go_dyndoc_id->initialize_document
     EXPORTING
       background_color = cl_dd_area=>col_textarea.

   CALL METHOD go_alv_grid->list_processing_events
     EXPORTING
       i_event_name = 'TOP_OF_PAGE'
       i_dyndoc_id  = go_dyndoc_id.

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
FORM set_field_catalog  USING pv_key pv_field pv_table pv_just pv_emph.
  gs_fcat-key       = pv_key.
  gs_fcat-fieldname = pv_field.
  gs_fcat-ref_table = pv_table.
  gs_fcat-just      = pv_just.
  gs_fcat-emphasize = pv_emph.

  CASE pv_field.
    WHEN 'MBLNR'.
      gs_fcat-hotspot = abap_true.
    WHEN 'MENGE'.
      gs_fcat-qfieldname = 'MEINS'.
      gs_fcat-coltext    = '수량'.
    WHEN 'NETWR'.
      gs_fcat-cfieldname = 'WAERS'.
      gs_fcat-coltext    = '단가'.
    WHEN 'MOVETYPE_T'.
      gs_fcat-coltext    = '이동유형'.
    WHEN 'BUDAT'.
      gs_fcat-coltext    = '일자'.
    WHEN 'MEINS'.
      gs_fcat-coltext    = '단위'.
    WHEN 'WAERS'.
      gs_fcat-coltext    = '통화'.
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

  gs_layout-zebra       = 'X'.
  gs_layout-cwidth_opt  = 'A'.
  gs_layout-sel_mode    = 'D'.
  gs_playout-no_toolbar = 'A'.
  gs_layout-grid_title  = '자재문서조회'.
  gs_layout-smalltitle  = abap_true.

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
*-- Top-of-page : Install Docking Container for Top-of-page(!!맨위에!! 생성)
  CREATE OBJECT go_top_container
    EXPORTING
      repid     = sy-cprog
      dynnr     = sy-dynnr
      side      = go_top_container->dock_at_top
      extension = 36. " Top of page 높이

  CREATE OBJECT go_container
    EXPORTING
      side             = go_container->dock_at_left
      extension        = 5000.

  CREATE OBJECT go_alv_grid
    EXPORTING
      i_parent         = go_container.

*-- Top-of-page : Create TOP-Document(!!맨 마지막에!! 작성)
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
  so_mbl = VALUE #( so_mbl[ 1 ] OPTIONAL ).
  CLEAR : lv_temp.
  IF so_mbl-low IS NOT INITIAL.
    lv_temp = so_mbl-low.
    IF so_mbl-high IS NOT INITIAL.
      CONCATENATE lv_temp ' ~ ' so_mbl-high INTO lv_temp.
    ENDIF.
  ELSE.
    lv_temp = '전체'.
  ENDIF.
  PERFORM add_row USING lr_dd_table col_field col_value '자재문서번호' lv_temp.

  so_move = VALUE #( so_move[ 1 ] OPTIONAL ).
  CLEAR : lv_temp.
  IF so_move-low IS NOT INITIAL.
    lv_temp = so_move-low.
  ELSE.
    lv_temp = '전체'.
  ENDIF.
  PERFORM add_row USING lr_dd_table col_field col_value '이동유형'  lv_temp.

  PERFORM set_top_of_page.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_ROW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LR_DD_TABLE
*&      --> COL_FIELD
*&      --> COL_VALUE
*&      --> P_
*&      --> LV_TEMP
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
*& Form SET_TOP_OF_PAGE
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
*& Form movetype_text
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM movetype_text .

  LOOP AT gt_doc_mat INTO gs_doc_mat.

      gv_tabix = sy-tabix.

      CASE gs_doc_mat-movetype.
        WHEN 'A'.
          gs_doc_mat-movetype_t = '입고'.
        WHEN 'B'.
          gs_doc_mat-movetype_t = '출고'.
        WHEN 'C'.
          gs_doc_mat-movetype_t = '출하'.
      ENDCASE.

      MODIFY gt_doc_mat FROM gs_doc_mat INDEX gv_tabix TRANSPORTING movetype_t.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_header_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_header_data .

  CLEAR : gt_doc_mat.
  SELECT mblnr mjahr vbeln movetype aufnr ponum rfnum
    INTO CORRESPONDING FIELDS OF TABLE gt_doc_mat
    FROM zc302mmt0011
   WHERE mblnr    IN so_mbl
     AND movetype IN so_move.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_hotspot_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&      --> ENDMETHOD
*&---------------------------------------------------------------------*
FORM handle_hotspot_click  USING    pv_row_id
                                    pv_column_id.

*-- get 자재문서 item data
   PERFORM get_item_data USING pv_row_id.

*-- 자재문서 item 팝업창 띄움
   CALL SCREEN 101 STARTING AT 03 05.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_item_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_item_data USING pv_row_id.

  CLEAR gs_doc_mat.
  READ TABLE gt_doc_mat INTO gs_doc_mat INDEX pv_row_id.

  CLEAR gt_doc_item.
  SELECT mblnr mjahr a~matnr a~maktx scode budat
         menge meins b~netwr b~waers qinum  b~bpcode
    INTO CORRESPONDING FIELDS OF TABLE gt_doc_item
    FROM zc302mmt0012 AS a INNER JOIN zc302mt0007 AS b
      ON a~matnr = b~matnr
   WHERE mblnr = gs_doc_mat-mblnr.


*-- 자재명 끌어오기
  CLEAR gt_master.
  SELECT matnr maktx
    INTO CORRESPONDING FIELDS OF TABLE gt_master
  FROM zc302mt0007.

   LOOP AT gt_doc_item INTO gs_doc_item.

     gv_tabix = sy-tabix.
     CLEAR gs_master.
     READ TABLE gt_master INTO gs_master WITH KEY matnr = gs_doc_item-matnr.

     IF sy-subrc = 0.
       gs_doc_item-maktx = gs_master-maktx.
     ENDIF.

     MODIFY gt_doc_item FROM gs_doc_item INDEX gv_tabix TRANSPORTING maktx.

   ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_popup_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_popup_screen .


  IF go_pop_container IS NOT BOUND.

    CLEAR : gt_pfcat, gs_pfcat.
    PERFORM set_pop_field_catalog USING : 'X' 'MBLNR'    'ZC302MMT0012' 'C' ' ',
                                          'X' 'MJAHR'    'ZC302MMT0012' 'C' ' ',
                                          'X' 'MATNR'    'ZC302MMT0012' 'C' ' ',
                                          ' ' 'MAKTX'    'ZC302MMT0012' ' ' 'X',
                                          ' ' 'SCODE'    'ZC302MMT0012' 'C' ' ',
*                                         ' ' 'MOVETYPE' 'ZC302MMT0011' 'C' ' ',
                                          ' ' 'BUDAT'    'ZC302MMT0012' 'C' ' ',
                                          ' ' 'MENGE'    'ZC302MMT0012' 'C' ' ',
                                          ' ' 'MEINS'    'ZC302MMT0012' 'C' ' ',
                                          ' ' 'NETWR'    'ZC302MMT0012' 'C' ' ',
                                          ' ' 'WAERS'    'ZC302MMT0012' 'C' ' ',
                                          ' ' 'QINUM'    'ZC302MMT0012' 'C' ' ',
                                          ' ' 'BPCODE'   'ZC302MMT0012' 'C' ' '.
    PERFORM create_pop_object.
    CALL METHOD go_pop_grid->set_table_for_first_display
      EXPORTING
        i_save                        = 'A'
        i_default                     = 'X'
        is_layout                     = gs_playout
      CHANGING
        it_outtab                     = gt_doc_item
        it_fieldcatalog               = gt_pfcat.


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
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_pop_field_catalog  USING pv_key pv_field pv_table pv_just pv_emph.
  gs_pfcat-key       = pv_key.
  gs_pfcat-fieldname = pv_field.
  gs_pfcat-ref_table = pv_table.
  gs_pfcat-just      = pv_just.
  gs_pfcat-emphasize = pv_emph.

  CASE pv_field.
    WHEN 'MENGE'.
      gs_pfcat-qfieldname = 'MEINS'.
      gs_pfcat-coltext    = '수량'.
    WHEN 'NETWR'.
      gs_pfcat-cfieldname = 'WAERS'.
      gs_pfcat-coltext    = '단가'.
    WHEN 'BUDAT'.
      gs_pfcat-coltext    = '일자'.
    WHEN 'MEINS'.
      gs_pfcat-coltext    = '단위'.
    WHEN 'WAERS'.
      gs_pfcat-coltext    = '통화'.
  ENDCASE.

  APPEND gs_pfcat TO gt_pfcat.

  CLEAR gs_pfcat.
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

  CREATE OBJECT go_pop_container
    EXPORTING
      container_name    = 'POP_CONT'.

  CREATE OBJECT go_pop_grid
    EXPORTING
      i_parent          = go_pop_container.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form pop_exit
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM pop_exit .

  CALL METHOD : go_pop_grid->free,
                go_pop_container->free.

  FREE: go_pop_grid, go_pop_container.

  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_value.

  CLEAR gt_mbl.
  SELECT mblnr
    INTO CORRESPONDING FIELDS OF TABLE gt_mbl
    FROM zc302mmt0011.

  CLEAR gt_mjahr.
  SELECT mjahr
    INTO CORRESPONDING FIELDS OF TABLE gt_mjahr
    FROM zc302mmt0011.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4_mbl.
 DATA : lt_return LIKE TABLE OF ddshretval WITH HEADER LINE.

  REFRESH : lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'MBLNR'     " Input에 넣어줄 필드
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'SO_MBL'       " Selection Screen Element
      window_title    = 'MBLNR'    " Description
      value_org       = 'S'
    TABLES
      value_tab       = gt_mbl    " F4에 뿌려줄 데이터(INITIALIZATION에서 select함)
      return_tab      = lt_return    " F4에서 선택된 값에 대한 정보
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_mjahr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_mjahr .

 DATA : lt_return LIKE TABLE OF ddshretval WITH HEADER LINE.

  REFRESH : lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'MJAHR'     " Input에 넣어줄 필드
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'SO_MJAHR'       " Selection Screen Element
      window_title    = 'MJAHR'    " Description
      value_org       = 'S'
    TABLES
      value_tab       = gt_mjahr    " F4에 뿌려줄 데이터(INITIALIZATION에서 select함)
      return_tab      = lt_return    " F4에서 선택된 값에 대한 정보
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
