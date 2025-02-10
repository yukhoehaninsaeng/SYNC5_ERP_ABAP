*&---------------------------------------------------------------------*
*& Include          ZC302RPMM8I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  CALL METHOD : go_html_cntrl->free,
                go_top_cont->free,
                go_alv_grid->free,
                go_dock_cont->free.

  FREE : go_html_cntrl, go_top_cont, go_alv_grid, go_dock_cont.
  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE gv_okcode.
    WHEN 'MCG'. " 자재 생성 프로그램으로 이동
      CALL TRANSACTION 'ZC302MM0006'.
    WHEN 'MIC'. " 입출고프로그램 이동
      CALL TRANSACTION 'ZC302MM0003'.
    WHEN 'MOC'. " 출하프로그램 이동
      CALL TRANSACTION 'ZC302RPSD0006'.
  ENDCASE.

ENDMODULE.
