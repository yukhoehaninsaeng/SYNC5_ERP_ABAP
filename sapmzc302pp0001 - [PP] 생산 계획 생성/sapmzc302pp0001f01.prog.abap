*&---------------------------------------------------------------------*
*& Include          SAPMZC302PP0001F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_base_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_base_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_pur_plan_h_data .

  CLEAR gt_spheader.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_spheader
    FROM zc302sdt0001
   ORDER BY pyear pmonth.

  IF gt_spheader IS INITIAL.
    MESSAGE s001 WITH TEXT-e06 DISPLAY LIKE 'E'.
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

    CLEAR gt_ufcat.
    PERFORM set_up_catalog USING : 'X' 'ICON'        ' '            'C' ' ',
                                   'X' 'SPNUM'       'ZC302SDT0001' ' ' ' ',
                                   ' ' 'SALE_ORG'    'ZC302SDT0001' ' ' ' ',
                                   ' ' 'CHANNEL'     'ZC302SDT0001' ' ' ' ',
                                   ' ' 'PYEAR'       'ZC302SDT0001' ' ' ' ',
                                   ' ' 'PMONTH'      'ZC302SDT0001' ' ' ' ',
                                   ' ' 'MENGE'       'ZC302SDT0001' ' ' ' ',
                                   ' ' 'MEINS'       'ZC302SDT0001' ' ' ' ',
                                   ' ' 'TOSAL'       'ZC302SDT0001' 'R' ' ',
                                   ' ' 'WAERS'       'ZC302SDT0001' ' ' ' ',
                                   ' ' 'DATUM'       'ZC302SDT0001' ' ' ' '.

    CLEAR : gt_dfcat, gs_dfcat.
    PERFORM set_down_catalog USING : 'X' 'SPNUM'   'ZC302SDT0002' ' ' ' ',
                                     ' ' 'POSNR'   'ZC302SDT0002' ' ' ' ',
                                     ' ' 'MATNR'   'ZC302SDT0002' ' ' ' ',
                                     ' ' 'MENGE'   'ZC302SDT0002' ' ' ' ',
                                     ' ' 'MEINS'   'ZC302SDT0002' ' ' ' ',
                                     ' ' 'NETWR'   'ZC302SDT0002' ' ' ' ',
                                     ' ' 'WAERS'   'ZC302SDT0002' ' ' ' '.

    CLEAR : gt_rfcat, gs_rfcat.
    PERFORM set_right_catalog USING : 'X' 'ICON'    ' '            'C' ' ',
                                      'X' 'SPNUM'   'ZC302PPT0001' ' ' ' ',
                                      'X' 'PDPCODE' 'ZC302PPT0001' ' ' ' ',
                                      'X' 'MATNR'   'ZC302PPT0001' ' ' ' ',
                                      ' ' 'MAKTX'   'ZC302PPT0001' ' ' ' ',
                                      ' ' 'PQUA'    'ZC302PPT0001' ' ' ' ',
                                      ' ' 'UNIT'    'ZC302PPT0001' ' ' ' ',
                                      ' ' 'EMP_NUM' 'ZC302PPT0001' ' ' ' ',
                                      ' ' 'PDPDAT'  'ZC302PPT0001' ' ' ' ',
                                      ' ' 'PDDLD'   'ZC302PPT0001' ' ' ' '.

    PERFORM set_layout.
    PERFORM create_object.

    SET HANDLER : lcl_event_handler=>hotspot_click FOR go_up_grid,
                  lcl_event_handler=>toolbar       FOR go_up_grid,
                  lcl_event_handler=>user_command  FOR go_up_grid.

    gs_variant-report = sy-repid.
    gs_variant-handle = 'ALV1'.

    CALL METHOD go_up_grid->set_table_for_first_display
      EXPORTING
        is_variant      = gs_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_ulayout
      CHANGING
        it_outtab       = gt_spheader
        it_fieldcatalog = gt_ufcat.


    gs_variant-handle = 'ALV2'.

    CALL METHOD go_down_grid->set_table_for_first_display
      EXPORTING
        is_variant      = gs_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_dlayout
      CHANGING
        it_outtab       = gt_spitem
        it_fieldcatalog = gt_dfcat.

    gs_variant-handle = 'ALV3'.

    CALL METHOD go_right_grid->set_table_for_first_display
      EXPORTING
        is_variant      = gs_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_rlayout
"       it_toolbar_excluding          = gt_ui_functions   추가안했음
      CHANGING
        it_outtab       = gt_pdplan
        it_fieldcatalog = gt_rfcat.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_up_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_up_catalog  USING pv_key pv_field pv_table pv_just pv_emph.

  gs_ufcat-key       = pv_key.
  gs_ufcat-fieldname = pv_field.
  gs_ufcat-ref_table = pv_table.
  gs_ufcat-just      = pv_just.
  gs_ufcat-emphasize = pv_emph.
*-- 판매계획번호에 hotspot event를 설치
  CASE pv_field.
    WHEN 'SPNUM'.
      gs_ufcat-hotspot = abap_true.
    WHEN 'PMONTH'.
      gs_ufcat-coltext = '월'.
    WHEN 'MENGE'.
      gs_ufcat-coltext = '판매계획수량'.
      gs_ufcat-qfieldname = 'MEINS'.
    WHEN 'MEINS'.
      gs_ufcat-coltext = '단위'.
    WHEN 'TOSAL'.
      gs_ufcat-cfieldname = 'WAERS'.
    WHEN 'WAERS'.
      gs_ufcat-coltext = '통화'.
    WHEN 'DATUM'.
      gs_ufcat-coltext = '판매계획생성일'.
    WHEN 'ICON'.
      gs_ufcat-coltext = '상태'.
  ENDCASE.

  APPEND gs_ufcat TO gt_ufcat.
  CLEAR gs_ufcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_down_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_down_catalog  USING pv_key pv_field pv_table pv_just pv_emph.

  gs_dfcat-key       = pv_key.
  gs_dfcat-fieldname = pv_field.
  gs_dfcat-ref_table = pv_table.
  gs_dfcat-just      = pv_just.
  gs_dfcat-emphasize = pv_emph.

  CASE pv_field.
    WHEN 'MENGE'.
      gs_dfcat-qfieldname = 'MEINS'.
      gs_dfcat-coltext    = '판매계획수량'.
    WHEN 'MEINS'.
      gs_dfcat-coltext    = '단위'.
    WHEN 'NETWR'.
      gs_dfcat-cfieldname = 'WAERS'.
      gs_dfcat-coltext    = '총 판매금액'.
    WHEN 'WAERS'.
      gs_dfcat-coltext    = '통화'.
  ENDCASE.

  APPEND gs_dfcat TO gt_dfcat.
  CLEAR gs_dfcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_right_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_right_catalog  USING pv_key pv_field pv_table pv_just pv_emph.

  gs_rfcat-key       = pv_key.
  gs_rfcat-fieldname = pv_field.
  gs_rfcat-ref_table = pv_table.
  gs_rfcat-just      = pv_just.
  gs_rfcat-emphasize = pv_emph.

  CASE pv_field.
    WHEN 'PQUA'.
      gs_rfcat-qfieldname = 'UNIT'.
    WHEN 'EMP_NUM'.
      gs_rfcat-coltext = '담당자'.
    WHEN 'ICON'.
      gs_rfcat-coltext = '상태'.
  ENDCASE.

  APPEND gs_rfcat TO gt_rfcat.
  CLEAR gs_rfcat.

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

  gs_ulayout-zebra      = abap_true.
  gs_ulayout-cwidth_opt = 'A'.
  gs_ulayout-sel_mode   = 'D'.
  gs_ulayout-grid_title = '판매계획 Header'.
  gs_ulayout-smalltitle = abap_true.

  gs_dlayout-zebra      = abap_true.
  gs_dlayout-cwidth_opt = 'A'.
  gs_dlayout-sel_mode   = 'D'.
  gs_dlayout-grid_title = '판매계획 Item'.
  gs_dlayout-smalltitle = abap_true.

  gs_rlayout-zebra      = abap_true.
  gs_rlayout-cwidth_opt = 'A'.
  gs_rlayout-sel_mode   = 'D'.
  gs_rlayout-grid_title = '생산계획'.
  gs_rlayout-smalltitle = abap_true.

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
  CREATE OBJECT go_split_cont1
    EXPORTING
      parent  = go_container
      rows    = 1  " 1행
      columns = 2. " 2열

*-- Assign container, ALV Grid
  CALL METHOD go_split_cont1->get_container
    EXPORTING
      row       = 1
      column    = 2
    RECEIVING
      container = go_right_cont.   " 할당받아서 옵젝 생성

  CREATE OBJECT go_right_grid
    EXPORTING
      i_parent = go_right_cont.    " 오른쪽은 하나만 띄우니까

  CALL METHOD go_split_cont1->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_left_cont.     " 왼쪽에 2개씩 띄울거니까

  CREATE OBJECT go_split_cont2
    EXPORTING
      parent  = go_left_cont
      rows    = 2
      columns = 1.

  CALL METHOD go_split_cont2->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_up_cont.

  CALL METHOD go_split_cont2->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_down_cont.

  CREATE OBJECT go_up_grid
    EXPORTING
      i_parent = go_up_cont.

  CREATE OBJECT go_down_grid
    EXPORTING
      i_parent = go_down_cont.

ENDFORM.
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

*-- 이벤트가 발생한 행의 데이터를 읽는다.
  CLEAR gs_spheader.
  READ TABLE gt_spheader INTO gs_spheader INDEX pv_row_id.

*-- 선택한 행의 상세 데이터를 조회
  CLEAR gt_spitem.
  SELECT spnum posnr matnr menge
         meins netwr waers
    INTO CORRESPONDING FIELDS OF TABLE gt_spitem
    FROM zc302sdt0002
    WHERE spnum = gs_spheader-spnum
      AND dflag NE 'X'.

*-- 자재명을 가지고 온다.


*-- Refresh down grid
  CALL METHOD go_down_grid->refresh_table_display.

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

*-- Set ALV Toolbar
  PERFORM set_toolbar USING : ' '    ' '              ' '  3  ' '       po_object,
                              'TOGL' icon_system_okay ' ' ' ' TEXT-b01  po_object.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_3
*&      --> P_
*&      --> PO_OBJECT
*&---------------------------------------------------------------------*
FORM set_toolbar  USING pv_func pv_icon pv_qinfo pv_type pv_text
                        po_object TYPE REF TO cl_alv_event_toolbar_set.

  CLEAR gs_button.
  gs_button-function  = pv_func.
  gs_button-icon      = pv_icon.
  gs_button-quickinfo = pv_qinfo.
  gs_button-butn_type = pv_type.
  gs_button-text      = pv_text.
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

  CASE pv_ucomm.
    WHEN 'TOGL'.
      PERFORM set_pdp_popup.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_pdp_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_pdp_data .

  DATA : lt_row       TYPE lvc_t_row,
         ls_row       TYPE lvc_s_row,
         lv_number(3),
         lv_maktx     TYPE zc302mt0007-maktx,
         lv_pqua(4)   TYPE n.

*-- 선택된 행 받기
  CALL METHOD go_up_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_row.

  IF lt_row IS INITIAL.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.
    EXIT. " LEAVE TO SCREEN 0.
  ENDIF.

*-- 생산계획번호 채번
  LOOP AT lt_row INTO ls_row.

    " 판매계획 Header를 하나씩 갖고 온다.
    CLEAR : gs_spheader, gs_pdplan. " 왼쪽거와 오른쪽거 모두 클리어
    READ TABLE gt_spheader INTO gs_spheader INDEX ls_row-index.

    " 판매계획의 상태가 생산계획 생성 후 라면 패스
    IF gs_spheader-status EQ 'X'.
      MESSAGE i001 WITH gs_spheader-spnum TEXT-e05 DISPLAY LIKE 'E'.
      CONTINUE.
    ENDIF.

    " 판매계획 Header의 판매계획번호에 따른 Item 데이터들을 끌고온다.
    CLEAR gt_spitem.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE gt_spitem
      FROM zc302sdt0002
     WHERE spnum EQ gs_spheader-spnum
       AND dflag NE 'X'.

    " 판매계획 Item을 통해서 생산계획을 생성한다.
    LOOP AT gt_spitem INTO gs_spitem.

      " corresponding 장점 : 있는 것들 값만 넣어줌. 인터널에서 alv. alv에서 인터널은 changing? - save 할 때
      MOVE-CORRESPONDING gs_spitem TO gs_pdplan.

      " ERDAT, ERNAM, EZET 초기화
      _init: gs_pdplan-erdat,
             gs_pdplan-erzet,
             gs_pdplan-ernam,
             gs_pdplan-aedat,
             gs_pdplan-aezet,
             gs_pdplan-aenam.

      " 생산계획번호 채번
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr = '01'  " 번호 범위 번호
          object      = 'ZC302PDPL' " 오브젝트 이름
        IMPORTING
          number      = lv_number.

      " ppn 앞에 붙이고 판매계획에서 년도 3번째거에서 2개, 판매계획에서 월, 채번한 번호까지 다 합쳐서 번호를 만들고 이걸 임시변수 lv_ppnum 추가. - gs_pdplan-pdpcode에 괄호치면 달라질 수 있?
      CONCATENATE 'PPN' gs_spheader-pyear+2(2) gs_spheader-pmonth lv_number INTO gs_pdplan-pdpcode.

      " 자재명 가져오기
      SELECT SINGLE maktx
        INTO lv_maktx
        FROM zc302mt0007
        WHERE matnr = gs_pdplan-matnr.

      gs_pdplan-maktx = lv_maktx.


      " 계획수량 계산
      lv_pqua = gs_spitem-menge * ( gv_pldq / 100 ).
      gs_pdplan-pqua = lv_pqua.     " 뉴메릭인 값에 넣었다가 넣어서 소숫점 없앤다.

      " UNIT과 MEINS 맞춰주기
      gs_pdplan-unit = gs_spitem-meins.

      " 사원번호 및 사원명 추가
      gs_pdplan-emp_num = gv_emp_num.

      " 생성계획일자 생성 (현재 날짜로)
      gs_pdplan-pdpdat = sy-datum.

      " 제품납기일 생성
      gs_pdplan-pddld = gs_pdplan-pdpdat + '35'.

      " 아이콘 추가
      gs_pdplan-icon  = icon_closed_folder_orphaned.

      APPEND gs_pdplan TO gt_pdplan.

    ENDLOOP.

    " 판매계획의 상태를 'X'로 바꾼다.(생산계획 생성 완료 상태로 변경)
    gs_spheader-status = 'X'.
    gs_spheader-icon   = icon_led_green.

    MODIFY gt_spheader FROM gs_spheader INDEX ls_row-index
                                        TRANSPORTING status icon.

  ENDLOOP.

  " 판매계획 상태 DB에 저장
  PERFORM save_purplan_h_data.

  " DB에 저장
  PERFORM save_pdplan_data. " 밖으로 꺼내줘야한다. 안그러면 축적되면서 지난 것까지 같이 저장을. 클리어 계속 해줘도 되지만 이게 깔끔?

* 리프레쉬도 해줘야한다.
  PERFORM refresh_up_table.
  PERFORM refresh_right_table.

  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_ename
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_ename .

*  SELECT SINGLE ename
*    INTO gv_ename
*    FROM zc302mt0003
*   WHERE emp_num EQ gv_emp_num.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_pdplan_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_pdplan_data .

  DATA : lt_save_plan TYPE TABLE OF zc302ppt0001,
         ls_save_plan TYPE zc302ppt0001,
         lv_tabix     TYPE sy-tabix.

  MOVE-CORRESPONDING gt_pdplan TO lt_save_plan.

*-- Set Time Stamp
  LOOP AT lt_save_plan INTO ls_save_plan.

    lv_tabix = sy-tabix.

    IF ls_save_plan-erdat IS INITIAL.
      ls_save_plan-erdat = sy-datum.
      ls_save_plan-ernam = sy-uname.
      ls_save_plan-erzet = sy-uzeit.
    ELSE.
      ls_save_plan-aedat = sy-datum.
      ls_save_plan-aenam = sy-uname.
      ls_save_plan-aezet = sy-uzeit.
    ENDIF.

    MODIFY lt_save_plan FROM ls_save_plan INDEX lv_tabix
                                          TRANSPORTING erdat ernam erzet
                                                       aedat aenam aezet.

  ENDLOOP.



*-- 생산오더 DB에 저장
  MODIFY zc302ppt0001 FROM TABLE lt_save_plan.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
    MESSAGE s001 WITH TEXT-e03.
  ELSE.
    MESSAGE s001 WITH TEXT-e04 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_up_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_right_table .

  DATA : ls_stable TYPE lvc_s_stbl.

  ls_stable-row = abap_true.
  ls_stable-col = abap_true.

  CALL METHOD go_right_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stable.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_pdp_popup
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_pdp_popup .

  DATA: lt_row TYPE lvc_t_row,
        ls_row TYPE lvc_s_row.

*-- 선택된 행 받기
  CALL METHOD go_up_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_row.

  " READ TABLE lt_row INTO ls_row INDEX 1.
  ls_row = VALUE #( lt_row[ 1 ] OPTIONAL ).

  READ TABLE gt_spheader INTO gs_spheader INDEX ls_row-index.

  gv_spnum = gs_spheader-spnum.

  CLEAR : gv_pldq, gv_emp_num.

  gv_emp_num = sy-uname.

  IF lt_row IS INITIAL.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.
*    EXIT. " LEAVE TO SCREEN 0.
  ELSEIF gs_spheader-status EQ 'X'.
    MESSAGE s001 WITH gs_spheader-spnum TEXT-e05 DISPLAY LIKE 'E'.
  ELSE.
    CALL SCREEN 101 STARTING AT 03 05.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_display_pur_plan
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_pur_plan_h .

  DATA: lv_tabix TYPE sy-tabix.

  LOOP AT gt_spheader INTO gs_spheader.

    lv_tabix = sy-tabix.

    CASE gs_spheader-status.
      WHEN space.
        gs_spheader-icon = icon_led_red.
      WHEN 'X'.
        gs_spheader-icon = icon_led_green.
    ENDCASE.

    MODIFY gt_spheader FROM gs_spheader INDEX lv_tabix
                                        TRANSPORTING icon.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_purplan_h_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_purplan_h_data .

  DATA : lt_save  TYPE TABLE OF zc302sdt0001,
         ls_save  TYPE zc302sdt0001,
         lv_tabix TYPE sy-tabix.

  MOVE-CORRESPONDING gt_spheader TO lt_save.

*-- Set Time Stamp
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

*-- 판매계획 DB에 저장
  MODIFY zc302sdt0001 FROM TABLE lt_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
*    MESSAGE s001 WITH TEXT-e03.
  ELSE.
    MESSAGE s001 WITH TEXT-e04 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_pro_plan_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_pro_plan_data .

  CLEAR gt_pdplan.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_pdplan
    FROM zc302ppt0001
   ORDER BY pdpcode.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_display_pro_plan
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_display_pro_plan .

  DATA: lv_tabix TYPE sy-tabix.

  LOOP AT gt_pdplan INTO gs_pdplan.

    lv_tabix = sy-tabix.

    CASE gs_pdplan-status.
      WHEN space.
        gs_pdplan-icon = icon_closed_folder_orphaned.
      WHEN 'X' OR 'M'.
        gs_pdplan-icon = icon_closed_folder_uptodate.
    ENDCASE.

    MODIFY gt_pdplan FROM gs_pdplan INDEX lv_tabix
                                    TRANSPORTING icon.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_left_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_up_table .

  DATA : ls_stable TYPE lvc_s_stbl.

  ls_stable-row = abap_true.
  ls_stable-col = abap_true.

  CALL METHOD go_up_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stable.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_select_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_select_data .

*-- 판매계획 Header 가져오기
  PERFORM get_sp_header.
  PERFORM make_display_pur_plan_h.
  PERFORM refresh_up_table.

*-- 밑의 판매계획 ITEM도 초기화
  CLEAR gt_spitem.
  PERFORM refresh_down_table.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_sp_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_sp_header .

*-- set_ranges
  REFRESH : gr_spnum, gr_pyear.

  IF gv_spnum IS NOT INITIAL.
    gr_spnum-sign   = 'I'.
    gr_spnum-option = 'EQ'.
    gr_spnum-low   = gv_spnum.
    APPEND gr_spnum.
  ENDIF.

  IF gv_pyear IS NOT INITIAL.
    gr_pyear-sign   = 'I'.
    gr_pyear-option = 'EQ'.
    gr_pyear-low   = gv_pyear.
    APPEND gr_pyear.
  ENDIF.

*-- select
  CLEAR gt_spheader.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_spheader
    FROM zc302sdt0001
   WHERE spnum IN gr_spnum
     AND pyear IN gr_pyear
   ORDER BY pyear pmonth.

  IF gt_spheader IS INITIAL.
    MESSAGE s001 WITH TEXT-e06 DISPLAY LIKE 'E'.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form reset_select_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM reset_select_data .

*-- 조회조건 초기화해주고 다시 검색
  CLEAR : gv_spnum, gv_pyear.

  PERFORM check_select_data.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_down_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_down_table .

  DATA: ls_stable TYPE lvc_s_stbl.

  ls_stable-row = abap_true.
  ls_stable-col = abap_true.

  CALL METHOD go_down_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stable.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_searchhelp
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_searchhelp .

  CLEAR gt_spn.
  SELECT spnum a~matnr maktx
    INTO CORRESPONDING FIELDS OF TABLE gt_spn
    FROM zc302sdt0002 AS a INNER JOIN zc302mt0007 AS b
      ON a~matnr = b~matnr.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_spnum_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_spnum_f4 .

  DATA : lt_return TYPE TABLE OF ddshretval WITH HEADER LINE,
         lt_read   TYPE TABLE OF dynpread WITH HEADER LINE. " (선택)

  IF lines( gt_spn ) EQ 0.                          " 판매계획이 없을 경우 f4도
    MESSAGE s001 WITH TEXT-e07 DISPLAY LIKE 'E'.    " 판매계획 데이터가 없습니다
    EXIT.
  ENDIF.

*-- Execute Search Help(F4)
  REFRESH lt_return.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'SPNUM'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'GV_SPNUM'
      window_title    = '판매계획 번호'
      value_org       = 'S'
    TABLES
      value_tab       = gt_spn
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.
