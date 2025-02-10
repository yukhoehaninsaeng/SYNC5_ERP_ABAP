*&---------------------------------------------------------------------*
*& Include          ZC302RPMM0005I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE gv_okcode.
    WHEN 'EXCELU'.
      PERFORM f4_filename.
      PERFORM excel_upload.
      PERFORM get_excel_data.
    WHEN 'EXCELD'.
      PERFORM excel_download.
    WHEN 'SAVE'.
      IF gt_inventory IS INITIAL.
        MESSAGE S001 WITH '엑셀을 업로드해주세요.' DISPLAY LIKE 'E'.
      ELSE.
        PERFORM excel_save.
      ENDIF.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  CALL METHOD : go_alv_grid->free,
                go_container->free.

  FREE: go_alv_grid, go_container.

  LEAVE TO SCREEN 0.

ENDMODULE.
