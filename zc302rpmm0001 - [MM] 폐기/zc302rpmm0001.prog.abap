*&---------------------------------------------------------------------*
*& Report ZC302RPMM0001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc302rpmm0001top                        .  " Global Data
INCLUDE zc302rpmm0001s01                        .  " Selection screen
INCLUDE zc302rpmm0001c01                        .  " alv event
INCLUDE zc302rpmm0001o01                        .  " PBO-Modules
INCLUDE zc302rpmm0001i01                        .  " PAI-Modules
INCLUDE zc302rpmm0001f01                        .  " FORM-Routines


**********************************************************************
* AT SELECTION-SCREEN OUTPUT.
**********************************************************************
AT SELECTION-SCREEN OUTPUT.
  PERFORM modify_screen.

**********************************************************************
* START-OF-SELECTION
**********************************************************************
START-OF-SELECTION.
  PERFORM get_data_base.
  PERFORM make_display_body.

  CALL SCREEN 100.
