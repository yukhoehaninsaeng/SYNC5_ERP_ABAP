*&---------------------------------------------------------------------*
*& Form DISPLAY_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_screen .
  _clear gt_fcat gs_fcat.
  IF go_cont IS NOT BOUND.

    PERFORM field_catalog.
    PERFORM create_object.

    PERFORM exclude_button TABLES gt_ui_functions.

    gv_variant-report = sy-repid.
    gv_variant-handle = 'ALV1'.

    CALL METHOD go_alv_grid->set_table_for_first_display
      EXPORTING
        is_variant           = gv_variant
        i_save               = 'A'
        i_default            = 'X'
        is_layout            = gs_layo
        it_toolbar_excluding = gt_ui_functions
      CHANGING
        it_outtab            = gt_body
        it_fieldcatalog      = gt_fcat.

  ELSE.
    CALL METHOD go_alv_grid->refresh_table_display.
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

  PERFORM set_field_catalog USING : 'X' 'XBLNR'   'ZC302MMT0010' 'C' 'X',
                                    'X' 'BLDAT'   'ZC302MMT0010' 'C' ' ',
                                    'X' 'BPCODE'  'ZC302MMT0010' 'C' ' ',
                                    ' ' 'CNAME'   'ZC302MT0001'  ' ' 'X',
                                    'X' 'MATNR'   'ZC302MMT0010' 'C' '',
                                    ' ' 'MAKTX'   'ZC302MT0007'  ' ' 'X',
                                    ' ' 'MENGE'   'ZC302MMT0010' ' ' ' ',
                                    ' ' 'MEINS'   'ZC302MMT0010' 'C' ' ',
                                    ' ' 'NETPR'   'ZC302MMT0010' ' ' ' ',
                                    ' ' 'NETWR'   'ZC302MMT0010' ' ' ' ',
                                    ' ' 'WAERS'   'ZC302MMT0010' 'C' ' '.

  PERFORM set_layout.
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
      gs_fcat-qfieldname = 'MEINS'.
      gs_fcat-coltext    = '수량'.
    WHEN 'NETWR'.
      gs_fcat-cfieldname = 'WAERS'.
      gs_fcat-coltext    = '총 합계'.
      gs_fcat-do_sum = 'X'.
    WHEN 'NETPR'.
      gs_fcat-cfieldname = 'WAERS'.
      gs_fcat-coltext    = '단가'.
    WHEN 'WAERS'.
      gs_fcat-coltext = '통화'.
    WHEN 'MEINS'.
      gs_fcat-coltext = '단위'.
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

  gs_layo-zebra = abap_true.
  gs_layo-cwidth_opt = 'A'.
  gs_layo-sel_mode   = 'D'.

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

*-- ALV
  CREATE OBJECT go_alv_grid
    EXPORTING
      i_parent = go_cont.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_button
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_UI_FUNCTIONS
*&---------------------------------------------------------------------*
FORM exclude_button  TABLES pt_ui_functions TYPE ui_functions. " ui functions은 table type이라서 structure사용이 불가함.

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
*& Form f4_filename
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_filename .
  DATA : lt_file   TYPE filetable,
         ls_file   LIKE LINE OF lt_file,
         lv_filter TYPE string,
         lv_path   TYPE string,
         lv_rc     TYPE i.


  CONCATENATE cl_gui_frontend_services=>filetype_excel
  'Excel 통합 문서(*.XLSX)|*.XLSX|'
  INTO lv_filter.


  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = 'File Open'
      default_extension       = lv_filter
      initial_directory       = lv_path
    CHANGING
      file_table              = lt_file
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  CHECK sy-subrc EQ 0.
  ls_file = VALUE #( lt_file[ 1 ] OPTIONAL ).

* Clear ls_files
  gv_file = ls_file-filename.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form excel_upload
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM excel_upload .
  TYPES : truxs_t_text_data(4096) TYPE c OCCURS 0.

  DATA : lt_raw_data  TYPE truxs_t_text_data,
         lt_excel     LIKE TABLE OF alsmex_tabline WITH HEADER LINE,
         lv_index     LIKE sy-tabix,
         lv_file_path TYPE rlgrap-filename.

  FIELD-SYMBOLS : <field>.

  _clear gt_excel gs_excel.
  CLEAR lv_index.

  lv_file_path = gv_file.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = lv_file_path
      i_begin_col             = 1
      i_begin_row             = 2
      i_end_col               = 100
      i_end_row               = 50000
    TABLES
      intern                  = lt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc EQ 1.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.    " File Conversion Failed
  ELSEIF sy-subrc <> 0.
    MESSAGE s001 WITH TEXT-e02.                     " File Open Error
    EXIT.
  ENDIF.

  CHECK NOT ( lt_excel[] IS INITIAL ).              " lt_excel에 값이 비어있는지 확인

  SORT lt_excel BY row col.


**********************************************************************
* 현재 열 인덱스를 lv_index에 저장 후, gs_excel구조의 해당 필드에 값을 할당
* 행의 끝에 도달 시 gs_excel을 gt_excel에 appent하고 gs_excel을 초기화
**********************************************************************
  LOOP AT lt_excel.

    lv_index = lt_excel-col.
    ASSIGN COMPONENT lv_index OF STRUCTURE gs_excel TO <field>.
    <field> = lt_excel-value.

    AT END OF row.
      APPEND gs_excel TO gt_excel.
      CLEAR gs_excel.
    ENDAT.

  ENDLOOP.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_excel_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_excel_data .

*  PERFORM set_display.
  CLEAR : gt_body, gs_body, gv_netwr, gv_aufnr, gv_plordco, gv_bldat.

  LOOP AT gt_excel INTO gs_excel.
    gv_tabix = sy-tabix.

    IF gv_tabix = 1.
      CLEAR gs_qc.
      READ TABLE gt_qc INTO gs_qc WITH KEY xblnr = gs_excel-xblnr
                                           matnr = gs_excel-matnr.

      IF sy-subrc EQ 0.

        gv_aufnr    = gs_qc-aufnr.
        gv_plordco  = gs_qc-plordco.
        gv_bldat    = gs_qc-bldat.
      ENDIF.
    ENDIF.

    gs_body = CORRESPONDING #( gs_excel ). " MOVE-CORRESPONDING 신문법

*-- Amount Convertion
    _currency gs_body-waers gs_body-netwr gs_body-netwr.
    _currency gs_body-waers gs_body-netpr gs_body-netpr.

*-- 하나의 원자재 품목 합계금액
    gs_body-netwr = gs_body-netpr * gs_body-menge.
*-- gv_netwr에 구매오더번호에 포함된 합계수량
    gv_netwr = gv_netwr + gs_body-netwr / 100.

    PERFORM get_qc_data.

    APPEND gs_body TO gt_body.
    CLEAR gs_body.

  ENDLOOP.

  PERFORM refresh_table.

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


  DATA : ls_stbl TYPE lvc_s_stbl.

  ls_stbl-row = abap_true .
  ls_stbl-col = abap_true.

  CALL METHOD go_alv_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stbl.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form excel_download
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM excel_download .
**********************************************************************
* Create excel upload application form
**********************************************************************
  DATA : lv_filename LIKE rlgrap-filename,
         lv_msg(100).

*-- Call windows browser
  CLEAR w_pfolder.
  PERFORM get_browser_info.

  IF w_pfolder IS INITIAL.
    EXIT.
  ENDIF.

  CLEAR lv_filename.
  CONCATENATE w_pfolder '\' 'Data_Upload' '.XLS' INTO lv_filename.

  PERFORM download_template USING lv_filename.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_browser_info
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_browser_info .

  IF w_pfolder IS NOT INITIAL.
    w_initialfolder = w_pfolder.
  ELSE.
    CALL METHOD cl_gui_frontend_services=>get_temp_directory
      CHANGING
        temp_dir = w_initialfolder.
  ENDIF.

  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title    = 'Download path'
      initial_folder  = w_initialfolder
    CHANGING
      selected_folder = w_pickedfolder.

  IF sy-subrc = 0.
    w_pfolder = w_pickedfolder.
  ELSE.
    MESSAGE i001 WITH TEXT-e05 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form download_template
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_FILENAME
*&---------------------------------------------------------------------*
FORM download_template  USING  pv_filename.

  DATA : wwwdata_item LIKE wwwdatatab,
         rc           TYPE i.

  gv_file = pv_filename.

  CALL FUNCTION 'WS_FILE_DELETE'
    EXPORTING
      file   = gv_file
    IMPORTING
      return = rc.

  SELECT SINGLE * FROM wwwdata
    INTO CORRESPONDING FIELDS OF wwwdata_item
   WHERE objid = 'ZC303_XLS_FORM_MM'. " Form name

  CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
    EXPORTING
      key         = wwwdata_item
      destination = gv_file.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form excel_save
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM excel_save .
  DATA : lv_tabix     TYPE sy-tabix,
         lv_answer(1),
         lv_num       TYPE i, " 업로드한 데이터의 개수
         lv_sum       TYPE i. " DB 테이블과 업로드한 데이터를 비교하여 DB에 존재하는 데이터를 카운트

  CLEAR : lv_tabix.

  DATA : lt_save TYPE TABLE OF zc302mmt0010,
         ls_save TYPE zc302mmt0010.

  PERFORM confirm_for_invo USING lv_answer.

  IF lv_answer NE '1'.
    MESSAGE s001 WITH TEXT-e07 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.



*-- invoice_comparison
*-- 기존 등록된 송장 데이터가 있으면 오류를 반환.
  CLEAR : gt_com.
  SELECT xblnr
*         bldat bpcode matnr maktx menge meins netpr netwr waers
    INTO CORRESPONDING FIELDS OF TABLE gt_com
    FROM zc302mmt0010.

  lv_num = lines( gt_body ).

  LOOP AT gt_body INTO gs_body.

    CLEAR gs_com.
    READ TABLE gt_com INTO gs_com WITH KEY xblnr = gs_body-xblnr.

    CLEAR gs_qc.
    READ TABLE gt_qc INTO gs_qc WITH KEY xblnr = gs_body-xblnr
                                         matnr = gs_body-matnr.

    IF gs_com IS INITIAL.
      PERFORM save_zc302mmt0010.
      PERFORM save_zc302mmt0009.
    ELSE.
      lv_sum += 1.
    ENDIF.

  ENDLOOP.

  IF lv_sum EQ 0.
    MESSAGE s001 WITH TEXT-i02. " 모두 저장되었습니다.
  ELSEIF lv_sum LT lv_num.
    MESSAGE s001 WITH TEXT-i03. " 부분적으로 저장되었습니다.
  ELSE.
    MESSAGE s001 WITH TEXT-e09 DISPLAY LIKE 'E'. " 모든 데이터가 DB에 존재하므로 저장이 되지 않았습니다.
  ENDIF.

  PERFORM refresh_table.

*  LOOP AT gt_excel INTO gs_excel.
*
*    lv_tabix = sy-tabix.
*
*
*
*    IF gs_excel = gs_com-xblnr.
*      MESSAGE s001 WITH TEXT-e08 DISPLAY LIKE 'E'.
*      EXIT.
*
*    ENDIF.
*
*  ENDLOOP.
*
*
*
*  MOVE-CORRESPONDING gt_body TO lt_save.
*
*  LOOP AT lt_save INTO ls_save.
*    gv_tabix = sy-tabix.
*
*    IF ls_save-erdat IS INITIAL.
*      ls_save-erdat = sy-datum.
*      ls_save-erzet = sy-uzeit.
*      ls_save-ernam = sy-uname.
*    ELSE.
*      ls_save-aedat = sy-datum.
*      ls_save-aezet = sy-uzeit.
*      ls_save-aenam = sy-uname.
*    ENDIF.
*
*    MODIFY lt_save FROM ls_save INDEX gv_tabix TRANSPORTING erdat erzet ernam
*                                                            aedat aezet aenam.
*  ENDLOOP.
*
*  MODIFY zc302mmt0010 FROM TABLE lt_save.
*  IF sy-subrc EQ 0.
*    COMMIT WORK AND WAIT.
*  ELSE.
*    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
*    ROLLBACK WORK.
*  ENDIF.


*-- 송장검증 테이블에 업로드된 엑셀데이터와 품질검수 테이블을 비교하여 구매오더번호, 최종입고 수량을 전달해줌.
*  MOVE-CORRESPONDING lt_save TO gt_iv.
*
*  LOOP AT gt_iv INTO gs_iv.
*    lv_tabix = sy-tabix.
*
*    READ TABLE gt_qc INTO gs_qc WITH KEY xblnr = gs_iv-xblnr
*                                         matnr = gs_iv-matnr.
*    IF sy-subrc EQ 0.
*      gs_iv-aufnr    = gv_aufnr.
*      gs_iv-qimenge  = gs_qc-qimenge.
*      gs_iv-instatus = 'B'.
*    ENDIF.
*
*    MODIFY gt_iv FROM gs_iv INDEX lv_tabix TRANSPORTING aufnr qimenge.
*  ENDLOOP.
*
*  MODIFY zc302mmt0009 FROM TABLE gt_iv.
*
*  IF sy-subrc EQ 0.
*    COMMIT WORK AND WAIT.
*    PERFORM refresh_table.
*    MESSAGE s001 WITH TEXT-i01.
*  ELSE.
*    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
*    ROLLBACK WORK.
*  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_make_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_make_display .

  DATA : lt_return TYPE TABLE OF ddshretval WITH HEADER LINE,
         lt_read   TYPE TABLE OF dynpread   WITH HEADER LINE.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_qc
    FROM zc302mmt0006.


  LOOP AT gt_body INTO gs_body.
    gv_tabix = sy-tabix.

    READ TABLE gt_bp       INTO gs_bp       WITH KEY bpcode = gs_body-bpcode.
    READ TABLE gt_material INTO gs_material WITH KEY matnr  = gs_body-matnr.
    READ TABLE gt_qc       INTO gs_qc       WITH KEY xblnr  = gs_body-xblnr
                                                     bpcode = gs_body-bpcode
                                                     matnr  = gs_body-matnr.

    IF sy-subrc EQ 0.

      gs_body-cname   = gs_bp-cname.
      gs_body-maktx   = gs_material-maktx.
      gs_body-aufnr   = gs_qc-aufnr.
      gs_body-plordco = gs_qc-plordco.
    ENDIF.

    MODIFY gt_body FROM gs_body INDEX gv_tabix TRANSPORTING cname maktx aufnr.

  ENDLOOP.

*-- Set value to Dynpro
  REFRESH lt_read.
  lt_read-fieldname = 'MATNR'.
  lt_read-fieldvalue = lt_return-fieldval.
  APPEND lt_read.
  lt_read-fieldname = 'MAKTX'.
  lt_read-fieldvalue = gs_body-maktx.
  APPEND lt_read.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-repid
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = lt_read
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_display .

*  DATA : lt_index TYPE lvc_t_row,
*         ls_index TYPE lvc_s_row.
*
*  CLEAR : lt_index, ls_index, gv_tabix.
*
*
*  CALL METHOD go_alv_grid->set_selected_rows
*    EXPORTING
*      it_index_rows = lt_index.
*
*  IF lines( lt_index ) > 1.
*    ls_index = VALUE #( lt_index[ 1 ] OPTIONAL ).
*    gv_tabix = ls_index-index.
*
*    READ TABLE gt_body INTO gs_body INDEX gv_tabix.

  gv_aufnr   = gs_body-aufnr.
  gv_plordco = gs_body-plordco.
  gv_bldat   = gs_body-bldat.
*  gv_netwr   =

*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_QC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_qc .
  CLEAR : gt_qc, gs_qc.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_qc
    FROM zc302mmt0006.

  CLEAR : gt_iv, gs_iv.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_iv
    FROM zc302mmt0009.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_qc_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_qc_data .

  LOOP AT gt_excel INTO gs_excel.

    READ TABLE gt_qc INTO gs_qc WITH KEY xblnr = gs_iv-xblnr
                                         matnr = gs_iv-matnr.

    IF sy-subrc EQ 0.
      gs_iv-aufnr = gs_qc-aufnr.
      gv_aufnr    = gs_qc-aufnr.
      gv_plordco  = gs_qc-plordco.
    ENDIF.

*    MODIFY gt_iv FROM gs_iv TRANSPORTING aufnr.
  ENDLOOP.

  PERFORM save_iv.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_iv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_iv .
  DATA lv_tabix TYPE sy-tabix.

  DATA : lt_save TYPE TABLE OF zc302mmt0009,
         ls_save TYPE zc302mmt0009.


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

    MODIFY lt_save FROM ls_save INDEX gv_tabix TRANSPORTING erdat erzet ernam
                                                            aedat aezet aenam.
  ENDLOOP.

  MOVE-CORRESPONDING gt_iv TO lt_save.
  MODIFY zc302mmt0009 FROM TABLE lt_save.

  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form confirm_for_invo
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ANSWER
*&---------------------------------------------------------------------*
FORM confirm_for_invo  USING    pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = '송장검증 Dialog'
      text_question         = '거래처 송장을 저장하시겠습니까?'
      text_button_1         = '예'(001)
      icon_button_1         = 'ICON_CHECKED'
      text_button_2         = '아니오'(002)
      icon_button_2         = 'ICON_CANCLED'
      default_button        = '1'
      display_cancel_button = 'X'
    IMPORTING
      answer                = pv_answer.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form invoice_comparison
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM invoice_comparison .





ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_zc302mmt0010
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_zc302mmt0010 .

  DATA: ls_save TYPE zc302mmt0010.

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

  MODIFY zc302mmt0010 FROM ls_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_display_qual_inspect
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_zc302mmt0009.

  DATA: ls_save TYPE zc302mmt0009.

  MOVE-CORRESPONDING gs_body TO ls_save.

  IF sy-subrc EQ 0.
    ls_save-aufnr    = gv_aufnr.
    ls_save-qimenge  = gs_qc-qimenge.
    ls_save-instatus = 'B'.
  ENDIF.

  IF ls_save-erdat IS INITIAL.
    ls_save-erdat = sy-datum.
    ls_save-erzet = sy-uzeit.
    ls_save-ernam = sy-uname.
  ELSE.
    ls_save-aedat = sy-datum.
    ls_save-aezet = sy-uzeit.
    ls_save-aenam = sy-uname.
  ENDIF.

  MODIFY zc302mmt0009 FROM ls_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.



ENDFORM.
