*&---------------------------------------------------------------------*
*& Include          SAPMZC302MM0006F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_base_Main_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_base_main_data .
  DATA : lv_tabix TYPE sy-tabix.

  CLEAR : gt_elem, gs_elem.
  CLEAR : gt_body.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_elem
    FROM zc302mt0007.

  SORT gt_elem  BY mtart matnr maktx gewei netwr.

  IF gt_elem IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
    STOP.

  ENDIF.

  LOOP AT gt_elem INTO gs_elem.

    lv_tabix = sy-tabix.

    CASE gs_elem-mtart.
      WHEN '01'.
        gs_elem-mtbez = '원자재'.
      WHEN '02'.
        gs_elem-mtbez = '반제품'.
      WHEN '03'.
        gs_elem-mtbez = '완제품'.
    ENDCASE.

    MODIFY gt_elem FROM gs_elem INDEX lv_tabix TRANSPORTING mtbez.

  ENDLOOP.


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
  DATA : lv_variant TYPE disvariant.

  IF go_cont IS NOT BOUND.
    PERFORM field_catalog.
    PERFORM create_object.
    PERFORM set_layout.

    lv_variant-report = sy-repid.

    CALL METHOD go_alv_grid->set_table_for_first_display
      EXPORTING
        is_variant           = lv_variant
        i_save               = 'A'
        i_default            = 'X'
        is_layout            = gs_layo
        it_toolbar_excluding = gt_ui_functions
      CHANGING
        it_outtab            = gt_elem
        it_fieldcatalog      = gt_fcat.

  ELSE.
    CALL METHOD go_alv_grid->refresh_table_display.
  ENDIF.

  CLEAR gs_elem.

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
  CLEAR gt_fcat.
  PERFORM set_field_catalog USING : 'X' 'MATNR'   'ZC302MT0007' 'C' ' ',
                                    ' ' 'MTBEZ' 'ZC302MT0007' 'C' 'X',
                                    ' ' 'MAKTX'   'ZC302MT0007' ' ' 'X',
                                    ' ' 'WEIGHT'  'ZC302MT0007' 'C' ' ',
                                    ' ' 'GEWEI'   'ZC302MT0007' 'C' ' ',
                                    ' ' 'NETWR'   'ZC302MT0007' ' ' ' ',
                                    ' ' 'WAERS'   'ZC302MT0007' 'C' ' ',
                                    ' ' 'MATLT'   'ZC302MT0007' 'C' ' ',
                                    ' ' 'MATMLT'  'ZC302MT0007' 'C' ' '.

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
  CLEAR gs_fcat.
  gs_fcat-key       = pv_key.
  gs_fcat-fieldname = pv_field.
  gs_fcat-ref_table = pv_table.
  gs_fcat-just      = pv_just.
  gs_fcat-emphasize = pv_emph.

  CASE pv_field.
    WHEN 'WEIGHT'.
      gs_fcat-qfieldname = 'GEWEI'.
      gs_fcat-coltext    = '수량'.
    WHEN 'GEWEI'.
      gs_fcat-coltext    = '단위'.
    WHEN 'NETWR'.
      gs_fcat-cfieldname = 'WAERS'.
      gs_fcat-coltext    = '단가'.
    WHEN 'WAERS'.
      gs_fcat-coltext    = '통화'.
    WHEN 'MTBEZ'.
      gs_fcat-coltext    = '자재유형'.
    WHEN OTHERS.
  ENDCASE.
  APPEND gs_fcat TO gt_fcat.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_data .
  DATA : lv_answer.

*-- 자재 데이터를 등록할지 최종적으로 물어봄
  IF gs_elem IS INITIAL.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  PERFORM range_number.

*-- Internal Table에 저장
  " gt_body에다가 insert db table에 insert

  gs_elem-netwr = gs_elem-netwr / 100.
  APPEND gs_elem TO gt_elem.
*  MOVE-CORRESPONDING gt_elem TO gt_body.



  PERFORM confirm CHANGING lv_answer.

  IF lv_answer NE '1'.
    EXIT.
  ENDIF.

  PERFORM save_material.
  CLEAR gs_elem.


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

*-- For Container
  CREATE OBJECT go_cont
    EXPORTING
      container_name = 'MAIN_CONT'.

*-- For ALV
  CREATE OBJECT go_alv_grid
    EXPORTING
      i_parent = go_cont.



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

  gs_layo-zebra      = abap_true.
  gs_layo-sel_mode   = 'D'.
  gs_layo-cwidth_opt = 'A'.
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
      titlebar              = 'save Dialog'
      diagnose_object       = ' '
      text_question         = '자재를 등록하시겠습니까?'
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
*& Form range_number
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form range_number
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM range_number .

  DATA lv_prefix(2).
  lv_prefix = ''.
  CASE gs_elem-mtart.
    WHEN '01'.
      lv_prefix = 'RM'.
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr = '01'
          object      = 'ZC303NR'
        IMPORTING
          number      = gs_elem-matnr.
    WHEN '02'.
      lv_prefix = 'SP'.
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr = '02'
          object      = 'ZC303NR'
        IMPORTING
          number      = gs_elem-matnr.
    WHEN '03'.
      lv_prefix = 'CP'.
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr = '03'
          object      = 'ZC303NR'
        IMPORTING
          number      = gs_elem-matnr.
  ENDCASE.

*--CP,SP,RM 를 matnr 앞에 붙이기
  CONCATENATE lv_prefix gs_elem-matnr INTO gs_elem-matnr.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_material
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_material .
  DATA : lt_save  TYPE TABLE OF zc302mt0007,
         ls_save  TYPE zc302mt0007,
         lv_tavix TYPE sy-tabix.

  MOVE-CORRESPONDING gs_elem TO ls_save.

  IF ls_save-erdat IS INITIAL.
    ls_save-erdat = sy-datum.
    ls_save-erzet = sy-uzeit.
    ls_save-ernam = sy-uname.
  ELSE.
    ls_save-aedat = sy-datum.
    ls_save-aezet = sy-uzeit.
    ls_save-aenam = sy-uname.
  ENDIF.

  MODIFY zc302mt0007 FROM ls_save.

  IF sy-subrc EQ 0.
    MESSAGE s102.
    COMMIT WORK AND WAIT.
*-- REFRESH
    CALL METHOD go_alv_grid->refresh_table_display.
    MESSAGE s001 WITH TEXT-i01.
  ELSE.
    ROLLBACK WORK.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_make_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_make_f4 .

  CLEAR : gs_bp, gt_bp.
  SELECT bpcode cname
    INTO CORRESPONDING FIELDS OF TABLE gt_bp
    FROM zc302mt0001
   WHERE bpcode LIKE 'PO%'.

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
  DATA : lt_return TYPE TABLE OF ddshretval WITH HEADER LINE.

  REFRESH : lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BPCODE'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'gs_elem-bpcode'    " Selection Screen Element
      window_title    = 'BP Code' " Description
      value_org       = 'S'
    TABLES
      value_tab       = gt_bp " F4에 뿌려줄 데이터
      return_tab      = lt_return " F4에서 선택된 값에 대한 정보
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
ENDFORM.
