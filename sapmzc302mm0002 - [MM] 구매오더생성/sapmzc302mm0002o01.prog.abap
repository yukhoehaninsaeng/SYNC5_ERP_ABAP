*&---------------------------------------------------------------------*
*& Include          SAPMZC302MM0002O01
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
*& Module GET_DATA OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE get_data OUTPUT.
  PERFORM search_data. " gt_body(header)  값 가져오는 구문
  PERFORM set_search_data.
  PERFORM sub_hdata.


ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_PROCESS_CONTROL OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_process_control OUTPUT.
  PERFORM display_screen.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0101 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0101 OUTPUT.
  SET PF-STATUS 'MENU101'.
  SET TITLEBAR 'TITLE101'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_POPUP_PROCESS_CONTROL OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_popup_process_control OUTPUT.
  PERFORM display_popup_screen.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module GET_POPUP_DATA OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE get_popup_data OUTPUT.
  PERFORM get_popup.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module GET_SO_ITEM OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE get_po_item OUTPUT.
  PERFORM get_po_item.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module MAKE_DISPLAY OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE make_display OUTPUT.
*-- 구매오더 아이템 리스트들이 전부 입고완료되면 구매오더 헤더의 상태를 변경해준다.
  PERFORM make_display_po.

*-- 구매요청번호 Search help
  PERFORM select_banfn.

ENDMODULE.
