*&---------------------------------------------------------------------*
*& Include          ZC302RPMM0005F01
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

*-- excel
  PERFORM get_body_data.

*-- header
  PERFORM get_header_data.

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

    PERFORM set_field_catalog USING : 'X' 'MATNR'     'ZC302MMT0013' 'C' ' ',
                                      'X' 'SCODE'     'ZC302MMT0013' 'C' ' ',
                                      ' ' 'MAKTX'     'ZC302MMT0013' ' ' 'X',
                                      ' ' 'MTART'     'ZC302MMT0013' 'C' ' ',
                                      ' ' 'SNAME'     'ZC302MMT0013' 'C' ' ',
                                      ' ' 'ADDRESS'   'ZC302MMT0013' ' ' 'X',
                                      ' ' 'H_RTPTQUA' 'ZC302MMT0013' 'C' ' ',
                                      ' ' 'MEINS'     'ZC302MMT0013' 'C' ' '.

    PERFORM set_layout.
    PERFORM create_object.

    gv_variant-report = sy-repid.
    gv_variant-handle = 'ALV1'.

    CALL METHOD go_alv_grid->set_table_for_first_display
      EXPORTING
        is_variant                    = gs_variant
        i_save                        = 'A'
        i_default                     = 'X'
        is_layout                     = gs_layout
      CHANGING
        it_outtab                     = gt_inventory
        it_fieldcatalog               = gt_fcat.

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
    WHEN 'H_RTPTQUA'.
      gs_fcat-qfieldname = 'MEINS'.
      gs_fcat-coltext    = '수량'.
    WHEN 'MEINS'.
      gs_fcat-coltext    = '단위'.
    WHEN 'MTART_T'.
      gs_fcat-coltext    = '자재유형'.
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
  gs_layout-grid_title = '완제품 엑셀 업로드'.
  gs_layout-smalltitle = abap_true.

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
      container_name    = 'MAIN_CONT'.

  CREATE OBJECT go_alv_grid
    EXPORTING
      i_parent          = go_container.


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

**********************************************************************
* Upload 할 파일을 찾는다
**********************************************************************

  DATA : lt_files  TYPE filetable,
         ls_files  LIKE LINE OF lt_files,
         lv_filter TYPE string,
         lv_path   TYPE string,
         lv_rc     TYPE i.

  CONCATENATE cl_gui_frontend_services=>filetype_excel
  'Excel 통합 문서(*.XLSX)|*.XLSX|'
  INTO lv_filter.

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

*  CLEAR ls_files.
  gv_file = ls_files-filename.

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
**********************************************************************
* Excel Upload 로직
**********************************************************************

  TYPES: truxs_t_text_data(4096) TYPE c OCCURS 0.

  DATA: lt_raw_data  TYPE truxs_t_text_data,
        lt_excel     LIKE TABLE OF alsmex_tabline WITH HEADER LINE,
        lv_index     LIKE sy-tabix,
        lv_file_path TYPE rlgrap-filename.

  FIELD-SYMBOLS:  <field>.

  CLEAR : gt_excel, gs_excel, lv_index.

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

  IF sy-subrc = 1.
    MESSAGE s001(k5) WITH TEXT-s01.
    EXIT.
  ELSEIF sy-subrc <> 0.
    MESSAGE s001(k5) WITH TEXT-e01 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  CHECK NOT ( lt_excel[] IS INITIAL ).

  SORT lt_excel BY row col.

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

  CLEAR : gs_inventory, gt_inventory.
  PERFORM get_master.

  LOOP AT gt_excel INTO gs_excel.
    gv_tabix = sy-tabix.

    CASE gs_excel-matnr(2).
*-- 완제품만 업로드 가능
      WHEN 'CP'.
        gs_inventory = CORRESPONDING #( gs_excel ).
        IF ( gs_inventory-maktx IS INITIAL ) AND ( gs_inventory-mtart IS INITIAL ).   " 자재명과 자재분류가 비었을 경우
*-- 자재명 끌어오기
          READ TABLE gt_venm INTO gs_venm WITH KEY matnr = gs_inventory-matnr.
          gs_inventory-maktx = gs_venm-maktx.
          gs_inventory-mtart = gs_venm-mtart.
        ENDIF.
*-- 창고명, 창고 주소 끌어오기
        IF ( gs_inventory-sname IS INITIAL ) AND ( gs_inventory-address IS INITIAL ). " 창고명과 소재지가 비었을 경우
         READ TABLE gt_st INTO gs_st WITH KEY scode = gs_inventory-scode.
         gs_inventory-sname = gs_st-sname.
         gs_inventory-address = gs_st-address.
        ENDIF.
*-- alv append
        APPEND gs_inventory TO gt_inventory.
        CLEAR gs_inventory.
*-- 완제품이 아닌 것들은 저장되지않음
      WHEN OTHERS.
        MESSAGE i001 WITH text-s02 DISPLAY LIKE 'E'.
    ENDCASE.


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
   WHERE objid = 'ZC321_XLS_FORM_MM'. " Form name

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

  DATA : lt_save_h TYPE TABLE OF zc302mmt0013,
         ls_save_h TYPE zc302mmt0013,
         lt_save_i TYPE TABLE OF zc302mmt0002,
         ls_save_i TYPE zc302mmt0002,
         lv_pk(10),
         lv_s_pk(10),
         lt_save_h_doc TYPE TABLE OF zc302mmt0011, "자재문서 header
         ls_save_h_doc TYPE zc302mmt0011, "자재문서 header
         lt_save_i_doc TYPE TABLE OF zc302mmt0012, "자재문서 item
         ls_save_i_doc TYPE zc302mmt0012. "자재문서 item

*--------------------------------------------------------------------*
* HEADER
*--------------------------------------------------------------------*
*-- HEADER에 엑셀 업로드 데이터 저장
   MOVE-CORRESPONDING gt_inventory TO lt_save_h.
   LOOP AT lt_save_h INTO ls_save_h.
      gv_tabix = sy-tabix.
      lv_pk = ls_save_h-matnr.
      lv_s_pk = ls_save_h-scode.

*-- 만약 헤더에 추가하려는 재고가 존재한다면 ITEM에만 추가되고 HEADER 수량만큼 더해줌
      SELECT SINGLE *
        INTO @DATA(ls_data)
        FROM zc302mmt0013
       WHERE matnr = @lv_pk.

*-- 동일 자재가 있다면
    IF ls_data IS NOT INITIAL.

       READ TABLE gt_header INTO gs_header WITH KEY matnr = lv_pk
                                                    scode = lv_s_pk.

      " 헤더 기존수량에추가되는 수량을 더하기
      ls_save_h-h_rtptqua = gs_header-h_rtptqua + ls_save_h-h_rtptqua.

      " 수정 정보 저장
      ls_save_h-aedat = sy-datum.
      ls_save_h-aenam = sy-uname.
      ls_save_h-aezet = sy-uzeit.

      MODIFY lt_save_h FROM ls_save_h INDEX gv_tabix TRANSPORTING h_rtptqua aedat aenam aezet .
    ELSE.
      ls_save_h-erdat = sy-datum.
      ls_save_h-ernam = sy-uname.
      ls_save_h-erzet = sy-uzeit.

      MODIFY lt_save_h FROM ls_save_h INDEX gv_tabix TRANSPORTING erdat ernam erzet .
    ENDIF.
   ENDLOOP.

*--------------------------------------------------------------------*
* ITEM
*--------------------------------------------------------------------*
*-- ITEM 생성일 SY-DATUM 저장
   MOVE-CORRESPONDING gt_inventory TO lt_save_i.
   LOOP AT lt_save_i INTO ls_save_i.
      gv_tabix = sy-tabix.

      lv_pk = ls_save_i-matnr.
      lv_s_pk = ls_save_h-scode.
      READ TABLE gt_inventory INTO gs_inventory WITH KEY matnr = lv_pk
                                                         scode = lv_s_pk.

*-- 생성일
      ls_save_i-bdatu = sy-datum.
*-- 아이템 수량
      ls_save_i-i_rtptqua = gs_inventory-h_rtptqua.
*-- time
      ls_save_i-erdat = sy-datum.
      ls_save_i-ernam = sy-uname.
      ls_save_i-erzet = sy-uzeit.

      MODIFY lt_save_i FROM ls_save_i INDEX gv_tabix TRANSPORTING bdatu i_rtptqua erdat ernam erzet .
    ENDLOOP.


*-- db에 저장
    MODIFY zc302mmt0013 FROM TABLE lt_save_h.
    MODIFY zc302mmt0002 FROM TABLE lt_save_i.

    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
      PERFORM refresh_table.
      MESSAGE s001 WITH TEXT-s01.
    ELSE.
      MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
      ROLLBACK WORK.
    ENDIF.

**********************************************************************
* 자재문서
**********************************************************************
*--------------------------------------------------------------------*
* 자재문서 header
*--------------------------------------------------------------------*
    CLEAR gs_mt_doc.
*-- 자재문서 header
    CALL FUNCTION 'NUMBER_GET_NEXT' "자재문서번호 채번
      EXPORTING
        nr_range_nr                  = '02' "입고가 몇번이더라
        object                       = 'ZC321MMMD'
     IMPORTING
       number                        = gs_mt_doc-mblnr.
     CONCATENATE 'MD' gs_mt_doc-mblnr+2(8) INTO gs_mt_doc-mblnr.
    gs_mt_doc-movetype = 'A'.       " 자재이동유형
    gs_mt_doc-mjahr    =  sy-datum(4). " 자재문서연도

*-- 타임스탬프 추가
    ls_save_h_doc-erdat = sy-datum.
    ls_save_h_doc-erzet = sy-uzeit.
    ls_save_h_doc-ernam = sy-uname.

*-- GT_MT_DOC의 헤더 관련된 필드만 복사
    MOVE-CORRESPONDING gs_mt_doc TO ls_save_h_doc.

*-- 자재문서 header 테이블
    MODIFY zc302mmt0011 FROM ls_save_h_doc.

*--------------------------------------------------------------------*
* 자재문서 item
*--------------------------------------------------------------------*
*-- 자재문서 item

  LOOP AT gt_inventory INTO gs_inventory.

    gv_tabix = sy-tabix.

    gs_mt_doc-matnr =  gs_inventory-matnr.     " 자재코드
    gs_mt_doc-maktx =  gs_inventory-maktx.     " 자재명
    gs_mt_doc-menge =  gs_inventory-h_rtptqua. " 수량
    gs_mt_doc-meins =  gs_inventory-meins.     " 단위
    gs_mt_doc-scode =  gs_inventory-scode.     " 창고코드
    gs_mt_doc-meins =  gs_inventory-meins.     " 단위
    gs_mt_doc-budat =  sy-datum.               " 날짜

    MODIFY gt_mt_doc FROM gs_mt_doc INDEX gv_tabix TRANSPORTING matnr maktx menge meins
                                                                scode meins budat.

    MOVE-CORRESPONDING gs_inventory TO gs_mt_doc.
    MOVE-CORRESPONDING gs_mt_doc    TO ls_save_i_doc.

*-- 자재문서 item 테이블
    MODIFY zc302mmt0012 FROM ls_save_i_doc.

  ENDLOOP.

  IF sy-subrc = 0.
    COMMIT WORK AND WAIT.
    MESSAGE s001 WITH TEXT-s01.
    PERFORM refresh_table.
  ELSE.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_body_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_body_data .

  SELECT matnr scode maktx mtart sname
         address h_rtptqua meins
    INTO CORRESPONDING FIELDS OF TABLE gt_inventory
    FROM zc302mmt0013.

   CLEAR : gt_inventory.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_header_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_header_data .

   SELECT matnr scode maktx mtart sname
         address h_rtptqua meins
    INTO CORRESPONDING FIELDS OF TABLE gt_header
    FROM zc302mmt0013.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_master
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_master .

  SELECT matnr maktx mtart
    INTO CORRESPONDING FIELDS OF TABLE gt_venm
    FROM zc302mt0007.

  SELECT scode sname address
    INTO CORRESPONDING FIELDS OF TABLE gt_st
    FROM zc302mt0005.

ENDFORM.
