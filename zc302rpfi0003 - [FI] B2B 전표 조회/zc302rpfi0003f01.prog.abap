*&---------------------------------------------------------------------*
*& Form get_base_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_base_data .
  " main data select
  SELECT *
    FROM zc302fit0001 AS a INNER JOIN zc302fit0002 AS b
      ON a~bukrs = b~bukrs
     AND a~gjahr = b~gjahr
     AND a~belnr = b~belnr
    INTO CORRESPONDING FIELDS OF TABLE gt_body
    WHERE a~bukrs IN so_bukrs
      AND a~gjahr IN so_gjahr
      AND a~belnr IN so_belnr.

  IF sy-subrc NE 0.
    MESSAGE S001 WITH 'no data exists' DISPLAY LIKE 'E'.
    STOP.
  ELSE.
    gv_lines = lines( gt_body ).
    MESSAGE S001 WITH gv_lines '건이 조회되었습니다.'.
  ENDIF.

  " get text data
  SELECT saknr txt50
    FROM zc302mt0006
    INTO CORRESPONDING FIELDS OF TABLE gt_text
    WHERE bukrs = '1000'
      AND ktopl = 'CAKR'.

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

  IF go_container IS NOT BOUND.
    " PK  F_NAME COL_TXT JUST  EMPH
    PERFORM field_catalog USING: 'X' 'BUKRS' '회사 코드' ' ' ' ',
                                 'X' 'BELNR' '전표 번호' ' ' ' ',
                                 'X' 'GJAHR' '회계 연도' ' ' ' ',
                                 'X' 'BUZEI' '전표 상세 번호' ' ' ' ',
                                 ' ' 'BLART' '전표 유형' ' ' ' ',
                                 ' ' 'BLDAT' '전표 전기일' ' ' ' ',
                                 ' ' 'BUDAT' '전표 증빙일' ' ' ' ',
                                 ' ' 'BKTXT' '전표 헤더 텍스트' ' ' ' ',
                                 ' ' 'KOART' '계정 유형' ' ' ' ',
                                 ' ' 'SHKZG' '차/대' ' ' 'X',
                                 ' ' 'PRICE' '금액' ' ' ' ',
                                 ' ' 'WAERS' '통화' ' ' ' ',
                                 ' ' 'BPCODE' 'BP CODE' ' ' ' ',
                                 ' ' 'HKONT' '계정 코드' ' ' ' ',
                                 ' ' 'TXT50' '계정 과목' ' ' ' ',
                                 ' ' 'EMP_NUM' '담당자' ' ' ' ',
                                 ' ' 'AUGBL' '반제 전표 번호' ' ' ' ',
                                 ' ' 'AUGDT' '전표 반제일' ' ' ' ',
                                 ' ' 'STBLG' '역분개 전표 번호' ' ' ' ',
                                 ' ' 'STGRD' '역분개 사유' ' ' ' ',
                                 ' ' 'ZISDN' '임시 전표 번호' ' ' ' ',
                                 ' ' 'ZISDD' '임시 전표 생성일' ' ' ' '.

    PERFORM set_layout.
    PERFORM create_object.

    SET HANDLER : lcl_event_handler=>top_of_page FOR go_alv_grid.

    CALL METHOD go_alv_grid->set_table_for_first_display
      EXPORTING
        i_default       = 'X'
        is_layout       = gs_layo
      CHANGING
        it_outtab       = gt_body
        it_fieldcatalog = gt_fcat.

    PERFORM register_event.

  ELSE.
    CALL METHOD go_alv_grid->refresh_table_display.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM field_catalog  USING  pv_key pv_fname pv_ctxt pv_just pv_emph.
  CLEAR: gs_fcat.
  gs_fcat-key = pv_key.
  gs_fcat-fieldname = pv_fname.
  gs_fcat-coltext = pv_ctxt.
  gs_fcat-emphasize = pv_emph.
  gs_fcat-just = pv_just.
  CASE pv_fname.
    WHEN 'PRICE'.
      gs_fcat-cfieldname = 'WAERS'.
  ENDCASE.

  APPEND gs_fcat TO gt_fcat.
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
  gs_layo-zebra = abap_true.
  gs_layo-cwidth_opt = 'A'.
  gs_layo-sel_mode = 'D'.
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

  CREATE OBJECT go_top_cont
    EXPORTING
      repid     = sy-cprog
      dynnr     = sy-dynnr
      side      = go_top_cont->dock_at_top
      extension = 60.

  CREATE OBJECT go_container
    EXPORTING
      side      = go_container->dock_at_left
      extension = 5000.

  CREATE OBJECT go_alv_grid
    EXPORTING
      i_parent = go_container.

* Create TOP-Document
  CREATE OBJECT go_dyndoc_id
    EXPORTING
      style = 'ALV_GRID'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_text_field
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_text_field.

  LOOP AT gt_body INTO gs_body.
    gv_tabix = sy-tabix.
    CLEAR: gs_text.
    READ TABLE gt_text INTO gs_text WITH KEY saknr = gs_body-hkont.
    IF sy-subrc = 0.
      gs_body-txt50 = gs_text-txt50.
      MODIFY gt_body FROM gs_body INDEX gv_tabix
                                  TRANSPORTING txt50.
    ENDIF.
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

  DATA : lr_dd_table TYPE REF TO cl_dd_table_element,
         col_field   TYPE REF TO cl_dd_area,
         col_value   TYPE REF TO cl_dd_area.

  DATA : lv_text TYPE sdydo_text_element.

  CALL METHOD go_dyndoc_id->add_table
    EXPORTING
      no_of_columns = 2
      border        = '0'
    IMPORTING
      table         = lr_dd_table.

  " Set column
  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_field.

  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_value.



  " Add row  - 회사 코드
  READ TABLE so_bukrs INDEX 1.
  CASE so_bukrs-option.
    WHEN 'EQ'.
      lv_text = so_bukrs-low.
    WHEN 'BT'.
      CONCATENATE so_bukrs-low ' ~ ' so_bukrs-high INTO lv_text.
    WHEN OTHERS.
      lv_text = '전체 조회'.
  ENDCASE.
  PERFORM add_row USING lr_dd_table col_field col_value '회사 코드' lv_text.

  " Add row - 회계 연도
  READ TABLE so_gjahr INDEX 1.
  CASE so_gjahr-option.
    WHEN 'EQ'.
      lv_text = so_gjahr-low.
    WHEN 'BT'.
      CONCATENATE so_gjahr-low '년 ~ ' so_gjahr-high '년' INTO lv_text.
    WHEN OTHERS.
      lv_text = '전체 조회'.
  ENDCASE.
  PERFORM add_row USING lr_dd_table col_field col_value '회계 연도' lv_text.

  " Add row - 전표 번호
  READ TABLE so_belnr INDEX 1.
  CASE so_belnr-option.
    WHEN 'EQ'.
      lv_text = so_belnr-low.
    WHEN 'BT'.
      CONCATENATE so_belnr-low ' ~ ' so_belnr-high INTO lv_text.
    WHEN OTHERS.
      lv_text = '전체 조회'.
  ENDCASE.
  PERFORM add_row USING lr_dd_table col_field col_value '전표 번호' lv_text.

  " Add row - 전표 상세 번호
  READ TABLE so_buzei INDEX 1.
  CASE so_buzei-option.
    WHEN 'EQ'.
      lv_text = so_buzei-low.
    WHEN 'BT'.
      CONCATENATE so_buzei-low ' ~ ' so_buzei-high INTO lv_text.
    WHEN OTHERS.
      lv_text = '전체 조회'.
  ENDCASE.
  PERFORM add_row USING lr_dd_table col_field col_value '전표 상세 번호' lv_text.

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
*&      --> LV_TEXT
*&---------------------------------------------------------------------*
FORM add_row  USING    pr_dd_table  TYPE REF TO cl_dd_table_element
                       pv_col_field TYPE REF TO cl_dd_area
                       pv_col_value TYPE REF TO cl_dd_area
                       pv_field
                       pv_text.

  DATA : lv_text TYPE sdydo_text_element.

*-- Field.
  lv_text = pv_field.

  CALL METHOD pv_col_field->add_text
    EXPORTING
      text         = lv_text
      sap_emphasis = cl_dd_document=>strong
      sap_color    = cl_dd_document=>list_heading_inv.

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
* Creating html control
  IF go_html_cntrl IS INITIAL.
    CREATE OBJECT go_html_cntrl
      EXPORTING
        parent = go_top_cont.
  ENDIF.

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
    MESSAGE s001 WITH 'Top of Page Error' DISPLAY LIKE 'E'.
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

  CALL METHOD go_alv_grid->list_processing_events
    EXPORTING
      i_event_name = 'TOP_OF_PAGE'
      i_dyndoc_id  = go_dyndoc_id.
ENDFORM.
