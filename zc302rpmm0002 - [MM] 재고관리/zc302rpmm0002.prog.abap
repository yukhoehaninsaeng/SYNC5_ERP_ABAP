*&---------------------------------------------------------------------*
*& Report ZC302RPMM0002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc302rpmm0002top                        .  " Global Data
INCLUDE zc302rpmm0002c01                        .  " AVL Event
INCLUDE zc302rpmm0002s01                        .  " Selection screen
INCLUDE zc302rpmm0002o01                        .  " PBO-Modules
INCLUDE zc302rpmm0002i01                        .  " PAI-Modules
INCLUDE zc302rpmm0002f01                        .  " FORM-Routines

**********************************************************************
* SELECTION-SCREEN
**********************************************************************
INITIALIZATION.
  PERFORM init_value.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_mat-low.
  PERFORM f4_matnr.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_scode-low.
  PERFORM f4_scode.

**********************************************************************
* START-OF-SELECTION
**********************************************************************
START-OF-SELECTION.
  PERFORM get_base_data.
  PERFORM make_display_body.

  CALL SCREEN 100.
