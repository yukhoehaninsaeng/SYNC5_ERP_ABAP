*&---------------------------------------------------------------------*
*& Include          SAPMZC302PP0002O01
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

  " ALV 생성 및 지정
  PERFORM display_screen.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module GET_DOCUMENT_DATA OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE get_document_data OUTPUT.

  IF go_container IS NOT BOUND.

    " 생산계획 및 계획오더 Header 데이터 Setting
    PERFORM get_base_data.

    " Search Help를 위한 생산계획 데이터 Setting
    PERFORM get_srchelp_data.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module MAKE_DISPLAY_BODY OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE make_display_body OUTPUT.

  IF go_container IS NOT BOUND.

    " 생산계획 아이콘 지정
    PERFORM make_display_left.

    " 계획오더 Header 아이콘 지정
    PERFORM make_display_up.

    " 계획오더 Item 현재재고 업데이트
    PERFORM update_down_data.

    " 부족수량이 없을 때 계획오더 Header 상태 변경 및 아이콘 지정
    PERFORM update_up_data.

  ENDIF.

ENDMODULE.
