*&---------------------------------------------------------------------*
*& Report ZC302RPFI0008
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc302rpfi0008top                        .    " Global Data
INCLUDE zc302rpfi0008s01                        .    " Selection
INCLUDE zc302rpfi0008c01                        .    " Class
INCLUDE zc302rpfi0008o01                        .  " PBO-Modules
INCLUDE zc302rpfi0008i01                        .  " PAI-Modules
INCLUDE zc302rpfi0008f01                        .  " FORM-Routines

*--------------------------------------------------------------------*
* At Selection Screen
*--------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_bpcde-low.
  PERFORM on_f4_bpcode_low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_bpcde-high.
  PERFORM on_f4_bpcode_high.

*--------------------------------------------------------------------*
* Selection Screen
*--------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM get_base_data.
  PERFORM set_sub_data.

  CALL SCREEN 100.
