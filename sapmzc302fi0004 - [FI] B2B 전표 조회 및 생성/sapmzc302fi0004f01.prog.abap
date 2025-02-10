*&---------------------------------------------------------------------*
*& Include          SAPMZC302FI0004F01
*&---------------------------------------------------------------------*
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
    PERFORM field_catalog_h USING : 'X' 'BUKRS' '회사 코드' ' ' ' ',
                                    'X' 'BELNR' '전표 번호' ' ' ' ',
                                    'X' 'GJAHR' '회계 연도' ' ' ' ',
                                    ' ' 'BLART' '전표 유형' ' ' ' ',
                                    ' ' 'BLDAT' '전표 전기일' ' ' ' ',
                                    ' ' 'BUDAT' '전표 증빙일' ' ' ' ',
                                    ' ' 'BKTXT' '전표 헤더 텍스트' ' ' ' ',
                                    ' ' 'EMP_NUM' '담당자' ' ' ' ',
                                    ' ' 'WAERS' '통화' ' ' ' ',
                                    ' ' 'AUGBL' '반제 전표 번호' ' ' ' ',
                                    ' ' 'AUGDT' '전표 반제일' ' ' ' ',
                                    ' ' 'STBLG' '역분개 전표 번호' ' ' ' ',
                                    ' ' 'STGRD' '역분개 사유' ' ' ' ',
                                    ' ' 'ZISDN' '임시 전표 번호' ' ' ' ',
                                    ' ' 'ZISDD' '임시 전표 생성일' ' ' ' '.
    PERFORM field_catalog_i USING : 'X' 'BUKRS' '회사 코드' ' ' ' ',
                                    'X' 'BELNR' '전표 번호' ' ' ' ',
                                    'X' 'GJAHR' '회계 연도' ' ' ' ',
                                    'X' 'BUZEI' '전표 상세 번호' ' ' ' ',
                                    ' ' 'KOART' '계정 유형' ' ' ' ',
                                    ' ' 'SHKZG' '차/대' ' ' 'X',
                                    ' ' 'PRICE' '금액' ' ' ' ',
                                    ' ' 'WAERS' '통화' ' ' ' ',
                                    ' ' 'BPCODE' 'BP CODE' ' ' ' ',
                                    ' ' 'HKONT' '계정 코드' ' ' ' ',
                                   ' ' 'TXT50' '계정 과목' ' ' ' ',
                                   ' ' 'AUGBL' '반제 전표 번호' ' ' ' ',
                                   ' ' 'AUGDT' '반제 일자' ' ' ' '.
    PERFORM set_layout.
    PERFORM create_object.

    PERFORM register_event.
    PERFORM exclude_buttons TABLES gt_ui_functions.

    CALL METHOD go_up_grid->set_table_for_first_display
      EXPORTING
        i_default       = 'X'
        is_layout       = gs_layo
      CHANGING
        it_outtab       = gt_header
        it_fieldcatalog = gt_h_fcat.

    go_up_grid->set_gridtitle( i_gridtitle = gv_up_title ).

    CALL METHOD go_down_grid->set_table_for_first_display
      EXPORTING
        i_default            = 'X'
        is_layout            = gs_layo
        it_toolbar_excluding = gt_ui_functions
      CHANGING
        it_outtab            = gt_item
        it_fieldcatalog      = gt_i_fcat.

    go_down_grid->set_gridtitle( i_gridtitle = gv_down_title ).

  ELSE.

    CALL METHOD go_up_grid->refresh_table_display.
    CALL METHOD go_down_grid->refresh_table_display.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_catalog_h
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM field_catalog_h  USING pv_key pv_fname pv_ctxt pv_just pv_emph.

  CLEAR: gs_h_fcat.
  gs_h_fcat-key = pv_key.
  gs_h_fcat-fieldname = pv_fname.
  gs_h_fcat-coltext = pv_ctxt.
  gs_h_fcat-emphasize = pv_emph.
  gs_h_fcat-just = pv_just.

  APPEND gs_h_fcat TO gt_h_fcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_catalog_i
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM field_catalog_i  USING  pv_key pv_fname pv_ctxt pv_just pv_emph.

  CLEAR : gs_i_fcat.
  gs_i_fcat-key = pv_key.
  gs_i_fcat-fieldname = pv_fname.
  gs_i_fcat-coltext = pv_ctxt.
  gs_i_fcat-emphasize = pv_emph.
  gs_i_fcat-just = pv_just.
  CASE pv_fname.
    WHEN 'PRICE'.
      gs_i_fcat-cfieldname = 'WAERS'.
    WHEN 'SHKZG'.
      gs_i_fcat-f4availabl = 'X'.
      gs_i_fcat-ref_table = 'ZC302FIT0002'.
    WHEN 'WAERS'.
      gs_i_fcat-f4availabl = 'X'.
    WHEN 'HKONT'.
      gs_i_fcat-f4availabl = 'X'.
  ENDCASE.

  APPEND gs_i_fcat TO gt_i_fcat.

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
  gs_layo-stylefname = 'CELLTAB'.
  gs_layo-smalltitle = 'X'.
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
  " custom container 생성
  CREATE OBJECT go_container
    EXPORTING
      container_name = 'MAIN_CONT'.

  " Split Container 생성
  CREATE OBJECT go_split_container
    EXPORTING
      parent  = go_container
      rows    = 2
      columns = 1.

  " Container 생성
  CALL METHOD go_split_container->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_container_up.

  CALL METHOD go_split_container->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_container_down.

  " alv 생성
  CREATE OBJECT go_up_grid
    EXPORTING
      i_parent = go_container_up.

  CREATE OBJECT go_down_grid
    EXPORTING
      i_parent = go_container_down.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form insert_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM insert_item .

  DATA : ls_item      LIKE gs_item,  " 중복 체크를 위한 변수
         lv_appending TYPE sy-subrc,
         lv_exrate    TYPE zc302fit0005-exrate, " 헤더 값 생성 여부 확인
         lv_number    TYPE nriv.
  " 전표 번호 채번
  IF gv_number IS INITIAL AND
     gv_buzei EQ 1.
    CALL FUNCTION 'NUMBER_GET_INFO'
      EXPORTING
        nr_range_nr = '01'
        object      = 'ZNRC302_2'
      IMPORTING
        interval    = lv_number.

    gv_belnr = lv_number-nrlevel + 1.
    gv_number = lv_number-nrlevel + 1.

    " 헤더 구성
    PERFORM set_header CHANGING lv_appending.

  ELSEIF gv_buzei EQ 1 AND  " db 반영 안 되고 rollback 된 경우
         gv_number IS NOT INITIAL.
    PERFORM set_header CHANGING lv_appending.
  ENDIF.

  IF lv_appending EQ 1.
    EXIT.
  ENDIF.

  " gs_item 구성
  CLEAR : gs_item-txt50.
  gs_item-bukrs = gv_bukrs.
  gs_item-gjahr = gv_gjahr.
  gs_item-belnr = gv_belnr.
  gs_item-buzei = gv_buzei.
  gs_item-koart = gv_koart.
  gs_item-shkzg = gv_shkzg.
  gs_item-erdat = sy-datum.
  gs_item-erzet = sy-uzeit.
  gs_item-ernam = sy-uname.
  " 외화의 경우 환율 적용한 값으로 자동 계산
  IF gv_waers NE 'KRW'.
    SELECT SINGLE exrate FROM zc302fit0005 INTO lv_exrate
                         WHERE fcurr = gv_waers
                           AND edate = gv_bldat.
    IF lv_exrate IS INITIAL.
      SELECT SINGLE exrate FROM zc302fit0005 INTO lv_exrate
                           WHERE fcurr = gv_waers.
      MESSAGE s001 WITH TEXT-e10 DISPLAY LIKE 'E'.
    ENDIF.

    gs_item-waers = 'KRW'.
    gs_item-price = gv_price * lv_exrate / 100.

  ELSE.
    gs_item-waers = 'KRW'.
    gs_item-price = gv_price.
  ENDIF.
  gs_item-bpcode = gv_bpcode.
  gs_item-hkont = gv_hkont.
  SELECT SINGLE txt50 FROM zc302mt0006 INTO gs_item-txt50
                                       WHERE bukrs = '1000'
                                         AND saknr = gv_hkont
                                         AND ktopl = 'CAKR'.

  " 유효성 검사 - 중복 확인
  READ TABLE gt_item INTO ls_item WITH KEY bukrs = gs_item-bukrs
                                           gjahr = gs_item-gjahr
                                           belnr = gs_item-belnr
                                           buzei = gs_item-buzei.

  IF ls_item IS NOT INITIAL.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  " 유효성 검사 2 - 필수 입력 확인
  IF ( gv_shkzg IS INITIAL ) OR
     ( gv_price IS INITIAL ) OR
     ( gv_waers IS INITIAL ) OR
     ( gv_hkont IS INITIAL ).
    MESSAGE s001 WITH '전표 상세 내역을 입력하세요.' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  " 유효한 값에 대해 itab에 append
  APPEND gs_item TO gt_item.
  CASE gs_item-shkzg.
    WHEN 'S'.
      gv_s_sum += gs_item-price.
      gv_s_sum = gv_s_sum * 100.
    WHEN 'H'.
      gv_h_sum += gs_item-price.
      gv_h_sum = gv_h_sum * 100.
  ENDCASE.
  " refresh table display.
  CALL METHOD go_down_grid->refresh_table_display.

  " screen element clearing
  gv_buzei += 1.
  CLEAR : gv_shkzg, gv_price, gv_bpcode, gv_augbl, gv_augdt, gv_hkont.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_document
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_document .

  DATA : lt_header       LIKE TABLE OF gs_header, " 중복 검사를 위한 변수
         ls_header       LIKE gs_header,
         lv_header_subrc TYPE sy-subrc, " 헤더 데이터 저장 여부 저장
         lv_item_subrc   TYPE sy-subrc,   " 아이템 데이터 저장 여부 저장
         lv_s_sum        LIKE zc302fit0002-price,
         lv_h_sum        LIKE zc302fit0002-price,
         lt_save         TYPE TABLE OF zc302fit0002,
         lv_answer(3).

  " 유효성 검사 - 중복 확인
  SELECT * FROM zc302fit0001
    INTO CORRESPONDING FIELDS OF TABLE lt_header.

  READ TABLE lt_header INTO ls_header WITH KEY bukrs = gs_header-bukrs
                                               belnr = gs_header-belnr
                                               gjahr = gs_header-gjahr.

  IF sy-subrc EQ 0. " 중복 값 존재
    MESSAGE s001 WITH TEXT-e06 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  " 유효성 검사 - 권한 확인
  IF gv_pernr NE 'KDT-C-12' AND
     gv_pernr NE 'KDT-C-06'.
    MESSAGE s001 WITH TEXT-e04 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  " 차/대 합계 확인
  LOOP AT gt_item INTO gs_item.
    CASE gs_item-shkzg.
      WHEN 'S'.
        lv_s_sum += gs_item-price.
      WHEN 'H'.
        lv_h_sum += gs_item-price.
    ENDCASE.
  ENDLOOP.

  IF lv_h_sum = lv_s_sum.
    " 최종 확인 용 팝업창 띄우기
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = '전표 생성 확인'
        text_question         = '전표를 발행하시겠습니까?'
        text_button_1         = '확인'(001)
        icon_button_1         = 'ICON_CHECKED'
        text_button_2         = '취소'(002)
        icon_button_2         = 'ICON_INCOMPLETE'
        default_button        = '1'
        display_cancel_button = ''
      IMPORTING
        answer                = lv_answer.

    IF lv_answer NE 001.
      EXIT.
      MESSAGE s001 WITH TEXT-e09 DISPLAY LIKE 'E'.
    ENDIF.
    " db 반영
    MODIFY zc302fit0001 FROM TABLE gt_header.
    lv_header_subrc = sy-subrc.
    MOVE-CORRESPONDING gt_item TO lt_save.
    MODIFY zc302fit0002 FROM TABLE lt_save.
    lv_item_subrc = sy-subrc.
  ELSE.
    lv_s_sum = lv_s_sum * 100.
    DATA(lv_s_res_sum) = CONV i( lv_s_sum ).
    lv_h_sum = lv_h_sum * 100.
    DATA(lv_h_res_sum) = CONV i( lv_h_sum ).
    MESSAGE s001 WITH TEXT-e07 lv_s_res_sum  TEXT-t04 lv_h_res_sum DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.


  IF lv_header_subrc EQ 0 AND
     lv_item_subrc EQ 0.
    COMMIT WORK AND WAIT.
    MESSAGE s001 WITH gv_number '전표가 생성 되었습니다.'.
    " 증번
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '01'
        object      = 'ZNRC302_2'
      IMPORTING
        number      = gv_number.

    " Pop up에서 전표 확인하기 편하라고 값 세팅
    gv_pop_belnr_low = gv_number.

    " 화면 refresh
    CLEAR : gs_item, gt_item, gs_header, gt_header,
            gv_belnr, gv_blart, gv_pernr, gv_bldat,
            gv_budat, gv_bktxt, gv_buzei, gv_koart,
            gv_shkzg, gv_price, gv_bpcode,
            gv_augbl, gv_augdt, gv_hkont, gv_number,
            gv_s_sum, gv_h_sum.

    gv_buzei = 1.

    CALL METHOD go_up_grid->refresh_table_display.
    CALL METHOD go_down_grid->refresh_table_display.
  ELSE.
    ROLLBACK WORK.
    MESSAGE s001 WITH TEXT-e08 DISPLAY LIKE 'E'.

    " 화면 refresh
    CLEAR : gs_item, gt_item, gs_header, gt_header,
            gv_belnr, gv_blart, gv_pernr, gv_bldat,
            gv_budat, gv_bktxt, gv_buzei, gv_koart,
            gv_shkzg, gv_price, gv_waers, gv_bpcode,
            gv_augbl, gv_augdt, gv_hkont,
            gv_s_sum, gv_h_sum.

    gv_buzei = 1.

    CALL METHOD go_up_grid->refresh_table_display.
    CALL METHOD go_down_grid->refresh_table_display.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_APPENDING
*&---------------------------------------------------------------------*
FORM set_header  CHANGING pv_appending.
  DATA : ls_header LIKE gs_header. " 중복 체크를 위한 변수

  " 값 존재하는지 체크
  IF gv_pernr IS INITIAL OR
  gv_belnr IS INITIAL OR
  gv_bldat IS INITIAL OR
  gv_budat IS INITIAL.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
    pv_appending = 1.
    EXIT.
  ENDIF.

  " gs_header 구성
  gs_header-bukrs = gv_bukrs.  " 회사 번호
  gs_header-belnr = gv_number. " 전표 번호
  gs_header-gjahr = gv_gjahr. " 회계연도
  gs_header-blart = gv_blart. " 전표 유형
  gs_header-bldat = gv_bldat. " 중빙일 - 거래가 발생한 날
  gs_header-budat = gv_budat. " 전기일 - 시스템에 전표 입력한 날
  gs_header-bktxt = gv_bktxt. " 헤더 텍스트
  gs_header-emp_num = gv_pernr. " 담당자
  gs_header-waers = 'KRW'. " 통화
  gs_header-erdat = sy-datum.
  gs_header-erzet = sy-uzeit.
  gs_header-ernam = sy-uname.

  " 유효성 검사 - 중복 확인
  READ TABLE gt_header INTO ls_header WITH KEY bukrs = gv_bukrs
                                               gjahr = gv_gjahr
                                               belnr = gv_belnr.
  IF ls_header IS INITIAL. " 중복되지 않으면
    " append
    IF gs_header-emp_num NE 'KDT-C-12' AND
       gs_header-emp_num NE 'KDT-C-06'.
      MESSAGE s001 WITH TEXT-e04 DISPLAY LIKE 'E'.
      pv_appending = 1.
      EXIT.
    ENDIF.
    APPEND gs_header TO gt_header.
    CALL METHOD go_up_grid->refresh_table_display.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_popup_range
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_popup_range .

  REFRESH : gr_bukrs, gr_gjahr, gr_belnr.

  IF gv_pop_bukrs IS NOT INITIAL.
    gr_bukrs-sign = 'I'.
    gr_bukrs-option = 'EQ'.
    gr_bukrs-low = gv_pop_bukrs.
    APPEND gr_bukrs.
  ENDIF.


  IF gv_pop_gjahr IS NOT INITIAL.
    gr_gjahr-sign = 'I'.
    gr_gjahr-option = 'EQ'.
    gr_gjahr-low = gv_pop_gjahr.
    APPEND gr_gjahr.
  ENDIF.


  IF gv_pop_belnr_low IS NOT INITIAL.
    gr_belnr-sign = 'I'.
    IF gv_pop_belnr_high IS NOT INITIAL.
      gr_belnr-option = 'BT'.
      gr_belnr-low = gv_pop_belnr_low.
      gr_belnr-high = gv_pop_belnr_high.
    ELSE.
      gr_belnr-option = 'EQ'.
      gr_belnr-low = gv_pop_belnr_low.
    ENDIF.
    APPEND gr_belnr.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form submit_program
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM submit_program .
  DATA : ls_seltab TYPE rsparams,
         lt_seltab TYPE TABLE OF rsparams.

  lt_seltab = VALUE #(
                       (
                          selname = 'SO_BUKRS'
                          kind = 'S'
                          sign = gr_bukrs-sign
                          option = gr_bukrs-option
                          low = gr_bukrs-low
                          high = gr_bukrs-high
                       )
                       (
                          selname = 'SO_GJAHR'
                          kind = 'S'
                          sign = gr_gjahr-sign
                          option = gr_gjahr-option
                          low = gr_gjahr-low
                          high = gr_gjahr-high
                       )
                       (
                          selname = 'SO_BELNR'
                          kind = 'S'
                          sign = gr_belnr-sign
                          option = gr_belnr-option
                          low = gr_belnr-low
                          high = gr_belnr-high
                       )
                     ).
  SUBMIT zc302rpfi0003 WITH SELECTION-TABLE lt_seltab
                       AND RETURN.
  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_f4_blart
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM handle_f4_blart .

  DATA: lt_return LIKE ddshretval OCCURS 0
                                  WITH HEADER LINE,
        BEGIN OF ls_text_table,
          blart TYPE bkpf-blart,
          ltext TYPE t003t-ltext,
        END OF ls_text_table,
        lt_text_table LIKE TABLE OF ls_text_table.

  " 서치헬프에 보여줄 유효 값 쿼리
  CLEAR : lt_text_table.
  SELECT blart ltext
    FROM zc302fit0007
    INTO CORRESPONDING FIELDS OF TABLE lt_text_table
    WHERE spras = '3'.

  " 서치헬프에서 값을 고르면 반환할 값을 필드를 통해서 설정
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield     = 'BLART'
      dynpprog     = sy-repid
      dynpnr       = sy-dynnr
      dynprofield  = 'LT_TEXT_TABLE-BLART'
      window_title = '전표 유형'
      value_org    = 'S'
    TABLES
      value_tab    = lt_text_table
      return_tab   = lt_return.

  READ TABLE lt_return INDEX 1.

  " 화면에 세팅
  gv_blart = lt_return-fieldval.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_f4_pernr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM handle_f4_pernr .

  DATA: lt_return2 LIKE ddshretval OCCURS 0 WITH HEADER LINE,
        BEGIN OF ls_employee,
          emp_num TYPE zc302mt0003-emp_num,
          orgtx   TYPE zc302mt0003-orgtx,
          ename   TYPE zc302mt0003-ename,
        END OF ls_employee,
        lt_employee LIKE TABLE OF ls_employee.

  " 서치 헬프에 붙일 유효값 쿼리
  CLEAR : lt_employee.
  SELECT emp_num orgtx ename
  FROM zc302mt0003
  INTO CORRESPONDING FIELDS OF TABLE lt_employee.

  " 서치헬프에서 값 선택 후 반환 할 필드 설정
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield     = 'EMP_NUM'
      dynpprog     = sy-repid
      dynpnr       = sy-dynnr
      dynprofield  = 'LT_EMPLOYEE-EMP_NUM'
      window_title = '담당 사원 번호'
      value_org    = 'S'
    TABLES
      value_tab    = lt_employee
      return_tab   = lt_return2.

  READ TABLE lt_return2 INDEX 1.

  "화면에 세팅
  gv_pernr = lt_return2-fieldval.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_f4_bpcode
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM handle_f4_bpcode .

  DATA : lt_return3 LIKE ddshretval OCCURS 0 WITH HEADER LINE,
         BEGIN OF ls_bpcode,
           bpcode TYPE zc302mt0001-bpcode,
           cname  TYPE zc302mt0001-cname,
         END OF ls_bpcode,
         lt_bpcode LIKE TABLE OF ls_bpcode.

  " 서치 헬프에 붙일 유효값 쿼리
  CLEAR : lt_bpcode.
  SELECT bpcode cname
    FROM zc302mt0001
    INTO CORRESPONDING FIELDS OF TABLE lt_bpcode.

  " 서치헬프에서 값 선택 후 반환 할 필드 설장
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield     = 'BPCODE'
      dynpprog     = sy-repid
      dynpnr       = sy-dynnr
      dynprofield  = 'LT_BPCODE0-BPCODE'
      window_title = '비즈니스 파트너'
      value_org    = 'S'
    TABLES
      value_tab    = lt_bpcode
      return_tab   = lt_return3.

  READ TABLE lt_return3 INDEX 1.

  " 화면에 세팅
  gv_bpcode = lt_return3-fieldval.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_f4_hkont
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM handle_f4_hkont .
  " 서치 헬프 창에서 값 선택 시 리턴 값을 담을 테이블
  DATA: lt_return4 TYPE TABLE OF ddshretval WITH HEADER LINE,
        " 서치 헬프 창의 리턴 값을 어떤 화면 요소에 맵핑할지 설정 하는 테이블
        lt_mapping TYPE TABLE OF dselc WITH HEADER LINE,
        " 서치 헬프 창의 필드 카탈로그 설정
        lt_field   TYPE TABLE OF dfies WITH HEADER LINE,
        " 서치 헬프 값이 선택 됐을 때 업데이트 할 화면 요소의 값
        lt_update  TYPE dynpread OCCURS 0 WITH HEADER LINE,
        BEGIN OF lt_value OCCURS 0,
          value(50),
        END OF lt_value,
        BEGIN OF ls_hkont,
          saknr  TYPE zc302mt0006-saknr,
          txt50  TYPE zc302mt0006-txt50,
          bpcode TYPE zc302mt0006-bpcode,
        END OF ls_hkont,
        lt_hkont LIKE TABLE OF ls_hkont.

  " 서치 헬프에 붙일 유효값 쿼리
  CLEAR : lt_hkont.
  SELECT saknr txt50 bpcode
  FROM zc302mt0006
  INTO CORRESPONDING FIELDS OF TABLE lt_hkont.

  LOOP AT lt_hkont INTO ls_hkont.
    CLEAR : lt_value.
    lt_value-value = ls_hkont-saknr.
    APPEND lt_value.

    CLEAR : lt_value.
    lt_value-value = ls_hkont-txt50.
    APPEND lt_value.

    CLEAR : lt_value.
    lt_value-value = ls_hkont-bpcode.
    APPEND lt_value.

  ENDLOOP.

  " 서치헬프 창에 붙일 필드 정의
  CLEAR: lt_field.
  lt_field-fieldname = 'SAKNR'.
  lt_field-outputlen = 20.
  lt_field-leng      = 20.
  lt_field-intlen    = 20.
  lt_field-reptext = '계정 코드'.
  APPEND lt_field.

  CLEAR: lt_field.
  lt_field-fieldname = 'TXT50'.
  lt_field-outputlen = 100.
  lt_field-leng      = 100.
  lt_field-intlen    = 100.
  lt_field-reptext = '계정 과목'.
  APPEND lt_field.

  CLEAR: lt_field.
  lt_field-fieldname = 'BPCODE'.
  lt_field-outputlen = 14.
  lt_field-leng      = 14.
  lt_field-intlen    = 14.
  lt_field-reptext = 'BPCODE'.
  APPEND lt_field.

  " 사용자가 값 선택 후 화면 필드에 맵핑되는 변수 설정
  CLEAR : lt_mapping.
  lt_mapping-fldname = 'BPCODE'.
  lt_mapping-dyfldname = 'GV_BPCODE'.
  APPEND lt_mapping.

  CLEAR : lt_mapping.
  lt_mapping-fldname = 'SAKNR'.
  lt_mapping-dyfldname = 'GV_HKONT'.
  APPEND lt_mapping.

  " 서치헬프 창 띄우기
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'SAKNR'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'LT_HKONT-SAKNR'
      window_title    = '계정 과목'
      value_org       = 'C'
    TABLES
      value_tab       = lt_value
      return_tab      = lt_return4
      field_tab       = lt_field
      dynpfld_mapping = lt_mapping.

  " 서치헬프의 값이 선택 된 후 업데이트 할 화면 요소 설정
  lt_update-fieldname = 'GV_BPCODE'.
  READ TABLE lt_return4 WITH KEY retfield = lt_update-fieldname.
  IF sy-subrc = 0.
    lt_update-fieldvalue = lt_return4-fieldval.
    APPEND lt_update.
  ENDIF.

  lt_update-fieldname = 'GV_HKONT'.
  READ TABLE lt_return4 WITH KEY retfield = lt_update-fieldname.
  IF sy-subrc = 0.
    lt_update-fieldvalue = lt_return4-fieldval.
    APPEND lt_update.
  ENDIF.

  " 서치헬프 리턴 값으로 화면 요소에 값 설정
  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = sy-cprog
      dynumb     = sy-dynnr
    TABLES
      dynpfields = lt_update.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_f4_waers
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM handle_f4_waers .

  DATA : lt_return5 LIKE ddshretval OCCURS 0 WITH HEADER LINE,
         BEGIN OF ls_waers,
           fcurr  TYPE zc302fit0005-fcurr,
           nation TYPE zc302fit0005-nation,
         END OF ls_waers,
         lt_waers LIKE TABLE OF ls_waers.

  " 서치 헬프에 붙일 유효값 쿼리
  CLEAR : lt_waers.
  SELECT DISTINCT fcurr nation
  FROM zc302fit0005
  INTO CORRESPONDING FIELDS OF TABLE lt_waers.

  " 서치헬프에서 값 선택 후 반환 할 필드 설장
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield     = 'FCURR'
      dynpprog     = sy-repid
      dynpnr       = sy-dynnr
      dynprofield  = 'LT_WAERS-FCURR'
      window_title = '통화키'
      value_org    = 'S'
    TABLES
      value_tab    = lT_waers
      return_tab   = lt_return5.

  READ TABLE lt_return5 INDEX 1.

*  " 화면에 세팅
*  gv_waers = lt_return5-fieldval.

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

  CLEAR : gs_button.
  gs_button-butn_type = '3'.
  APPEND gs_button TO po_object->mt_toolbar.

  CLEAR : gs_button.
  gs_button-function = 'MODI'.
  gs_button-icon = icon_toggle_display_change.
  CASE gv_mode.
    WHEN 'E'.
      gs_button-text = TEXT-t01.
    WHEN 'D'.
      gs_button-text = TEXT-t02.
    WHEN OTHERS.
  ENDCASE.
  gs_button-quickinfo = '조회 <-> 편집'.
  APPEND gs_button TO po_object->mt_toolbar.

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
    WHEN 'MODI'.
      PERFORM change_mode.
      CALL METHOD go_down_grid->set_toolbar_interactive.
  ENDCASE.
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

  DATA : lt_f4      TYPE lvc_t_f4 WITH HEADER LINE,
         lt_f4_data TYPE lvc_s_f4.

  SET HANDLER : lcl_event_handler=>toolbar FOR go_down_grid,
                lcl_event_handler=>user_command FOR go_down_grid,
                lcl_event_handler=>modify_value FOR go_down_grid,
                lcl_event_handler=>onf4 FOR go_down_grid.

  " toolbar
  CALL METHOD go_down_grid->set_toolbar_interactive.

  "f4 help
  lt_f4_data-fieldname = 'HKONT'.
  lt_f4_data-register = 'X'.
  lt_f4_data-getbefore = 'X'.
  lt_f4_data-chngeafter = 'X'.
  INSERT lt_f4_data INTO TABLE lt_f4.

  lt_f4_data-fieldname = 'WAERS'.
  lt_f4_data-register = 'X'.
  lt_f4_data-getbefore = 'X'.
  lt_f4_data-chngeafter = 'X'.
  INSERT lt_f4_data INTO TABLE lt_f4.

  lt_f4_data-fieldname = 'SHKZG'.
  lt_f4_data-register = 'X'.
  lt_f4_data-getbefore = 'X'.
  lt_f4_data-chngeafter = 'X'.
  INSERT lt_f4_data INTO TABLE lt_f4.

  CALL METHOD go_down_grid->register_f4_for_fields
    EXPORTING
      it_f4 = lt_f4[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form change_mode
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM change_mode .
  CASE gv_mode.
    WHEN 'D'.   " display
      PERFORM input_active.
      gv_mode = 'E'.
    WHEN 'E'.   " edit
      PERFORM input_inactive.
      gv_mode = 'D'.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form input_active
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM input_active .

  DATA : ls_celltab TYPE lvc_s_styl,
         lv_tabix   TYPE sy-tabix.

  LOOP AT gt_item INTO gs_item.
    lv_tabix = sy-tabix.

    ls_celltab-fieldname = 'SHKZG'.
    ls_celltab-style = go_down_grid->mc_style_enabled.
    INSERT ls_celltab INTO TABLE gs_item-celltab.

    ls_celltab-fieldname = 'PRICE'.
    ls_celltab-style = go_down_grid->mc_style_enabled.
    INSERT ls_celltab INTO TABLE gs_item-celltab.

    ls_celltab-fieldname = 'WAERS'.
    ls_celltab-style = go_down_grid->mc_style_enabled.
    INSERT ls_celltab INTO TABLE gs_item-celltab.

    ls_celltab-fieldname = 'SAKNR'.
    ls_celltab-style = go_down_grid->mc_style_enabled.
    INSERT ls_celltab INTO TABLE gs_item-celltab.

    MODIFY gt_item FROM gs_item INDEX lv_tabix
                                TRANSPORTING celltab.

  ENDLOOP.

  CALL METHOD go_down_grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form input_inactive
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM input_inactive .
  " alv에서 변경된 값을 전부 읽어와서 -> itab 업데이트
  " itab 업데이트 된 거에 맞춰서 -> 다른 필드 업데이트 -> 그리드 리프레쉬
  CALL METHOD go_down_grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 0.

  CALL METHOD go_down_grid->refresh_table_display.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_buttons
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exclude_buttons TABLES pt_ui_functions TYPE ui_functions.

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
*& Form handle_modify_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM handle_modify_value USING pv_modified
                                pt_good_cells TYPE lvc_t_modi.

  DATA : ls_modi_cell  TYPE lvc_s_modi,
         lv_field1(10),
         lv_field2(10),
         lv_exrate     TYPE zc302fit0005-exrate.

  CHECK pv_modified IS NOT INITIAL.

  ls_modi_cell = VALUE #( pt_good_cells[ 1 ] OPTIONAL ).

  CASE ls_modi_cell-fieldname.

    WHEN 'HKONT'.
      gs_sh_saknr = VALUE #( gt_sh_saknr[ saknr = ls_modi_cell-value ] OPTIONAL ).
      gs_item-txt50 = gs_sh_saknr-txt50.
      gs_item-bpcode = gs_sh_saknr-bpcode.
      lv_field1 = 'TXT50'.
      lv_field2 = 'BPCODE'.

    WHEN 'PRICE'.
      READ TABLE gt_item INTO gs_item INDEX ls_modi_cell-row_id.
      lv_field1 = 'PRICE'.
      MODIFY gt_item FROM gs_item INDEX ls_modi_cell-row_id
                                  TRANSPORTING (lv_field1).
    WHEN 'WAERS'.
      gs_sh_waers = VALUE #( gt_sh_waers[ fcurr = ls_modi_cell-value ] OPTIONAL ).
      lv_field1 = 'WAERS'.
      lv_field2 = 'PRICE'.

      IF gs_sh_waers-fcurr NE 'KRW'.
        SELECT SINGLE exrate
          INTO lv_exrate
          FROM zc302fit0005
          WHERE fcurr = gs_sh_waers-fcurr
            AND edate = gv_bldat.

        IF sy-subrc NE 0.
          MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.
          EXIT.
        ELSE.
          gs_item-price *= lv_exrate.
          gs_item-waers = 'KRW'.
        ENDIF.
      ENDIF.

  ENDCASE.

  MODIFY gt_item FROM gs_item INDEX ls_modi_cell-row_id
                              TRANSPORTING (lv_field1) (lv_field2).

  CALL METHOD go_down_grid->refresh_table_display.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_onf4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_FIELDNAME
*&      --> E_FIELDVALUE
*&      --> ES_ROW_NO
*&      --> ER_EVENT_DATA
*&      --> ET_BAD_CELLS
*&      --> E_DISPLAY
*&---------------------------------------------------------------------*
FORM handle_onf4  USING    p_fieldname TYPE lvc_fname
                           p_fieldvalue TYPE lvc_value
                           ps_row_no TYPE lvc_s_roid
                           pi_event_data TYPE REF TO cl_alv_event_data
                           pt_bad_cells TYPE lvc_t_modi
                           p_display TYPE char01.

  FIELD-SYMBOLS <fs_tab> TYPE STANDARD TABLE.

  DATA : dynprog          LIKE sy-repid,
         dynnr            LIKE sy-dynnr,
         window_title(30),
         l_row            TYPE p,
         ls_item          LIKE gs_item,
         lv_field         TYPE dfies-fieldname,
         lv_text          TYPE help_info-dynprofld,
         lv_flag.

  DATA : lt_return LIKE TABLE OF ddshretval WITH HEADER LINE.
  CLEAR : dynprog, dynnr, window_title.

  READ TABLE gt_item INTO ls_item INDEX ps_row_no-row_id.
  dynprog = sy-repid.
  dynnr = sy-dynnr.

  CASE p_fieldname.
    WHEN 'HKONT'.
      window_title = '계정 과목'.
      lv_field    = 'SAKNR'.
      lv_text      = 'TXT50'.
      ASSIGN gt_sh_saknr TO <fs_tab>.
    WHEN 'SHKZG'.
      pi_event_data->m_event_handled = abap_false.
      EXIT.
    WHEN 'WAERS'.
      window_title = '통화'.
      lv_field = 'FCURR'.
      lv_text = 'NATION'.
      ASSIGN gt_sh_waers TO <fs_tab>.
  ENDCASE.


  IF gt_sh_saknr IS NOT INITIAL AND
     <fs_tab> IS ASSIGNED.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = lv_field
        dynpprog        = dynprog
        dynpnr          = dynnr
        dynprofield     = lv_text
        window_title    = window_title
        value_org       = 'S'
      TABLES
        value_tab       = <fs_tab>
        return_tab      = lt_return
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.
  ELSEIF gt_sh_saknr IS INITIAL AND
         <fs_tab> IS ASSIGNED.
    MESSAGE s001 WITH '테이블엔 값이 없고 할당은 된 경우 ' DISPLAY LIKE 'E'.
  ELSEIF gt_sh_saknr IS NOT INITIAL AND
         <fs_tab> IS NOT ASSIGNED.
    MESSAGE s001 WITH '테이블엔 갓이 있고 할다잉 안 된 경우' DISPLAY LIKE 'E'.
  ENDIF.


  pi_event_data->m_event_handled = 'X'.

  FIELD-SYMBOLS:  <fs> TYPE lvc_t_modi.

  DATA: ls_modi TYPE lvc_s_modi.

  ASSIGN pi_event_data->m_data->* TO <fs>.

  READ TABLE lt_return INDEX 1.
  IF sy-subrc = 0.
    ls_modi-row_id    = ps_row_no-row_id.
    ls_modi-fieldname = p_fieldname.
    ls_modi-value     = lt_return-fieldval.
    APPEND ls_modi TO <fs>.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_alv_search_help_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_alv_search_help_data .

  CLEAR : gt_sh_waers, gt_sh_saknr.

  " 계정 과목
  SELECT DISTINCT saknr txt50 bpcode
    FROM zc302mt0006
    INTO CORRESPONDING FIELDS OF TABLE gt_sh_saknr.

  " 통화
  SELECT DISTINCT fcurr nation
    FROM zc302fit0005
    INTO CORRESPONDING FIELDS OF TABLE gt_sh_waers.

ENDFORM.
