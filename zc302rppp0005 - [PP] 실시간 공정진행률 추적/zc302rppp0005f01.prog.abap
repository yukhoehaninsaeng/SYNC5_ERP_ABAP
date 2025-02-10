*&---------------------------------------------------------------------*
*& Include          ZC302RPPP0006F01
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

  PERFORM get_product_order_data.

  PERFORM get_product_log_data.

  IMPORT
    gt_invman TO gt_invman
    FROM MEMORY ID 'INV'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_product_order_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_product_order_data .

  CLEAR gt_order.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_order
    FROM zc302ppt0007.

  IF gt_order IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_pro_log_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_product_log_data .

  CLEAR gt_pro_log.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_pro_log
    FROM zc302ppt0010.

  CLEAR gt_make.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_make
    FROM zc302ppt0010
   WHERE pstep  EQ 'A'
     AND status EQ '2'.

  CLEAR gt_fill.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_fill
    FROM zc302ppt0010
   WHERE pstep  EQ 'B'
     AND status EQ '2'.

  CLEAR gt_pack.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_pack
    FROM zc302ppt0010
   WHERE pstep  EQ 'C'
     AND status EQ '2'.

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

  DATA: lo_ran    TYPE REF TO cl_abap_random_int,
        lv_tabix  TYPE sy-tabix,
        lv_num    TYPE i.

  lo_ran = cl_abap_random_int=>create( seed = CONV i( sy-uzeit )  " seed는 type이 int이기 때문에 CONV I( )를 사용하여 타입 변환
                                           min  = 5
                                           max  = 16 ).

  LOOP AT gt_make INTO gs_make.

    lv_tabix = sy-tabix.

    READ TABLE gt_pro_log INTO gs_fill WITH KEY ponum = gs_make-ponum
                                                pcode = gs_make-pcode
                                                pstep = 'B'.
    READ TABLE gt_pro_log INTO gs_pack WITH KEY ponum = gs_make-ponum
                                                pcode = gs_make-pcode
                                                pstep = 'C'.

    IF gs_make-pperc LT 100.

      lv_num = lo_ran->get_next( ).

      gs_make-pperc = gs_make-pperc + lv_num.

      IF gs_make-pperc GE 100.
        gs_make-pperc = '100'.
        gs_make-ppend = gs_make-ppstr + '7'.
      ENDIF.

      MODIFY gt_make FROM gs_make INDEX lv_tabix
                                  TRANSPORTING pperc ppend.

      " gt_pro_log에 백업
      MODIFY gt_pro_log FROM gs_make TRANSPORTING pperc ppend status
                                            WHERE ponum = gs_make-ponum
                                              AND pcode = gs_make-pcode
                                              AND pstep = gs_make-pstep.

      " 공정이 진행되었습니다 라고 Message 띄우기
      IF sy-subrc EQ 0.
        MESSAGE s001 WITH gs_make-pstep TEXT-g01.
      ELSE.
        MESSAGE s002 WITH gs_make-pstep TEXT-e02 DISPLAY LIKE 'E'.
      ENDIF.

    ELSEIF ( gs_make-pperc EQ 100 ) AND
           ( gs_fill-pperc LT 100 ).

      IF gs_fill-status IS INITIAL.

        gs_fill-status = '2'.

        APPEND gs_fill TO gt_fill.

      ENDIF.

      lv_num = lo_ran->get_next( ).

      gs_fill-pperc = gs_fill-pperc + lv_num.

      IF gs_fill-pperc GE 100.
        gs_fill-pperc = '100'.
        gs_fill-ppend = gs_fill-ppstr + '7'.
      ENDIF.

      MODIFY gt_fill FROM gs_fill TRANSPORTING pperc ppend
                                         WHERE ponum = gs_fill-ponum
                                           AND pcode = gs_fill-pcode.

      " gt_pro_log에 백업
      MODIFY gt_pro_log FROM gs_fill TRANSPORTING pperc ppend status
                                            WHERE ponum = gs_fill-ponum
                                              AND pcode = gs_fill-pcode
                                              AND pstep = gs_fill-pstep.

      " 공정이 진행되었습니다 라고 Message 띄우기
      IF sy-subrc EQ 0.
        MESSAGE s001 WITH gs_fill-pstep TEXT-g01.
      ELSE.
        MESSAGE s002 WITH gs_fill-pstep TEXT-e02 DISPLAY LIKE 'E'.
      ENDIF.

    ELSEIF ( gs_fill-pperc EQ 100 ) AND
           ( gs_pack-pperc LT 100 ).

      IF gs_pack-status IS INITIAL.

        gs_pack-status = '2'.

        APPEND gs_pack TO gt_pack.

      ENDIF.

      lv_num = lo_ran->get_next( ).

      gs_pack-pperc = gs_pack-pperc + lv_num.

      IF gs_pack-pperc GE 100.
        gs_pack-pperc = '100'.
        gs_pack-ppend = gs_pack-ppstr + '7'.
      ENDIF.

      MODIFY gt_pack FROM gs_pack TRANSPORTING pperc ppend status
                                         WHERE ponum = gs_pack-ponum
                                           AND pcode = gs_pack-pcode.

      " gt_pro_log에 백업
      MODIFY gt_pro_log FROM gs_pack TRANSPORTING pperc ppend status
                                            WHERE ponum = gs_pack-ponum
                                              AND pcode = gs_pack-pcode
                                              AND pstep = gs_pack-pstep.

      " 공정이 진행되었습니다 라고 Message 띄우기
      IF sy-subrc EQ 0.
        MESSAGE s001 WITH gs_pack-pstep TEXT-g01.
      ELSE.
        MESSAGE s002 WITH gs_pack-pstep TEXT-e02 DISPLAY LIKE 'E'.
      ENDIF.

    ELSEIF gs_pack-pperc EQ 100.

      " 공정이 완료된 생산오더 레코드를 끌고온다.
      READ TABLE gt_order INTO gs_order WITH KEY ponum = gs_pack-ponum.

      " 생산오더 상태를 3으로 바꾸고 품질검수 이름 넣고 버튼으로 바꾼다. + icon 포함
      gs_order-status = '3'.

      MODIFY gt_order FROM gs_order TRANSPORTING status
                                           WHERE ponum = gs_pack-ponum.

      " 각각 gt_make, gt_fill, gt_pack에 DELETE 후 gt_pro_log에 백업
      DELETE gt_make WHERE ponum = gs_order-ponum.
      DELETE gt_fill WHERE ponum = gs_order-ponum.
      DELETE gt_pack WHERE ponum = gs_order-ponum.

      gs_pack-status = '3'.

      MODIFY gt_pro_log FROM gs_pack TRANSPORTING status
                                            WHERE ponum = gs_pack-ponum.

      " 생산 오더 저장
      PERFORM set_product_order_data.

      " 공정이 완료되었습니다라고 Message 띄우기
      IF sy-subrc EQ 0.
        MESSAGE s001 WITH gs_order-maktx TEXT-g02.
      ELSE.
        MESSAGE s001 WITH gs_order-maktx TEXT-e03.
      ENDIF.

    ENDIF.

    PERFORM save_inv_manage_data.  " 재고관리 업데이트
    PERFORM save_product_log_data. " 공정 진행 로그 전체 저장

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_product_order_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_product_order_data .

  DATA: ls_save TYPE zc302ppt0007.

  MOVE-CORRESPONDING gs_order TO ls_save.

  IF ls_save IS INITIAL.
    MESSAGE s000 WITH TEXT-e03 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  "* Set Time Stamp (계획오더 Item)
  IF ls_save-erdat IS INITIAL.
    ls_save-erdat = sy-datum.
    ls_save-ernam = sy-uname.
    ls_save-erzet = sy-uzeit.
  ELSE.
    ls_save-aedat = sy-datum.
    ls_save-aenam = sy-uname.
    ls_save-aezet = sy-uzeit.
  ENDIF.


  " 공정 진행 로그 DB에 저장
  MODIFY zc302ppt0007 FROM ls_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE s000 WITH TEXT-e04 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_product_log_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_product_log_data .

  DATA: lt_save  TYPE TABLE OF zc302ppt0010,
        ls_save  TYPE zc302ppt0010,
        lv_tabix TYPE sy-tabix.

  MOVE-CORRESPONDING gt_pro_log TO lt_save.

  IF lt_save IS INITIAL.
    MESSAGE s000 WITH TEXT-e03 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  "* Set Time Stamp (계획오더 Item)
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

  " 공정 진행 로그 DB에 저장
  MODIFY zc302ppt0010 FROM TABLE lt_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE s000 WITH TEXT-e04 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

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
                     grid_title = '백그라운드 잡 로그 기록 정보'
                     smalltitle = abap_true
                     ctab_fname = 'COLOR' ).

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
*& Form set_init_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_init_value .

  pa_name = 'SYNCYOUNG_PPP_BATCH'.

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
*&      --> LV_TEXT2
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
*& Form set_batch_job
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_batch_job .

  DATA: lt_tbtcstep TYPE TABLE OF tbtcstep,
        ls_tbtcstep TYPE tbtcstep.

  DATA: lv_jobcount TYPE btcjobcnt,
        lv_jobname  TYPE btcjob,
        lv_check    VALUE abap_true.

  LOOP AT gt_order INTO gs_order.

    IF ( gs_order-status EQ '3' ) OR
       ( gs_order-status EQ '4' ).
      lv_check = abap_false.
    ELSE.
      lv_check = abap_true.
    ENDIF.

  ENDLOOP.

  IF lv_check EQ abap_false.

    lv_jobname = 'SYNCYOUNG_PPP_BATCH'.

    SELECT SINGLE jobcount
      INTO lv_jobcount
      FROM tbtco
     WHERE jobname EQ lv_jobname   " 자신이 만든 배치잡 이름 설정
       AND status  EQ 'S'.

    CALL FUNCTION 'BP_JOB_MODIFY'
      EXPORTING
        dialog       = 'Y'
        jobcount     = lv_jobcount
        jobname      = lv_jobname  " 자신이 만든 배치잡 이름 설정
        opcode       = 18
      tables
        new_steplist = lt_tbtcstep.

  ENDIF.


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

  DATA: ls_scol TYPE lvc_s_scol.

  LOOP AT gt_batch_log ASSIGNING FIELD-SYMBOL(<fs_batch>).

    CLEAR ls_scol.
    ls_scol-fname = 'RL_STATUS'.

    CASE <fs_batch>-status.
      WHEN 'A'.
        <fs_batch>-rl_status = 'Cancelled'.
        ls_scol-color-col    = 6.
        ls_scol-color-int    = 1.
      WHEN 'F'.
        <fs_batch>-rl_status = 'Finished'.
        ls_scol-color-col    = 5.
        ls_scol-color-int    = 1.
      WHEN 'P'.
        <fs_batch>-rl_status = 'Scheduled'.
        ls_scol-color-col    = 4.
        ls_scol-color-int    = 1.
      WHEN 'R'.
        <fs_batch>-rl_status = 'Running'.
      WHEN 'S'.
        <fs_batch>-rl_status = 'Released'.
        ls_scol-color-col    = 3.
        ls_scol-color-int    = 1.
      WHEN 'Y'.
        <fs_batch>-rl_status = 'Ready'.
      WHEN 'X'.
        <fs_batch>-rl_status = 'Unknown_state'.
    ENDCASE.

    INSERT ls_scol INTO TABLE <fs_batch>-color.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_inv_manage_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_inv_manage_data .

  DATA: lt_save TYPE TABLE OF zc302mmt0013,
        ls_save TYPE zc302mmt0013,
        lv_tabix TYPE sy-tabix.

  MOVE-CORRESPONDING gt_invman TO lt_save.

  IF lt_save IS INITIAL.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'.
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
  MODIFY zc302mmt0013 FROM TABLE lt_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE s001 WITH TEXT-e06 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
