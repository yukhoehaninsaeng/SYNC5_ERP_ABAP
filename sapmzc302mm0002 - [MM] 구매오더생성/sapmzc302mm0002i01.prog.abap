*&---------------------------------------------------------------------*
*& Include          SAPMZC302MM0002I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  CALL METHOD : go_alv_grid->free,
                go_cont->free.

  FREE : go_alv_grid, go_cont.

  LEAVE TO SCREEN 0.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  DATA : lv_chrow. " 행 선택

  CASE gv_okcode.
    WHEN 'SPR'.
      PERFORM search_data.

  ENDCASE.

  CALL METHOD go_alv_grid->refresh_table_display.
  CALL METHOD go_up_grid->refresh_table_display.
  CALL METHOD go_down_grid->refresh_table_display.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  POPUP_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE popup_exit INPUT.

  CALL METHOD : go_down_grid2->free,
                go_up_grid2->free,
                go_down_cont2->free,
                go_up_cont2->free,
                go_split_cont3->free,
                go_popup_cont->free.

  FREE : go_down_grid2, go_up_grid2, go_down_cont2, go_up_cont2
         , go_split_cont3, go_popup_cont.

  CLEAR: gt_pfcat1, gt_pfcat2. " 안 하면 field catalog 계속 쌓여서 필드가 계속 늘어남 !!!

  CLEAR: gt_popup_body.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0101 INPUT.

  CASE gv_okcode.
    WHEN 'POC'.
      PERFORM order_create.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_AUFNR_LOW  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_aufnr_low INPUT.

  PERFORM get_aufnr_low.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_AUFNR_HIGH  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_aufnr_high INPUT.

  PERFORM get_aufnr_high.

ENDMODULE.
