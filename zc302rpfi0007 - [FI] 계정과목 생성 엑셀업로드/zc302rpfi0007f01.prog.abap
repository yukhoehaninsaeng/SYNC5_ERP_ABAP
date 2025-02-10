*&---------------------------------------------------------------------*
*& Include          ZC302RPFI0007F01
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

  CLEAR : gt_gldata.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_gldata
    FROM zc302mt0006
*    WHERE bukrs IN gr_bukrs
*      AND ktopl IN gr_ktopl
*      AND txt50 IN gr_txt50
*      AND gjgrp IN gr_gjgr
    ORDER BY saknr ASCENDING.

  IF gt_gldata IS INITIAL.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'.
  ENDIF.

*  gv_total = lines( gt_gldata ).


ENDFORM.

*&---------------------------------------------------------------------*
*& Module INIT_PROCESS_CONTROL OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_process_control OUTPUT.

  PERFORM display_screen.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form display_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_screen .

  IF go_container2 IS NOT BOUND.

    CLEAR : gs_fcat2, gt_fcat2.
    PERFORM set_fcat2 USING : 'X' 'BUKRS' 'ZC302MT0006' 'C' 'X',
                              'X' 'KTOPL' 'ZC302MT0006' 'C' 'X',
                              'X' 'SAKNR' 'ZC302MT0006' 'C' 'X',
                              ' ' 'TXT50' 'ZC302MT0006' 'C' ' ',
                              ' ' 'GJGRP' 'ZC302MT0006' 'C' ' ',
                              ' ' 'GL_FLAG' 'ZC302MT0006' 'C' ' ',
                              ' ' 'BPCODE' 'ZC302MT0006' 'C' ' '.

    PERFORM set_layout.
    PERFORM exclude_button TABLES gt_ui_functions.

    PERFORM create_object.

    gs_variant-report = sy-repid.
    gs_variant-handle = 'ALV1'.

    SET HANDLER : lcl_event_handler=>toolbar FOR go_alv_grid2,
                  lcl_event_handler=>user_command FOR go_alv_grid2.

    CALL METHOD go_alv_grid2->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        i_save               = 'A'
        i_default            = 'X'
        is_layout            = gs_layout
        it_toolbar_excluding = gt_ui_functions
      CHANGING
        it_outtab            = gt_gldata
        it_fieldcatalog      = gt_fcat2.


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

  gs_layout-zebra = 'X'.
  gs_layout-cwidth_opt = 'A'.
  gs_layout-sel_mode = 'D'.
*  gs_layout-totals_bef = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_fcat2  USING   pv_key pv_field pv_table pv_just pv_emph.

  gs_fcat2-key = pv_key.
  gs_fcat2-fieldname = pv_field.
  gs_fcat2-ref_table = pv_table.
  gs_fcat2-just = pv_just.
  gs_fcat2-emphasize = pv_emph.
  gs_fcat2-f4availabl = abap_true.

  CASE pv_field.
    WHEN 'KTOPL'.
      gs_fcat2-coltext = '계정과목표'.
    WHEN 'BUKRS'.
      gs_fcat2-coltext = '회사 코드'.
    WHEN 'SAKNR'.
      gs_fcat2-coltext = '계정과목코드'.
    WHEN 'TXT50'.
      gs_fcat2-coltext = '계정과목명'.
    WHEN 'GL_FLAG'.
      gs_fcat2-coltext = '계정 유형'.
    WHEN 'BPCODE'.
      gs_fcat2-coltext = '거래처 코드'.
  ENDCASE.

  APPEND gs_fcat2 TO gt_fcat2.
  CLEAR : gs_fcat2.

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
*& Form create_object
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_object .

  CREATE OBJECT go_container2
    EXPORTING
      container_name = 'MAIN_CONT'.

  CREATE OBJECT go_alv_grid2
    EXPORTING
      i_parent = go_container2.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_account
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_account .

*  DATA: lv_answer.                " 계정 생성 확인을 위한 변수
*
*
**-- 유효성 검사 - 권한 확인
*  IF sy-uname NE 'KDT-C-12' AND
*     sy-uname NE 'KDT-C-06'.
*    MESSAGE i001 WITH TEXT-e06 DISPLAY LIKE 'E'.
*    EXIT.
*  ENDIF.
*
**-- 필수입력 확인
**  IF ( gv_buk IS INITIAL ) OR
**     ( gv_kto IS INITIAL ) OR
**     ( gv_fla IS INITIAL ) OR
**     ( gv_txt IS INITIAL ).
**    MESSAGE i001 WITH TEXT-e04 DISPLAY LIKE 'E'.
**    EXIT.
**  ENDIF.
*
**- 계정 생성 전 확인 팝업창
*  PERFORM confirm_create CHANGING lv_answer.
*
**-- 확인 후 계정과목코드 자동채번
*  IF lv_answer NE '1'.
*    EXIT.
*  ELSEIF lv_answer EQ '1'.
*    PERFORM get_saknr.
*  ENDIF.
*
*
*  "계정과목 생성
*  CLEAR : gs_gldata.
*  gs_gldata-bukrs = gv_buk.
*  gs_gldata-ktopl = gv_kto.
*  gs_gldata-gl_flag = gv_fla.
*  gs_gldata-gjgrp = gv_gjgr2.
*  gs_gldata-saknr = gv_sak.
*  gs_gldata-txt50 =  gv_txt .
*  gs_gldata-erdat = sy-datum.
*  gs_gldata-ernam = sy-uname.
*  gs_gldata-erzet = sy-uzeit.
*  APPEND gs_gldata TO gt_gldata.
*
*  " 신규 데이터 DB 저장
*  MODIFY  zc302mt0006 FROM TABLE gt_gldata.
*
*
*  IF  sy-subrc EQ 0.
*    MESSAGE s001 WITH TEXT-i01.
*  ELSE.
*    ROLLBACK WORK.
*    MESSAGE s001 WITH TEXT-i02 DISPLAY LIKE 'E'.
*  ENDIF.
*
*  CALL METHOD go_alv_grid2->refresh_table_display.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form confirm_create
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM confirm_create  CHANGING pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'SAVE DIALOG'
      diagnose_object       = ' '
      text_question         = '계정을 생성 하시겠습니까?'
      text_button_1         = 'YES'(001)
      icon_button_1         = 'ICON_OKAY'
      text_button_2         = 'NO'(002)
      icon_button_2         = 'ICON_CANCLE'
      default_button        = '1'
      display_cancel_button = ''
    IMPORTING
      answer                = pv_answer.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_saknr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_saknr .
*
*  CASE gv_gjgr2.
*    WHEN 'CA'.
*      PERFORM make_docunum USING '01'.
*    WHEN 'NA'.
*      PERFORM make_docunum USING '02'.
*    WHEN 'CL'.
*      PERFORM make_docunum USING '03'.
*    WHEN 'NL'.
*      PERFORM make_docunum USING '04'.
*    WHEN 'CP'.
*      PERFORM make_docunum USING '05'.
*    WHEN 'RV'.
*      PERFORM make_docunum USING '06'.
*    WHEN 'EP'.
*      PERFORM make_docunum USING '07'.
*  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_docunum
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM make_docunum   USING    pv_num.

*  CALL FUNCTION 'NUMBER_GET_NEXT'
*    EXPORTING
*      nr_range_nr = pv_num
*      object      = 'ZNRC306_1'
*    IMPORTING
*      number      = gv_number.
*
*  CONCATENATE 'ACC' gv_number INTO gv_sak.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form download_excel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM download_excel .

  DATA : lv_filename TYPE rlgrap-filename,
         lv_msg(100).

*-- Call windows browser : 다운로드 위치에 대한 경로명 생성
  CLEAR : w_pfolder.
  PERFORM get_browser_info.

  IF w_pfolder IS INITIAL.
    EXIT.
  ENDIF.

  " 다운로드 파일명 세팅해줌
  CLEAR lv_filename.
  CONCATENATE w_pfolder '\' 'Data_Upload_Form' '.Xls' INTO lv_filename.


  PERFORM download_template USING lv_filename. " 템플릿 다운로드

ENDFORM.
*&---------------------------------------------------------------------*
*& Form download_template
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_FILENAME
*&---------------------------------------------------------------------*
FORM download_template   USING    pv_filename.

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
   WHERE objid = 'ZC306_XLS_FORM_FI_GL'. " FORM NAME

  CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
    EXPORTING
      key         = wwwdata_item
      destination = gv_file.


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

  IF sy-uname NE 'KDT-C-12' AND
     sy-uname NE 'KDT-C-06'.
    MESSAGE i001 WITH TEXT-e06 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 업로드할 파일 찾는 로직
  PERFORM get_filepath.

**********************************************************************
*-- 엑셀 업로드
  TYPES: truxs_t_text_data(4096)   TYPE c OCCURS 0.

  DATA: lt_raw_data  TYPE truxs_t_text_data,
        lt_excel     LIKE TABLE OF alsmex_tabline WITH HEADER LINE,
        lv_index     LIKE sy-tabix,
        lv_file_path TYPE rlgrap-filename.

  FIELD-SYMBOLS:  <field>.

**-- 파일 경로가 없는 경우 에러 메시지 디스플레이
  IF gv_file IS INITIAL.
    MESSAGE s001(k5) WITH '업로드 할 파일을 선택하세요' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  CLEAR : gt_excel, gs_excel, lv_index.

  lv_file_path = gv_file.

*-- Excel 파일 데이터 변환하여 읽어오기
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = lv_file_path
      i_begin_col             = 1
      i_begin_row             = 3
      i_end_col               = 100
      i_end_row               = 50000
    TABLES
      intern                  = lt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc = 1.
    MESSAGE s001 WITH '파일 변환 실패'.
    EXIT.
  ELSEIF sy-subrc <> 0.
    MESSAGE s001 WITH '파일 열기 실패'.
    EXIT.
  ENDIF.

  CHECK NOT ( lt_excel[] IS INITIAL ).

  SORT lt_excel BY row col.


*-- 한 줄씩 itab에 append
  LOOP AT lt_excel.

    lv_index = lt_excel-col.
    ASSIGN COMPONENT lv_index OF STRUCTURE gs_excel TO <field>.
    <Field> = lt_excel-value.

    AT END OF row.

      " 필수 데이터 확인
      IF ( gs_excel-bukrs IS NOT INITIAL ) AND
         ( gs_excel-ktopl IS NOT INITIAL ) AND
         ( gs_excel-txt50 IS NOT INITIAL ) AND
         ( gs_excel-gjgrp IS NOT INITIAL ) AND
         ( gs_excel-gl_flag IS NOT INITIAL ) .
        APPEND gs_excel TO gt_excel.
        CLEAR gs_excel.
      ELSE.
        MESSAGE s001 WITH '유효하지 않는 데이터가 포함되어있습니다.' '데이터를 확인하세요.' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.
    ENDAT.

  ENDLOOP.

  PERFORM make_excel_data.
  CALL SCREEN 101 STARTING AT 03 05.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_filepath
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_filepath .

  DATA : lt_files     TYPE filetable,
         ls_files     LIKE LINE OF lt_files,
         lv_filter    TYPE string,
         lv_path      TYPE string,
         lv_rc        TYPE i,
         lv_file_path TYPE rlgrap-filename.

*-- 확장자가 .xlsx인 파일만 필터링
  CONCATENATE cl_gui_frontend_services=>filetype_excel
              'Excel 통합 문서(*.XLSX)|*.XLSX|'
              INTO lv_filter.


*-- 파일 경로 가져오기
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = 'File open'
      file_filter             = lv_filter
      initial_directory       = lv_path
    CHANGING
      file_table              = lt_files
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.


  CHECK sy-subrc EQ 0.
  ls_files = VALUE #( lt_files[ 1 ] OPTIONAL ).

*-- 파일 경로명 세팅
  gv_file = ls_files-filename.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_excel_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_excel_data .


*-- 업로드 되면서 자동 채번
  CLEAR : gt_popbody, gs_popbody, gs_gldata.
  LOOP AT gt_excel INTO gs_excel.

    gs_gldata = CORRESPONDING #( gs_excel ).

    PERFORM set_saknr_excel.

    gs_POPBODY = CORRESPONDING #( gs_gldata ).

    gs_POPBODY-erdat = sy-datum.
    gs_POPBODY-ernam = sy-uname.
    gs_POPBODY-erzet = sy-uzeit.

    APPEND gs_POPBODY TO gt_POPBODY.
    CLEAR gs_POPBODY.
  ENDLOOP.

*-- 업로드 데이터 ITAB APPEND

*-- ALV 반영
*  MODIFY zc302mt0006 FROM TABLE gt_gldata.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_saknr_excel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_saknr_excel .

  CASE gs_gldata-gjgrp.
    WHEN 'CA'.
      PERFORM make_docunum_excel USING '01'.
    WHEN 'NA'.
      PERFORM make_docunum_excel USING '02'.
    WHEN 'CL'.
      PERFORM make_docunum_excel USING '03'.
    WHEN 'NL'.
      PERFORM make_docunum_excel USING '04'.
    WHEN 'CP'.
      PERFORM make_docunum_excel USING '05'.
    WHEN 'RV'.
      PERFORM make_docunum_excel USING '06'.
    WHEN 'EP'.
      PERFORM make_docunum_excel USING '07'.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_docunum_excel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM make_docunum_excel  USING pv_gjgrp.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = pv_gjgrp
      object      = 'ZNRC306_1'
    IMPORTING
      number      = gv_number.

  CONCATENATE 'ACC' gv_number INTO gs_gldata-saknr.

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
      window_title    = 'Download Path'
      initial_folder  = w_initialfolder
    CHANGING
      selected_folder = w_pickedfolder.

  IF sy-subrc = 0.
    W_pfolder = w_pickedfolder.
  ELSE.
    MESSAGE i001 WITH '폴더 선택에 오류가 발생했습니다.' DISPLAY LIKE 'E'.
    STOP.
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

  IF go_popcont IS NOT BOUND.

    CLEAR : gs_pfcat, gt_pfcat.
    PERFORM set_pop_fieldcat USING :  'X' 'BUKRS' '회사 코드' 'C' 'X',
                                      'X' 'KTOPL' '계정과목표' 'C' 'X',
                                      'X' 'SAKNR' '계정과목코드' 'C' 'X',
                                      ' ' 'TXT50' '계정과목명' 'C' ' ',
                                      ' ' 'GJGRP' '계정 그룹' 'C' ' ',
                                      ' ' 'GL_FLAG' '계정 유형' 'C' ' ',
                                      ' ' 'BPCODE' '거래처 코드' 'C' ' '.

    PERFORM set_playout.

    PERFORM create_pobject.

    CALL METHOD go_pop_grid->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        i_save               = 'A'
        i_default            = 'X'
        is_layout            = gs_playout
        it_toolbar_excluding = gt_ui_functions
      CHANGING
        it_outtab            = gt_popbody
        it_fieldcatalog      = gt_pfcat.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_pop_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_pop_fieldcat  USING  pv_key pv_field pv_table pv_just pv_emph.

  gs_Pfcat-key = pv_key.
  gs_Pfcat-fieldname = pv_field.
  gs_Pfcat-coltext = pv_table.
  gs_Pfcat-just = pv_just.
  gs_Pfcat-emphasize = pv_emph.

  APPEND gs_pfcat TO gt_pfcat.
  CLEAR : gs_pfcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_playout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_playout .

  gs_playout-zebra = 'X'.
  gs_playout-cwidth_opt = 'A'.
  gs_playout-sel_mode = 'D'.
*  gs_playout-no_toolbar = abap_true.
  gs_playout-grid_title = '엑셀업로드 미리보기'.
  gs_playout-smalltitle = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_pobject
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_pobject .

  CREATE OBJECT go_popcont
    EXPORTING
      container_name = 'POP_CONT'.

  CREATE OBJECT go_pop_grid
    EXPORTING
      i_parent = go_popcont.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_excelpop
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_excelpop .

  DATA : lv_answer.

*-- confirm for save
  PERFORM confirm CHANGING lv_answer.

  IF lv_answer NE 1.
    EXIT.
  ENDIF.


  MODIFY zc302mt0006 FROM TABLE gt_popbody.

  IF sy-subrc EQ 0.

*-- ALV 반영
    APPEND gs_gldata TO gt_gldata.
    MESSAGE s001 WITH TEXT-i01 '데이터를 성공적으로 저장했습니다.'.
    CALL METHOD go_alv_grid2->refresh_table_display.

  ELSE.
    MESSAGE s001 WITH TEXT-i02  DISPLAY LIKE 'E'.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form confirm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM confirm   CHANGING pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'SAVE DIALOG'
      text_question         = '저장 하시겠습니까?'
      text_button_1         = 'YES'(001)
      icon_button_1         = 'ICON_OKAY'
      text_button_2         = 'NO'(002)
      icon_button_2         = 'ICON_CANCEL'
      default_button        = '1'
      display_cancel_button = ''
    IMPORTING
      answer                = pv_answer.

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
           bpcode TYPE zc302mt0001-bpcode,
           cname  TYPE zc302mt0001-cname,
         END OF ls_bpcode,
         lt_bpcode LIKE TABLE OF ls_bpcode.

  SELECT  bpcode cname
    INTO CORRESPONDING FIELDS OF TABLE lt_bpcode
    FROM zc302mt0001
   ORDER BY bpcode.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BPCODE'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GV_BPCO'
      value_org       = 'S'
    TABLES
      value_tab       = lt_bpcode
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
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
  CLEAR gs_button.
  Gs_button-butn_type = 3.
  APPEND gs_button TO po_object->mt_toolbar.

  CLEAR gs_button.
  gs_button-function = 'TOGL'.
  gs_button-icon = icon_toggle_display_change.
  gs_button-quickinfo = 'DISPLAY <-> CHANGE'.
  APPEND gs_button TO po_object->mt_toolbar.


  IF gv_mode EQ 'E'.

    CLEAR gs_button.
    gs_button-function = 'DROW'.
    gs_button-icon = icon_delete_row.
    gs_button-quickinfo = 'DELETE ROW'.
    APPEND gs_button TO po_object->mt_toolbar.

    CLEAR gs_button.
    gs_button-function = 'TSAVE'.
    gs_button-icon = icon_system_save.
    gs_button-quickinfo = 'TOOLBAR_SAVE'.
    APPEND gs_button TO po_object->mt_toolbar.

  ENDIF.
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
    WHEN 'DROW'.
      PERFORM process_row USING 'D'.
    WHEN 'TOGL'.
      PERFORM process_row USING 'T'.
    WHEN 'TSAVE'.
      PERFORM save_data.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_row
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM process_row  USING   pv_job.

  DATA : ls_style TYPE lvc_s_styl,
         lt_row   TYPE lvc_t_row,
         ls_row   TYPE lvc_s_row.

  CASE pv_job.
    WHEN 'T'.
      CASE gv_mode.
        WHEN 'E'.
          gv_mode = 'D'.
          CALL METHOD go_alv_grid2->set_ready_for_input
            EXPORTING
              i_ready_for_input = 0.

        WHEN 'D'.
          gv_mode = 'E'.
          CALL METHOD go_alv_grid2->set_ready_for_input
            EXPORTING
              i_ready_for_input = 1.
      ENDCASE.

    WHEN 'D'.
      CALL METHOD go_alv_grid2->get_selected_rows
        IMPORTING
          et_index_rows = lt_row.

      IF lt_row IS INITIAL.
        MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
        EXIT.                        "???
      ENDIF.

      SORT lt_row BY index DESCENDING.

      LOOP AT lt_row INTO ls_row.

        CLEAR gs_gldata.
        READ TABLE gt_gldata INTO gs_gldata INDEX ls_row-index.

        MOVE-CORRESPONDING gs_gldata TO gs_delt.
        APPEND gs_delt TO gt_delt.

        DELETE gt_gldata INDEX ls_row-index.
      ENDLOOP.

      CALL METHOD go_alv_grid2->refresh_table_display.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_data .

  DATA : lt_save   TYPE TABLE OF  zc302mt0006,
         ls_save   TYPE zc302mt0006,
         lv_tabix  TYPE sy-tabix,
         lv_answer.


  CALL METHOD go_alv_grid2->check_changed_data.

  " Alv의 데이터를 lt_save에 저장
  MOVE-CORRESPONDING gt_gldata TO lt_save.

  " Lt_save에 값이 존재하지 않고, gt_gldata에도 값이 존재하지 않으면 에러 메시지
  IF ( lt_save IS INITIAL ) AND
     ( gt_gldata IS INITIAL ) .
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'e'.
    EXIT.
  ENDIF.

  " 저장할 지 확인하는 알림창 띄우기
  PERFORM confirm CHANGING lv_answer.

  " 사용자가 저장하지 않는다고 하면, 프로그램 나가기.
  IF lv_answer NE '1'.
    EXIT.
  ENDIF.

  LOOP AT lt_save INTO ls_save.
    Lv_tabix = sy-tabix.

    IF ls_save IS INITIAL.
      Ls_save-erdat = sy-datum.
      Ls_save-ernam = sy-uname.
      Ls_save-erzet = sy-uzeit.

    ELSE.
      Ls_save-aedat = sy-datum.
      Ls_save-aenam = sy-uname.
      Ls_save-aezet = sy-uzeit.

    ENDIF.

    MODIFY lt_save FROM ls_save INDEX lv_tabix
                                TRANSPORTING erdat ernam erzet
                                             erdat aenam aezet.

  ENDLOOP.

  IF gt_delt IS NOT INITIAL.
    DELETE zc302mt0006 FROM TABLE gt_delt.
  ENDIF.

  MODIFY zc302mt0006 FROM TABLE lt_save.
  IF sy-subrc = 0.
    COMMIT WORK AND WAIT.
    PERFORM get_base_data.
    CALL METHOD go_alv_grid2->refresh_table_display.
    MESSAGE s102.
  ELSE.
    ROLLBACK WORK.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
  ENDIF.

  CALL METHOD go_alv_grid2->refresh_table_display.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_alv .



ENDFORM.
