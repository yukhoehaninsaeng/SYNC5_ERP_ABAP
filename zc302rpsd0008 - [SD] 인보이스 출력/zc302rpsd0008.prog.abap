*&---------------------------------------------------------------------*
*& Report ZC302RPSD0008
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE ZC302RPSD0008TOP.  " Global Data
INCLUDE ZC302RPSD0008C01.  " Local Class
INCLUDE ZC302RPSD0008S01.  " Selection Screen
INCLUDE ZC302RPSD0008O01.  " PBO-Modules
INCLUDE ZC302RPSD0008I01.  " PAI-Modules
INCLUDE ZC302RPSD0008F01.  " FORM-Routines

**********************************************************************
* INITIALIZATION
**********************************************************************
INITIALIZATION.
  PERFORM INIT_VALUE.

**********************************************************************
* AT SELECTION-SCREEN
**********************************************************************
AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_SCREEN.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_BPCODE.
  PERFORM BP_F4.

**********************************************************************
* START-OF-SELECTION
**********************************************************************
START-OF-SELECTION.
  PERFORM GET_SO_DATA.

  CALL SCREEN 100.
