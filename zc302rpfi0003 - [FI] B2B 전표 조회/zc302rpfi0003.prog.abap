*&---------------------------------------------------------------------*
*& Report ZC302RPFI0003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc302rpfi0003top                        .  " Global Data
INCLUDE ZC302RPFI0003s01                        .  " Selection Screen
INCLUDE ZC302RPFI0003c01                        .  " Class
INCLUDE zc302rpfi0003o01                        .  " PBO-Modules
INCLUDE zc302rpfi0003i01                        .  " PAI-Modules
INCLUDE zc302rpfi0003f01                        .  " FORM-Routines

*--------------------------------------------------------------------*
* Start of Selection
*--------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM get_base_data.   " main data
  PERFORM set_text_field.  " subdata

  CALL SCREEN 100.
