*&---------------------------------------------------------------------*
*& Include          SAPMZC302PP0002I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  CALL METHOD: go_down_grid->free,
               go_up_grid->free,
               go_down_cont->free,
               go_up_cont->free,
               go_split_cont2->free,
               go_right_cont->free,
               go_left_grid->free,
               go_left_cont->free,
               go_split_cont1->free,
               go_container->free.

  FREE: go_down_grid, go_up_grid, go_down_cont, go_up_cont,
        go_split_cont2, go_right_cont, go_left_grid, go_left_cont,
        go_split_cont1, go_container.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE gv_okcode.
    WHEN 'CHK1'.
      PERFORM check_select_data. " 입력필드에 맞는 생산계획 데이터를 Setting
    WHEN 'INI1'.
      PERFORM reset_select_data. " 검색 조건 및 데이터 Setting 초기화
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_PDPCODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_pdpcode INPUT.

  PERFORM get_pdpcode_f4.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_PDPDAT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_pdpdat INPUT.

  PERFORM get_pdpdat_f4.

ENDMODULE.
