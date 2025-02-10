*&---------------------------------------------------------------------*
*& Include          SAPMZC302MM0001I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  CALL METHOD: go_top_right_grid->free,
               go_top_left_grid->free,
               go_down_cont->free,
               go_up_cont->free,
               go_split_cont2->free,
               go_bottom_cont->free,
               go_bottom_grid->free,
               go_top_cont->free,
               go_split_cont1->free,
               go_container->free.

  FREE: go_top_right_grid, go_top_left_grid, go_down_cont, go_up_cont,
        go_split_cont2, go_bottom_cont, go_bottom_grid, go_top_cont,
        go_split_cont1, go_container.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

*-- 검색 조건
  PERFORM set_ranges.

  CASE gv_okcode.
    WHEN 'VIEW'.
      PERFORM get_gt_mpr_h.
      PERFORM refresh_table_tl.
      PERFORM refresh_table_tr.
      PERFORM refresh_table_bottom.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_POP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_pop INPUT.

   CALL METHOD : go_text_cont->free,
                go_text_edit->free.

  FREE : go_text_cont, go_text_edit.

  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0101 INPUT.

  CASE gv_okcode.
    WHEN 'OUT'.
      MESSAGE S001 WITH TEXT-E03 DISPLAY LIKE 'E'.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      MESSAGE S001 WITH TEXT-S01.
      PERFORM remark_save.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_POP_2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_pop_2 INPUT.
  CALL METHOD : go_text_cont2->free,
                go_text_edit2->free.

  FREE : go_text_cont2, go_text_edit2.

  LEAVE TO SCREEN 0.

ENDMODULE.
