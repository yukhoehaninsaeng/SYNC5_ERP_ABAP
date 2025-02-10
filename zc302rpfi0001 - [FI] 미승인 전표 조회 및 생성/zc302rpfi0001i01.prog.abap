*&---------------------------------------------------------------------*
*& Include          ZC302RPFI0001I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
LEAVE TO SCREEN 0.
ENDMODULE.
********&---------------------------------------------------------------------*
********&      Module  USER_COMMAND_0100  INPUT
********&---------------------------------------------------------------------*
********       text
********----------------------------------------------------------------------*
*******MODULE user_command_0100 INPUT.
*******  " 선택된 행의 정보를 받을 변수
*******  DATA: ls_rowno TYPE lvc_s_row,
*******        lt_rowno TYPE lvc_t_row.
*******
*******  CASE gv_okcode.
*******    WHEN 'CRTE'.
*******      " 선택된 행의 index값 저장
*******        CALL METHOD go_left_grid->get_selected_rows
*******          IMPORTING
*******            et_index_rows = lt_rowno.
*******        gv_lines = lines( lt_rowno ).
*******
*******        " 선택된 행의 개수 체크
*******        IF gv_lines > 1.
*******          MESSAGE s000 WITH '하나의 행만 선택하세요!' DISPLAY LIKE 'E'.
*******          EXIT.
*******        ELSEIF gv_lines = 0.
*******          MESSAGE s000 WITH '행을 선택하세요!' DISPLAY LIKE 'E'.
*******          EXIT.
*******        ENDIF.
*******
*******        " 행의 인덱스 값을 읽어서 해당 문서의 번호를 알아옴.
*******        READ TABLE lt_rowno INTO ls_rowno INDEX 1.
*******        READ TABLE <fs_itab> INTO <fs_wa> INDEX ls_rowno-index.
*******
*******        " 임시 전표 발행 여부 확인
*******        IF <fs_ivflag> = 'Y'.
*******          MESSAGE s000 WITH '임시 전표가 존재합니다.' DISPLAY LIKE 'E'.
*******          EXIT.
*******        ENDIF.
*******
*******
*******        " 임시 전표 생성 - 테이블 수정이 필요할 것 같음...
*******        " AP AR에 따라서 세금 인식을 다르게 해야 함....ㅎ
*******        CLEAR: gs_body.
*******        gs_body-zisdn = <fs_docno>.
*******        gs_body-zisdd = sy-datum.
*******        gs_body-gjahr = sy-datum+0(4).
*******        gs_body-zmont = sy-datum+4(2).
*******        gs_body-bpcode = <fs_bpcode>.
*******        gs_body-sptyp = <fs_sptyp>.
*******        CASE gv_mode.
*******          WHEN 'SELL'.
*******            gs_body-spamt = <fs_net_cash> / gv_tax_rate.
*******            gs_body-vadtx = <fs_net_cash> - gs_body-spamt.
*******        ENDCASE.
*******        gs_body-toamt = <fs_net_cash>.
*******        gs_body-waers = <fs_waers>.
*******        gs_body-jpflag = 'N'.
*******        APPEND gs_body TO gt_body.
*******
*******        "alv display refresh
*******        CALL METHOD go_right_grid->refresh_table_display.
*******
*******        " db 반영 - 임시 전표 테이블
*******        MODIFY zc302fit0004 FROM TABLE gt_body.
*******
*******        " db 반영 실패 시
*******        IF sy-subrc NE 0.
*******          ROLLBACK WORK.
*******          MESSAGE s000  WITH 'DB 저장 실패' DISPLAY LIKE 'E'.
*******          STOP.
*******        ENDIF.
*******
*******        " 성공 시 임시 전표 발행 여부 Y 표시
*******          <fs_ivflag> = 'Y'.
*******
*******          " db 테이블 반영 ( 각각 송장 검증 or billing ).
*******          MODIFY <fs_itab> FROM <fs_wa> INDEX ls_rowno-index.
*******          CASE gv_mode.
*******            WHEN 'BUY'.
*******              MODIFY zc302mmt0009 FROM TABLE <fs_itab>.
*******            WHEN 'SELL'.
*******              MODIFY zc302sdt0009 FROM TABLE <fs_itab>.
*******            WHEN OTHERS.
*******          ENDCASE.
*******
*******          IF sy-subrc = 0.
*******            MESSAGE s000 WITH 'DB 반영 완료'.
*******            COMMIT WORK AND WAIT.
*******          ELSE.
*******            ROLLBACK WORK.
*******            MESSAGE s000 WITH 'DB 반영 실패' DISPLAY LIKE 'E'.
*******          ENDIF.
*******  ENDCASE.
*******ENDMODULE. 삭제 예정
