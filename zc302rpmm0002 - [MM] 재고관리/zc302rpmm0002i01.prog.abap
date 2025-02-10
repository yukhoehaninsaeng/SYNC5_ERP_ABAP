*&---------------------------------------------------------------------*
*& Include          ZC302RPMM0002I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  CALL METHOD : go_left_grid->free,
                go_right_grid->free,
                go_left_container->free,
                go_right_container->free,
                go_split_container->free,
                go_container->free.

  FREE : go_left_grid, go_right_grid, go_left_container, go_right_container,
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
    WHEN 'EXCELU'.
      MESSAGE S001 WITH '엑셀 업로그'.
    WHEN 'EXCELD'.
      MESSAGE S001 WITH '엑셀 ㄷㅏ운롣,'.
  ENDCASE.

ENDMODULE.
