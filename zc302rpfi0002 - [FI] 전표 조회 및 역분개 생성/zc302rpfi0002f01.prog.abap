*&---------------------------------------------------------------------*
*& Include          ZC302RPFI0002F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form set_init_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_init_value .

  pa_buk = '1000'.
  pa_gja = '2024'.

  pa_butxt = 'SYNCYOUNG'.

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

*-- 전표 header data
  CLEAR gt_bkpf.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_bkpf
    FROM zc302fit0001
    WHERE bukrs EQ pa_buk
      AND gjahr EQ pa_gja
      AND belnr IN so_bel
      AND budat IN so_bud
      AND belnr NOT LIKE '5%'   " 역분개 전표 포함 X
*      AND belnr NOT LIKE '2%'
     ORDER BY belnr budat ASCENDING.

*-- 데이터 빈값 확인
  IF gt_bkpf IS INITIAL .
    MESSAGE i001 WITH TEXT-e09 DISPLAY LIKE 'E'.
    STOP.
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

*-- set Field catalog
    CLEAR :  gt_ufcat, gt_dfcat.
    " For up grid
    PERFORM set_fcat USING : 'U' 'X' 'BUKRS' '회사코드' 'C' ' ',        " 회사코드
                             'U' 'X' 'GJAHR' '회계연도' 'C' ' ',        " 회계연도
                             'U' 'X' 'BELNR' '전표번호' 'C' ' ',        " 전표번호
                             'U' ' ' 'BLART' '전표유형' 'C' ' ',        " 전표유형
                             'U' ' ' 'BLDAT' '증빙일' 'C' ' ',          " 증빙일
                             'U' ' ' 'BUDAT' '전기일' 'C' ' ',          " 전기일
                             'U' ' ' 'BKTXT' '전표헤더텍스트' 'L' ' ',    " 전표헤더텍스트
                             'U' ' ' 'EMP_NUM' '담당자' 'C' ' ',        " 담당자
                             'U' ' ' 'STBLG' '역분개번호' 'C' 'X',       " 역분개번호
                             'U' ' ' 'BTN'  '역분개 생성 버튼' 'C' ' ',   " 역분개 생성 버튼
*--------------------------------------------------------------------*
                              "  For down grid
                             'D' 'X' 'GJAHR' '회계연도' 'C' ' ',        " 회계연도
                             'D' 'X' 'BELNR' '전표번호' 'C' ' ',        " 전표번호
                             'D' 'X' 'BUZEI' '아이템 번호' 'C' ' ',      " 아이템 번호
                             'D' ' ' 'KOART' '계정유형' 'C' ' ',        " 계정유형
                             'D' ' ' 'SHKZG' '차/대변' 'C' ' ',        " 차/대변
                             'D' ' ' 'HKONT' '계정과목코드' 'C' ' ',      " 계정과목코드
                             'D' ' ' 'TXT50' '계정과목명' 'C' ' ',       " 계정과목명
                             'D' ' ' 'PRICE' '가격' 'C' ' ',            " 가격
                             'D' ' ' 'WAERS' '통화' 'C' ' ',            " 통화
                             'D' ' ' 'BPCODE' '거래처코드' 'C' ' '.      " 거래처코드



    PERFORM set_layout.
    PERFORM create_object.

*-- ALV 툴바 불필요한 버튼 제거
    PERFORM exclude_button TABLES gt_ui_functions.

    gs_variant-report = sy-repid.
    gs_variant-handle = 'ALV1'.

*-- Event 설치
    SET HANDLER : lcl_event_handler=>top_of_page   FOR go_up_grid,
                  lcl_event_handler=>hotspot_click FOR go_up_grid,
                  lcl_event_handler=>create_btn_click FOR go_up_grid.

*-- UP GRID
    CALL METHOD go_up_grid->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        i_save               = 'A'
        i_default            = 'X'
        is_layout            = gs_layout
        it_toolbar_excluding = gt_ui_functions
      CHANGING
        it_outtab            = gt_bkpf
        it_fieldcatalog      = gt_ufcat.

    gs_variant-report = sy-repid.
    gs_variant-handle = 'ALV2'.

*-- DOWN GRID
    CALL METHOD go_down_grid->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        i_save               = 'A'
        i_default            = 'X'
        is_layout            = gs_dlayout
        it_toolbar_excluding = gt_ui_functions
      CHANGING
        it_outtab            = gt_bseg
        it_fieldcatalog      = gt_dfcat
        it_sort              = gt_sort.


*-- TOP OF PAGE
    CALL METHOD go_dyndoc_id->initialize_document
      EXPORTING
        background_color = cl_dd_area=>col_textarea.

    CALL METHOD go_up_grid->list_processing_events
      EXPORTING
        i_event_name = 'TOP_OF_PAGE'
        i_dyndoc_id  = go_dyndoc_id.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_fcat  USING  pv_gubun pv_key pv_field pv_table pv_just pv_emph.

  DATA : lv_s_fcat(8),
         lv_t_fcat(8).

*-- 필드심볼  WA & ITAB 선언
  FIELD-SYMBOLS : <fs_s_fcat> LIKE gs_ufcat,
                  <fs_t_fcat> LIKE gt_ufcat.


  " U 또는 D를 이용해서 이름 만들어주기 위함
  CONCATENATE 'GS_' pv_gubun 'FCAT' INTO lv_s_fcat.
  CONCATENATE 'GT_' pv_gubun 'FCAT' INTO lv_t_fcat.

  ASSIGN (lv_s_fcat) TO <fs_s_fcat>.
  ASSIGN (lv_t_fcat) TO <fs_t_fcat>.

*-- 필드심볼에 값 넣기
  IF <fs_s_fcat> IS ASSIGNED.
    CLEAR : <fs_s_fcat>.
    <fs_s_fcat>-key = pv_key.
    <fs_s_fcat>-fieldname = pv_field.
    <fs_s_fcat>-coltext = pv_table.
    <fs_s_fcat>-just = pv_just.
    <fs_s_fcat>-emphasize = pv_emph.

*-- 필드값 이름 변경 및 기능 구현
    CASE pv_field.
      WHEN 'BTN'.
        <fs_s_fcat>-coltext = '내역생성/조회'.   "역분개 생성 버튼
        <fs_s_fcat>-style   = cl_gui_alv_grid=>mc_style_button.
      WHEN 'BELNR'.
        IF pv_gubun EQ 'U'.
          <fs_s_fcat>-hotspot = abap_true.  " 전표 핫스팟 설치
        ENDIF.
      WHEN 'STBLG'.
        <fs_s_fcat>-hotspot = abap_true.    " 역분개전표 핫스팟 설치

      WHEN 'PRICE'.
        <fs_s_fcat>-cfieldname = 'WAERS'.
        <fs_s_fcat>-do_sum = abap_true.
    ENDCASE.


    APPEND <fs_s_fcat> TO <fs_t_fcat>.
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

*-- set UP ALV layout.
  gs_layout-zebra      = 'X'.
  gs_layout-cwidth_opt = 'A'.
  gs_layout-sel_mode   = 'D'.
  gs_layout-no_totline = abap_true.
  gs_layout-grid_title = '전표 조회'.
  gs_layout-smalltitle = abap_true.

*-- set Down ALV layout.
  gs_dlayout-zebra      = 'X'.
  gs_dlayout-cwidth_opt = 'A'.
  gs_dlayout-sel_mode   = 'D'.
  gs_dlayout-no_totline = abap_true.
  gs_dlayout-grid_title = '전표 상세'.
  gs_dlayout-smalltitle = abap_true.

*-- set subtotal
  CLEAR : gt_sort, gs_sort.
  gs_sort-spos = 1.             " 차/대변 코드를 1순위로 정렬
  gs_sort-fieldname = 'SHKZG'.
  gs_sort-up = abap_true.       " ACSENDING
  gs_sort-subtot  = abap_true.  " Do subtotals
  APPEND gs_sort TO gt_sort.

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

*-- set Top of page
  CREATE OBJECT go_top_container
    EXPORTING
      repid     = sy-cprog
      dynnr     = sy-dynnr
      side      = go_top_container->dock_at_top
      extension = 55.   " Top of page

*-- Docking conainer
  CREATE OBJECT go_container
    EXPORTING
      side      = go_container->dock_at_left
      extension = 5000.

*-- Splitter container
  CREATE OBJECT go_split_cont
    EXPORTING
      parent  = go_container
      rows    = 2
      columns = 1.

*-- 행 높이 설정
  CALL METHOD go_split_cont->set_row_height
    EXPORTING
      id     = 1
      height = 62.

*-- Assign container (1행 1열)
  CALL METHOD go_split_cont->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_up_cont.

*-- Assign container (2행 1열)
  CALL METHOD go_split_cont->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_down_cont.

*-- up ALV
  CREATE OBJECT go_up_grid
    EXPORTING
      i_parent = go_up_cont.

*-- down ALV
  CREATE OBJECT go_down_grid
    EXPORTING
      i_parent = go_down_cont.


*-- TOP of Page : Create Top-Document (맨 마지막에)
  CREATE OBJECT go_dyndoc_id
    EXPORTING
      style = 'ALV_GIRD'.


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
*& Form add_row
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LR_DD_TABLE
*&      --> COL_FIELD
*&      --> COL_VALUE
*&      --> P_
*&      --> LV_TEXT
*&---------------------------------------------------------------------*
FORM add_row  USING  pr_dd_table  TYPE REF TO cl_dd_table_element
                     pv_col_field TYPE REF TO cl_dd_area
                     pv_col_value TYPE REF TO cl_dd_area
                     pv_field
                     pv_text.

  DATA : lv_text TYPE sdydo_text_element.

*-- Field에 값 세팅
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

  CALL METHOD pv_col_field->add_gap
    EXPORTING
      width = 3.

  CALL METHOD pr_dd_table->new_row.



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

*-- create table
  CALL METHOD go_dyndoc_id->add_table
    EXPORTING
      no_of_columns = 2
      border        = '0'
    IMPORTING
      table         = lr_dd_table.

*-- Set column (Add column to Table)
  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_field.

  CALL METHOD lr_dd_table->add_column
    IMPORTING
      column = col_value.

*-- 회사코드
  PERFORM add_row USING lr_dd_table col_field col_value '회사코드' pa_buk.

*-- 회계연도
  PERFORM add_row USING lr_dd_table col_field col_value '회계연도' pa_gja.

*-- 전표번호
  so_bel = VALUE #( so_bel[ 1 ] OPTIONAL ).
  CLEAR : lv_temp.
  IF so_bel-low IS NOT INITIAL.
    lv_temp = so_bel-low.
    IF so_bel-high IS NOT INITIAL.
      CONCATENATE lv_temp ' ~ ' so_bel-high INTO lv_temp.
    ENDIF.
  ELSE.
    lv_temp = '전체'.
  ENDIF.
  PERFORM add_row USING lr_dd_table col_field col_value '전표번호' lv_temp.

*-- 전기일자
  so_bud = VALUE #( so_bud[ 1 ] OPTIONAL ).
  CLEAR : lv_temp.
  IF so_bud-low IS NOT INITIAL.
    lv_temp = so_bud-low.
    IF so_bud-high IS NOT INITIAL.
      CONCATENATE lv_temp ' ~ ' so_bud-high INTO lv_temp.
    ENDIF.
  ELSE.
    lv_temp = '전체'.
  ENDIF.
  PERFORM add_row USING lr_dd_table col_field col_value '전기일' lv_temp.


*-- top of page 설치
  PERFORM set_top_of_page.


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

*-- Creating html control
  IF go_html_cntrl IS INITIAL.
    CREATE OBJECT go_html_cntrl
      EXPORTING
        parent = go_top_container.
  ENDIF.

  CALL METHOD go_dyndoc_id->merge_document.
  go_dyndoc_id->html_control = go_html_cntrl.


*-- Display document
  CALL METHOD go_dyndoc_id->display_document
    EXPORTING
      reuse_control      = 'X'
      parent             = go_top_container
    EXCEPTIONS
      html_display_error = 1.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form register_event
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*FORM register_event .

*  CALL METHOD go_dyndoc_id->initialize_document
*    EXPORTING
*      background_color = cl_dd_area=>col_textarea.
*
*  CALL METHOD go_up_grid->list_processing_events
*    EXPORTING
*      i_event_name = 'TOP_OF_PAGE'
*      i_dyndoc_id  = go_dyndoc_id.

*ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_hotspot_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&---------------------------------------------------------------------*
FORM handle_hotspot_click  USING    pv_row_id
                                    pv_column_id.

  DATA : lv_tabix TYPE sy-tabix.

  " 선택한 행의 정보를 읽어옴
  READ TABLE gt_bkpf INTO gs_bkpf INDEX pv_row_id.

*-- 필드 2개에 핫스팟 적용 ( 전표, 역분개전표 )
  IF pv_column_id EQ 'BELNR' .            " 전표번호일 경우
    CLEAR : gt_bseg.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE gt_bseg
      FROM zc302fit0002
      WHERE belnr EQ gs_bkpf-belnr
      ORDER BY buzei  ASCENDING.

  ELSEIF pv_column_id EQ 'STBLG'.         " 역분개전표 번호일 경우
    CLEAR : gt_bseg.

    " 역분개 전표 데이터 확인
    IF ( gs_bkpf-belnr ) IS NOT INITIAL AND
       ( gs_bkpf-stblg ) IS INITIAL .
      MESSAGE i001 WITH TEXT-e10 DISPLAY LIKE 'E'.
      CALL METHOD go_down_grid->refresh_table_display.
      EXIT.
    ENDIF.

    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE gt_bseg
      FROM zc302fit0002
      WHERE belnr EQ gs_bkpf-stblg
      ORDER BY buzei ASCENDING.

  ENDIF.


*-- Get texttable 계정과목명
  SELECT saknr txt50
    INTO CORRESPONDING FIELDS OF TABLE gt_txt
    FROM zc302mt0006.

  SORT gt_txt BY saknr ASCENDING.

  LOOP AT gt_bseg INTO gs_bseg.
    lv_tabix = sy-tabix.

    READ TABLE gt_txt INTO gs_txt WITH KEY saknr = gs_bseg-hkont BINARY SEARCH.

    IF sy-subrc = 0.
      gs_bseg-txt50 = gs_txt-txt50.
    ENDIF.

    MODIFY gt_bseg FROM gs_bseg INDEX lv_tabix TRANSPORTING txt50.
  ENDLOOP.


  CALL METHOD go_down_grid->refresh_table_display.
  CALL METHOD go_up_grid->check_changed_data.

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

  DATA : lv_tabix TYPE sy-tabix.

*-- 버튼 아이콘 설정
  LOOP AT gt_bkpf INTO gs_bkpf.
    lv_tabix = sy-tabix.

    " 역분개필드 데이터 확인
    IF gs_bkpf-stgrd IS INITIAL.
      gs_bkpf-btn = icon_create_text.
    ELSE.
      gs_bkpf-btn = icon_display_text.
    ENDIF.

    MODIFY gt_bkpf FROM gs_bkpf INDEX lv_tabix TRANSPORTING btn.

  ENDLOOP.

  " ALV에서 역분개 필드에 값이 없다면 생성 아이콘을 넣고,
  " 값이 있다면 조회 아이콘을 넣는다.
  " => 아이콘을 통해 역분개전표를 생성/ 조회 할 수 있다.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_textedit_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_textedit_data .

**-- 게시물 번호 별도 보관 ( 밑에 로직은 일단 상관 X)
*  CLEAR gv_stgrd.
*  IF gt_bkpf IS NOT INITIAL.
**      READ TABLE gt_text INTO gs_text INDEX 1.  " Original
*    gs_bkpf = VALUE #( gt_bkpf[ 1 ] OPTIONAL ). " New
*    gv_stgrd = gs_bkpf-stgrd.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_text
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_text .

  DATA : lv_stgrd  TYPE zc302fit0001-stgrd,  "역분개 사유 (텍스트 에디터값 받아올 변수)
         lv_answer.


*-- 역분개 전표 헤더 정보 생성
  " 텍스트 저장 전 확인
  PERFORM confirm_text CHANGING lv_answer.

  IF lv_answer NE '1'.  " 아니오 로직
    EXIT.
  ENDIF.


*-- 역분개 번호 채번
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '05'
      object      = 'ZNRC302_2'
    IMPORTING
      number      = gv_number.

*-- 기존 선택된행 값 업데이트
  gs_bkpf-stblg = gv_number.
  gs_bkpf-btn   = ''.
  gs_bkpf-aedat = sy-datum.
  gs_bkpf-aezet = sy-uzeit.
  gs_bkpf-aenam = sy-uname.

*-- 역분개 내역 추가
  " 텍스트 에디터에서 입력값 가져옴
  CALL METHOD go_text_edit->get_text_as_r3table
    IMPORTING
      table                  = gt_content
    EXCEPTIONS
      error_dp               = 1
      error_cntl_call_method = 2
      error_dp_create        = 3
      potential_data_loss    = 4
      OTHERS                 = 5.

  " 텍스트 내용이 없으면 오류 메세지
  IF gt_content IS INITIAL.
    MESSAGE i001 WITH TEXT-e02 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  " 텍스트 에디터의 내용 역분개 내역으로 옮김(줄바꿈은 띄어쓰기로 구분)
  LOOP AT gt_content INTO gs_content.
    CONCATENATE gs_bkpf-stgrd gs_content-tdline cl_abap_char_utilities=>newline INTO gs_bkpf-stgrd.
  ENDLOOP.

  lv_stgrd = gs_bkpf-stgrd.
  CALL METHOD go_text_edit->delete_text.

  " ITAB에 반영
  MODIFY gt_bkpf FROM gs_bkpf INDEX gv_pre_row TRANSPORTING stblg stgrd aedat aezet aenam.

*--------------------------------------------------------------------*
* 신규 역분개 전표 생성
*--------------------------------------------------------------------*
*-- 신규 역분개 전표 헤더 생성
  CLEAR : gs_bkpf.
  gs_bkpf-bukrs = gv_bukrs.     " 회사번호
  gs_bkpf-belnr =  gv_number.   " 전표번호(역분개)
  gs_bkpf-gjahr = gv_gjahr.     " 회계연도
  gs_bkpf-blart =  gv_blart.    " 전표유형
  gs_bkpf-bktxt = gv_bktxt.     " 전표헤더텍스트
  gs_bkpf-bldat = sy-datum.     " 증빙일자
  gs_bkpf-budat = sy-datum.     " 전기일자
  gs_bkpf-stblg = gv_belnr.     " 역분개번호(역분개 전 전표)
  gs_bkpf-stgrd = lv_stgrd.     " 역분개사유
  gs_bkpf-emp_num = sy-uname.   " 담당직원
  gs_bkpf-waers = gv_waers.     " 통화
  gs_bkpf-xref1_hd = gv_xref1_hd. " 참조필드
  gs_bkpf-erdat = sy-datum.     " 생성날짜
  gs_bkpf-erzet = sy-uzeit.     " 생성시간
  gs_bkpf-ernam = sy-uname.     " 생성자
  APPEND gs_bkpf TO gt_bkpf.

  " 기존 헤더 & 신규 헤더 한번에 DB 반영
  PERFORM save_header.

*-- 신규 역분개 전표 아이템 생성하여 DB 반영
  PERFORM create_reserveitem.

*-- 생성 성공시 메세지
  IF sy-subrc EQ 0.
    MESSAGE s001 WITH TEXT-e03.
  ENDIF.

  PERFORM get_base_data.
  PERFORM make_display_body.

  PERFORM refresh_up_table.

  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_create_btn_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ES_COL_ID
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM handle_create_btn_click  USING    pv_col_id
                                       ps_row_no TYPE lvc_s_roid.

  DATA : lv_answer.

*-- 선택한 전표 헤더 읽어오기
  CLEAR : gv_belnr.
  gv_pre_row = ps_row_no-row_id.
  READ TABLE gt_bkpf INTO gs_bkpf INDEX ps_row_no-row_id.
  gv_belnr = gs_bkpf-belnr.    " 선택한 전표 인덱스 백업
  gv_bukrs = gs_bkpf-bukrs.
  gv_gjahr = gs_bkpf-gjahr.
  gv_blart = gs_bkpf-blart.
  gv_bktxt = gs_bkpf-bktxt.
  gv_waers = gs_bkpf-waers.
  gv_zisdn = gs_bkpf-zisdn.
  gv_zisdd = gs_bkpf-zisdd.
  gv_xref1_hd = gs_bkpf-xref1_hd.


*- 반제 전표 체크
  IF gs_bkpf-augbl IS NOT INITIAL.
    MESSAGE i001 WITH TEXT-e05  DISPLAY LIKE 'E'.
  ENDIF.

*-- TEXT EDITOR 팝업 띄우기
  IF gs_bkpf-stgrd IS INITIAL.
    PERFORM confirm CHANGING lv_answer.

    IF lv_answer NE '1'.  " 아니오 로직
      EXIT.
    ENDIF.
    " 역분개 사유 생성 popup - Text editor
    CALL SCREEN 101 STARTING AT 06 05.
    PERFORM make_display_body.
  ELSE.
    " 역분개 사유 조회 popup
    CALL SCREEN 102 STARTING AT 06 05.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_textpop
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_textpop .

  IF gs_bkpf-btn IS NOT INITIAL.
    CALL SCREEN 101 STARTING AT 60 05.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_reserveitem
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_reserveitem.

  DATA : lt_bseg  TYPE TABLE OF zc302fit0002,
         ls_bseg  TYPE zc302fit0002,
         lv_tabix TYPE sy-tabix.

*-- 기존 전표의 아이템 읽어오기
  CLEAR lt_bseg.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE lt_bseg
    FROM zc302fit0002
   WHERE belnr EQ gv_belnr.

*-- 아이템들 차대변 바꿔주기
  LOOP AT lt_bseg INTO ls_bseg.
    lv_tabix = sy-tabix.

    CASE ls_bseg-shkzg.
      WHEN 'H'.
        ls_bseg-shkzg = 'S'.
      WHEN 'S'.
        ls_bseg-shkzg = 'H'.
    ENDCASE.

    ls_bseg-belnr =  gv_number.
    ls_bseg-erdat = sy-datum.
    ls_bseg-erzet = sy-uzeit.
    ls_bseg-ernam = sy-uname.

    MODIFY lt_bseg FROM ls_bseg INDEX lv_tabix TRANSPORTING shkzg belnr erdat erzet ernam.
  ENDLOOP.

  MODIFY zc302fit0002 FROM TABLE lt_bseg.

  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_header .
  DATA : lt_save   TYPE TABLE OF zc302fit0001,
         ls_save   TYPE zc302fit0001,
         lv_tabix  TYPE sy-tabix,
         lv_answer.

  CLEAR : lt_save.
  MOVE-CORRESPONDING gt_bkpf TO lt_save.

  IF lt_save IS INITIAL.
    MESSAGE s001 WITH TEXT-e07.
  ENDIF.

  MODIFY zc302fit0001 FROM TABLE lt_save.

  IF sy-subrc = 0.
    COMMIT WORK AND WAIT.

  ELSE.
    ROLLBACK WORK.

  ENDIF.


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
      titlebar              = '역분개 생성'
      text_question         = '역분개 전표를 생성하시겠습니까?'
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
*& Form set_popup
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_popup .

*-- Set text popup
  IF go_text_cont IS NOT BOUND.
    PERFORM create_text_object.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_text_object
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_text_object .

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
      toolbar_mode = go_text_edit->false.  " true 대신 1로, false 대신 0으로 넣어도 된다.

*-- Display <-> Change
  CALL METHOD go_text_edit->set_readonly_mode
    EXPORTING
      readonly_mode = go_text_edit->false.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_selection_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_selection_screen .

*-- 회사코드 입력창 닫기
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'BUK'.
        screen-input = 0.
    ENDCASE.

    MODIFY SCREEN.
  ENDLOOP.

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

  " ALV 저장 후 선택된 위치 그대로 고정
  DATA: ls_stable TYPE lvc_s_stbl.

  ls_stable-col = abap_true.
  ls_stable-row = abap_true.

  CALL METHOD go_up_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stable.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_pop_display2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_pop_display2 .

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
      container_name = 'POP2_CON'.

*-- Text Editor
  CREATE OBJECT go_text_edit2
    EXPORTING
      wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
      parent        = go_text_cont2.

*-- Edit toolbar
  CALL METHOD go_text_edit2->set_toolbar_mode
    EXPORTING
      toolbar_mode = go_text_edit2->true.  " true 대신 1로, false 대신 0으로 넣어도 된다.

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

*-- DB로 부터 내용을 받아왔다면 editor에 binding 한다.
  IF gt_bkpf IS NOT INITIAL.

    CLEAR gs_bkpf.
    READ TABLE gt_bkpf INTO gs_bkpf INDEX gv_pre_row.   " Original syntax


*-- 줄바꿈 기호를 기준으로 단어를 분리
    SPLIT gs_bkpf-stgrd AT cl_abap_char_utilities=>newline " 줄바꿈 ( AT 뒤에는 기호 지정 -> 기호에 따라 SPLIT으로 단어 분리 )
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

    CALL METHOD go_text_edit2->set_readonly_mode
      EXPORTING
        readonly_mode = go_text_edit2->true.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form confirm_text
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM confirm_text  CHANGING pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = '역분개 생성'
      text_question         = '역분개 전표를 생성하면 수정할 수 없습니다. 생성하시겠습니까?'
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
*& Form get_f4_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_f4_data .

  CLEAR : gs_search, gt_search.
  SELECT belnr
    INTO CORRESPONDING FIELDS OF TABLE gt_search
    FROM zc302fit0001
    WHERE belnr NOT LIKE '5%'
    ORDER BY belnr ASCENDING.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F4_BELNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_belnr .

  DATA : lt_return LIKE TABLE OF ddshretval WITH HEADER LINE.

  REFRESH : lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'BELNR'     " Input에 넣어줄 필드
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'SO_BEL'    " Selection Screen Element
      window_title    = '전표번호'     " Description
      value_org       = 'S'
    TABLES
      value_tab       = gt_search    " F4에 뿌려줄 데이터(INITIALIZATION에서 select함)
      return_tab      = lt_return    " F4에서 선택된 값에 대한 정보
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
