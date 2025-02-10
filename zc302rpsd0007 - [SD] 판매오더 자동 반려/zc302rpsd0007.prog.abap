*&---------------------------------------------------------------------*
*& Report ZC302RPSD0007
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE ZC302RPSD0007TOP                        .    " Global Data
INCLUDE ZC302RPSD0007O01                        .  " PBO-Modules
INCLUDE ZC302RPSD0007I01                        .  " PAI-Modules
INCLUDE ZC302RPSD0007F01                        .  " FORM-Routines


**********************************************************************
* START-OF-SELECTION
**********************************************************************
START-OF-SELECTION.
  IF SY-BATCH = 'X'. " 배치잡으로 실행된 경우
    PERFORM SO_AUTO_REJECT.
  ELSE.
    PERFORM GET_LOG.
    CALL SCREEN 100.
  ENDIF.
