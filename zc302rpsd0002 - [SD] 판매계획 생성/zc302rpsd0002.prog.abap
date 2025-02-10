*&---------------------------------------------------------------------*
*& Report ZC302RPSD0002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE ZC302RPSD0002TOP.  " Global Data
INCLUDE ZC302RPSD0002S01.  " Selection Screen
INCLUDE ZC302RPSD0002C01.  " Class
INCLUDE ZC302RPSD0002O01.  " PBO-Modules
INCLUDE ZC302RPSD0002I01.  " PAI-Modules
INCLUDE ZC302RPSD0002F01.  " FORM-Routines

**********************************************************************
* INITIALIZATION
**********************************************************************
INITIALIZATION.
  PERFORM INIT_VALUE.

**********************************************************************
* SELECTION-SCREEN OUTPUT
**********************************************************************
AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_SCREEN.

**********************************************************************
* AT SELECTION-SCREEN
**********************************************************************
AT SELECTION-SCREEN.
  PERFORM CHECK_INPUT.

**********************************************************************
* START-OF-SELECTION
**********************************************************************
START-OF-SELECTION.
  PERFORM CHECK_DUPLICATION.
  PERFORM CREATE_PLAN.

  CALL SCREEN 100.
