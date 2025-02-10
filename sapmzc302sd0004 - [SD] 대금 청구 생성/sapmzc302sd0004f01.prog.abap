*&---------------------------------------------------------------------*
*& Include          SAPMZC302SD0004F01
*&---------------------------------------------------------------------*
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

    CLEAR : gt_lfcat, gs_lfcat.
    PERFORM set_left_catalog USING : 'X' 'DLVNUM'    'ZC302SDT0005' 'C',   " 출하번호
                                     'X' 'SONUM'     'ZC302SDT0005' 'C',   " 판매주문번호
                                     ' ' 'SALE_ORG'  'ZC302SDT0005' ' ',   " 영업조직
                                     ' ' 'CHANNEL'   'ZC302SDT0005' ' ',   " 유통채널
                                     ' ' 'BPCODE'    'ZC302SDT0005' ' ',   " BP코드
                                     ' ' 'DTYPE'     'ZC302SDT0005' ' ',   " 배송유형
                                     ' ' 'DCOMP'     'ZC302SDT0005' ' ',   " 배송업체
                                     ' ' 'EMP_NUM'   'ZC302SDT0005' ' ',   " 사원번호
                                     ' ' 'PIFLAG'    'ZC302SDT0005' ' ',   " 피킹여부
                                     ' ' 'GIFLAG'    'ZC302SDT0005' ' ',   " GI여부
                                     ' ' 'BFLAG'     'ZC302SDT0005' ' '.   " 대금청구여부

    CLEAR : gt_rfcat, gs_rfcat.
    PERFORM set_right_catalog USING : 'X' 'BILNUM'    'ZC302SDT0009' 'C',  " 대금청구번호
                                      ' ' 'SALE_ORG'  'ZC302SDT0009' ' ',  " 영업조직
                                      ' ' 'CHANNEL'   'ZC302SDT0009' ' ',  " 유통채널
                                      ' ' 'SONUM'     'ZC302SDT0009' ' ',  " 판매주문번호
                                      ' ' 'BPCODE'    'ZC302SDT0009' ' ',  " BP코드
                                      ' ' 'NETWR'     'ZC302SDT0009' ' ',  " 청구금액
                                      ' ' 'WAERS'     'ZC302SDT0009' ' ',  " 통화키
                                      ' ' 'BLDAT'     'ZC302SDT0009' ' ',  " 청구일자
                                      ' ' 'EMP_NUM'   'ZC302SDT0009' ' '.  " 사원번호

    PERFORM set_layout.
    PERFORM create_object.

    gs_variant-report = sy-repid.
    gs_variant-handle = 'ALV1'.

    SET HANDLER : lcl_event_handler=>toolbar       FOR go_left_grid,
                  lcl_event_handler=>toolbar_right FOR go_right_grid,
                  lcl_event_handler=>user_command  FOR go_left_grid,
                  lcl_event_handler=>user_command  FOR go_right_grid.

    CALL METHOD go_left_grid->set_table_for_first_display
      EXPORTING
        is_variant      = gs_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_llayout
      CHANGING
        it_outtab       = gt_ship
        it_fieldcatalog = gt_lfcat.

    gs_variant-report = sy-repid.
    gs_variant-handle = 'ALV2'.

    CALL METHOD go_right_grid->set_table_for_first_display
      EXPORTING
        is_variant      = gs_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_rlayout
      CHANGING
        it_outtab       = gt_billing
        it_fieldcatalog = gt_rfcat.


    CALL METHOD go_split_cont->set_column_width
      EXPORTING
        id    = 1
        width = 47.


  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_left_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_left_catalog  USING pv_key pv_field pv_table pv_just.

  gs_lfcat-key       = pv_key.
  gs_lfcat-fieldname = pv_field.
  gs_lfcat-ref_table = pv_table.
  gs_lfcat-just      = pv_just.

  CASE pv_field.
    WHEN 'DCOMP'.
      gs_lfcat-coltext = '배송업체'.
    WHEN 'EMP_NUM'.
      gs_lfcat-coltext = '사원번호'.
  ENDCASE.

  APPEND gs_lfcat TO gt_lfcat.
  CLEAR gs_lfcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_right_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_right_catalog  USING   pv_key pv_field pv_table pv_just.

  CLEAR gs_rfcat.
  gs_rfcat-key         = pv_key.
  gs_rfcat-fieldname   = pv_field.
  gs_rfcat-ref_table   = pv_table.
  gs_rfcat-just        = pv_just.

  CASE pv_field.
    WHEN 'BLDAT'.
      gs_rfcat-coltext = '청구일자'.
    WHEN 'NETWR'.
      gs_rfcat-coltext = '청구금액'.
      gs_rfcat-cfieldname = 'WAERS'.
    WHEN 'EMP_NUM'.
      gs_rfcat-coltext = '사원번호'.
    WHEN 'WAERS'.
      gs_rfcat-coltext = '통화'.
  ENDCASE.

  APPEND gs_rfcat TO gt_rfcat.
  CLEAR gs_rfcat.

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
      container_name = 'MAIN_CONT'.

  CREATE OBJECT go_split_cont
    EXPORTING
      parent  = go_container
      rows    = 1
      columns = 2.

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

  CREATE OBJECT go_left_grid
    EXPORTING
      i_parent = go_left_cont.

  CREATE OBJECT go_right_grid
    EXPORTING
      i_parent = go_right_cont.

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

  PERFORM set_ranges.

  CLEAR gt_ship.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_ship
    FROM zc302sdt0005
   WHERE dlvnum   IN gr_dlvnum
     AND sale_org IN gr_sale_org
     AND channel  IN gr_channel
     AND bpcode   IN gr_bpcode
     AND piflag   EQ 'Y'           " 피킹여부 Y만
     AND giflag   EQ 'Y'           " 출하여부 Y만
     AND bflag    EQ 'N'           " 대금청구여부 N만 조회
     AND channel  NE 'OS'.         " 자사몰 제외 (B2B만 대금청구)


*
*  IF gt_ship IS INITIAL.
*    MESSAGE s037 DISPLAY LIKE 'E'.
*    EXIT.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_ranges
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_ranges .

  REFRESH : gr_dlvnum, gr_sale_org, gr_channel, gr_bpcode.

  IF gv_dlvnum IS NOT INITIAL.
    gr_dlvnum-sign = 'I'.
    gr_dlvnum-option = 'EQ'.
    gr_dlvnum-low = gv_dlvnum.
    APPEND gr_dlvnum.
  ENDIF.


  IF gv_sale_org IS NOT INITIAL.
    gr_sale_org-sign = 'I'.
    gr_sale_org-option = 'EQ'.
    gr_sale_org-low = gv_sale_org.
    APPEND gr_sale_org.
  ENDIF.


  IF gv_channel IS NOT INITIAL.
    gr_channel-sign = 'I'.
    gr_channel-option = 'EQ'.
    gr_channel-low = gv_channel.
    APPEND gr_channel.
  ENDIF.

  IF gv_bpcode IS NOT INITIAL.
    gr_bpcode-sign = 'I'.
    gr_bpcode-option = 'EQ'.
    gr_bpcode-low = gv_bpcode.
    APPEND gr_bpcode.
  ENDIF.

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

  gs_llayout = VALUE #( zebra = abap_true
                       cwidth_opt = 'A'
                       sel_mode   = 'D'
                       grid_title = '출하문서(GI완료건)'
                       smalltitle =  abap_true ).

  gs_rlayout = VALUE #( zebra = abap_true
                        cwidth_opt = 'A'
                        sel_mode   = 'D'
                        grid_title = '대금청구문서'
                        smalltitle =  abap_true ).

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

*-- Set ALV Toolbar
  PERFORM set_toolbar USING : 'BILLING' icon_short_message ' ' ' ' TEXT-i01 po_object.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> ICON_SYSTEM_OKAY
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> PO_OBJECT
*&---------------------------------------------------------------------*
FORM set_toolbar  USING  pv_func pv_icon pv_qinfo pv_type pv_text
                         po_object TYPE REF TO cl_alv_event_toolbar_set.

  CLEAR gs_button.
  gs_button-function  = pv_func.
  gs_button-icon      = pv_icon.
  gs_button-quickinfo = pv_qinfo.
  gs_button-butn_type = pv_type.
  gs_button-text      = pv_text.
  APPEND gs_button TO po_object->mt_toolbar.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_user_command
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM handle_user_command  USING pv_ucomm.

  CASE pv_ucomm.
    WHEN 'BILLING'.
      PERFORM create_billing.
    WHEN 'SAVE'.
      PERFORM save_billing.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_billing
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_billing.

  DATA : lt_row    TYPE lvc_t_row,
         ls_row    TYPE lvc_s_row,
         lv_answer,
         lv_sonum  TYPE zc302sdt0009-sonum,      " 판매주문번호(조건 사용 시)
         ls_temp   TYPE zc302sdt0009.

  DATA : BEGIN OF ls_bilnum,
           bilnum TYPE zc302sdt0009-bilnum,
         END OF ls_bilnum,
         lt_bilnum        LIKE TABLE OF ls_bilnum,
         lv_condition(10),
         lv_year          TYPE i,
         lv_month         TYPE i,
         lv_bilnum        TYPE zc302sdt0009-bilnum,
         lv_index         TYPE numc4.

  lv_year  = sy-datum+2(2).  " 현재년도
  lv_month = sy-datum+4(2).  " 현재월


*-- 확인 팝업창
  PERFORM confirm CHANGING lv_answer.

  IF lv_answer NE '1'.
    MESSAGE w101.
    EXIT.
  ENDIF.

*-- 왼쪽 ALV(출하)에서 선택된 행의 Index 가져오기
  CALL METHOD go_left_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_row.

*-- 선택된 행이 있는지 확인
  IF sy-subrc = 0 AND lines( lt_row ) > 0.

    LOOP AT lt_row INTO ls_row.
      CLEAR : gs_ship, gs_billing.
      READ TABLE gt_ship INTO gs_ship INDEX ls_row-index.

      MOVE-CORRESPONDING gs_ship TO gs_billing.

*-- 대금청구번호 채번
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr = '01'
          object      = 'ZNRC302242'
        IMPORTING
          number      = gv_number.

      " 새로운 대금청구번호 생성
      gs_billing-bilnum = 'IV' && lv_year && lv_month && gv_number.

*-- 사원번호(담당자)
      gs_billing-emp_num = sy-uname.

*-- 청구일자
      gs_billing-bldat = sy-datum.

*-- 판매주문번호 담기
      lv_sonum = gs_billing-sonum.

      gs_billing-ivflag = 'N'.

*-- gs_ship의 판매주문번호(sonum)에서 주문금액, 통화
      SELECT SINGLE netwr waers
        INTO (gs_billing-netwr, gs_billing-waers)
        FROM zc302sdt0003
       WHERE sonum = lv_sonum.

*-- TIME STAMP 는 CLEAR
      CLEAR : gs_billing-aedat, gs_billing-aenam, gs_billing-aezet,
              gs_billing-erdat, gs_billing-ernam, gs_billing-erzet.

      APPEND gs_billing TO gt_billing.

    ENDLOOP.

    CALL METHOD go_left_grid->refresh_table_display.
    CALL METHOD go_right_grid->refresh_table_display.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_toolbar_right
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM handle_toolbar_right  USING po_object TYPE REF TO cl_alv_event_toolbar_set
                                 pv_interactive.

*-- Set ALV Toolbar
  PERFORM set_toolbar USING : 'SAVE' icon_system_save ' ' ' ' TEXT-i02 po_object.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form confirm_billing
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM confirm_billing  CHANGING pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = '대금청구생성'
      text_question         = 'Billing을 생성하시겠습니까?'
      text_button_1         = 'Yes'(001)
      icon_button_1         = 'ICON_OKAY'
      text_button_2         = 'No'(002)
      icon_button_2         = 'ICON_CANCEL'
      default_button        = '1'
      display_cancel_button = 'X'
    IMPORTING
      answer                = pv_answer.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_billing
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_billing.

*-- 저장용 ITAB 을 선언
  DATA : lt_save   TYPE TABLE OF zc302sdt0009,
         ls_save   TYPE zc302sdt0009,
         lv_tabix  TYPE sy-tabix,
         lv_answer.

  MOVE-CORRESPONDING gt_billing TO lt_save.

*-- 저장 데이터가 없을 시 아래 로직 수행하지 않기
  IF ( lt_save IS INITIAL ).
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 확인 메시지
  PERFORM confirm CHANGING lv_answer.

*-- TIMESTAMP 정보 세팅
  LOOP AT lt_save INTO ls_save.

    lv_tabix = sy-tabix.

    ls_save-erdat = sy-datum.
    ls_save-ernam = sy-uname.
    ls_save-erzet = sy-uzeit.


    MODIFY lt_save FROM ls_save INDEX lv_tabix
                                TRANSPORTING erdat ernam erzet.

  ENDLOOP.

*-- 저장
  MODIFY zc302sdt0009 FROM TABLE lt_save.

*-- 대금청구여부 Y로 업데이트
  LOOP AT gt_billing INTO gs_billing.
    DATA(lv_tabix2) = sy-tabix.

    READ TABLE gt_ship INTO gs_ship WITH KEY sonum = gs_ship-sonum.

    gs_ship-bflag = 'Y'.
    gs_ship-aedat = sy-datum.
    gs_ship-aenam = sy-uname.
    gs_ship-aezet = sy-uzeit.

    MODIFY gt_ship FROM gs_ship INDEX lv_tabix2 TRANSPORTING bflag aedat aenam aezet.

  ENDLOOP.

  MODIFY zc302sdt0005 FROM TABLE gt_ship.


  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
    MESSAGE i001 WITH '저장되었습니다.'.
    PERFORM refresh_left_alv.     " 변경된 데이터를 GI탭에 반영
  ELSE.
    ROLLBACK WORK.
    MESSAGE i001 WITH '저장에 실패하였습니다.' DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form confirm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM confirm  CHANGING pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = '대금 청구 문서 생성'
      text_question         = '대금 청구 문서를 생성하시겠습니까?'
      text_button_1         = 'Yes'(001)
      icon_button_1         = 'ICON_OKAY'
      text_button_2         = 'No'(002)
      icon_button_2         = 'ICON_CANCEL'
      default_button        = '1'
      display_cancel_button = 'X'
    IMPORTING
      answer                = pv_answer.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_dlvnum_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_dlvnum_f4 .

  DATA : BEGIN OF ls_dlvnum,
           dlvnum TYPE zc302sdt0005-dlvnum,
         END OF ls_dlvnum,
         lt_dlvnum LIKE TABLE OF ls_dlvnum.

  SELECT DISTINCT dlvnum
    INTO CORRESPONDING FIELDS OF TABLE lt_dlvnum
    FROM zc302sdt0005
   WHERE piflag EQ 'Y'
     AND giflag EQ 'Y'
     AND bflag EQ 'N'
   ORDER BY dlvnum.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'DLVNUM'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GV_DLVNUM'
      value_org       = 'S'
    TABLES
      value_tab       = lt_dlvnum
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_channel_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_channel_f4 .

  DATA : BEGIN OF ls_channel,
           channel TYPE zc302sdt0005-channel,
         END OF ls_channel,
         lt_channel LIKE TABLE OF ls_channel.

  SELECT DISTINCT channel
    INTO CORRESPONDING FIELDS OF TABLE lt_channel
    FROM zc302sdt0005
    WHERE piflag EQ 'Y'
     AND giflag EQ 'Y'
     AND bflag EQ 'N'
   ORDER BY channel.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'CHANNEL'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GV_CHANNEL'
      value_org       = 'S'
    TABLES
      value_tab       = lt_channel
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_bpcode_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_bpcode_f4 .

  DATA : BEGIN OF ls_bpcode,
           bpcode TYPE zc302sdt0005-bpcode,
         END OF ls_bpcode,
         lt_bpcode LIKE TABLE OF ls_bpcode.

  SELECT DISTINCT bpcode
    INTO CORRESPONDING FIELDS OF TABLE lt_bpcode
    FROM zc302sdt0005
   WHERE piflag EQ 'Y'
     AND giflag EQ 'Y'
     AND bflag EQ 'N'
   ORDER BY bpcode.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BPCODE'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GV_BPCODE'
      value_org       = 'S'
    TABLES
      value_tab       = lt_bpcode
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_left_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_left_alv .

  CLEAR gt_ship.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_ship
    FROM zc302sdt0005
   WHERE dlvnum   IN gr_dlvnum
     AND sale_org IN gr_sale_org
     AND channel  IN gr_channel
     AND bpcode   IN gr_bpcode
     AND piflag   EQ 'Y'           " 피킹여부 Y만
     AND giflag   EQ 'Y'           " 출하여부 Y만
     AND bflag    EQ 'N'.          " 대금청구여부 N만 조회

  CALL METHOD go_left_grid->refresh_table_display.

ENDFORM.
