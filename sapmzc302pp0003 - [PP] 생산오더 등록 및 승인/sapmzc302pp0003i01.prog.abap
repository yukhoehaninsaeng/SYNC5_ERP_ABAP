*&---------------------------------------------------------------------*
*& Include          SAPMZC302PP0003I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  CALL METHOD: go_right_grid->free,
               go_down_grid->free,
               go_up_grid->free,
               go_down_cont->free,
               go_up_cont->free,
               go_split_cont2->free,
               go_left_cont->free,
               go_right_cont->free,
               go_split_cont1->free,
               go_container->free.

  FREE: go_right_grid, go_down_grid, go_up_grid, go_down_cont,
        go_up_cont, go_split_cont2, go_left_cont, go_right_cont,
        go_split_cont1, go_container.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_POP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_pop INPUT.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0101 INPUT.

  CASE gv_okcode.
    WHEN 'APPR'.
      PERFORM make_display_po_uc.
    WHEN 'CACL'.
      CLEAR: gv_emp_num.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_EMPLOYEE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_employee INPUT.

  PERFORM get_employee_f4.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE gv_okcode.
    WHEN 'CHK1'.
      PERFORM check_select_data.
    WHEN 'INI1'.
      PERFORM reset_select_data.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_PLORDCO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_plordco INPUT.

  PERFORM get_plordco_f4.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_MATERIAL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_material INPUT.

  PERFORM get_material_f4.

ENDMODULE.
