
*&---------------------------------------------------------------------*
*& Form DISPLAY_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_screen .
  DATA lv_variant TYPE disvariant.

  IF go_cont IS NOT BOUND.
    CLEAR : gt_fcat1, gs_fcat1,gt_fcat2, gs_fcat2,gt_fcat3, gs_fcat3.

    PERFORM field_catalog.
    PERFORM set_layout.
    PERFORM create_object.

    lv_variant-report = sy-repid.
    lv_variant-handle = 'ALV1'.

    SET HANDLER : lcl_event_handler=>hotspot_click2 FOR go_up_grid,
                  lcl_event_handler=>toolbar FOR go_alv_grid,
                  lcl_event_handler=>user_command FOR go_alv_grid.


    CALL METHOD go_alv_grid->set_table_for_first_display
      EXPORTING
        is_variant      = lv_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_layo
      CHANGING
        it_outtab       = gt_body
        it_fieldcatalog = gt_fcat1.

    lv_variant-handle = 'ALV2'.
    CALL METHOD go_up_grid->set_table_for_first_display
      EXPORTING
        is_variant      = lv_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_layo2
      CHANGING
        it_outtab       = gt_sub_hdata
        it_fieldcatalog = gt_fcat2.

    lv_variant-handle = 'ALV3'.
    CALL METHOD go_down_grid->set_table_for_first_display
      EXPORTING
        is_variant      = lv_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_layo3
      CHANGING
        it_outtab       = gt_sub_idata
        it_fieldcatalog = gt_fcat3.

  ELSE.
    CALL METHOD go_alv_grid->refresh_table_display.
    CALL METHOD go_up_grid->refresh_table_display.
    CALL METHOD go_down_grid->refresh_table_display.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM field_catalog .

*-- field catalog '1', '2', '3' 는 field symbol을 사용하기위해 지정
  "fieldsymbol key  field      table       just emphasize
  PERFORM set_field_catalog USING : '1' 'X' 'ICON'    'ZC302MMT0004'   'C' ' ',
                                    '1' 'X' 'BANFN'   'ZC302MMT0004'   'C' ' ',
                                    '1' 'X' 'PLORDCO' 'ZC302MMT0004'   'C' ' ',
                                    '1' 'X' 'MATNR'   'ZC302MMT0004'   ' ' ' ',
                                    '1' ' ' 'BEDAT'   'ZC302MMT0004'   'C' ' ',
                                    '1' ' ' 'BEDAR'   'ZC302MMT0004'   'C' ' ',
                                    '1' ' ' 'MEINS'   'ZC302MMT0004'   ' ' ' ',
*                                    '1' ' ' 'RSTATUS' 'ZC302MMT0004'   ' ' 'X',

                                    '2' 'X' 'ICON_SUB' 'ZC302MMT0007'  'C' ' ',
                                    '2' 'X' 'AUFNR'    'ZC302MMT0007'  'C' ' ',
                                    '2' 'X' 'BANFN'    'ZC302MMT0007'  'C' ' ',
                                    '2' 'X' 'PLORDCO'  'ZC302MMT0007'  'C' ' ',
                                    '2' ' ' 'BEDAT'    'ZC302MMT0007'  'C' ' ',
                                    '2' ' ' 'BODAT'    'ZC302MMT0007'  'C' ' ',
*                                    '2' ' ' 'STOSTAT'  'ZC302MMT0007'  ' ' ' ',

                                    '3' 'X' 'ICON_I'   'ZC302MMT0008'   'C' ' ',
                                    '3' 'X' 'AUFNR'    'ZC302MMT0008'   ' ' ' ',
                                    '3' 'X' 'BPCODE'   'ZC302MMT0008'   ' ' ' ',
                                    '3' 'X' 'MATNR'    'ZC302MMT0008'   ' ' ' ',
                                    '3' ' ' 'MAKTX'    'ZC302MMT0008'   ' ' 'X',
                                    '3' ' ' 'MENGE'    'ZC302MMT0008'   ' ' ' ',
                                    '3' ' ' 'MEINS'    'ZC302MMT0008'   ' ' ' ',
                                    '3' ' ' 'NETWR'    'ZC302MMT0008'   ' ' ' ',
                                    '3' ' ' 'WAERS'    'ZC302MMT0008'   ' ' ' ',
                                    '3' ' ' 'EINDT'    'ZC302MMT0008'   'C' ' ',
                                    '3' ' ' 'LFDAT'    'ZC302MMT0008'   'C' ' '.





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
FORM set_field_catalog  USING pv_num pv_key pv_field pv_table pv_just pv_emph .     "field sybol을 사용하기 위해 pv_num을 지정

  FIELD-SYMBOLS : <fs_fcat> LIKE gs_fcat1, " 필드심볼을 사용하여 <fs_fcat> 을 gs_fcat1의 형태로 만들어준다.
                  <ft_fcat> LIKE gt_fcat1.

  DATA : lvc_s_fcat(8), lvc_t_fcat(8).    "gs_fcat의 형태에 숫자 1,2,3을 붙이기 위해 lvc_s_fcat 8자리로 만들어줌

  CONCATENATE : 'GS_FCAT' pv_num INTO lvc_s_fcat,   " concatenate를 사용하여 gs_fcat과 숫자 1,2,3을 합쳐주고 lvc_s_fcat으로 값을 던져준다.
                'GT_FCAT' pv_num INTO lvc_t_fcat.

  ASSIGN : (lvc_s_fcat) TO <fs_fcat>,    " Assign을 사용하여 lvc_s_fcat과 <fs_fcat> 필드심볼로 값던져줌
           (lvc_t_fcat) TO <ft_fcat>.    " <fs_fcat>, <ft_fcat>을 gs_fcat, gt_fcat자리에 넣어주면 상황에 맞게 잘 적용된다.

  <fs_fcat>-key       = pv_key.
  <fs_fcat>-fieldname = pv_field.
  <fs_fcat>-ref_table = pv_table.
  <fs_fcat>-just      = pv_just.
  <fs_fcat>-emphasize = pv_emph.
*  gs_fcat-col_pos   = pv_pos. "칼럼 순서를 정해줌 pv_pos

  CASE pv_field.
    WHEN 'BEDAR'.
      <fs_fcat>-qfieldname = 'MEINS'.
    WHEN 'MENGE'.
      <fs_fcat>-qfieldname = 'MEINS'.
      <fs_fcat>-coltext    = '수량'.
    WHEN 'NETWR'.
      <fs_fcat>-cfieldname = 'WAERS'.
      <fs_fcat>-coltext    = '단가'.
    WHEN 'ICON'.
      <fs_fcat>-coltext = '상태'.
    WHEN 'ICON_SUB'.
      <fs_fcat>-coltext = '상태'.
    WHEN 'ICON_I'.
      <fs_fcat>-coltext = '상태'.
    WHEN 'AUFNR'.
      IF pv_table EQ 'ZC302MMT0007'.
        <fs_fcat>-hotspot = abap_true.
      ENDIF.
    WHEN 'BODAT'.
      <fs_fcat>-coltext = '발주일자'.
    WHEN 'MEINS'.
      <fs_fcat>-coltext = '단위'.
    WHEN 'WAERS'.
      <fs_fcat>-coltext = '통화'.
    WHEN 'EINDT'.
      <fs_fcat>-coltext = '입고예정일'.
    WHEN 'LFDAT'.
      <fs_fcat>-coltext = '입고완료일'.

  ENDCASE.


  APPEND <fs_fcat> TO <ft_fcat>.
  CLEAR <fs_fcat>.

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

  CREATE OBJECT go_cont
    EXPORTING
      container_name = 'MAIN_CONT'.


*-- Split
  CREATE OBJECT go_split_cont
    EXPORTING
      parent  = go_cont
      rows    = 1
      columns = 2.

*-- Assign Container
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

*-- Right Split
  CREATE OBJECT go_split2_cont
    EXPORTING
      parent  = go_right_cont
      rows    = 2
      columns = 1.

*-- Assign Right Container
  CALL METHOD go_split2_cont->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_up_cont.

  CALL METHOD go_split2_cont->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_down_cont.

*-- Set Column Width
  CALL METHOD go_split_cont->set_column_width
    EXPORTING
      id    = 1
      width = 40.

*-- ALV
  CREATE OBJECT go_alv_grid
    EXPORTING
      i_parent = go_left_cont.

*-- Right ALV
  CREATE OBJECT go_up_grid
    EXPORTING
      i_parent = go_up_cont.

  CREATE OBJECT go_down_grid
    EXPORTING
      i_parent = go_down_cont.


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

  gs_layo-zebra       = abap_true.
  gs_layo-cwidth_opt  = 'A'.
  gs_layo-sel_mode    = 'D'.
  gs_layo-grid_title  = '승인된 자재구매 리스트'.
  gs_layo-smalltitle  = abap_true.

  gs_layo2-zebra       = abap_true.
  gs_layo2-cwidth_opt  = 'A'.
  gs_layo2-sel_mode    = 'D'.
  gs_layo2-grid_title  = '구매발주 완료 리스트'.
  gs_layo2-smalltitle  = abap_true.

  gs_layo3-zebra       = abap_true.
  gs_layo3-cwidth_opt  = 'A'.
  gs_layo3-sel_mode    = 'D'.
  gs_layo3-grid_title  = '구매발주 상세내역'.
  gs_layo3-smalltitle  = abap_true.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form search_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM search_data .

  CLEAR : gt_body, gs_body.

  " Set Search Condition
  REFRESH : gr_bedat, gr_banfn.

  IF gv_lowdate IS NOT INITIAL.
    gr_bedat-sign = 'I'.
    gr_bedat-option = 'EQ'.
    gr_bedat-low = gv_lowdate.

    IF gv_highdate IS NOT INITIAL.
      gr_bedat-option = 'BT'.
      gr_bedat-high = gv_highdate.
    ENDIF.

    APPEND gr_bedat.
  ENDIF.

  IF gv_lro IS NOT INITIAL.
    gr_banfn-sign = 'I'.
    gr_banfn-option = 'EQ'.
    gr_banfn-low = gv_lro.

    IF gv_hro IS NOT INITIAL.
      gr_banfn-option = 'BT'.
      gr_banfn-high = gv_hro.
    ENDIF.

    APPEND gr_banfn.
  ENDIF.


  SELECT banfn plordco bedat bedar meins matnr rstatus
  INTO CORRESPONDING FIELDS OF TABLE gt_body
  FROM zc302mmt0004
 WHERE rstatus = 'A'
   AND bedat IN gr_bedat
   AND banfn IN gr_banfn.

  SORT gt_body BY banfn plordco matnr.

  IF gt_body IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form purchase_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM purchase_order USING pv_chrow.

  DATA : lt_index TYPE lvc_t_row,
         ls_index TYPE lvc_s_row.


  CLEAR : lt_index, ls_index.

  CALL METHOD go_alv_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_index.

  IF lines( lt_index ) > 1.
    MESSAGE s001 WITH text-e04 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  CLEAR : gs_body, gt_popup_body.
  ls_index = VALUE #( lt_index[ 1 ] OPTIONAL ).
  gv_tabix = ls_index-index.

  " 선택한 구매 요청 데이터 읽어옴
  READ TABLE gt_body INTO gs_body INDEX ls_index-index.
  APPEND gs_body TO gt_popup_body.

  CALL SCREEN 101 STARTING AT 01 02.

  CALL METHOD go_alv_grid->refresh_table_display.
  CALL METHOD go_up_grid->refresh_table_display.
  CALL METHOD go_down_grid->refresh_table_display.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form sub_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM sub_hdata .

  CLEAR : gt_sub_hdata, gs_sub_idata.

  SELECT aufnr banfn   emp_num ename  bedat netwr
         bodat plordco waers   stostat lfdat
    INTO CORRESPONDING FIELDS OF TABLE gt_sub_hdata
    FROM zc302mmt0007.

  SORT gt_sub_hdata BY aufnr DESCENDING banfn ASCENDING.

  LOOP AT gt_sub_hdata INTO gs_sub_hdata.
    gv_tabix = sy-tabix.

    CASE gs_sub_hdata-stostat.
      WHEN 'B'.
        gs_sub_hdata-icon_sub = icon_led_yellow.
      WHEN 'A'.
        gs_sub_hdata-icon_sub = icon_led_green.
    ENDCASE.

    IF sy-subrc = 0.
      MODIFY gt_sub_hdata FROM gs_sub_hdata INDEX gv_tabix
                                            TRANSPORTING icon_sub.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_popup_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_popup_screen .
  DATA : lv_variant TYPE disvariant.

  IF go_popup_cont IS NOT BOUND.

    PERFORM pop_field_catalog.
    PERFORM create_object_pop.

    lv_variant-report = sy-repid.
    lv_variant-handle = 'ALV4'.

    CALL METHOD go_up_grid2->set_table_for_first_display
      EXPORTING
        is_variant      = lv_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_playo1
      CHANGING
        it_outtab       = gt_popup_body
        it_fieldcatalog = gt_pfcat1.

    lv_variant-handle = 'ALV5'.
    CALL METHOD go_down_grid2->set_table_for_first_display
      EXPORTING
        is_variant      = lv_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_playo2
      CHANGING
        it_outtab       = gt_body2
        it_fieldcatalog = gt_pfcat2.
  ELSE.
    CALL METHOD go_up_grid2->refresh_table_display.
    CALL METHOD go_down_grid2->refresh_table_display.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form pop_field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM pop_field_catalog .

  PERFORM set_popup_field_catalog USING : '1' 'X' 'BANFN'     'ZC302MMT0004' 'C' ' ',
                                          '1' ' ' 'PLORDCO'   'ZC302MMT0004' 'C' ' ',
                                          '1' ' ' 'BEDAT'     'ZC302MMT0004' ' ' ' ',
                                          '1' ' ' 'BEDAR'     'ZC302MMT0004' ' ' ' ',
                                          '1' ' ' 'MEINS'     'ZC302MMT0004' ' ' ' ',
                                          '1' ' ' 'MATNR'     'ZC302MMT0004' 'C' ' ',

                                          '2' 'X' 'BANFN'     'ZC302MMT0005' 'C' ' ',
                                          '2' 'X' 'PLORDCO'   'ZC302MMT0005' 'C' ' ',
                                          '2' 'X' 'MATNR'     'ZC302MMT0005' 'C' ' ',
                                          '2' ' ' 'MAKTX'     'ZC302MMT0005' ' ' 'X',
                                          '2' ' ' 'MENGE'     'ZC302MMT0005' ' ' ' ',
                                          '2' ' ' 'MEINS'     'ZC302MMT0005' ' ' ' ',
                                          '2' ' ' 'NETWR'     'ZC302MMT0005' ' ' ' ',
                                          '2' ' ' 'WAERS'     'ZC302MMT0005' ' ' ' '.

  PERFORM set_layout2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_popup_field_catalog
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
FORM set_popup_field_catalog  USING pv_num pv_key pv_field
                                    pv_table pv_just pv_emph.

  FIELD-SYMBOLS : <fs_fcat> LIKE gs_pfcat1,
                  <ft_fcat> LIKE gt_pfcat1.



  DATA : lvc_s_fcat(9), lvc_t_fcat(9).

  CONCATENATE : 'GS_PFCAT' pv_num INTO lvc_s_fcat,
                'GT_PFCAT' pv_num INTO lvc_t_fcat.

  ASSIGN : (lvc_s_fcat) TO <fs_fcat>,
           (lvc_t_fcat) TO <ft_fcat>.



  <fs_fcat>-key       = pv_key.
  <fs_fcat>-fieldname = pv_field.
  <fs_fcat>-ref_table = pv_table.
  <fs_fcat>-just      = pv_just.
  <fs_fcat>-emphasize = pv_emph.

  CASE pv_field.
    WHEN 'BEDAR'.
      <fs_fcat>-qfieldname = 'MEINS'.
    WHEN 'MENGE'.
      <fs_fcat>-qfieldname = 'MEINS'.
    WHEN 'NETWR'.
      <fs_fcat>-cfieldname = 'WAERS'.
    WHEN 'NETWR'.
      <fs_fcat>-qfieldname = 'WAERS'.
    WHEN 'AUFNR'.
      <fs_fcat>-hotspot = abap_true.

  ENDCASE.

  APPEND <fs_fcat> TO <ft_fcat>.
  CLEAR <fs_fcat>.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_object_pop
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_object_pop .

*-- POPUP Container
  CREATE OBJECT go_popup_cont
    EXPORTING
      container_name = 'POP_CONT'.

*-- Split
  CREATE OBJECT go_split_cont3
    EXPORTING
      rows    = 2
      columns = 1
      parent  = go_popup_cont.

*-- Assign Container
  CALL METHOD go_split_cont3->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_up_cont2.

  CALL METHOD go_split_cont3->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_down_cont2.

*-- Set Column Width
*  CALL METHOD go_split_cont3->set_column_width
*    EXPORTING
*      id    = 1
*      width = 40.

*-- ALV
  CREATE OBJECT go_up_grid2
    EXPORTING
      i_parent = go_up_cont2.

  CREATE OBJECT go_down_grid2
    EXPORTING
      i_parent = go_down_cont2.





ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout2 .

  gs_playo1-zebra       = abap_true.
  gs_playo1-cwidth_opt  = 'A'.
  gs_playo1-sel_mode    = 'D'.
  gs_playo1-grid_title  = '자재 구매요청 Header'.
  gs_playo1-smalltitle  = abap_true.

  gs_playo2-zebra       = abap_true.
  gs_playo2-cwidth_opt  = 'A'.
  gs_playo2-sel_mode    = 'D'.
  gs_playo2-grid_title  = '자재 구매요청 Item'.
  gs_playo2-smalltitle  = abap_true.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_popup
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_popup .

  SELECT aufnr banfn  ename bedat netwr bodat plordco waers
    INTO CORRESPONDING FIELDS OF TABLE gt_sub_hdata
    FROM zc302mmt0007.

  SELECT aufnr bpcode matnr menge meins netwr waers
    INTO CORRESPONDING FIELDS OF TABLE gt_sub_idata
    FROM zc302mmt0008.

  LOOP AT gt_sub_idata INTO gs_sub_idata.

    gv_tabix = sy-tabix.

    READ TABLE gt_material INTO gs_material WITH KEY matnr = gs_sub_idata-matnr.

    IF sy-subrc EQ 0.
      gs_sub_idata-matlt = gs_material-matlt.
    ENDIF.

    MODIFY gt_sub_idata FROM gs_sub_idata INDEX gv_tabix TRANSPORTING matlt.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form order_create
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM order_create.

  DATA : lv_prefix(2) VALUE 'PO',
         lv_answer(1),
         lv_month(2),
         lv_year(4),
         lv_prd(8).

  DATA : lt_index  TYPE lvc_t_row,
         ls_index  TYPE lvc_s_row,
         lv_create.

  DATA : lv_banfn LIKE gs_body-banfn.

  " 발주 승인 컨펌
  PERFORM ask_create CHANGING lv_answer.

  IF lv_answer NE '1'.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*  lv_banfn = gs_body-banfn.

**********************************************************************
*구매요청 헤더 status 발주완료로 변경
**********************************************************************
*-- 선택된 행의 정보를 읽어와서 구매오더가 생성된 항목의 상태값을 A->C로 변경해주는 로직
  gs_body-rstatus = 'C'.
  gs_body-icon    = icon_led_yellow.

  MODIFY gt_body FROM gs_body INDEX gv_tabix
                              TRANSPORTING icon rstatus.

  PERFORM save_pur_request.

**********************************************************************
* 구매오더 헤더 생성
**********************************************************************
*-- 구매오더번호 생성
  CLEAR : gs_temp_hdata.

*-- 현재날짜 연도와 월 가져오는것
  lv_year = sy-datum+2(2).   "년
  lv_month = sy-datum+4(2).  "월

  IF lv_month < '10'.
    CONCATENATE lv_year(2) '0' lv_month INTO lv_year.
  ELSE.
    CONCATENATE lv_year(2) lv_month INTO lv_year.
  ENDIF.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZC303MMPO'
    IMPORTING
      number      = gs_temp_hdata-aufnr.

  CONCATENATE lv_prefix lv_year gs_temp_hdata-aufnr INTO gs_temp_hdata-aufnr.

*-- 구매오더 상태 업데이트
  gs_temp_hdata-bodat   = sy-datum.        " 발주일자
  gs_temp_hdata-stostat = 'B'.             " 발주완료 여부 ( B: 배송 중 )
  gs_temp_hdata-banfn   = gs_body-banfn.   " 구매요청번호
  gs_temp_hdata-bedat   = gs_body-bedat.   " 구매요청일자
  gs_temp_hdata-plordco = gs_body-plordco. " 계획오더번호

  " 구매오더 Header DB 저장
  PERFORM save_pur_order_h.

  " 신규 생성된 헤더 alv에 반영
  CLEAR : gs_sub_hdata.
  MOVE-CORRESPONDING gs_temp_hdata TO gs_sub_hdata.
  APPEND gs_sub_hdata TO gt_sub_hdata.

**********************************************************************
* 구매오더 아이템 생성
**********************************************************************
  PERFORM create_po_item.
  MOVE-CORRESPONDING gt_sub_idata TO gt_qc.

**********************************************************************
* 구매오더 ITEM 정보 품질검수로 전송
* 시나리오 발주이후 바로 원자재 입고 -> 원자재 품질검수 진행
* 품질검수에서 필요한 입고번호, 입고날짜, 송장번호 채번하여 전달.
**********************************************************************
  PERFORM make_display_qc.
  PERFORM save_qc.

*-- icon change
  PERFORM sub_hdata.


*-- ITAB refresh
  PERFORM refresh_table.

  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_hotspot_click2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&---------------------------------------------------------------------*
FORM handle_hotspot_click2  USING    pv_row_id  pv_column_id.

  CLEAR gs_sub_idata.
  READ TABLE gt_sub_hdata INTO gs_sub_hdata INDEX pv_row_id.

  CLEAR gt_sub_idata.
  SELECT aufnr banfn plordco bpcode matnr maktx
         menge meins netwr waers eindt lfdat devsta
    INTO CORRESPONDING FIELDS OF TABLE gt_sub_idata
    FROM zc302mmt0008
   WHERE aufnr    EQ gs_sub_hdata-aufnr
     AND banfn    EQ gs_sub_hdata-banfn
     AND plordco  EQ gs_sub_hdata-plordco.

  SORT gt_sub_idata BY matnr.

  LOOP AT gt_sub_idata INTO gs_sub_idata.
    gv_tabix = sy-tabix.
    CASE gs_sub_idata-devsta.
      WHEN 'B'.
        gs_sub_idata-icon_i = icon_led_yellow.
      WHEN 'A'.
        gs_sub_idata-icon_i = icon_led_green.
    ENDCASE.

    IF sy-subrc = 0.
      MODIFY gt_sub_idata FROM gs_sub_idata INDEX gv_tabix
                                            TRANSPORTING icon_i.
    ENDIF.
  ENDLOOP.

  IF gt_sub_idata IS INITIAL.
    MESSAGE  s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
  ENDIF.

  CALL METHOD go_down_grid->refresh_table_display.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ask_create
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ask_create CHANGING pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      text_question         = '해당 품목을 발주하시겠습니까?.'
      text_button_1         = 'YES'(001)
      icon_button_1         = 'ICON_OKAY'
      text_button_2         = 'NO'(002)
      icon_button_2         = 'ICON_CANCEL'
      default_button        = '1'
      display_cancel_button = 'X'
    IMPORTING
      answer                = pv_answer.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_search_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_search_data .
  LOOP AT gt_body INTO gs_body.
    gv_tabix = sy-tabix.
    CASE gs_body-rstatus.
      WHEN 'A'. "구매발주가 안된 리스트는 red로 표시.
        gs_body-icon = icon_led_red.
*      WHEN 'C'.
*        gs_body-icon = icon_led_green.
    ENDCASE.
    IF sy-subrc = 0.
      MODIFY gt_body FROM gs_body INDEX gv_tabix
                                  TRANSPORTING icon.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_po_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_po_item .

*-- gs_body2에 자재코드별 구매리드타임 입력
  SELECT matnr bpcode matlt maktx
    INTO CORRESPONDING FIELDS OF TABLE gt_material
    FROM zc302mt0007.

*-- 구매오더 아이템 데이터 채우기
  MOVE-CORRESPONDING gt_body2 TO gt_temp_idata.

  " BP코드와 입고예정일 채우기
  LOOP AT gt_temp_idata INTO gs_temp_idata.

    gv_tabix = sy-tabix.

    " 해당 자재의 리드타임과 BP코드 읽어옴
    CLEAR : gs_material, gs_body2.
    READ TABLE gt_material INTO gs_material WITH KEY matnr = gs_temp_idata-matnr. " 구매리드타임
    READ TABLE gt_body2    INTO gs_body2    WITH KEY banfn = gs_temp_idata-banfn
                                                     matnr = gs_temp_idata-matnr.

    " 현재시간과 구매리드타임을 더한 입고 예정일을 생성해준다.
    CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
      EXPORTING
        date      = sy-datum
        days      = gs_material-matlt
        months    = '00'
        signum    = '+'
        years     = '00'
      IMPORTING
        calc_date = gs_temp_idata-eindt.         " 입고 예정일

    gs_temp_idata-aufnr  = gs_temp_hdata-aufnr.  " 구매오더번호
    gs_temp_idata-bpcode = gs_material-bpcode.   " BPcode
    gs_temp_idata-maktx  = gs_material-maktx.    " 자재명
    gs_temp_idata-menge  = gs_body2-menge.       " 수량
    gs_temp_idata-meins  = gs_body2-meins.       " 단위
    gs_temp_idata-netwr  = gs_body2-netwr.       " 단가
    gs_temp_idata-waers  = gs_body2-waers.       " 통화
    gs_temp_idata-lfdat  = ''.                   " 입고완료일
    gs_temp_idata-devsta = 'B'.                  " 배송상태



    MODIFY gt_temp_idata FROM gs_temp_idata INDEX gv_tabix
                                            TRANSPORTING aufnr eindt bpcode menge
                                                         meins netwr waers xblnr devsta.
  ENDLOOP.



  " 구매오더 아이템 DB에 저장
  PERFORM save_purchase_order_data.

  " 스크린 100의 구매오더 item alv에 반영
  CLEAR gt_sub_idata.
  MOVE-CORRESPONDING gt_temp_idata TO gt_sub_idata.
  PERFORM sub_idata.

  PERFORM refresh_down_table.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_so_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_po_item .

  CLEAR : gt_sub_idata, gs_popup_body.

  gs_popup_body = VALUE #( gt_popup_body[ 1 ] OPTIONAL ).

  SELECT matnr banfn plordco maktx menge meins waers netwr
    INTO CORRESPONDING FIELDS OF TABLE gt_body2
    FROM zc302mmt0005
   WHERE banfn EQ gs_popup_body-banfn.

  IF gt_body2 IS INITIAL.
    MESSAGE  s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form move_material
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_qc .

  DATA: lt_save  TYPE TABLE OF zc302mmt0006,
        ls_save  TYPE zc302mmt0006,
        lv_tabix TYPE sy-tabix.

  MOVE-CORRESPONDING gt_qc TO lt_save.

  LOOP AT lt_save INTO ls_save.

    lv_tabix = sy-tabix.

    IF ls_save-erdat IS INITIAL.
      ls_save-erdat = sy-datum.
      ls_save-erzet = sy-uzeit.
      ls_save-ernam = sy-uname.
    ELSE.
      ls_save-aedat = sy-datum.
      ls_save-aezet = sy-uzeit.
      ls_save-aenam = sy-uname.
    ENDIF.

    MODIFY lt_save FROM ls_save INDEX lv_tabix
                                TRANSPORTING erdat erzet ernam
                                             aedat aezet aenam.

  ENDLOOP.

  MODIFY zc302mmt0006 FROM TABLE lt_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form etc_number
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_qc .

  DATA : lv_prefix1(2) VALUE 'MD',    " 자재문서번호
         lv_prefix2(3) VALUE 'MIV',   " 송장번호
*         lv_prefix2(4) VALUE 'MIVD',   "송장문서번호
         lv_day(2),
         lv_month(2),
         lv_year(4).

  LOOP AT gt_qc INTO gs_qc.

    gv_tabix = sy-tabix.

**********************************************************************
* 송장번호
**********************************************************************

*-- 현재날짜 연도와 월 가져오는것
    lv_year  = sy-datum+2(2).  " 년
    lv_month = sy-datum+4(2).  " 월
    lv_day   = sy-datum+6(2).  " 일

    IF lv_month < '10'.
      CONCATENATE lv_year(2) '0' lv_month lv_day INTO lv_year.
    ELSE.
      CONCATENATE lv_year(2) lv_month lv_day INTO lv_year.
    ENDIF.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '01'
        object      = 'ZC303MMMIV'
      IMPORTING
        number      = gs_qc-xblnr.

    CONCATENATE lv_prefix2 lv_year gs_qc-xblnr INTO gs_qc-xblnr.

**********************************************************************
* 자재문서번호
**********************************************************************

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '01'
        object      = 'ZC321MMMD'
      IMPORTING
        number      = gs_qc-mblnr.

    CONCATENATE lv_prefix1 gs_qc-mblnr INTO gs_qc-mblnr.

**********************************************************************
* 자재코드 별 창고코드
**********************************************************************
    IF gs_qc-matnr CP 'RM*'.
      gs_qc-scode = 'ST01'.
    ELSEIF gs_qc-matnr CP 'SP*'.
      gs_qc-scode = 'ST02'.
    ENDIF.

**********************************************************************
* Etc number, Stat exporting
**********************************************************************
*-- 송장일자 생성
    gs_qc-bldat = sy-datum.
*-- 입고일자 생성
    gs_qc-budat = sy-datum.
*-- 검수상태 미완료 설정
    gs_qc-qstat = 'B'.

    READ TABLE gt_sub_idata INTO gs_sub_idata WITH KEY matnr = gs_qc-matnr
                                                       aufnr = gs_qc-aufnr.

    IF sy-subrc EQ 0.
*-- 희망송장일자 생성 자재코드별 희망송장일자가 달라짐.
      gs_qc-hbudat = gs_qc-bldat + gs_sub_idata-matlt.
*-- 희망입고일자 생성
      gs_qc-hbldat = gs_qc-budat + gs_sub_idata-matlt.
*-- 검수상태 설정
      gs_qc-qstat = 'B'.
    ENDIF.


    MODIFY gt_qc FROM gs_qc INDEX gv_tabix
                            TRANSPORTING xblnr mblnr bldat budat hbudat hbldat qstat scode.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_purchase_order_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_purchase_order_data .

  DATA: lt_save TYPE TABLE OF zc302mmt0008,
        ls_save TYPE zc302mmt0008.

  MOVE-CORRESPONDING gt_temp_idata TO lt_save.

  LOOP AT lt_save INTO ls_save.

    gv_tabix = sy-tabix.

    IF ls_save-erdat IS INITIAL.
      ls_save-erdat = sy-datum.
      ls_save-erzet = sy-uzeit.
      ls_save-ernam = sy-uname.
    ELSE.
      ls_save-aedat = sy-datum.
      ls_save-aezet = sy-uzeit.
      ls_save-aenam = sy-uname.
    ENDIF.

    MODIFY lt_save FROM ls_save INDEX gv_tabix
                                TRANSPORTING erdat erzet ernam
                                             aedat aezet aenam.

  ENDLOOP.

  " 신규 item db에 반영
  MODIFY zc302mmt0008 FROM TABLE lt_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_display_po
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_po .

  DATA: lv_tabix TYPE sy-tabix.

  LOOP AT gt_sub_hdata INTO gs_sub_hdata.

    lv_tabix = sy-tabix.
*--구매오더의 아이템 행 확인
    SELECT SINGLE COUNT(*)
      INTO @DATA(lv_num1)
      FROM zc302mmt0008
     WHERE aufnr EQ @gs_sub_hdata-aufnr.

*-- 구매오더 아이템의 입고가 완료된 행 확인
    SELECT SINGLE COUNT(*)
      INTO @DATA(lv_num2)
      FROM zc302mmt0008
     WHERE aufnr  EQ @gs_sub_hdata-aufnr
       AND devsta EQ 'A'.

*-- 행이 같아지면 구매오더 헤더의 상태를 입고완료로 바꿔준다.
    IF lv_num1 EQ lv_num2.
      gs_sub_hdata-stostat  = 'A'.
      gs_sub_hdata-icon_sub = icon_led_green.
      gs_sub_hdata-lfdat    = sy-datum.
    ELSE.
      CONTINUE.
    ENDIF.

    MODIFY gt_sub_hdata FROM gs_sub_hdata INDEX lv_tabix
                                          TRANSPORTING stostat icon_sub lfdat.

  ENDLOOP.

  PERFORM save_pur_order_h_data.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_pur_order_h_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_pur_order_h_data .

  DATA: lt_save  TYPE TABLE OF zc302mmt0007,
        ls_save  TYPE zc302mmt0007,
        lv_tabix TYPE sy-tabix.

  MOVE-CORRESPONDING gt_sub_hdata TO lt_save.

  LOOP AT lt_save INTO ls_save.

    lv_tabix = sy-tabix.

    IF ls_save-erdat IS INITIAL.
      ls_save-erdat = sy-datum.
      ls_save-erzet = sy-uzeit.
      ls_save-ernam = sy-uname.
    ELSE.
      ls_save-aedat = sy-datum.
      ls_save-aezet = sy-uzeit.
      ls_save-aenam = sy-uname.
    ENDIF.

    MODIFY lt_save FROM ls_save INDEX lv_tabix
                                TRANSPORTING erdat erzet ernam
                                             aedat aezet aenam.

  ENDLOOP.

  " 신규 Header db에 반영
  MODIFY zc302mmt0007 FROM TABLE lt_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM toolbar  USING    po_object TYPE REF TO cl_alv_event_toolbar_set
                       pv_interactive.

  PERFORM set_left_tbar USING: ' '    ' '         ' '  3  ' '        po_object,
                               'MOC'  icon_order  ' ' ' ' TEXT-i01   po_object.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_left_tbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_3
*&      --> P_
*&      --> PO_OBJECT
*&---------------------------------------------------------------------*
FORM set_left_tbar  USING    pv_func pv_icon pv_qinfo pv_type pv_text
                             po_object TYPE REF TO cl_alv_event_toolbar_set.

  CLEAR gs_po_btn.
  gs_po_btn-function  = pv_func.
  gs_po_btn-icon      = pv_icon.
  gs_po_btn-quickinfo = pv_qinfo.
  gs_po_btn-butn_type = pv_type.
  gs_po_btn-text      = pv_text.
  APPEND gs_po_btn TO po_object->mt_toolbar.

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
    WHEN 'MOC'.
      PERFORM purchase_order USING gv_chrow.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_pur_request
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_pur_request .

  DATA: ls_save  TYPE zc302mmt0004.

  MOVE-CORRESPONDING gs_body TO ls_save.

  ls_save-aedat = sy-datum.
  ls_save-aezet = sy-uzeit.
  ls_save-aenam = sy-uname.

  MODIFY zc302mmt0004 FROM ls_save.

  IF sy-subrc = 0.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_pur_order_h
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_pur_order_h .

  DATA: ls_save TYPE zc302mmt0007.

  MOVE-CORRESPONDING gs_temp_hdata TO ls_save.

  " Timestamp
  IF ls_save-erdat IS INITIAL.
    ls_save-erdat = sy-datum.
    ls_save-erzet = sy-uzeit.
    ls_save-ernam = sy-uname.
  ELSE.
    ls_save-aedat = sy-datum.
    ls_save-aezet = sy-uzeit.
    ls_save-aenam = sy-uname.
  ENDIF.

  " DB  테이블에 신규 헤더 생성
  MODIFY zc302mmt0007 FROM ls_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

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

  PERFORM refresh_left_table.
  PERFORM refresh_up_table.
  PERFORM refresh_down_table.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_left_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_left_table .

  DATA: ls_stable TYPE lvc_s_stbl.

  ls_stable-col = abap_true.
  ls_stable-row = abap_true.

  CALL METHOD go_alv_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stable.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_up_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_up_table .

  DATA: ls_stable TYPE lvc_s_stbl.

  ls_stable-col = abap_true.
  ls_stable-row = abap_true.

  CALL METHOD go_up_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stable.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_down_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_down_table .

  DATA: ls_stable TYPE lvc_s_stbl.

  ls_stable-col = abap_true.
  ls_stable-row = abap_true.

  CALL METHOD go_down_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stable.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form sub_idata
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM sub_idata .


*
*  SELECT *
*    INTO CORRESPONDING FIELDS OF TABLE gt_sub_idata
*    FROM zc302mmt0008
*   WHERE aufnr EQ gs_sub_hdata-aufnr.
*
*  SORT gt_sub_idata BY aufnr DESCENDING banfn ASCENDING.
*
  LOOP AT gt_sub_idata INTO gs_sub_idata.
    gv_tabix = sy-tabix.

    CASE gs_sub_idata-devsta.
      WHEN 'B'.
        gs_sub_idata-icon_i = icon_led_yellow.
      WHEN 'A'.
        gs_sub_idata-icon_i = icon_led_green.
    ENDCASE.

    IF sy-subrc = 0.
      MODIFY gt_sub_idata FROM gs_sub_idata INDEX gv_tabix
                                            TRANSPORTING icon_i.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_aufnr_low
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_aufnr_low .

  DATA : lt_return TYPE TABLE OF ddshretval WITH HEADER LINE.

  REFRESH lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BANFN'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GV_LRO'
      window_title    = '구매요청번호'
      value_org       = 'S'
    TABLES
      value_tab       = gt_pr
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_aufnr_high
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_aufnr_high .
  DATA : lt_return TYPE TABLE OF ddshretval WITH HEADER LINE.

  REFRESH lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BANFN'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GV_HRO'
      window_title    = '구매요청번호'
      value_org       = 'S'
    TABLES
      value_tab       = gt_pr
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_banfn
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_banfn .
  CLEAR gt_pr.
  SELECT DISTINCT banfn
    INTO CORRESPONDING FIELDS OF TABLE gt_pr
    FROM zc302mmt0004.

  SORT gt_pr BY banfn.

ENDFORM.
