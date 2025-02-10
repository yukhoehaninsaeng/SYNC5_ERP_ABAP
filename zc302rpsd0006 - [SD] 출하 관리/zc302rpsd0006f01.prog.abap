*&---------------------------------------------------------------------*
*& Include          ZC302RPSD0006F01
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

  DATA : lv_tabix TYPE sy-tabix,
         lt_mdocu TYPE TABLE OF zc302mmt0011,
         ls_mdocu TYPE zc302mmt0011.

**********************************************************************
* 조회 탭 - 출하 Header 데이터 SELECT
**********************************************************************
  CLEAR gt_ship.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_ship
    FROM zc302sdt0005
   WHERE dlvnum   IN so_dlvn
     AND sonum    IN so_sonu
     AND sale_org IN so_sale
*     AND channel  IN so_chan
  ORDER BY dlvnum.

*-- 자재문서 데이터 SELECT
  CLEAR lt_mdocu.
  SELECT mblnr vbeln
    INTO CORRESPONDING FIELDS OF TABLE lt_mdocu
    FROM zc302mmt0011.

*-- GT_SHIP에 자재문서번호 넣기
  LOOP AT gt_ship INTO gs_ship.

    lv_tabix = sy-tabix.

*-- 자재문서T의 출하번호가 같은 것을 READ
    CLEAR ls_mdocu.
    READ TABLE lt_mdocu INTO ls_mdocu WITH KEY vbeln = gs_ship-dlvnum.

*-- 자재문서번호 세팅
    IF sy-subrc EQ 0.
      gs_ship-matdoc = ls_mdocu-mblnr.
    ENDIF.

    MODIFY gt_ship FROM gs_ship INDEX lv_tabix TRANSPORTING matdoc.

  ENDLOOP.

**********************************************************************
* 피킹 탭 - 출하 Header 에서 피킹여부 N인 데이터 SELECT
**********************************************************************
  CLEAR gt_ship2.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_ship2
    FROM zc302sdt0005
   WHERE dlvnum   IN so_dlvn
     AND sonum    IN so_sonu
     AND sale_org IN so_sale
*     AND channel  IN so_chan
     AND piflag   EQ 'N'         " 피킹여부 N만
  ORDER BY dlvnum.


**********************************************************************
* GI 탭 - 출하 Header 에서 피킹여부 Y, 출하여부 N인 데이터 SELECT
**********************************************************************
  CLEAR gt_ship3.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_ship3
    FROM zc302sdt0005
   WHERE dlvnum   IN so_dlvn
     AND sonum    IN so_sonu
     AND sale_org IN so_sale
*     AND channel  IN so_chan
     AND piflag   EQ 'Y'          " 피킹여부 Y만
     AND giflag   EQ 'N'          " 출하여부 N만
  ORDER BY dlvnum.


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
    PERFORM set_field_catalog USING : 'X' 'DLVNUM'    'ZC302SDT0005' 'C',   " 출하번호
                                      'X' 'SONUM'     'ZC302SDT0005' 'C',   " 판매주문번호
                                      ' ' 'SALE_ORG'  'ZC302SDT0005' ' ',   " 영업조직
                                      ' ' 'CHANNEL'   'ZC302SDT0005' ' ',   " 유통채널
                                      ' ' 'BPCODE'    'ZC302SDT0005' ' ',   " BP코드
                                      ' ' 'CUST_NUM'  'ZC302SDT0005' ' ',   " 회원코드
                                      ' ' 'DTYPE'     'ZC302SDT0005' ' ',   " 배송유형
                                      ' ' 'DCOMP'     'ZC302SDT0005' ' ',   " 배송업체
                                      ' ' 'PIFLAG'    'ZC302SDT0005' ' ',   " 피킹여부
                                      ' ' 'GIFLAG'    'ZC302SDT0005' ' ',   " GI여부
                                      ' ' 'EMP_NUM'   'ZC302SDT0005' ' ',   " 사원번호
                                      ' ' 'BFLAG'     'ZC302SDT0005' ' ',   " 대금청구여부
                                      ' ' 'MATDOC'    'ZC302SDT0005' ' '.   " 자재문서번호

    CLEAR : gt_fcat2, gs_fcat2.
    PERFORM set_field_catalog2 USING : 'X' 'DLVNUM'    'ZC302SDT0005' 'C',   " 출하번호
                                       'X' 'SONUM'     'ZC302SDT0005' 'C',   " 판매주문번호
                                       ' ' 'SALE_ORG'  'ZC302SDT0005' ' ',   " 영업조직
                                       ' ' 'CHANNEL'   'ZC302SDT0005' ' ',   " 유통채널
                                       ' ' 'BPCODE'    'ZC302SDT0005' ' ',   " BP코드
                                       ' ' 'CUST_NUM'  'ZC302SDT0005' ' ',   " 회원코드
                                       ' ' 'DTYPE'     'ZC302SDT0005' ' ',   " 배송유형
                                       ' ' 'DCOMP'     'ZC302SDT0005' ' ',   " 배송업체
                                       ' ' 'PIFLAG'    'ZC302SDT0005' ' ',   " 피킹여부
                                       ' ' 'GIFLAG'    'ZC302SDT0005' ' ',   " GI여부
                                       ' ' 'EMP_NUM'   'ZC302SDT0005' ' '.   " 사원번호

    CLEAR : gt_fcat3, gs_fcat3.
    PERFORM set_field_catalog3 USING : 'X' 'DLVNUM'    'ZC302SDT0005' 'C',   " 출하번호
                                       'X' 'SONUM'     'ZC302SDT0005' 'C',   " 판매주문번호
                                       ' ' 'SALE_ORG'  'ZC302SDT0005' ' ',   " 영업조직
                                       ' ' 'CHANNEL'   'ZC302SDT0005' ' ',   " 유통채널
                                       ' ' 'BPCODE'    'ZC302SDT0005' ' ',   " BP코드
                                       ' ' 'CUST_NUM'  'ZC302SDT0005' ' ',   " 회원코드
                                       ' ' 'DTYPE'     'ZC302SDT0005' ' ',   " 배송유형
                                       ' ' 'DCOMP'     'ZC302SDT0005' ' ',   " 배송업체
                                       ' ' 'PIFLAG'    'ZC302SDT0005' ' ',   " 피킹여부
                                       ' ' 'GIFLAG'    'ZC302SDT0005' ' ',   " GI여부
                                       ' ' 'EMP_NUM'   'ZC302SDT0005' ' '.   " 사원번호


    PERFORM set_layout.
    PERFORM create_object.

    SET HANDLER : lcl_event_handler=>toolbar_tab2  FOR go_alv_grid2,
                  lcl_event_handler=>user_command  FOR go_alv_grid2,
                  lcl_event_handler=>toolbar_tab3  FOR go_alv_grid3,
                  lcl_event_handler=>user_command  FOR go_alv_grid3,
                  lcl_event_handler=>top_of_page   FOR go_alv_grid,
                  lcl_event_handler=>hotspot_click FOR go_alv_grid,
                  lcl_event_handler=>hotspot_click2 FOR go_alv_grid3.


    CALL METHOD go_dyndoc_id->initialize_document
      EXPORTING
        background_color = cl_dd_area=>col_textarea.

    CALL METHOD go_alv_grid->list_processing_events
      EXPORTING
        i_event_name = 'TOP_OF_PAGE'
        i_dyndoc_id  = go_dyndoc_id.


    gs_variant-report = sy-repid.
    gs_variant-handle = 'ALV1'.

    CALL METHOD go_alv_grid->set_table_for_first_display
      EXPORTING
        is_variant      = gs_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_layout
      CHANGING
        it_outtab       = gt_ship
        it_fieldcatalog = gt_fcat.

    gs_variant-report = sy-repid.
    gs_variant-handle = 'ALV2'.

    CALL METHOD go_alv_grid2->set_table_for_first_display
      EXPORTING
        is_variant      = gs_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_layout
      CHANGING
        it_outtab       = gt_ship2
        it_fieldcatalog = gt_fcat2.

    gs_variant-report = sy-repid.
    gs_variant-handle = 'ALV3'.

    CALL METHOD go_alv_grid3->set_table_for_first_display
      EXPORTING
        is_variant      = gs_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_layout
      CHANGING
        it_outtab       = gt_ship3
        it_fieldcatalog = gt_fcat3.


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
*&---------------------------------------------------------------------*
FORM set_field_catalog  USING    pv_key pv_field pv_table pv_just.

  gs_fcat-key       = pv_key.
  gs_fcat-fieldname = pv_field.
  gs_fcat-ref_table = pv_table.
  gs_fcat-just      = pv_just.

  CASE pv_field.
    WHEN 'DCOMP'.
      gs_fcat-coltext = '배송업체'.
    WHEN 'MATDOC'.
      gs_fcat-hotspot = abap_true.
    WHEN 'EMP_NUM'.
      gs_fcat-coltext = '사원번호'.
  ENDCASE.

  APPEND gs_fcat TO gt_fcat.
  CLEAR gs_fcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_field_catalog2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_field_catalog2  USING    pv_key pv_field pv_table pv_just.

  gs_fcat2-key       = pv_key.
  gs_fcat2-fieldname = pv_field.
  gs_fcat2-ref_table = pv_table.
  gs_fcat2-just      = pv_just.

  CASE pv_field.
    WHEN 'DCOMP'.
      gs_fcat2-coltext = '배송업체'.
    WHEN 'MATDOC'.
      gs_fcat2-hotspot = abap_true.
    WHEN 'EMP_NUM'.
      gs_fcat2-coltext = '사원번호'.
  ENDCASE.

  APPEND gs_fcat2 TO gt_fcat2.
  CLEAR gs_fcat2.

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

  gs_layout = VALUE #( zebra = abap_true
                       cwidth_opt = 'A'
                       sel_mode   = 'D').

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

  CREATE OBJECT go_top_container
    EXPORTING
      repid     = sy-cprog
      dynnr     = sy-dynnr
      side      = go_top_container->dock_at_top
      extension = 60. " Top of page 높이

  CREATE OBJECT go_container
    EXPORTING
      container_name = 'MAIN_CONT'.

  CREATE OBJECT go_alv_grid
    EXPORTING
      i_parent = go_container.

  CREATE OBJECT go_container2
    EXPORTING
      container_name = 'MAIN_CONT2'.

  CREATE OBJECT go_alv_grid2
    EXPORTING
      i_parent = go_container2.

  CREATE OBJECT go_container3
    EXPORTING
      container_name = 'MAIN_CONT3'.

  CREATE OBJECT go_alv_grid3
    EXPORTING
      i_parent = go_container3.

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
FORM handle_toolbar_tab2  USING    po_object TYPE REF TO cl_alv_event_toolbar_set
                              pv_interactive.

  PERFORM set_toolbar USING : 'PICK' icon_compare ' ' ' ' TEXT-i02 po_object.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
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
FORM handle_user_command  USING    pv_ucomm.

  CASE pv_ucomm.
    WHEN 'PICK'.                       " 피킹 버튼
      PERFORM process_picking.
    WHEN 'SHIP'.
      PERFORM process_ship.            " GI 버튼
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_picking
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_picking .

  DATA : lt_row TYPE lvc_t_row,
         ls_row TYPE lvc_s_row.

  DATA : lv_dlvnum TYPE zc302sdt0006-dlvnum.

  DATA : lv_tabix TYPE sy-tabix,
         ls_style TYPE lvc_s_styl.

*-- 피킹탭에서 선택된 행의 INDEX 가져오기
  CALL METHOD go_alv_grid2->get_selected_rows
    IMPORTING
      et_index_rows = lt_row.

*-- 선택된 행이 있는지 확인
  IF sy-subrc = 0 AND lines( lt_row ) = 1.

    LOOP AT lt_row INTO ls_row.

*-- 선택한 행의 데이터 읽어오기
      CLEAR : gs_ship2.
      READ TABLE gt_ship2 INTO gs_ship2 INDEX ls_row-index.

*-- 선택한 행의 출하번호를 lv_dlvnum에 담기(조건 시 사용)
      IF sy-subrc EQ 0.
        lv_dlvnum = gs_ship2-dlvnum.
      ENDIF.

    ENDLOOP.
  ELSE.
    " 1개의 행만 선택해주세요.
    MESSAGE s001 WITH TEXT-i04 DISPLAY LIKE 'E'.
    DATA(lv_err) = abap_true.
  ENDIF.

  CHECK lv_err IS INITIAL.

*-- 출하 Item 데이터 SELECT
  CLEAR gt_iship.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_iship
    FROM zc302sdt0006
   WHERE dlvnum = lv_dlvnum.  " 선택한 행의 출하번호와 같은

  IF gt_iship IS INITIAL.
    " 출하 아이템이 존재하지 않습니다.
    MESSAGE s001 WITH TEXT-e06 DISPLAY LIKE 'E'.
    CLEAR lv_err.
    lv_err = abap_true.
  ENDIF.

  CHECK lv_err IS INITIAL.

*-- GT_ISHIP의 MENGE_P(피킹수량) 편집모드 설정
  CLEAR gs_iship.
  LOOP AT gt_iship INTO gs_iship.

    lv_tabix = sy-tabix.

*-- Exit mode
    CLEAR : ls_style, gs_iship-celltab.
    ls_style-fieldname = 'MENGE_P'.
    ls_style-style = cl_gui_alv_grid=>mc_style_enabled.
    INSERT ls_style INTO TABLE gs_iship-celltab.

*-- Other field is display mode
    CLEAR : ls_style.
    ls_style-style = cl_gui_alv_grid=>mc_style_disabled.
    INSERT ls_style INTO TABLE gs_iship-celltab.

    MODIFY gt_iship FROM gs_iship INDEX lv_tabix TRANSPORTING celltab.

  ENDLOOP.

*-- 출하 ITEM ALV 띄우기 - CALL POPUP SCREEN
  CALL SCREEN 101 STARTING AT 03 05.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_toolbar_tab3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM handle_toolbar_tab3  USING   po_object TYPE REF TO cl_alv_event_toolbar_set
                                  pv_interactive.

  PERFORM set_toolbar USING : 'SHIP' icon_transport ' ' ' ' TEXT-i03 po_object.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_ship
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_ship .

  DATA : lt_row    TYPE lvc_t_row,
         ls_row    TYPE lvc_s_row,
         lv_answer.


**********************************************************************
* 필요한 데이터 SELECT
**********************************************************************
*-- 재고관리H 데이터 SELECT
  SELECT matnr scode h_rtptqua h_resmat
    INTO CORRESPONDING FIELDS OF TABLE gt_stock
    FROM zc302mmt0013
   WHERE scode = 'ST05'.

*-- 재고관리I 데이터 SELECT
  SELECT matnr scode bdatu i_rtptqua i_resmat
    INTO CORRESPONDING FIELDS OF TABLE gt_istock
    FROM zc302mmt0002
   WHERE scode = 'ST05'
     AND i_rtptqua <> 0.   " 재고가 0이 아닌 경우

  " 자재별 생산일 기준으로 오름차순 정렬
  SORT gt_istock BY matnr bdatu ASCENDING.

*-- 판매오더I 데이터 SELECT
  SELECT a~sonum a~matnr a~menge a~meins a~netwr a~waers c~maktx b~bpcode b~cust_num
    INTO CORRESPONDING FIELDS OF TABLE gt_iorder
    FROM zc302sdt0004 AS a INNER JOIN zc302sdt0003 AS b
                                   ON a~sonum = b~sonum
                      LEFT OUTER JOIN zc302mt0007 AS c
                                   ON a~matnr = c~matnr.

**-- 확인 팝업창
*  PERFORM confirm_gi CHANGING lv_answer.
*
**-- 받아온 lv_ansewer이 1(yes)가 아닐 때
*  IF lv_answer NE '1'.
*    MESSAGE s101 DISPLAY LIKE 'E'.
*  ENDIF.
*
*  CHECK lv_answer EQ '1'.

*-- GI탭에서 선택한 행 받아오기
  CALL METHOD go_alv_grid3->get_selected_rows
    IMPORTING
      et_index_rows = lt_row.

**********************************************************************
* 선택된 행에 대한 로직 구현
**********************************************************************
*-- 선택된 행이 있는지 확인
  CLEAR: gt_mdocu, gt_imdocu.

  IF sy-subrc = 0 AND lines( lt_row ) = 1.

    LOOP AT lt_row INTO ls_row.

*--  출하탭에서 선택한 행에 대한 데이터 읽어오기
      CLEAR gs_ship3.
      READ TABLE gt_ship3 INTO gs_ship3 INDEX ls_row-index.


      LOOP AT gt_iorder INTO gs_iorder WHERE sonum = gs_ship3-sonum.

*-- 재고관리에서 자재코드가 같은 경우
        LOOP AT gt_stock INTO gs_stock WHERE matnr = gs_iorder-matnr.
*-- 재고가 부족하면 후속 로직을 중단하고 에러 메시지 출력
          IF gs_stock-h_rtptqua < gs_iorder-menge.
            " 재고가 부족합니다. 재고 현황을 확인하세요.
            MESSAGE s001 WITH TEXT-e04 DISPLAY LIKE 'E'.
            RETURN.
          ENDIF.
        ENDLOOP.

      ENDLOOP.


*-- MM 자재문서 생성
      PERFORM create_mdocu_header.     " 자재문서 Header ITAB 구성
      PERFORM create_mdocu_item.       " 자재문서 Item ITAB 구성

*-- 출하H ITAB 업데이트
      IF sy-subrc EQ 0.
        gs_ship3-giflag = 'Y'.              " 출하여부 Y
        gs_ship3-matdoc = gs_mdocu-mblnr.   " 생성된 자재문서번호 표시
        gs_ship3-aedat  = sy-datum.
        gs_ship3-aenam  = sy-uname.
        gs_ship3-aezet  = sy-uzeit.
        MODIFY gt_ship3 FROM gs_ship3 INDEX ls_row-index TRANSPORTING giflag matdoc aedat aenam aezet.
      ENDIF.

*-- MM 재고관리 현재수량, 예약재고 업데이트(감소)
      PERFORM update_amount.                           " 재고관리 Header
      PERFORM update_amount_item.                      " 재고관리 Item

    ENDLOOP.

  ELSE.
    " 1개의 행만 선택해주세요.
    MESSAGE s001 WITH TEXT-i04 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 확인 팝업창
  PERFORM confirm_gi CHANGING lv_answer.

*-- 받아온 lv_ansewer이 1(yes)가 아닐 때
  IF lv_answer NE '1'.
    MESSAGE s101 DISPLAY LIKE 'E'.
  ENDIF.

  CHECK lv_answer EQ '1'.

**********************************************************************
* 출하H DB 출하여부 Y로 업데이트
**********************************************************************
  UPDATE zc302sdt0005 FROM TABLE gt_ship3.

**********************************************************************
* 자재문서DB(H,I) 생성
**********************************************************************
  INSERT zc302mmt0011 FROM TABLE gt_mdocu.
  INSERT zc302mmt0012 FROM TABLE gt_imdocu.


**********************************************************************
* COMMIT 처리
**********************************************************************
  IF sy-subrc EQ 0.
    MESSAGE s001 WITH TEXT-i07.
    COMMIT WORK AND WAIT.
*-- GI탭에서 출하된 건은 사라짐
    DELETE gt_ship3 WHERE giflag = 'Y'.
    CALL METHOD : go_alv_grid3->refresh_table_display.
    PERFORM update_display_tab.  " 변경된 데이터를 조회 탭에 반영(자재문서번호, GI여부)
  ELSE.
    " 출하에 실패하였습니다.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
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
*--
  so_dlvn = VALUE #( so_dlvn[ 1 ] OPTIONAL ).
  CLEAR : lv_temp.
  IF so_dlvn-low IS NOT INITIAL.
    lv_temp = so_dlvn-low.
    IF so_dlvn-high IS NOT INITIAL.
      CONCATENATE lv_temp ' ~ ' so_dlvn-high INTO lv_temp.
    ENDIF.
  ELSE.
    lv_temp = '전체'.
  ENDIF.
  PERFORM add_row USING lr_dd_table col_field col_value '출하번호' lv_temp.

  so_sonu = VALUE #( so_sonu[ 1 ] OPTIONAL ).
  CLEAR : lv_temp.
  IF so_sonu-low IS NOT INITIAL.
    lv_temp = so_sonu-low.
    IF so_sonu-high IS NOT INITIAL.
      CONCATENATE lv_temp ' ~ ' so_sonu-high INTO lv_temp.
    ENDIF.
  ELSE.
    lv_temp = '전체'.
  ENDIF.
  PERFORM add_row USING lr_dd_table col_field col_value '판매주문번호' lv_temp.

  so_sale = VALUE #( so_sale[ 1 ] OPTIONAL ).
  CLEAR : lv_temp.
  IF so_sale-low IS NOT INITIAL.
    lv_temp = so_sale-low.
    IF so_sale-high IS NOT INITIAL.
      CONCATENATE lv_temp ' ~ ' so_sale-high INTO lv_temp.
    ENDIF.
  ELSE.
    lv_temp = '전체'.
  ENDIF.
  PERFORM add_row USING lr_dd_table col_field col_value '영업조직' lv_temp.

*  so_chan = VALUE #( so_chan[ 1 ] OPTIONAL ).
*  CLEAR : lv_temp.
*  IF so_chan-low IS NOT INITIAL.
*    lv_temp = so_chan-low.
*    IF so_chan-high IS NOT INITIAL.
*      CONCATENATE lv_temp ' ~ ' so_chan-high INTO lv_temp.
*    ENDIF.
*  ELSE.
*    lv_temp = '전체'.
*  ENDIF.
*  PERFORM add_row USING lr_dd_table col_field col_value '유통채널' lv_temp.

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
    PERFORM set_pop_field_catalog USING : 'X' 'DLVNUM'  'ZC302SDT0006' 'C',
                                          'X' 'POSNR'   'ZC302SDT0006' ' ',
                                          ' ' 'MATNR'   'ZC302SDT0006' ' ',
                                          ' ' 'SCODE'   'ZC302SDT0006' ' ',
                                          ' ' 'MENGE'   'ZC302SDT0006' ' ',
                                          ' ' 'MENGE_P' 'ZC302SDT0006' ' ',
                                          ' ' 'MEINS'   'ZC302SDT0006' ' '.

    PERFORM set_pop_layout.
    PERFORM create_pop_object.
    PERFORM exclude_button TABLES gt_ui_functions.

    CALL METHOD go_pop_grid->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        i_save               = 'A'
        i_default            = 'X'
        is_layout            = gs_playout
        it_toolbar_excluding = gt_ui_functions
      CHANGING
        it_outtab            = gt_iship
        it_fieldcatalog      = gt_pfcat.

    PERFORM register_event.
  ELSE.
    CALL METHOD go_pop_grid->refresh_table_display.
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
    WHEN 'MENGE_P'.
      gs_pfcat-qfieldname = 'MEINS'.
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

  gs_playout = VALUE #( zebra = abap_true
                        cwidth_opt = 'A'
                        sel_mode   = 'D'
                        stylefname = 'CELLTAB').


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
*& Form register_event
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM register_event .

  CALL METHOD go_pop_grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_button
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_UI_FUNCTIONS
*&---------------------------------------------------------------------*
FORM exclude_button  TABLES   pt_ui_functions TYPE ui_functions.

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
*& Form save_shipment_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_shipment_item .

  DATA : lt_save   TYPE TABLE OF zc302sdt0006,
         ls_save   TYPE zc302sdt0006,
         lv_tabix  TYPE sy-tabix,
         lv_answer.

  DATA : lv_valid  TYPE abap_bool.

*-- ALV의 변경사항(추가,삭제,수정 등)을 ITAB에 반영한다.
  CALL METHOD go_pop_grid->check_changed_data.

  LOOP AT gt_iship INTO gs_iship.
    " 피킹수량 <> 재고수량인 경우 로직 종료
    IF gs_iship-menge_p NE gs_iship-menge.
      " 피킹수량이 재고수량과 일치하지 않습니다.
      MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
      lv_valid = abap_true.
      " 피킹수량 = 재고수량인 경우 출하H 피킹여부 Y로 업데이트
    ELSE.
      CLEAR gs_ship2.
      READ TABLE gt_ship2 INTO gs_ship2 WITH KEY dlvnum = gs_iship-dlvnum.

      IF sy-subrc EQ 0.
        gs_ship2-piflag = 'Y'.
        gs_ship2-aedat = sy-datum.
        gs_ship2-aenam = sy-uname.
        gs_ship2-aezet = sy-uzeit.
      ENDIF.

      MODIFY gt_ship2 FROM gs_ship2 INDEX sy-tabix TRANSPORTING piflag aedat aenam aezet.

    ENDIF.
  ENDLOOP.

  CHECK lv_valid IS INITIAL.


**********************************************************************
* LT_SAVE(출하I 저장 ITAB) 구성
**********************************************************************
*-- 저장ITAB에 MOVE
  MOVE-CORRESPONDING gt_iship TO lt_save.

*-- 저장ITAB이 비었다면 로직 종류
  IF lt_save IS INITIAL.
    " 저장할 데이터가 없습니다.
    MESSAGE s001 WITH TEXT-e07 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 저장 확인 팝업창
  PERFORM confirm CHANGING lv_answer.

*-- 받아온 lv_ansewer이 1(yes)가 아닐 때
  IF lv_answer NE '1'.
    MESSAGE s101 DISPLAY LIKE 'E'.
  ENDIF.

  CHECK lv_answer EQ '1'.

*-- TIMESTAMP 정보를 세팅
  LOOP AT lt_save INTO ls_save.

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

  ENDLOOP.

**********************************************************************
* 출하I DB 업데이트(피킹수량 반영)
**********************************************************************
  MODIFY zc302sdt0006 FROM TABLE lt_save.

**********************************************************************
* 출하H DB 피킹여부 Y로 업데이트
**********************************************************************
  MODIFY zc302sdt0005 FROM TABLE gt_ship2.

*-- COMMIT 처리
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
    " 피킹이 완료되었습니다.
    MESSAGE s001 WITH TEXT-i05.
    DELETE gt_ship2 WHERE piflag = 'Y'.   " 피킹된 건은 피킹탭에서 삭제
    CALL METHOD go_alv_grid2->refresh_table_display.
    PERFORM update_gi_tab.     " 피킹된 건에 대해 GI탭과 조회탭 ALV 새로고침
  ELSE.
    ROLLBACK WORK.
    " 피킹에 실패하였습니다.
    MESSAGE s001 WITH TEXT-i06 DISPLAY LIKE 'E'.
  ENDIF.

  LEAVE TO SCREEN 0.

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
      titlebar              = '피킹수량 업데이트'
      text_question         = '피킹수량을 반영하시겠습니까?'
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
*& Form confirm_gi
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM confirm_gi  CHANGING pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'GI'
      text_question         = '출하를 진행하시겠습니까?'
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
*& Form create_mdocu_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_MDOCU
*&---------------------------------------------------------------------*
FORM create_mdocu_header.

  DATA : lv_number(8) TYPE n.

*-- 자재문서번호 채번
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZC321MMMD'
    IMPORTING
      number      = lv_number.

  CLEAR gs_mdocu.
  gs_mdocu-mblnr = 'MD' && lv_number.  " 자재문서번호
  gs_mdocu-mjahr = sy-datum.           " 자재문서연도
  gs_mdocu-vbeln = gs_ship3-dlvnum.    " 출하번호
  gs_mdocu-movetype = 'C'.             " 자재이동유형(출하)

  IF gs_mdocu-erdat IS INITIAL.
    gs_mdocu-erdat = sy-datum.
    gs_mdocu-ernam = sy-uname.
    gs_mdocu-erzet = sy-uzeit.
  ELSE.
    gs_mdocu-aedat = sy-datum.
    gs_mdocu-aenam = sy-uname.
    gs_mdocu-aezet = sy-uzeit.
  ENDIF.

  APPEND gs_mdocu TO gt_mdocu.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_mdocu_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_IMDOCU
*&---------------------------------------------------------------------*
FORM create_mdocu_item.

  CLEAR gs_iorder.
  SORT gt_iorder BY sonum matnr.

  LOOP AT gt_iorder INTO gs_iorder WHERE sonum = gs_ship3-sonum.

    gs_imdocu-mblnr    = gs_mdocu-mblnr.
    gs_imdocu-mjahr    = gs_mdocu-mjahr.
    gs_imdocu-matnr    = gs_iorder-matnr.
    gs_imdocu-scode    = 'ST05'.
    gs_imdocu-movetype = gs_mdocu-movetype.
    gs_imdocu-budat    = sy-datum.
    gs_imdocu-menge    = gs_iorder-menge.
    gs_imdocu-meins    = gs_iorder-meins.
    gs_imdocu-waers    = gs_iorder-waers.
    gs_imdocu-netwr    = gs_iorder-netwr.
    gs_imdocu-maktx    = gs_iorder-maktx.

*-- B2C일때는 cust_num, B2B일때는 bpcode
    IF gs_iorder-cust_num IS NOT INITIAL.
      gs_imdocu-bpcode   = gs_iorder-cust_num.
    ELSE.
      gs_imdocu-bpcode   = gs_iorder-bpcode.
    ENDIF.

    gs_imdocu-erdat = sy-datum.
    gs_imdocu-ernam = sy-uname.
    gs_imdocu-erzet = sy-uzeit.

    APPEND gs_imdocu TO gt_imdocu.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_amount
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_STOCK
*&---------------------------------------------------------------------*
FORM update_amount.

*-- 판매오더 Item 에서 주문수량 가져오기
  LOOP AT gt_iorder INTO gs_iorder WHERE sonum = gs_ship3-sonum.

*-- 재고관리에서 자재코드가 같은 경우
    LOOP AT gt_stock INTO gs_stock WHERE matnr = gs_iorder-matnr.

      gs_stock-h_rtptqua = gs_stock-h_rtptqua - gs_iorder-menge.
      gs_stock-h_resmat  = gs_stock-h_resmat - gs_iorder-menge.
      gs_stock-aedat     = sy-datum.
      gs_stock-aenam     = sy-uname.
      gs_stock-aezet     = sy-uzeit.

      MODIFY gt_stock FROM gs_stock INDEX sy-tabix TRANSPORTING h_rtptqua h_resmat aedat aenam aezet.

    ENDLOOP.

  ENDLOOP.

  LOOP AT gt_stock INTO gs_stock.
    UPDATE zc302mmt0013
      SET h_rtptqua = @gs_stock-h_rtptqua,
           h_resmat = @gs_stock-h_resmat,
              aedat = @gs_stock-aedat,
              aenam = @gs_stock-aenam,
              aezet = @gs_stock-aezet
     WHERE matnr = @gs_stock-matnr
       AND scode = 'ST05'.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_amount_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_amount_item .


  DATA: lv_iorder_menge TYPE zc302mmt0002-i_resmat,       " 변동되는 주문수량
        lt_istock_upt   TYPE TABLE OF zc302mmt0002.       " 재고관리I


*-- 재고 감소 로직
  LOOP AT gt_iorder INTO gs_iorder WHERE sonum = gs_ship3-sonum.

    lv_iorder_menge = gs_iorder-menge.

    LOOP AT gt_istock INTO gs_istock WHERE matnr = gs_iorder-matnr.

      " 현재재고 및 예약재고 업데이트 로직
      IF gs_istock-i_resmat >= lv_iorder_menge.                          " 예약재고 >= 주문수량
        gs_istock-i_resmat = gs_istock-i_resmat - lv_iorder_menge.       " 예약재고 업데이트
        gs_istock-i_rtptqua = gs_istock-i_rtptqua - lv_iorder_menge.     " 현재재고 업데이트
        lv_iorder_menge = 0.                                             " 주문수량을 0으로 설정

        " 변경된 i_resmat 및 i_rtptqua만 lt_istock_upt에 저장
        APPEND gs_istock TO lt_istock_upt.
        EXIT.                                                            " 예약 재고가 충분하므로 루프 종료
      ELSE.                                                              " 예약재고 < 주문수량
        gs_istock-i_rtptqua = gs_istock-i_rtptqua - gs_istock-i_resmat.  " 현재재고 업데이트
        lv_iorder_menge = lv_iorder_menge - gs_istock-i_resmat.          " 주문수량에서 소진된 예약재고 차감
        gs_istock-i_resmat = 0.                                          " 예약재고는 모두 소진

        " 변경된 i_resmat 및 i_rtptqua만 lt_istock_upt에 저장
        APPEND gs_istock TO lt_istock_upt.
      ENDIF.

      " 주문 수량이 다 소진된 경우
      IF lv_iorder_menge <= 0.
        EXIT.
      ENDIF.

    ENDLOOP.

    " 남은 주문 수량이 있을 경우 처리
    IF lv_iorder_menge > 0.
      MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
    ENDIF.

  ENDLOOP.

  LOOP AT lt_istock_upt INTO gs_istock.

    UPDATE zc302mmt0002 SET  i_resmat = @gs_istock-i_resmat,
                            i_rtptqua = @gs_istock-i_rtptqua,
                                aedat = @sy-datum,
                                aenam = @sy-uname,
                                aezet = @sy-uzeit
    WHERE matnr = @gs_istock-matnr
      AND scode = 'ST05'
      AND bdatu = @gs_istock-bdatu.  " 생성일 기준 추가

    IF sy-subrc NE 0.
      " 자재문서가 없습니다.
      MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
    ENDIF.

  ENDLOOP.

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

*-- 엽업조직 '0001'로 초기값 설정
  CLEAR so_sale.
  so_sale-sign = 'I'.
  so_sale-option = 'EQ'.
  so_sale-low = '0001'.

  APPEND so_sale.

*-- 출하번호 Search Help
  CLEAR gt_dlvnum.
  SELECT dlvnum
    INTO CORRESPONDING FIELDS OF TABLE gt_dlvnum
    FROM zc302sdt0005.

**-- 판매주문번호 Search Help
*  CLEAR gt_sonum.
*  SELECT sonum
*    INTO CORRESPONDING FIELDS OF TABLE gt_sonum
*    FROM zc302sdt0005.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form screen_output
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM screen_output .

*-- 출력속성 : 엽업조직은 입력창 막기
  LOOP AT SCREEN.

    CASE screen-group1.
      WHEN 'SAL'.
        screen-input = 0.
    ENDCASE.

    MODIFY SCREEN.

  ENDLOOP.

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

*-- 선택한 행의 데이터 읽기
  CLEAR gs_ship.
  READ TABLE gt_ship INTO gs_ship INDEX pv_row_id.

*-- 자재문서가 없을 시 EXIT
  IF gs_ship-matdoc IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 선택행에 대한 상세 데이터 조회
  CLEAR gt_mdocu_pop.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_mdocu_pop
    FROM zc302mmt0012
   WHERE mblnr = gs_ship-matdoc.

*-- CALL POPUP SCREEN
  CALL SCREEN 102 STARTING AT 03 05.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_popup2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_popup2 .

  IF go_pop_cont2 IS NOT BOUND.

    CLEAR : gt_pfcat2, gs_pfcat2.
    PERFORM set_pop2_field_catalog USING : 'X' 'MBLNR'    'ZC302MMT0012' 'C',
                                           'X' 'MJAHR'    'ZC302MMT0012' 'C',
                                           'X' 'MATNR'    'ZC302MMT0012' ' ',
                                           ' ' 'MAKTX'    'ZC302MMT0012' ' ',
                                           ' ' 'SCODE'    'ZC302MMT0012' ' ',
                                           ' ' 'MOVETYPE' 'ZC302MMT0012' ' ',
                                           ' ' 'BUDAT'    'ZC302MMT0012' ' ',
                                           ' ' 'MENGE'    'ZC302MMT0012' ' ',
                                           ' ' 'MEINS'    'ZC302MMT0012' ' ',
                                           ' ' 'NETWR'    'ZC302MMT0012' ' ',
                                           ' ' 'WAERS'    'ZC302MMT0012' ' '.

    PERFORM set_pop2_layout.

    PERFORM create_pop2_object.

    CALL METHOD go_pop_grid2->set_table_for_first_display
      EXPORTING
        is_variant      = gs_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_playout2
      CHANGING
        it_outtab       = gt_mdocu_pop
        it_fieldcatalog = gt_pfcat2.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_pop3_field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_pop2_field_catalog  USING pv_key pv_field pv_table pv_just.

  gs_pfcat2-key = pv_key.
  gs_pfcat2-fieldname = pv_field.
  gs_pfcat2-ref_table = pv_table.
  gs_pfcat2-just = pv_just.

  CASE pv_field.
    WHEN 'BUDAT'.
      gs_pfcat2-coltext = '출하날짜'.
    WHEN 'MENGE'.
      gs_pfcat2-coltext = '주문수량'.
      gs_pfcat2-qfieldname = 'MEINS'.
    WHEN 'MEINS'.
      gs_pfcat2-coltext = '단위'.
    WHEN 'WAERS'.
      gs_pfcat2-coltext = '통화'.
    WHEN 'NETWR'.
      gs_pfcat2-coltext = '주문금액'.
      gs_pfcat2-cfieldname = 'WAERS'.
  ENDCASE.

  APPEND gs_pfcat2 TO gt_pfcat2.
  CLEAR gs_pfcat2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_pop2_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_pop2_layout .

  gs_playout2-zebra = abap_true.
  gs_playout2-cwidth_opt = 'A'.
  gs_playout2-sel_mode = 'D'.
  gs_playout2-no_toolbar = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_pop2_object
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_pop2_object .

  CREATE OBJECT go_pop_cont2
    EXPORTING
      container_name = 'POP_CONT2'.


  CREATE OBJECT go_pop_grid2
    EXPORTING
      i_parent = go_pop_cont2.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_gi_tab
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_gi_tab .
**********************************************************************
*-- GI탭 ALV 새로고침
**********************************************************************
*-- GI탭에 피킹된 건에 대해 ALV 갱신
  CLEAR gt_ship3.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_ship3
    FROM zc302sdt0005
   WHERE dlvnum   IN so_dlvn
      AND sonum    IN so_dlvn
      AND sale_org IN so_sale
*      AND channel  IN so_chan
      AND piflag   = 'Y'  " 피킹여부 Y만
      AND giflag   = 'N'. " 출하여부 N만


  " GI탭 ALV 갱신
  CALL METHOD go_alv_grid3->refresh_table_display.

**********************************************************************
*-- 조회탭 ALV 새로고침
**********************************************************************
*-- 조회탭의 피킹여부 Y로 업데이트
  CLEAR gs_ship.
  LOOP AT gt_ship INTO gs_ship.

    gs_ship-piflag = 'Y'.
    MODIFY gt_ship FROM gs_ship.

  ENDLOOP.

  CLEAR gt_ship.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_ship
    FROM zc302sdt0005
   WHERE dlvnum   IN so_dlvn
      AND sonum    IN so_dlvn
      AND sale_org IN so_sale.
*      AND channel  IN so_chan.

  " 조회탭 ALV 갱신
  CALL METHOD go_alv_grid->refresh_table_display.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_field_catalog3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_field_catalog3  USING  pv_key pv_field pv_table pv_just.

  gs_fcat3-key       = pv_key.
  gs_fcat3-fieldname = pv_field.
  gs_fcat3-ref_table = pv_table.
  gs_fcat3-just      = pv_just.

  CASE pv_field.
    WHEN 'DCOMP'.
      gs_fcat3-coltext = '배송업체'.
    WHEN 'MATDOC'.
      gs_fcat3-hotspot = abap_true.
    WHEN 'EMP_NUM'.
      gs_fcat3-coltext = '사원번호'.
    WHEN 'SONUM'.
      gs_fcat3-hotspot = abap_true.
  ENDCASE.

  APPEND gs_fcat3 TO gt_fcat3.
  CLEAR gs_fcat3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_display_tab
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_display_tab .

*-- 조회탭의 GI여부 Y로 업데이트
  CLEAR gs_ship.
  LOOP AT gt_ship INTO gs_ship.

    gs_ship-giflag = 'Y'.
    MODIFY gt_ship FROM gs_ship.

  ENDLOOP.

  CLEAR gt_ship.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_ship
    FROM zc302sdt0005
   WHERE dlvnum   IN so_dlvn
      AND sonum    IN so_dlvn
      AND sale_org IN so_sale.
*      AND channel  IN so_chan.

  " 조회탭 ALV 갱신
  CALL METHOD go_alv_grid->refresh_table_display.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_dlvnum
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_dlvnum .

  DATA : lt_return LIKE TABLE OF ddshretval WITH HEADER LINE.

  REFRESH : lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'DLVNUM'     " Input에 넣어줄 필드
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'SO_DLVN-LOW'       " Selection Screen Element
      window_title    = '출하번호'    " Description
      value_org       = 'S'
    TABLES
      value_tab       = gt_dlvnum    " F4에 뿌려줄 데이터(INITIALIZATION에서 select함)
      return_tab      = lt_return    " F4에서 선택된 값에 대한 정보
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

*-- 출하번호와 매칭되는 판매주문번호만 SELECT
  READ TABLE lt_return INDEX 1.

  SELECT *
    FROM zc302sdt0005
    INTO CORRESPONDING FIELDS OF TABLE gt_sonum
   WHERE dlvnum = lt_return-fieldval.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_sonum
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_sonum .

  DATA : lt_return LIKE TABLE OF ddshretval WITH HEADER LINE.

  REFRESH : lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'SONUM'     " Input에 넣어줄 필드
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'SO_SONUM-LOW'    " Selection Screen Element
      window_title    = '판매주문번호'    " Description
      value_org       = 'S'
    TABLES
      value_tab       = gt_sonum     " F4에 뿌려줄 데이터(INITIALIZATION에서 select함)
      return_tab      = lt_return    " F4에서 선택된 값에 대한 정보
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF lt_return IS INITIAL.
    MESSAGE s001 WITH TEXT-e08 DISPLAY LIKE 'E'.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_hotspot_click2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&---------------------------------------------------------------------*
FORM handle_hotspot_click2  USING  pv_row_id pv_column_id.


*-- 선택한 행의 데이터 읽기
  CLEAR gs_ship3.
  READ TABLE gt_ship3 INTO gs_ship3 INDEX pv_row_id.

*-- 선택행에 대한 상세 데이터 조회
  CLEAR gt_iorder_pop.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_iorder_pop
    FROM zc302sdt0004
   WHERE sonum = gs_ship3-sonum.

*-- CALL POPUP SCREEN
  CALL SCREEN 103 STARTING AT 03 05.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_popup3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_popup3 .

  IF go_pop_cont3 IS NOT BOUND.

    CLEAR : gt_pfcat3, gs_pfcat3.
    PERFORM set_pop3_field_catalog USING : 'X' 'SONUM'    'ZC302SDT0004' 'C',
                                           'X' 'POSNR'    'ZC302SDT0004' 'C',
                                           ' ' 'MATNR'    'ZC302SDT0004' 'C',
                                           ' ' 'MENGE'    'ZC302SDT0004' ' ',
                                           ' ' 'MEINS'    'ZC302SDT0004' ' ',
                                           ' ' 'NETWR'    'ZC302SDT0004' ' ',
                                           ' ' 'WAERS'    'ZC302SDT0004' ' '.

    PERFORM set_pop3_layout.

    PERFORM create_pop3_object.

    CALL METHOD go_pop_grid3->set_table_for_first_display
      EXPORTING
        is_variant      = gs_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_playout3
      CHANGING
        it_outtab       = gt_iorder_pop
        it_fieldcatalog = gt_pfcat3.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_pop3_field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_pop3_field_catalog  USING pv_key pv_field pv_table pv_just.

  gs_pfcat3-key = pv_key.
  gs_pfcat3-fieldname = pv_field.
  gs_pfcat3-ref_table = pv_table.
  gs_pfcat3-just = pv_just.

  CASE pv_field.
    WHEN 'MENGE'.
      gs_pfcat3-coltext = '주문수량'.
      gs_pfcat3-qfieldname = 'MEINS'.
    WHEN 'MEINS'.
      gs_pfcat3-coltext = '단위'.
    WHEN 'WAERS'.
      gs_pfcat3-coltext = '통화'.
    WHEN 'NETWR'.
      gs_pfcat3-coltext = '주문금액'.
      gs_pfcat3-cfieldname = 'WAERS'.
  ENDCASE.

  APPEND gs_pfcat3 TO gt_pfcat3.
  CLEAR gs_pfcat3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_pop3_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_pop3_layout .

  gs_playout3-zebra = abap_true.
  gs_playout3-cwidth_opt = 'A'.
  gs_playout3-sel_mode = 'D'.
  gs_playout3-no_toolbar = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_pop3_object
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_pop3_object .

  CREATE OBJECT go_pop_cont3
    EXPORTING
      container_name = 'POP_CONT3'.


  CREATE OBJECT go_pop_grid3
    EXPORTING
      i_parent = go_pop_cont3.

ENDFORM.
