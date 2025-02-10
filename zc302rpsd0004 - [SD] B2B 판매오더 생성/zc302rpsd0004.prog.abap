*&---------------------------------------------------------------------*
*& Report ZC302RPSD0004
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE ZC302RPSD0004TOP.  " Global Data
INCLUDE ZC302RPSD0004S01.  " Selection Screen
INCLUDE ZC302RPSD0004C01.  " Local Class
INCLUDE ZC302RPSD0004O01.  " PBO-Modules
INCLUDE ZC302RPSD0004I01.  " PAI-Modules
INCLUDE ZC302RPSD0004F01.  " FORM-Routines

SELECTION-SCREEN FUNCTION KEY 1. " Selection Screen Button

**********************************************************************
* INITIALIZATION
**********************************************************************
INITIALIZATION.
  PERFORM INIT_VALUE.

**********************************************************************
* AT SELECTION-SCREEN
**********************************************************************
AT SELECTION-SCREEN.
  PERFORM BUTTON_CONTROL. " Excel 템플릿 다운로드

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_SCREEN.  " 라디오버튼 선택에 따른 Selection Screen 입력 필드 변경

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_CHNL.
  PERFORM F4_CHANNEL.     " 유통채널에 Search Help(F4) 설치

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_PATH.
  PERFORM GET_FILEPATH.   " 파일 경로 가져오기

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_BP.
  PERFORM F4_BPCODE.      " BP코드 필드에 Search Help(F4) 설치

**********************************************************************
* START-OF-SELECTION
**********************************************************************
START-OF-SELECTION.
  PERFORM CHECK_INPUT.    " Selection Screen Input Validation
  PERFORM CHECK_DUPLICATE.   " 중복 체크 로직

  PERFORM GET_MATERIAL_INFO. " 자재 정보 가져오기
  PERFORM GET_BP_NAME.       " 입력한 BP코드에 대한 BP명 읽어오기

  CASE 'X'.
    WHEN P_RB1. " 직접 입력
      PERFORM SET_HEADER.
      CALL SCREEN 100.
    WHEN P_RB2. " Excel 업로드
      PERFORM EXCEL_UPLOAD.
      PERFORM SET_HEADER. " 판매오더 헤더 데이터 생성
      CALL SCREEN 200.
  ENDCASE.
