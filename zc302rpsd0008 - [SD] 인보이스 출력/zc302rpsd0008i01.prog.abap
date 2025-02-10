*&---------------------------------------------------------------------*
*& Include          ZC302RPSD0008I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  CALL METHOD : GO_ALV->FREE, GO_CONT->FREE,
                GO_HTML_CNTRL->FREE, GO_TOP_CONTAINER->FREE.

  FREE : GO_ALV, GO_CONT, GO_HTML_CNTRL, GO_TOP_CONTAINER.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CASE GV_OKCODE.
    WHEN 'EXCL'. " Excel 파일 생성
      PERFORM PRINT_INVOICE.
    WHEN 'INVC'. " PDF 파일 생성
      GV_PDF = 'X'.
      PERFORM PRINT_INVOICE.
      CLEAR : GV_PDF.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_200 INPUT.

  CALL METHOD : GO_ALV_POP->FREE, GO_CONT_POP->FREE.

  FREE : GO_ALV_POP, GO_CONT_POP.

  LEAVE TO SCREEN 0.

ENDMODULE.
