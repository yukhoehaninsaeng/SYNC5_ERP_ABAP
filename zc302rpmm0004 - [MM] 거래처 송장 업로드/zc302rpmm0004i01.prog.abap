*&---------------------------------------------------------------------*
*& Include          ZC302RPMM0004I01
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
  CASE gv_okcode.
    WHEN 'IU'.
      PERFORM f4_filename.
      PERFORM excel_upload.
      PERFORM get_excel_data.
    WHEN 'IF'.
      PERFORM excel_download.
    WHEN 'IS'.
*-- 거래처 송장
      IF gt_body IS INITIAL.
        MESSAGE s001 WITH  TEXT-e06 DISPLAY LIKE 'E'.
      ELSE.
        PERFORM excel_save.
      ENDIF.
    WHEN  'IVF'.
      CALL TRANSACTION 'ZC302RPMM0009'.
  ENDCASE.

ENDMODULE.
