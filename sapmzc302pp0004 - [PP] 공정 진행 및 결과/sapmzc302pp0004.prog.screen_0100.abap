PROCESS BEFORE OUTPUT.
  MODULE status_0100.
  MODULE get_document_data.           " 데이터 조회
  MODULE make_display.                " 데이터의 Style 설정
  MODULE init_process_control.        " Container 및 ALV 설정

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.        " Exit 설정
  MODULE user_command_0100.           " 버튼 기능 설정

PROCESS ON VALUE-REQUEST.
  FIELD gv_ponum MODULE get_ponum.    " 생산오더번호 서치헬프 설정
  FIELD gv_matnr MODULE get_material. " 자재코드 서치헬프 설정
