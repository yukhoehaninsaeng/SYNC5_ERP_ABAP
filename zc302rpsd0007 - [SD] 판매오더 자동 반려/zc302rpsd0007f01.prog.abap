*&---------------------------------------------------------------------*
*& Include          ZC302RPSD0007F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SO_AUTO_REJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SO_AUTO_REJECT .
  DATA : LV_GAP   TYPE P,
         LV_TABIX TYPE SY-TABIX.

*--------------------------------------------------------------------*
* 판매오더 생성일로부터 7일이 지난 오더는 자동 반려 처리
*--------------------------------------------------------------------*
*-- 결재 대기 상태의 판매오더 가져오기
  CLEAR : GT_SO_HEADER, GS_SO_HEADER.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_SO_HEADER
    FROM ZC302SDT0003
    WHERE STATUS = ''      " 결재 대기 상태
      AND CHANNEL <> 'OS'. " 자사몰 제외

  LOOP AT GT_SO_HEADER INTO GS_SO_HEADER.
    LV_TABIX = SY-TABIX.

    " 해당 오더가 판매오더 생성일로부터 몇 일이 지났는지 계산
    CALL FUNCTION 'SD_DATETIME_DIFFERENCE'
      EXPORTING
        DATE1    = GS_SO_HEADER-SDATE
        TIME1    = GS_SO_HEADER-ERZET
        DATE2    = SY-DATUM
        TIME2    = SY-UZEIT
      IMPORTING
        DATEDIFF = LV_GAP.

    " 판매오더 생성일로부터 7일이 지난 경우 자동으로 반려 처리
    IF LV_GAP > 7.
      GS_SO_HEADER-STATUS = 'R'.          " 결재 상태 변경
      GS_SO_HEADER-REMARK = '결재 기간 초과'.  " 반려 사유

      " Timestamp
      GS_SO_HEADER-AEDAT = SY-DATUM.
      GS_SO_HEADER-AEZET = SY-UZEIT.
      GS_SO_HEADER-AENAM = 'Batch Job'.

      MODIFY GT_SO_HEADER FROM GS_SO_HEADER INDEX LV_TABIX TRANSPORTING STATUS REMARK AEDAT AEZET AENAM.

      IF SY-SUBRC = 0.
        MESSAGE S001 WITH GS_SO_HEADER-SONUM TEXT-I01.
      ENDIF.
    ENDIF.

    CLEAR : GS_SO_HEADER.
  ENDLOOP.

  " DB Table에 자동 반려 내역 반영
  MODIFY ZC302SDT0003 FROM TABLE GT_SO_HEADER.

  IF SY-SUBRC = 0.
    COMMIT WORK AND WAIT.
  ELSE.
    MESSAGE S001 WITH TEXT-E01 DISPLAY LIKE 'E'.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_LOG .
  DATA : LV_TABIX TYPE SY-TABIX,
         LS_COLOR TYPE LVC_S_SCOL.

*-- Batch Job 로그 데이터 가져오기
  CLEAR : GS_BATCH_JOB_LOG, GT_BATCH_JOB_LOG.
  SELECT JOBNAME JOBCOUNT SDLUNAME STATUS STRTDATE STRTTIME RELDATE RELTIME ENDDATE ENDTIME PERIODIC
    FROM TBTCO
    INTO CORRESPONDING FIELDS OF TABLE GT_BATCH_JOB_LOG
    WHERE JOBNAME = 'SO_AUTO_REJECT'.

*    SORT GT_BATCH_JOB_LOG BY STRTDATE STRTTIME.

*-- 로그를 불러오지 못한 경우 에러 메시지 디스플레이
  IF GT_BATCH_JOB_LOG IS INITIAL.
    MESSAGE S001 WITH TEXT-E02 DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

*-- STATUS description 세팅 및 상태별 색상 변경
  LOOP AT GT_BATCH_JOB_LOG INTO GS_BATCH_JOB_LOG.
    LV_TABIX = SY-TABIX.
    CLEAR : GS_BATCH_JOB_LOG-COLOR, LS_COLOR.

    CASE GS_BATCH_JOB_LOG-STATUS.
      WHEN 'A'.
        GS_BATCH_JOB_LOG-STATUS_DES = 'Cancelled'.
        LS_COLOR-FNAME = 'STATUS_DES'.
        LS_COLOR-COLOR-COL = 6. " Red
        INSERT LS_COLOR INTO TABLE GS_BATCH_JOB_LOG-COLOR.
      WHEN 'F'.
        GS_BATCH_JOB_LOG-STATUS_DES = 'Completed'.
        LS_COLOR-FNAME = 'STATUS_DES'.
        LS_COLOR-COLOR-COL = 5. " Green
        INSERT LS_COLOR INTO TABLE GS_BATCH_JOB_LOG-COLOR.
      WHEN 'P'.
        GS_BATCH_JOB_LOG-STATUS_DES = 'Scheduled'.
      WHEN 'R'.
        GS_BATCH_JOB_LOG-STATUS_DES = 'Running'.
        LS_COLOR-FNAME = 'STATUS_DES'.
        LS_COLOR-COLOR-COL = 3. " Yellow
        INSERT LS_COLOR INTO TABLE GS_BATCH_JOB_LOG-COLOR.
      WHEN 'S'.
        GS_BATCH_JOB_LOG-STATUS_DES = 'Released'.
      WHEN 'Y'.
        GS_BATCH_JOB_LOG-STATUS_DES = 'Ready'.
      WHEN 'X'.
        GS_BATCH_JOB_LOG-STATUS_DES = 'Unknown state'.
        LS_COLOR-FNAME = 'STATUS_DES'.
        LS_COLOR-COLOR-COL = 7. " Orange
        INSERT LS_COLOR INTO TABLE GS_BATCH_JOB_LOG-COLOR.
    ENDCASE.

    MODIFY GT_BATCH_JOB_LOG FROM GS_BATCH_JOB_LOG INDEX LV_TABIX TRANSPORTING STATUS_DES COLOR.

    CLEAR : GS_BATCH_JOB_LOG.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT .

  CLEAR : GS_LAYOUT.

  GS_LAYOUT-ZEBRA      = ABAP_TRUE.
  GS_LAYOUT-CWIDTH_OPT = 'A'.
  GS_LAYOUT-SEL_MODE   = 'D'.
  GS_LAYOUT-CTAB_FNAME = 'COLOR'.
  GS_LAYOUT-GRID_TITLE = '판매오더 자동 반려 배치잡 로그'.
  GS_LAYOUT-SMALLTITLE = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT .
  CREATE OBJECT GO_CONT
    EXPORTING
      SIDE      = GO_CONT->DOCK_AT_LEFT
      EXTENSION = 5000.

  CREATE OBJECT GO_ALV
    EXPORTING
      I_PARENT = GO_CONT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_FCAT  USING PV_KEY
                     PV_FIELD
                     PV_TEXT
                     PV_JUST
                     PV_EMP.
  CLEAR : GS_FCAT.

  GS_FCAT-KEY       = PV_KEY.
  GS_FCAT-FIELDNAME = PV_FIELD.
  GS_FCAT-COLTEXT   = PV_TEXT.
  GS_FCAT-JUST      = PV_JUST.
  GS_FCAT-EMPHASIZE = PV_EMP.

  APPEND GS_FCAT TO GT_FCAT.

ENDFORM.
