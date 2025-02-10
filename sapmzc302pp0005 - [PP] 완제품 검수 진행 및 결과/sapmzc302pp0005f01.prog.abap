*&---------------------------------------------------------------------*
*& Include          SAPMZC302PP0005F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form display_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_screen .

*-- Set field catalog
  IF go_container IS NOT BOUND.

    CLEAR : gt_fcat, gs_fcat.
    PERFORM set_field_catalog USING : 'X' 'ICON'     ''             'C' ' ',
                                      'X' 'QINUM'    'ZC302PPT0011' ' ' ' ',
                                      'X' 'PONUM'    'ZC302PPT0011' ' ' ' ',
                                      'X' 'MATNR'    'ZC302PPT0011' ' ' ' ',
                                      ' ' 'MAKTX'    'ZC302PPT0011' ' ' 'X',
                                      ' ' 'PLANT'    'ZC302PPT0011' ' ' ' ',
                                      ' ' 'EMP_NUM'  'ZC302PPT0011' 'C' ' ',
                                      ' ' 'PPSTR'    'ZC302PPT0011' 'C' ' ',
                                      ' ' 'PPEND'    'ZC302PPT0011' 'C' ' ',
                                      ' ' 'RQAMT'    'ZC302PPT0011' ' ' ' ',
                                      ' ' 'DISMENGE' 'ZC302PPT0011' ' ' ' ',
                                      ' ' 'MENGE'    'ZC302PPT0011' ' ' 'X',
                                      ' ' 'UNIT'     'ZC302PPT0011' ' ' ' ',
                                      ' ' 'QIDAT'    'ZC302PPT0011' 'C' ' '.

    PERFORM set_layout.
    PERFORM create_object.

    SET HANDLER : lcl_event_handler=>toolbar      FOR go_alv_grid,
                  lcl_event_handler=>user_command FOR go_alv_grid.

    gs_variant-report = sy-repid.

    CALL METHOD go_alv_grid->set_table_for_first_display
      EXPORTING
        is_variant      = gs_variant
        i_save          = 'A'
        i_default       = 'X'
        is_layout       = gs_layout
      CHANGING
        it_outtab       = gt_check
        it_fieldcatalog = gt_fcat.
  ELSE.
    CALL METHOD go_alv_grid->refresh_table_display.
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
    WHEN 'ICON'.
      gs_fcat-coltext = '상태'.
    WHEN 'EMP_NUM'.
      gs_fcat-coltext = '검수담당자'.
    WHEN 'UNIT'.
      gs_fcat-coltext = '단위'.
    WHEN 'RQAMT' OR 'DISMENGE' OR 'MENGE'.
      gs_fcat-qfieldname = 'UNIT'.
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

  gs_layout-zebra      = abap_true.
  gs_layout-cwidth_opt = 'A'.
  gs_layout-sel_mode   = 'D'.
  gs_layout-grid_title = '검수정보'.    " 그리드 타이틀 주기
  gs_layout-smalltitle = abap_true.  " 타이틀 크기 줄이기

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

*-- Main Container
  CREATE OBJECT go_container
    EXPORTING
      container_name = 'MAIN_CONT'.

*-- ALV Grid
  CREATE OBJECT go_alv_grid
    EXPORTING
      i_parent = go_container.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  CASE 'X'.

    WHEN gv_rb1.         " 전체
      CLEAR gt_check.
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE gt_check
        FROM zc302ppt0011
       WHERE ponum IN gr_ponum
         AND matnr IN gr_matnr
         AND plant IN gr_plant
         AND ppend IN gr_ppend.

    WHEN gv_rb2.         " 검수 미완료
      CLEAR gt_check.
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE gt_check
        FROM zc302ppt0011
       WHERE ponum IN gr_ponum
         AND matnr IN gr_matnr
         AND plant IN gr_plant
         AND ppend IN gr_ppend
         AND slwon EQ ' '.   " IS INITIAL.

    WHEN gv_rb3.         " 검수 완료 및 입고 대기
      CLEAR gt_check.
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE gt_check
        FROM zc302ppt0011
       WHERE ponum IN gr_ponum
         AND matnr IN gr_matnr
         AND plant IN gr_plant
         AND ppend IN gr_ppend
         AND slwon EQ 'A'.

    WHEN gv_rb4.         " 입고 완료
      CLEAR gt_check.
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE gt_check
        FROM zc302ppt0011
       WHERE ponum IN gr_ponum
         AND matnr IN gr_matnr
         AND plant IN gr_plant
         AND ppend IN gr_ppend
         AND slwon EQ 'B'.
  ENDCASE.

  MODIFY SCREEN.

  IF gt_check IS INITIAL.
    MESSAGE s001 WITH TEXT-e14 DISPLAY LIKE 'E'.
  ENDIF.

*-- alv 화면을 새로고침해줘야한다. 이전에 이미 다른 화면을 띄워놨기 때문에 새로고침해줘야 뜬다.
*-- 이거 해주니 오류생김
*  PERFORM refresh_table.

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
  " 전체
*  PERFORM set_toolbar USING: '    ' ' '                   ' '  3  ' '      po_object,
*                             'FTAD' icon_check            ' ' ' ' TEXT-b01 po_object,
*                             'RQRG' icon_product_receipts ' ' ' ' TEXT-b02 po_object,
*                             'QCCK' icon_check            ' ' ' ' TEXT-b03 po_object.

  IF gv_okcode IS INITIAL.
    " 처음 들어갔을 때
    PERFORM set_toolbar USING: '    ' ' '                   ' '  3  ' '      po_object,
                           'FTAD' icon_check            ' ' ' ' TEXT-b01 po_object,
                           'RQRG' icon_product_receipts ' ' ' ' TEXT-b02 po_object,
                           'QCCK' icon_read_file            ' ' ' ' TEXT-b03 po_object.
  ELSE.
    CASE 'X'.
      WHEN gv_rb1.  " 전체
        PERFORM set_toolbar USING: '    ' ' '                   ' '  3  ' '      po_object,
                               'FTAD' icon_check            ' ' ' ' TEXT-b01 po_object,
                               'RQRG' icon_product_receipts ' ' ' ' TEXT-b02 po_object,
                               'QCCK' icon_read_file            ' ' ' ' TEXT-b03 po_object.
      WHEN gv_rb2.  " 검수 미완료
        PERFORM set_toolbar USING: '    ' ' '                   ' '  3  ' '      po_object,
                               'FTAD' icon_check            ' ' ' ' TEXT-b01 po_object.
      WHEN gv_rb3.  " 검수 완료 및 입고대기
        PERFORM set_toolbar USING: '    ' ' '                   ' '  3  ' '      po_object,
                               'RQRG' icon_product_receipts ' ' ' ' TEXT-b02 po_object,
                               'QCCK' icon_read_file            ' ' ' ' TEXT-b03 po_object.
      WHEN gv_rb4.  " 입고 완료
        PERFORM set_toolbar USING: '    ' ' '                   ' '  3  ' '      po_object,
                               'QCCK' icon_read_file            ' ' ' ' TEXT-b03 po_object.
    ENDCASE.

  ENDIF.



* CASE gs_check-slwon.
*  WHEN ' '.
*    PERFORM set_toolbar USING: '    ' ' '                   ' '  3  ' '      po_object,
*                             'FTAD' icon_check            ' ' ' ' TEXT-b01 po_object.
*  WHEN 'A'.
*    PERFORM set_toolbar USING: '    ' ' '                   ' '  3  ' '      po_object,
*                             'RQRG' icon_product_receipts ' ' ' ' TEXT-b02 po_object,
*                             'QCCK' icon_check            ' ' ' ' TEXT-b03 po_object.
*  WHEN 'B'.
*    PERFORM set_toolbar USING: '    ' ' '                   ' '  3  ' '      po_object,
*                             'QCCK' icon_check            ' ' ' ' TEXT-b03 po_object.
*ENDCASE.

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
    WHEN 'FTAD'.            " 검수진행
      PERFORM check_quality.
    WHEN 'RQRG'.
      PERFORM request_RG.    " 입고요청
    WHEN 'QCCK'.
      PERFORM check_quality_view. " 검수조회

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_quality
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_quality .

  DATA : lt_row    TYPE lvc_t_row,
         ls_row    TYPE lvc_s_row,
         lv_answer.

*-- 선택된 행 받기
  CALL METHOD go_alv_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_row.

  " 하나의 행만 선택
  IF lines( lt_row ) > 1.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  " READ TABLE lt_row INTO ls_row INDEX 1.
  ls_row = VALUE #( lt_row[ 1 ] OPTIONAL ).

  gv_tabix = ls_row-index.

  READ TABLE gt_check INTO gs_check INDEX gv_tabix.

  gv_ponum = gs_check-ponum.
  gv_matnr = gs_check-matnr.

  " 생산오더에서 계획수량(필요소요량)과 단위 가져오기
  gv_rqamt = gs_check-rqamt.
*  SELECT SINGLE rqamt
*    INTO gv_rqamt
*    FROM zc302ppt0007
*   WHERE ponum = gv_ponum.


  gv_unit = gs_check-unit.
*  SELECT SINGLE unit
*    INTO gv_unit
*    FROM zc302ppt0007
*   WHERE ponum = gv_ponum.


*-- 검수일 현재날짜로
  gv_qidat = gs_check-ppend + '03'.

*-- 검수자 로그인한 사람 - 본인으로
  gv_emp_num = sy-uname.

*-- 폐기량
  gv_dismenge = gs_check-dismenge.

*-- 최종생산량 나오게 하기.
  gv_menge = gs_check-menge.


  IF lt_row IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
    EXIT. " LEAVE TO SCREEN 0.
  ELSEIF gs_check-slwon NE space.
    MESSAGE s001 WITH TEXT-e13 DISPLAY LIKE 'E'.
    EXIT.
  ELSE.
    CALL SCREEN 101 STARTING AT 03 05.
    CLEAR gv_dismenge.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_screen2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_screen2 .

  IF go_pop_cont IS NOT BOUND. " 바인딩되지않았을 때 (객체 생성되지 않았을 때)

    PERFORM create_object2.
    PERFORM set_text.

  ENDIF.

  IF gv_rqamt = gv_menge.               " 폐기량 0이면 페기사유 적은거 삭제하고 read only로
    MESSAGE s001 WITH TEXT-e16 DISPLAY LIKE 'E'.
    CALL METHOD go_text_edit->delete_text. " 기존 작성된 내용 삭제

    CALL METHOD go_text_edit->set_readonly_mode
      EXPORTING
        readonly_mode = go_text_edit->true. " true로 하면 읽기전용
  ELSE.
    CALL METHOD go_text_edit->set_readonly_mode
      EXPORTING
        readonly_mode = go_text_edit->false.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_object2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_object2 .

*-- Container
  CREATE OBJECT go_pop_cont
    EXPORTING
      container_name = 'MAIN_CONT2'.

*-- Text editor
  CREATE OBJECT go_text_edit
    EXPORTING
      wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
      parent        = go_pop_cont.

*-- Edit toolbar
  CALL METHOD go_text_edit->set_toolbar_mode
    EXPORTING
      toolbar_mode = go_text_edit->false.


  "  -- Display <-> Change
*  IF gs_check-slwon IS INITIAL.
*    CALL METHOD go_text_edit->set_readonly_mode
*      EXPORTING
*        readonly_mode = go_text_edit->true. " true로 하면 읽기전용
*  ELSE. " salwon IS NOT INITIAL.
*    CALL METHOD go_text_edit->set_readonly_mode
*      EXPORTING
*       readonly_mode = go_text_edit->true. " true로 하면 읽기전용
*  ENDIF.



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

*-- DB로부터 내용을 받아왔다면 EDITOR에 Binding 한다.
*  CLEAR gs_check.
** READ TABLE gt_check_info INTO gs_check_info INDEX 1. " Original syntax
*    gs_check = VALUE #( gt_check[ 1 ] OPTIONAL ). " New syntax

**-- 줄바꿈 기호를 기준으로 단어를 분리
  SPLIT gs_check-direason AT cl_abap_char_utilities=>newline
                               INTO TABLE gt_content.

*-- 자동 들여쓰기
  CALL METHOD go_text_edit->set_autoindent_mode
    EXPORTING
      auto_indent            = 1
    EXCEPTIONS
      error_cntl_call_method = 1
      OTHERS                 = 2.

*-- 기존 작성된 내용 삭제
  CALL METHOD go_text_edit->delete_text.

*-- Set text to Editor
  CALL METHOD go_text_edit->set_selected_text_as_r3table
    EXPORTING
      table           = gt_content
*     enable_editing_protected_text = false
    EXCEPTIONS
      error_dp        = 1
      error_dp_create = 2
      OTHERS          = 3.

  "이거 어차피 안뜨게 해서 필요없다.
*  IF gs_check-slwon IS NOT INITIAL.        " 검수미완료 상태가 아니면 읽기전용이게
*    CALL METHOD go_text_edit->set_readonly_mode
*      EXPORTING
*        readonly_mode = go_text_edit->true. " true로 하면 읽기전용
*  ENDIF.

*  IF gs_check-rqamt EQ gs_check-menge.
*    CALL METHOD go_text_edit->set_readonly_mode
*      EXPORTING
*        readonly_mode = go_text_edit->true.
*  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_check_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_check_data .

  DATA : lt_row    TYPE lvc_t_row,
         ls_row    TYPE lvc_s_row,
         lv_answer.

  " ok_code 초기화 (엔터치기 위해서)
  CLEAR gv_okcode.

  " 폐기수량이 계획수량보다 많을 시 오류메시지
  IF gv_dismenge > gv_rqamt.
    MESSAGE s001 WITH TEXT-e06 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  " 최종생산량과 필요소요량 최신화
  gv_menge = gv_rqamt - gv_dismenge.




*-- 선택된 행 받기
  CALL METHOD go_alv_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_row.

  IF lt_row IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
    EXIT. " LEAVE TO SCREEN 0.
  ELSEIF gs_check-qinum IS NOT INITIAL.
    MESSAGE s001 WITH TEXT-e13 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 검수 완료할건지 팝업
  PERFORM confirm_for_check CHANGING lv_answer.

  " 확인이 아니면 메시지창 띄워주면서 나가게
  IF lv_answer NE '1'.
    MESSAGE s001 WITH TEXT-e02 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 폐기사유 저장
  PERFORM save_text.

  " 폐기수량이 있는데 폐기사유 없을 시 오류뜨면서 나가게
  IF gv_dismenge NE 0 AND gs_check-direason IS INITIAL.
    MESSAGE s001 WITH TEXT-e15 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.


  IF gv_rqamt = gv_menge AND gs_check-direason IS NOT INITIAL.   " 폐기량 0이면 페기사유 적은거 삭제하고 read only로
*    MESSAGE s001 WITH TEXT-e16 DISPLAY LIKE 'E'.
*    CALL METHOD go_text_edit->delete_text. " 기존 작성된 내용 삭제 - 어차피 밖에서 하니까
    CLEAR gs_check-direason.
    EXIT.
  ENDIF.

  CALL METHOD go_text_edit->delete_text. " text editor 클리어


*-- 검수번호 채번 및 데이터 업데이트
  PERFORM get_qcnum.



*-- 완제품 검수 상태 변경 및 저장
  PERFORM save_check_data.



*-- 다시 SELECT
*  CLEAR gt_check.
*  SELECT *
*    INTO CORRESPONDING FIELDS OF TABLE gt_check
*    FROM zc302ppt0011
*   WHERE ponum IN gr_ponum
*     AND matnr IN gr_matnr
*     AND plant IN gr_plant
*     AND ppend IN gr_ppend
*     AND slwon EQ ' '.   " IS INITIAL.

  PERFORM get_data. " 다시 SELECT
  PERFORM set_icon. " 아이콘 최신화

*-- 테이블 최신화?
  PERFORM refresh_table.


  LEAVE TO SCREEN 0.

**-- 다시 select 해서 검색화면 최신화 - 안된다
*  PERFORM get_data.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form confirm_for_check
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM confirm_for_check  CHANGING pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = '품질검수 확인'
      text_question         = '검수를 완료하시겠습니까?'
      text_button_1         = '네'(001)
      icon_button_1         = 'ICON_OKAY'
      text_button_2         = '아니요'(002)
      icon_button_2         = 'ICON_CANCEL'
      default_button        = '1'
      display_cancel_button = space
    IMPORTING
      answer                = pv_answer.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_qcnum
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_qcnum .

  DATA : lv_tabix     TYPE sy-tabix,
         lv_number(4).    " 채번 번호가 4자리


*    lv_datum = sy-datum+2.

  " 검수번호 채번
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZC302QCNO'
    IMPORTING
      number      = lv_number.

  " 현재 날짜의 3번째 자리부터 수를 가져와서 넣어준다. 6자리
  CONCATENATE 'QC' sy-datum(2) lv_number INTO DATA(lv_qcnum).

  " gs_check_info에 채번한 것 추가
  gs_check-qinum = lv_qcnum.

  " 최종생산량 계산
  IF gv_dismenge > gv_rqamt.
    MESSAGE s001 WITH TEXT-e06 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  gv_menge = gv_rqamt - gv_dismenge.

  " 들어있는 정보들 gs_check에 넣어주기 - 다음 코드에서 db에 업뎃해주기 위해서
  gs_check-emp_num  = gv_emp_num.
  gs_check-menge    = gv_menge.
  gs_check-dismenge = gv_dismenge.
  gs_check-qidat    = gv_qidat.

  " 입고여부에 입고대기 상태 부여
  gs_check-slwon = 'A'.

  " 테이블 바로 최신화되게 만들어주는
  MODIFY gt_check FROM gs_check INDEX gv_tabix
                                TRANSPORTING icon qinum menge dismenge qidat emp_num
                                             direason slwon.

*-- db에 업데이트
  UPDATE zc302ppt0011
     SET qinum     = gs_check-qinum       " 품질검수번호 업데이트
         menge     = gs_check-menge       " 최종생산량 업데이트
         dismenge  = gs_check-dismenge    " 폐기량 업데이트
         qidat     = gs_check-qidat       " 품질검수일자도 업데이트를 해줘야
         emp_num   = gs_check-emp_num     " 관리자도 넣어줘
         direason  = gs_check-direason    " 스크린 에디터 폐기사유 - set_text에서 저 장
         slwon     = gs_check-slwon       " 입고여부 넣어주기
   WHERE ponum     = gs_check-ponum
     AND matnr     = gs_check-matnr.      " pk인 matnr까지 줘보자

  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
    MESSAGE s001 WITH TEXT-e07.
  ELSE.
    MESSAGE s001 WITH TEXT-e08 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_check_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_check_data .

  DATA : ls_save TYPE zc302ppt0011.

  MOVE-CORRESPONDING gs_check TO ls_save.

  " Set Time Stamp (검수 정보)
  IF ls_save-erdat IS INITIAL.
    ls_save-erdat = sy-datum.
    ls_save-ernam = sy-uname.
    ls_save-erzet = sy-uzeit.
  ELSE.
    ls_save-aedat = sy-datum.
    ls_save-aenam = sy-uname.
    ls_save-aezet = sy-uzeit.
  ENDIF.

  " 검수 정보 DB에 저장
  MODIFY zc302ppt0011 FROM ls_save.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
    MESSAGE s001 WITH TEXT-e03.
  ELSE.
    MESSAGE s001 WITH TEXT-e08 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form calc_menge
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM calc_menge .

  IF gv_dismenge > gv_rqamt.
    MESSAGE s001 WITH TEXT-e06 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  gv_menge = gv_rqamt - gv_dismenge.  " 최종생산량 = 필요소요량 - 폐기량

*  IF gv_rqamt EQ gv_dismenge.
*    LOOP AT SCREEN.
*      IF screen-name = 'gv_direason'.
*        screen-input = 0. " 읽기 전용으로
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.

*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_icon
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_icon .

  DATA : lv_tabix TYPE sy-tabix.

  LOOP AT gt_check INTO gs_check.

    lv_tabix = sy-tabix.

**-- 품질검수번호의 존재유무에 따라서 상태를 변화시켜준다. 검수안했으면 품질검수번호 없기 때문
*    IF gs_check-qinum IS INITIAL.
*      gs_check-icon = icon_led_red.
*    ELSE.
*      gs_check-icon = icon_led_green.
*    ENDIF.

*-- 품질검수번호 없으면 상태를 01로 부여
    IF gs_check-qinum IS INITIAL.
      gs_check-qcgrs = '01'.
    ELSEIF gs_check-slwon EQ 'A'.   " 입고대기 일 때 노란불
      gs_check-qcgrs = '02'.
    ELSE.
      gs_check-qcgrs = '03'.
    ENDIF.

*-- 현재 상태에 따라 아이콘 변경
    CASE gs_check-qcgrs.
      WHEN '01'.
        gs_check-icon = icon_led_red.
      WHEN '02'.
        gs_check-icon = icon_led_yellow.
      WHEN '03'.
        gs_check-icon = icon_led_green.
    ENDCASE.


*-- modify 반드시 해줘야한다.
    MODIFY gt_check FROM gs_check INDEX lv_tabix
                                  TRANSPORTING icon.

  ENDLOOP.

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

  DATA : ls_stable TYPE lvc_s_stbl.

  ls_stable-row = abap_true.
  ls_stable-col = abap_true.

  CALL METHOD go_alv_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stable.

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

*-- Get text from Editor
  CALL METHOD go_text_edit->get_text_as_r3table
    IMPORTING
      table                  = gt_content
    EXCEPTIONS
      error_dp               = 1
      error_cntl_call_method = 2
      error_dp_create        = 3
      potential_data_loss    = 4
      OTHERS                 = 5.

  IF gt_content IS INITIAL.
    MESSAGE s001 WITH TEXT-e09 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.


*-- Append text
  CLEAR gs_check-direason.
  LOOP AT  gt_content INTO gs_content.

    CONCATENATE gs_check-direason gs_content-tdline
                cl_abap_char_utilities=>newline INTO gs_check-direason.

  ENDLOOP.

*-- gt에 넣고 gs는 초기화 - 다음에 다른정보 받으려고
*  APPEND gs_check TO gt_check.
*  CLEAR gs_check.

**-- db에 업데이트
*  MODIFY zc302ppt0011 FROM TABLE gt_text.
*  COMMIT WORK.
*
*  MESSAGE s102.






ENDFORM.
*&---------------------------------------------------------------------*
*& Form change_RG_status
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM request_RG .

  DATA : lt_row    TYPE lvc_t_row,
         ls_row    TYPE lvc_s_row,
         lv_answer.
*-- 선택된 행 받기
  CALL METHOD go_alv_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_row.

  " 하나의 행만 선택
  IF lines( lt_row ) > 1.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  " READ TABLE lt_row INTO ls_row INDEX 1.
  ls_row = VALUE #( lt_row[ 1 ] OPTIONAL ).

  gv_tabix = ls_row-index.

  READ TABLE gt_check INTO gs_check INDEX gv_tabix.

  IF lt_row IS INITIAL.
    MESSAGE s001 WITH TEXT-e10 DISPLAY LIKE 'E'.
    EXIT. " LEAVE TO SCREEN 0.
  ELSEIF gs_check-slwon NE 'A'.                   " 입고대기 상태가 아닐 경우
    MESSAGE s001 WITH TEXT-e12 DISPLAY LIKE 'E'.
    EXIT. " LEAVE TO SCREEN 0.
  ENDIF.

*-- 입고 요청할건지 팝업
  PERFORM confirm_for_RG CHANGING lv_answer.

  " 확인이 아니면 메시지창 띄워주면서 나가게
  IF lv_answer NE '1'.
    MESSAGE s001 WITH TEXT-e11 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

*-- 자재문서 업뎃, 생산실적처리, 입고상태 바꿔주고 + 폐기
  PERFORM process_progress.

**-- 검수 정보 상태 업데이트 ( ITAB )
*  gs_check-slwon = 'B'.
*  gs_check-icon  = icon_led_green.
*
*  MODIFY gt_check FROM gs_check INDEX gv_tabix
*                                TRANSPORTING slwon icon.
*
**-- DB에 입고 정보 업데이트
*  UPDATE zc302ppt0011
*     SET slwon     = gs_check-slwon       " 입고여부 넣어주기
*   WHERE ponum     = gs_check-ponum
*     AND matnr     = gs_check-matnr.
*
*  IF sy-subrc EQ 0.
*    COMMIT WORK AND WAIT.
*    MESSAGE s001 WITH TEXT-e07.
*  ELSE.
*    MESSAGE s001 WITH TEXT-e08 DISPLAY LIKE 'E'.
*    ROLLBACK WORK.
*  ENDIF.
*
**-- 완제품 검수 상태 변경 및 저장
*  PERFORM save_check_data.

*-- db에 여러 데이터 저장
  PERFORM save_db_data.

*-- 다시 SELECT
*  CLEAR gt_check.
*  SELECT *
*    INTO CORRESPONDING FIELDS OF TABLE gt_check
*    FROM zc302ppt0011
*   WHERE ponum IN gr_ponum
*     AND matnr IN gr_matnr
*     AND plant IN gr_plant
*     AND ppend IN gr_ppend
*     AND slwon EQ 'A'.

  PERFORM get_data. " 다시 SELECT
  PERFORM set_icon. " 아이콘 최신화

*-- 테이블 최신화?
  PERFORM refresh_table.

**-- 다시 select 해서 검색화면 최신화 - 안된다
*  PERFORM get_data.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form confirm_for_RG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ANSWER
*&---------------------------------------------------------------------*
FORM confirm_for_RG  CHANGING pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = '입고요청 확인'
      text_question         = '입고 요청하시겠습니까?'
      text_button_1         = '네'(001)
      icon_button_1         = 'ICON_OKAY'
      text_button_2         = '아니요'(002)
      icon_button_2         = 'ICON_CANCEL'
      default_button        = '1'
      display_cancel_button = space
    IMPORTING
      answer                = pv_answer.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_range_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_range_data .

*-- set_ranges
  REFRESH : gr_ponum, gr_ponum[],
            gr_matnr, gr_matnr[],
            gr_plant, gr_plant[],
            gr_ppend, gr_ppend[].


*-- 생산오더로 검색
  IF gv_ponum2 IS NOT INITIAL.
    gr_ponum-sign   = 'I'.
    gr_ponum-option = 'EQ'.
    gr_ponum-low    = gv_ponum2.
    APPEND gr_ponum.
  ENDIF.

*-- 자재코드로 검색
  IF gv_matnr2 IS NOT INITIAL.
    gr_matnr-sign   = 'I'.
    gr_matnr-option = 'EQ'.
    gr_matnr-low    = gv_matnr2.
    APPEND gr_matnr.
  ENDIF.

*-- 공장코드로 검색
  IF gv_plant IS NOT INITIAL.
    gr_plant-sign = 'I'.
    gr_plant-option = 'EQ'.
    gr_plant-low    = gv_plant.
    APPEND gr_plant.
  ENDIF.

*-- 공정종료일 범위값
  IF gv_PPEND_low IS NOT INITIAL.
    gr_ppend-sign     = 'I'.          " 포함
    gr_ppend-option   = 'EQ'.         " 범위 (Between)
    gr_ppend-low      = gv_PPEND_low.
    IF gv_PPEND_high IS NOT INITIAL.
      gr_ppend-option = 'BT'.
      gr_ppend-high   = gv_PPEND_high.
    ENDIF.
    APPEND gr_ppend.
  ENDIF.



  CASE 'X'.

    WHEN gv_rb1.         " 전체
      CLEAR gt_check.
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE gt_check
        FROM zc302ppt0011
       WHERE ponum IN gr_ponum
         AND matnr IN gr_matnr
         AND plant IN gr_plant
         AND ppend IN gr_ppend.

    WHEN gv_rb2.         " 검수 미완료
      CLEAR gt_check.
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE gt_check
        FROM zc302ppt0011
       WHERE ponum IN gr_ponum
         AND matnr IN gr_matnr
         AND plant IN gr_plant
         AND ppend IN gr_ppend
         AND slwon EQ ' '.   " IS INITIAL.

    WHEN gv_rb3.         " 검수 완료 및 입고 대기
      CLEAR gt_check.
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE gt_check
        FROM zc302ppt0011
       WHERE ponum IN gr_ponum
         AND matnr IN gr_matnr
         AND plant IN gr_plant
         AND ppend IN gr_ppend
         AND slwon EQ 'A'.

    WHEN gv_rb4.         " 입고 완료
      CLEAR gt_check.
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE gt_check
        FROM zc302ppt0011
       WHERE ponum IN gr_ponum
         AND matnr IN gr_matnr
         AND plant IN gr_plant
         AND ppend IN gr_ppend
         AND slwon EQ 'B'.
  ENDCASE.


*-- 검색 조건 없을 경우 데이터가 없습니다 메시지 출력
  IF gt_check IS INITIAL.
    MESSAGE s001 WITH TEXT-e14 DISPLAY LIKE 'E'.
  ENDIF.


*-- alv 화면을 새로고침해줘야한다. 이전에 이미 다른 화면을 띄워놨기 때문에 새로고침해줘야 뜬다.
  PERFORM refresh_table.


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

*-- 자재문서, 재고관리, 생산실적을 위해 데이터를 가져온다. + 폐기?
  PERFORM get_sub_data.

*-- 데이터 발생 (자재, 생산실적,...) + 폐기
  PERFORM make_display.

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
  CLEAR gt_inv_h.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_inv_h
    FROM zc302mmt0013
   WHERE scode EQ 'ST03'.


*-- 자재마스터 데이터 가져온다. ( 단가를 위해서 )
  CLEAR gt_mat.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_mat
    FROM zc302mt0007
   WHERE matnr LIKE 'CP%'.

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

**-- 폐기 가져온다. ( 폐기비용과 화폐키 위해?)
*  CLEAR gt_dis.
*  SELECT *
*    INTO CORRESPONDING FIELDS OF TABLE gt_dis
*    FROM zc302mmt0001.

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

  " 1. 자재문서를 발생시킨다. (자재문서 테이블에 데이터 추가)
  PERFORM mat_docu_generation.

  " 2. 재고관리에 수량을 채워준다. (Header & Item)
  PERFORM add_inv_managment.

  " 3. 생산실적 데이터를 생성한다.
  PERFORM production_perform.

  " 4. 검수정보 테이블의 상태를 'B'로 바꿔서 DB에 저장한다.
  PERFORM set_check_status.

  " 5. 폐기 있을 경우 폐기 보내준다.
  IF gs_check-dismenge > 0.
    PERFORM make_dis.
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
  gs_md_header-ponum    = gs_check-ponum. " 생산오더번호

  APPEND gs_md_header TO gt_md_header.

*-- 자재문서 Item에 추가
  CLEAR gs_md_item.

  gs_md_item-mblnr  = gv_mblnr.               " 자재문서번호
  gs_md_item-mjahr  = sy-datum(4).            " 자재문서연도
  gs_md_item-matnr  = gs_check-matnr.        " 자재코드
  gs_md_item-scode  = 'ST03'.                 " 창고코드
  gs_md_item-movetype = 'A'.                  " 자재이동유형
  gs_md_item-budat  = gs_check-ppend + '06'. " 입고날짜 = 공정 종료일 + 6일
  gs_md_item-menge  = gs_check-menge.        " 수량 = 최종생산량
  gs_md_item-meins  = gs_check-unit.         " 단위
  " 완제품 단가 및 통화키
  READ TABLE gt_mat INTO gs_mat WITH KEY matnr = gs_check-matnr.
  gs_md_item-netwr  = gs_mat-netwr.           " 완제품 단가
  gs_md_item-waers  = gs_mat-waers.           " 단가의 통화키

  gs_md_item-qinum  = gs_check-qinum.        " 품질검수번호
  gs_md_item-maktx  = gs_check-maktx.        " 자재명

  APPEND gs_md_item TO gt_md_item.

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
  READ TABLE gt_inv_h INTO gs_inv_h WITH KEY matnr = gs_check-matnr.
  IF sy-subrc EQ 0.
    gs_inv_h-h_rtptqua += gs_check-menge.
  ENDIF.

  MODIFY gt_inv_h FROM gs_inv_h TRANSPORTING h_rtptqua
                                       WHERE matnr = gs_check-matnr
                                         AND scode = 'ST03'.

*-- 재고관리 Item
  CLEAR gs_inv_i.
  gs_inv_i-matnr = gs_check-matnr.  " 자재코드
  gs_inv_i-scode = 'ST03'.           " 창고코드

  " 생성일(유통기한)
*  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
*    EXPORTING
*      date      = gs_check-ppend
*      days      = '0'
*      months    = '0'
*      signum    = '+'
*      years     = '3'
*    IMPORTING
*      calc_date = gs_inv_i-bdatu.

  gs_inv_i-bdatu     = gs_check-ppend.
  gs_inv_i-sname     = '03'.                " 창고명
  gs_inv_i-maktx     = gs_check-maktx.     " 자재명
  gs_inv_i-mblnr     = gv_mblnr.            " 자재문서번호
  gs_inv_i-mtart     = '03'.                " 자재유형
  gs_inv_i-i_rtptqua = gs_check-menge. " 현재재고 = 최종생산량
  gs_inv_i-meins     = gs_check-unit.  " 단위

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

  MOVE-CORRESPONDING gs_check TO gs_pro_per.

  " BOM_ID
  READ TABLE gt_bom INTO gs_bom WITH KEY matnr = gs_check-matnr.
  gs_pro_per-bomid = gs_bom-bomid.

  " 공정코드
  READ TABLE gt_pcode INTO gs_pcode WITH KEY matnr = gs_check-matnr.
  gs_pro_per-pcode = gs_pcode-pcode.

  gs_pro_per-pqua  = gs_check-rqamt. " 품질검수량 = 필요소요량
  gs_pro_per-mblnr = gv_mblnr.        " 자재문서번호
  gs_pro_per-mjahr = sy-datum(4).     " 자재문서연도

  APPEND gs_pro_per TO gt_pro_per.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_check_status
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_check_status .

*-- 검수 정보 상태 업데이트 ( ITAB )
  gs_check-slwon = 'B'.
  gs_check-icon  = icon_led_green.  " 이거 밖에서 select 하고 변화줘서 여기선 필요없?

  MODIFY gt_check FROM gs_check INDEX gv_tabix
                                TRANSPORTING slwon icon.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_db_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_db_data .

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
  " 검수정보 저장
  PERFORM save_qcinfo.

  " 폐기 있을 때 폐기 저장
  IF gs_check-dismenge > 0.
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
  " 반복문인게 여러 row여서?
  DATA : lt_save  TYPE TABLE OF zc302mmt0011,
         ls_save  TYPE zc302mmt0011,
         lv_tabix TYPE sy-tabix.

  MOVE-CORRESPONDING gt_md_header TO lt_save.

  IF lt_save IS INITIAL.
    MESSAGE s001 WITH TEXT-e14 DISPLAY LIKE 'E'.    " 데이터가 없습니다.
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
    MESSAGE s001 WITH TEXT-e08 DISPLAY LIKE 'E'.    " 저장에 실패하였습니다.
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
    MESSAGE s001 WITH TEXT-e14 DISPLAY LIKE 'E'.
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
    MESSAGE s001 WITH TEXT-e08 DISPLAY LIKE 'E'.
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
    MESSAGE s001 WITH TEXT-e14 DISPLAY LIKE 'E'.
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
    MESSAGE s001 WITH TEXT-e08 DISPLAY LIKE 'E'.
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
    MESSAGE s001 WITH TEXT-e14 DISPLAY LIKE 'E'.
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
    MESSAGE s001 WITH TEXT-e08 DISPLAY LIKE 'E'.
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
    MESSAGE s001 WITH TEXT-e14 DISPLAY LIKE 'E'.
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
    MESSAGE s001 WITH TEXT-e08 DISPLAY LIKE 'E'.
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

  MOVE-CORRESPONDING gt_check TO lt_save.

  IF lt_save IS INITIAL.
    MESSAGE s001 WITH TEXT-e14 DISPLAY LIKE 'E'.
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
    MESSAGE s001 WITH TEXT-e08 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
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

  CLEAR : gv_ponum2, gv_matnr2, gv_plant, gv_PPEND_low, gv_PPEND_high.

  PERFORM get_range_data.

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
  gs_dis-scode     = 'ST03'.                         " 창고코드
  gs_dis-matnr     = gs_check-matnr.                 " 자재코드
  gs_dis-qinum     = gs_check-qinum.                 " 품질검수번호
  gs_dis-maktx     = gs_check-maktx.                 " 자재명
  gs_dis-disreason = gs_check-direason.              " 폐기사유 - 변수명 다르니 조심
  gs_dis-dismenge  = gs_check-dismenge.              " 폐기량
  gs_dis-budat     = gs_check-ppend + '06'.          " 입고날짜 = 공정 종료일 + 6일
  gs_dis-meins     = gs_check-unit.                  " 단위
  gs_dis-emp_num   = gs_check-emp_num.               " 담당자
*  READ TABLE gt_dis INTO gs_dis WITH KEY matnr = gs_check-matnr.     " 이거 의미없는거 같은데
  gs_dis-discost   = gs_check-dismenge * 100.        " 폐기비용
  gs_dis-waers     = 'KRW'.                          " 비용의 통화키
  gs_dis-status    = 'B'.                            " 폐기상태 초기값 'B' - 대기

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
    MESSAGE s001 WITH TEXT-e14 DISPLAY LIKE 'E'.     " 데이터가 없습니다.
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
    MESSAGE s001 WITH TEXT-e08 DISPLAY LIKE 'E'.    " 저장에 실패하였습니다.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_quality_view
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_quality_view .

  DATA : lt_row    TYPE lvc_t_row,
         ls_row    TYPE lvc_s_row,
         lv_answer.
*-- 선택된 행 받기
  CALL METHOD go_alv_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_row.

  " 하나의 행만 선택
  IF lines( lt_row ) > 1.
    MESSAGE s001 WITH TEXT-e05 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  " READ TABLE lt_row INTO ls_row INDEX 1.
  ls_row = VALUE #( lt_row[ 1 ] OPTIONAL ).

  gv_tabix = ls_row-index.

  READ TABLE gt_check INTO gs_check INDEX gv_tabix.

  gv_ponum = gs_check-ponum.
  gv_matnr = gs_check-matnr.

  " 생산오더에서 계획수량(필요소요량)과 단위 가져오기
  gv_rqamt = gs_check-rqamt.

  " 단위
  gv_unit = gs_check-unit.

*-- 검수일
  gv_qidat = gs_check-qidat.

*-- 검수자
  gv_emp_num = gs_check-emp_num.

*-- 폐기량
  gv_dismenge = gs_check-dismenge.

*-- 최종생산량 나오게 하기.
  gv_menge = gs_check-menge.


  IF lt_row IS INITIAL.
    MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'.
    EXIT. " LEAVE TO SCREEN 0.
  ELSE.
    CALL SCREEN 102 STARTING AT 03 05.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_screen3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_screen3 .

  IF go_pop_cont2 IS NOT BOUND.

    PERFORM create_object3.
    PERFORM set_text2.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_object3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_object3 .

*-- Container
  CREATE OBJECT go_pop_cont2
    EXPORTING
      container_name = 'MAIN_CONT3'.

*-- Text editor
  CREATE OBJECT go_text_edit2
    EXPORTING
      wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
      parent        = go_pop_cont2.

*-- Edit toolbar
  CALL METHOD go_text_edit2->set_toolbar_mode
    EXPORTING
      toolbar_mode = go_text_edit2->false.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_text2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_text2 .

**-- 줄바꿈 기호를 기준으로 단어를 분리
  SPLIT gs_check-direason AT cl_abap_char_utilities=>newline
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
*     enable_editing_protected_text = false
    EXCEPTIONS
      error_dp        = 1
      error_dp_create = 2
      OTHERS          = 3.


  CALL METHOD go_text_edit2->set_readonly_mode
    EXPORTING
      readonly_mode = go_text_edit2->true. " true로 하면 읽기전용

ENDFORM.
