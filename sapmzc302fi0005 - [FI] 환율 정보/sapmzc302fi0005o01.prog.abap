*&---------------------------------------------------------------------*
*& Include          SAPMZC302FI0005O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'MENU100'.
  SET TITLEBAR 'TITLE100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_PROCESS_CONTROL OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_process_control OUTPUT.

  " 첫 실행에서는 전체 데이터 조회, 이후에 조건 입력 후 다시 조회하는 경우에는 실행 x
  IF gt_body IS INITIAL OR
     gt_log IS INITIAL.
    PERFORM init_ranges.
    PERFORM get_base_data.
  ENDIF.

  PERFORM set_chart  TABLES  gt_value_usa gt_col_text_usa
                     USING '미국'.
  PERFORM set_chart  TABLES gt_value_chn gt_col_text_chn
                     USING  '중국'.
  PERFORM set_chart  TABLES gt_value_jpn gt_col_text_jpn
                     USING  '일본'.
  PERFORM set_chart  TABLES gt_value_eur gt_col_text_eur
                     USING  '유로'.

  PERFORM display_screen.

ENDMODULE.
**&---------------------------------------------------------------------*
**& Module SET_RANGES OUTPUT
**&---------------------------------------------------------------------*
**&
**&---------------------------------------------------------------------*
*MODULE set_ranges OUTPUT.
*  PERFORM init_ranges.
*  PERFORM get_base_data.
*ENDMODULE.
*&---------------------------------------------------------------------*
*& Module ACTIVE_TAB OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE active_tab OUTPUT.
  IF gv_tab IS INITIAL.
    go_tab-activetab = 'TAB1'.
  ELSE.
    go_tab-activetab = gv_tab.
  ENDIF.

  CASE gv_tab.
    WHEN 'TAB1'.
      gv_subscreen = '0110'.
    WHEN 'TAB2'.
      gv_subscreen = '0120'.
    WHEN 'TAB3'.
      gv_subscreen = '0130'.
    WHEN 'TAB4'.
      gv_subscreen = '0140'.
    WHEN 'TAB5'.
      gv_subscreen = '0150'.
    WHEN 'TAB6'.
      gv_subscreen = '0160'.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_DISPLAY OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_display OUTPUT.
  CASE gv_subscreen.
    WHEN '0130'.
      PERFORM init_display  TABLES gt_value_usa gt_col_text_usa
                            USING  go_cont_usa.
    WHEN '0140'.
      PERFORM init_display  TABLES gt_value_chn gt_col_text_chn
                            USING  go_cont_chn.
    WHEN '0150'.
      PERFORM init_display  TABLES gt_value_jpn gt_col_text_jpn
                            USING  go_cont_jpn.
    WHEN '0160'.
      PERFORM init_display  TABLES gt_value_eur gt_col_text_eur
                            USING  go_cont_eur.
  ENDCASE.
ENDMODULE.
