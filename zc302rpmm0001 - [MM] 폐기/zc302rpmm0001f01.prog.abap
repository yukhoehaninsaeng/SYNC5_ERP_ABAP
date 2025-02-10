
*&---------------------------------------------------------------------*
*& Include          ZC302RPMM0001F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data_base
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data_base.

  CLEAR gt_discard.
  CASE gv_mode.
*-- 원자재
    WHEN 'RM'.
     SELECT scode matnr maktx qinum  disreason
            dismenge meins budat  emp_num disnum bpcode waers
        INTO CORRESPONDING FIELDS OF TABLE gt_discard
        FROM zc302mmt0001
       WHERE status = 'B'
         AND matnr LIKE 'RM%'.

*-- 반제품
    WHEN 'SP'.
     SELECT scode matnr maktx qinum  disreason
            dismenge meins budat  emp_num disnum bpcode waers
        INTO CORRESPONDING FIELDS OF TABLE gt_discard
        FROM zc302mmt0001
       WHERE status = 'B'
         AND matnr LIKE 'SP%'.

*-- 완제품
    WHEN 'CP'.
     SELECT scode matnr maktx qinum  disreason
            dismenge meins budat  emp_num disnum bpcode waers
        INTO CORRESPONDING FIELDS OF TABLE gt_discard
        FROM zc302mmt0001
       WHERE status = 'B'
         AND matnr LIKE 'CP%'.

*-- 전체
   WHEN OTHERS.
     SELECT scode matnr maktx qinum  disreason
            dismenge meins budat  emp_num disnum bpcode waers
        INTO CORRESPONDING FIELDS OF TABLE gt_discard
        FROM zc302mmt0001
       WHERE status = 'B'.

  ENDCASE.

*-- 조회시 건수 카운팅
  gv_count = lines( gt_discard ).
  MESSAGE s001 WITH gv_count TEXT-s02.

*-- bottom grid
  PERFORM get_data_base_bottom.

*-- 폐기처리 상태 표시
  PERFORM status_text.

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

*-- top alv
    CLEAR : gt_fcat, gs_fcat.

    PERFORM set_field_catalog USING : 'X' 'SCODE'     'ZC302MMT0001' 'C' ' ',
                                      'X' 'MATNR'     'ZC302MMT0001' 'C' ' ',
                                      ' ' 'MAKTX'     'ZC302MMT0001' ' ' 'X',
                                      ' ' 'DISREASON_T' 'ZC302MMT0001' 'C' ' ',
*                                      ' ' 'DISREASON' 'ZC302MMT0001' 'C' ' ',
                                      ' ' 'DISMENGE'  'ZC302MMT0001' 'C' ' ',
                                      ' ' 'MEINS'     'ZC302MMT0001' 'C' ' ',
                                      ' ' 'EMP_NUM'   'ZC302MMT0001' 'C' ' ',
                                      ' ' 'BUDAT'     'ZC302MMT0001' 'C' ' ',
*                                      ' ' 'DISNUM'    'ZC302MMT0001' 'C' ' ',
                                      ' ' 'QINUM'     'ZC302MMT0001' 'C' ' '.

*-- bottom alv
    CLEAR : gt_bfcat, gs_bfcat.
    PERFORM set_bottom_field_catalog USING : 'X' 'DISNUM'      'ZC302MMT0001' 'C' '',
                                             'X' 'SCODE'       'ZC302MMT0001' 'C' '',
                                             'X' 'MATNR'       'ZC302MMT0001' 'C' '',
                                             ' ' 'MAKTX'       'ZC302MMT0001' ' ' 'X',
*                                            ' ' 'DISREASON'   'ZC302MMT0001' 'C' '',
                                             ' ' 'DISMENGE'    'ZC302MMT0001' 'C' '',
                                             ' ' 'MEINS'       'ZC302MMT0001' 'C' '',
*                                            ' ' 'EMP_NUM'     'ZC302MMT0001' 'C' '',
                                             ' ' 'DISCOST'     'ZC302MMT0001' 'C' '',
                                             ' ' 'WAERS'       'ZC302MMT0001' 'C' '',
*                                            ' ' 'STATUS'      'ZC302MMT0001' 'C' '',
                                             ' ' 'BUDAT'       'ZC302MMT0001' 'C' '',
                                             ' ' 'QINUM'       'ZC302MMT0001' 'C' ''.

    PERFORM create_object.

    SET HANDLER : lcl_event_handler=>top_of_page   FOR go_top_grid,
                  lcl_event_handler=>toolbar       FOR go_top_grid,
                  lcl_event_handler=>user_command  FOR go_top_grid,
                  lcl_event_handler=>button_click  FOR go_top_grid.

    gv_variant-report = sy-repid.

    PERFORM set_layout.

*-- top grid
    gv_variant-handle = 'ALV1'.
    CALL METHOD go_top_grid->set_table_for_first_display
      EXPORTING
        is_variant                    = gv_variant
        i_save                        = 'A'
        i_default                     = 'X'
        is_layout                     = gs_layout
      CHANGING
        it_outtab                     = gt_discard
        it_fieldcatalog               = gt_fcat.

*-- bottom grid
    gv_variant-handle = 'ALV2'.
    CALL METHOD go_bottom_grid->set_table_for_first_display
      EXPORTING
        i_save                        = 'A'
        i_default                     = 'X'
        is_layout                     = gs_blayout
      CHANGING
        it_outtab                     = gt_discard_bottom
        it_fieldcatalog               = gt_bfcat.


*-- top of page
    CALL METHOD go_dyndoc_id->initialize_document
      EXPORTING
        background_color = cl_dd_area=>col_textarea.

    CALL METHOD go_top_grid->list_processing_events
      EXPORTING
        i_event_name = 'TOP_OF_PAGE'
        i_dyndoc_id  = go_dyndoc_id.


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

  gs_fcat-key       = pv_key.
  gs_fcat-fieldname = pv_field.
  gs_fcat-ref_table = pv_table.
  gs_fcat-just      = pv_just.
  gs_fcat-emphasize = pv_emph.

  CASE pv_field.
    WHEN 'DISREASON_T'.
      gs_fcat-coltext = '폐기사유'.
    WHEN 'DISMENGE'.
      gs_fcat-qfieldname = 'MEINS'.
    WHEN 'DISCOST'.
      gs_fcat-cfieldname = 'WAERS'.
    WHEN 'MAKTX'.
      gs_fcat-coltext    = '자재명'.
    WHEN 'MEINS'.
      gs_fcat-coltext    = '단위'.
    WHEN 'BUDAT'.
      gs_fcat-coltext    = '일자'.
    WHEN 'EMP_NUM'.
      gs_fcat-coltext    = '사원번호'.
  ENDCASE.

  APPEND gs_fcat TO gt_fcat.
  CLEAR gs_fcat.

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

  gs_layout-zebra      = 'X'.
  gs_layout-cwidth_opt = 'A'.
  gs_layout-sel_mode   = 'D'.
  gs_layout-grid_title = '폐기 신청 리스트'.
  gs_layout-smalltitle = abap_true.
  gs_layout-stylefname = 'CELLTAB'.

  gs_blayout-zebra      = 'X'.
  gs_blayout-cwidth_opt = 'A'.
  gs_blayout-sel_mode   = 'D'.
  gs_blayout-grid_title = '폐기 완료 리스트'.
  gs_blayout-smalltitle = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_object .

*-- Top-of-page : Install Docking Container for Top-of-page(!!맨위에!! 생성)
  CREATE OBJECT go_top_container
    EXPORTING
      repid     = sy-cprog
      dynnr     = sy-dynnr
      side      = go_top_container->dock_at_top
      extension = 30. " Top of page 높이

 CREATE OBJECT go_container
  EXPORTING
    container_name  = 'MAIN_CONT'.

  CREATE OBJECT go_splitter_cont "spliter
    EXPORTING
      parent  = go_container
      rows    = 2
      columns = 1.

  CALL METHOD go_splitter_cont->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_top_cont.

  CALL METHOD go_splitter_cont->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_bottom_cont.

  CREATE OBJECT go_top_grid
    EXPORTING
      i_parent = go_top_cont.

  CREATE OBJECT go_bottom_grid
    EXPORTING
      i_parent = go_bottom_cont.

*-- Top-of-page : Create TOP-Document(!!맨 마지막에!! 작성)
  CREATE OBJECT go_dyndoc_id
    EXPORTING
      style = 'ALV_GRID'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form discard
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM discard .
  DATA : lv_answer(1).

  PERFORM answer CHANGING lv_answer.

*- -폐기 신청 버튼 클릭 유무에 따른 로직
  IF lv_answer = '1'.
    PERFORM discard_logic.
  ELSEIF  lv_answer = '2'.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_screen .

  LOOP AT SCREEN.
**********************************************************************
* 라디오버튼에 따른 데이터 조회
**********************************************************************
    CASE 'X'.
*-- 원자재
      WHEN pa_rd02.
        gv_mode = 'RM'.
*-- 반제품
      WHEN pa_rd03.
        gv_mode = 'SP'.
*-- 완제품
      WHEN pa_rd04.
        gv_mode = 'CP'.
*-- 전체 조회
      WHEN OTHERS.
        gv_mode = 'ALL'.
    ENDCASE.

    MODIFY SCREEN.
  ENDLOOP.

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
*-- 자재분류 설정
  IF pa_rd01 = 'X'.
    PERFORM add_row USING lr_dd_table col_field col_value '자재분류' '전체'.
  ELSEIF pa_rd02 = 'X'.
    PERFORM add_row USING lr_dd_table col_field col_value '자재분류' '원자재'.
  ELSEIF pa_rd03 = 'X'.
    PERFORM add_row USING lr_dd_table col_field col_value '자재분류' '반제품'.
  ELSE.
    PERFORM add_row USING lr_dd_table col_field col_value '자재분류' '완제품'.
  ENDIF.

  PERFORM set_top_of_page.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_row
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
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
*&---------------------------------------------------------------------*
*& Form answer
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ANSWER
*&---------------------------------------------------------------------*
FORM answer  CHANGING    pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
     text_question          = '폐기처리하시겠습니까?'
      text_button_1         = '네'(001)
      icon_button_1         = 'ICON_OKAY'
      text_button_2         = '아니요'(002)
      icon_button_2         = 'ICON_CANCEL'
      default_button        = '1'
      display_cancel_button = ''
   IMPORTING
     answer                 = pv_answer.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_bottom_field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_bottom_field_catalog  USING pv_key pv_field pv_table pv_just pv_emph.

  gs_bfcat-key       = pv_key.
  gs_bfcat-fieldname = pv_field.
  gs_bfcat-ref_table = pv_table.
  gs_bfcat-just      = pv_just.
  gs_bfcat-emphasize = pv_emph.

  CASE pv_field.
    WHEN 'DISMENGE'.
      gs_bfcat-qfieldname = 'MEINS'.
    WHEN 'DISCOST'.
      gs_bfcat-cfieldname = 'WAERS'.
    WHEN 'MEINS'.
      gs_bfcat-coltext    = '단위'.
    WHEN 'WAERS'.
      gs_bfcat-coltext    = '통화'.
    WHEN 'BUDAT'.
      gs_bfcat-coltext    = '일자'.
    WHEN 'EMP_NUM'.
      gs_bfcat-coltext    = '사원번호'.
  ENDCASE.

  APPEND gs_bfcat TO gt_bfcat.

  CLEAR gs_bfcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_base_bottom
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data_base_bottom .

*-- 폐기처리 완료 조회
  CLEAR gt_discard_bottom.

  CASE gv_mode.
*-- 원자재
    WHEN 'RM'.
       SELECT disnum scode matnr qinum maktx disreason
              dismenge meins budat emp_num discost bpcode waers status
         INTO CORRESPONDING FIELDS OF TABLE gt_discard_bottom
         FROM zc302mmt0001
        WHERE matnr LIKE 'RM%'
          AND status = 'A'.
*-- 반제품
    WHEN 'SP'.
       SELECT disnum scode matnr qinum maktx disreason
              dismenge meins budat emp_num discost bpcode waers status
         INTO CORRESPONDING FIELDS OF TABLE gt_discard_bottom
         FROM zc302mmt0001
        WHERE matnr LIKE 'SP%'
          AND status = 'A'.
*-- 완제품
    WHEN 'CP'.
     SELECT disnum scode matnr qinum maktx disreason
            dismenge meins budat emp_num discost bpcode waers status
        INTO CORRESPONDING FIELDS OF TABLE gt_discard_bottom
        FROM zc302mmt0001
       WHERE matnr LIKE 'CP%'
         AND status = 'A'.
*-- 전체
   WHEN OTHERS.
     SELECT disnum scode matnr qinum maktx disreason
            dismenge meins budat emp_num discost bpcode waers status
        INTO CORRESPONDING FIELDS OF TABLE gt_discard_bottom
        FROM zc302mmt0001
       WHERE status = 'A'.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form discard_logic
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM discard_logic .

  DATA : lt_index TYPE lvc_t_row, "ALV 선택라인 저장 인터널테이블
         ls_index TYPE lvc_s_row,
         lt_save  TYPE TABLE OF zc302mmt0001,
         ls_save  TYPE zc302mmt0001,
         lv_disreason TYPE zc302mmt0001-disreason,
         lv_bpcode TYPE zc302mmt0001-bpcode.

  CALL METHOD go_top_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_index.

*-- 다중 선택을 위한 SORT
  SORT lt_index BY index DESCENDING.

*-- 폐기 완료 되면 폐기테이블에 쌓아주기
  LOOP AT lt_index INTO ls_index.

*-- 체크 된 index값 가져오기
    READ TABLE gt_discard INTO gs_discard INDEX ls_index-index.

*-- bottom grid로 append해주기
*    lv_disreason = gs_discard_bottom-disreason.
*    lv_bpcode = gs_discard_bottom-bpcode.
    MOVE-CORRESPONDING gs_discard TO gs_discard_bottom.
    gs_discard_bottom-disreason = gs_discard-disreason.
    gs_discard_bottom-bpcode = gs_discard-bpcode.
*    gs_discard_bottom-bpcode = lv_bpcode.
    gs_discard_bottom-budat2    = sy-datum.              " 폐기처리 일자
    gs_discard_bottom-discost   = gs_discard_bottom-dismenge * 1. " 폐기비용 건당 100원
    gs_discard_bottom-waers     = 'KRW'.                 " 통화
    gs_discard_bottom-status    = 'A'.                   " 상태

*-- TIME STAMP
    ls_save-aedat = sy-datum.
    ls_save-aezet = sy-uzeit.
    ls_save-aenam = sy-uname.

    APPEND gs_discard_bottom TO gt_discard_bottom.

*-- select 된거 top grid 리스트에서 지우기
    DELETE gt_discard INDEX ls_index-index.

    MOVE-CORRESPONDING gs_discard_bottom TO ls_save.

*-- append된 bottom 테이블의 상태값을 폐기 테이블에 저장
    MODIFY zc302mmt0001 FROM ls_save.

  ENDLOOP.

*-- 상태 표시
    PERFORM status_text.

*-- 저장로직
  IF sy-subrc = 0.
    MESSAGE s001 WITH TEXT-s01.
    COMMIT WORK AND WAIT.
*-- refresh table
    PERFORM refresh_table_top.
    PERFORM refresh_table_bottom.
  ELSE.
   MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
   ROLLBACK WORK.
 ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_table_top
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_table_top .

  DATA : ls_stbl TYPE lvc_s_stbl.

  ls_stbl-row = abap_true.
  ls_stbl-col = abap_true.

  CALL METHOD go_top_grid->refresh_table_display
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
*& Form status_text
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM status_text .

  LOOP AT gt_discard_bottom INTO gs_discard_bottom.
    gv_tabix = sy-tabix.

   IF gs_discard_bottom-status      = 'A'.
      gs_discard_bottom-status_text = '완료'.
   ENDIF.

   MODIFY gt_discard_bottom FROM gs_discard_bottom INDEX gv_tabix TRANSPORTING status_text.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&      --> E_INTERACTIVE
*&---------------------------------------------------------------------*
FORM handle_toolbar  USING   po_object TYPE REF TO cl_alv_event_toolbar_set
                              pv_interactive.

*-- 구분선
  CLEAR gs_button.
  gs_button-butn_type = 3.
  APPEND gs_button TO po_object->mt_toolbar.

*-- 폐기버튼
  CLEAR gs_button.
  gs_button-function = 'DCD'.
  gs_button-icon     = icon_delete.
  gs_button-text     = TEXT-b01.
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
  DATA : lt_index  TYPE lvc_t_row,
         ls_index  TYPE lvc_s_row.

  CALL METHOD go_top_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_index.

  CASE pv_ucomm.
    WHEN 'DCD'.
      IF lines( lt_index ) < 1.
        MESSAGE s001 WITH TEXT-s03 DISPLAY LIKE 'E'.
        EXIT.
      ELSE.
        PERFORM discard.
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_display_body
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_body .

  DATA : ls_style TYPE lvc_s_styl.

  LOOP AT gt_discard INTO gs_discard.

    gv_tabix = sy-tabix.
    IF gs_discard-disreason IS NOT INITIAL.
      CLEAR ls_style.
      ls_style-fieldname = 'DISREASON_T'.
      ls_style-style     = cl_gui_alv_grid=>mc_style_button.
      INSERT ls_style INTO TABLE gs_discard-celltab.
      gs_discard-disreason_t = '조회'.

    ENDIF.

    MODIFY gt_discard FROM gs_discard INDEX gv_tabix TRANSPORTING disreason_t celltab.

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
FORM handle_button_click  USING ps_col_id TYPE lvc_s_col
                                ps_row_no TYPE lvc_s_roid.

  DATA : ls_discard LIKE gs_discard.

  READ TABLE gt_discard INTO gs_discard INDEX ps_row_no-row_id.

  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF ls_discard
    FROM zc302MMT0001
   WHERE disnum = gs_discard-disnum.

    gv_disreason = ls_discard-disreason.

*-- 팝업
    CALL SCREEN 101 STARTING AT 65 05.


ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_0101 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0101 OUTPUT.
 SET PF-STATUS 'MENU101'.
 SET TITLEBAR 'TITLE101'.
ENDMODULE.
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
      container_name = 'POP_CONT'.

*-- Text Editor
  CREATE OBJECT go_text_edit
    EXPORTING
      wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
      parent        = go_text_cont.

*-- Edit toolbar
  CALL METHOD go_text_edit->set_toolbar_mode
    EXPORTING
      toolbar_mode = go_text_edit->false.

*-- Set Read-Only Mode
  CALL METHOD go_text_edit->set_readonly_mode
    EXPORTING
      readonly_mode = go_text_edit->false.

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
  SPLIT gv_disreason AT cl_abap_char_utilities=>newline " 줄바꿈 ( AT 뒤에는 기호 지정 -> 기호에 따라 SPLIT으로 단어 분리 )
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

*-- Set Read-Only Mode
  CALL METHOD go_text_edit->set_readonly_mode
    EXPORTING
      readonly_mode = go_text_edit->true.


ENDFORM.
