*&---------------------------------------------------------------------*
*& Report ZC302RP0001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc302rpsd0001top.
INCLUDE zc302rpsd0001s01.
INCLUDE zc302rpsd0001c01.
INCLUDE zc302rpsd0001o01.
INCLUDE zc302rpsd0001i01.
INCLUDE zc302rpsd0001f01.

SELECTION-SCREEN FUNCTION KEY 1. " Selection Screen Button

**********************************************************************
* INITIALIZATION
**********************************************************************
INITIALIZATION.
  PERFORM init_value.

**********************************************************************
* AT SELECTION-SCREEN
**********************************************************************
AT SELECTION-SCREEN.
*-- 탬플릿 다운로드 기능
  PERFORM button_control.

AT SELECTION-SCREEN OUTPUT.
  PERFORM modify_screen.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path.
*-- 파일 경로 가져오기
  PERFORM get_filepath.

***********************************************************************
* START-OF-SELECTION
***********************************************************************
START-OF-SELECTION.

  PERFORM get_base_data.

  CASE 'X'.
    WHEN p_rb1.                       " 직접입력
      PERFORM make_display_body.
      CALL SCREEN 100.
    WHEN p_rb2.                       " 엑셀업로드
      PERFORM excel_upload.
      PERFORM make_body.
      CALL SCREEN 100.
    WHEN p_rb3.                       " 조회
      CALL SCREEN 100.
  ENDCASE.
