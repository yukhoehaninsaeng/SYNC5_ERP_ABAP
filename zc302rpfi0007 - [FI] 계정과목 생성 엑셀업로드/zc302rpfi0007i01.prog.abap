*&---------------------------------------------------------------------*
*& Include          ZC302RPFI0007I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  CALL METHOD : go_alv_grid2->free,
                go_container2->free.

  FREE : go_alv_grid2, go_container2.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE gv_okcode.
    WHEN 'REFRESH' .
      PERFORM refresh_alv.

    WHEN 'FORM'.
      PERFORM download_excel.
    WHEN 'EXCELUP'.
      PERFORM excel_upload.


  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  POP_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pop_exit INPUT.

  CALL METHOD : go_pop_grid->free,
                go_popcont->free.

  FREE : go_pop_grid, go_popcont.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0101 INPUT.

  CASE gv_okpop.
    WHEN 'SAVE'.
      PERFORM save_excelpop.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_BPCODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*MODULE get_bpcode INPUT.
*
*  PERFORM get_bpcode_f4.
*
*ENDMODULE.
