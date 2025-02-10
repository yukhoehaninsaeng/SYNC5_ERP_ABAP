*&---------------------------------------------------------------------*
*& Include          ZC302RPFI0006F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form compose_url
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM compose_url .
  " url 구성
  CONCATENATE 'https://www.koreaexim.go.kr/site/program/financial/exchangeJSON?authkey=K48kA7yDxcFwCWEzwOUDQ6d5ZUQX8yWk&searchdate'
            sy-datum '&data=AP01' INTO gv_url.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_http
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_http .
  CALL METHOD cl_http_client=>create_by_url
    EXPORTING
      url                = gv_url       " Url을 통한 직접 통신
    IMPORTING
      client             = go_client    " interface 설정
    EXCEPTIONS
      argument_not_found = 1
      plugin_not_active  = 2
      internal_error     = 3
      pse_not_found      = 4
      pse_not_distrib    = 5
      pse_errors         = 6
      OTHERS             = 7.

  " 실패 시 에러 메시지
  IF sy-subrc <> 0.
    MESSAGE s001 WITH 'HTTP Error' DISPLAY LIKE'E'.
    RETURN.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_request_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_request_header .
  " Request 구성 - 메서드는 get으로 설정
  CALL METHOD go_client->request->set_method
    EXPORTING
      method = if_http_request=>co_request_method_get.

  " 헤더 구성
  go_client->request->set_header_field(
    EXPORTING
      name  = 'Content-Type'
      value = 'application/json'         " 데이터 저장 형식 선언
  ).

  " authorization: 자격 증명 설정 ( api 제공하는 site에서 발급 받아야 함 )
  go_client->request->set_header_field(
    EXPORTING
      name  = 'Authorization'
      value = 'K48kA7yDxcFwCWEzwOUDQ6d5ZUQX8yWk'   " API key
  ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form http_send_receive
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM http_send_receive .

  " send
  CALL METHOD go_client->send
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3
      http_invalid_timeout       = 4
      OTHERS                     = 5.

  " 실패 시 에러 메시지
  IF sy-subrc <> 0.
    CALL METHOD go_client->get_last_error
      IMPORTING
        message = gv_message.
    MESSAGE s000 WITH gv_message DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  " receive
  CALL METHOD go_client->receive
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3
      OTHERS                     = 4.

  " 실패 시 에러 메시지
  IF sy-subrc <> 0.
    CALL METHOD go_client->get_last_error
      IMPORTING
        message = gv_message.
    MESSAGE s000 WITH gv_message DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_response
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_response .
  " 응답이 온 경우에 메세드를 실행해서
  " 응답 데이터를 gv_res_json에 담음
  IF go_client->response IS NOT INITIAL.
    CALL METHOD go_client->response->if_http_entity~get_cdata
      RECEIVING
        data = gv_res_json.
  ELSE.
    MESSAGE s001 WITH '데이터가 존재하지 않습니다.' DISPLAY LIKE 'E'.
  ENDIF.

  " api로 받아온 데이터의 형식을 itab 형식으로 담아내기
  CALL METHOD /ui2/cl_json=>deserialize
    EXPORTING
      json = gv_res_json
    CHANGING
      data = gt_res.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_data .

  LOOP AT gt_res INTO gs_res.
    " json으로 받아오는 response의 데이터는 string 타입이라 ,가 문자열로 존재하는데
    " db table의 exrate의 데이터 타입과 호환되지 않아서 아래의 replace 구문 사용
    REPLACE ALL OCCURRENCES OF ',' IN: gs_res-bkpr WITH ''.
    gv_tabix = sy-tabix.
    gs_body-nation = gs_res-cur_nm.
    CASE gs_res-cur_unit.
      WHEN 'IDR(100)'.
        gs_body-fcurr = 'IDR'.
      WHEN 'JPY(100)'.
        gs_body-fcurr = 'JPY'.
      WHEN OTHERS.
        gs_body-fcurr = gs_res-cur_unit.
    ENDCASE.
    gs_body-tcurr = 'KRW'.
    gs_body-exrate = gs_res-bkpr.
    gs_body-edate = sy-datum.
    gs_body-waers = 'KRW'.
    gs_body-erdat = sy-datum.
    gs_body-erzet = sy-uzeit.
    gs_body-ernam = sy-uname.
    APPEND gs_body TO gt_body.
  ENDLOOP.

  MODIFY zc302fit0005 FROM TABLE gt_body.
  IF sy-subrc = 0.
    MESSAGE s001 WITH 'DB 저장 완료'.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE s001 WITH 'DB 저장 실패'.
    ROLLBACK WORK.
  ENDIF.

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
  " 데이터 저장 전 CLEAR
  CLEAR: gs_body, gt_body.

  " selection screen 조회 조건에 맞는 데이터 불러오기
      " 국가, 기존 통화, 변환 통화, 환율 적용일, 환율, 통화, 생성일, 생성시 ,생성인
  SELECT nation fcurr tcurr edate exrate waers erdat erzet ernam
    FROM zc302fit0005
    INTO CORRESPONDING FIELDS OF TABLE gt_body
    WHERE edate IN so_edate.

  " 테이블에 데이터가 존재하면 행 개수 표시, 존재하지 않으면 에러 메시지 표시
  IF gt_body IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
    STOP.
  ELSE.
    gv_lines = lines( gt_body ).
    MESSAGE s001 WITH gv_lines TEXT-t01.
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
  " container가 존재하는지 체크
  IF  go_container IS NOT BOUND.
    " 필드 카탈로그 세팅
                                 "key  field    col_text  just  emph
    PERFORM field_catalog USING : 'X' 'NATION' '국가 및 통화명' ' ' ' ',
                                  'X' 'FCURR' '기존 통화' 'C' ' ',
                                  'X' 'TCURR' '변환 통화' 'C' ' ',
                                  'X' 'EDATE' '환율 적용일' 'C' ' ',
                                  'X' 'EXRATE' '환율' ' ' 'X',
                                  ' ' 'ERDAT' '생성일'  ' ' ' ',
                                  ' ' 'ERZET' '생성시간'  ' ' ' ',
                                  ' ' 'ERNAM' '생성자'  ' ' ' '.
    " 테이블 레이아웃 설정
    PERFORM set_layout.
    " 오브젝트 생성
    PERFORM create_object.

    " 이벤트 핸들러 등록
    SET HANDLER : lcl_event_handler=>top_of_page  FOR go_alv_grid. " 어떤 ALV에 붙이던 상관없음

    " TOP OF PAGE 이벤트 처리
    CALL METHOD go_dyndoc_id->initialize_document
      EXPORTING
        background_color = cl_dd_area=>col_textarea.

    CALL METHOD go_alv_grid->list_processing_events
      EXPORTING
        i_event_name = 'TOP_OF_PAGE'
        i_dyndoc_id  = go_dyndoc_id.

    " ALV 화면에 보여주기
    CALL METHOD go_alv_grid->set_table_for_first_display
      EXPORTING
        i_default       = 'X'
        is_layout       = gs_layo
      CHANGING
        it_outtab       = gt_body
        it_fieldcatalog = gt_fcat.
  ELSE.
    " 컨테이너가 존재하는 경우 REFRESH
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
FORM field_catalog  USING pv_key pv_fname pv_ctxt pv_just pv_emph .

  CLEAR: gs_fcat.

  gs_fcat-key = pv_key.
  gs_fcat-fieldname = pv_fname.
  gs_fcat-coltext = pv_ctxt.
  gs_fcat-emphasize = pv_emph.
  gs_fcat-just = pv_just.

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

  CLEAR : gs_layo.
  gs_layo-zebra = abap_true.        " 줄무늬 표시
  gs_layo-cwidth_opt = 'A'.         " Cell 너비 자동 설정
  gs_layo-sel_mode = 'D'.           " 다중 선택
  gs_layo-grid_title = '환율'.       " alv 타이틀 설정
  gs_layo-smalltitle = abap_true.   " alv 타이틀 작게 설정

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
  " top of page 컨테이너 생성
  CREATE OBJECT go_top_container
    EXPORTING
      repid     = sy-cprog
      dynnr     = sy-dynnr
      side      = go_top_container->dock_at_top
      extension = 30. " Top of page 높이

   " 데이터 보여줄 컨테이너 생성
  CREATE OBJECT go_container
    EXPORTING
      side      = go_container->dock_at_left
      extension = 5000.

  " alv grid 생성
  CREATE OBJECT go_alv_grid
    EXPORTING
      i_parent = go_container.

  " Top-of-page : Create TOP-Document
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
  so_edate = VALUE #( so_edate[ 1 ] OPTIONAL ).
  CLEAR : lv_temp.
  IF so_edate-low IS NOT INITIAL.
    lv_temp = so_edate-low.
    IF so_edate-high IS NOT INITIAL.
      CONCATENATE lv_temp ' ~ ' so_edate-high INTO lv_temp.
    ENDIF.
  ELSE.
    lv_temp = '전체'.
  ENDIF.
  PERFORM add_row USING lr_dd_table col_field col_value '환율 적용일' lv_temp.

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
