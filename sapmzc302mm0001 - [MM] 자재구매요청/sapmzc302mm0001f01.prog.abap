*&---------------------------------------------------------------------*
*& Include          SAPMZC302MM0001F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data_base
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data_base .

*-- 검색 조건
  PERFORM set_ranges.

*-- 구매요청 header
  PERFORM get_gt_mpr_h.

*-- 승인 및 반려 리스트
  PERFORM get_mpr_total_all_data.
  PERFORM make_display_mpr_total.

*-- 서치 헬프
  PERFORM get_search_help.

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
    CLEAR : gt_tfcat, gs_tfcat.
    PERFORM set_field_catalog USING : 'X' 'BANFN'   'ZC302MMT0004' 'C' ' ',
                                      ''  'MATNR'   'ZC302MMT0004' 'C' ' ',
                                      ''  'MAKTX'   'ZC302MMT0004' ' ' 'X',
                                      ''  'PLORDCO' 'ZC302MMT0004' 'C' ' ',
                                      ''  'BEDAR'   'ZC302MMT0004' 'C' ' ',
                                      ''  'MEINS'   'ZC302MMT0004' 'C' ' ',
                                      ''  'BEDAT'   'ZC302MMT0004' 'C' ' '.
    CLEAR : gt_trfcat, gs_trfcat.
    PERFORM set_field_right_catalog USING : 'X' 'BANFN'   'ZC302MMT0005' 'C' '',
                                            'X' 'PLORDCO' 'ZC302MMT0005' 'C' '',
                                            'X' 'MATNR'   'ZC302MMT0005' 'C' '',
                                            ''  'MAKTX'   'ZC302MMT0005' ' ' 'X',
                                            ''  'MENGE'   'ZC302MMT0005' 'C' '',
                                            ''  'MEINS'   'ZC302MMT0005' 'C' '',
                                            ''  'NETWR'   'ZC302MMT0005' 'C' '',
                                            ''  'WAERS'   'ZC302MMT0005' 'C' '',
                                            ''  'BEDAT'   'ZC302MMT0005' 'C' ''.
    CLEAR : gt_dfcat, gs_dfcat.
    PERFORM set_down_catalog USING :  'X' 'ICON'    'ZC302MMT0005' 'C' '',
                                      'X' 'PLORDCO' 'ZC302MMT0005' 'C' '',
                                      'X' 'BANFN'   'ZC302MMT0005' 'C' '',
                                      'X' 'MATNR'   'ZC302MMT0005' 'C' '',
                                      ''  'MAKTX'   'ZC302MMT0005' ' ' 'X',
                                      ''  'MENGE'   'ZC302MMT0005' 'C' '',
                                      ''  'MEINS'   'ZC302MMT0005' 'C' '',
                                      ''  'NETWR'   'ZC302MMT0005' 'C' '',
                                      ''  'WAERS'   'ZC302MMT0005' 'C' '',
                                      ''  'REMARK'  'ZC302MMT0005' ' ' '',
                                      ''  'BEDAT'   'ZC302MMT0005' 'C' ''.
    PERFORM set_layout.
    PERFORM create_object.

    SET HANDLER : lcl_event_handler=>hotspot_click FOR go_top_left_grid,
                  lcl_event_handler=>toolbar       FOR go_top_left_grid,
                  lcl_event_handler=>user_command  FOR go_top_left_grid,
                  lcl_event_handler=>button_click  FOR go_bottom_grid.

*-- 구매요청 Header
    gv_variant-report = sy-repid.
    gv_variant-handle = 'ALV1'.

    CALL METHOD go_top_left_grid->set_table_for_first_display "왼쪽 위
      EXPORTING
        is_variant      = gv_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_tlayout
      CHANGING
        it_outtab       = gt_mpr_h
        it_fieldcatalog = gt_tfcat.

*-- 구매요청 Item
    gv_variant-handle = 'ALV2'.

    CALL METHOD go_top_right_grid->set_table_for_first_display "오른쪽 위
      EXPORTING
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_trlayout
      CHANGING
        it_outtab       = gt_mpr_i
        it_fieldcatalog = gt_trfcat.

*-- 승인 및 반려 리스트
    gv_variant-handle = 'ALV3'.

    CALL METHOD go_bottom_grid->set_table_for_first_display "아래
      EXPORTING
        is_variant      = gv_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_dlayout
      CHANGING
        it_outtab       = gt_mpr_total
        it_fieldcatalog = gt_dfcat.

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
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_field_catalog  USING pv_key pv_field pv_table pv_just pv_emph.

  gs_tfcat-key       = pv_key.
  gs_tfcat-fieldname = pv_field.
  gs_tfcat-ref_table = pv_table.
  gs_tfcat-just      = pv_just.
  gs_tfcat-emphasize = pv_emph.

  CASE pv_field.
    WHEN 'BEDAR'.
      gs_tfcat-qfieldname = 'MEINS'.
    WHEN 'BANFN'.
      gs_tfcat-hotspot    = abap_true.
    WHEN 'BEDAT'.
      gs_tfcat-coltext    = '구매요청생성일자'.
    WHEN 'MEINS'.
      gs_tfcat-coltext    = '단위'.
  ENDCASE.

  APPEND gs_tfcat TO gt_tfcat.
  CLEAR gs_tfcat.

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

  gs_tlayout-zebra      = 'X'.
  gs_tlayout-cwidth_opt = 'A'.
  gs_tlayout-sel_mode   = 'D'.
  gs_tlayout-grid_title = '구매요청 리스트 (완제품)'.
  gs_tlayout-smalltitle = abap_true.

  gs_trlayout-zebra      = 'X'.
  gs_trlayout-cwidth_opt = 'A'.
  gs_trlayout-sel_mode   = 'D'.
  gs_trlayout-grid_title = '완제품 생성 시 필요한 원재료 리스트'.
  gs_trlayout-smalltitle = abap_true.

  gs_dlayout-zebra      = 'X'.
  gs_dlayout-cwidth_opt = 'A'.
  gs_dlayout-sel_mode   = 'D'.
  gs_dlayout-grid_title = '승인 및 반려 리스트'.
  gs_dlayout-stylefname = 'CELLTAB'.
  gs_dlayout-smalltitle = abap_true.

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

 CREATE OBJECT go_split_cont1
    EXPORTING
      parent  = go_container
      rows    = 1  " 2행
      columns = 2. " 1열

  CALL METHOD go_split_cont1->get_container
    EXPORTING
      row       = 1
      column    = 2
    RECEIVING
      container = go_top_cont.

  CALL METHOD go_split_cont1->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_bottom_cont.

  CREATE OBJECT go_split_cont2
    EXPORTING
      parent  = go_bottom_cont
      rows    = 2
      columns = 1.

  CALL METHOD go_split_cont2->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_up_cont.

  CALL METHOD go_split_cont2->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_down_cont.

  CREATE OBJECT go_bottom_grid
    EXPORTING
      i_parent = go_top_cont.

  CREATE OBJECT go_top_left_grid
    EXPORTING
      i_parent = go_up_cont.

  CREATE OBJECT go_top_right_grid
    EXPORTING
      i_parent = go_down_cont.


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

  REFRESH : gr_bedat, gr_matnr.
  CLEAR : gr_bedat, gr_matnr.

  IF gv_bedat IS NOT INITIAL.
    gr_bedat-sign     = 'I'.
    gr_bedat-option   = 'EQ'.
    gr_bedat-low = gv_bedat.
    IF gv_bedat2 IS NOT INITIAL.
      gr_bedat-option = 'BT'.
      gr_bedat-high   = gv_bedat2.
    ENDIF.
    APPEND gr_bedat.
  ENDIF.

  IF gv_matnr IS NOT INITIAL.
    gr_matnr-sign   = 'I'.
    gr_matnr-option = 'EQ'.
    gr_matnr-low    = gv_matnr.
    APPEND gr_matnr.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_hotspot_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM handle_hotspot_click  USING pv_row_id pv_column_id.

*-- 구매요청 header 읽어오기
  CLEAR gs_mpr_h.
  READ TABLE gt_mpr_h INTO gs_mpr_h INDEX pv_row_id.

  CLEAR gt_mpr_i.
  SELECT matnr banfn plordco maktx menge meins bedat netwr waers
    INTO CORRESPONDING FIELDS OF TABLE gt_mpr_i
    FROM zc302mmt0005
   WHERE banfn = gs_mpr_h-banfn.

  PERFORM refresh_table_tr.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_field_popup_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_field_right_catalog  USING pv_key pv_field pv_table pv_just pv_emph.

  gs_trfcat-key       = pv_key.
  gs_trfcat-fieldname = pv_field.
  gs_trfcat-ref_table = pv_table.
  gs_trfcat-just      = pv_just.
  gs_trfcat-emphasize = pv_emph.

  CASE pv_field.
    WHEN 'MENGE'.
      gs_trfcat-qfieldname = 'MEINS'. " 수량 설정
      gs_trfcat-coltext    = '수량'.
    WHEN 'NETWR'.
      gs_trfcat-cfieldname = 'WAERS'. " 금액 설정
      gs_trfcat-coltext    = '단가'.
    WHEN 'BEDAT'.
      gs_trfcat-coltext    = '희망구매요청일자'.
    WHEN 'MEINS'.
      gs_trfcat-coltext    = '단위'.
    WHEN 'WAERS'.
      gs_trfcat-coltext    = '통화'.
  ENDCASE.

  APPEND gs_trfcat TO gt_trfcat.
  CLEAR gs_trfcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_down_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_down_catalog  USING pv_key pv_field pv_table pv_just pv_emph.

  gs_dfcat-key       = pv_key.
  gs_dfcat-fieldname = pv_field.
  gs_dfcat-ref_table = pv_table.
  gs_dfcat-just      = pv_just.
  gs_dfcat-emphasize = pv_emph.

  CASE pv_field.
    WHEN 'BEDAR'.
      gs_dfcat-qfieldname = 'MEINS'. " 수량 설정
    WHEN 'MENGE'.
      gs_dfcat-qfieldname = 'MEINS'. " 수량 설정
      gs_dfcat-coltext    = '수량'.
    WHEN 'NETWR'.
      gs_dfcat-coltext    = '단가'. " 가격 설정
      gs_dfcat-cfieldname = 'WAERS'.
    WHEN 'MEINS'.
      gs_dfcat-coltext    = '단위'.
    WHEN 'WAERS'.
      gs_dfcat-coltext    = '통화'.
    WHEN 'ICON'.
      gs_dfcat-coltext    = '상태'.
    WHEN 'BEDAT'.
      gs_dfcat-coltext    = '희망구매요청일자'.
  ENDCASE.

  APPEND gs_dfcat TO gt_dfcat.
  CLEAR gs_dfcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_double_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM handle_double_click  USING pv_row pv_column.

*-- 선택한 행의 데이터 읽어오기
  CLEAR gs_mpr_total.
  READ TABLE gt_mpr_total INTO gs_mpr_total INDEX pv_row.
  gv_index = pv_row.

  SELECT *
  INTO CORRESPONDING FIELDS OF TABLE gt_mpr_i
    FROM zc302mmt0005
     WHERE banfn = gs_mpr_total-banfn.

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

*-- 반려사유 작성란
  IF go_text_cont IS NOT BOUND.
    PERFORM create_pop_object.
  ENDIF.

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

*-- container
  CREATE OBJECT go_text_cont
    EXPORTING
      container_name = 'POP_CONT'.

*-- Text Editor
  CREATE OBJECT go_text_edit
    EXPORTING
      wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
      parent        = go_text_cont.

*-- Edit toolbar
  CALL METHOD go_text_edit->set_toolbar_mode
    EXPORTING
      toolbar_mode = go_text_edit->false.  " true 대신 1로, false 대신 0으로 넣어도 된다.

*-- Display <-> Change
  CALL METHOD go_text_edit->set_readonly_mode
    EXPORTING
      readonly_mode = go_text_edit->false.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form remark_save
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM remark_save .

DATA :lt_save TYPE TABLE OF zc302mmt0005,
      ls_save TYPE zc302mmt0005.


*-- Get text from Editor
  CALL METHOD go_text_edit->get_text_as_r3table
    IMPORTING
      table                  = gt_content
    EXCEPTIONS
      error_dp               = 1
      error_cntl_call_method = 2
      error_dp_create        = 3
      potential_data_loss    = 4
      OTHERS                 = 5.

*-- text editor
  LOOP AT gt_content INTO gs_content.

     CONCATENATE gs_mpr_total-remark gs_content-tdline
                cl_abap_char_utilities=>newline INTO gs_mpr_total-remark.

  ENDLOOP.

  PERFORM rt_btn.

  LOOP AT gt_mpr_total INTO gs_mpr_total.

    gv_tabix = sy-tabix.

*-- 사용자가 입력한 반려사유 가져옴(입력 받은 값 WA에 업데이트)
    gs_mpr_total-remark = gs_content-tdline.
    gs_mpr_total-icon   = icon_led_red.

*-- 반려사유 저장
    MODIFY gt_mpr_total FROM gs_mpr_total INDEX gv_tabix TRANSPORTING remark icon aedat aenam aezet.

*-- 테이블 양식에 맞게 itab 이동
    MOVE-CORRESPONDING gs_mpr_total TO ls_save.

    APPEND ls_save TO lt_save.

  ENDLOOP.
  LOOP AT lt_save INTO ls_save.
    gv_tabix = sy-tabix.
*-- 타임스탬프 수정
    ls_save-aedat = sy-datum.
    ls_save-aenam = sy-uname.
    ls_save-aezet = sy-uzeit.

    MODIFY lt_save FROM ls_save INDEX gv_tabix TRANSPORTING aedat aenam aezet.



  ENDLOOP.
  CALL METHOD go_text_edit->delete_text.

*-- 저장로직 주석
  MODIFY zc302mmt0005 FROM TABLE lt_save.
  IF sy-subrc = 0.
    MESSAGE s001 WITH TEXT-s03.
    COMMIT WORK AND WAIT.
    PERFORM get_mpr_total_all_data.
    PERFORM make_display_mpr_total.
    PERFORM refresh_table_bottom.
    PERFORM refresh_table_tl.
    PERFORM refresh_table_tr.
*-- save 버튼 클릭 후 나가는 로직
    LEAVE TO SCREEN 0.
  ELSE.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_field_popup
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_field_popup  USING pv_key pv_field pv_table pv_just pv_emph.

  gs_pfcat-key       = pv_key.
  gs_pfcat-fieldname = pv_field.
  gs_pfcat-ref_table = pv_table.
  gs_pfcat-just      = pv_just.
  gs_pfcat-emphasize = pv_emph.

  APPEND gs_pfcat TO gt_pfcat.
  CLEAR gs_pfcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_gt_mpr_h
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_gt_mpr_h .

*-- status가 빈값만
  CLEAR : gt_mpr_h, gt_mpr_i .
  SELECT banfn plordco bedat bedar meins matnr maktx rstatus
    INTO CORRESPONDING FIELDS OF TABLE gt_mpr_h
    FROM zc302mmt0004
   WHERE matnr IN gr_matnr
     AND bedat IN gr_bedat
     AND rstatus = ''.

    gv_count = lines( gt_mpr_h ).
    MESSAGE s001 WITH gv_count TEXT-s04.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_mpr_i_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_mpr_total_data .

  CLEAR gt_mpr_total.
  SELECT a~matnr a~banfn a~plordco a~maktx menge a~bedat a~meins netwr waers remark rstatus
    INTO CORRESPONDING FIELDS OF TABLE gt_mpr_total
    FROM zc302mmt0005 AS a INNER JOIN zc302mmt0004 AS b
      ON a~banfn EQ b~banfn
   WHERE a~banfn = gs_mpr_h-banfn.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_mpr_total_all_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_mpr_total_all_data .

*-- rstatus안에 값이 있는 것들만 조회
    CLEAR gt_mpr_total.
    SELECT a~matnr a~banfn a~plordco a~maktx menge a~bedat a~meins netwr waers remark rstatus
      INTO CORRESPONDING FIELDS OF TABLE gt_mpr_total
      FROM zc302mmt0005 AS a INNER JOIN zc302mmt0004 AS b
        ON a~banfn EQ b~banfn
     WHERE rstatus IN ('A', 'B').


ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_display_mpr_total
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_mpr_total .

  DATA : ls_style TYPE lvc_s_styl.
*-- 구매요청 승인 및 반려 아이콘
  LOOP AT gt_mpr_total INTO gs_mpr_total.

    gv_tabix = sy-tabix.

    CASE gs_mpr_total-rstatus.
*-- 승인
      WHEN 'A'.
        gs_mpr_total-icon = icon_led_green.
*-- 반려
      WHEN 'B'.
        gs_mpr_total-icon = icon_led_red.
    ENDCASE.

*-- 반려 사유
  IF gs_mpr_total-remark IS NOT INITIAL.
    CLEAR : ls_style.
    ls_style-fieldname = 'REMARK'.
    ls_style-style     = cl_gui_alv_grid=>mc_style_button.
    INSERT ls_style INTO TABLE gs_mpr_total-celltab.
    gs_mpr_total-remark = '조회'.

  ENDIF.
    MODIFY gt_mpr_total FROM gs_mpr_total INDEX gv_tabix
                                          TRANSPORTING icon remark celltab.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_table_tr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_table_tr .
  DATA : ls_stbl TYPE lvc_s_stbl.

  ls_stbl-row = abap_true.
  ls_stbl-col = abap_true.

  CALL METHOD go_top_right_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stbl.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_table_bottom
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_table_bottom .
  DATA : ls_stbl TYPE lvc_s_stbl.

  ls_stbl-row = abap_true.
  ls_stbl-col = abap_true.

  CALL METHOD go_bottom_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stbl.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_table_tl
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_table_tl .
  DATA : ls_stbl TYPE lvc_s_stbl.

  ls_stbl-row = abap_true.
  ls_stbl-col = abap_true.

  CALL METHOD go_top_left_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stbl.

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

*-- 구분선
  CLEAR gs_button.
  gs_button-butn_type = 3.
  APPEND gs_button TO po_object->mt_toolbar.

*-- 승인 버튼
  CLEAR gs_button.
  gs_button-function  = 'AP'.
  gs_button-icon      = icon_checked.
  gs_button-text      = TEXT-b01.
  APPEND gs_button TO po_object->mt_toolbar.

*-- 반려 버튼
  CLEAR gs_button.
  gs_button-function  = 'RT'.
  gs_button-icon      = icon_incomplete.
  gs_button-text      = TEXT-b02.
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

  DATA : lt_index  TYPE lvc_t_row,
         ls_index  TYPE lvc_s_row.

  CALL METHOD go_top_left_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_index.

  CASE pv_ucomm.
*-- 승인
     WHEN 'AP'.
*-- 행 선택 안하고 버튼 클릭시 에러메시지창
      IF lines( lt_index ) < 1.
        MESSAGE s001 WITH TEXT-e04 DISPLAY LIKE 'E'.
        EXIT.
      ELSE.
        PERFORM ap_btn.
      ENDIF.
*-- 반려
     WHEN 'RT'.
*-- 행 선택 안하고 버튼 클릭시 에러메시지창
      IF lines( lt_index ) < 1.
        MESSAGE s001 WITH TEXT-e04 DISPLAY LIKE 'E'.
        EXIT.
*-- 반려는 하나의 행만 선택 가능
      ELSEIF lines( lt_index ) >= 2.
        MESSAGE i001 WITH TEXT-i02.
        EXIT.
      ELSE.
        CALL SCREEN 101 STARTING AT 65 05.
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_search_help
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_search_help .

  CLEAR : gs_mat, gt_mat.
  SELECT matnr maktx
    INTO CORRESPONDING FIELDS OF TABLE gt_mat
    FROM zc302mt0007.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  GET_MATERIAL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_material INPUT.

  PERFORM get_meterial_f4.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form get_meterial_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_meterial_f4 .

  DATA : lt_return TYPE TABLE OF ddshretval WITH HEADER LINE.

*-- Execute Search Help(F4)
  REFRESH lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'MATNR'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GV_MATNR'
      window_title    = 'Material code'
      value_org       = 'S'
    TABLES
      value_tab       = gt_mat
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ap_btn
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ap_btn .

DATA : lt_index  TYPE lvc_t_row,
       ls_index  TYPE lvc_s_row,
       ls_save_h TYPE zc302mmt0004,
       lv_answer_ap(1),
       lv_banfn(10),
       lv_pk(10).

  CALL METHOD go_top_left_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_index.

*-- 두개이상 선택하기 위한 정렬
  SORT lt_index BY index DESCENDING.

  LOOP AT lt_index INTO ls_index.

*-- 선택 구매요청 header 읽어오기
    CLEAR gs_mpr_h.
    READ TABLE gt_mpr_h INTO gs_mpr_h INDEX ls_index-index.

*-- 승인 데이터 설정
    PERFORM get_mpr_total_data.

*-- 승인 상태 설정
    gs_mpr_h-rstatus = 'A'.

*-- 구매요청처리된 셀 삭제
    DELETE gt_mpr_h INDEX ls_index-index.
    CLEAR : gt_mpr_i.

*-- DB에 저장하기 전 준비
    MOVE-CORRESPONDING gs_mpr_h TO ls_save_h.

    IF ls_save_h IS INITIAL.
      MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
    ENDIF.

*-- Set Time Stamp ( 구매요청 Header)
    ls_save_h-aedat = sy-datum.
    ls_save_h-aenam = sy-uname.
    ls_save_h-aezet = sy-uzeit.

**-- 자재구매요청 Header DB에 저장 주석
    MODIFY zc302mmt0004 FROM ls_save_h.
    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
*-- 승인 버튼 클릭시 메시지창
*      MESSAGE i001 WITH TEXT-i03.
      MESSAGE s001 WITH TEXT-s02.
    ELSE.
      MESSAGE s000 WITH TEXT-e01 DISPLAY LIKE 'E'.
      ROLLBACK WORK.
    ENDIF.

  ENDLOOP.

  PERFORM get_mpr_total_all_data.
  PERFORM make_display_mpr_total.
  PERFORM refresh_table_bottom.
  PERFORM refresh_table_tl.
  PERFORM refresh_table_tr.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form rt_btn
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM rt_btn .
  DATA : lt_index  TYPE lvc_t_row,
         ls_index  TYPE lvc_s_row,
         ls_save_h TYPE zc302mmt0004,
         lv_answer_ap(1),
         lv_banfn(10),
         lv_pk(10).

  CALL METHOD go_top_left_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_index.

  LOOP AT lt_index INTO ls_index.

*-- 선택 구매요청 header 읽어오기
    CLEAR gs_mpr_h.
    READ TABLE gt_mpr_h INTO gs_mpr_h INDEX ls_index-index.

*-- 반려 리스트 데이터 설정
    PERFORM get_mpr_total_data.

*-- 반려사유 상태값 변경
    gs_mpr_h-rstatus = 'B'.
*-- 구매요청처리된 셀 삭제
    DELETE gt_mpr_h INDEX ls_index-index.
    CLEAR : gt_mpr_i.

*-- DB에 저장하기 전 준비
    MOVE-CORRESPONDING gs_mpr_h TO ls_save_h.

    IF ls_save_h IS INITIAL.
      MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
    ENDIF.

*-- Set Time Stamp ( 구매요청 Header)
*    IF ls_save_h-erdat IS INITIAL.
*      ls_save_h-erdat = sy-datum.
*      ls_save_h-ernam = sy-uname.
*      ls_save_h-erzet = sy-uzeit.
*    ELSE.
      ls_save_h-aedat = sy-datum.
      ls_save_h-aenam = sy-uname.
      ls_save_h-aezet = sy-uzeit.
*    ENDIF.

*-- 자재구매요청 Header DB에
    MODIFY zc302mmt0004 FROM ls_save_h.
    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
*-- 승인 버튼 클릭시 메시지창
      MESSAGE s001 WITH TEXT-s03.
    ELSE.
      MESSAGE s000 WITH TEXT-e01 DISPLAY LIKE 'E'.
      ROLLBACK WORK.
    ENDIF.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_button_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ES_COL_ID
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM handle_button_click  USING ps_col_id TYPE lvc_s_col   " 행
                                ps_row_no TYPE lvc_s_roid. " 열


  READ TABLE gt_mpr_total INTO gs_mpr_total INDEX ps_row_no-row_id. "1번값이 들어옴

  SELECT banfn remark
    INTO CORRESPONDING FIELDS OF TABLE gt_mpr_i
    FROM zc302mmt0005
   WHERE banfn = gs_mpr_total-banfn.
  READ TABLE gt_mpr_i INTO gs_mpr_i WITH KEY banfn = gs_mpr_total-banfn.

*-- 아이템에 반려사유 불러오기
  CALL SCREEN 102 STARTING AT 65 05.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_pop_display2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_pop_display2 .

  IF go_text_cont2 IS NOT BOUND.
    PERFORM create_object_text2.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_object_text2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_object_text2 .

*-- container
  CREATE OBJECT go_text_cont2
    EXPORTING
      container_name = 'POP_CONT2'.

*-- Text Editor
  CREATE OBJECT go_text_edit2
    EXPORTING
      wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
      parent        = go_text_cont2.

*-- Edit toolbar
  CALL METHOD go_text_edit2->set_toolbar_mode
    EXPORTING
      toolbar_mode = go_text_edit2->false.

*-- Set Read-Only Mode
  CALL METHOD go_text_edit2->set_readonly_mode
    EXPORTING
      readonly_mode = go_text_edit2->false.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_text
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_text .
*-- 줄바꿈 기호를 기준으로 단어를 분리
  CLEAR : gt_content.
  SPLIT gs_mpr_i-remark AT cl_abap_char_utilities=>newline
                                      INTO TABLE gt_content.

*-- 자동 들여쓰기
  CALL METHOD go_text_edit2->set_autoindent_mode
    EXPORTING
      auto_indent            = 1
    EXCEPTIONS
      error_cntl_call_method = 1
      OTHERS                 = 2.

*-- 기존 작성된 내용 삭제
  CALL METHOD go_text_edit2->delete_text.


*-- Set text to Editor
  CALL METHOD go_text_edit2->set_selected_text_as_r3table
    EXPORTING
      table           = gt_content
    EXCEPTIONS
      error_dp        = 1
      error_dp_create = 2
      OTHERS          = 3.

*-- Set Read-Only Mode
  CALL METHOD go_text_edit2->set_readonly_mode
    EXPORTING
      readonly_mode = go_text_edit2->true.
ENDFORM.
