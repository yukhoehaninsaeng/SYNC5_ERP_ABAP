*&---------------------------------------------------------------------*
*& Include          SAPMZC302SD0003F01
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
    PERFORM set_left_catalog USING : 'X' 'SONUM'     'ZC302SDT0003' 'C',   " 판매주문번호
                                     ' ' 'SALE_ORG'  'ZC302SDT0003' ' ',   " 영업조직
                                     ' ' 'CHANNEL'   'ZC302SDT0003' ' ',   " 유통채널
                                     ' ' 'BPCODE'    'ZC302SDT0003' ' ',   " BP코드
                                     ' ' 'CUST_NUM'  'ZC302SDT0003' 'C',   " 회원번호
                                     ' ' 'PDATE'     'ZC302SDT0003' ' ',   " 주문일자
                                     ' ' 'NETWR'     'ZC302SDT0003' ' ',   " 주문금액
                                     ' ' 'WAERS'     'ZC302SDT0003' ' ',   " 통화
                                     ' ' 'SDATE'     'ZC302SDT0003' ' ',   " 판매오더생성일
                                     ' ' 'STATUS'    'ZC302SDT0003' ' ',   " 결재상태
                                     ' ' 'APDATE'    'ZC302SDT0003' ' '.   " 결재일자


    CLEAR : gt_rfcat, gs_rfcat.
    PERFORM set_right_catalog USING :   'X' 'DLVNUM'    'ZC302SDT0005' 'C',   " 출하번호
                                        'X' 'SONUM'     'ZC302SDT0005' 'C',   " 판매주문번호
                                        ' ' 'SALE_ORG'  'ZC302SDT0005' ' ',   " 영업조직
                                        ' ' 'CHANNEL'   'ZC302SDT0005' ' ',   " 유통채널
                                        ' ' 'BPCODE'    'ZC302SDT0005' ' ',   " BP코드
                                        ' ' 'CUST_NUM'  'ZC302SDT0005' ' ',   " 회원번호
                                        ' ' 'DTYPE'     'ZC302SDT0005' ' ',   " 배송유형
                                        ' ' 'DCOMP'     'ZC302SDT0005' ' ',   " 배송업체
                                        ' ' 'EMP_NUM'   'ZC302SDT0005' ' ',   " 사원번호
                                        ' ' 'BFLAG'     'ZC302SDT0005' ' '.   " 대금청구여부

    PERFORM set_layout.
    PERFORM create_object.


    SET HANDLER : lcl_event_handler=>toolbar        FOR go_left_grid,
                  lcl_event_handler=>toolbar_right  FOR go_right_grid,
                  lcl_event_handler=>user_command   FOR go_left_grid,
                  lcl_event_handler=>user_command   FOR go_right_grid,
                  lcl_event_handler=>hotspot_click  FOR go_left_grid.


    gs_variant-report = sy-repid.
    gs_variant-handle = 'ALV1'.

    CALL METHOD go_left_grid->set_table_for_first_display
      EXPORTING
        is_variant      = gs_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_llayout
      CHANGING
        it_outtab       = gt_order
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
        it_outtab       = gt_ship
        it_fieldcatalog = gt_rfcat.

    CALL METHOD go_split_cont->set_column_width
      EXPORTING
        id    = 1
        width = 53.


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
*&---------------------------------------------------------------------*
FORM set_left_catalog  USING    pv_key pv_field pv_table pv_just.

  gs_lfcat-key       = pv_key.
  gs_lfcat-fieldname = pv_field.
  gs_lfcat-ref_table = pv_table.
  gs_lfcat-just      = pv_just.

  CASE pv_field.
    WHEN 'NETWR'.
      gs_lfcat-cfieldname = 'WAERS'.
      gs_lfcat-coltext    = '총 주문금액'.
    WHEN 'SONUM'.
      gs_lfcat-hotspot = abap_true.
    WHEN 'WAERS'.
      gs_lfcat-coltext = '통화'.
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
    WHEN 'DCOMP'.
      gs_rfcat-coltext = '배송업체'.
    WHEN 'EMP_NUM'.
      gs_rfcat-coltext = '사원번호'.
  ENDCASE.

  APPEND gs_rfcat TO gt_rfcat.
  CLEAR gs_rfcat.

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
                        grid_title = '판매오더(승인건)'
                        smalltitle =  abap_true ).

  gs_rlayout = VALUE #( zebra = abap_true
                        cwidth_opt = 'A'
                        sel_mode   = 'D'
                        grid_title = '출하문서'
                        smalltitle =  abap_true ).

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

*-- Main container
  CREATE OBJECT go_container
    EXPORTING
      container_name = 'MAIN_CONT'.

*-- Splitter container
  CREATE OBJECT go_split_cont
    EXPORTING
      parent  = go_container
      rows    = 1
      columns = 2.

*-- Assign container
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

*-- ALV
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

  CLEAR gt_order.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_order
    FROM zc302sdt0003
  WHERE sale_org IN gr_sale_org
    AND channel  IN gr_channel
    AND bpcode   IN gr_bpcode
    AND cust_num IN gr_bpcode
    AND status   EQ 'A'       " 판매오더 승인만 조회
    AND sflag    EQ 'N'.      " .  "EQ space

  IF gt_order IS INITIAL.
    MESSAGE s037 DISPLAY LIKE 'E'.
  ENDIF.

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

  REFRESH : gr_sale_org, gr_channel, gr_bpcode.

  IF gv_sale_org IS NOT INITIAL.
    gr_sale_org-sign   = 'I'.
    gr_sale_org-option = 'EQ'.
    gr_sale_org-low    = gv_sale_org.
    APPEND gr_sale_org.
  ENDIF.

  IF gv_channel IS NOT INITIAL.
    gr_channel-sign   = 'I'.
    gr_channel-option = 'EQ'.
    gr_channel-low    = gv_channel.
    APPEND gr_channel.
  ENDIF.

  IF gv_bpcode IS NOT INITIAL.
    gr_bpcode-sign   = 'I'.
    gr_bpcode-option = 'EQ'.
    gr_bpcode-low    = gv_bpcode.
    APPEND gr_bpcode.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM handle_toolbar  USING    po_object TYPE REF TO cl_alv_event_toolbar_set
                              pv_interactive.

*-- Set ALV Toolbar
  PERFORM set_toolbar USING : 'SHIP' icon_transport ' ' ' ' TEXT-i03 po_object.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> ICON_TRANSPORT
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> PO_OBJECT
*&---------------------------------------------------------------------*
FORM set_toolbar  USING   pv_func pv_icon pv_qinfo pv_type pv_text
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
*& Form handle_toolbar_right
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM handle_toolbar_right  USING   po_object TYPE REF TO cl_alv_event_toolbar_set
                                   pv_interactive.

*-- Set ALV Toolbar
  PERFORM set_toolbar USING : 'SAVE' icon_system_save ' ' ' ' TEXT-i04 po_object.

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
    WHEN 'SHIP'.
      PERFORM create_shipment.
    WHEN 'SAVE'.
      PERFORM save_shipment.      " 출하Header 저장
      PERFORM save_shipment_item. " 출하Item 저장
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_shipment
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_shipment.

*-- 운송유형 선택 팝업
  CALL SCREEN 101 STARTING AT 03 05.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_shipment
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_shipment .

  DATA : lt_save   TYPE TABLE OF zc302sdt0005,
         ls_save   TYPE zc302sdt0005,
         lv_tabix  TYPE sy-tabix,
         lv_answer.

  CALL METHOD go_right_grid->check_changed_data.

  MOVE-CORRESPONDING gt_ship  TO lt_save.

  IF lt_save IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 확인 팝업창
  PERFORM confirm_save CHANGING lv_answer.

  IF lv_answer NE '1'.
    MESSAGE w101.
    EXIT.
  ENDIF.

  LOOP AT lt_save INTO ls_save.
*-- TIMESTAMP 정보를 세팅
    lv_tabix = sy-tabix.

    IF ls_save-erdat IS INITIAL.
      ls_save-erdat = sy-datum.
      ls_save-ernam = sy-uname.
      ls_save-erzet = sy-uzeit.
    ELSE.
      ls_save-aedat = sy-datum.
      ls_save-aenam = sy-uname.
      ls_save-aezet = sy-uzeit.
    ENDIF.

    MODIFY lt_save FROM ls_save INDEX lv_tabix
                                TRANSPORTING erdat ernam erzet
                                             aedat aenam aezet.

*-- 저장
    MODIFY zc302sdt0005 FROM TABLE lt_save.

*-- 판매오더h에서 출하 생성 여부 Y로 업데이트
    LOOP AT lt_save INTO ls_save.
      UPDATE zc302sdt0003 SET sflag = 'Y' WHERE sonum = ls_save-sonum.
      DELETE gt_order WHERE sonum = ls_save-sonum.
    ENDLOOP.

*    CALL METHOD : go_left_grid->refresh_table_display.

    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
      MESSAGE s001 WITH TEXT-i01.
    ELSE.
      ROLLBACK WORK.
      MESSAGE s001 WITH TEXT-i02 DISPLAY LIKE 'E'.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_confirm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_confirm.

  DATA : lt_row    TYPE lvc_t_row,
         ls_row    TYPE lvc_s_row,
         lv_answer,
         lv_sonum  TYPE zc302sdt0009-sonum,      " 판매주문번호(조건 사용 시)
         lv_dtype  TYPE zc302sdt0005-dtype,      " 배송유형
         lv_dcomp  TYPE zc302sdt0005-dcomp.      " 배송업체


*-- 확인 팝업창
  PERFORM confirm CHANGING lv_answer.

  IF lv_answer NE '1'.
    MESSAGE w101.
    EXIT.
  ENDIF.

*-- 왼쪽 ALV(판매오더)에서 선택된 행의 Index 가져오기
  CALL METHOD go_left_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_row.

*-- 선택된 행이 있는지 확인
  IF sy-subrc = 0 AND lines( lt_row ) > 0.

    LOOP AT lt_row INTO ls_row.
      CLEAR: gs_order, gs_ship.
      READ TABLE gt_order INTO gs_order INDEX ls_row-index.

      MOVE-CORRESPONDING gs_order TO gs_ship.

      CLEAR : gs_ship-erdat,
              gs_ship-erzet,
              gs_ship-ernam,
              gs_ship-aedat,
              gs_ship-aezet,
              gs_ship-aenam.

*-- 판매주문번호 담기
      lv_sonum = gs_ship-sonum.

*-- 출하번호 채번
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr = '01'
          object      = 'ZNRC30224'
        IMPORTING
          number      = gv_number.

      gs_ship-dlvnum  = 'DN' && gv_number.
      gs_ship-dtype   = gv_dtype.             " 배송유형 업데이트
      gs_ship-dcomp   = gv_dcomp.             " 배송업체 업데이트
      gs_ship-piflag  = 'N'.                  " 피킹여부 초기값 N
      gs_ship-giflag  = 'N'.                  " GI여부 초기값 N
      gs_ship-bflag   = 'N'.                  " 대금청구여부 초기값 N
      gs_ship-emp_num = sy-uname.

      APPEND gs_ship TO gt_ship.

    ENDLOOP.

    CALL METHOD go_right_grid->refresh_table_display.
    CALL METHOD go_left_grid->refresh_table_display.

  ENDIF.

  LEAVE TO SCREEN 0.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_dtype
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_dtype .

  DATA : BEGIN OF ls_dtype,
           dtype  TYPE dd07t-domvalue_l,
           ddtext TYPE dd07t-ddtext,
         END OF ls_dtype,
         lt_dtype LIKE TABLE OF ls_dtype.

*-- Get domain value
  SELECT domvalue_l AS dtype ddtext
    INTO CORRESPONDING FIELDS OF TABLE lt_dtype
    FROM dd07t
   WHERE domname = 'ZC302D_SD_DTYPE'
     AND ddlanguage = sy-langu.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'DTYPE'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GV_DTYPE'
      value_org       = 'S'
    TABLES
      value_tab       = lt_dtype
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.



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
      titlebar              = '출하문서 생성'
      text_question         = '출하문서를 생성하시겠습니까?'
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
*& Form confirm_save
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM confirm_save  CHANGING pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = '저장'
      text_question         = '저장하시겠습니까?'
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
*& Form f4_dcomp
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_dcomp .

  DATA : BEGIN OF ls_dcomp,
           bpcode TYPE zc302mt0001-bpcode,
           cname  TYPE zc302mt0001-cname,
         END OF ls_dcomp,
         lt_dcomp LIKE TABLE OF ls_dcomp.


  SELECT bpcode cname
    INTO CORRESPONDING FIELDS OF TABLE lt_dcomp
    FROM zc302mt0001
   WHERE bpcode LIKE 'SH%'.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'CNAME'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GV_DCOMP'
      value_org       = 'S'
    TABLES
      value_tab       = lt_dcomp
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_hotspot_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&---------------------------------------------------------------------*
FORM handle_hotspot_click  USING  pv_row_id pv_column_id.

*-- 선택한 행의 데이터를 읽어온다.
  CLEAR gs_order.
  READ TABLE gt_order INTO gs_order INDEX pv_row_id.

*-- 선택행에 대한 상세 데이터를 조회한다.
  CLEAR gt_iorder.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_iorder
    FROM zc302sdt0004
   WHERE sonum = gs_order-sonum.

  IF gt_iorder IS INITIAL.
    MESSAGE s037 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  CALL SCREEN 102 STARTING AT 03 05.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_popup
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_popup .

  IF go_pop_cont IS NOT BOUND.

    CLEAR : gt_pfcat, gs_pfcat.
    PERFORM set_pop_field_catalog USING : 'X' 'SONUM' 'ZC302SDT0004' 'C',
                                          ' ' 'POSNR' 'ZC302SDT0004' ' ',
                                          ' ' 'MATNR' 'ZC302SDT0004' 'C',
                                          ' ' 'MENGE' 'ZC302SDT0004' ' ',
                                          ' ' 'MEINS' 'ZC302SDT0004' ' ',
                                          ' ' 'NETWR' 'ZC302SDT0004' ' ',
                                          ' ' 'WAERS' 'ZC302SDT0004' ' '.


    PERFORM set_pop_layout.

    PERFORM create_pop_object.


    gs_variant-report = sy-repid.
    gs_variant-handle = 'ALV3'.

    CALL METHOD go_pop_grid->set_table_for_first_display
      EXPORTING
        is_variant      = gs_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_playout
      CHANGING
        it_outtab       = gt_iorder
        it_fieldcatalog = gt_pfcat.


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
*&---------------------------------------------------------------------*
FORM set_pop_field_catalog  USING pv_key pv_field pv_table pv_just.

  gs_pfcat-key       = pv_key.
  gs_pfcat-fieldname = pv_field.
  gs_pfcat-ref_table = pv_table.
  gs_pfcat-just      = pv_just.

  CASE pv_field.
    WHEN 'MENGE'.
      gs_pfcat-qfieldname = 'MEINS'.
      gs_pfcat-coltext    = '수량'.
    WHEN 'MEINS'.
      gs_pfcat-coltext    = '단위'.
    WHEN 'NETWR'.
      gs_pfcat-cfieldname = 'WAERS'.
      gs_pfcat-coltext    = '주문금액'.
    WHEN 'WAERS'.
      gs_pfcat-coltext    = '통화'.
  ENDCASE.

  APPEND gs_pfcat TO gt_pfcat.
  CLEAR gs_pfcat.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_pop_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_pop_layout .

  gs_playout-zebra = abap_true.
  gs_playout-cwidth_opt = 'A'.
  gs_playout-sel_mode = 'D'.

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

  CREATE OBJECT go_pop_cont
    EXPORTING
      container_name = 'POP_CONT'.

  CREATE OBJECT go_pop_grid
    EXPORTING
      i_parent = go_pop_cont.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_shipment_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_shipment_item .

*-- 저장 시 필요한 변수 선언
  DATA : lt_save   TYPE TABLE OF zc302sdt0006,
         ls_save   TYPE zc302sdt0006,
         lv_tabix  TYPE sy-tabix,
         lv_answer.

*-- GT_SHIP의 판매주문번호 가져오기
  DATA : lv_sonum        TYPE zc302sdt0005-sonum,
         lt_temp         TYPE TABLE OF zc302sdt0006,
         lt_zc302sdt0004 TYPE TABLE OF zc302sdt0004,
         ls_zc302sdt0004 TYPE zc302sdt0004.

*  DATA : lt_ship TYPE TABLE OF zc302sdt0005,
*         ls_ship TYPE zc302sdt0005.
*
*  lt_ship[] = gt_ship[].
*  SORT lt_ship BY sonum.
*  DELETE ADJACENT DUPLICATES FROM lt_ship COMPARING sonum.

*-- 출하Item에 판매오더Item의 데이터 담기
*  IF lt_ship[] IS NOT INITIAL.
*    SELECT *
*      INTO CORRESPONDING FIELDS OF TABLE lt_zc302sdt0004
*      FROM zc302sdt0004
*      FOR ALL ENTRIES IN lt_ship
*     WHERE sonum = lt_ship-sonum.  " 판매주문번호가 같을 때
*  ENDIF.
*  SORT lt_zc302sdt0004 BY sonum.
*-- 조회가능 sonum 정보 Types
  TYPES : BEGIN OF gty_sonum,
            sonum TYPE zc302e_sd_sonum,
          END OF gty_sonum,
          gtt_sonum TYPE TABLE OF gty_sonum WITH EMPTY KEY.

*-- sonum List Internal Table
  DATA : gt_sonum   TYPE gtt_sonum.

  LOOP AT gt_ship INTO gs_ship.
    APPEND gs_ship-sonum TO gt_sonum.
  ENDLOOP.


  SELECT *
    FROM zc302sdt0004 AS a INNER JOIN @gt_sonum AS b
                                ON a~sonum EQ b~sonum
    INTO CORRESPONDING FIELDS OF TABLE @lt_zc302sdt0004.


  LOOP AT gt_ship INTO gs_ship.

    READ TABLE lt_zc302sdt0004 INTO ls_zc302sdt0004 WITH KEY sonum = gs_ship-sonum
                                                     BINARY SEARCH.
    IF sy-subrc EQ 0.
      LOOP AT lt_zc302sdt0004 INTO ls_zc302sdt0004 FROM sy-tabix.
        IF ls_zc302sdt0004-sonum NE gs_ship-sonum.
          EXIT.
        ELSE.
          MOVE-CORRESPONDING ls_zc302sdt0004 TO gs_iship.

          gs_iship-dlvnum = gs_ship-dlvnum.
          gs_iship-scode = 'ST01'.

          CLEAR : gs_iship-erdat,
                  gs_iship-erzet,
                  gs_iship-ernam,
                  gs_iship-aedat,
                  gs_iship-aezet,
                  gs_iship-aenam.


          APPEND gs_iship TO gt_iship.  " 새로 레코드 생성
        ENDIF.
      ENDLOOP.
    ENDIF.




**-- 판매주문번호 가져오기
*    lv_sonum = gs_ship-sonum.
*
**-- 출하Item에 판매오더Item의 데이터 담기
*    SELECT *
*      INTO CORRESPONDING FIELDS OF TABLE lt_temp
*      FROM zc302sdt0004
*     WHERE sonum = lv_sonum.  " 판매주문번호가 같을 때
*
*    APPEND LINES OF lt_temp TO gt_iship.  " 새로 레코드 생성

*-- GT_ISHIP 출하번호(dlvnum) 값 할당
*    LOOP AT gt_iship INTO gs_iship.
*      " dlvnum 필드가 비어있는 경우에만 값 할당
*      IF gs_iship-dlvnum IS INITIAL.
*        gs_iship-dlvnum = gs_ship-dlvnum. " 현재 gs_ship의 dlvnum을 할당
*        gs_iship-scode = 'ST01'.
*        MODIFY gt_iship FROM gs_iship.    " 원래 레코드 업데이트
*      ENDIF.
*    ENDLOOP.

  ENDLOOP.




*  LOOP AT gt_ship INTO gs_ship.
**-- 판매주문번호 가져오기
*    lv_sonum = gs_ship-sonum.
*
**-- 출하Item에 판매오더Item의 데이터 담기
*    SELECT *
*      INTO CORRESPONDING FIELDS OF TABLE lt_temp
*      FROM zc302sdt0004
*     WHERE sonum = lv_sonum.  " 판매주문번호가 같을 때
*
*    APPEND LINES OF lt_temp TO gt_iship.  " 새로 레코드 생성
*
**-- GT_ISHIP 출하번호(dlvnum) 값 할당
*    LOOP AT gt_iship INTO gs_iship.
*      " dlvnum 필드가 비어있는 경우에만 값 할당
*      IF gs_iship-dlvnum IS INITIAL.
*        gs_iship-dlvnum = gs_ship-dlvnum. " 현재 gs_ship의 dlvnum을 할당
*        gs_iship-scode = 'ST01'.
*        MODIFY gt_iship FROM gs_iship.    " 원래 레코드 업데이트
*      ENDIF.
*    ENDLOOP.
*
*  ENDLOOP.


*-- 출하 ITEM 저장
  MOVE-CORRESPONDING gt_iship  TO lt_save.

  IF lt_save IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.


  LOOP AT lt_save INTO ls_save.
*-- TIMESTAMP 정보를 세팅
    lv_tabix = sy-tabix.

    IF ls_save-erdat IS INITIAL.
      ls_save-erdat = sy-datum.
      ls_save-ernam = sy-uname.
      ls_save-erzet = sy-uzeit.
    ELSE.
      ls_save-aedat = sy-datum.
      ls_save-aenam = sy-uname.
      ls_save-aezet = sy-uzeit.
    ENDIF.

    MODIFY lt_save FROM ls_save INDEX lv_tabix
                                TRANSPORTING erdat ernam erzet
                                             aedat aenam aezet.

*-- 저장
    MODIFY zc302sdt0006 FROM TABLE lt_save.

    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
      MESSAGE s001 WITH TEXT-i01.
    ELSE.
      ROLLBACK WORK.
      MESSAGE s001 WITH TEXT-i02 DISPLAY LIKE 'E'.
    ENDIF.

  ENDLOOP.


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
           bpcode TYPE zc302sdt0003-bpcode,
         END OF ls_bpcode,
         lt_bpcode LIKE TABLE OF ls_bpcode.

  SELECT DISTINCT bpcode
    INTO CORRESPONDING FIELDS OF TABLE lt_bpcode
    FROM zc302sdt0003
   WHERE status EQ 'A'
     AND sflag  EQ 'N'
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
*& Form get_channel_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_channel_f4 .

  DATA : BEGIN OF ls_channel,
           channel TYPE zc302sdt0003-channel,
         END OF ls_channel,
         lt_channel LIKE TABLE OF ls_channel.

  SELECT DISTINCT channel
    INTO CORRESPONDING FIELDS OF TABLE lt_channel
    FROM zc302sdt0003
   WHERE status EQ 'A'
     AND sflag EQ 'N'
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
