*&---------------------------------------------------------------------*
*& Report ZC302RPMM0004
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc302rpmm0004top                        .    " Global Data

INCLUDE zc302rpmm0004o01                        .  " PBO-Modules
INCLUDE zc302rpmm0004i01                        .  " PAI-Modules
INCLUDE zc302rpmm0004f01                        .  " FORM-Routines

START-OF-SELECTION.
*  PERFORM get_make_display.
  PERFORM get_qc.

  CALL SCREEN 100.
