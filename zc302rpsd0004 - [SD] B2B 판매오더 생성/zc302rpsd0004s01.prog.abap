*&---------------------------------------------------------------------*
*& Include          ZC302RPSD0004S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-T01.
  SELECTION-SCREEN SKIP.

  " 라디오 버튼(직접 입력, Excel 업로드)
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : P_RB1 RADIOBUTTON GROUP G1 USER-COMMAND EVT DEFAULT 'X'. " 직접 입력
    SELECTION-SCREEN POSITION 4.
    SELECTION-SCREEN COMMENT (10) TEXT-R01.

    PARAMETERS : P_RB2 RADIOBUTTON GROUP G1.                              " Excel 업로드
    SELECTION-SCREEN POSITION 18.
    SELECTION-SCREEN COMMENT (10) TEXT-R02.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN ULINE.

  PARAMETERS : P_SORG TYPE ZC302SDT0003-SALE_ORG DEFAULT '0001' MODIF ID ORG,   " 영업조직
               P_CHNL TYPE ZC302SDT0003-CHANNEL,                                " 유통채널
               P_BP   TYPE ZC302SDT0003-BPCODE,                                 " BP코드
               P_PDAT TYPE ZC302SDT0003-PDATE,                                  " 주문일자
               P_INUM TYPE N LENGTH 3 MODIF ID NUM.                             " 아이템개수

  PARAMETERS : P_PATH TYPE RLGRAP-FILENAME MODIF ID PAT.                        " 파일경로

SELECTION-SCREEN END OF BLOCK B1.
