*&---------------------------------------------------------------------*
*& Include          SAPMZC302MM0003I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  CALL METHOD : go_up_grid->free,
                go_down_grid->free,
                go_up_cont->free,
                go_down_cont->free,
                go_split_cont->free,
                go_container->free.

  FREE : go_up_grid, go_down_grid, go_up_cont,
         go_down_cont, go_split_cont, go_container.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  DATA : lv_answer.
  CASE gv_okcode.
*-- 조회버튼
    WHEN 'VIEW'.
      PERFORM view_screen.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_POP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_pop INPUT.

  CALL METHOD : go_pop_grid->free,
                go_pop_container->free.

  FREE : go_pop_grid, go_pop_container.


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
      IF gv_rtptqua IS NOT INITIAL.
       PERFORM expt_alv.
      ELSE.
        MESSAGE S001 WITH TEXT-S03 DISPLAY LIKE 'E'.
      ENDIF.
  ENDCASE.

ENDMODULE.
