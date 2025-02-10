*&---------------------------------------------------------------------*
*& Report ZC302RPFI0007
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc302rpfi0007top                        .    " Global Data

INCLUDE zc302rpfi0007c01                        .  " PBO-Modules
INCLUDE zc302rpfi0007o01                        .  " PBO-Modules
INCLUDE zc302rpfi0007i01                        .  " PAI-Modules
INCLUDE zc302rpfi0007f01                        .  " FORM-Routines

**********************************************************************
*START-OF-SELECTION
**********************************************************************
START-OF-SELECTION.
  PERFORM get_base_data.

  CALL SCREEN 100.
