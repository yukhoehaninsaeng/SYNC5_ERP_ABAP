*&---------------------------------------------------------------------*
*& Include          SAPMZC302PP0001I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  CALL METHOD: go_down_grid->free,
               go_up_grid->free,
               go_down_cont->free,
               go_up_cont->free,
               go_split_cont2->free,
               go_left_cont->free,
               go_right_grid->free,
               go_right_cont->free,
               go_split_cont1->free,
               go_container->free.

  FREE: go_down_grid, go_up_grid, go_down_cont, go_up_cont,
        go_split_cont2, go_left_cont, go_right_grid, go_right_cont,
        go_split_cont1, go_container.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_POP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_pop INPUT.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0101 INPUT.

  " gv_okcode가 존재할 때만 CASE 실행
  IF NOT gv_okcode IS INITIAL.

    CASE gv_okcode.
      WHEN 'CRT1'.
        PERFORM make_pdp_data.
      WHEN 'CAN1'.
        MESSAGE s001 WITH TEXT-e01 DISPLAY LIKE 'E'. " 생산 오더 생성 취소
        CLEAR gv_okcode.  " 취소 후 okcode 초기화
        LEAVE TO SCREEN 0.
    ENDCASE.

  ENDIF.

*   ename 설정
*  PERFORM set_ename.

  " gv_okcode 초기화 (취소나 다른 동작을 방지)
  CLEAR gv_okcode.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE gv_okcode.
    WHEN 'CHK1'.
      PERFORM check_select_data.
    WHEN 'INI1'.
      PERFORM reset_select_data.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_SPNUM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_spnum INPUT.

  PERFORM get_spnum_f4.

ENDMODULE.
