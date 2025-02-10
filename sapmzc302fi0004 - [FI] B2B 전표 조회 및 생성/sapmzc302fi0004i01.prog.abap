*&---------------------------------------------------------------------*
*& Include          SAPMZC302FI0004I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  CALL METHOD : go_down_grid->free,
                go_up_grid->free,
                go_container_down->free,
                go_container_up->free,
                go_split_container->free,
                go_container->free.

  FREE: go_down_grid, go_up_grid, go_container_down, go_container_up,
        go_split_container, go_container.

  LEAVE TO SCREEN 0.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE gv_okcode.

  WHEN 'READ'.                         " 전표 조회
    CALL SCREEN 101 STARTING AT 05 03
                    ENDING AT 50 10.

  WHEN 'IROW'.                         " 전표 아이템 추가
    PERFORM insert_item.

  WHEN 'SAVE'.                         " 전표 생성
    PERFORM create_document.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  ON_BLART_F4  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE on_blart_f4 INPUT.

  PERFORM handle_f4_blart.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  ON_PERNR_F4  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE on_pernr_f4 INPUT.

  PERFORM handle_f4_pernr.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  ON_BPCODE_F4  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE on_bpcode_f4 INPUT.

  PERFORM handle_f4_bpcode.
*  PERFORM handle_f4_hkont.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  ON_HKONT_F4  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE on_hkont_f4 INPUT.

  PERFORM handle_f4_hkont.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  ON_WAERS_F4  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE on_waers_f4 INPUT.

  PERFORM handle_f4_waers.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_POPUP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_popup INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0101 INPUT.

  CASE gv_okcode.
    WHEN 'SRCH'.
      PERFORM set_popup_range.
      PERFORM submit_program.
      gv_okcode = 'EXIT'.
*  CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
*    EXPORTING
*      functioncode           = 'ENTE'
*    EXCEPTIONS
*      function_not_supported = 1
*      OTHERS                 = 2.

  CALL METHOD cl_gui_cfw=>set_new_ok_code
  EXPORTING
    new_code = 'ENTER'.
  ENDCASE.

ENDMODULE.
