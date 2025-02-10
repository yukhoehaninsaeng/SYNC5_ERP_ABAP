*&---------------------------------------------------------------------*
*& Include          SAPMZC302FI0003F01
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

  PERFORM set_ranges.

  " 입출금내역 테이블 & 전표 헤더 join
  CLEAR : gt_body.
  SELECT wdnum, sfnum, cust_num, cust_name, banka, bankn,
         price, a~waers, dw_flag, dwdate, bel_flag, belnr, xref1_hd,
         a~erdat, a~erzet, a~ernam
    INTO CORRESPONDING FIELDS OF TABLE @gt_body
    FROM zc302fit0006 AS a LEFT OUTER JOIN zc302fit0001 AS b   " Left outer join 할때는 먼저 적용되야할 조건절을 ON절에 넣어줘야함
      ON a~sfnum EQ b~xref1_hd
     AND belnr  NOT LIKE '5%'
   WHERE sfnum    IN @gr_rfnum
     AND bel_flag EQ @gv_belflag
     AND dwdate   IN @gr_pdate
     AND dw_flag  IN @gr_dwflag
   ORDER BY sfnum ASCENDING.

*    SELECT  wdnum sfnum cust_num cust_name banka bankn
*         price a~waers dw_flag dwdate bel_flag belnr xref1_hd
*         a~erdat a~erzet a~ernam
*    INTO CORRESPONDING FIELDS OF TABLE gt_body
*    FROM zc302fit0006 AS a LEFT OUTER JOIN zc302fit0001 AS b
*      ON a~sfnum EQ b~xref1_hd
*    WHERE sfnum    IN gr_rfnum
*      AND bel_flag EQ gv_belflag
*      AND dwdate   IN gr_pdate
*      AND dw_flag  IN gr_dwflag
* ORDER BY sfnum ASCENDING.

  " 데이터 유무 확인
  IF gt_body IS INITIAL.
    MESSAGE s001 WITH TEXT-i01 DISPLAY LIKE 'E'.
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

    " LEFT GRID - 입출금내역
    CLEAR : gt_lfcat.
    PERFORM set_left_fcat USING : ' ' 'DW_FLAG'  'ZC302FIT0006' 'C' 'X' '1',
                                  'X' 'SFNUM'    'ZC302FIT0006' 'C' ' ' '2',
                                  'X' 'WDNUM'    'ZC302FIT0006' 'C' ' ' '3',
                                  'X' 'CUST_NUM' 'ZC302FIT0006' 'C' ' ' '4',
                                  ' ' 'BANK'    'ZC302FIT0006' 'C' ' ' '5',
                                  ' ' 'BANKN'    'ZC302FIT0006' 'C' ' ' '6',
                                  ' ' 'PRICE'    'ZC302FIT0006' ' ' ' ' '7',
                                  ' ' 'WAERS'    'ZC302FIT0006' 'C' ' ' '8',
                                  ' ' 'DWDATE'   'ZC302FIT0006' 'C' ' ' '9',
                                  ' ' 'ICON'     '  '           'C' ' ' '10',
                                  ' ' 'BTN'      '  '           'C' ' ' '11',
                                  ' ' 'BELNR'    ' '            'C' ' ' '12'.

    " RIGHT GRID - 판매내역
    CLEAR : gt_rfcat.
    PERFORM set_right_fcat USING :'X' 'SONUM' '판매주문번호' 'C' ' ' '1',
                                  ' ' 'PDATE' '주문일자'    'C' ' ' '2',
                                  ' ' 'POSNR' '아이템번호'   'C' ' ' '3',
                                  ' ' 'MATNR' '자재코드'    'C' ' ' '4',
                                  ' ' 'MENGE' '수량'       'C' ' ' '5',
                                  ' ' 'MEINS' '단위'       'C' ' ' '6',
                                  ' ' 'NETWR' '판매금액'    'C' ' ' '7',
                                  ' ' 'WAERS' '통화'       'C' ' ' '8'.
    " RIGHT GRID - 반품내역
    CLEAR: gt_rfcat2.
    PERFORM set_right_fcat2 USING : 'X' 'RFNUM'  '반품번호'    'C' ' ' '1',
                                    'X' 'SONUM'  '판매주문번호'  'C' ' ' '2',
                                    ' ' 'PDATE'  '주문일자'    'C'  ' ' '3',
                                    ' ' 'POSNR'  '아이템번호'   'C' ' ' '4',
                                    ' ' 'MATNR'  '자재코드'    'C' ' ' '5',
                                    ' ' 'MENGE'  '수량'      'C' ' ' '6',
                                    ' ' 'MEINS'  '단위'      'C' ' ' '7',
                                    ' ' 'NETWR'  '금액'      'C' ' ' '8',
                                    ' ' 'WAERS'  '통화'      'C' ' ' '9',
*                                    ' ' 'RCDAT'  '반품처리일자' 'C' ' ' '10',
                                    ' ' 'REMARK' '반품사유'    'C' ' ' '11'.



    PERFORM set_layout.
    PERFORM exclude_button TABLES gt_ui_functions.
    PERFORM create_object.

    " EVENT 설치
    SET HANDLER : lcl_event_handler=>hotspot_click FOR go_left_grid,
                  lcl_event_handler=>create_btn_click FOR go_left_grid,
                  lcl_event_handler=>double_click FOR go_left_grid.

    gs_variant-report = sy-repid.
    gs_variant-handle = 'ALV1'.

    " LEFT GRID
    CALL METHOD go_left_grid->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        i_save               = 'A'
        i_default            = 'X'
        is_layout            = gs_layout
        it_toolbar_excluding = gt_ui_functions
      CHANGING
        it_outtab            = gt_body
        it_fieldcatalog      = gt_lfcat.


    gs_variant-handle = 'ALV2'.
    " RIGHT GRID - 판매내역
    CALL METHOD go_right_grid->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        i_save               = 'A'
        i_default            = 'X'
        is_layout            = gs_layout
        it_toolbar_excluding = gt_ui_functions
      CHANGING
        it_outtab            = gt_sdata
        it_fieldcatalog      = gt_rfcat.

    " RIGHT GRID - 반품내역
    gs_variant-handle = 'ALV3'.
    CALL METHOD go_right_grid->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        i_save               = 'A'
        i_default            = 'X'
        is_layout            = gs_layout2
        it_toolbar_excluding = gt_ui_functions
      CHANGING
        it_outtab            = gt_fdata
        it_fieldcatalog      = gt_rfcat2.

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

  " left layout
  gs_layout-zebra = 'X'.
  gs_layout-cwidth_opt = 'A'.
  gs_layout-sel_mode = 'D'.
  gs_layout-grid_title = 'B2C 입/출금 내역'.
  gs_layout-smalltitle = abap_true.

  " right layout
  gs_layout2-zebra = 'X'.
  gs_layout2-cwidth_opt = 'A'.
  gs_layout2-sel_mode = 'D'.
  gs_layout2-grid_title = 'B2C 판매/반품 내역'.
  gs_layout2-smalltitle = abap_true.

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

*-- Main container
  CREATE OBJECT go_container
    EXPORTING
      container_name = 'MAIN_CONT'.

*-- Splitter container
  CREATE OBJECT go_split_cont
    EXPORTING
      parent  = go_container
      rows    = 1
      columns = 2.

*-- Assign container  -> 오브젝트는 따로 생성 안해줘도 된다 (자동으로 생성됨)
  CALL METHOD go_split_cont->get_container
    EXPORTING
      row       = 1  " 왼쪽 1행 1열에는 left container
      column    = 1
    RECEIVING     " 객체를 생성해줌
      container = go_left_cont.

  CALL METHOD go_split_cont->get_container
    EXPORTING
      row       = 1  " 오른쪽 1행 2열에는 right container
      column    = 2
    RECEIVING
      container = go_right_cont.

*-- 간격 줄이기
  CALL METHOD go_split_cont->set_column_width
    EXPORTING
      id    = 1     " Column ID (왼쪽이니까 1번 )
      width = 58.   " 퍼센테이지

  " ALV 생성
  CREATE OBJECT go_left_grid
    EXPORTING
      i_parent = go_left_cont.

  CREATE OBJECT go_right_grid
    EXPORTING
      i_parent = go_right_cont.




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

  REFRESH : gr_bukrs, gr_pdate, gr_rfnum, gr_dwflag.

  " 회사번호
  IF gv_bukrs IS NOT INITIAL.
    gr_bukrs-sign = 'I'.
    gr_bukrs-option = 'EQ'.
    gr_bukrs-low = gv_bukrs.
    APPEND gr_bukrs.
  ENDIF.

  " 참조번호
  IF gv_rfnum IS NOT INITIAL.
    gr_rfnum-sign = 'I'.
    gr_rfnum-option = 'EQ'.
    gr_rfnum-low = gv_rfnum.
    APPEND gr_rfnum.
  ENDIF.

  " 전표생성여부
*  IF gv_belflag IS NOT INITIAL.
*    gr_bel_flag-sign = 'I'.
*    gr_bel_flag-option = 'EQ'.
*    gr_bel_flag-low = gv_belflag.
*    APPEND gr_bel_flag.
*  ENDIF.

  " 전표 일자
  IF gv_dat_fr IS NOT INITIAL.
    gr_pdate-sign = 'I'.
    gr_pdate-option = 'EQ'.
    gr_pdate-low = gv_dat_fr.

    IF gv_dat_to IS NOT INITIAL.
      gr_pdate-option = 'BT'.
      gr_pdate-high = gv_dat_to.
    ENDIF.

    APPEND gr_pdate.
  ENDIF.

  " 입금/출금
  IF gv_dwflag IS NOT INITIAL.
    gr_dwflag-sign = 'I'.
    gr_dwflag-option = 'EQ'.
    gr_dwflag-low = gv_dwflag.
    APPEND gr_dwflag.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_left_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_left_fcat  USING  pv_key pv_field pv_table pv_just pv_emph pv_pos.

  CLEAR : gs_lfcat.
  gs_lfcat-key = pv_key.
  gs_lfcat-fieldname = pv_field.
  gs_lfcat-ref_table = pv_table.
  gs_lfcat-just = pv_just.
  gs_lfcat-emphasize = pv_emph.
  gs_lfcat-col_pos = pv_pos.

  CASE pv_field.
    WHEN 'DW_FLAG'.
      gs_lfcat-coltext = '입/출금'.
    WHEN 'BANKA'.
      gs_lfcat-coltext = '은행'.
    WHEN 'BANKN'.
      gs_lfcat-coltext = '계좌번호'.
    WHEN 'PRICE'.
      gs_lfcat-coltext = '금액'.
      gs_lfcat-cfieldname = 'WAERS'.
    WHEN 'WAERS'.
      gs_lfcat-coltext = '통화'.
    WHEN 'CREATE'.
      gs_lfcat-coltext = '전표생성'.
    WHEN 'CUST_NUM'.
      gs_lfcat-coltext = '회원코드'.
    WHEN 'ICON'.
      gs_lfcat-coltext = '전표생성여부'.
    WHEN 'DWDATE'.
      gs_lfcat-coltext = '입출금일자'.
    WHEN 'SFNUM'.
      gs_lfcat-hotspot = abap_true.
    WHEN 'BTN'.
      gs_lfcat-coltext = '전표생성'.
      gs_lfcat-style   = cl_gui_alv_grid=>mc_style_button.
    WHEN 'BELNR'.
      gs_lfcat-coltext = '전표번호'.
      gs_lfcat-emphasize = abap_true.
    WHEN 'BANK'.
      gs_lfcat-coltext = '은행'.

  ENDCASE.

  APPEND gs_lfcat TO gt_lfcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_hotspot_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&---------------------------------------------------------------------*
FORM handle_hotspot_click  USING   pv_row_id pv_column_id.
  DATA: lv_sum TYPE zc302fit0002-price.

  CLEAR gs_body.
  READ TABLE gt_body INTO gs_body INDEX pv_row_id.

  IF gs_body-sfnum CP 'SO*'.

*-- 선택한 데이터를 읽어온다
*  CLEAR gt_sdata.
*  gs_body-price /= 100.

*- 판매오더 아이템 조회
*-- 선택행에 대한 상세 데이터를 조회한다
    " 판매/ 반품 데이터 따로 가져오기
    CLEAR gt_sdata.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE gt_sdata
      FROM zc302sdt0003 AS a INNER JOIN zc302sdt0004 AS b
        ON a~sonum EQ b~sonum
      WHERE a~sonum EQ gs_body-sfnum.

    LOOP AT gt_sdata INTO gs_sdata.
      lv_sum += gs_sdata-netwr.
    ENDLOOP.

    READ TABLE gt_sdata INTO gs_sdata WITH KEY sonum = gs_body-sfnum.
    IF  gt_sdata IS INITIAL.
      MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.
    ENDIF.


    IF  lv_sum NE gs_body-price .
      MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
    ENDIF.
**********************************************************************
**********************************************************************
  ELSEIF gs_body-sfnum CP 'RN*'.
* 반품 데이터 가져오기
    CLEAR : gt_fdata.
    SELECT a~rfnum a~sonum a~remark rcdat c~posnr c~matnr c~menge c~meins
           pdate c~netwr c~waers
    INTO CORRESPONDING FIELDS OF TABLE gt_fdata
    FROM zc302sdt0007 AS a
      INNER JOIN zc302sdt0003 AS b
        ON a~sonum EQ b~sonum
      INNER JOIN zc302sdt0004 AS c
        ON b~sonum EQ c~sonum
    WHERE a~rfnum EQ gs_body-sfnum.


    " 반품 데이터 금액 확인
    LOOP AT gt_fdata INTO gs_fdata.
      lv_sum += gs_fdata-netwr.
    ENDLOOP.

    READ TABLE gt_fdata INTO gs_fdata WITH KEY sonum = gs_body-sfnum.

    " 데이터 빈값 확인
    IF  gt_fdata IS INITIAL.
      MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.
    ENDIF.

    " 판매금액, 입금금액 확인
    IF  lv_sum NE gs_body-price .
      MESSAGE s001 WITH TEXT-e03 DISPLAY LIKE 'E'.
    ENDIF.

  ENDIF.


*-- 참조번호에 따른 ALV 설정
  " 판매번호일때
  IF gs_body-sfnum CP 'SO*'.
    CALL METHOD go_right_grid->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        i_save               = 'A'
        i_default            = 'X'
        is_layout            = gs_layout
        it_toolbar_excluding = gt_ui_functions
      CHANGING
        it_outtab            = gt_sdata
        it_fieldcatalog      = gt_rfcat.

    " 반품번호일때
  ELSEIF gs_body-sfnum CP 'RN*'.

    CALL METHOD go_right_grid->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        i_save               = 'A'
        i_default            = 'X'
        is_layout            = gs_layout
        it_toolbar_excluding = gt_ui_functions
      CHANGING
        it_outtab            = gt_fdata
        it_fieldcatalog      = gt_rfcat2.

  ENDIF.

  CALL METHOD go_right_grid->refresh_table_display.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_reft_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_right_fcat  USING   pv_key pv_field pv_table pv_just pv_emph pv_pos.

  CLEAR : gs_rfcat.
  gs_rfcat-key = pv_key.
  gs_rfcat-fieldname = pv_field.
  gs_rfcat-coltext = pv_table.
  gs_rfcat-just = pv_just.
  gs_rfcat-emphasize = pv_emph.
  gs_lfcat-col_pos = pv_pos.

  CASE pv_field.
    WHEN 'NETWR'.
      gs_rfcat-cfieldname = 'WAERS'.
      gs_rfcat-do_sum = abap_true.
    WHEN 'MENGE'.
      gs_rfcat-qfieldname = 'MEINS'.
  ENDCASE.

  APPEND gs_rfcat TO gt_rfcat.

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

  LOOP AT gt_body INTO gs_body.

    lv_tabix = sy-tabix.

    " 전표 생성 시 플래그 아이콘 변경
    CASE gs_body-bel_flag.
      WHEN 'X'.
        gs_body-icon = icon_led_green.
      WHEN ' '.
        gs_body-icon = icon_led_red.
        gs_body-btn  = icon_create_text.
    ENDCASE.

    CASE gs_body-banka.
      WHEN 'IB'.
        gs_body-bank = '기업은행'.
      WHEN 'SH'.
        gs_body-bank = '신한은행'.
      WHEN 'KB'.
        gs_body-bank = '국민은행 '.
      WHEN 'WR'.
        gs_body-bank = '우리은행 '.
      WHEN 'HN'.
        gs_body-bank = '하나은행 '.
    ENDCASE.

    MODIFY gt_body FROM gs_body INDEX lv_tabix TRANSPORTING icon btn price bank.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_CREATE_BTN_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ES_COL_ID
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM handle_create_btn_click  USING    pv_col_id
                                       ps_row_no TYPE lvc_s_roid.
  DATA : lv_answer.

*-- 유효성 검사 - 권한 확인
*  IF sy-uname NE 'KDT-C-12' AND
*     sy-uname NE 'KDT-C-06'.
*    MESSAGE i001 WITH TEXT-e06 DISPLAY LIKE 'E'.
*    EXIT.
*  ENDIF.


*-- 선택한 행의 정보를 읽어온다
  CLEAR : gs_body.
  READ TABLE gt_body INTO gs_body INDEX ps_row_no-row_id.

  .

*-- 전표 중복 체크
  IF gs_body-belnr IS NOT INITIAL.
    MESSAGE i001 WITH TEXT-i02  DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.
*-- 저장 확인 팝업
  PERFORM confirm CHANGING lv_answer.

  IF lv_answer NE 1.
    EXIT.
  ENDIF.

*-- 전표번호 생성 - 판매/반품
  PERFORM get_belnr.

**********************************************************************
*-- 헤더/ 아이템 생성
  IF gs_body-btn IS NOT INITIAL.

*-- 기존판매내역에 전표 추가 & 전표 헤더 생성(입금/출금)  -> 테이블에 데이터 넣어주는 로직
    IF gs_body-dw_flag EQ 'D'.   "입금일떄
      "- gs_body(입출금내역)기존 선택한 행에 전표번호 넣어주기
      gs_body-belnr = gv_arbel.
      gs_body-bel_flag = 'X'.    " 전표 생성여부 'X'
      gs_body-btn   = ''.
      gs_body-icon = icon_led_green.
      " 인터널테이블에 저장
      MODIFY gt_body FROM gs_body INDEX ps_row_no-row_id
                                  TRANSPORTING belnr bel_flag btn icon.

      " 전표 헤더/아이템 생성 상세
      PERFORM get_bkpf_bseg.

      " 입출금내역 변경 사항 DB 반영
      PERFORM save_body_to_dbtable.

      "전표헤더/아이템 테이블 DB반영
      PERFORM save_dbtable.
*--------------------------------------------------------------------*
      " 출금일떄
    ELSEIF gs_body-dw_flag EQ 'W'.
      "- gs_body(입출금내역)기존 선택한 행에 전표번호 넣어주기
      gs_body-belnr = gv_apbel.
      gs_body-bel_flag = 'X'.    " 전표 생성여부 'X'
      gs_body-btn   = ''.
      gs_body-icon = icon_led_green.
      MODIFY gt_body FROM gs_body INDEX ps_row_no-row_id TRANSPORTING belnr bel_flag btn icon.
      " 전표 헤더/아이템 생성 상세
      PERFORM get_bkpf_bsegw.

      " 입출금내역 변경 사항 DB 반영
      PERFORM save_body_to_dbtable.

      "전표헤더/아이템 테이블 DB반영
      PERFORM save_dbtable.



    ENDIF.
**********************************************************************
*--  전표 생성 성공메세지
    IF sy-subrc EQ 0 .
      MESSAGE s001 WITH TEXT-e04.
    ENDIF.

*-- ALV REFRESH
    PERFORM get_data_base.
    PERFORM make_display_body .
    CALL METHOD go_left_grid->refresh_table_display.


  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_dbtable
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_dbtable .
  DATA : lt_save_h TYPE TABLE OF zc302fit0001,
         ls_save_h TYPE zc302fit0001,
         lt_save_i TYPE TABLE OF zc302fit0002,
         ls_save_i TYPE zc302fit0002,
         lv_tabix  TYPE sy-tabix,
         lv_answer.

  " header, item  값 넣어줌
  CLEAR: lt_save_h, lt_save_i.
  MOVE-CORRESPONDING gt_bkpf TO lt_save_h.
  MOVE-CORRESPONDING gt_bseg TO lt_save_i.

  " 저장내용 빈값 확인
  IF ( lt_save_h  IS INITIAL ) AND
     ( lt_save_i IS INITIAL ).
    MESSAGE s001 WITH TEXT-i01 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*    " 유효성 검사 - 권한 확인
*  IF gs_bkpf-emp_num NE 'KDT-C-12' AND
*     gs_bkpf-emp_num NE 'KDT-C-06'.
*    MESSAGE s000 WITH '권한을 확인하세요.' DISPLAY LIKE 'E'.
*    EXIT.
*  ENDIF.

  " DB 반영
  MODIFY zc302fit0001 FROM TABLE lt_save_h.
  MODIFY zc302fit0002 FROM TABLE lt_save_i.

  " 로직 성공여부 확인
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_belnr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_belnr .

*-- 판매 -> 매출 전표
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '02'
      object      = 'ZNRC302_2'
    IMPORTING
      number      = gv_arbel.

*-- 반품
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZNRC302_2'
    IMPORTING
      number      = gv_apbel.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_bkpf_bseg
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_bkpf_bseg .

  DATA : lv_s_sum      TYPE zc302fit0002-price,
         lv_h_sum      TYPE zc302fit0002-price,
         lv_item_subrc TYPE sy-subrc,   " 아이템 데이터 저장 여부 저장
         lv_price      TYPE zc302fit0002-price,  " 판매금액에서 수익금 계산변수
         lv_gjahr      TYPE zc302fit0002-gjahr.

*  CLEAR : gs_body.
  READ TABLE gt_body INTO gs_body INDEX gv_pre_row.

  lv_price = gs_body-price / '1.1'.
  lv_gjahr = gs_body-dwdate(4).

**********************************************************************
* 입금 전표/ 아이템 생성
*-- 전표 헤더
  CLEAR : gs_bkpf.
  gs_bkpf-bukrs = '1000'.
  gs_bkpf-belnr = gv_arbel.
  gs_bkpf-gjahr = lv_gjahr.         "연도 추출
  gs_bkpf-blart = 'DZ'.             "고객지불 유형 (blart tt 확인완)
  gs_bkpf-bldat = gs_body-dwdate.   "전표 증빙일
  gs_bkpf-budat = gs_body-dwdate.   "전기일
  gs_bkpf-bktxt = '온라인주문' && gs_body-sfnum.
  gs_bkpf-emp_num = sy-uname.
  gs_bkpf-waers = 'KRW'.
  gs_bkpf-xref1_hd = gs_body-sfnum.
  gs_bkpf-erdat = sy-datum.
  gs_bkpf-ernam = sy-uname.
  gs_bkpf-erzet = sy-uzeit.

  APPEND gs_bkpf TO gt_bkpf.

*--------------------------------------------------------------------*
*-- 전표 아이템
  " 차변 - 현금 (자산의 증가)
  CLEAR : gs_bseg.
  gs_bseg-bukrs = '1000'.
  gs_bseg-belnr = gv_arbel.
  gs_bseg-gjahr = lv_gjahr.
  gs_bseg-buzei = '1'.
  gs_bseg-koart = 'D'. " 고객
  gs_bseg-shkzg = 'S'. " 차변
  gs_bseg-hkont = 'ACC0001000'.     " 현금 계정번호
  gs_bseg-price = gs_body-price.
  gs_bseg-waers = gs_body-waers.
*  gs_bseg-bpcode =
  gs_bseg-erdat = sy-datum.
  gs_bseg-ernam = sy-uname.
  gs_bseg-erzet = sy-uzeit.
  SELECT SINGLE txt50 FROM zc302mt0006 INTO gs_bseg-txt50
                                     WHERE bukrs = '1000'
                                       AND ktopl = 'CAKR'.
  APPEND gs_bseg TO gt_bseg.

  " 대변 - 수익금
  CLEAR : gs_bseg.
  gs_bseg-bukrs = '1000'.
  gs_bseg-belnr = gv_arbel.
  gs_bseg-gjahr = lv_gjahr.
  gs_bseg-buzei = '2'.
  gs_bseg-koart = 'D'. " 고객
  gs_bseg-shkzg = 'H'. " 대변
  gs_bseg-hkont = 'ACC0006001'.     " 제품수익(자체생산) 계정번호
  gs_bseg-price =  lv_price.
  gs_bseg-waers = gs_body-waers.
*  gs_bseg-bpcode =
  gs_bseg-erdat = sy-datum.
  gs_bseg-ernam = sy-uname.
  gs_bseg-erzet = sy-uzeit.
  SELECT SINGLE txt50 FROM zc302mt0006 INTO gs_bseg-txt50
                                   WHERE bukrs = '1000'
                                     AND ktopl = 'CAKR'.
  APPEND gs_bseg TO gt_bseg.

  " 대변 - 매출세액(
  CLEAR : gs_bseg.
  gs_bseg-bukrs = '1000'.
  gs_bseg-belnr = gv_arbel.
  gs_bseg-gjahr = lv_gjahr.
  gs_bseg-buzei = '3'.
  gs_bseg-koart = 'D'. " 고객
  gs_bseg-shkzg = 'H'. " 대변
  gs_bseg-hkont = 'ACC0003016'.     " 매출세액(부가세예수금) 계정번호
  gs_bseg-price = gs_body-price - lv_price.
  gs_bseg-waers = gs_body-waers.
*  gs_bseg-bpcode =

  gs_bseg-erdat = sy-datum.
  gs_bseg-ernam = sy-uname.
  gs_bseg-erzet = sy-uzeit.
  SELECT SINGLE txt50 FROM zc302mt0006 INTO gs_bseg-txt50
                                        WHERE bukrs = '1000'
                                        AND ktopl = 'CAKR'.
  APPEND gs_bseg TO gt_bseg.


  "차변 금액이 맞을때 유효성 검사 - 권한 확인
*  IF  gs_bkpf-emp_num  NE 'KDT-C-12' AND
*      gs_bkpf-emp_num  NE 'KDT-C-06'.
*    MESSAGE s001 WITH '권한을 확인하세요.' DISPLAY LIKE 'E'.
*    EXIT.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_body_to_dbtable
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_body_to_dbtable .
  DATA : ls_save TYPE zc302fit0006.

  " 저장내용 옮겨줌
  MOVE-CORRESPONDING gs_body TO ls_save.

  " Timestamp 저장

  ls_save-aedat = sy-datum.
  ls_save-aezet = sy-uzeit.
  ls_save-aenam = sy-uname.

  " DB 반영
  MODIFY zc302fit0006 FROM ls_save.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form confirm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM confirm  CHANGING pv_answer.

  " 생성 전 확인
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = '전표 생성'
      text_question         = '전표를 생성하시겠습니까??'
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
*& Form get_bkpf_bsegw
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_bkpf_bsegw .
  DATA : lv_s_sum      TYPE zc302fit0002-price,  " 차변 합계
         lv_h_sum      TYPE zc302fit0002-price,  " 대변 합계
         lv_item_subrc TYPE sy-subrc,            " 아이템 데이터 저장 여부 저장
         lv_price      TYPE zc302fit0002-price.  " 판매금액에서 수익금 계산변수

  " 부가세 계산
  lv_price = gs_body-price / '1.1'.

**********************************************************************
*** 반품 전표/ 아이템 생성
*-- 전표 헤더
  CLEAR : gs_bkpf.
  gs_bkpf-bukrs = '1000'.
  gs_bkpf-belnr = gv_apbel.
  gs_bkpf-gjahr = gs_body-dwdate+1(4).  "연도 추출
  gs_bkpf-blart = 'DZ'.             "고객지불 유형
  gs_bkpf-bldat = gs_body-dwdate.   "전표 증빙일
  gs_bkpf-budat = gs_body-dwdate.   "전기일
  gs_bkpf-bktxt = '온라인반품' && gs_body-sfnum.
  gs_bkpf-emp_num = sy-uname.
  gs_bkpf-waers = 'KRW'.
  gs_bkpf-xref1_hd = gs_body-sfnum.
  gs_bkpf-erdat = sy-datum.
  gs_bkpf-ernam = sy-uname.
  gs_bkpf-erzet = sy-uzeit.
  APPEND gs_bkpf TO gt_bkpf.

*--------------------------------------------------------------------*
*-- 전표 아이템
  " 대변 - 현금 (자산의 감소)
  CLEAR : gs_bseg.
  gs_bseg-bukrs = '1000'.
  gs_bseg-belnr = gv_apbel.
  gs_bseg-gjahr = gs_body-dwdate+1(4).
  gs_bseg-buzei = '1'.
  gs_bseg-koart = 'D'. " 고객
  gs_bseg-shkzg = 'H'. " 대변
  gs_bseg-hkont = 'ACC0001000'.      " 현금 감소
  gs_bseg-price = gs_body-price.
  gs_bseg-waers = gs_body-waers.
*  gs_bseg-bpcode =
  gs_bseg-erdat = sy-datum.
  gs_bseg-ernam = sy-uname.
  gs_bseg-erzet = sy-uzeit.

  SELECT SINGLE txt50 FROM zc302mt0006 INTO gs_bseg-txt50
                                        WHERE bukrs = '1000'
                                        AND ktopl = 'CAKR'.
  APPEND gs_bseg TO gt_bseg.

  " 차변 - 제품매출(반품)
  CLEAR : gs_bseg.
  gs_bseg-bukrs = '1000'.
  gs_bseg-belnr = gv_apbel.
  gs_bseg-gjahr = gs_body-dwdate+1(4).
  gs_bseg-buzei = '2'.
  gs_bseg-koart = 'D'. " 고객
  gs_bseg-shkzg = 'S'. " 차변
  gs_bseg-hkont = 'ACC0006001'.     " 제품매출(반품) 계정번호
  gs_bseg-price =  lv_price.
  gs_bseg-waers = gs_body-waers.
*  gs_bseg-bpcode =
  gs_bseg-erdat = sy-datum.
  gs_bseg-ernam = sy-uname.
  gs_bseg-erzet = sy-uzeit.
  SELECT SINGLE txt50 FROM zc302mt0006 INTO gs_bseg-txt50
                                          WHERE bukrs = '1000'
                                          AND ktopl = 'CAKR'.
  APPEND gs_bseg TO gt_bseg.

  " 차변 - 매출세액(반품)
  CLEAR : gs_bseg.
  gs_bseg-bukrs = '1000'.
  gs_bseg-belnr = gv_apbel.
  gs_bseg-gjahr = gs_body-dwdate+1(4).
  gs_bseg-buzei = '3'.
  gs_bseg-koart = 'D'. " 고객
  gs_bseg-shkzg = 'S'. " 차변
  gs_bseg-hkont = 'ACC0003016'.     " 매출세엑(반품) 계정번호로 넣어줄 예정
  gs_bseg-price = gs_body-price - lv_price.
  gs_bseg-waers = gs_body-waers.
*  gs_bseg-bpcode =
  gs_bseg-erdat = sy-datum.
  gs_bseg-ernam = sy-uname.
  gs_bseg-erzet = sy-uzeit.
  SELECT SINGLE txt50 FROM zc302mt0006 INTO gs_bseg-txt50
                                        WHERE bukrs = '1000'
                                        AND ktopl = 'CAKR'.
  APPEND gs_bseg TO gt_bseg.



*  " 차/대 합계 확인
*  LOOP AT gt_bseg INTO gs_bseg.
*    CASE gs_bseg-shkzg.
*      WHEN 'S'.
*        lv_s_sum + lv_h_sum = gs_bseg-price.
*      WHEN 'H'.
*        lv_s_sum + lv_h_sum = gs_bseg-price.
*    ENDCASE.
*  ENDLOOP.
*
*  IF lv_h_sum NE lv_s_sum.
*    MESSAGE s001 WITH '차변과 대변의 합이 맞지 않습니다.' DISPLAY LIKE 'E'.
*    EXIT.
*
*  ELSEIF      "차변 금액이 맞을때 유효성 검사 - 권한 확인
*    gs_bkpf-emp_num NE 'KDT-C-12' AND
*    gs_bkpf-emp_num NE 'KDT-C-06'.
*    MESSAGE s000 WITH '권한을 확인하세요.' DISPLAY LIKE 'E'.
*    EXIT.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_right_fcat2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_right_fcat2  USING  pv_key pv_field pv_table pv_just pv_emph pv_pos.

  CLEAR : gs_rfcat2.
  gs_rfcat2-key = pv_key.
  gs_rfcat2-fieldname = pv_field.
  gs_rfcat2-coltext = pv_table.
  gs_rfcat2-just = pv_just.
  gs_rfcat2-emphasize = pv_emph.
  gs_rfcat2-col_pos = pv_pos.

  CASE pv_field.
    WHEN 'NETWR'.
      gs_rfcat2-cfieldname = 'WAERS'.
      gs_rfcat2-do_sum = abap_true.
    WHEN 'MENGE'.
      gs_rfcat2-qfieldname = 'MEINS'.
  ENDCASE.

  APPEND gs_rfcat2 TO gt_rfcat2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_double_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM handle_double_click  USING    pv_erow  pv_column.
  DATA : lv_tabix TYPE sy-tabix.

*-- 이벤트가 발생한 행의 데이터를 읽는다 .
  CLEAR gs_body.
  READ TABLE gt_body INTO gs_body INDEX pv_erow.  "이벤트는 위치정보밖에주지를목해서 readtable을 공식으로 사용


*-- 선택한 행의 상세 데이터를 조회한다.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_bseg
    FROM zc302fit0002
    WHERE belnr EQ gs_body-belnr.

*-- Get texttable - 계정과목명
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

  IF gs_body-belnr IS INITIAL.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'.
    EXIT.
  ELSE.
    CALL SCREEN 101 STARTING AT 06 05.

  ENDIF.


  CALL METHOD go_right_grid->refresh_table_display.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_popscreen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_popscreen .

  IF go_pop_cont IS NOT BOUND.

    " fieldcatalog
    CLEAR : gt_pfcat.
    PERFORM set_pop_fcat USING :  'X' 'BUKRS' '회사코드'      'C' 'X' '1',
                                  'X' 'GJAHR' '회계연도'      'C' ' ' '2',
                                  'X' 'BELNR' '전표번호'      'C' ' ' '3',
                                  'X' 'BUZEI' '개별 항목 번호' 'C' ' ' '4',
                                  ' ' 'KOART' '계정유형'      'C' ' ' '5',
                                  ' ' 'SHKZG' '차/대변'      'C' ' ' '6',
                                  ' ' 'PRICE' '금액'        ' ' ' ' '7',
                                  ' ' 'WAERS' '통화'        'C' ' ' '8',
                                  ' ' 'HKONT' '계정과목코드'   'C' ' ' '9',
                                  ' ' 'TXT50' '계정과목명'    'C' ' ' '10'.

    PERFORM set_playout.
    PERFORM pcreate_object.
*
*    gs_variant-report = sy-repid.
*    gs_variant-handle = 'ALV2'.

    CALL METHOD go_pop_grid->set_table_for_first_display
      EXPORTING
        is_variant           = gs_variant
        i_save               = 'A'
        i_default            = 'X'
        is_layout            = gs_playout
        it_toolbar_excluding = gt_ui_functions
      CHANGING
        it_outtab            = gt_bseg
        it_fieldcatalog      = gt_pfcat
        it_sort              = gt_sort.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_pop_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_pop_fcat  USING   pv_key pv_field pv_table pv_just pv_emph pv_pos.

  CLEAR : gs_pfcat.
  gs_pfcat-key = pv_key.
  gs_pfcat-fieldname = pv_field.
  gs_pfcat-coltext = pv_table.
  gs_pfcat-just = pv_just.
  gs_pfcat-emphasize = pv_emph.
  gs_pfcat-col_pos = pv_pos.

  " fieldcat 통화 & 합계액 설정
  CASE pv_field.
    WHEN 'PRICE'.
      gs_pfcat-cfieldname = 'WAERS'.
      gs_pfcat-do_sum = abap_true.
  ENDCASE.

  APPEND gs_pfcat TO gt_pfcat.

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
  gs_playout-no_totline = abap_true.
  gs_playout-no_toolbar = abap_true.

*-- Set sort & subtotal  : subtotal by carrid &connid
  CLEAR : gt_sort, gs_sort.
  gs_sort-spos  = 1.
  gs_sort-fieldname = 'SHKZG'.
  gs_sort-up = abap_true.       " ACSENDING
  gs_sort-subtot  = abap_true.  " Do subtotals
  APPEND gs_sort TO gt_sort.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form pcreate_object
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM pcreate_object .

*-- Main container
  CREATE OBJECT go_pop_cont
    EXPORTING
      container_name = 'POP_CONT'.

*-- ALV
  CREATE OBJECT go_pop_grid
    EXPORTING
      i_parent = go_pop_cont.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_search_help
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_search_help .

  CLEAR : gs_sfnum, gt_sfnum.
  SELECT sfnum
    INTO CORRESPONDING FIELDS OF TABLE gt_sfnum
    FROM zc302fit0006.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  GET_SFNUM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_sfnum INPUT.

  DATA : BEGIN OF ls_sfnum,
           sfnum TYPE zc302fit0006-sfnum,
         END OF ls_sfnum,
         lt_sfnum LIKE TABLE OF ls_sfnum.

  SELECT sfnum
    INTO CORRESPONDING FIELDS OF TABLE lt_sfnum
    FROM zc302fit0006
   ORDER BY sfnum.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'SFNUM'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GV_RFNUM'
      value_org       = 'S'
    TABLES
      value_tab       = lt_sfnum
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDMODULE.
