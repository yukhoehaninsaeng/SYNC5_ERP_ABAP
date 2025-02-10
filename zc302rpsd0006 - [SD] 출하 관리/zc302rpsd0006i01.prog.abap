*&---------------------------------------------------------------------*
*& Include          ZC302RPSD0006I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  CALL METHOD : go_alv_grid->free,
                go_alv_grid2->free,
                go_alv_grid3->free,
                go_container->free,
                go_container2->free,
                go_container3->free.

  FREE : go_alv_grid, go_alv_grid2, go_alv_grid3, go_container, go_container2, go_container3.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PROCESS_TAB  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE process_tab INPUT.

  IF gv_okcode(3) EQ 'TAB'.
    gv_tab = gv_okcode.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_POP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_pop INPUT.

  CALL METHOD : go_pop_grid->free,
                go_pop_cont->free.

  FREE : go_pop_grid, go_pop_cont.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0101 INPUT.

  CASE gv_okcode.
    WHEN 'SAVE'.
      PERFORM save_shipment_item.  " 출하 Item DB테이블에 피킹수량 반영하기
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_POP2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_pop2 INPUT.

  CALL METHOD : go_pop_grid2->free,
                go_pop_cont2->free.

  FREE : go_pop_grid2, go_pop_cont2.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_POP3  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_pop3 INPUT.

  CALL METHOD : go_pop_grid3->free,
              go_pop_cont3->free.

  FREE : go_pop_grid3, go_pop_cont3.

  LEAVE TO SCREEN 0.

ENDMODULE.
