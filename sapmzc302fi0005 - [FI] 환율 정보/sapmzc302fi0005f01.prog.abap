*&---------------------------------------------------------------------*
*& Include          SAPMZC302FI0005F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form init_ranges
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_ranges .

  REFRESH: gr_nation, gr_fcurr, gr_tcurr, gr_edate, gr_exrate, gr_jobname.

  " 국가명 화폐명
  IF gv_nation IS NOT INITIAL.
    gr_nation-sign = 'I'.
    gr_nation-option = 'EQ'.
    gr_nation-low = gv_nation.
    APPEND gr_nation.
  ENDIF.

  " 기존 통화
  IF gv_fcurr IS NOT INITIAL.
    gr_fcurr-sign = 'I'.
    gr_fcurr-option = 'EQ'.
    gr_fcurr-low = gv_fcurr.
    APPEND gr_fcurr.
  ENDIF.

  " 변환 통화
  IF gv_tcurr IS NOT INITIAL.
    gr_tcurr-sign = 'I'.
    gr_tcurr-option = 'EQ'.
    gr_tcurr-low = gv_tcurr.
    APPEND gr_tcurr.
  ENDIF.

  " 환율 적용일
  IF gv_edate IS NOT INITIAL.
    gr_edate-sign = 'I'.
    gr_edate-option = 'EQ'.
    gr_edate-low = gv_edate.
    APPEND gr_edate.
  ENDIF.

  " 환율
  IF gv_exrate IS NOT INITIAL.
    gr_exrate-sign = 'I'.
    gr_exrate-option = 'EQ'.
    gr_exrate-low = gv_exrate.
    APPEND gr_exrate.
  ENDIF.

  " 배치잡 이름
  IF gv_jobname IS NOT INITIAL.
    gr_jobname-sign = 'I'.
    gr_jobname-option = 'EQ'.
    gr_jobname-low = gv_jobname.
    APPEND gr_jobname.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_BASE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_base_data .

  " 환율 데이터 셀렉트
  PERFORM get_exrate_data.

  " 배치 잡 로그 데이터 셀렉트
  PERFORM get_log_data.

  " 미국 환율 데이터
  CLEAR : gt_usa.
  SELECT nation fcurr tcurr edate exrate waers erdat erzet ernam
    FROM zc302fit0005
    INTO CORRESPONDING FIELDS OF TABLE gt_usa
    WHERE nation = '미국 달러'.

  " 일본 환율 데이터
  CLEAR : gt_jpn.
  SELECT nation fcurr tcurr edate exrate waers erdat erzet ernam
    FROM zc302fit0005
    INTO CORRESPONDING FIELDS OF TABLE gt_jpn
    WHERE nation = '일본 옌'.

  " 중국 환율 데이터
  CLEAR : gt_chn.
  SELECT nation fcurr tcurr edate exrate waers erdat erzet ernam
    FROM zc302fit0005
    INTO CORRESPONDING FIELDS OF TABLE gt_chn
    WHERE nation = '위안화'.

  " 유로 환율 데이터
  CLEAR : gt_eur.
  SELECT nation fcurr tcurr edate exrate waers erdat erzet ernam
    FROM zc302fit0005
    INTO CORRESPONDING FIELDS OF TABLE gt_eur
    WHERE nation = '유로'.

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
  IF go_cont_exr IS NOT BOUND OR
     go_cont_log IS NOT BOUND.
    " 환율         key  field   text  just emph
    PERFORM field_catalog USING : 'X' 'NATION' '국가' ' ' ' ',
                                  'X' 'FCURR' '기존 통화' 'C' ' ',
                                  'X' 'TCURR' '변환 통화' 'C' ' ',
                                  'X' 'EDATE' '환율 적용일' '' ' ',
                                  ' ' 'EXRATE' '환율' ' ' 'X'.
    " 배치잡 로그
    PERFORM field_catalog_log USING : 'X' 'JOBNAME'    'Job명'     'C' ' ',
                                      'X' 'JOBCOUNT'   'Job ID'    'C' ' ',
                                      ' ' 'SDLUNAME'   '생성자'     'C' ' ',
                                      ' ' 'STATUS_DES' '상태'       'C' ' ',
                                      ' ' 'STRTDATE'   '시작 날짜'   'C' ' ',
                                      ' ' 'STRTTIME'   '시작 시간'   'C' ' ',
                                      ' ' 'RELDATE'    '배포 날짜'   'C' ' ',
                                      ' ' 'RELTIME'    '배포 시간'   'C' ' ',
                                      ' ' 'ENDDATE'    '종료 날짜'   'C' ' ',
                                      ' ' 'ENDTIME'    '종료 시간'   'C' ' ',
                                      ' ' 'PERIODIC'   '주기적 실행 여부' 'C' 'X'.
    PERFORM set_layout.
    PERFORM create_object.

    " 101번 스크린
    CALL METHOD go_grid_exr->set_table_for_first_display
      EXPORTING
        i_default       = 'X'
        is_layout       = gs_layo
      CHANGING
        it_outtab       = gt_body
        it_fieldcatalog = gt_fcat_exr.

    " 102번 스크린
    CALL METHOD go_grid_log->set_table_for_first_display
      EXPORTING
        i_default       = 'X'
        is_layout       = gs_layo2
      CHANGING
        it_outtab       = gt_log
        it_fieldcatalog = gt_fcat_log.

  ELSE.
    CALL METHOD go_grid_exr->refresh_table_display.
    CALL METHOD go_grid_log->refresh_table_display.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM field_catalog  USING pv_key pv_fname pv_ctxt pv_just pv_emph .

  CLEAR: gs_fcat.
  gs_fcat-key = pv_key.
  gs_fcat-fieldname = pv_fname.
  gs_fcat-coltext = pv_ctxt.
  gs_fcat-emphasize = pv_emph.
  gs_fcat-just = pv_just.

  APPEND gs_fcat TO gt_fcat_exr.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_catalog_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM field_catalog_log  USING pv_key pv_fname pv_ctxt pv_just pv_emph .
  CLEAR: gs_fcat.
  gs_fcat-key = pv_key.
  gs_fcat-fieldname = pv_fname.
  gs_fcat-coltext = pv_ctxt.
  gs_fcat-emphasize = pv_emph.
  gs_fcat-just = pv_just.

  APPEND gs_fcat TO gt_fcat_log.

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

  CLEAR: gs_layo.

  gs_layo-zebra = abap_true.
  gs_layo-cwidth_opt = 'A'.
  gs_layo-sel_mode = 'D'.
  gs_layo-ctab_fname = 'COLOR'.
  gs_layo-grid_title = '환율'.
  gs_layo-smalltitle = abap_true.

  gs_layo2-zebra = abap_true.
  gs_layo2-cwidth_opt = 'A'.
  gs_layo2-sel_mode = 'D'.
  gs_layo2-ctab_fname = 'COLOR'.
  gs_layo2-grid_title = '배치잡 로그'.
  gs_layo2-smalltitle = abap_true.

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

  " alv
  CREATE OBJECT go_cont_exr
    EXPORTING
      container_name              = 'EXR_CONT'.

  CREATE OBJECT go_cont_log
    EXPORTING
      container_name = 'LOG_CONT'.

  CREATE OBJECT go_grid_exr
    EXPORTING
      i_parent          = go_cont_exr.

  CREATE OBJECT go_grid_log
    EXPORTING
      i_parent = go_cont_log.

  " chart
  CREATE OBJECT go_cont_usa
    EXPORTING
      container_name = 'USA_CONT'.

  CREATE OBJECT go_cont_chn
    EXPORTING
      container_name = 'CHN_CONT'.

  CREATE OBJECT go_cont_jpn
    EXPORTING
      container_name = 'JPN_CONT'.

  CREATE OBJECT go_cont_eur
    EXPORTING
      container_name = 'EUR_CONT'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_exrate_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_exrate_data .

  CLEAR : gt_body.

  SELECT nation fcurr tcurr edate exrate waers erdat erzet ernam
    FROM zc302fit0005
    INTO CORRESPONDING FIELDS OF TABLE gt_body
    WHERE nation IN gr_nation
      AND fcurr IN gr_fcurr
      AND tcurr IN gr_tcurr
      AND edate IN gr_edate
      AND exrate IN gr_exrate.

  " 110번 스크린에서만 메시지 표시
  IF gv_tab = 'TAB1'.
    gv_lines = lines( gt_body ).

    IF gt_body IS INITIAL.
      MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
      EXIT.
    ELSE.
      MESSAGE s001 WITH gv_lines TEXT-t01.
    ENDIF.
  ENDIF.


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

  REFRESH : gr_jobname.

  IF gv_jobname IS NOT INITIAL.
    gr_jobname-sign = 'I'.
    gr_jobname-sign = 'I'.
    gr_jobname-option = 'EQ'.
    gr_jobname-low = gv_jobname.
    APPEND gr_jobname.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_log_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_log_data .

  CASE 'X'.
      " 전체 선택
    WHEN gv_all.
      CLEAR : gt_log.
      SELECT jobname jobcount sdluname strtdate strttime status
             reldate reltime enddate endtime periodic
        FROM tbtco
        INTO CORRESPONDING FIELDS OF TABLE gt_log
        WHERE jobname IN gr_jobname.

      IF gv_tab = 'TAB2'.
        gv_lines = lines( gt_log ).

        " 조회 후 메시지
        IF gt_log IS INITIAL.
          MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
          EXIT.
        ELSE.
          MESSAGE s001 WITH gv_lines TEXT-t01.
        ENDIF.
      ENDIF.


      PERFORM set_cell_color.

      " 배포 완료
    WHEN gv_release.

      CLEAR : gt_log.
      SELECT jobname jobcount sdluname strtdate strttime status
             reldate reltime enddate endtime periodic
        FROM tbtco
        INTO CORRESPONDING FIELDS OF TABLE gt_log
        WHERE jobname IN gr_jobname
          AND status = 'S'.

      IF gv_tab = 'TAB2'.
        gv_lines = lines( gt_log ).

        " 조회 후 메시지
        IF gt_log IS INITIAL.
          MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
          EXIT.
        ELSE.
          MESSAGE s001 WITH gv_lines TEXT-t01.
        ENDIF.
      ENDIF.

      PERFORM set_cell_color.

      " 준비
    WHEN gv_ready.

      CLEAR : gt_log.
      SELECT jobname jobcount sdluname strtdate strttime status
             reldate reltime enddate endtime periodic
        FROM tbtco
        INTO CORRESPONDING FIELDS OF TABLE gt_log
        WHERE jobname IN gr_jobname
          AND status = 'Y'.

      IF gv_tab = 'TAB2'.
        gv_lines = lines( gt_log ).

        " 조회 후 메시지
        IF gt_log IS INITIAL.
          MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
          EXIT.
        ELSE.
          MESSAGE s001 WITH gv_lines TEXT-t01.
        ENDIF.
      ENDIF.

      PERFORM set_cell_color.

      " 실행 중
    WHEN gv_active.

      CLEAR : gt_log.
      SELECT jobname jobcount sdluname strtdate strttime status
             reldate reltime enddate endtime periodic
        FROM tbtco
        INTO CORRESPONDING FIELDS OF TABLE gt_log
        WHERE jobname IN gr_jobname
          AND status = 'R'.

      IF gv_tab = 'TAB2'.
        gv_lines = lines( gt_log ).

        " 조회 후 메시지
        IF gt_log IS INITIAL.
          MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
          EXIT.
        ELSE.
          MESSAGE s001 WITH gv_lines TEXT-t01.
        ENDIF.
      ENDIF.

      PERFORM set_cell_color.

      " 종료
    WHEN gv_finish.
      CLEAR : gt_log.
      SELECT jobname jobcount sdluname strtdate strttime status
             reldate reltime enddate endtime periodic
        FROM tbtco
        INTO CORRESPONDING FIELDS OF TABLE gt_log
        WHERE jobname IN gr_jobname
          AND status = 'F'.

     IF gv_tab = 'TAB2'.
        gv_lines = lines( gt_log ).

        " 조회 후 메시지
        IF gt_log IS INITIAL.
          MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
          EXIT.
        ELSE.
          MESSAGE s001 WITH gv_lines TEXT-t01.
        ENDIF.
      ENDIF.

      PERFORM set_cell_color.

      " 취소
    WHEN gv_canceled.
      CLEAR : gt_log.
      SELECT jobname jobcount sdluname strtdate strttime status
             reldate reltime enddate endtime periodic
        FROM tbtco
        INTO CORRESPONDING FIELDS OF TABLE gt_log
        WHERE jobname IN gr_jobname
          AND status = 'A'.

      IF gv_tab = 'TAB2'.
        gv_lines = lines( gt_log ).

        " 조회 후 메시지
        IF gt_log IS INITIAL.
          MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
          EXIT.
        ELSE.
          MESSAGE s001 WITH gv_lines TEXT-t01.
        ENDIF.
      ENDIF.

      PERFORM set_cell_color.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_chart
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_VALUE_USA
*&---------------------------------------------------------------------*
FORM set_chart  TABLES   pt_value_cur STRUCTURE gprval
                         pt_col_text_cur STRUCTURE gprtxt
                 USING   pv_rowtxt.
  DATA : lv_prefix(3) VALUE 'VAL',
         lv_index     TYPE i VALUE 1,
         lv_string(2),
         lv_colname   TYPE string.

  FIELD-SYMBOLS : <fs>.

  REFRESH : pt_value_cur, pt_col_text_cur.
  pt_value_cur-rowtxt = pv_rowtxt.

  CASE pv_rowtxt.
    WHEN '미국'.
      LOOP AT gt_usa INTO gs_usa.
        " X 축 구성
        CLEAR: lv_colname.
        lv_string = lv_index.
        CONCATENATE lv_prefix lv_string INTO lv_colname.

        " Y축 값 할당
        ASSIGN COMPONENT lv_colname OF STRUCTURE pt_value_cur TO <fs>.
        <fs> = gs_usa-exrate.
        lv_index = lv_index + 1.

        CLEAR: pt_col_text_cur.
        pt_col_text_cur-coltxt = gs_usa-edate.

        APPEND pt_col_text_cur.
      ENDLOOP.
      UNASSIGN <fs>.
      APPEND pt_value_cur.

    WHEN '중국'.
      LOOP AT gt_chn INTO gs_chn.
        " X 축 구성
        CLEAR: lv_colname.
        lv_string = lv_index.
        CONCATENATE lv_prefix lv_string INTO lv_colname.

        " Y축 값 할당
        ASSIGN COMPONENT lv_colname OF STRUCTURE pt_value_cur TO <fs>.
        <fs> = gs_chn-exrate.
        lv_index = lv_index + 1.

        CLEAR: pt_col_text_cur.
        pt_col_text_cur-coltxt = gs_chn-edate.

        APPEND pt_col_text_cur.
      ENDLOOP.

      APPEND pt_value_cur.
    WHEN '일본'.
      LOOP AT gt_jpn INTO gs_jpn.
        " X 축 구성
        CLEAR: lv_colname.
        lv_string = lv_index.
        CONCATENATE lv_prefix lv_string INTO lv_colname.

        " Y축 값 할당
        ASSIGN COMPONENT lv_colname OF STRUCTURE pt_value_cur TO <fs>.
        <fs> = gs_jpn-exrate.
        lv_index = lv_index + 1.

        CLEAR: pt_col_text_cur.
        pt_col_text_cur-coltxt = gs_jpn-edate.

        APPEND pt_col_text_cur.
      ENDLOOP.

      APPEND pt_value_cur.
    WHEN '유로'.
      LOOP AT gt_eur INTO gs_eur.
        " X 축 구성
        CLEAR: lv_colname.
        lv_string = lv_index.
        CONCATENATE lv_prefix lv_string INTO lv_colname.

        " Y축 값 할당
        ASSIGN COMPONENT lv_colname OF STRUCTURE pt_value_cur TO <fs>.
        <fs> = gs_eur-exrate.
        lv_index = lv_index + 1.

        CLEAR: pt_col_text_cur.
        pt_col_text_cur-coltxt = gs_eur-edate.

        APPEND pt_col_text_cur.
      ENDLOOP.

      APPEND pt_value_cur.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_CONT_USA
*&---------------------------------------------------------------------*
FORM init_display   TABLES    pt_value_cur STRUCTURE gprval
                              pt_col_text_cur STRUCTURE gprtxt
                     USING    po_cont_nation.
  CALL FUNCTION 'GFW_PRES_SHOW'
    EXPORTING
      presentation_type = gfw_prestype_lines
      parent            = po_cont_nation
    TABLES
      values            = pt_value_cur
      column_texts      = pt_col_text_cur.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_cell_color
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_cell_color .

  DATA : ls_color TYPE lvc_s_scol.

  LOOP AT gt_log INTO gs_log.

    gv_tabix = sy-tabix.

    CASE gs_log-status.
      WHEN 'A'.
        gs_log-status_des = 'Cancelled'.
        ls_color-fname = 'STATUS_DES'.
        ls_color-color-col = 6. " Red

        INSERT ls_color INTO TABLE gs_log-color.
      WHEN 'F'.
        gs_log-status_des = 'Completed'.
        ls_color-fname = 'STATUS_DES'.
        ls_color-color-col = 5. " Green
        INSERT ls_color INTO TABLE gs_log-color.
      WHEN 'P'.
        gs_log-status_des = 'Scheduled'.
      WHEN 'R'.
        gs_log-status_des = 'Running'.
        ls_color-fname = 'STATUS_DES'.
        ls_color-color-col = 3. " Yellow
        INSERT ls_color INTO TABLE gs_log-color.
      WHEN 'S'.
        gs_log-status_des = 'Released'.
      WHEN 'Y'.
        gs_log-status_des = 'Ready'.
      WHEN 'X'.
        gs_log-status_des = 'Unknown state'.
        ls_color-fname = 'STATUS_DES'.
        ls_color-color-col = 7. " Orange
        INSERT ls_color INTO TABLE gs_log-color.
    ENDCASE.

    MODIFY gt_log FROM gs_log INDEX gv_tabix
                              TRANSPORTING status_des color.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_nation
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_nation .
  DATA: lt_return_nation LIKE ddshretval OCCURS 0
                                  WITH HEADER LINE,
        BEGIN OF ls_nation,
          nation TYPE zc302fit0005-nation,
        END OF ls_nation,
        lt_nation LIKE TABLE OF ls_nation.

  " 서치헬프에 보여줄 유효 값 쿼리
  CLEAR : lt_nation.
  SELECT DISTINCT nation
    FROM zc302fit0005
    INTO CORRESPONDING FIELDS OF TABLE lt_nation.

  " 서치헬프에서 값을 고르면 반환할 값을 필드를 통해서 설정
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield     = 'NATION'
      dynpprog     = sy-repid
      dynpnr       = sy-dynnr
      dynprofield  = 'LT_NATION'
      window_title = '국가 및 통화'
      value_org    = 'S'
    TABLES
      value_tab    = lt_nation
      return_tab   = lt_return_nation.

  READ TABLE lt_return_nation INDEX 1.

  " 화면에 세팅
  gv_nation = lt_return_nation-fieldval.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_fcurr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_fcurr .
  DATA: lt_return_fcurr LIKE ddshretval OCCURS 0
                                  WITH HEADER LINE,
        BEGIN OF ls_fcurr,
          fcurr  TYPE zc302fit0005-fcurr,
          nation TYPE zc302fit0005-nation,
        END OF ls_fcurr,
        lt_fcurr LIKE TABLE OF ls_fcurr.

  " 서치헬프에 보여줄 유효 값 쿼리
  CLEAR : lt_fcurr.
  SELECT DISTINCT nation fcurr
    FROM zc302fit0005
    INTO CORRESPONDING FIELDS OF TABLE lt_fcurr.

  " 서치헬프에서 값을 고르면 반환할 값을 필드를 통해서 설정
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield     = 'FCURR'
      dynpprog     = sy-repid
      dynpnr       = sy-dynnr
      dynprofield  = 'LT_FCURR'
      window_title = '기존 통화'
      value_org    = 'S'
    TABLES
      value_tab    = lt_fcurr
      return_tab   = lt_return_fcurr.

  READ TABLE lt_return_fcurr INDEX 1.

  " 화면에 세팅
  gv_fcurr = lt_return_fcurr-fieldval.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_tcurr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_tcurr .
  DATA: lt_return_tcurr LIKE ddshretval OCCURS 0
                                        WITH HEADER LINE,
        BEGIN OF ls_tcurr,
          tcurr TYPE zc302fit0005-tcurr,
        END OF ls_tcurr,
        lt_tcurr LIKE TABLE OF ls_tcurr.

  " 서치헬프에 보여줄 유효 값 쿼리
  CLEAR : lt_tcurr.
  SELECT DISTINCT tcurr
    FROM zc302fit0005
    INTO CORRESPONDING FIELDS OF TABLE lt_tcurr.

  " 서치헬프에서 값을 고르면 반환할 값을 필드를 통해서 설정
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield     = 'TCURR'
      dynpprog     = sy-repid
      dynpnr       = sy-dynnr
      dynprofield  = 'LT_TCURR'
      window_title = '기존 통화'
      value_org    = 'S'
    TABLES
      value_tab    = lt_tcurr
      return_tab   = lt_return_tcurr.

  READ TABLE lt_return_tcurr INDEX 1.

  " 화면에 세팅
  gv_tcurr = lt_return_tcurr-fieldval.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_jobname
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_jobname .
  DATA: lt_return_jobname LIKE ddshretval OCCURS 0
                                          WITH HEADER LINE,
        BEGIN OF ls_jobname,
          jobname TYPE tbtco-jobname,
        END OF ls_jobname,
        lt_jobname LIKE TABLE OF ls_jobname.

  " 서치헬프에 보여줄 유효 값 쿼리
  CLEAR : lt_jobname.
  SELECT jobname
    FROM tbtco
    INTO CORRESPONDING FIELDS OF TABLE lt_jobname
    WHERE jobname LIKE 'Z*.'.

  " 서치헬프에서 값을 고르면 반환할 값을 필드를 통해서 설정
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield     = 'jobname'
      dynpprog     = sy-repid
      dynpnr       = sy-dynnr
      dynprofield  = 'LT_jobname'
      window_title = '기존 통화'
      value_org    = 'S'
    TABLES
      value_tab    = lt_jobname
      return_tab   = lt_return_jobname.

  READ TABLE lt_return_jobname INDEX 1.

  " 화면에 세팅
  gv_jobname = lt_return_jobname-fieldval.

ENDFORM.
