*&---------------------------------------------------------------------*
*& Include          ZC302RPFI0008F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form on_f4_bpcode_low
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM on_f4_bpcode_low .

  DATA : lt_return TYPE TABLE OF ddshretval WITH HEADER LINE,
         lt_read   TYPE TABLE OF dynpread WITH HEADER LINE,
         BEGIN OF ls_bpcode,
           bpcode TYPE zc302mt0001-bpcode,
           cname  TYPE zc302mt0001-cname,
         END OF ls_bpcode,
         lt_bpcode LIKE TABLE OF ls_bpcode.

  SELECT DISTINCT bpcode cname
    INTO CORRESPONDING FIELDS OF TABLE lt_bpcode
    FROM zc302mt0001.

*-- Execute Search Help(F4)
  REFRESH lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BPCODE'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'SO_BPCODE-LOW'
      window_title    = '비즈니스 파트너'
      value_org       = 'S'
    TABLES
      value_tab       = lt_bpcode
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

*-- Get description
  lt_return = VALUE #( lt_return[ 1 ] OPTIONAL ).
  so_bpcde-low = lt_return-fieldval.

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

  DATA : lt_return TYPE TABLE OF ddshretval WITH HEADER LINE,
         lt_read   TYPE TABLE OF dynpread WITH HEADER LINE,
         BEGIN OF ls_bpcode,
           bpcode TYPE zc302mt0001-bpcode,
           cname  TYPE zc302mt0001-cname,
         END OF ls_bpcode,
         lt_bpcode LIKE TABLE OF ls_bpcode.

  SELECT DISTINCT bpcode cname
    INTO CORRESPONDING FIELDS OF TABLE lt_bpcode
    FROM zc302mt0001.

*-- Execute Search Help(F4)
  REFRESH lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BPCODE'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'SO_BPCODE-HIGH'
      window_title    = '비즈니스 파트너'
      value_org       = 'S'
    TABLES
      value_tab       = lt_bpcode
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

*-- Get description
  lt_return = VALUE #( lt_return[ 1 ] OPTIONAL ).
  so_bpcde-high = lt_return-fieldval.

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

  CASE 'X'.
    WHEN pa_all.
      SELECT *
        FROM zc302fit0004
        INTO CORRESPONDING FIELDS OF TABLE gt_body
        WHERE bpcode IN so_bpcde.
    WHEN pa_nall.
      SELECT *
        FROM zc302fit0004
        INTO CORRESPONDING FIELDS OF TABLE gt_body
        WHERE jpflag = 'N'
          AND bpcode IN so_bpcde.
  ENDCASE.

  gv_lines = lines( gt_body ).
  IF gt_body IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
    STOP.
  ELSE.
    MESSAGE s001 WITH gv_lines TEXT-t03.
    SORT gt_body BY jpflag ASCENDING.
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

  LOOP AT gt_body INTO gs_body .
    gv_tabix = sy-tabix.
    CASE gs_body-jpflag.
      WHEN 'Y'.
        gs_body-icon = icon_led_green.
      WHEN 'N'.
        gs_body-icon = icon_led_yellow.
    ENDCASE.
    MODIFY gt_body FROM gs_body INDEX gv_tabix
                                TRANSPORTING icon.
  ENDLOOP.

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
  IF go_cont IS NOT BOUND.
    PERFORM set_left_fcat USING : 'X' 'ICON' 'ICON' '발행 여부' ' ' ' ',
                                  'X' 'ZISDN' 'ZC302FIT0004' '미승인 전표 번호' ' ' 'C',
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

    PERFORM set_top_fcat USING : 'X' 'BUKRS' '회사 코드' ' ' ' ',
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

    PERFORM set_bot_fcat USING : 'X' 'BUKRS' '회사 코드' ' ' ' ',
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
    CALL METHOD go_left_grid->set_table_for_first_display
      EXPORTING
        i_default       = 'X'
        is_layout       = gs_layo_left
      CHANGING
        it_outtab       = gt_body
        it_fieldcatalog = gt_left_fcat.

    CALL METHOD go_top_grid->set_table_for_first_display
      EXPORTING
        i_default       = 'X'
        is_layout       = gs_layo_rtop
      CHANGING
        it_outtab       = gt_bkpf
        it_fieldcatalog = gt_top_fcat.

    CALL METHOD go_bot_grid->set_table_for_first_display
      EXPORTING
        i_default       = 'X'
        is_layout       = gs_layo_rbot
      CHANGING
        it_outtab       = gt_bseg
        it_fieldcatalog = gt_bot_fcat.
  ELSE.
    CALL METHOD go_left_grid->refresh_table_display.
    CALL METHOD go_top_grid->refresh_table_display.
    CALL METHOD go_bot_grid->refresh_table_display.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_left_fcat
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
FORM set_left_fcat  USING  pv_key pv_field pv_table
                           pv_coltext pv_emph pv_just.

  CLEAR : gs_left_fcat.
  gs_left_fcat-key = pv_key.
  gs_left_fcat-fieldname = pv_field.
  gs_left_fcat-ref_table = pv_table.
  gs_left_fcat-coltext = pv_coltext.
  gs_left_fcat-emphasize = pv_emph.
  gs_left_fcat-just = pv_just.
  CASE pv_field.
    WHEN 'SPAMT'.
      gs_left_fcat-cfieldname = 'WAERS'.
    WHEN 'TOAMT'.
      gs_left_fcat-cfieldname = 'WAERS'.
    WHEN 'VADTX'.
      gs_left_fcat-cfieldname = 'WAERS'.
  ENDCASE.

  APPEND gs_left_fcat TO gt_left_fcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_top_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_top_fcat  USING  pv_key pv_field
                          pv_coltext pv_emph pv_just.

  CLEAR gs_top_fcat.
  gs_top_fcat-key = pv_key.
  gs_top_fcat-fieldname = pv_field.
  gs_top_fcat-coltext = pv_coltext.
  gs_top_fcat-emphasize = pv_emph.
  gs_top_fcat-just = pv_just.

  APPEND gs_top_fcat TO gt_top_fcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_bot_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_bot_fcat   USING  pv_key pv_fname pv_ctxt pv_just pv_emph.

  CLEAR : gs_bot_fcat.
  gs_bot_fcat-key = pv_key.
  gs_bot_fcat-fieldname = pv_fname.
  gs_bot_fcat-coltext = pv_ctxt.
  gs_bot_fcat-emphasize = pv_emph.
  gs_bot_fcat-just = pv_just.

  CASE pv_fname.
    WHEN 'PRICE'.
      gs_bot_fcat-cfieldname = 'WAERS'.
  ENDCASE.
  APPEND gs_bot_fcat TO gt_bot_fcat.

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

  gs_layo_left-zebra = abap_true.
  gs_layo_left-cwidth_opt = 'A'.
  gs_layo_left-sel_mode = 'D'.
  gs_layo_left-smalltitle = 'X'.
  gs_layo_left-grid_title = '미승인 전표'.

  gs_layo_rtop-zebra = abap_true.
  gs_layo_rtop-cwidth_opt = 'A'.
  gs_layo_rtop-sel_mode = 'D'.
  gs_layo_rtop-smalltitle = 'X'.
  gs_layo_rtop-grid_title = '승인 전표 헤더'.

  gs_layo_rbot-zebra = abap_true.
  gs_layo_rbot-cwidth_opt = 'A'.
  gs_layo_rbot-sel_mode = 'D'.
  gs_layo_rbot-smalltitle = 'X'.
  gs_layo_rbot-grid_title = '승인 전표 상세 내역'.

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
  " top of page
  CREATE OBJECT go_top_container
    EXPORTING
      repid     = sy-cprog
      dynnr     = sy-dynnr
      side      = go_top_container->dock_at_top
      extension = 50. " Top of page 높이

  " main container
  CREATE OBJECT go_cont
    EXPORTING
      side      = go_cont->dock_at_left
      extension = 5000.
  " split container
  CREATE OBJECT go_split
    EXPORTING
      parent  = go_cont
      rows    = 1
      columns = 2.
  " container left
  CALL METHOD go_split->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_left_cont.
  " container right
  CALL METHOD go_split->get_container
    EXPORTING
      row       = 1
      column    = 2
    RECEIVING
      container = go_right_cont.
  " right split container
  CREATE OBJECT go_split2
    EXPORTING
      parent  = go_right_cont
      rows    = 2
      columns = 1.
  " right_top
  CALL METHOD go_split2->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_top_cont.
  " right_bottom
  CALL METHOD go_split2->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_bot_cont.
  " grid
  CREATE OBJECT go_left_grid
    EXPORTING
      i_parent = go_left_cont.

  CREATE OBJECT go_top_grid
    EXPORTING
      i_parent = go_top_cont.

  CREATE OBJECT go_bot_grid
    EXPORTING
      i_parent = go_bot_cont.

  " top of page create doc
  CREATE OBJECT go_dyndoc_id
    EXPORTING
      style = 'ALV_GRID'.
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

  DATA : ls_button TYPE stb_button.

  CLEAR : ls_button.
  ls_button-function = 'CRTE'.
  ls_button-icon = icon_write_file.
  ls_button-quickinfo = '전표 승인'.
  ls_button-text = TEXT-t04.

  APPEND ls_button TO po_object->mt_toolbar.

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

  SET HANDLER : lcl_event_handler=>toolbar FOR go_left_grid,
                lcl_event_handler=>user_command FOR go_left_grid,
                lcl_event_handler=>top_of_page  FOR go_left_grid.

  CALL METHOD go_left_grid->set_toolbar_interactive.

  CALL METHOD go_dyndoc_id->initialize_document
    EXPORTING
      background_color = cl_dd_area=>col_textarea.

  CALL METHOD go_left_grid->list_processing_events
    EXPORTING
      i_event_name = 'TOP_OF_PAGE'
      i_dyndoc_id  = go_dyndoc_id.

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
      PERFORM create_doc.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_doc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_doc .
  " 선택된 행 받아오기
  DATA : ls_rowno     TYPE lvc_s_row,
         lt_rowno     TYPE lvc_t_row,
         lv_answer(3),                 " 팝업 창 받아오기
         lv_number    TYPE nriv,
         ls_billing   TYPE zc302sdt0009,
         ls_songjang  TYPE zc302mmt0009,
         ls_master    TYPE zc302mt0006,
         lt_billing   TYPE TABLE OF zc302sdt0009,
         lt_songjang  TYPE TABLE OF zc302mmt0009,
         lt_master    TYPE TABLE OF zc302mt0006,
         lt_save      TYPE TABLE OF zc302fit0004.

  SELECT *
    FROM zc302mt0006
    INTO CORRESPONDING FIELDS OF TABLE lt_master.

  SELECT *
    FROM zc302sdt0009
    INTO CORRESPONDING FIELDS OF TABLE lt_billing.

  SELECT *
    FROM zc302mmt0009
    INTO CORRESPONDING FIELDS OF TABLE lt_songjang.

  " 선택된 행의 index값 저장
  CALL METHOD go_left_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_rowno.

  gv_lines = lines( lt_rowno ).

  " 선택된 행의 개수 체크
  IF gv_lines > 1.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.
    EXIT.
  ELSEIF gv_lines = 0.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  " 행의 인덱스 값을 읽어서 해당 문서의 번호를 알아옴.
  READ TABLE lt_rowno INTO ls_rowno INDEX 1.
  READ TABLE gt_body INTO gs_body INDEX ls_rowno-index.

  " 전표 발행 여부 확인
  IF gs_body-jpflag = 'Y'.
    MESSAGE s001 WITH TEXT-e04 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  " 발행 확인을 위한 팝업 창 띄우기
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      text_question         = '미승인 전표를 승인하시겠습니까?'
      text_button_1         = '전표 승인'(001)
      icon_button_1         = 'ICON_CHECKED'
      text_button_2         = '승인 취소'(002)
      icon_button_2         = 'ICON_INCOMPLETE'
      default_button        = '1'
      display_cancel_button = ' '
    IMPORTING
      answer                = lv_answer.

  " 취소 버튼 클릭 시 프로그램 분기
  IF lv_answer <> 1.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  " 공급 유형에 따른 프로그램 분기
  CASE gs_body-sptyp.
    WHEN 'AR'.
      " 채번
      CALL FUNCTION 'NUMBER_GET_INFO'
        EXPORTING
          nr_range_nr = '02'
          object      = 'ZNRC302_2'
        IMPORTING
          interval    = lv_number.

      " bldat 증빙일 가져오기
      READ TABLE lt_billing INTO ls_billing WITH KEY bilnum = gs_body-zisdn.
      gs_bkpf-bldat = ls_billing-bldat.

      " koart 설정
      gs_bseg-koart = 'D'.


    WHEN 'AP'.
      " 채번
      CALL FUNCTION 'NUMBER_GET_INFO'
        EXPORTING
          nr_range_nr = '03'
          object      = 'ZNRC302_2'
        IMPORTING
          interval    = lv_number.

      " bldat 증빙일 가져오기
      READ TABLE lt_songjang INTO ls_songjang WITH KEY docxbn = gs_body-zisdn.
      gs_bkpf-bldat = ls_songjang-bldat.

      " koart 설정
      gs_bseg-koart = 'M'.
  ENDCASE.

  " 전표 헤더 및 아이템 생성
  gs_bkpf-bukrs = '1000'.
  gs_bkpf-belnr = lv_number-nrlevel + 1.
  gs_bkpf-gjahr = '2024'.  " 질문 -> 승인한 날의 연도로 가져오기
  gs_bkpf-blart = 'AB'. " 전표 유형 : 회계
  gs_bkpf-budat = sy-datum.
  gs_bkpf-bktxt = 'AR/AP 전표'.
  gs_bkpf-emp_num = sy-uname.
  gs_bkpf-waers = 'KRW'.
  gs_bkpf-zisdn = gs_body-zisdn.
  gs_bkpf-zisdd = gs_body-zisdd.
  gs_bkpf-erdat = sy-datum.
  gs_bkpf-erzet  = sy-uzeit.
  gs_bkpf-ernam = sy-uname.

  gs_bseg-bukrs = '1000'.
  gs_bseg-gjahr = '2024'.
  gs_bseg-belnr = lv_number-nrlevel + 1.
  gs_bseg-buzei = '001'.
  CASE gs_body-sptyp.
    WHEN 'AR'.
      gs_bseg-shkzg = 'S'.
      gs_bseg-price =  gs_body-spamt.
      gs_bseg-waers = 'KRW'.
      gs_bseg-bpcode = gs_body-bpcode.
      READ TABLE lt_master INTO ls_master WITH KEY bpcode = gs_body-bpcode.
      gs_bseg-hkont = ls_master-saknr.
      gs_bseg-txt50 = ls_master-txt50.
      gs_bseg-erdat = sy-datum.
      gs_bseg-erzet = sy-uzeit.
      gs_bseg-ernam = sy-uname.
      APPEND gs_bseg TO gt_bseg.
      CLEAR : gs_body-bpcode.

      gs_bseg-buzei = '0002'.
      gs_bseg-koart = 'S'.
      gs_bseg-shkzg = 'S'.
      gs_bseg-price = gs_body-vadtx.
      gs_bseg-waers = 'KRW'.
      gs_bseg-hkont = 'ACC0003013'.
      READ TABLE lt_master INTO ls_master WITH KEY saknr = gs_bseg-hkont.
      gs_bseg-txt50 = ls_master-txt50.
      gs_bseg-erdat = sy-datum.
      gs_bseg-erzet = sy-uzeit.
      gs_bseg-ernam = sy-uname.
      APPEND gs_bseg TO gt_bseg.

      gs_bseg-buzei = '003'.
      gs_bseg-koart = 'S'.
      gs_bseg-shkzg = 'H'.
      gs_bseg-price = gs_body-toamt.
      gs_bseg-waers = 'KRW'.
      gs_bseg-hkont = 'ACC0006000'.
      READ TABLE lt_master INTO ls_master WITH KEY saknr = gs_bseg-hkont.
      gs_bseg-txt50 = ls_master-txt50.
      gs_bseg-erdat = sy-datum.
      gs_bseg-erzet = sy-uzeit.
      gs_bseg-ernam = sy-uname.
      APPEND gs_bseg TO gt_bseg.
      CLEAR gs_bseg.
    WHEN 'AP'.
      gs_bseg-shkzg = 'H'.
      gs_bseg-price = gs_body-toamt.
      gs_bseg-waers = 'KRW'.
      gs_bseg-bpcode = gs_body-bpcode.
      READ TABLE lt_master INTO ls_master WITH KEY bpcode = gs_body-bpcode.
      gs_bseg-hkont = ls_master-saknr.
      gs_bseg-txt50 = ls_master-txt50.
      gs_bseg-erdat = sy-datum.
      gs_bseg-erzet = sy-uzeit.
      gs_bseg-ernam = sy-uname.
      APPEND gs_bseg TO gt_bseg.

      gs_bseg-buzei = '002'.
      gs_bseg-koart = 'S'.
      gs_bseg-shkzg = 'S'.
      gs_bseg-price = gs_body-toamt.
      gs_bseg-waers = 'KRW'.
      IF gs_body-bpcode = 'PO0004' OR gs_body-bpcode = 'PO0005'.
        gs_bseg-hkont = 'ACC0001016'.
        READ TABLE lt_master INTO ls_master WITH KEY saknr = gs_bseg-hkont.
        gs_bseg-txt50 = ls_master-txt50.
      ELSE.
        gs_bseg-hkont = 'ACC0001026'.
        READ TABLE lt_master INTO ls_master WITH KEY saknr = gs_bseg-hkont.
        gs_bseg-txt50 = ls_master-txt50.
      ENDIF.
      gs_bseg-erdat = sy-datum.
      gs_bseg-erzet = sy-uzeit.
      gs_bseg-ernam = sy-uname.
      APPEND gs_bseg TO gt_bseg.

  ENDCASE.


  APPEND gs_bkpf TO gt_bkpf.
  gs_body-jpflag = 'Y'.
  gs_body-icon = icon_led_green.
  MODIFY gt_body FROM gs_body INDEX ls_rowno-index
                              TRANSPORTING jpflag icon.

  "alv display refresh
  SORT gt_bkpf BY erdat DESCENDING erzet DESCENDING.
  CALL METHOD go_left_grid->refresh_table_display.
  CALL METHOD go_top_grid->refresh_table_display.
  CALL METHOD go_bot_grid->refresh_table_display.

  " db 반영 - 임시 전표 테이블
  MOVE-CORRESPONDING gt_body TO lt_save.
  MODIFY zc302fit0004 FROM TABLE lt_save.
  MODIFY zc302fit0001 FROM TABLE gt_bkpf.
  MODIFY zc302fit0002 FROM TABLE gt_bseg.
  CLEAR : gs_bkpf, gs_bseg.

  " db 반영 실패 시
  IF sy-subrc NE 0.
    ROLLBACK WORK.
    MESSAGE s001  WITH TEXT-e06 DISPLAY LIKE 'E'.
    EXIT.
  ELSE.
    COMMIT WORK AND WAIT.
    MESSAGE s001 WITH TEXT-t05.
    CASE gs_body-sptyp.
      WHEN 'AR'.
        CALL FUNCTION 'NUMBER_GET_NEXT'
          EXPORTING
            nr_range_nr = '02'
            object      = 'ZNRC302_2'
          IMPORTING
            number      = lv_number.

      WHEN 'AP'.
        CALL FUNCTION 'NUMBER_GET_NEXT'
          EXPORTING
            nr_range_nr = '03'
            object      = 'ZNRC302_2'
          IMPORTING
            number      = lv_number.
    ENDCASE.
  ENDIF.

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
  CLEAR : lv_temp.
  IF pa_all = abap_true.
    lv_temp = '전체'.
  ELSE.
    lv_temp = '미승인 전표'.
  ENDIF.

  PERFORM add_row USING lr_dd_table col_field col_value '승인 여부' lv_temp.

*-- 계획년도 & 계획 월
  so_bpcde = VALUE #( so_bpcde[ 1 ] OPTIONAL ).
  CLEAR : lv_temp.
  IF so_bpcde-low IS NOT INITIAL.
    lv_temp = so_bpcde-low.
    IF so_bpcde-high IS NOT INITIAL.
      CONCATENATE lv_temp ' ~ ' so_bpcde-high INTO lv_temp.
    ENDIF.
  ELSE.
    lv_temp = '전체'.
  ENDIF.

  PERFORM add_row USING lr_dd_table col_field col_value 'BP Code' lv_temp.

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
    MESSAGE s001 WITH TEXT-e07 DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.
