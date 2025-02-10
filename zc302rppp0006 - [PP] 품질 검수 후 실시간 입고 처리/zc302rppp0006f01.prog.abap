*&---------------------------------------------------------------------*
*& Include          ZC302RPPP0006F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_batch_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_batch_data .

  CLEAR gt_batch_log.
  SELECT a~jobname a~jobcount b~progname a~sdluname a~sdlstrtdt a~sdlstrttm
         a~reldate a~reltime a~strtdate a~strttime a~enddate a~endtime a~status
    INTO CORRESPONDING FIELDS OF TABLE gt_batch_log
    FROM tbtco AS a LEFT OUTER JOIN tbtcp AS b
      ON a~jobname  EQ b~jobname
     AND a~jobcount EQ b~jobcount
   WHERE a~jobname EQ pa_name.

  SORT gt_batch_log BY sdlstrtdt sdlstrttm.

  IF gt_batch_log IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
  ENDIF.

  gv_count = lines( gt_batch_log ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_display_batch
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_batch .

  LOOP AT gt_batch_log ASSIGNING FIELD-SYMBOL(<fs_batch>).

    CASE <fs_batch>-status.
      WHEN 'A'.
        <fs_batch>-rl_status = 'Cancelled'.
      WHEN 'F'.
        <fs_batch>-rl_status = 'Finished'.
      WHEN 'P'.
        <fs_batch>-rl_status = 'Scheduled'.
      WHEN 'R'.
        <fs_batch>-rl_status = 'Running'.
      WHEN 'S'.
        <fs_batch>-rl_status = 'Released'.
      WHEN 'Y'.
        <fs_batch>-rl_status = 'Ready'.
      WHEN 'X'.
        <fs_batch>-rl_status = 'Unknown_state'.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_base_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_base_data .

*-- 검수 정보 가져온다.
  PERFORM get_qual_check_data.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_progress
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_progress .

*-- 자재문서, 재고관리, 생산실적을 위해 데이터를 가져온다.
  PERFORM get_sub_data.

*-- 검수정보의 각 데이터마다 발생시킨다.
  PERFORM make_display.




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

    CLEAR gt_fcat.
    PERFORM set_field_catalog USING: 'X' 'JOBNAME'   'Job 이름'      ' ' ' ',
                                     'X' 'JOBCOUNT'  'Job ID'        ' ' ' ',
                                     ' ' 'PROGNAME'  '프로그램 이름' ' ' ' ',
                                     ' ' 'SDLUNAME'  '사용자'        ' ' ' ',
                                     ' ' 'SDLSTRTDT' '스케줄 일자'   ' ' ' ',
                                     ' ' 'SDLSTRTTM' '스케줄 시간'   ' ' ' ',
                                     ' ' 'RELDATE'   '릴리즈 일자'   ' ' ' ',
                                     ' ' 'RELTIME'   '릴리즈 시간'   ' ' ' ',
                                     ' ' 'STRTDATE'  '배치 시작일자' ' ' ' ',
                                     ' ' 'STRTTIME'  '배치 시작시간' ' ' ' ',
                                     ' ' 'ENDDATE'   '배치 종료일자' ' ' ' ',
                                     ' ' 'ENDTIME'   '배치 종료시간' ' ' ' ',
                                     ' ' 'RL_STATUS' '상태'          ' ' 'X'.
    PERFORM set_layout.
    PERFORM create_object.

    PERFORM exclude_toolbar TABLES gt_ui_functions.

    SET HANDLER lcl_event_handler=>top_of_page FOR go_alv_grid.

    CALL METHOD go_alv_grid->set_table_for_first_display
      EXPORTING
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_layout
        is_variant      = gs_variant
      CHANGING
        it_outtab       = gt_batch_log
        it_fieldcatalog = gt_fcat.

    PERFORM register_event.

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
FORM set_field_catalog  USING pv_key pv_field pv_text pv_just pv_emph.

  gs_fcat = VALUE #( key       = pv_key
                     fieldname = pv_field
                     coltext   = pv_text
                     just      = pv_just
                     emphasize = pv_emph ).


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

  gs_layout = VALUE #( zebra      = abap_true
                     cwidth_opt = 'A'
                     sel_mode   = 'D'
                     grid_title = '로그 기록 정보'
                     smalltitle = abap_true ).

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
      repid     = sy-cprog                      " 현재 프로그램(Function, Class Method 등)을 호출한 프로그램의 ID
      dynnr     = sy-dynnr                      " 현재 Screen number
      side      = go_top_container->dock_at_top
      extension = 38.

  CREATE OBJECT go_container
    EXPORTING
      repid     = sy-cprog
      dynnr     = sy-dynnr
      side      = go_container->dock_at_left
      extension = 3000.

  CREATE OBJECT go_alv_grid
    EXPORTING
      i_parent = go_container.

* Create TOP-Document
  CREATE OBJECT go_dyndoc_id
    EXPORTING
      style = 'ALV_GRID'.     " 문서 내에서 텍스트의 스타일을 지정하는 옵션 설정

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_UI_FUNCTIONS
*&---------------------------------------------------------------------*
FORM exclude_toolbar  TABLES   pt_ui_functions TYPE ui_functions.

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
*& Form register_event
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM register_event .

  " 문서의 기본 속성(배경색 등)을 설정하는데 사용
  CALL METHOD go_dyndoc_id->initialize_document
    EXPORTING
      background_color = cl_dd_area=>col_textarea. " SAP 시스템에서 정의된 표준 색상으로 지정

  " ALV에서 TOP-OF-PAGE 이번트가 발생할 때 초기화된 동적 문서(go_dynoc_id)를 출력하도록 설정
  CALL METHOD go_alv_grid->list_processing_events
    EXPORTING
      i_event_name = 'TOP_OF_PAGE' " 이벤트 이름 지정
      i_dyndoc_id  = go_dyndoc_id. " 이벤트에서 사용할 동적 문서 객체

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

  DATA : lr_dd_table TYPE REF TO cl_dd_table_element, " 동적문서 내에서 테이블 요소를 생성하고 관리하는데 사용
         col_field   TYPE REF TO cl_dd_area,          " 동적문서 내에서 텍스트나 다른 요소들을 구분하여 배치할 수 있는 구조를 제공
         col_value   TYPE REF TO cl_dd_area,
         col_value2  TYPE REF TO cl_dd_area.

  DATA : lv_text  TYPE sdydo_text_element,
         lv_text2 TYPE sdydo_text_element.

  CALL METHOD go_dyndoc_id->add_table
    EXPORTING
      no_of_columns = 2
      border        = '0'
    IMPORTING
      table         = lr_dd_table.

*-- Set column
  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_field.

  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_value.

  lv_text = pa_name.
  PERFORM add_row USING lr_dd_table col_field col_value col_value2 '백그라운드 잡 이름' lv_text.

  lv_text = gv_count.
  PERFORM add_row USING lr_dd_table col_field col_value col_value2 '데이터 개수' lv_text.

*-- top_of_page 실행 (없으면 dump)
  PERFORM set_top_of_page.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_row
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LR_DD_TABLE
*&      --> COL_FIELD
*&      --> COL_VALUE
*&      --> COL_VALUE2
*&      --> P_
*&      --> LV_TEXT
*&---------------------------------------------------------------------*
FORM add_row  USING pr_dd_table  TYPE REF TO cl_dd_table_element
                    pv_col_field TYPE REF TO cl_dd_area
                    pv_col_value TYPE REF TO cl_dd_area
                    pv_col_value2 TYPE REF TO cl_dd_area
                    pv_field
                    pv_text.

  DATA : lv_text TYPE sdydo_text_element.

*-- Field.
  lv_text = pv_field.

  CALL METHOD pv_col_field->add_text
    EXPORTING
      text         = lv_text
      sap_emphasis = cl_dd_document=>strong
      sap_color    = cl_dd_document=>list_heading_inv.

*- Field쪽 gap
  CALL METHOD pv_col_field->add_gap
    EXPORTING
      width = 3.

*-- Value.
  lv_text = pv_text.

  CALL METHOD pv_col_value->add_text
    EXPORTING
      text         = lv_text
      sap_emphasis = cl_dd_document=>heading
      sap_color    = cl_dd_document=>list_negative_inv.

*- Value쪽 gap
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

* Creating html control
  IF go_html_cntrl IS INITIAL.
    CREATE OBJECT go_html_cntrl
      EXPORTING
        parent = go_top_container.
  ENDIF.

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
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_qual_check_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_qual_check_data .

  CLEAR gt_qcinfo.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_qcinfo
    FROM zc302ppt0011
   WHERE slwon EQ 'A'.

  IF gt_qcinfo IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_inv_manage_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_inv_manage_data .

  CLEAR gt_inv_h.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_inv_h
    FROM zc302mmt0013
   WHERE scode EQ 'ST03'.

  IF gt_qcinfo IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form mat_docu_generation
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM mat_docu_generation .

  DATA: lv_number(10).

*-- 자재문서 Header에 추가
  CLEAR gs_md_header.

  " 자재문서번호 채번 및 추가
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZC321MMMD'
    IMPORTING
      number      = lv_number.
  CONCATENATE 'MD' lv_number+2(8) INTO gv_mblnr.

  gs_md_header-mblnr    = gv_mblnr.       " 자재문서번호
  gs_md_header-mjahr    = sy-datum(4).    " 자재문서연도
  gs_md_header-movetype = 'A'.             " 자재이동유형
  gs_md_header-ponum    = gs_qcinfo-ponum. " 생산오더번호

  APPEND gs_md_header TO gt_md_header.

*-- 자재문서 Item에 추가
  CLEAR gs_md_item.

  gs_md_item-mblnr  = gv_mblnr.               " 자재문서번호
  gs_md_item-mjahr  = sy-datum(4).            " 자재문서연도
  gs_md_item-matnr  = gs_qcinfo-matnr.        " 자재코드
  gs_md_item-scode  = 'ST03'.                 " 창고코드
  gs_md_item-movetype = 'A'.                  " 자재이동유형
  gs_md_item-budat  = gs_qcinfo-ppend + '06'. " 입고날짜 = 공정 종료일 + 6일
  gs_md_item-menge  = gs_qcinfo-menge.        " 수량 = 최종생산량
  gs_md_item-meins  = gs_qcinfo-unit.         " 단위
  " 완제품 단가 및 통화키
  READ TABLE gt_mat INTO gs_mat WITH KEY matnr = gs_qcinfo-matnr.
  gs_md_item-netwr  = gs_mat-netwr.           " 완제품 단가
  gs_md_item-waers  = gs_mat-waers.           " 단가의 통화키

  gs_md_item-qinum  = gs_qcinfo-qinum.        " 품질검수번호
  gs_md_item-maktx  = gs_qcinfo-maktx.        " 자재명

  APPEND gs_md_item TO gt_md_item.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_mat_master_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_mat_master_data .

  CLEAR gt_mat.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_mat
    FROM zc302mt0007
   WHERE matnr LIKE 'CP%'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_inv_managment
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM add_inv_managment .

*-- 재고관리 Header
  READ TABLE gt_inv_h INTO gs_inv_h WITH KEY matnr = gs_qcinfo-matnr.
  IF sy-subrc EQ 0.
    gs_inv_h-h_rtptqua += gs_qcinfo-menge.
  ENDIF.

  MODIFY gt_inv_h FROM gs_inv_h TRANSPORTING h_rtptqua
                                       WHERE matnr = gs_qcinfo-matnr
                                         AND scode = 'ST03'.

*-- 재고관리 Item
  CLEAR gs_inv_i.
  gs_inv_i-matnr = gs_qcinfo-matnr.  " 자재코드
  gs_inv_i-scode = 'ST03'.           " 창고코드

  " 생성일(유통기한)
*  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
*    EXPORTING
*      date      = gs_qcinfo-ppend
*      days      = '0'
*      months    = '0'
*      signum    = '+'
*      years     = '3'
*    IMPORTING
*      calc_date = gs_inv_i-bdatu.

  gs_inv_i-bdatu     = gs_qcinfo-ppend.     " 생성일(유통기한)
  gs_inv_i-sname     = '03'.                " 창고명
  gs_inv_i-maktx     = gs_qcinfo-maktx.     " 자재명
  gs_inv_i-mblnr     = gv_mblnr.            " 자재문서번호
  gs_inv_i-mtart     = '03'.                " 자재유형
  gs_inv_i-i_rtptqua = gs_qcinfo-menge. " 현재재고 = 최종생산량
  gs_inv_i-meins     = gs_qcinfo-unit.  " 단위

  APPEND gs_inv_i TO gt_inv_i.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form production_perform
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM production_perform .

  MOVE-CORRESPONDING gs_qcinfo TO gs_pro_per.

  " BOM_ID
  READ TABLE gt_bom INTO gs_bom WITH KEY matnr = gs_qcinfo-matnr.
  gs_pro_per-bomid = gs_bom-bomid.

  " 공정코드
  READ TABLE gt_pcode INTO gs_pcode WITH KEY matnr = gs_qcinfo-matnr.
  gs_pro_per-pcode = gs_pcode-pcode.

  gs_pro_per-pqua  = gs_qcinfo-rqamt. " 품질검수량 = 필요소요량
  gs_pro_per-mblnr = gv_mblnr.        " 자재문서번호
  gs_pro_per-mjahr = sy-datum(4).     " 자재문서연도

  APPEND gs_pro_per TO gt_pro_per.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_sub_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_sub_data .

*-- 재고관리 Header 가져온다. ( 수량 업데이트를 위해서 )
  PERFORM get_inv_manage_data.

*-- 자재마스터 데이터 가져온다. ( 단가를 위해서 )
  PERFORM get_mat_master_data.

*-- BOM Header 가져온다. ( BOM_ID를 위해서 )
  CLEAR gt_bom.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_bom
    FROM zc302ppt0004.

*-- 공정 Header 가져온다. ( 공정코드를 위해서 )
  CLEAR gt_pcode.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_pcode
    FROM zc302ppt0008.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_qcinfo_status
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_qcinfo_status USING pv_tabix.

  pv_tabix = sy-tabix.

  gs_qcinfo-slwon = 'B'.

  MODIFY gt_qcinfo FROM gs_qcinfo INDEX pv_tabix
                                  TRANSPORTING slwon.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display .

  DATA: lv_tabix TYPE sy-tabix.

  LOOP AT gt_qcinfo INTO gs_qcinfo.

    " 1. 자재문서를 발생시킨다. (자재문서 테이블에 데이터 추가)
    PERFORM mat_docu_generation.

    " 2. 재고관리에 수량을 채워준다. (Header & Item)
    PERFORM add_inv_managment.

    " 3. 생산실적 데이터를 생성한다.
    PERFORM production_perform.

    " 4. 검수정보 테이블의 상태를 'B'로 바꿔서 DB에 저장한다.
    PERFORM set_qcinfo_status USING lv_tabix.

    " 5. 폐기 있을 경우 폐기 보내준다.
    IF gs_qcinfo-dismenge > 0.
      PERFORM make_dis.
    ENDIF.

  ENDLOOP.

*  cl_demo_output=>display( gt_md_header ).
*  cl_demo_output=>display( gt_md_item ).
*  cl_demo_output=>display( gt_inv_h ).
*  cl_demo_output=>display( gt_inv_i ).
*  cl_demo_output=>display( gt_pro_per ).
*  cl_demo_output=>display( gt_qcinfo ).

*-- DB에 저장

  " 자재문서 header 저장
  PERFORM save_md_header.
  " 자재문서 item 저장
  PERFORM save_md_item.
  " 재고관리 header 저장
  PERFORM save_inv_h.
  " 재고관리 item 저장
  PERFORM save_inv_i.
  " 생산실적처리 저장
  PERFORM save_pro_per.
  " 검수정보 저장 (slwon)
  PERFORM save_qcinfo.
  " 페기 정보 저장
  IF gs_qcinfo-dismenge > 0.
    PERFORM save_dis.
  ENDIF.





ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_md_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_md_header .

  DATA : lt_save  TYPE TABLE OF zc302mmt0011,
         ls_save  TYPE zc302mmt0011,
         lv_tabix TYPE sy-tabix.

  MOVE-CORRESPONDING gt_md_header TO lt_save.

  IF lt_save IS INITIAL.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  "* Set Time Stamp (자재문서 Head)
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

  " DB에 저장
  MODIFY zc302mmt0011 FROM TABLE lt_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_md_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_md_item .

  DATA : lt_save  TYPE TABLE OF zc302mmt0012,
         ls_save  TYPE zc302mmt0012,
         lv_tabix TYPE sy-tabix.

  MOVE-CORRESPONDING gt_md_item TO lt_save.

  IF lt_save IS INITIAL.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  "* Set Time Stamp (자재문서 item)
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

  " DB에 저장
  MODIFY zc302mmt0012 FROM TABLE lt_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_inv_h
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_inv_h .

  DATA : lt_save  TYPE TABLE OF zc302mmt0013,
         ls_save  TYPE zc302mmt0013,
         lv_tabix TYPE sy-tabix.

  MOVE-CORRESPONDING gt_inv_h TO lt_save.

  IF lt_save IS INITIAL.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  "* Set Time Stamp (재고관리 Head)
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

  " DB에 저장
  MODIFY zc302mmt0013 FROM TABLE lt_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_inv_i
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_inv_i .

  DATA : lt_save  TYPE TABLE OF zc302mmt0002,
         ls_save  TYPE zc302mmt0002,
         lv_tabix TYPE sy-tabix.

  MOVE-CORRESPONDING gt_inv_i TO lt_save.

  IF lt_save IS INITIAL.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  "* Set Time Stamp (재고관리 item)
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

  " DB에 저장
  MODIFY zc302mmt0002 FROM TABLE lt_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_pro_per
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_pro_per .

  DATA : lt_save  TYPE TABLE OF zc302ppt0012,
         ls_save  TYPE zc302ppt0012,
         lv_tabix TYPE sy-tabix.

  MOVE-CORRESPONDING gt_pro_per TO lt_save.

  IF lt_save IS INITIAL.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  "* Set Time Stamp (생산실적처리)
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

  " DB에 저장
  MODIFY zc302ppt0012 FROM TABLE lt_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_qcinfo
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_qcinfo .

  DATA : lt_save  TYPE TABLE OF zc302ppt0011,
         ls_save  TYPE zc302ppt0011,
         lv_tabix TYPE sy-tabix.

  MOVE-CORRESPONDING gt_qcinfo TO lt_save.

  IF lt_save IS INITIAL.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  "* Set Time Stamp (검수정보)
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

  " DB에 저장
  MODIFY zc302ppt0011 FROM TABLE lt_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_init_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_init_value .

  pa_name = 'SYNCYOUNG_POGR_BATCH'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_dis
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_dis .

  CLEAR gs_dis.

  " 폐기번호 채번 및 추가
  gv_year   = sy-datum+2(2).
  gv_month  = sy-datum+4(2).
  gv_day    = sy-datum+6(2).

  IF gv_month < '10'.     " 10월 미만이면 한자리니 앞에 0 붙여주기
    CONCATENATE gv_year(2) '0' gv_month gv_day INTO gv_year.
  ELSE.
    CONCATENATE gv_year(2) gv_month(2) gv_day INTO gv_year.
  ENDIF.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZC302MMDN'
    IMPORTING
      number      = gs_dis-disnum.
  CONCATENATE 'DN' gv_year gs_dis-disnum INTO gs_dis-disnum.

  " 폐기문서
  gs_dis-scode     = 'ST03'.                          " 창고코드
  gs_dis-matnr     = gs_qcinfo-matnr.                 " 자재코드
  gs_dis-qinum     = gs_qcinfo-qinum.                 " 품질검수번호
  gs_dis-maktx     = gs_qcinfo-maktx.                 " 자재명
  gs_dis-disreason = gs_qcinfo-direason.              " 폐기사유 - 변수명 다르니 조심
  gs_dis-dismenge  = gs_qcinfo-dismenge.              " 폐기량
  gs_dis-budat     = gs_qcinfo-ppend + '06'.          " 입고날짜 = 공정 종료일 + 6일
  gs_dis-meins     = gs_qcinfo-unit.                  " 단위
  gs_dis-emp_num   = gs_qcinfo-emp_num.               " 담당자
  gs_dis-discost   = gs_qcinfo-dismenge * 100.        " 폐기비용
  gs_dis-waers     = 'KRW'.                           " 비용의 통화키
  gs_dis-status    = 'B'.                             " 폐기상태 초기값 'B' - 대기

  APPEND gs_dis TO gt_dis.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_dis
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_dis .

  DATA : lt_save  TYPE TABLE OF zc302mmt0001,
         ls_save  TYPE zc302mmt0001,
         lv_tabix TYPE sy-tabix.

  MOVE-CORRESPONDING gt_dis TO lt_save.

  IF lt_save IS INITIAL.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.     " 데이터가 없습니다.
    EXIT.
  ENDIF.

  "* Set Time Stamp (폐기)
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

  " DB에 저장
  MODIFY zc302mmt0001 FROM TABLE lt_save.

  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.    " 저장에 실패하였습니다.
    ROLLBACK WORK.
  ENDIF.


ENDFORM.
