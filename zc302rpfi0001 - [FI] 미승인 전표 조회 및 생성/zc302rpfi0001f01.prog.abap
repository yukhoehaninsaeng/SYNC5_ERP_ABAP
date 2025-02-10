*&---------------------------------------------------------------------*
*& Form set_okcode
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_mode .
  " 1000번 스크린에 따른 분기
  LOOP AT SCREEN.
    CASE 'X'.
      WHEN pa_sell.
        gv_mode = 'SELL'.
        ASSIGN gs_billing TO <fs_wa> CASTING LIKE gs_billing.
        ASSIGN gt_billing TO <fs_itab>.
        ASSIGN COMPONENT 'ICON' OF STRUCTURE gs_billing TO <fs_icon>.
        ASSIGN COMPONENT 'BPCODE' OF STRUCTURE gs_billing TO <fs_bpcode>.
        ASSIGN COMPONENT 'WAERS' OF STRUCTURE gs_billing  TO <fs_waers>.
        ASSIGN COMPONENT 'IVFLAG' OF STRUCTURE gs_billing TO <fs_ivflag>.
        ASSIGN COMPONENT 'BILNUM' OF STRUCTURE gs_billing TO <fs_docno>.
        ASSIGN COMPONENT 'NETWR' OF STRUCTURE gs_billing TO <fs_net_cash>.
        ASSIGN COMPONENT 'AEDAT' OF STRUCTURE gs_billing TO <fs_aedat>.
        ASSIGN COMPONENT 'AEZET' OF STRUCTURE gs_billing TO <fs_aezet>.
        ASSIGN COMPONENT 'AENAM' OF STRUCTURE gs_billing TO <fs_aenam>.
        ASSIGN 'AR' TO <fs_sptyp>.

      WHEN pa_buy.
        gv_mode = 'BUY'.
        ASSIGN gs_songjang TO <fs_wa> CASTING LIKE gs_songjang.
        ASSIGN gt_songjang TO <fs_itab>.
        ASSIGN COMPONENT 'ICON' OF STRUCTURE gs_songjang TO <fs_icon>.
        ASSIGN COMPONENT 'BPCODE' OF STRUCTURE gs_songjang TO <fs_bpcode>.
        ASSIGN COMPONENT 'WAERS' OF STRUCTURE gs_songjang  TO <fs_waers>.
        ASSIGN COMPONENT 'IVFLAG' OF STRUCTURE gs_songjang TO <fs_ivflag>.
        ASSIGN COMPONENT 'DOCXBN' OF STRUCTURE gs_songjang TO <fs_docno>.
        ASSIGN COMPONENT 'NETWR' OF STRUCTURE gs_songjang TO <fs_net_cash>.
        ASSIGN COMPONENT 'AEDAT' OF STRUCTURE gs_songjang TO <fs_aedat>.
        ASSIGN COMPONENT 'AEZET' OF STRUCTURE gs_songjang TO <fs_aezet>.
        ASSIGN COMPONENT 'AENAM' OF STRUCTURE gs_songjang TO <fs_aenam>.
        ASSIGN 'AP' TO <fs_sptyp>.
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
  CASE gv_mode.

    WHEN 'BUY'.
      CASE 'X'.
        WHEN pa_all.    " 전체
          SELECT * FROM zc302mmt0009
            INTO CORRESPONDING FIELDS OF TABLE <fs_itab>
            WHERE bpcode IN so_bpcd
              AND instatus = 'A'.

        WHEN pa_not.    " 미발행
          SELECT * FROM zc302mmt0009
            INTO CORRESPONDING FIELDS OF TABLE <fs_itab>
            WHERE bpcode IN so_bpcd
              AND ivflag = 'N'
              AND  instatus = 'A'.

        WHEN pa_yes.    " 발행
          SELECT * FROM zc302mmt0009
            INTO CORRESPONDING FIELDS OF TABLE <fs_itab>
            WHERE bpcode IN so_bpcd
              AND ivflag = 'Y'
              AND instatus = 'A'.
      ENDCASE.
      SORT gt_songjang BY ivflag ASCENDING bpcode ASCENDING bldat DESCENDING.

    WHEN 'SELL'.
      CASE 'X'.
        WHEN pa_all.    " 전체
          SELECT * FROM zc302sdt0009
            INTO CORRESPONDING FIELDS OF TABLE <fs_itab>
            WHERE bpcode IN so_bpcd.

        WHEN pa_not.    " 미발행
          SELECT * FROM zc302sdt0009
            INTO CORRESPONDING FIELDS OF TABLE <fs_itab>
            WHERE bpcode IN so_bpcd
              AND ivflag = 'N'.

        WHEN pa_yes.    " 발행
          SELECT * FROM zc302sdt0009
            INTO CORRESPONDING FIELDS OF TABLE <fs_itab>
            WHERE bpcode IN so_bpcd
              AND ivflag = 'Y'.
      ENDCASE.

      " 데이터 정렬
      SORT gt_billing BY ivflag ASCENDING bpcode ASCENDING bldat DESCENDING.
  ENDCASE.

  SELECT * FROM zc302fit0004
        INTO CORRESPONDING FIELDS OF TABLE gt_body
        WHERE sptyp = <fs_sptyp>.

  " 데이터 정렬 ( 최신 순 )
  SORT gt_body BY zisdd DESCENDING.

  gv_lines = lines( <fs_itab> ).

  " 데이터가 존재하지 않을 시 에러 메시지
  IF <fs_itab> IS INITIAL.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.
    EXIT.
  ELSE.
    MESSAGE s001 WITH gv_lines '건이 조회되었습니다.'.
  ENDIF.

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
    PERFORM set_layout.
    PERFORM create_object.

    " 매입처인지 매출처인지에 따라 왼쪽 ALV에 다른 field_catalog가 필요함.
    CASE gv_mode.
      WHEN 'SELL'.
        PERFORM field_catalog_left USING: 'X' 'ICON' 'ICON' '발행 여부' ' ' ' ',
                                          'X' 'BILNUM' 'ZC302SDT0009' '대금 청구 번호' ' ' 'C',
                                          ' ' 'SALE_ORG' 'ZC302SDT0009' '영업 조직' ' ' ' ',
                                          ' ' 'CHANNEL' 'ZC302SDT0009' '유통 채널' ' ' ' ',
                                          ' ' 'SONUM' 'ZC302SDT0009' '판매 주문 번호' 'X' ' ',
                                          ' ' 'BPCODE' 'ZC302SDT0009' 'BP코드' ' ' ' ',
                                          ' ' 'NETWR' 'ZC302SDT0009' '총 금액' ' ' ' ',
                                          ' ' 'WAERS' 'ZC302SDT0009' '통화' ' ' ' ',
                                          ' ' 'BLDAT' 'ZC302SDT0009' '날짜' ' ' ' '.
      WHEN 'BUY'.
        " 송장 검증 테이블
        PERFORM field_catalog_left USING: 'X' 'ICON' 'ICON' '발행 여부' ' ' ' ',
                                          'X' 'DOCXBN' 'ZC302MMT0009' '송장 검증 번호' ' ' 'C',
                                          ' ' 'BPCODE' 'ZC302MMT0009' 'BP 코드' ' ' ' ',
                                          ' ' 'BLDAT' 'ZC302MMT0009' '송장 일자' ' ' ' ',
                                          ' ' 'AUFNR' 'ZC302MMT0009' '구매 오더 번호' ' ' ' ',
                                          ' ' 'XBLNR' 'ZC302MMT0009' '송장번호' 'X' ' ',
                                          ' ' 'MATNR' 'ZC302MMT0009' '자재 코드' ' ' ' ',
                                          ' ' 'MAKTX' 'ZC302MMT0009' '자재명' ' ' ' ',
                                          ' ' 'W_NUM' 'ZC302MMT0009' '사원 번호' ' ' ' ',
                                          ' ' 'INSTATUS' 'ZC302MMT0009' '상태' ' ' ' ',
                                          ' ' 'QIMENGE' 'ZC302MMT0009' '최종 입고 수량' ' ' ' ',
                                          ' ' 'MEINS' 'ZC302MMT0009' '단위' ' ' ' ',
                                          ' ' 'NETWR' 'ZC302MMT0009' '총 금액' ' ' ' ',
                                          ' ' 'WAERS' 'ZC302MMT0009' '통화' ' ' ' '.
    ENDCASE.
    PERFORM field_catalog_right USING : 'X' 'ZISDN' 'ZC302FIT0004' '미승인 전표 번호' ' ' 'C',
                                        ' ' 'ZISDD' 'ZC302FIT0004' '생성 일자' ' ' ' ',
                                        ' ' 'GJAHR' 'ZC302FIT0004' '전표 연도' ' ' ' ',
                                        ' ' 'ZMONT' 'ZC302FIT0004' '회계 월' ' ' ' ',
                                        ' ' 'BPCODE' 'ZC302FIT0004' 'BP 코드' ' ' ' ',
                                        ' ' 'CNAME' 'ZC302FIT0004' '기업 명' ' ' ' ',
                                        ' ' 'SPTYP' 'ZC302FIT0004' '공급 유형' ' ' ' ',
                                        ' ' 'SPAMT' 'ZC302FIT0004' '공급가액' ' ' ' ',
                                        ' ' 'VADTX' 'ZC302FIT0004' '부가가치세' ' ' ' ',
                                        ' ' 'TOAMT' 'ZC302FIT0004' '합계액' ' ' ' ',
                                        ' ' 'WAERS' 'ZC302FIT0004' '통화' ' ' ' '.
    " 이벤트 등록
    PERFORM register_event.

    " 왼쪽 alv display
    CALL METHOD go_left_grid->set_table_for_first_display
      EXPORTING
        i_default       = 'X'
        is_layout       = gs_layo
      CHANGING
        it_outtab       = <fs_itab>
        it_fieldcatalog = gt_fcat_left.

    " 오른쪽 alv display
    CALL METHOD go_right_grid->set_table_for_first_display
      EXPORTING
        i_default       = 'X'
        is_layout       = gs_layo
      CHANGING
        it_outtab       = gt_body
        it_fieldcatalog = gt_fcat_right.

  ELSE.
    CALL METHOD go_left_grid->refresh_table_display.
    CALL METHOD go_right_grid->refresh_table_display.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_catalog_left
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
FORM field_catalog_left  USING  pv_key pv_field pv_table
                                pv_coltext pv_emph pv_just.

  CLEAR: gs_fcat_left.
  gs_fcat_left-key = pv_key.
  gs_fcat_left-fieldname = pv_field.
  gs_fcat_left-ref_table = pv_table.
  gs_fcat_left-coltext = pv_coltext.
  gs_fcat_left-emphasize = pv_emph.
  gs_fcat_left-just = pv_just.
  CASE pv_field.
    WHEN 'NETWR'.
      gs_fcat_left-cfieldname = 'WAERS'.
  ENDCASE.

  APPEND gs_fcat_left TO gt_fcat_left.

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
  CLEAR: gs_layo.
  gs_layo-zebra = 'X'.
  gs_layo-sel_mode = 'D'.
  gs_layo-cwidth_opt = 'A'.
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
  " Top of Page Container
  CREATE OBJECT go_top_container
    EXPORTING
      repid     = sy-cprog
      dynnr     = sy-dynnr
      side      = go_top_container->dock_at_top
      extension = 70.                 " Top of page 높이 설정

  " alv 붙일  container
  CREATE OBJECT go_container
    EXPORTING
      side      = go_container->dock_at_left
      extension = 5000.

  CREATE OBJECT go_split_container
    EXPORTING
      parent  = go_container
      rows    = 1
      columns = 2.

  CALL METHOD go_split_container->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_left_container.

  CALL METHOD go_split_container->get_container
    EXPORTING
      row       = 1
      column    = 2
    RECEIVING
      container = go_right_container.

  CREATE OBJECT go_left_grid
    EXPORTING
      i_parent = go_left_container.

  CREATE OBJECT go_right_grid
    EXPORTING
      i_parent = go_right_container.

*-- Top-of-page : Create TOP-Document(!!맨 마지막에!! 작성)
  CREATE OBJECT go_dyndoc_id
    EXPORTING
      style = 'ALV_GRID'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_catalog_right
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
FORM field_catalog_right  USING pv_key pv_field pv_table
                                pv_coltext pv_emph pv_just.

  CLEAR: gs_fcat_right.
  gs_fcat_right-key = pv_key.
  gs_fcat_right-fieldname = pv_field.
  gs_fcat_right-ref_table = pv_table.
  gs_fcat_right-coltext = pv_coltext.
  gs_fcat_right-emphasize = pv_emph.
  gs_fcat_right-just = pv_just.

  CASE pv_field.
    WHEN 'TOAMT'.
      gs_fcat_right-cfieldname = 'WAERS'.
    WHEN 'VADTX'.
      gs_fcat_right-cfieldname = 'WAERS'.
    WHEN 'SPAMT'.
      gs_fcat_right-cfieldname = 'WAERS'.
  ENDCASE.

  APPEND gs_fcat_right TO gt_fcat_right.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EVENT_TOP_OF_PAGE
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


  " Top of Page의 레이아웃 세팅
  " Top of page의 보여줄 테이블 생성
  CALL METHOD go_dyndoc_id->add_table
    EXPORTING
      no_of_columns = 3
      border        = '0'
    IMPORTING
      table         = lr_dd_table.

  " 해당 테이블의 column 설정
  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_field.

  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_value.

  " Top of Page 레이아웃에 맞는 값 세팅
  " 문서 종류 , 문서 번호 설정
  IF pa_buy = 'X'.    " 라디오 버튼 값에 따른 분기
    PERFORM add_row USING lr_dd_table col_field col_value '문서 종류' '매입처'.
  ELSE.
    PERFORM add_row USING lr_dd_table col_field col_value '문서 종류' '매출처'.
  ENDIF.

  IF pa_all = 'X'.
    PERFORM add_row USING lr_dd_table col_field col_value '발행 여부' '전체'.
  ELSEIF pa_not = 'X'.
    PERFORM add_row USING lr_dd_table col_field col_value '발행 여부' '미발행'.
  ELSE.
    PERFORM add_row USING lr_dd_table col_field col_value '발행 여부' '발행'.
  ENDIF.


  so_bpcd = VALUE #( so_bpcd[ 1 ] OPTIONAL ).
  CLEAR : lv_temp.
  IF so_bpcd-low IS NOT INITIAL.
    lv_temp = so_bpcd-low.
    IF so_bpcd-high IS NOT INITIAL.
      CONCATENATE lv_temp ' ~ ' so_bpcd-high INTO lv_temp.
    ENDIF.
  ELSE.
    lv_temp = '전체'.
  ENDIF.
  PERFORM add_row USING lr_dd_table col_field col_value '거래처 코드' lv_temp.

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
*&      --> P_
*&---------------------------------------------------------------------*
FORM add_row  USING    pr_dd_table TYPE REF TO cl_dd_table_element
                       pv_col_field   TYPE REF TO cl_dd_area
                       pv_col_value   TYPE REF TO cl_dd_area
                       pv_field
                       pv_text.
  DATA: lv_text TYPE sdydo_text_element.

  " Field에 값 세팅
  lv_text = pv_field.
  CALL METHOD pv_col_field->add_text
    EXPORTING
      text         = lv_text
      sap_color    = cl_dd_document=>list_heading_inv
      sap_emphasis = cl_dd_document=>strong.

  CALL METHOD pv_col_field->add_gap
    EXPORTING
      width = 3.

  " Value에 값 세팅
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
    MESSAGE s001 WITH 'Top OF PAGE EVENT error' DISPLAY LIKE 'E'.
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
  SET HANDLER : lcl_event_handler=>top_of_page FOR go_left_grid,
                lcl_event_handler=>toolbar_imsi FOR go_left_grid,
                lcl_event_handler=>user_command FOR go_left_grid.

  CALL METHOD go_dyndoc_id->initialize_document
    EXPORTING
      background_color = cl_dd_area=>col_textarea.

  CALL METHOD go_left_grid->list_processing_events
    EXPORTING
      i_event_name = 'TOP_OF_PAGE'
      i_dyndoc_id  = go_dyndoc_id.

  CALL METHOD go_left_grid->set_toolbar_interactive.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_toolbar_imsi
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM handle_toolbar_imsi  USING po_object TYPE REF TO cl_alv_event_toolbar_set
                                pv_interactive.

  CLEAR : gs_button.
  gs_button-function = 'CRTE'.
  gs_button-icon = icon_write_file.
  gs_button-quickinfo = '미승인 전표 생성'.
  gs_button-text = TEXT-t03.

  APPEND gs_button TO po_object->mt_toolbar.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_user_command
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM handle_user_command  USING    pv_ucomm.

  CASE pv_ucomm.
    WHEN 'CRTE'.
      PERFORM create_imsi.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_imsi
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_imsi .
  " 선택된 행을 읽어올 용도의 변수
  DATA: ls_rowno     TYPE lvc_s_row,
        lt_rowno     TYPE lvc_t_row,
        lv_answer(3).

  " 선택된 행의 index값 저장
  CALL METHOD go_left_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_rowno.
  gv_lines = lines( lt_rowno ).

  " 선택된 행의 개수 체크
  IF gv_lines > 1.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
    EXIT.
  ELSEIF gv_lines = 0.
    MESSAGE s001 WITH TEXT-e04 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  " 행의 인덱스 값을 읽어서 해당 문서의 번호를 알아옴.
  READ TABLE lt_rowno INTO ls_rowno INDEX 1.
  READ TABLE <fs_itab> INTO <fs_wa> INDEX ls_rowno-index.

  " 임시 전표 발행 여부 확인
  IF <fs_ivflag> = 'Y'.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  " 발행 확인을 위한 팝업 창 띄우기
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      text_question         = '미승인 전표를 생성하시겠습니까?'
      text_button_1         = '전표 생성'(001)
      icon_button_1         = 'ICON_CHECKED'
      text_button_2         = '생성 취소'(002)
      icon_button_2         = 'ICON_INCOMPLETE'
      default_button        = '1'
      display_cancel_button = ' '
    IMPORTING
      answer                = lv_answer.

  IF lv_answer <> 1.
    MESSAGE s001 WITH TEXT-e07 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  " 임시 전표 생성
  CLEAR: gs_body.
  gs_body-zisdn = <fs_docno>.
  gs_body-zisdd = sy-datum.
  gs_body-gjahr = sy-datum+0(4).
  gs_body-zmont = sy-datum+4(2).
  gs_body-bpcode = <fs_bpcode>.
  SELECT SINGLE cname FROM zc302mt0001
    INTO gs_body-cname
    WHERE bpcode = <fs_bpcode>.
  gs_body-sptyp = <fs_sptyp>.
  CASE gv_mode.
    WHEN 'SELL'.
      gs_body-spamt = <fs_net_cash> / gv_tax_rate.
      gs_body-vadtx = <fs_net_cash> - gs_body-spamt.
  ENDCASE.
  gs_body-toamt = <fs_net_cash>.
  gs_body-waers = <fs_waers>.
  gs_body-jpflag = 'N'.
  gs_body-erdat = sy-datum.
  gs_body-erzet = sy-uzeit.
  gs_body-ernam = sy-uname.
  APPEND gs_body TO gt_body.

  "alv display refresh
  SORT gt_body BY zisdd DESCENDING erzet DESCENDING.
  CALL METHOD go_right_grid->refresh_table_display.

  " db 반영 - 임시 전표 테이블
  MODIFY zc302fit0004 FROM TABLE gt_body.

  " db 반영 실패 시
  IF sy-subrc NE 0.
    ROLLBACK WORK.
    MESSAGE s001  WITH TEXT-e06 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  " 성공 시 임시 전표 발행 여부 Y 표시
  <fs_icon> = icon_led_green.
  <fs_ivflag> = 'Y'.
  <fs_aedat> = sy-datum.
  <fs_aezet> = sy-uzeit.
  <fs_aenam> = sy-uname.

  " db 테이블 반영 ( 각각 송장 검증 or billing ).
  MODIFY <fs_itab> FROM <fs_wa> INDEX ls_rowno-index.
  CASE gv_mode.
    WHEN 'BUY'.
      MODIFY zc302mmt0009 FROM TABLE <fs_itab>.
    WHEN 'SELL'.
      MODIFY zc302sdt0009 FROM TABLE <fs_itab>.
    WHEN OTHERS.
  ENDCASE.

  IF sy-subrc = 0.
    MESSAGE s001 WITH TEXT-t07.
    COMMIT WORK AND WAIT.
    CALL METHOD go_left_grid->refresh_table_display.
  ELSE.
    ROLLBACK WORK.
    MESSAGE s001 WITH TEXT-e06 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form on_f4_bpcode_low
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM on_f4_bpcode_low .

  DATA: lt_return TYPE TABLE OF ddshretval WITH HEADER LINE,
        BEGIN OF ls_bpcode,
          bpcode TYPE zc302mt0001-bpcode,
          cname  TYPE zc302mt0001-cname,
        END OF ls_bpcode,
        lt_bpcode LIKE TABLE OF ls_bpcode.

  SELECT bpcode cname
    INTO CORRESPONDING FIELDS OF TABLE lt_bpcode
    FROM zc302mt0001.

  IF sy-subrc = 0.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = 'BPCODE'
        dynpprog        = sy-repid
        dynpnr          = sy-dynnr
        window_title    = '거래처 목록'
        value_org       = 'S'
      TABLES
        value_tab       = lt_bpcode
        return_tab      = lt_return
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.

    lt_return = VALUE #( lt_return[ 1 ] OPTIONAL ).
    so_bpcd-low = lt_return-fieldval.

  ELSE.
    MESSAGE  s001 WITH TEXT-e01.
    EXIT.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form on_f4_bpcode_high
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM on_f4_bpcode_high .
  DATA: lt_return_high TYPE TABLE OF ddshretval WITH HEADER LINE,
        BEGIN OF ls_bpcode,
          bpcode TYPE zc302mt0001-bpcode,
          cname  TYPE zc302mt0001-cname,
        END OF ls_bpcode,
        lt_bpcode LIKE TABLE OF ls_bpcode.

  SELECT bpcode cname
    INTO CORRESPONDING FIELDS OF TABLE lt_bpcode
    FROM zc302mt0001.

  IF sy-subrc = 0.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = 'BPCODE'
        dynpprog        = sy-repid
        dynpnr          = sy-dynnr
        window_title    = '거래처 목록'
        value_org       = 'S'
      TABLES
        value_tab       = lt_bpcode
        return_tab      = lt_return_high
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.

    lt_return_high = VALUE #( lt_return_high[ 1 ] OPTIONAL ).
    so_bpcd-high = lt_return_high-fieldval.

  ELSE.
    MESSAGE  s001 WITH TEXT-e01.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_sub_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_sub_data .
  DATA : ls_bpcode TYPE zc302mt0001,
         lt_bpcode TYPE TABLE OF zc302mt0001.

  SELECT * FROM zc302mt0001
    INTO CORRESPONDING FIELDS OF TABLE lt_bpcode.

  " 아이콘 설정 및 텍스트 테이블에서 값 불러오기
  LOOP AT <fs_itab> INTO <fs_wa>.
    gv_tabix = sy-tabix.

    CASE <fs_ivflag>.
      WHEN 'Y'.
        <fs_icon> = icon_led_green.
      WHEN OTHERS.
        <fs_icon> = icon_led_red.
    ENDCASE.

    MODIFY <fs_itab> FROM <fs_wa> INDEX gv_tabix.
  ENDLOOP.

  LOOP AT gt_body INTO gs_body.
    gv_tabix = sy-tabix.

    " 마스터 테이블에서 값 가져오기
    READ TABLE lt_bpcode INTO ls_bpcode WITH KEY bpcode = gs_body-bpcode.

    " 회사 이름 세팅하고 테이블에 값 적용
    IF sy-subrc = 0.
      gs_body-cname = ls_bpcode-cname.
      MODIFY gt_body FROM gs_body INDEX gv_tabix TRANSPORTING cname.
    ENDIF.

  ENDLOOP.

ENDFORM.
