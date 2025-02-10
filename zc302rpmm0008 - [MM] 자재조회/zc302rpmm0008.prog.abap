*&---------------------------------------------------------------------*
*& Report ZC302RPMM8
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc302rpmm8top                           .    " Global Data

INCLUDE zc302rpmm8c01                           .  " Class
INCLUDE zc302rpmm8s01                           .  " Selection Screen
INCLUDE zc302rpmm8o01                           .  " PBO-Modules
INCLUDE zc302rpmm8i01                           .  " PAI-Modules
INCLUDE zc302rpmm8f01                           .  " FORM-Routines

**********************************************************************
* INITIALIZATION.
**********************************************************************
INITIALIZATION.
  PERFORM get_make_f4.

**********************************************************************
* AT SELECTION-SCREEN.
**********************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_bpc-low.
  PERFORM get_f4_bpcode.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_bpc-high.
  PERFORM get_f4_bpcode.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_mat-low.
  PERFORM get_f4_matnr.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_mat-high.
  PERFORM get_f4_matnr.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_sco-low.
  PERFORM get_f4_scode.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_sco-high.
  PERFORM get_f4_scode.
**********************************************************************
*&& START-OF-SELECTION
**********************************************************************
START-OF-SELECTION.
  PERFORM get_base_data.
  PERFORM get_body_display.

  CALL SCREEN 100.
