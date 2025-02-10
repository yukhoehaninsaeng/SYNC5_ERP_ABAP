*&---------------------------------------------------------------------*
*& Include          SAPMZC302SD0004I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  CALL METHOD : go_left_grid->free,
                go_right_grid->free,
                go_left_cont->free,
                go_right_cont->free,
                go_split_cont->free,
                go_container->free.

  FREE : go_left_grid, go_right_grid, go_left_cont, go_right_cont,
         go_split_cont, go_container.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE gv_okcode.
    WHEN 'SEAR'.   " 조회버튼
      PERFORM get_base_data.
      CALL METHOD go_left_grid->refresh_table_display.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_DLVNUM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_dlvnum INPUT.

  PERFORM get_dlvnum_f4.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_CHANNEL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_channel INPUT.

  PERFORM get_channel_f4.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_BPCODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_bpcode INPUT.

   PERFORM get_bpcode_f4.

ENDMODULE.
