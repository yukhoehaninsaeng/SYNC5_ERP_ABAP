*&---------------------------------------------------------------------*
*& Report      ZC302RPFI0006
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc302rpfi0006top                        .    " Global Data
INCLUDE zc302rpfi0006s01                        .    " Selection Screen
INCLUDE zc302rpfi0006c01                        .    " Class
INCLUDE zc302rpfi0006o01                        .    " PBO
INCLUDE ZC302rpfi0006i01                        .    " PAI
INCLUDE zc302rpfi0006f01                        .  " FORM-Routines


*--------------------------------------------------------------------*
* Start of Selection
* Selection Screen에서 실행 버튼 클릭 시, 데이터 조회 및 검색 결과에 대한 값 출력
*--------------------------------------------------------------------*
START-OF-SELECTION.
  IF sy-batch = abap_true.
    PERFORM compose_url.
    PERFORM create_http.
    PERFORM set_request_header.
    PERFORM http_send_receive.
    PERFORM get_response.
    PERFORM save_data.
  ELSE.
    PERFORM get_base_data.
    CALL SCREEN 100.
  ENDIF.
