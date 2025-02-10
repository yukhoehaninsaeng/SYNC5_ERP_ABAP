*&---------------------------------------------------------------------*
*& Report ZC302RPFI0001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc302rpfi0001top                        .  " Global Data
INCLUDE zc302rpfi0001S01                        .  " Selection Screen
INCLUDE zc302rpfi0001c01                        .  " Class
INCLUDE zc302rpfi0001o01                        .  " PBO-Modules
INCLUDE zc302rpfi0001i01                        .  " PAI-Modules
INCLUDE zc302rpfi0001f01                        .  " FORM-Routines

*--------------------------------------------------------------------*
* Selection Screen Output.
*--------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  " parameter 선택 값에 따라 gv_okcode에 다른 값 저장 -> 나중에 alv에 띄울 데이터가 다름
  PERFORM set_mode.

*--------------------------------------------------------------------*
* Start of Selection
*--------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM get_base_data.
  PERFORM set_sub_data.
  CALL SCREEN 100.
