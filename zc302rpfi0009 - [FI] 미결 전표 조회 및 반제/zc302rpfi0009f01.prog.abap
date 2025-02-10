*&---------------------------------------------------------------------*
*& Include          ZC302RPFI0009F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form on_f4_bpcode
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM on_f4_bpcode  USING pv_flag.
  " F4 help Variable
  DATA : lt_return TYPE TABLE OF ddshretval WITH HEADER LINE,
         lt_read   TYPE TABLE OF dynpread WITH HEADER LINE,
         BEGIN OF ls_bpcode,
           bpcode TYPE zc302mt0001-bpcode,
           cname  TYPE zc302mt0001-cname,
         END OF ls_bpcode,
         lt_bpcode LIKE TABLE OF ls_bpcode,
         lv_dfield TYPE help_info-dynprofld.

  SELECT DISTINCT bpcode cname
    INTO CORRESPONDING FIELDS OF TABLE lt_bpcode
    FROM zc302mt0001.

  CASE pv_flag.
    WHEN 'low'.
      lv_dfield = 'SO_BPCD-LOW'.
    WHEN 'high'.
      lv_dfield = 'SO_BPCD-HIGH'.
  ENDCASE.

*-- Execute Search Help(F4)
  REFRESH lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BPCODE'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = lv_dfield
      window_title    = '비즈니스 파트너'
      value_org       = 'S'
    TABLES
      value_tab       = lt_bpcode
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

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

  CLEAR : gt_body.

  CASE 'X'.
    WHEN pa_all.

      SELECT *
        FROM zc302fit0001 AS a LEFT OUTER JOIN zc302fit0002 AS b
          ON a~bukrs = b~bukrs
         AND a~gjahr = b~gjahr
         AND a~belnr = b~belnr
        WHERE bpcode IN @so_bpcd
          AND budat IN @so_date
          AND stblg IS INITIAL
          AND stgrd IS INITIAL
          AND b~buzei = 1
          AND a~xref1_hd IS INITIAL
          AND bpcode IS NOT INITIAL
        INTO CORRESPONDING FIELDS OF TABLE @gt_body.

    WHEN pa_nall.
      SELECT DISTINCT *
        FROM zc302fit0001 AS a INNER JOIN zc302fit0002 AS b
          ON a~bukrs = b~bukrs
         AND a~gjahr = b~gjahr
         AND a~belnr = b~belnr
        WHERE bpcode IN @so_bpcd
          AND budat IN @so_date
          AND a~augbl IS INITIAL
          AND stblg IS INITIAL
          AND stgrd IS INITIAL
          AND b~buzei = 1
        AND a~xref1_hd IS INITIAL
        AND bpcode IS NOT INITIAL
      INTO CORRESPONDING FIELDS OF TABLE @gt_body.

  ENDCASE.

  IF gt_body IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
    STOP.
  ELSE.
    gv_lines = lines( gt_body ).
    MESSAGE s001 WITH gv_lines TEXT-t03.
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
  LOOP AT gt_body INTO gs_body.
    gv_tabix = sy-tabix.
    IF gs_body-augbl IS INITIAL.
      gs_body-icon = icon_led_yellow.
      MODIFY gt_body FROM gs_body INDEX gv_tabix
                                  TRANSPORTING icon.
    ELSE.
      gs_body-icon = icon_led_green.
      MODIFY gt_body FROM gs_body INDEX gv_tabix
                                  TRANSPORTING icon.
    ENDIF.
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
    PERFORM set_fcat.
    PERFORM set_layout.
    PERFORM create_object.
    PERFORM register_events.

*    perform register_event.
    CALL METHOD go_ltop_grid->set_table_for_first_display
      EXPORTING
        i_default       = 'X'
        is_layout       = gs_layo_ltop
      CHANGING
        it_outtab       = gt_body
        it_fieldcatalog = gt_ltop_fcat.


    CALL METHOD go_lbot_grid->set_table_for_first_display
      EXPORTING
        i_default       = 'X'
        is_layout       = gs_layo_lbot
      CHANGING
        it_outtab       = gt_item
        it_fieldcatalog = gt_lbot_fcat.

    CALL METHOD go_rtop_grid->set_table_for_first_display
      EXPORTING
        i_default       = 'X'
        is_layout       = gs_layo_rtop
      CHANGING
        it_outtab       = gt_bkpf
        it_fieldcatalog = gt_rtop_fcat.

    CALL METHOD go_rbot_grid->set_table_for_first_display
      EXPORTING
        i_default       = 'X'
        is_layout       = gs_layo_rbot
      CHANGING
        it_outtab       = gt_bseg
        it_fieldcatalog = gt_rbot_fcat.
  ELSE.
    CALL METHOD go_ltop_grid->refresh_table_display.
    CALL METHOD go_lbot_grid->refresh_table_display.
    CALL METHOD go_rtop_grid->refresh_table_display.
    CALL METHOD go_rbot_grid->refresh_table_display.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fcat .

  PERFORM set_ltop_fcat USING : 'X' 'ICON' '완결 여부' ' ' 'X',
                                'X' 'BUKRS' '회사 코드' ' ' 'X',
                                'X' 'BELNR' '전표 번호' ' ' ' ',
                                'X' 'GJAHR' '회계 연도' ' ' 'X',
                                ' ' 'AUGBL' '반제 전표 번호' 'X' ' ',
                                ' ' 'AUGDT' '전표 반제일' 'X' ' ',
                                ' ' 'BLART' '전표 유형' ' ' ' ',
                                ' ' 'BLDAT' '전표 전기일' ' ' ' ',
                                ' ' 'BUDAT' '전표 증빙일' ' ' ' ',
                                ' ' 'BKTXT' '전표 헤더 텍스트' ' ' ' ',
                                ' ' 'EMP_NUM' '담당자' ' ' ' ',
                                ' ' 'WAERS' '통화' ' ' ' ',
                                ' ' 'ZISDN' '임시 전표 번호' ' ' ' ',
                                ' ' 'ZISDD' '임시 전표 생성일' ' ' ' '.

  PERFORM set_lbot_fcat USING : 'X' 'BUKRS' '회사 코드' ' ' ' ',
                                'X' 'BELNR' '전표 번호' ' ' ' ',
                                'X' 'GJAHR' '회계 연도' ' ' ' ',
                                'X' 'BUZEI' '전표 상세 번호' '' ' ',
                                ' ' 'AUGBL' '반제 전표 번호' 'X' ' ',
                                ' ' 'AUGDT' '반제 일자' 'X' ' ',
                                ' ' 'KOART' '계정 유형' ' ' ' ',
                                ' ' 'SHKZG' '차/대' ' ' 'X',
                                ' ' 'PRICE' '금액' ' ' ' ',
                                ' ' 'WAERS' '통화' ' ' ' ',
                                ' ' 'BPCODE' 'BP CODE' ' ' ' ',
                                ' ' 'HKONT' '계정 코드' ' ' ' ',
                                ' ' 'TXT50' '계정 과목' ' ' ' '.

  PERFORM set_rtop_fcat USING : 'X' 'BUKRS' '회사 코드' ' ' ' ',
                                'X' 'BELNR' '전표 번호' ' ' ' ',
                                'X' 'GJAHR' '회계 연도' ' ' ' ',
                                ' ' 'XREF1_HD' '원 전표' 'X' ' ',
                                ' ' 'BLART' '전표 유형' ' ' ' ',
                                ' ' 'BLDAT' '전표 전기일' ' ' ' ',
                                ' ' 'BUDAT' '전표 증빙일' ' ' ' ',
                                ' ' 'BKTXT' '전표 헤더 텍스트' ' ' ' ',
                                ' ' 'EMP_NUM' '담당자' ' ' ' ',
                                ' ' 'WAERS' '통화' ' ' ' '.

  PERFORM set_rbot_fcat USING : 'X' 'BUKRS' '회사 코드' ' ' ' ',
                                'X' 'BELNR' '전표 번호' ' ' ' ',
                                'X' 'GJAHR' '회계 연도' ' ' ' ',
                                'X' 'BUZEI' '전표 상세 번호' ' ' ' ',
                                ' ' 'KOART' '계정 유형' ' ' ' ',
                                ' ' 'SHKZG' '차/대' ' ' 'X',
                                ' ' 'PRICE' '금액' ' ' ' ',
                                ' ' 'WAERS' '통화' ' ' ' ',
                                ' ' 'BPCODE' 'BP CODE' ' ' ' ',
                                ' ' 'HKONT' '계정 코드' ' ' ' '.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_ltop_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_ltop_fcat  USING  pv_key pv_field
                           pv_coltext pv_emph pv_just.
  CLEAR gs_ltop_fcat.
  gs_ltop_fcat-key = pv_key.
  gs_ltop_fcat-fieldname = pv_field.
  gs_ltop_fcat-coltext = pv_coltext.
  gs_ltop_fcat-emphasize = pv_emph.
  gs_ltop_fcat-just = pv_just.

  CASE pv_field.
    WHEN 'BELNR'.
      gs_ltop_fcat-hotspot = abap_true.
  ENDCASE.
  APPEND gs_ltop_fcat TO gt_ltop_fcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_lbot_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_lbot_fcat  USING  pv_key pv_field
                           pv_coltext pv_emph pv_just.

  CLEAR gs_lbot_fcat.
  gs_lbot_fcat-key = pv_key.
  gs_lbot_fcat-fieldname = pv_field.
  gs_lbot_fcat-coltext = pv_coltext.
  gs_lbot_fcat-emphasize = pv_emph.
  gs_lbot_fcat-just = pv_just.

  CASE pv_field.
    WHEN 'PRICE'.
      gs_lbot_fcat-cfieldname = 'WAERS'.
  ENDCASE.

  APPEND gs_lbot_fcat TO gt_lbot_fcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_rtop_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_rtop_fcat  USING  pv_key pv_field
                           pv_coltext pv_emph pv_just.

  CLEAR gs_rtop_fcat.
  gs_rtop_fcat-key = pv_key.
  gs_rtop_fcat-fieldname = pv_field.
  gs_rtop_fcat-coltext = pv_coltext.
  gs_rtop_fcat-emphasize = pv_emph.
  gs_rtop_fcat-just = pv_just.

  APPEND gs_rtop_fcat TO gt_rtop_fcat.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_rbot_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_rbot_fcat  USING pv_key pv_field
                          pv_coltext pv_emph pv_just.

  CLEAR gs_rbot_fcat.
  gs_rbot_fcat-key = pv_key.
  gs_rbot_fcat-fieldname = pv_field.
  gs_rbot_fcat-coltext = pv_coltext.
  gs_rbot_fcat-emphasize = pv_emph.
  gs_rbot_fcat-just = pv_just.

  CASE pv_field.
    WHEN 'PRICE'.
      gs_rbot_fcat-cfieldname = 'WAERS'.
  ENDCASE.

  APPEND gs_rbot_fcat TO gt_rbot_fcat.

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

  gs_layo_ltop-zebra = abap_true.
  gs_layo_ltop-cwidth_opt = 'A'.
  gs_layo_ltop-sel_mode = 'D'.
  gs_layo_ltop-smalltitle = 'X'.
  gs_layo_ltop-grid_title = '전표 헤더'.

  gs_layo_lbot-zebra = abap_true.
  gs_layo_lbot-cwidth_opt = 'A'.
  gs_layo_lbot-sel_mode = 'D'.
  gs_layo_lbot-smalltitle = 'X'.
  gs_layo_lbot-grid_title = '전표 상세 내역'.

  gs_layo_rtop-zebra = abap_true.
  gs_layo_rtop-cwidth_opt = 'A'.
  gs_layo_rtop-sel_mode = 'D'.
  gs_layo_rtop-smalltitle = 'X'.
  gs_layo_rtop-grid_title = '반제 전표 헤더'.

  gs_layo_rbot-zebra = abap_true.
  gs_layo_rbot-cwidth_opt = 'A'.
  gs_layo_rbot-sel_mode = 'D'.
  gs_layo_rbot-smalltitle = 'X'.
  gs_layo_rbot-grid_title = '반제 전표 상세 내역'.

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

  " TOP OF PAGE
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
      rows    = 2
      columns = 2.

  " container left top
  CALL METHOD go_split->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_ltop_cont.

  " container left bottom
  CALL METHOD go_split->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_lbot_cont.

  " container right top
  CALL METHOD go_split->get_container
    EXPORTING
      row       = 1
      column    = 2
    RECEIVING
      container = go_rtop_cont.

  " container right bottom
  CALL METHOD go_split->get_container
    EXPORTING
      row       = 2
      column    = 2
    RECEIVING
      container = go_rbot_cont.

  " grid
  CREATE OBJECT go_ltop_grid
    EXPORTING
      i_parent = go_ltop_cont.

  " grid
  CREATE OBJECT go_lbot_grid
    EXPORTING
      i_parent = go_lbot_cont.

  " grid
  CREATE OBJECT go_rtop_grid
    EXPORTING
      i_parent = go_rtop_cont.

  " grid
  CREATE OBJECT go_rbot_grid
    EXPORTING
      i_parent = go_rbot_cont.

  " Top-of-page : Create TOP-Document
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
  ls_button-text = TEXT-t05.

  APPEND ls_button TO po_object->mt_toolbar.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_user_command
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM handle_user_command  USING   pv_ucomm.

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
         lt_bkpf      TYPE TABLE OF zc302fit0001,
         lt_bseg      TYPE TABLE OF zc302fit0002,
         lv_subrc1    TYPE sy-subrc,
         lv_subrc2    TYPE sy-subrc,
         lv_subrc3    TYPE sy-subrc,
         lv_subrc4    TYPE sy-subrc.


  " 선택된 행의 index값 저장
  CALL METHOD go_ltop_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_rowno.

  gv_lines = lines( lt_rowno ).

  " 선택된 행의 개수 체크
  IF gv_lines > 1.
    MESSAGE s001 WITH TEXT-e04 DISPLAY LIKE 'E'.
    EXIT.
  ELSEIF gv_lines = 0.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  " 행의 인덱스 값을 읽어서 해당 문서의 번호를 알아옴.
  READ TABLE lt_rowno INTO ls_rowno INDEX 1.
  READ TABLE gt_body INTO gs_body INDEX ls_rowno-index.

  " 전표 발행 여부 확인
  IF gs_body-augbl IS NOT INITIAL.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  " 발행 확인을 위한 팝업 창 띄우기
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      text_question         = '반제 처리하시겠습니까?'
      text_button_1         = '승인'(001)
      icon_button_1         = 'ICON_CHECKED'
      text_button_2         = '취소'(002)
      icon_button_2         = 'ICON_INCOMPLETE'
      default_button        = '1'
      display_cancel_button = ' '
    IMPORTING
      answer                = lv_answer.

  " 취소 버튼 클릭 시 프로그램 분기
  IF lv_answer <> 1.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  " 채번
  CALL FUNCTION 'NUMBER_GET_INFO'
    EXPORTING
      nr_range_nr = '04'
      object      = 'ZNRC302_2'
    IMPORTING
      interval    = lv_number.


  " 기존 전표의 반제 관련 필드 채우기
  gs_body-icon = icon_led_green.
  gs_body-augbl = lv_number-nrlevel + 1. " 반제 전표 번호 삽입
  gs_body-augdt = sy-datum.
  gs_body-aedat = sy-datum.
  gs_body-aezet = sy-uzeit.
  gs_body-aenam = sy-uname.
  MODIFY gt_body FROM gs_body INDEX ls_rowno-index
                              TRANSPORTING augbl augdt aedat
                                           aezet aenam icon.
  CLEAR : gs_bkpf, gs_bseg.
  " ap, ar에 따른 프로그램 분기
  CASE gs_body-zisdn+0(1).
    WHEN 'I'.
      MESSAGE s001 WITH 'ar'.
      " 새로 생성될 반제 전표의 헤더 구성
      gs_bkpf-bukrs = gs_body-bukrs.
      gs_bkpf-belnr = lv_number-nrlevel + 1.
      gs_bkpf-gjahr = sy-datum+0(4).
      gs_bkpf-blart = 'AB'.
      gs_bkpf-bldat = sy-datum.
      gs_bkpf-budat = sy-datum.
      gs_bkpf-bktxt = 'AR 반제'.
      gs_bkpf-emp_num = sy-uname.
      gs_bkpf-waers = gs_body-waers.
      gs_bkpf-xref1_hd = gs_body-belnr.
      gs_bkpf-erdat = sy-datum.
      gs_bkpf-erzet = sy-uzeit.
      gs_bkpf-ernam = sy-uname.
      APPEND gs_bkpf TO gt_bkpf.

      " 새로 생성될 반제 전표의 아이템 구성
      CLEAR : gt_item.
      SELECT * FROM zc302fit0002
        INTO CORRESPONDING FIELDS OF TABLE gt_item
        WHERE bukrs = gs_body-bukrs
          AND gjahr = gs_body-gjahr
          AND belnr = gs_body-belnr.

      IF gt_item IS INITIAL.
        MESSAGE s001 WITH TEXT-e06 DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

      LOOP AT gt_item INTO gs_item.
        gv_tabix = sy-tabix.

        IF gs_item-shkzg = 'S'.
          MOVE-CORRESPONDING gs_item TO gs_bseg.
          gs_bseg-gjahr = sy-datum+0(4).
          gs_bseg-belnr = lv_number-nrlevel + 1.
          gs_bseg-shkzg = 'H'.
          gs_bseg-erdat = sy-datum.
          gs_bseg-erzet = sy-uzeit.
          gs_bseg-ernam = sy-uname.
          CLEAR : gs_bseg-aenam, gs_bseg-aezet, gs_bseg-aedat.
          APPEND gs_bseg TO gt_bseg.
        ELSE.
          MOVE-CORRESPONDING gs_item TO gs_bseg.
          gs_bseg-gjahr = sy-datum+0(4).
          gs_bseg-belnr = lv_number-nrlevel + 1.
          gs_bseg-koart = 'A'.
          gs_bseg-shkzg = 'S'.
          CLEAR gs_bseg-bpcode.
          gs_bseg-hkont = 'ACC0001000'.
          gs_bseg-erdat = sy-datum.
          gs_bseg-ernam = sy-uname.
          gs_bseg-erzet = sy-uzeit.
          CLEAR : gs_bseg-aenam, gs_bseg-aezet, gs_bseg-aedat.
          APPEND gs_bseg TO gt_bseg.
        ENDIF.

        gs_item-augbl = lv_number-nrlevel + 1.
        gs_item-augdt = sy-datum.
        MODIFY gt_item FROM gs_item INDEX gv_tabix
                                    TRANSPORTING augbl augdt.
      ENDLOOP.

      " 이렇게 하면 gt_body 바뀌고, gt_item 바뀌고 gt_bkpf 바뀌고 gt_bseg바뀌고
      "따라서 각각 db table을 반영해줄 필요가 있습니도.
    WHEN 'M'.
      MESSAGE s001 WITH 'ap'.
      " 새로 생성될 반제 전표의 헤더 구성
      gs_bkpf-bukrs = gs_body-bukrs.
      gs_bkpf-belnr = lv_number-nrlevel + 1.
      gs_bkpf-gjahr = sy-datum+0(4).
      gs_bkpf-blart = 'AB'.
      gs_bkpf-bldat = sy-datum.
      gs_bkpf-budat = sy-datum.
      gs_bkpf-bktxt = 'AP 반제'.
      gs_bkpf-emp_num = sy-uname.
      gs_bkpf-waers = gs_body-waers.
      gs_bkpf-xref1_hd = gs_body-belnr.
      gs_bkpf-erdat = sy-datum.
      gs_bkpf-erzet = sy-uzeit.
      gs_bkpf-ernam = sy-uname.
      APPEND gs_bkpf TO gt_bkpf.

      " 새로 생성될 반제 전표의 아이템 구성
      CLEAR : gt_item.
      SELECT * FROM zc302fit0002
        INTO CORRESPONDING FIELDS OF TABLE gt_item
        WHERE bukrs = gs_body-bukrs
          AND gjahr = gs_body-gjahr
          AND belnr = gs_body-belnr.

      IF gt_item IS INITIAL.
        MESSAGE s001 WITH TEXT-e06 DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

      LOOP AT gt_item INTO gs_item.
        gv_tabix = sy-tabix.

        IF gs_item-shkzg = 'H'.
          MOVE-CORRESPONDING gs_item TO gs_bseg.
          gs_bseg-gjahr = sy-datum+0(4).
          gs_bseg-belnr = lv_number-nrlevel + 1.
          gs_bseg-shkzg = 'S'.
          gs_bseg-erdat = sy-datum.
          gs_bseg-erzet = sy-uzeit.
          gs_bseg-ernam = sy-uname.
          CLEAR : gs_bseg-aenam, gs_bseg-aezet, gs_bseg-aedat.
          APPEND gs_bseg TO gt_bseg.
        ELSE.
          MOVE-CORRESPONDING gs_item TO gs_bseg.
          gs_bseg-gjahr = sy-datum+0(4).
          gs_bseg-belnr = lv_number-nrlevel + 1.
          gs_bseg-koart = 'A'.
          gs_bseg-shkzg = 'H'.
          CLEAR gs_bseg-bpcode.
          gs_bseg-hkont = 'ACC0001000'.
          gs_bseg-erdat = sy-datum.
          gs_bseg-ernam = sy-uname.
          gs_bseg-erzet = sy-uzeit.
          CLEAR : gs_bseg-aenam, gs_bseg-aezet, gs_bseg-aedat.
          APPEND gs_bseg TO gt_bseg.
        ENDIF.

        gs_item-augbl = lv_number-nrlevel + 1.
        gs_item-augdt = sy-datum.
        MODIFY gt_item FROM gs_item INDEX gv_tabix
                                          TRANSPORTING augbl augdt.
      ENDLOOP.
  ENDCASE.

  " DB 테이블 저장
  MOVE-CORRESPONDING gt_body TO lt_bkpf.
  MOVE-CORRESPONDING gt_item TO lt_bseg.

  MODIFY zc302fit0001 FROM TABLE lt_bkpf.
  lv_subrc1 = sy-subrc.
  MODIFY zc302fit0002 FROM TABLE lt_bseg.
  lv_subrc2 = sy-subrc.

  MODIFY zc302fit0001 FROM TABLE gt_bkpf.
  lv_subrc3 = sy-subrc.
  MODIFY zc302fit0002 FROM TABLE gt_bseg.
  lv_subrc4 = sy-subrc.

  IF lv_subrc1 = 0 AND
     lv_subrc2 = 0 AND
     lv_subrc3 = 0 AND
     lv_subrc4 = 0.

    COMMIT WORK AND WAIT.
    MESSAGE s001 WITH TEXT-t04.
    " alv refresh
    CALL METHOD : go_ltop_grid->refresh_table_display,
                  go_rtop_grid->refresh_table_display,
                  go_rbot_grid->refresh_table_display.

    " 전표 채번했으니까 증번
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '04'
        object      = 'ZNRC302_2'
      IMPORTING
        number      = lv_number.

  ELSE.

    ROLLBACK WORK.
    MESSAGE s001 WITH TEXT-e07 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_hotspot
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&---------------------------------------------------------------------*
FORM handle_hotspot  USING   pv_row_id
                             pv_column_id.

  CLEAR : gs_body.
  READ TABLE gt_body INTO gs_body INDEX pv_row_id.

  CLEAR : gt_item.
  SELECT * FROM zc302mt0006 AS a INNER JOIN zc302fit0002 AS b
    ON a~saknr = b~hkont
   AND a~bukrs = b~bukrs
    INTO CORRESPONDING FIELDS OF TABLE gt_item
    WHERE b~bukrs = gs_body-bukrs
      AND b~gjahr = gs_body-gjahr
      AND b~belnr = gs_body-belnr.

  CALL METHOD : go_lbot_grid->refresh_table_display.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form register_events
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM register_events .
  SET HANDLER : lcl_event_handler=>hotspot FOR go_ltop_grid,
                lcl_event_handler=>toolbar FOR go_ltop_grid,
                lcl_event_handler=>user_command FOR go_ltop_grid,
                lcl_event_handler=>top_of_page  FOR go_ltop_grid.

  CALL METHOD go_ltop_grid->set_toolbar_interactive.

  CALL METHOD go_dyndoc_id->initialize_document
    EXPORTING
      background_color = cl_dd_area=>col_textarea.

  CALL METHOD go_ltop_grid->list_processing_events
    EXPORTING
      i_event_name = 'TOP_OF_PAGE'
      i_dyndoc_id  = go_dyndoc_id.

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
  IF pa_all = abap_true.
    lv_temp = '전체'.
  ELSE.
    lv_temp = '미결 전표'.
  ENDIF.
  PERFORM add_row USING lr_dd_table col_field col_value '완결 여부' lv_temp.

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
  PERFORM add_row USING lr_dd_table col_field col_value 'BP Code' lv_temp.

*-- 계획년도 & 계획 월
  so_date = VALUE #( so_date[ 1 ] OPTIONAL ).
  CLEAR : lv_temp.
  IF so_date-low IS NOT INITIAL.
    lv_temp = so_date-low.
    IF so_date-high IS NOT INITIAL.
      CONCATENATE lv_temp ' ~ ' so_date-high INTO lv_temp.
    ENDIF.
  ELSE.
    lv_temp = '전체'.
  ENDIF.
  PERFORM add_row USING lr_dd_table col_field col_value '전표 전기일' lv_temp.

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
