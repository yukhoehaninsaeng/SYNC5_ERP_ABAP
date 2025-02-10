*&---------------------------------------------------------------------*
*& Report ZC302RPMM0009
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc302rpmm0009top                        .  " Global Data
INCLUDE zc302rpmm0009c01                        .  " Class
INCLUDE zc302rpmm0009s01                        .  " Selection Screen
INCLUDE zc302rpmm0009o01                        .  " PBO-Modules
INCLUDE zc302rpmm0009i01                        .  " PAI-Modules
INCLUDE zc302rpmm0009f01                        .  " FORM-Routines

**********************************************************************
* INITIALIZATION
**********************************************************************
INITIALIZATION.
  PERFORM init_value.

**********************************************************************
* AT SELECTION-SCREEN
**********************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_au-low.
  PERFORM f4_aufnr_low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_au-high.
  PERFORM f4_aufnr_high.
**********************************************************************
* START-OF-SELECTION
**********************************************************************
START-OF-SELECTION.
  PERFORM get_base_data.
  PERFORM get_make_display.


  CALL SCREEN 100.
