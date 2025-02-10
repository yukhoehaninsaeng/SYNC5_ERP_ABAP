*&---------------------------------------------------------------------*
*& Report ZC302RPFI0005
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE ZC302RPFI0005TOP                        .    " Global Data

 INCLUDE ZC302RPFI0005S01                        .  " Selection screen
 INCLUDE ZC302RPFI0005O01                        .  " PBO-Modules
 INCLUDE ZC302RPFI0005I01                        .  " PAI-Modules
 INCLUDE ZC302RPFI0005F01                        .  " FORM-Routines

**********************************************************************
* INITIALIZATION
**********************************************************************
INITIALIZATION.
  PERFORM set_init_value.

**********************************************************************
*AT SELECTION-SCREEN OUTPUT
**********************************************************************
AT SELECTION-SCREEN OUTPUT.
  PERFORM set_selection_screen.

**********************************************************************
*START-OF-SELECTION
**********************************************************************
START-OF-SELECTION.
  PERFORM get_base_data.

  CALL SCREEN 100.

** ALV TREE 재정비
** PDF 추가
