*&---------------------------------------------------------------------*
*& Include          SAPMZC302MM0004O01
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
*& Module GET_QC_DATA OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE get_qc_data OUTPUT.
  PERFORM get_qc_main_data..
  PERFORM make_display_data.
  PERFORM get_inv_mange_data. " 재고관리 Header
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
  IF  gs_body2-qstat BETWEEN 'A' AND 'C'.
    SET PF-STATUS 'MENU101' EXCLUDING 'QCC'.
  ELSE.
    SET PF-STATUS 'MENU101'.
  ENDIF.

  SET TITLEBAR 'TITLE101'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module GET_POPUP_DATA OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE get_popup_data OUTPUT.

  PERFORM qc_data.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module HEYHEY OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE check_menge OUTPUT.

  IF gs_body2-qstat BETWEEN 'A' AND 'C' .
    LOOP AT SCREEN.
      CASE screen-name.
        WHEN 'GV_DISMENGE'.
          screen-input = 0.
        WHEN 'GV_QIMENGE'.
          screen-input = 0.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.





ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0102 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0102 OUTPUT.
  SET PF-STATUS 'MENU102'.
  SET TITLEBAR 'TITLE102'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_POP_TEXT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_pop_text OUTPUT.
  PERFORM set_pop_display.
  PERFORM set_text.

*  IF gs_body-disreason IS not INITIAL.
*    CALL METHOD go_text_edit->delete_text.
*  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0103 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0103 OUTPUT.
  SET PF-STATUS 'MENU103'.
  SET TITLEBAR 'TITLE103'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_POP_TEXT_READ OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_pop_text_read OUTPUT.
  PERFORM set_pop_display3.
  PERFORM set_text2.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module MODIFY_SCREEN OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE modify_screen OUTPUT.
*  LOOP AT SCREEN.
*
*    IF gs_body2-qstat BETWEEN 'A' AND 'C'.
*
*      IF screen-group1 EQ 'QCC'.
*        screen-active = 0.
*      ENDIF.
*
*    ENDIF.
*
*    MODIFY SCREEN.
*
*  ENDLOOP.


ENDMODULE.
*&---------------------------------------------------------------------*
*& Module DISREASON_INPUT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE disreason_input OUTPUT.
  PERFORM disreason_input.
ENDMODULE.
