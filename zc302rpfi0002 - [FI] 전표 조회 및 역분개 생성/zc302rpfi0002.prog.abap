*&---------------------------------------------------------------------*
*& Report ZC302RPFI0002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc302rpfi0002top                        .  " Global Data
INCLUDE zc302rpfi0002s01                        .  " Selection screen
INCLUDE zc302rpfi0002c01                        .  " event
INCLUDE zc302rpfi0002o01                        .  " PBO-Modules
INCLUDE zc302rpfi0002i01                        .  " PAI-Modules
INCLUDE zc302rpfi0002f01                        .  " FORM-Routines

**********************************************************************
* INITIALIZATION
**********************************************************************
INITIALIZATION.
  PERFORM set_init_value.
  PERFORM get_f4_data.

**********************************************************************
*AT SELECTION-SCREEN
**********************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_bel-low. " low 값 F4달기
  PERFORM f4_belnr.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_bel-high. " high 값 F4달기
  PERFORM f4_belnr.

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
  PERFORM make_display_body.

  CALL SCREEN 100.
