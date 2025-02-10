*&---------------------------------------------------------------------*
*& Report ZC302RPSD0003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE ZC302RPSD0003TOP.  " Global Data
INCLUDE ZC302RPSD0003S01.  " Selection Screen
INCLUDE ZC302RPSD0003C01.  " Class
INCLUDE ZC302RPSD0003O01.  " PBO-Modules
INCLUDE ZC302RPSD0003I01.  " PAI-Modules
INCLUDE ZC302RPSD0003F01.  " FORM-Routines

**********************************************************************
* INITIALIZATION
**********************************************************************
INITIALIZATION.
  PERFORM INIT_VALUE. " 데이터 기본 값 초기화

**********************************************************************
* AT SELECTION-SCREEN OUTPUT
**********************************************************************
AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_SCREEN. " 스크린 속성 세팅

**********************************************************************
* START-OF-SELECTION
**********************************************************************
START-OF-SELECTION.
  PERFORM GET_SALES_PLAN. " 판매 계획 데이터 가져오기

  CALL SCREEN 100.
