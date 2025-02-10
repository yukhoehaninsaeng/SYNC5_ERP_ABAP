*&---------------------------------------------------------------------*
*& Include          ZC302RPSD0007O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'MENU100'.
  SET TITLEBAR 'TITLE100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_PROCESS_CONTROL OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_PROCESS_CONTROL OUTPUT.
  IF GO_CONT IS NOT BOUND.
    CLEAR : GT_FCAT.

    PERFORM SET_FCAT USING : 'X' 'JOBNAME'    'Job명'     'C' ' ',
                             'X' 'JOBCOUNT'   'Job ID'    'C' ' ',
                             ' ' 'SDLUNAME'   '생성자'     'C' ' ',
                             ' ' 'STATUS_DES' '상태'       'C' ' ',
                             ' ' 'STRTDATE'   '시작 날짜'   'C' ' ',
                             ' ' 'STRTTIME'   '시작 시간'   'C' ' ',
                             ' ' 'ENDDATE'    '종료 날짜'   'C' ' ',
                             ' ' 'ENDTIME'    '종료 시간'   'C' ' ',
                             ' ' 'RELDATE'    '배포 날짜'   'C' ' ',
                             ' ' 'RELTIME'    '배포 시간'   'C' ' ',
                             ' ' 'PERIODIC'   '주기적 실행 여부' 'C' ' '.


    PERFORM SET_LAYOUT.

    PERFORM CREATE_OBJECT.

    CALL METHOD GO_ALV->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        I_SAVE          = 'A'
        I_DEFAULT       = 'X'
        IS_LAYOUT       = GS_LAYOUT
      CHANGING
        IT_OUTTAB       = GT_BATCH_JOB_LOG
        IT_FIELDCATALOG = GT_FCAT.

  ENDIF.
ENDMODULE.
