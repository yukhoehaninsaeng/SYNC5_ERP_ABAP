*&---------------------------------------------------------------------*
*& Report ZC302RPMM0007
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc302rpmm0007top                        .  " Global Data
INCLUDE zc302rpmm0007c01                        .  " alv event
INCLUDE zc302rpmm0007s01                        .  " Selection screen
INCLUDE zc302rpmm0007o01                        .  " PBO-Modules
INCLUDE zc302rpmm0007i01                        .  " PAI-Modules
INCLUDE zc302rpmm0007f01                        .  " FORM-Routines

**********************************************************************
* INITIALIZATION
**********************************************************************
INITIALIZATION.
  PERFORM init_value.

**********************************************************************
* AT SELECTION-SCREEN
**********************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_mbl-low.
  PERFORM f4_mbl.

**********************************************************************
* START-OF-SELECTION
**********************************************************************
START-OF-SELECTION.
  PERFORM get_base_data.

  CALL SCREEN 100.
