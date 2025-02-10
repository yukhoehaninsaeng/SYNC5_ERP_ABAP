*&---------------------------------------------------------------------*
*& Include          ZC302RPMM0002F01
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

*-- 건수 메시지 출력
  gv_count = lines( gt_header ).
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

    CLEAR : gt_fcat, gs_fcat.
    PERFORM set_field_catalog USING : 'X' 'ICON'      '            ' 'C' '',
                                      'X' 'MATNR'     'ZC302MMT0013' 'C' ' ',
                                      'X' 'SCODE'     'ZC302MMT0013' 'C' ' ',
                                      ' ' 'MAKTX'     'ZC302MMT0013' ' ' 'X',
                                      ' ' 'MTART_T'   'ZC302MMT0013' 'C' ' ',
*                                     ' ' 'SNAME'     'ZC302MMT0013' 'C' ' ',
                                      ' ' 'SNAME_T'     'ZC302MMT0013' 'C' ' ',
                                      ' ' 'ADDRESS'   'ZC302MMT0013' ' ' 'X',
*                                     ' ' 'MTART'     'ZC302MMT0013' 'C' 'X',
                                      ' ' 'H_RTPTQUA' 'ZC302MMT0013' 'C' ' ',
                                      ' ' 'H_RESMAT'  'ZC302MMT0013' 'C' ' ',
                                      ' ' 'MEINS'     'ZC302MMT0013' 'C' ' '.

    PERFORM set_item_field_catalog USING :'X' 'ICON'      '            ' 'C' '',
                                          'X' 'MATNR'     'ZC302MMT0002' 'C' 'X',
                                          'X' 'SCODE'     'ZC302MMT0002' 'C' ' ',
                                          'X' 'BDATU'     'ZC302MMT0002' 'C' ' ',
                                          ' ' 'MAKTX'     'ZC302MMT0002' ' ' 'X',
*                                         ' ' 'MTART'     'ZC302MMT0002' 'C' ' ',
*                                         ' ' 'MTART_T'   'ZC302MMT0002' 'C' ' ',
*                                         ' ' 'SNAME'     'ZC302MMT0002' 'C' ' ',
                                          ' ' 'I_RTPTQUA' 'ZC302MMT0002' 'C' ' ',
                                          ' ' 'I_RESMAT'  'ZC302MMT0002' 'C' ' ',
                                          ' ' 'MEINS'     'ZC302MMT0002' 'C' ' '.

    PERFORM set_layout.
    PERFORM create_object.
    SET HANDLER : lcl_event_handler=>top_of_page  FOR go_left_grid,
                  lcl_event_handler=>hotspot_click FOR go_left_grid.

    gv_variant-report = sy-repid.

    gv_variant-handle = 'ALV1'.
    CALL METHOD go_left_grid->set_table_for_first_display
      EXPORTING
        is_variant                    = gv_variant
        i_save                        = 'A'
        i_default                     = 'X'
        is_layout                     = gs_layout
      CHANGING
        it_outtab                     = gt_header
        it_fieldcatalog               = gt_fcat.

    gv_variant-handle = 'ALV2'.
    CALL METHOD go_right_grid->set_table_for_first_display
      EXPORTING
        is_variant                    = gv_variant
        i_save                        = 'A'
        i_default                     = 'X'
        is_layout                     = gs_rlayout
      CHANGING
        it_outtab                     = gt_item
        it_fieldcatalog               = gt_ifcat.


    CALL METHOD go_dyndoc_id->initialize_document
      EXPORTING
        background_color = cl_dd_area=>col_textarea.

    CALL METHOD go_left_grid->list_processing_events
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
    WHEN 'MATNR'.
      gs_fcat-hotspot = abap_true.
    WHEN 'MENGE'.
      gs_fcat-qfieldname = 'MEINS'.
    WHEN 'H_RTPTQUA'.
      gs_fcat-qfieldname = 'MEINS'.
      gs_fcat-coltext    = '실시간 제품 수량'.
    WHEN 'MEINS'.
      gs_fcat-coltext    = '단위'.
    WHEN 'H_RESMAT'.
      gs_fcat-qfieldname = 'MEINS'.
      gs_fcat-coltext    = '예약 재고'.
    WHEN 'ICON'.
      gs_fcat-coltext    = ' 상태 '.
    WHEN 'MTART_T'.
      gs_fcat-coltext    = '자재분류'.
    WHEN 'SNAME_T'.
      gs_fcat-coltext    = '창고분류'.
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

  gs_layout-zebra      = 'X'.
  gs_layout-cwidth_opt = 'A'.
  gs_layout-sel_mode   = 'D'.
  gs_layout-grid_title   = '재고관리 Header'.
  gs_layout-smalltitle  = abap_true.
  gs_layout-ctab_fname  = 'COLOR'.

  gs_rlayout-zebra      = 'X'.
  gs_rlayout-cwidth_opt = 'A'.
  gs_rlayout-sel_mode   = 'D'.
  gs_rlayout-grid_title   = '재고관리 Item'.
  gs_rlayout-smalltitle  = abap_true.

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
      extension = 46. " Top of page 높이

  CREATE OBJECT go_container
    EXPORTING
      container_name    = 'MAIN_CONT'.

  CREATE OBJECT go_split_container
    EXPORTING
      parent            = go_container
      rows              = 1
      columns           = 2.

  CALL METHOD go_split_container->get_container
    EXPORTING
      row               = 1
      column            = 1
    RECEIVING
      container         = go_left_container.

  CALL METHOD go_split_container->get_container
    EXPORTING
      row               = 1
      column            = 2
    RECEIVING
      container         = go_right_container.

  CREATE OBJECT go_left_grid
    EXPORTING
      i_parent          = go_left_container.

  CREATE OBJECT go_right_grid
    EXPORTING
      i_parent          = go_right_container.

*-- Top-of-page : Create TOP-Document(!!맨 마지막에!! 작성)
  CREATE OBJECT go_dyndoc_id
    EXPORTING
      style             = 'ALV_GRID'.

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
  DATA : gs_qua       TYPE zc302mmt0013-h_rtptqua,
         gs_total_qua TYPE zc302mmt0013-h_rtptqua,
         ls_scol      TYPE lvc_s_scol,
         l_date       LIKE sy-datum.

  LOOP AT gt_header INTO gs_header.
    gv_tabix = sy-tabix.

    PERFORM get_item_data .

*-- 아이템 끌어오기
    LOOP AT gt_item INTO gs_item.
      CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
      EXPORTING
        date            = gs_item-bdatu
        days            = 0
        months          = 0
        signum          = '+'
        years           = 2
     IMPORTING
       calc_date       = l_date. "생성일 + 2year

     IF l_date <= sy-datum.
         ls_scol-color-col = 6.
         ls_scol-nokeycol = 'X'.
         INSERT ls_scol INTO TABLE gs_header-color.
     ENDIF.
    ENDLOOP.

*-- 자재명 끌어오기
    READ TABLE gt_matnr INTO gs_matnr WITH KEY matnr = gs_header-matnr.
    gs_header-maktx = gs_matnr-maktx.

*-- 자재분류 끌어오기
    CASE gs_header-matnr(2).
      WHEN 'CP'.
        gs_header-mtart = '03'.
      WHEN 'SP'.
        gs_header-mtart = '02'.
      WHEN 'RM'.
        gs_header-mtart = '01'.
    ENDCASE.

*-- 자재분류 텍스트 노출
    CASE gs_header-mtart.
      WHEN '01'.
        gs_header-mtart_t = '원자재'.
      WHEN '02'.
        gs_header-mtart_t = '반제품'.
      WHEN '03'.
        gs_header-mtart_t = '완제품'.
    ENDCASE.

*-- 사용 가능 수량 (현재재고-예약재고)
    gs_qua = gs_header-h_rtptqua - gs_header-h_resmat.
*-- ( 사용가능수량/안전재고수량 ) * 100
    gs_total_qua = ( gs_qua / 1000 ) * 100.

*-- 안전재고량 대비 재고 수량을 계산해서 아이콘 표시
    IF gs_total_qua >= 70.
      gs_header-icon = icon_led_green.
    ELSEIF  gs_total_qua >= 50 AND gs_total_qua < 70.
      gs_header-icon = icon_led_yellow.
    ELSE.
       gs_header-icon = icon_led_red.
    ENDIF.

*-- 창고 끌어오기
    CASE gs_header-scode(4).
      WHEN 'ST01'.
        gs_header-sname = '01'.
        gs_header-sname_t = '원자재 창고'.
      WHEN 'ST02'.
        gs_header-sname = '02'.
        gs_header-sname_t = '반제품 창고'.
      WHEN 'ST03'.
        gs_header-sname = '03'.
        gs_header-sname_t = '완제품 창고'.
      WHEN 'ST05'.
        gs_header-sname = '05'.
        gs_header-sname_t = '물류센터 창고'.
    ENDCASE.

    READ TABLE gt_scode INTO gs_scode WITH KEY sname = gs_header-sname.
    gs_header-address = gs_scode-address.

*    cl_demo_output=>display( gt_scode ).

    MODIFY gt_header FROM gs_header INDEX gv_tabix TRANSPORTING color maktx mtart mtart_t icon sname sname_t address.

  ENDLOOP.


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

  so_type = VALUE #( so_type[ 1 ] OPTIONAL ).
  CLEAR : lv_temp.
  IF so_type-low IS NOT INITIAL.
    lv_temp = so_type-low.
    CASE lv_temp.
      WHEN '01'.
        lv_temp = '원자재'.
      WHEN '02'.
        lv_temp = '반제품'.
      WHEN '03'.
        lv_temp = '완제품'.
    ENDCASE.
  ELSE.
    lv_temp = '전체'.
  ENDIF.
  PERFORM add_row USING lr_dd_table col_field col_value '자재유형' lv_temp.

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

  so_scode = VALUE #( so_scode[ 1 ] OPTIONAL ).
  CLEAR : lv_temp.
  IF so_scode-low IS NOT INITIAL.
    lv_temp = so_scode-low.
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
*& Form init_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_value .

*-- 자재분류끌어오기
  CLEAR gt_mtart.
  SELECT mtart
    INTO CORRESPONDING FIELDS OF TABLE gt_mtart
    FROM zc302mt0007.

*-- 자재마스터 끌어오기
    CLEAR gt_matnr.
    SELECT matnr maktx
      INTO CORRESPONDING FIELDS OF TABLE gt_matnr
      FROM zc302mt0007.

*-- 창고명 끌어오기
  CLEAR gt_scode.
  SELECT scode sname address
    INTO CORRESPONDING FIELDS OF TABLE gt_scode
    FROM zc302mt0005.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_search
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_MATNR .

  DATA : lt_return LIKE TABLE OF ddshretval WITH HEADER LINE,
         lt_read   TYPE TABLE OF dynpread WITH HEADER LINE,
         lv_repid TYPE repid,
         lv_dynnr TYPE d020s-dnum,
         lv_fieldname TYPE dynfnam,
         lv_value TYPE dynfieldvalue.

  lv_repid = sy-repid.
  lv_dynnr = sy-dynnr.
  lv_fieldname = 'SO_TYPE-LOW'.


CALL FUNCTION 'FM_FYC_DYNPRO_VALUE_READ'
  EXPORTING
    i_repid            = lv_repid
    i_dynnr            = lv_dynnr
    i_fieldname        = lv_fieldname
 IMPORTING
   e_fieldvalue       = lv_value.

  IF lv_value IS INITIAL.
    CLEAR gt_matnr.
    SELECT matnr maktx
      INTO CORRESPONDING FIELDS OF TABLE gt_matnr
      FROM zc302mt0007.
  ELSE.
    CLEAR gt_matnr.
    SELECT matnr maktx
      INTO CORRESPONDING FIELDS OF TABLE gt_matnr
      FROM zc302mt0007
     WHERE mtart = lv_value.
  ENDIF.


  REFRESH : lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'MATNR'     " Input에 넣어줄 필드
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'SO_MAT'       " Selection Screen Element
      window_title    = 'MATNR'    " Description
      value_org       = 'S'
    TABLES
      value_tab       = gt_matnr    " F4에 뿌려줄 데이터(INITIALIZATION에서 select함)
      return_tab      = lt_return    " F4에서 선택된 값에 대한 정보
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  REFRESH lt_read.
  lt_read-fieldvalue = lt_return-fieldval.
  CASE lt_read-fieldvalue(2).
    WHEN 'CP'. "완제품
     CLEAR gt_scode.
     SELECT scode sname address
       INTO CORRESPONDING FIELDS OF TABLE gt_scode
       FROM zc302mt0005
      WHERE scode = 'ST03'
        OR scode = 'ST05'.
    WHEN 'SP'. "반제품
     CLEAR gt_scode.
     SELECT scode sname address
       INTO CORRESPONDING FIELDS OF TABLE gt_scode
       FROM zc302mt0005
      WHERE scode = 'ST02'.
    WHEN 'RM'. "원자재
     CLEAR gt_scode.
     SELECT scode sname address
       INTO CORRESPONDING FIELDS OF TABLE gt_scode
       FROM zc302mt0005
      WHERE scode = 'ST01'.
    WHEN OTHERS.
     CLEAR gt_scode.
     SELECT scode sname address
       INTO CORRESPONDING FIELDS OF TABLE gt_scode
       FROM zc302mt0005.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_scode
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_scode .

  DATA : lt_return LIKE TABLE OF ddshretval WITH HEADER LINE.

  REFRESH : lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'SCODE'     " Input에 넣어줄 필드
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'SO_SCODE'       " Selection Screen Element
      window_title    = 'SCODE'    " Description
      value_org       = 'S'
    TABLES
      value_tab       = gt_scode    " F4에 뿌려줄 데이터(INITIALIZATION에서 select함)
      return_tab      = lt_return    " F4에서 선택된 값에 대한 정보
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

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

*-- 좌측 재고관리 header 데이터
  CLEAR gt_header.
  SELECT matnr scode maktx sname address  mtart h_rtptqua
         h_resmat meins
    INTO CORRESPONDING FIELDS OF TABLE gt_header
    FROM zc302mmt0013
   WHERE mtart IN so_type
     AND matnr IN so_mat
     AND scode IN so_scode
   ORDER BY scode DESCENDING  matnr ASCENDING.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_item_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_item_data .

*-- 우측 재고관리 item 데이터
  CLEAR gt_item.
  SELECT matnr scode bdatu maktx sname
         mtart i_rtptqua i_resmat meins
    INTO CORRESPONDING FIELDS OF TABLE gt_item
    FROM zc302mmt0002
   WHERE matnr = gs_header-matnr
     AND scode = gs_header-scode.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_item_field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_item_field_catalog  USING pv_key pv_field pv_table pv_just pv_emph.

  gs_ifcat-key       = pv_key.
  gs_ifcat-fieldname = pv_field.
  gs_ifcat-ref_table = pv_table.
  gs_ifcat-just      = pv_just.
  gs_ifcat-emphasize = pv_emph.

  CASE pv_field.
    WHEN 'I_RTPTQUA'.
      gs_ifcat-qfieldname = 'MEINS'.
      gs_ifcat-coltext    = '수량'.
    WHEN 'MEINS'.
      gs_ifcat-coltext    = '단위'.
    WHEN 'I_RESMAT'.
      gs_ifcat-qfieldname = 'MEINS'.
      gs_ifcat-coltext    = '예약 재고'.
    WHEN 'ICON'.
      gs_ifcat-coltext    = '상태 '.
    WHEN 'MTART_T'.
      gs_ifcat-coltext    = '자재분류'.
  ENDCASE.

  APPEND gs_ifcat TO gt_ifcat.
  CLEAR gs_ifcat.
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

  CLEAR gs_header.
  READ TABLE gt_header INTO gs_header INDEX pv_row_id.

  PERFORM get_item_data.

*-- maktx 끌어오기
  LOOP AT gt_item INTO gs_item.

    gv_tabix = sy-tabix.
    CLEAR: gs_matnr.
    READ TABLE gt_matnr INTO gs_matnr WITH KEY matnr = gs_item-matnr.
    IF sy-subrc = 0.
      gs_item-maktx = gs_matnr-maktx.
    ENDIF.

    MODIFY gt_item FROM gs_item INDEX gv_tabix TRANSPORTING maktx.

  ENDLOOP.
  PERFORM make_display_item.

  PERFORM refresh_table.

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

  DATA : ls_stbl TYPE lvc_s_stbl.

  ls_stbl-row = abap_true.
  ls_stbl-col = abap_true.

  CALL METHOD go_right_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stbl.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_mtart_tet
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_item .

  LOOP AT gt_item INTO gs_item.

    DATA: l_date LIKE sy-datum.

    gv_tabix = sy-tabix.

    CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
      EXPORTING
        date            = gs_item-bdatu
        days            = 0
        months          = 0
        signum          = '+'
        years           = 2
     IMPORTING
       calc_date       = l_date. "생성일 + 2year

*-- 생성일로부터 2년지난 날짜 보다 현재 날짜가 더 크면
    IF gs_item-bdatu IS INITIAL.
      gs_item-icon   = icon_space.
    ELSEIF l_date <= sy-datum.
        gs_item-icon = icon_message_warning.
    ELSE.
        gs_item-icon = icon_space.
    ENDIF.

    CASE gs_item-mtart.
      WHEN '01'.
        gs_item-mtart_t = '원자재'.
      WHEN '02'.
        gs_item-mtart_t = '반제품'.
      WHEN '03'.
        gs_item-mtart_t = '완제품'.
    ENDCASE.

    MODIFY gt_item FROM gs_item INDEX sy-tabix TRANSPORTING mtart_t icon.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_type
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_type .
  DATA : lt_return LIKE TABLE OF ddshretval WITH HEADER LINE,
         lt_read   TYPE TABLE OF dynpread WITH HEADER LINE.

  REFRESH : lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'MTART'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
*      dynprofield     = 'GT_MTART-MTART'
      window_title    = '자재분류'
      value_org       = 'S'
    TABLES
      value_tab       = gt_mtart
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  READ TABLE lt_return INDEX 1.
  so_type = lt_return-fieldval.

*  REFRESH lt_read.
*  lt_read-fieldvalue = lt_return-fieldval.
  CASE lt_return-fieldval.

    WHEN '01'.
*-- 자재
       CLEAR gt_matnr.
       SELECT matnr maktx
         INTO CORRESPONDING FIELDS OF TABLE gt_matnr
         FROM zc302mt0007
        WHERE matnr LIKE 'RM%'.

*-- 창고
     CLEAR gt_scode.
     SELECT scode sname address
       INTO CORRESPONDING FIELDS OF TABLE gt_scode
       FROM zc302mt0005
      WHERE scode = 'ST01'.

    WHEN '02'. "반제품
*-- 자재
       CLEAR gt_matnr.
       SELECT matnr maktx
         INTO CORRESPONDING FIELDS OF TABLE gt_matnr
         FROM zc302mt0007
        WHERE matnr LIKE 'SP%'.

*-- 창고
     CLEAR gt_scode.
     SELECT scode sname address
       INTO CORRESPONDING FIELDS OF TABLE gt_scode
       FROM zc302mt0005
      WHERE scode = 'ST02'.
    WHEN '03'. "완제품
*-- 자재
       CLEAR gt_matnr.
       SELECT matnr maktx
         INTO CORRESPONDING FIELDS OF TABLE gt_matnr
         FROM zc302mt0007
        WHERE matnr LIKE 'CP%'.
*-- 창고
     CLEAR gt_scode.
     SELECT scode sname address
       INTO CORRESPONDING FIELDS OF TABLE gt_scode
       FROM zc302mt0005
      WHERE scode = 'ST03'
         OR scode = 'ST05'.
    WHEN OTHERS.
*-- 자재
       CLEAR gt_matnr.
       SELECT matnr maktx
         INTO CORRESPONDING FIELDS OF TABLE gt_matnr
         FROM zc302mt0007.
*-- 창고
     CLEAR gt_scode.
     SELECT scode sname address
       INTO CORRESPONDING FIELDS OF TABLE gt_scode
       FROM zc302mt0005.

    ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_parameter
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_parameter CHANGING pv_search.
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'TP'.
        pv_search = so_type-low.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.
