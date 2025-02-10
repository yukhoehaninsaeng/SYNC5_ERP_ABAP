*&---------------------------------------------------------------------*
*& Report ZC302RPSD0005
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc302rpsd0005top                        .  " Global Data
INCLUDE ZC302RPSD0005s01                        .  " Selection Screen
INCLUDE ZC302RPSD0005c01                        .  " ALV Event
INCLUDE zc302rpsd0005o01                        .  " PBO-Modules
INCLUDE zc302rpsd0005i01                        .  " PAI-Modules
INCLUDE zc302rpsd0005f01                        .  " FORM-Routines


**********************************************************************
* INITIALIZATION
**********************************************************************
INITIALIZATION.
*-- SEARCH HELP에 담길 반품번호 담기
  PERFORM init_value.

***********************************************************
* AT SELECTION-SCREEN
***********************************************************
*-- 반품번호 SEARCH HELP 세팅
AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_rfnum-low.
  PERFORM f4_rfnum.

*-- 판매주문번호 SEARCH HELP 세팅
AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_sonum-low.
  PERFORM f4_sonum.

**********************************************************************
* START-OF-SELECTION
**********************************************************************
START-OF-SELECTION.
*-- MAIN ALV에 띄울 ITAB 구성
  PERFORM get_base_data.
  PERFORM make_display_body.

  CALL SCREEN 100.
