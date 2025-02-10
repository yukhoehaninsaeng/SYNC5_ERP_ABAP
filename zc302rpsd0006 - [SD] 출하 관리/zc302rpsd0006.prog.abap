*&---------------------------------------------------------------------*
*& Report ZC302RPSD0006
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc302rpsd0006top                        .  " Global Data
INCLUDE zc302rpsd0006s01                        .  " Selection screen
INCLUDE zc302rpsd0006c01                        .  " ALV Event
INCLUDE zc302rpsd0006o01                        .  " PBO-Modules
INCLUDE zc302rpsd0006i01                        .  " PAI-Modules
INCLUDE zc302rpsd0006f01                        .  " FORM-Routines

**********************************************************************
* INITIALIZATION
**********************************************************************
INITIALIZATION.
  PERFORM init_value.

**********************************************************************
* AT SELECTION-SCREEN OUTPUT
**********************************************************************
AT SELECTION-SCREEN OUTPUT.
  PERFORM screen_output.

***********************************************************
* AT SELECTION-SCREEN
***********************************************************
*-- 출하번호 SEARCH HELP
AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_dlvn-low.
  PERFORM f4_dlvnum.


***********************************************************
* AT SELECTION-SCREEN
***********************************************************
*-- 판매주문번호 SEARCH HELP
AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_sonu-low.
  PERFORM f4_sonum.

**********************************************************************
* START-OF-SELECTION
**********************************************************************
START-OF-SELECTION.
  PERFORM get_base_data.

  CALL SCREEN 100.
