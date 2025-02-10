*&---------------------------------------------------------------------*
*& Include          SAPMZC302MM0004F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_qc_main_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_qc_main_data .

  DATA : lv_date      TYPE sy-datum,
         lv_date_5day TYPE sy-datum.

  lv_date = sy-datum.
  lv_date_5day  = lv_date - 2. "최근 3일 데이터만 품질검수 완료에서 보여줌

  CLEAR : gt_body, gs_body, gs_employee.

*-- 직원정보
  SELECT SINGLE ename emp_num orgtx plstx
      INTO CORRESPONDING FIELDS OF gs_employee
      FROM zc302mt0003
     WHERE emp_num = sy-uname.

*-- Screen painter Employee info.
  gv_emp_num  = gs_employee-emp_num.
  gv_emp      = gs_employee-ename.
  gv_orgtx    = gs_employee-orgtx.
  gv_plstx    = gs_employee-plstx.


  IF gs_body-qstat BETWEEN 'A' AND 'C'.
    gv_emp_num2  = gs_body-emp_num.
    gv_emp2      = gs_body-ename.
  ENDIF.

*-- Screen painter icon Total.
  PERFORM icon_total.

*-- 원자재 입고 리스트
  SELECT *
     INTO CORRESPONDING FIELDS OF TABLE gt_body
     FROM zc302mmt0006
    WHERE aufnr     IN gr_aufnr
      AND budat     IN gr_budat
      AND pastrterm IN gr_pastrterm
      AND qstat     EQ 'B'.

  SORT gt_body BY aufnr matnr.

  IF gt_body IS INITIAL.
    MESSAGE s001 WITH TEXT-e09 DISPLAY LIKE 'E'.
  ENDIF.

*-- 원자재 품질검수 완료 리스트
  IF gv_okcode EQ 'SH'.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE gt_body2
      FROM zc302mmt0006
     WHERE aufnr     IN gr_aufnr
       AND budat     IN gr_budat
       AND pastrterm IN gr_pastrterm
       AND qstat     BETWEEN 'A' AND 'C'.
  ELSE.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE gt_body2
      FROM zc302mmt0006
      WHERE aufnr     IN gr_aufnr
      AND budat     IN gr_budat
      AND pastrterm IN gr_pastrterm
      AND qstat     BETWEEN 'A' AND 'C'
      AND pastrterm >= lv_date_5day.

  ENDIF.


  SORT gt_body BY aufnr matnr.

  IF gt_body2 IS INITIAL.
    MESSAGE s001 WITH TEXT-e10 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form range_condition
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_search_condition.

  " Set Search Condition
  REFRESH : gr_aufnr, gr_budat, gr_pastrterm.

*-- 구매 오더번호 Range
  IF gv_po_low IS NOT INITIAL.
    gr_aufnr-sign = 'I'.
    gr_aufnr-option = 'EQ'.
    gr_aufnr-low = gv_po_low.

    IF gv_po_high IS NOT INITIAL.
      gr_aufnr-option = 'BT'.
      gr_aufnr-high = gv_po_high.
    ENDIF.

    APPEND gr_aufnr.
  ENDIF.

*-- 입고날짜 Range
  IF gv_date_low IS NOT INITIAL.
    gr_budat-sign = 'I'.
    gr_budat-option = 'EQ'.
    gr_budat-low = gv_date_low.

    IF gv_date_high IS NOT INITIAL.
      gr_budat-option = 'BT'.
      gr_budat-high = gv_date_high.
    ENDIF.

    APPEND gr_budat.
  ENDIF.

*-- 검수일 Range
  IF gv_ch_low IS NOT INITIAL.
    gr_pastrterm-sign = 'I'.
    gr_pastrterm-option = 'EQ'.
    gr_pastrterm-low = gv_ch_low.

    IF gv_ch_high IS NOT INITIAL.
      gr_pastrterm-option = 'BT'.
      gr_pastrterm-high = gv_ch_high.
    ENDIF.

    APPEND gr_pastrterm.
  ENDIF.


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

  PERFORM set_search_condition.
  PERFORM get_qc_main_data.

  PERFORM refresh_table.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MQC_Check
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM mqc_check USING pv_chrow.

  DATA : lt_index TYPE lvc_t_row,
         ls_index TYPE lvc_s_row.

  CLEAR : lt_index, ls_index, gv_tabix, gs_body2.

  CALL METHOD go_alv_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_index.

  IF lines( lt_index ) > 1.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'.
    EXIT.
  ELSEIF lines( lt_index ) < 1.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'.
    EXIT.
  ELSE.
    CLEAR : ls_index.
    ls_index = VALUE #( lt_index[ 1 ] OPTIONAL ).
    gv_tabix = ls_index-index.

    READ TABLE gt_body INTO gs_body INDEX gv_tabix. " 첫번째 선택된 행

    CLEAR: gv_qinum, gv_emp, gv_emp_num, gv_pastrterm.
    IF sy-subrc = 0.
      gv_po_num     = gs_body-aufnr.     " 구매오더번호
      gv_income_num = gs_body-xblnr.     " 송장번호
      gv_menge      = gs_body-menge.     " 입고수량
      gv_matnr      = gs_body-matnr.     " 자재코드
      gv_maktx      = gs_body-maktx.     " 자재명
      gv_meins      = gs_body-meins.     " 단위
      gv_dismenge   = gs_body-dismenge.  " 폐기수량
      gv_qimenge    = gs_body-qimenge.   " 최종입고수량
      gv_disreason  = gs_body-disreason. " 폐기사유
      gv_emp2       = gs_body-ename.     " 사원이름
      gv_emp_num2   = gs_body-emp_num.   " 사원번호
      gv_qc_date    = gs_body-pastrterm. " 검수일
    ENDIF.
  ENDIF.

  gv_status = 'QCH'.

  CALL SCREEN 101 STARTING AT 03 05.

  CALL METHOD cl_gui_cfw=>set_new_ok_code
    EXPORTING
      new_code = 'ENTER'.

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

  IF go_cont IS NOT BOUND.

    CLEAR : gt_fcat, gs_fcat, gt_fcat2, gs_fcat2.
    PERFORM field_catalog.
    PERFORM create_object.

    gv_variant-report = sy-repid.
    gv_variant-handle = 'ALV1'.

    SET HANDLER lcl_event_handler=>toolbar      FOR go_alv_grid.
    SET HANDLER lcl_event_handler=>toolbar2     FOR go_down_grid.
    SET HANDLER lcl_event_handler=>user_command FOR go_alv_grid.
    SET HANDLER lcl_event_handler=>user_command FOR go_down_grid.

*-- 상단 ALV
    CALL METHOD go_alv_grid->set_table_for_first_display
      EXPORTING
        is_variant      = gv_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_layo
      CHANGING
        it_outtab       = gt_body
        it_fieldcatalog = gt_fcat.

*-- 하단 ALV
    gv_variant-handle = 'ALV2'.

    CALL METHOD go_down_grid->set_table_for_first_display
      EXPORTING
        is_variant      = gv_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_layo2
      CHANGING
        it_outtab       = gt_body2
        it_fieldcatalog = gt_fcat2.
  ELSE.

    PERFORM refresh_table.


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
  "입고자재문서번호 송장번호 창고코드
  PERFORM set_field_catalog USING : 'X' 'ICON'        'ICON'         'C' ' ',
                                    'X' 'AUFNR'       'ZC302MMT0006' 'C' ' ', " 구매오더번호
                                    'X' 'BPCODE'      'ZC302MMT0006' 'C' ' ', " BP
                                    'X' 'MATNR'       'ZC302MMT0006' 'C' 'X', " 자재코드
                                    ' ' 'MAKTX'       'ZC302MMT0006' ' ' 'X', " 자재명
                                    ' ' 'MENGE'       'ZC302MMT0006' ' ' ' ', " 최초수량
                                    ' ' 'MEINS'       'ZC302MMT0006' 'C' ' ', " 단위
                                    ' ' 'SCODE'       'ZC302MMT0006' 'C' ' ', " 창고코드
                                    ' ' 'XBLNR'       'ZC302MMT0006' 'C' ' ', " 송장번호
                                    ' ' 'HBLDAT'      'ZC302MMT0006' 'C' ' ', " 희망송장일자
                                    ' ' 'HBUDAT'      'ZC302MMT0006' 'C' ' ', " 희망입고일자
                                    ' ' 'BLDAT'       'ZC302MMT0006' 'C' ' ', " 송장일자
                                    ' ' 'BUDAT'       'ZC302MMT0006' 'C' ' '. " 입고일자

  PERFORM set_field_catalog2 USING : 'X' 'ICON'        'ICON'         'C' ' ',
                                     'X' 'AUFNR'       'ZC302MMT0006' 'C' ' ', " 구매오더번호
                                     'X' 'QINUM'       'ZC302MMT0006' 'C' ' ', " 품질검수번호
                                     'X' 'BPCODE'      'ZC302MMT0006' 'C' ' ', " BP
                                     'X' 'MATNR'       'ZC302MMT0006' 'C' 'X', " 자재코드
                                     ' ' 'MAKTX'       'ZC302MMT0006' ' ' 'X', " 자재명
                                     ' ' 'MENGE'       'ZC302MMT0006' ' ' ' ', " 최초수량
                                     ' ' 'QIMENGE'     'ZC302MMT0006' ' ' ' ', " 최종수량
                                     ' ' 'MEINS'       'ZC302MMT0006' 'C' ' ', " 단위
                                     ' ' 'ENAME'       'ZC302MMT0006' 'C' ' ', " 사원번호
                                     ' ' 'SCODE'       'ZC302MMT0006' 'C' ' ', " 창고코드
                                     ' ' 'XBLNR'       'ZC302MMT0006' 'C' ' ', " 송장번호
                                     ' ' 'HBLDAT'      'ZC302MMT0006' 'C' ' ', " 희망송장일자
                                     ' ' 'HPASTRTERM'  'ZC302MMT0006' 'C' ' ', " 희망검수일
                                     ' ' 'HBUDAT'      'ZC302MMT0006' 'C' ' ', " 희망입고일자
                                     ' ' 'MBLNR'       'ZC302MMT0006' 'C' ' ', " 자재문서번호
                                     ' ' 'BLDAT'       'ZC302MMT0006' 'C' ' ', " 송장일자
                                     ' ' 'PASTRTERM'   'ZC302MMT0006' 'C' ' ', " 검수일자
                                     ' ' 'BUDAT'       'ZC302MMT0006' 'C' ' '. " 입고일자




  PERFORM set_layout.


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
  gs_layo-grid_title  = '원자재 입고 리스트'.
  gs_layo-smalltitle  = abap_true.

  gs_layo2-zebra       = abap_true.
  gs_layo2-cwidth_opt  = 'A'.
  gs_layo2-sel_mode    = 'D'.
  gs_layo2-grid_title  = '원자재 품질검수 완료 리스트'.
  gs_layo2-smalltitle  = abap_true.

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

  gs_fcat-key       = pv_key.
  gs_fcat-fieldname = pv_field.
  gs_fcat-ref_table = pv_table.
  gs_fcat-just      = pv_just.
  gs_fcat-emphasize = pv_emph.

  CASE pv_field.
    WHEN 'MENGE'.
      gs_fcat-coltext     = '최초입고수량'.
      gs_fcat-qfieldname  = 'MEINS'.
    WHEN 'MAKTX'.
      gs_fcat-coltext = '자재명'.
    WHEN 'MEINS'.
      gs_fcat-coltext = '단위'.
    WHEN 'HBLDAT'.
      gs_fcat-coltext = '희망송장일자'.
    WHEN 'HPASTRTERM'.
      gs_fcat-coltext = '희망검수일'.
    WHEN 'HBUDAT'.
      gs_fcat-coltext = '희망입고일자'.
    WHEN 'BLDAT'.
      gs_fcat-coltext = '송장일자'.
    WHEN 'PASTRTERM'.
      gs_fcat-coltext = '검수일'.
    WHEN 'BUDAT'.
      gs_fcat-coltext = '입고일자'.
    WHEN 'ICON'.
      gs_fcat-coltext = '상태'.
    WHEN 'QIMENGE'.
      gs_fcat-coltext = '최종입고수량'.
    WHEN 'EMP'.
      gs_fcat-coltext = '검수자'.
    WHEN 'PASTRTERM'.
      gs_fcat-f4availabl = 'X'.
  ENDCASE.



  APPEND gs_fcat TO gt_fcat.
  CLEAR gs_fcat.

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

*-- Container
  CREATE OBJECT go_cont
    EXPORTING
      container_name = 'MAIN_CONT'.

*-- Split
  CREATE OBJECT go_split_cont
    EXPORTING
      parent  = go_cont
      rows    = 2
      columns = 1.

*-- Assign Container
  CALL METHOD go_split_cont->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_up_cont.

  CALL METHOD go_split_cont->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_down_cont.

*-- ALV
  CREATE OBJECT go_alv_grid
    EXPORTING
      i_parent = go_up_cont.

  CREATE OBJECT go_down_grid
    EXPORTING
      i_parent = go_down_cont.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_display_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_data .

  SELECT matnr maktx
    INTO CORRESPONDING FIELDS OF TABLE gt_material
    FROM zc302mt0007.

  SORT gt_material BY matnr ASCENDING.

*-- 원자재 입고 리스트
  LOOP AT gt_body INTO gs_body.
    gv_tabix = sy-tabix.

    READ TABLE gt_material INTO gs_material WITH KEY matnr = gs_body-matnr
                                            BINARY SEARCH.

    IF sy-subrc EQ 0.
      gs_body-maktx = gs_material-maktx.
    ENDIF.

    CASE gs_body-qstat.
      WHEN 'A'.
        gs_body-icon  = icon_led_green.
      WHEN 'B'.
        gs_body-icon  = icon_led_yellow.
    ENDCASE.

    MODIFY gt_body  FROM gs_body   INDEX gv_tabix  TRANSPORTING maktx icon.
  ENDLOOP.


*-- 원자재 품질검수 완료 리스트
  LOOP AT gt_body2 INTO gs_body2.
    gv_tabix = sy-tabix.

    READ TABLE gt_material INTO gs_material WITH KEY matnr = gs_body2-matnr
                                            BINARY SEARCH.

    IF sy-subrc EQ 0.
      gs_body2-maktx = gs_material-maktx.
    ENDIF.

    CASE gs_body2-qstat.
      WHEN 'A'.
        gs_body2-icon = icon_led_green.
      WHEN 'B'.
        gs_body2-icon = icon_led_yellow.
      WHEN 'C'.
        gs_body2-icon = icon_message_warning.
    ENDCASE.

    MODIFY gt_body2 FROM gs_body2 INDEX gv_tabix TRANSPORTING maktx icon.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form icon_total
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM icon_total .

*  IF gv_com_total IS INITIAL.
  CLEAR gt_body.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_body
    FROM zc302mmt0006
   WHERE qstat = 'A'.
  gv_com_total = lines( gt_body ).
*  ENDIF.

*  IF gv_incom_total IS INITIAL.
  CLEAR gt_body.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_body
    FROM zc302mmt0006
   WHERE qstat = 'B'.
  gv_incom_total = lines( gt_body ).
*  ENDIF.

*  IF gv_dissum_total is  not INITIAL.
  CLEAR gt_body.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_body
    FROM zc302mmt0006
   WHERE qstat = 'C'.
  gv_dissum_total = lines( gt_body ).
*  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM handle_toolbar  USING  po_object TYPE REF TO cl_alv_event_toolbar_set
                           pv_interactive.

  PERFORM set_left_tbar USING: ' '    ' '                            ' '  3  ' '        po_object,
                               'QCH' icon_inspection_characteristic  ' ' ' ' TEXT-i09    po_object.


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

  CLEAR gs_center_btn.
  gs_center_btn-function  = pv_func.
  gs_center_btn-icon      = pv_icon.
  gs_center_btn-quickinfo = pv_qinfo.
  gs_center_btn-butn_type = pv_type.
  gs_center_btn-text      = pv_text.
  APPEND gs_center_btn TO po_object->mt_toolbar.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form QC_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM qc_data .

ENDFORM.
*&---------------------------------------------------------------------*
*& Module SET_INIT_POPUP_PROCESS OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_init_popup_process OUTPUT.
  PERFORM display_popup_screen.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form display_popup_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_popup_screen .

  IF go_pop_cont IS NOT BOUND.

    PERFORM pfield_catalog.
    PERFORM popup_create_object.


  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form pfield_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM pfield_catalog .



ENDFORM.
*&---------------------------------------------------------------------*
*& Form popup_create_object
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM popup_create_object .
*-- Container
  CREATE OBJECT go_pop_cont
    EXPORTING
      container_name = 'POPUP_CONT'.

*-- ALV
  CREATE OBJECT go_alv_grid
    EXPORTING
      i_parent = go_pop_cont.


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
    WHEN 'QCH'.     " 검수진행
      PERFORM mqc_check USING gv_chrow.
    WHEN 'QIC'.     " 검수정보확인
      PERFORM mqc_info USING gv_chrow.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  EXIT_POPUP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_popup INPUT.

  LEAVE TO SCREEN 0.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form QCCAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM qccan .

  CLEAR: gv_dismenge, gv_qimenge, gv_okcode.

  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form input_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM input_data .

*  CLEAR : gv_total_menge.
  gv_total_menge = gv_dismenge + gv_qimenge.

  IF gv_total_menge > gv_menge.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.
  ELSEIF gv_total_menge <  gv_menge .
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
  ELSE.

    " 품질 검수 확인
    PERFORM ask_qc CHANGING gv_answer.

    IF gv_answer NE '1'.
      MESSAGE s001 WITH TEXT-e07 DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.

    IF gv_dismenge > 0.

      PERFORM qc_document_number. " 품질검수번호 채번
      PERFORM dispose_number.     " 폐기번호 채번
      PERFORM hpastrterm_data.    " 희망검수일, 희망송장일, 희망입고일 자재코드 별

      gs_body-icon      = icon_message_warning.
      gs_body-dismenge  = gv_dismenge.
      gs_body-qimenge   = gv_qimenge.
      gs_body-ename     = gs_employee-ename.
      gs_body-pastrterm = sy-datum.       " 검수일
      gs_body-emp_num   = gs_employee-emp_num.
      gs_body-qstat     = 'C'.            " 품질검수완료
      gs_body-status    = 'B'.            " 폐기상태 초기값 'B'
      gv_com_total     -= 1.
      gv_dissum_total  += 1.

      MODIFY gt_body FROM gs_body INDEX gv_tabix
                                  TRANSPORTING icon dismenge qimenge disreason hpastrterm hbldat hbudat
                                               emp_num ename pastrterm qinum disnum qstat status.

*-- 폐기 DB 저장
      PERFORM dis.

*-- 기존값 삭제 후 테이블에 리프레쉬
**      DELETE TABLE gt_body FROM gs_body.
*      DELETE gt_body WHERE aufnr = gs_body-aufnr
*                       AND matnr = gs_body-matnr.

    ELSE.

      PERFORM qc_document_number. " 품질검수번호 채번.
      PERFORM hpastrterm_data.    " 희망검수일 자재코드 별

      gs_body-icon      = icon_led_green.
      gs_body-qimenge   = gv_qimenge.
      gs_body-ename     = gs_employee-ename.
      gs_body-pastrterm = sy-datum.       "검수일
      gs_body-emp_num   = gs_employee-emp_num.
      gs_body-qstat     = 'A'.            "품질검수완료
      gv_com_total     -= 1.
      gv_incom_total   += 1.


      MODIFY gt_body FROM gs_body INDEX gv_tabix
                                  TRANSPORTING icon qimenge hpastrterm
                                               emp_num ename pastrterm qinum qstat.
    ENDIF.

*-- 구매오더 Item Setting & DB 저장
    PERFORM make_display_porder_i.
    PERFORM save_pur_order_i.

*-- 자재문서 Header 및 Item Setting & DB 저장
    PERFORM make_display_mat_docu.
    PERFORM save_mat_docu_h.
    PERFORM save_mat_docu_i.

*-- 상단 alv 행 데이터 삭제 후 하단 alv에 데이터 업데이트

    DELETE gt_body WHERE aufnr = gs_body-aufnr
                     AND matnr = gs_body-matnr.

    APPEND gs_body TO gt_body2.
    PERFORM refresh_table.



*-- 재고관리 Header Setting & DB 저장
    PERFORM make_display_mat_wareh.
    PERFORM save_mat_wareh.

*-- 품질검수 DB 저장 (상태를 A or C로 변경)
    PERFORM save_quality_insp.

    CLEAR: gv_okcode, gv_dismenge, gv_qimenge, gv_total_menge.
    LEAVE TO SCREEN 0.

  ENDIF.

  PERFORM refresh_table.

  CALL METHOD cl_gui_cfw=>set_new_ok_code
    EXPORTING
      new_code = 'ENTER'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ask_qc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GV_ANSWER
*&---------------------------------------------------------------------*
FORM ask_qc  CHANGING pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      text_question         = '해당 품목 검수를 완료하시겠습니까?'
      text_button_1         = 'YES'(001)
      icon_button_1         = 'ICON_OKAY'
      text_button_2         = 'NO'(002)
      icon_button_2         = 'ICON_CANCLE'
      default_button        = '1'
      display_cancel_button = 'X'
    IMPORTING
      answer                = pv_answer.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form QC_Document_number
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM qc_document_number .

  DATA : lv_prefix(2) VALUE 'IN'.

  gv_year   = sy-datum+2(2).
  gv_month  = sy-datum+4(2).
  gv_day    = sy-datum+6(2).

  IF gv_month < '10'.
    CONCATENATE gv_year(2) '0' gv_month gv_day INTO gv_year.
  ELSE.
    CONCATENATE gv_year(2) gv_month(2) gv_day INTO gv_year.
  ENDIF.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZC302QCIN'
    IMPORTING
      number      = gs_body-qinum.

  CONCATENATE lv_prefix gv_year gs_body-qinum INTO gs_body-qinum.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form dispose_number
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM dispose_number .

  DATA : lv_prefix(2) VALUE 'DN'.

  gv_year   = sy-datum+2(2).
  gv_month  = sy-datum+4(2).
  gv_day    = sy-datum+6(2).

  IF gv_month < '10'.
    CONCATENATE gv_year(2) '0' gv_month gv_day INTO gv_year.
  ELSE.
    CONCATENATE gv_year(2) gv_month(2) gv_day INTO gv_year.
  ENDIF.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZC302MMDN'
    IMPORTING
      number      = gs_body-disnum.

  CONCATENATE lv_prefix gv_year gs_body-disnum INTO gs_body-disnum.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form input_disreason
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM input_disreason .

  CASE gv_status.
    WHEN 'QCH'.
      READ TABLE gt_body INTO gs_body INDEX gv_tabix.

*      IF gs_body-disreason IS INITIAL.
      CALL SCREEN 102 STARTING AT 03 05.   " 팝업스크린 texteditor 입력
*      ENDIF.

    WHEN 'QIC'.   "품질검수가 완료된 항목을 조회할때 폐기사유가 있으면 103번 스크린 폐기사유가 없으면 오류메세지
      READ TABLE gt_body2 INTO gs_body2 INDEX gv_tabix.

      IF gs_body2-disreason IS NOT INITIAL.
        CALL SCREEN 103 STARTING AT 03 05.     " 팝업스크린 texteditor 출력
      ELSE.
        MESSAGE s001 WITH TEXT-i04 DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form hpastrterm_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM hpastrterm_data .

  SELECT matnr bpcode matlt
      INTO CORRESPONDING FIELDS OF TABLE gt_material
      FROM zc302mt0007.

  CLEAR gs_material.
  READ TABLE gt_material INTO gs_material WITH KEY matnr = gs_body-matnr.
*-- 희망 검수일
  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      date      = sy-datum
      days      = gs_material-matlt
      months    = '00'
      signum    = '+'
      years     = '00'
    IMPORTING
      calc_date = gs_body-hpastrterm.

*-- 희망입고일
  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      date      = sy-datum
      days      = gs_material-matlt
      months    = '00'
      signum    = '+'
      years     = '00'
    IMPORTING
      calc_date = gs_body-hbldat.

*-- 희망 송장일
  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      date      = sy-datum
      days      = gs_material-matlt
      months    = '00'
      signum    = '+'
      years     = '00'
    IMPORTING
      calc_date = gs_body-hbudat.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_DB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_quality_insp .

  DATA: ls_save TYPE zc302mmt0006.

  MOVE-CORRESPONDING gs_body TO ls_save.

  ls_save-aedat = sy-datum.
  ls_save-aezet = sy-uzeit.
  ls_save-aenam = sy-uname.

  UPDATE zc302mmt0006 SET qinum       = ls_save-qinum
                          dismenge    = ls_save-dismenge
                          qimenge     = ls_save-qimenge
                          disnum      = ls_save-disnum
                          ename       = ls_save-ename
                          emp_num     = ls_save-emp_num
                          pastrterm   = ls_save-pastrterm
                          hpastrterm  = ls_save-hpastrterm
                          qstat       = ls_save-qstat
                          disreason   = ls_save-disreason
                          mblnr       = ls_save-mblnr
                          aedat       = ls_save-aedat
                          aezet       = ls_save-aezet
                          aenam       = ls_save-aenam
                    WHERE aufnr       = ls_save-aufnr
                      AND plordco     = ls_save-plordco
                      AND matnr       = ls_save-matnr
                      AND xblnr       = ls_save-xblnr.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE s001 WITH TEXT-e08 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

  PERFORM refresh_table.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_pop_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_pop_display .

  IF go_text_cont IS NOT BOUND.
    PERFORM create_object_text.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_object_text
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_object_text .

*-- container
  CREATE OBJECT go_text_cont
    EXPORTING
      container_name = 'POP_CONT1'.

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
*& Form disreason_save
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM disreason_save .


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

  IF gt_content IS INITIAL.
    MESSAGE s001 WITH TEXT-e04 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  LOOP AT gt_content INTO gs_content.

    CONCATENATE gs_body-disreason gs_content-tdline
                cl_abap_char_utilities=>newline INTO gs_body-disreason.
  ENDLOOP.

  MODIFY gt_body FROM gs_body INDEX gv_tabix
                              TRANSPORTING disreason.

  CALL METHOD go_text_edit->delete_text.

  PERFORM exit_popup.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_pop_display3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_pop_display3 .

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
      toolbar_mode = go_text_edit2->false.  " true 대신 1로, false 대신 0으로 넣어도 된다.

*-- Set Read-Only Mode
  " text edit의 값을 가져오기 위해 create object에서 read only mode를 false로 가져오고 다름 set text에서 값을 정상적으로 가져온 후
  " read only mode = go_text_edit2->true로 설정해서 읽기만 가능하게 해준다.

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

*  IF gt_body IS NOT INITIAL.

  CLEAR gs_body.
  READ TABLE gt_body INTO gs_body INDEX gv_tabix.

*-- 줄바꿈 기호를 기준으로 단어를 분리
  CLEAR : gt_content.
  SPLIT gs_body-disreason AT cl_abap_char_utilities=>newline " 줄바꿈 ( AT 뒤에는 기호 지정 -> 기호에 따라 SPLIT으로 단어 분리 )
                                      INTO TABLE gt_content.

*-- 자동 들여쓰기
  CALL METHOD go_text_edit->set_autoindent_mode
    EXPORTING
      auto_indent            = 1
    EXCEPTIONS
      error_cntl_call_method = 1
      OTHERS                 = 2.

*-- 기존 작성된 내용 삭제
  CALL METHOD go_text_edit->delete_text.


*-- Set text to Editor
  CALL METHOD go_text_edit->set_selected_text_as_r3table
    EXPORTING
      table           = gt_content
    EXCEPTIONS
      error_dp        = 1
      error_dp_create = 2
      OTHERS          = 3.

*cl_demo_output=>display( gt_content ).
*-- Set Read-Only Mode
  IF gs_body-qstat EQ 'A'.

    CALL METHOD go_text_edit->set_readonly_mode
      EXPORTING
        readonly_mode = go_text_edit->true.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_final_quan
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_final_quan .



  gv_qimenge = gv_menge - gv_dismenge.

  IF gv_dismenge > gv_menge.
    MESSAGE i001 WITH TEXT-i01 DISPLAY LIKE 'E'.
    gv_qimenge = space.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_aufnr_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_aufnr_f4 .

  DATA : lt_return TYPE TABLE OF ddshretval WITH HEADER LINE.

  SELECT DISTINCT aufnr
    INTO CORRESPONDING FIELDS OF TABLE gt_polow
    FROM zc302mmt0006.

  REFRESH lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'AUFNR'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GV_PO_LOW'
      window_title    = '구매오더번호'
      value_org       = 'S'
    TABLES
      value_tab       = gt_polow
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_aufnr_f4_2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_aufnr_f4_2 .
  DATA : lt_return TYPE TABLE OF ddshretval WITH HEADER LINE.

  SELECT DISTINCT aufnr
    INTO CORRESPONDING FIELDS OF TABLE gt_polow
    FROM zc302mmt0006.


  REFRESH lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'AUFNR'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GV_PO_HIGH'
      window_title    = '구매오더번호'
      value_org       = 'S'
    TABLES
      value_tab       = gt_polow
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_error_message
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_error_message .

  MESSAGE i001 WITH TEXT-i02 DISPLAY LIKE 'E'.
  EXIT.
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

  PERFORM refresh_up_table.
  PERFORM refresh_down_table.

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
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_field_catalog2  USING pv_key pv_field pv_table pv_just pv_emph.

  gs_fcat2-key       = pv_key.
  gs_fcat2-fieldname = pv_field.
  gs_fcat2-ref_table = pv_table.
  gs_fcat2-just      = pv_just.
  gs_fcat2-emphasize = pv_emph.

  CASE pv_field.
    WHEN 'MENGE'.
      gs_fcat2-coltext     = '최초입고수량'.
      gs_fcat2-qfieldname  = 'MEINS'.
    WHEN 'MAKTX'.
      gs_fcat2-coltext = '자재명'.
    WHEN 'MEINS'.
      gs_fcat2-coltext = '단위'.
    WHEN 'HBLDAT'.
      gs_fcat2-coltext = '희망송장일자'.
    WHEN 'HPASTRTERM'.
      gs_fcat2-coltext = '희망검수일'.
    WHEN 'HBUDAT'.
      gs_fcat2-coltext = '희망입고일자'.
    WHEN 'BLDAT'.
      gs_fcat2-coltext = '송장일자'.
    WHEN 'PASTRTERM'.
      gs_fcat2-coltext = '검수일'.
    WHEN 'BUDAT'.
      gs_fcat2-coltext = '입고일자'.
    WHEN 'ICON'.
      gs_fcat2-coltext = '상태'.
    WHEN 'QIMENGE'.
      gs_fcat2-coltext     = '최종입고수량'.
      gs_fcat2-qfieldname  = 'MEINS'.
    WHEN 'EMP'.
      gs_fcat2-coltext = '검수자'.
    WHEN 'PASTRTERM'.
      gs_fcat2-f4availabl = 'X'.
  ENDCASE.



  APPEND gs_fcat2 TO gt_fcat2.
  CLEAR gs_fcat2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_toolbar2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM handle_toolbar2  USING po_object TYPE REF TO cl_alv_event_toolbar_set
                           pv_interactive.

  PERFORM set_left_tbar2 USING: ' '    ' '                           ' '  3  ' '        po_object,
                               'QIC' icon_inspection_characteristic  ' ' ' ' TEXT-i10    po_object.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_left_tbar2
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
FORM set_left_tbar2  USING   pv_func pv_icon pv_qinfo pv_type pv_text
                             po_object TYPE REF TO cl_alv_event_toolbar_set.

  CLEAR gs_center_btn.
  gs_qc_btn-function  = pv_func.
  gs_qc_btn-icon      = pv_icon.
  gs_qc_btn-quickinfo = pv_qinfo.
  gs_qc_btn-butn_type = pv_type.
  gs_qc_btn-text      = pv_text.
  APPEND gs_qc_btn TO po_object->mt_toolbar.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form mqc_info
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_CHROW
*&---------------------------------------------------------------------*
FORM mqc_info  USING    pv_chrow.

  DATA : lt_index TYPE lvc_t_row,
         ls_index TYPE lvc_s_row.

  CLEAR : lt_index, ls_index, gv_tabix.

  CALL METHOD go_down_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_index.

  IF lines( lt_index ) > 1.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'.
    EXIT.
  ELSEIF lines( lt_index ) < 1.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'.
    EXIT.
  ELSE.
    CLEAR : ls_index.
    ls_index = VALUE #( lt_index[ 1 ] OPTIONAL ).
    gv_tabix = ls_index-index.

    READ TABLE gt_body2 INTO gs_body2 INDEX gv_tabix. " 첫번째 선택된 행

    IF sy-subrc = 0.
      gv_qinum      = gs_body2-qinum.     " 품질검수번호
      gv_po_num     = gs_body2-aufnr.     " 구매오더번호
      gv_income_num = gs_body2-xblnr.     " 송장번호
      gv_menge      = gs_body2-menge.     " 입고수량
      gv_matnr      = gs_body2-matnr.     " 자재코드
      gv_maktx      = gs_body2-maktx.     " 자재명
      gv_meins      = gs_body2-meins.     " 단위
      gv_dismenge   = gs_body2-dismenge.  " 폐기수량
      gv_qimenge    = gs_body2-qimenge.   " 최종입고수량
      gv_disreason  = gs_body2-disreason. " 폐기사유
*-- Screen 101에서 사용되는 변수
      gv_qc_date    = gs_body2-pastrterm. " 검수일
      gv_emp2       = gs_body2-ename.     " 사원이름
      gv_emp_num2   = gs_body2-emp_num.   " 사원번호
*-- Screen 103에서 사용되는 변수
      gv_emp        = gs_body2-ename.     " 사원이름
      gv_emp_num    = gs_body2-emp_num.   " 사원번호
      gv_pastrterm  = gs_body2-pastrterm. " 검수일


    ENDIF.
  ENDIF.

  gv_status = 'QIC'.

  CALL SCREEN 101 STARTING AT 03 05.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form dis
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM dis .

  DATA : ls_save TYPE zc302mmt0001.

  MOVE-CORRESPONDING gs_body TO ls_save.

  IF ls_save-erdat IS INITIAL.
    ls_save-erdat = sy-datum.
    ls_save-erzet = sy-uzeit.
    ls_save-ernam = sy-uname.
  ELSE.
    ls_save-aedat = sy-datum.
    ls_save-aezet = sy-uzeit.
    ls_save-aenam = sy-uname.
  ENDIF.

  MODIFY zc302mmt0001 FROM ls_save.

  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
    PERFORM refresh_table.
*    MESSAGE s001 WITH TEXT-i03.
  ELSE.
    MESSAGE s001 WITH TEXT-e08 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form Material_document
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_mat_docu .

  _clear gt_mdh gs_mdh.
  _clear gt_mdi gs_mdi.

  DATA : lv_prefix(2) VALUE 'MD'.

*  gv_year   = sy-datum+2(2).
*  gv_month  = sy-datum+4(2).
*  gv_day    = sy-datum+6(2).
*
*  IF gv_month < '10'.
*    CONCATENATE gv_year(2) '0' gv_month gv_day INTO gv_year.
*  ELSE.
*    CONCATENATE gv_year(2) gv_month(2) gv_day INTO gv_year.
*  ENDIF.

  gs_mdh-mjahr    = sy-datum+0(4).
  gs_mdh-movetype = 'A'.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZC321MMMD'
    IMPORTING
      number      = gs_body-mblnr.

  CONCATENATE lv_prefix gs_body-mblnr+2(8) INTO gs_body-mblnr.

*-- 자재문서 Header 데이터 추가
  MOVE-CORRESPONDING gs_body TO gs_mdh.
  gs_mdh-mjahr    = sy-datum(4).
  gs_mdh-movetype = 'A'.

*-- 자재문서 Item 데이터 추가
  MOVE-CORRESPONDING gs_body TO gs_mdi.
  gs_mdi-mjahr    = sy-datum(4).
  gs_mdi-movetype = 'A'.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form material_warehouse
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_mat_wareh .

  " 자재코드가 같은 재고관리 데이터 가져온다.
  READ TABLE gt_mwh INTO gs_mwh WITH KEY matnr = gs_body-matnr.

  " 현재재고에 최종입고량을 더해준다.
  gs_mwh-h_rtptqua += gs_body-qimenge.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form iid
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_porder_i .
  _clear gt_po gs_po.


  READ TABLE gt_body INTO gs_body WITH KEY aufnr   = gs_po-aufnr
                                           matnr   = gs_po-matnr
                                           plordco = gs_po-plordco.

  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF gs_po
    FROM zc302mmt0008
   WHERE aufnr   = gs_body-aufnr
     AND matnr   = gs_body-matnr
     AND plordco = gs_body-plordco.

  IF sy-subrc EQ 0.
    gs_po-lfdat = gs_body-budat.
  ENDIF.

  gs_po-devsta = 'A'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_inv_mange_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_inv_mange_data .

  CLEAR gt_mwh.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_mwh
    FROM zc302mmt0013.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form no_disreason
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM no_disreason .
  IF gv_dismenge EQ 0.

    LOOP AT SCREEN.
      CASE gv_okcode.
        WHEN 'DISR'.
          screen-active = 0.
      ENDCASE.
    ENDLOOP.

    MODIFY SCREEN.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISREASON_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM disreason_input .
  IF gv_menge EQ gv_qimenge.
    LOOP AT SCREEN.
      CASE screen-group1.
        WHEN 'DIS'.
          screen-input = 0.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.

*-- 원자재 품질 검수에서 폐기 수량이 없으면 폐기사유 입력불가
  ELSEIF gv_dismenge EQ 0.
    LOOP AT SCREEN.
      CASE screen-group1.
        WHEN 'DIS'.
          screen-input = 0.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_pur_order_i
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_pur_order_i .

  DATA: ls_save TYPE zc302mmt0008.

  MOVE-CORRESPONDING gs_po TO ls_save.

  IF ls_save-erdat IS INITIAL.
    ls_save-erdat = sy-datum.
    ls_save-erzet = sy-uzeit.
    ls_save-ernam = sy-uname.
  ELSE.
    ls_save-aedat = sy-datum.
    ls_save-aezet = sy-uzeit.
    ls_save-aenam = sy-uname.
  ENDIF.

  MODIFY zc302mmt0008 FROM ls_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
    MESSAGE s001 WITH TEXT-e08 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_mat_docu
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_mat_docu_h .

  DATA: ls_save TYPE zc302mmt0011.

  MOVE-CORRESPONDING gs_mdh TO ls_save.

  IF ls_save-erdat IS INITIAL.
    ls_save-erdat = sy-datum.
    ls_save-erzet = sy-uzeit.
    ls_save-ernam = sy-uname.
  ELSE.
    ls_save-aedat = sy-datum.
    ls_save-aezet = sy-uzeit.
    ls_save-aenam = sy-uname.
  ENDIF.

  MODIFY zc302mmt0011 FROM ls_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
    MESSAGE s001 WITH TEXT-e08 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_mat_docu_i
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_mat_docu_i .

  DATA: ls_save TYPE zc302mmt0012.

  MOVE-CORRESPONDING gs_mdi TO ls_save.

  IF ls_save-erdat IS INITIAL.
    ls_save-erdat = sy-datum.
    ls_save-erzet = sy-uzeit.
    ls_save-ernam = sy-uname.
  ELSE.
    ls_save-aedat = sy-datum.
    ls_save-aezet = sy-uzeit.
    ls_save-aenam = sy-uname.
  ENDIF.

  MODIFY zc302mmt0012 FROM ls_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
    MESSAGE s001 WITH TEXT-e08 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_mat_wareh
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_mat_wareh .

  DATA: ls_save TYPE zc302mmt0013.

  MOVE-CORRESPONDING gs_mwh TO ls_save.

  IF ls_save-erdat IS INITIAL.
    ls_save-erdat = sy-datum.
    ls_save-erzet = sy-uzeit.
    ls_save-ernam = sy-uname.
  ELSE.
    ls_save-aedat = sy-datum.
    ls_save-aezet = sy-uzeit.
    ls_save-aenam = sy-uname.
  ENDIF.

  MODIFY zc302mmt0013 FROM ls_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
    MESSAGE s001 WITH TEXT-e08 DISPLAY LIKE 'E'.
  ENDIF.

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

  CALL METHOD go_alv_grid->refresh_table_display
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
*& Form exit_popup
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exit_popup .

  CALL METHOD : go_text_cont->free,
                go_text_edit->free.

  FREE : go_text_cont, go_text_edit.

  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_text2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_text2 .

  CLEAR gs_body2.
  READ TABLE gt_body2 INTO gs_body2 INDEX gv_tabix.

*-- 줄바꿈 기호를 기준으로 단어를 분리
  CLEAR : gt_content.
  SPLIT gs_body2-disreason AT cl_abap_char_utilities=>newline " 줄바꿈 ( AT 뒤에는 기호 지정 -> 기호에 따라 SPLIT으로 단어 분리 )
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

*cl_demo_output=>display( gt_content ).
*-- Set Read-Only Mode
  CALL METHOD go_text_edit2->set_readonly_mode
    EXPORTING
      readonly_mode = go_text_edit2->true.

ENDFORM.
