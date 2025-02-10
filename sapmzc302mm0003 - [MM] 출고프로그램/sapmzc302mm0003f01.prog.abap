
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

*-- top
    CLEAR : gt_tfcat, gs_tfcat.
    PERFORM set_up_field_catalog USING : 'X' 'MATNR'     'ZC302MMT0013' 'C' ' ',
                                         ' ' 'MAKTX'     'ZC302MMT0013' ' ' 'X',
                                         ' ' 'H_RTPTQUA' 'ZC302MMT0013' 'C' ' ',
                                         ' ' 'MEINS'     'ZC302MMT0013' 'C' ' '.

*-- bottom
    CLEAR : gt_bfcat, gs_bfcat.
    PERFORM set_bottom_field_catalog USING: 'X' 'MATNR'     'ZC302MMT0013' 'C' ' ',
                                            ' ' 'MAKTX'     'ZC302MMT0013' ' ' 'X',
                                            ' ' 'H_RTPTQUA' 'ZC302MMT0013' 'C' ' ',
                                            ' ' 'MEINS'     'ZC302MMT0013' 'C' ' '.
**-- POPUP
*    CLEAR : gt_pfcat, gs_pfcat.
*    PERFORM set_popup_field_catalog USING : 'X' 'MATNR' 'ZC302MMT0012' 'C' '',
*                                            'X' 'MENGE' 'ZC302MMT0012' 'C' ''.


    PERFORM set_layout.
    PERFORM create_object.

    SET HANDLER : lcl_event_handler=>toolbar FOR go_up_grid,
                  lcl_event_handler=>user_command FOR go_up_grid.

*-- top
    gv_variant-report = sy-repid.
    gv_variant-handle = 'ALV1'.
    CALL METHOD go_up_grid->set_table_for_first_display
      EXPORTING
        is_variant                    = gv_variant
        i_save                        = 'A'
        i_default                     = 'X'
        is_layout                     = gs_tlayout
      CHANGING
        it_outtab                     = gt_export
        it_fieldcatalog               = gt_tfcat.

*-- bottom
    gv_variant-handle = 'ALV2'.
    CALL METHOD go_down_grid->set_table_for_first_display
      EXPORTING
        is_variant                    = gv_variant
        i_save                        = 'A'
        i_default                     = 'X'
        is_layout                     = gs_blayout
      CHANGING
        it_outtab                     = gt_export_bottom
        it_fieldcatalog               = gt_bfcat.


*-- popup
*    gv_variant-handle = 'ALV3'.
*    CALL METHOD go_pop_grid->set_table_for_first_display
*      EXPORTING
*        i_save                        = 'A'
*        i_default                     = 'X'
*        is_layout                     = gs_playout
*      CHANGING
*        it_outtab                     = gt_qt
*        it_fieldcatalog               = gt_pfcat.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_up_field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_up_field_catalog  USING pv_key pv_field pv_table pv_center pv_emph.

  gs_tfcat-key       = pv_key.
  gs_tfcat-fieldname = pv_field.
  gs_tfcat-ref_table = pv_table.
  gs_tfcat-just      = pv_center.
  gs_tfcat-emphasize = pv_emph.

  CASE pv_field.
    WHEN 'MENGE'.
      gs_tfcat-qfieldname = 'MEINS'.
      gs_tfcat-coltext    = '수량'.
    WHEN 'H_RTPTQUA'.
      gs_tfcat-qfieldname = 'MEINS'.
      gs_tfcat-coltext    = '수량'.
    WHEN 'H_RESMAT'.
      gs_tfcat-qfieldname = 'MEINS'.
    WHEN 'MEINS'.
      gs_tfcat-coltext    = '단위'.
    WHEN 'MTART_T'.
      gs_tfcat-coltext    = '자재 분류'.
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
  gs_tlayout-grid_title = '공장 창고'.
  gs_tlayout-smalltitle = abap_true.

  gs_blayout-zebra      = 'X'.
  gs_blayout-cwidth_opt = 'A'.
  gs_blayout-sel_mode   = 'D'.
  gs_blayout-grid_title = '물류 창고'.
  gs_blayout-smalltitle = abap_true.

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
      container_name  = 'MAIN_CONT'.

  CREATE OBJECT go_split_cont
    EXPORTING
      parent  = go_container
      rows    = 1     " 행
      columns = 2.    " 열

  CALL METHOD go_split_cont->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_up_cont.

  CALL METHOD go_split_cont->get_container
    EXPORTING
      row       = 1
      column    = 2
    RECEIVING
      container = go_down_cont.

  CREATE OBJECT go_up_grid
    EXPORTING
      i_parent = go_up_cont.

  CREATE OBJECT go_down_grid
    EXPORTING
      i_parent = go_down_cont.

*-- POPUP
*  CREATE OBJECT go_pop_container
*    EXPORTING
*      container_name    = 'POP_CONT'.
*  CREATE OBJECT go_pop_grid
*    EXPORTING
*      i_parent          = go_pop_container.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form expt_btn
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM expt_btn  CHANGING pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
     text_question               = '출고처리하시겠습니까?'
     text_button_1               = '네'(001)
     icon_button_1               = 'ICON_OKAY'
     text_button_2               = '아니요'(002)
     icon_button_2               = 'ICON_CANCEL'
     default_button              = '1'
     display_cancel_button       = ' '
   IMPORTING
     answer                      = pv_answer.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_base
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data_base .

*-- get master data
  PERFORM get_data_master.

*-- top data
  PERFORM get_data.

*-- bottom data
  PERFORM get_data_total.

*-- Screen painter
  PERFORM get_screen_data.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form VIEW_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM view_screen .

*-- 조회 버튼 클릭 시
    PERFORM get_data.
    PERFORM get_data_master.
    PERFORM refresh_table_up.
    PERFORM refresh_table_down.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form expt_view
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ANSWER
*&---------------------------------------------------------------------*
*FORM expt_view.
*
*   CALL SCREEN 101 STARTING AT 03 05.
*
*ENDFORM.
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
FORM set_bottom_field_catalog  USING pv_key pv_field pv_table pv_center pv_emph.

  gs_bfcat-key       = pv_key.
  gs_bfcat-fieldname = pv_field.
  gs_bfcat-ref_table = pv_table.
  gs_bfcat-just      = pv_center.
  gs_bfcat-emphasize = pv_emph.

  CASE pv_field.
    WHEN 'H_RTPTQUA'.
      gs_bfcat-qfieldname = 'MEINS'.
      gs_bfcat-coltext    = '수량'.
    WHEN 'H_RESMAT'.
      gs_bfcat-qfieldname = 'MEINS'.
    WHEN 'MEINS'.
      gs_bfcat-coltext    = '단위'.
    WHEN 'WAERS'.
      gs_bfcat-coltext    = '통화'.
    WHEN 'BUDAT'.
      gs_bfcat-coltext    = '일자'.
  ENDCASE.

  APPEND gs_bfcat TO gt_bfcat.
  CLEAR gs_bfcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form expt_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM expt_alv .

   DATA : lt_index     TYPE lvc_t_row,
          ls_index     TYPE lvc_s_row,
          lt_save_h    TYPE TABLE OF zc302mmt0011, "자재문서 header
          ls_save_h    TYPE zc302mmt0011,          "자재문서 header
          lt_save_i    TYPE TABLE OF zc302mmt0012, "자재문서 item
          ls_save_i    TYPE zc302mmt0012,          "자재문서 item
          lt_save_mt_i TYPE TABLE OF zc302mmt0002, "재고관리 item
          ls_save_mt_i TYPE zc302mmt0002,          "재고관리 item
          lt_save_mt_h TYPE TABLE OF zc302mmt0013, "재고관리 header
          ls_save_mt_h TYPE zc302mmt0013,          "재고관리 header
          lv_pk(10).

    CALL METHOD go_up_grid->get_selected_rows
      IMPORTING
        et_index_rows = lt_index.

    CALL METHOD go_up_grid->check_changed_data.


    READ TABLE lt_index INTO ls_index INDEX 1.
    IF gs_export-h_rtptqua < gv_rtptqua.
      MESSAGE s001 WITH TEXT-i02  DISPLAY LIKE 'E'.
      EXIT.
    ELSE.
*-- 출고지시할 인덱스 선택
    READ TABLE gt_export INTO gs_export INDEX ls_index-index.
    lv_pk = gs_export-matnr.


*--------------------------------------------------------------------*
* 재고 관리 헤더 세팅
*--------------------------------------------------------------------*
*-- 헤더에 ST05가있는지 확인
      SELECT SINGLE *
        INTO @DATA(ls_st05_h)
        FROM zc302mmt0013
        WHERE matnr = @lv_pk
          AND scode = 'ST05'.

      IF ls_st05_h IS INITIAL. " ST05에 해당 자재코드의 재고가 존재하지 않는 경우 -> 헤더와 아이템 모두 새로 만들어주어야 함
*-- GS_HEADER 클리어
*       CLEAR ls_st05_h.
*-- GS_EXPORT를 GS_HEADER에 복사
        MOVE-CORRESPONDING gs_export TO ls_st05_h.
*-- 창고코드를 ST05로 바꿔줌
        ls_st05_h-scode = 'ST05'.
        ls_st05_h-erdat = sy-datum.
        ls_st05_h-erzet = sy-uzeit.
        ls_st05_h-ernam = sy-uname.
      ELSE.
        ls_st05_h-h_rtptqua =  ls_st05_h-h_rtptqua + gs_export-h_rtptqua.
        ls_st05_h-aedat     = sy-datum.
        ls_st05_h-aezet     = sy-uzeit.
        ls_st05_h-aenam     = sy-uname.
      ENDIF.

*--------------------------------------------------------------------*
* 재고관리 아이템 세팅
*--------------------------------------------------------------------*
*-- 재고 관리 ITEM을 읽어옴
  SELECT *
    FROM zc302mmt0002
    INTO TABLE @DATA(lt_st03_i)
  WHERE matnr = @lv_pk
    AND scode = 'ST03'.

**********************************************************************
*    SELECT SINGLE *
*      INTO @DATA(ls_st03_i)
*      FROM zc302mmt0002
*      WHERE matnr = @lv_pk
*        AND scode = 'ST03'.
*
*    IF ls_st03_i IS NOT INITIAL.
*         MOVE-CORRESPONDING gs_export TO ls_st03_i.
*      ls_st03_i-i_rtptqua = 0.
*    ENDIF.
**********************************************************************
  MOVE-CORRESPONDING lt_st03_i TO lt_save_mt_i.

*-- 아이템에 정보 추가
  LOOP AT lt_save_mt_i INTO ls_save_mt_i.
      ls_save_mt_i-scode = 'ST05'.
      ls_save_mt_i-sname = '05'.
      ls_save_mt_i-erdat = sy-datum.
      ls_save_mt_i-erzet = sy-uzeit.
      ls_save_mt_i-ernam = sy-uname.

    MODIFY lt_save_mt_i FROM ls_save_mt_i INDEX sy-tabix TRANSPORTING  scode sname erdat erzet ernam.

  ENDLOOP.

*--------------------------------------------------------------------*
* ITAB 데이터 변경
*--------------------------------------------------------------------*
*  DELETE gt_export INDEX ls_index-index.

  LOOP AT gt_export_bottom INTO gs_export_bottom.
    gv_tabix = sy-tabix.

    IF gs_export-matnr = gs_export_bottom-matnr.
      gs_export_bottom-h_rtptqua += gs_export-h_rtptqua.
      MODIFY gt_export_bottom FROM gs_export_bottom INDEX gv_tabix
                                                  TRANSPORTING h_rtptqua.
    ENDIF.
  ENDLOOP.

  gs_export-h_rtptqua = 0.
  MODIFY gt_export FROM gs_export INDEX ls_index-index TRANSPORTING h_rtptqua.

*--------------------------------------------------------------------*
* DB 데이터 변경
*--------------------------------------------------------------------*
  MOVE-CORRESPONDING gs_export TO ls_save_mt_h.

*-- st05 header 업데이트 또는 생성
  MODIFY zc302mmt0013 FROM ls_save_mt_h.
  MODIFY zc302mmt0013 FROM ls_st05_h.

*-- 기존 st03 item 삭제
  DELETE zc302mmt0002  FROM TABLE lt_st03_i.

*-- 새로운 st05아이템 추가
  MODIFY  zc302mmt0002 FROM TABLE lt_save_mt_i.

ENDIF.


*--------------------------------------------------------------------*
* 자재문서
*--------------------------------------------------------------------*
*-- 자재마스터에서 단가정보, 자재분류 가져오기
    CLEAR : gs_mt_master.
    READ TABLE gt_mt_master INTO gs_mt_master WITH KEY matnr = gs_export-matnr.

    CLEAR gs_mt_doc.
*-- 자재문서 header
    CALL FUNCTION 'NUMBER_GET_NEXT' "자재문서번호 채번
      EXPORTING
        nr_range_nr                  = '01'
        object                       = 'ZC321MMMD'
     IMPORTING
       number                        = gs_mt_doc-mblnr.
     CONCATENATE 'MD' gs_mt_doc-mblnr+2(8) INTO gs_mt_doc-mblnr.
    gs_mt_doc-movetype = 'B'.       " 자재이동유형
    gs_mt_doc-mjahr =  sy-datum(4). " 자재문서연도

*-- 자재문서 item
    gs_mt_doc-matnr =  gs_export-matnr.     " 자재코드
    gs_mt_doc-maktx =  gs_export-maktx.     " 자재명
    gs_mt_doc-scode = 'ST05'.
    gs_mt_doc-menge =  gs_export-h_rtptqua. " 출고 수량
    gs_mt_doc-meins =  gs_export-meins.     " 단위
    gs_mt_doc-budat =  sy-datum.            " 출고날짜

*-- 타임스탬프 추가
    ls_save_h-erdat = sy-datum.
    ls_save_h-erzet = sy-uzeit.
    ls_save_h-ernam = sy-uname.
    ls_save_i-erdat = sy-datum.
    ls_save_i-erzet = sy-uzeit.
    ls_save_i-ernam = sy-uname.

*-- GT_MT_DOC의 헤더 관련된 필드만 복사
    MOVE-CORRESPONDING gs_mt_doc TO ls_save_h.

*-- GT_MT_DOC의 아이템 관련된 필드만 복사
    MOVE-CORRESPONDING gs_mt_doc TO ls_save_i.

*-- 자재문서 header 테이블
    MODIFY zc302mmt0011 FROM ls_save_h.

*-- 자재문서 item 테이블
    MODIFY zc302mmt0012 FROM ls_save_i.

*-- 출고 시 카운트
    gv_im = gv_im - 1. " 입고
    gv_ex = gv_ex + 1. " 출고

  IF sy-subrc = 0.
    COMMIT WORK AND WAIT.
    MESSAGE s001 WITH TEXT-s02.
    PERFORM  refresh_table_up.
    PERFORM  refresh_table_down.
  ELSE.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

*-- 상단 입출고 리스트 업데이트
  CALL METHOD cl_gui_cfw=>set_new_ok_code
    EXPORTING
        new_code = 'ENTER'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_popup_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_popup_data .

  DATA : lt_index TYPE lvc_t_row,
         ls_index TYPE lvc_s_row,
         lv_pk(10).

  CALL METHOD go_up_grid->get_selected_rows
      IMPORTING
        et_index_rows = lt_index.

  CLEAR gv_rtptqua.

*-- 선택행 데이터 읽어오기
  READ TABLE lt_index INTO ls_index INDEX 1.

  CLEAR gs_export.
  READ TABLE gt_export INTO gs_export INDEX ls_index-index.

  CLEAR gt_qt.
  SELECT matnr h_rtptqua
    INTO CORRESPONDING FIELDS OF TABLE gt_qt
    FROM zc302mmt0013
  WHERE matnr = gs_export-matnr.

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
*&---------------------------------------------------------------------*
FORM set_popup_field_catalog USING pv_key pv_field pv_table pv_center pv_emph.

  gs_pfcat-key       = pv_key.
  gs_pfcat-fieldname = pv_field.
  gs_pfcat-ref_table = pv_table.
  gs_pfcat-just      = pv_center.
  gs_pfcat-emphasize = pv_emph.

  APPEND gs_pfcat TO gt_pfcat.
  CLEAR gs_pfcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GRID_NAME
*&---------------------------------------------------------------------*
FORM refresh_table_down .
  DATA : ls_stbl TYPE lvc_s_stbl.

  ls_stbl-row = abap_true.
  ls_stbl-col = abap_true.

  CALL METHOD go_down_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stbl.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_table_up
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_table_up .
  DATA : ls_stbl TYPE lvc_s_stbl.

  ls_stbl-row = abap_true.
  ls_stbl-col = abap_true.

  CALL METHOD go_up_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stbl.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  IF gt_export IS INITIAL.
    CLEAR gt_export.
    SELECT a~matnr a~scode a~maktx
           h_rtptqua h_resmat a~meins a~mtart a~sname address i_rtptqua
      INTO CORRESPONDING FIELDS OF TABLE gt_export
      FROM zc302mmt0013 AS a INNER JOIN zc302mmt0002 AS b
        ON a~matnr = b~matnr
      WHERE a~scode = 'ST03'
      ORDER BY a~matnr DESCENDING.
  ENDIF.

*    CLEAR gt_export.
*    SELECT matnr scode maktx
*           h_rtptqua h_resmat meins mtart sname address i_rtptqua
*      INTO CORRESPONDING FIELDS OF TABLE gt_export
*      FROM zc302mmt0013 AS A INNER JOIN ZC302MMT0002 AS B
*      WHERE scode = 'ST03'
*      ORDER BY matnr DESCENDING.

*-- 자재명 끌어오기
  PERFORM get_master_data.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_total
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data_total .
*
  IF gt_export_bottom IS INITIAL.
    CLEAR gt_export_bottom.
    SELECT matnr scode maktx
           h_rtptqua h_resmat meins mtart sname address
      INTO CORRESPONDING FIELDS OF TABLE gt_export_bottom
      FROM zc302mmt0013
      WHERE scode = 'ST05'
   ORDER BY matnr DESCENDING.
  ENDIF.

*-- 자재명 끌어오기
  PERFORM get_master_data_bottom.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_master
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data_master .

*-- 자재마스터 단가, 자재분류 정보
  CLEAR gt_mt_master.
  SELECT matnr mtart netwr waers maktx
    INTO CORRESPONDING FIELDS OF TABLE gt_mt_master
    FROM zc302mt0007.


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

  CLEAR gs_button.
  gs_button-butn_type = 3.
  APPEND gs_button TO po_object->mt_toolbar.

  CLEAR gs_button.
  gs_button-function = 'EXPT'.
  gs_button-icon     = icon_transport.
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

  DATA : lt_index TYPE lvc_t_row,
         ls_index TYPE lvc_s_row.

  CALL METHOD go_up_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_index.

  CASE pv_ucomm.
    WHEN 'EXPT'.
      IF lines( lt_index ) < 1.
        MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
        EXIT.
*-- 선택된 행이 1이 아니면 에러메시지 뜨도록 하기
      ELSEIF lines( lt_index ) > 1.
        MESSAGE s001 WITH TEXT-e01  DISPLAY LIKE 'E'.
        EXIT.
      ELSE.
       PERFORM expt_btn CHANGING lv_answer.
       IF lv_answer = '1'.
           PERFORM expt_alv.
       ELSE.
          MESSAGE s001 WITH TEXT-s01 DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_screen_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_screen_data .

  IF gv_im IS INITIAL.
    CLEAR gt_export.
    SELECT matnr scode maktx
           h_rtptqua h_resmat meins mtart sname address
      INTO CORRESPONDING FIELDS OF TABLE gt_export
      FROM zc302mmt0013
     WHERE scode = 'ST03'
     ORDER BY matnr.
    gv_im = lines( gt_export ).
  ENDIF.

  IF gv_ex IS INITIAL.
    CLEAR gt_export_bottom.
    SELECT matnr scode maktx
           h_rtptqua h_resmat meins mtart sname address
      INTO CORRESPONDING FIELDS OF TABLE gt_export_bottom
      FROM zc302mmt0013
     WHERE scode = 'ST05'
     ORDER BY matnr.
    gv_ex = lines( gt_export_bottom ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_master_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_master_data .

  LOOP AT gt_export INTO gs_export.

    gv_tabix = sy-tabix.

    CLEAR gs_mt_master.
    READ TABLE gt_mt_master INTO gs_mt_master WITH KEY matnr = gs_export-matnr.
    gs_export-maktx = gs_mt_master-maktx.

    MODIFY gt_export FROM gs_export INDEX gv_tabix TRANSPORTING maktx.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_master_data_bottom
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_master_data_bottom .


  LOOP AT gt_export_bottom INTO gs_export_bottom.

    gv_tabix = sy-tabix.

    CLEAR gs_mt_master.
    READ TABLE gt_mt_master INTO gs_mt_master WITH KEY matnr = gs_export_bottom-matnr.
    gs_export_bottom-maktx = gs_mt_master-maktx.

    MODIFY gt_export_bottom FROM gs_export_bottom INDEX gv_tabix TRANSPORTING maktx.

  ENDLOOP.

ENDFORM.
