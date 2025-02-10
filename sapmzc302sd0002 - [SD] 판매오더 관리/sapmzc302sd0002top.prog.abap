*&---------------------------------------------------------------------*
*& Include SAPMZC302SD0002TOP        - Module Pool      SAPMZC302SD0002
*&---------------------------------------------------------------------*
PROGRAM SAPMZC302SD0002 MESSAGE-ID K5.

**********************************************************************
* TAB STRIP CONTROLS
**********************************************************************
CONTROLS : GO_TAB_STRIP TYPE TABSTRIP.

DATA : GV_SUBSCREEN TYPE SY-DYNNR VALUE '0110', " 서브스크린 번호
       GV_TAB       TYPE SY-UCOMM VALUE 'TAB1'. " 탭 번호

**********************************************************************
* RANGES
**********************************************************************
RANGES : GR_CHNL   FOR ZC302SDT0003-CHANNEL,  " 채널
         GR_BPCODE FOR ZC302SDT0003-BPCODE,   " BP코드
         GR_DATE   FOR ZC302SDT0003-SDATE.    " 판매오더생성일

**********************************************************************
* CLASS INSTANCE
**********************************************************************
*-- 스크린 100번
DATA : GO_CONT_FST TYPE REF TO CL_GUI_CUSTOM_CONTAINER, " [전체]탭 컨테이너
       GO_CONT_PEN TYPE REF TO CL_GUI_CUSTOM_CONTAINER, " [대기] 탭 컨테이너
       GO_CONT_APP TYPE REF TO CL_GUI_CUSTOM_CONTAINER, " [승인] 탭 컨테이너
       GO_CONT_REJ TYPE REF TO CL_GUI_CUSTOM_CONTAINER, " [반려] 탭 컨테이너
       GO_ALV_FST  TYPE REF TO CL_GUI_ALV_GRID,         " [전체] 탭 ALV Grid
       GO_ALV_PEN  TYPE REF TO CL_GUI_ALV_GRID,         " [대기] 탭 ALV Grid
       GO_ALV_APP  TYPE REF TO CL_GUI_ALV_GRID,         " [승인] 탭 ALV Grid
       GO_ALV_REJ  TYPE REF TO CL_GUI_ALV_GRID.         " [반려] 탭 ALV Grid

*-- 결재 팝업
DATA : GO_CONT_POP     TYPE REF TO CL_GUI_CUSTOM_CONTAINER,     " 좌측 컨테이너
       GO_ALV_POP      TYPE REF TO CL_GUI_ALV_GRID,             " 좌측 ALV Grid
       GO_CONT_QTY     TYPE REF TO CL_GUI_CUSTOM_CONTAINER,     " 우측 메인 컨테이너
       GO_SPLIT_CONT   TYPE REF TO CL_GUI_SPLITTER_CONTAINER,   " Splitter 컨테이너
       GO_CONT_QTY_MAT TYPE REF TO CL_GUI_CONTAINER,            " 우측 상단 컨테이너
       GO_CONT_QTY_DAT TYPE REF TO CL_GUI_CONTAINER,            " 우측 하단 컨테이너
       GO_ALV_QTY_MAT  TYPE REF TO CL_GUI_ALV_GRID,             " 우측 상단 ALV Grid
       GO_ALV_QTY_DAT  TYPE REF TO CL_GUI_ALV_GRID.             " 우측 하단 ALV Grid

*-- 판매오더 상세 정보 팝업
DATA : GO_CONT_DETAIL TYPE REF TO CL_GUI_CUSTOM_CONTAINER, " 컨테이너
       GO_ALV_DETAIL  TYPE REF TO CL_GUI_ALV_GRID.         " ALV Grid

*-- 반려 사유 입력 팝업
DATA : GO_CONT_TE   TYPE REF TO CL_GUI_CUSTOM_CONTAINER, " Text Editor를 위한 컨테이너
       GO_TEXT_EDIT TYPE REF TO CL_GUI_TEXTEDIT.         " 반려 사유 입력을 위한 Text Editor


**********************************************************************
* WA & ITAB
**********************************************************************
*-- [전체] 탭 ALV에 바인딩 될 ITAB & WA
DATA : BEGIN OF GS_SO_HEADER.
         INCLUDE STRUCTURE ZC302SDT0003.
DATA :   ICON           TYPE ICON-ID,     " 결재 상태
         REMARK_BTN(30),                  " 반려 사유 상세
       END OF GS_SO_HEADER,
       GT_SO_HEADER LIKE TABLE OF GS_SO_HEADER.

*-- [승인] 탭 ALV에 바인딩 될 ITAB & WA
DATA : GS_SO_APP LIKE GS_SO_HEADER,
       GT_SO_APP LIKE TABLE OF GS_SO_APP.

*-- [반려] 탭 ALV에 바인딩 될 ITAB & WA
DATA : GS_SO_REJ LIKE GS_SO_HEADER,
       GT_SO_REJ LIKE TABLE OF GS_SO_REJ.

*-- [대기] 탭 ALV에 바인딩 될 ITAB & WA
DATA : BEGIN OF GS_SO_PEN.
         INCLUDE STRUCTURE ZC302SDT0003.
DATA :   ICON        TYPE ICON-ID,        " 결재 상태
         COLOR       TYPE LVC_T_SCOL,     " Color 속성 컬럼
         APP_BTN(10),                     " 결재 버튼
       END OF GS_SO_PEN,
       GT_SO_PEN LIKE TABLE OF GS_SO_PEN.

*-- 결재 팝업 : 판매오더 아이템에 바인딩될 ITAB & WA
DATA : BEGIN OF GS_SO_ITEM.
         INCLUDE STRUCTURE ZC302SDT0004.
DATA :   MAKTX TYPE ZC302MT0007-MAKTX,    " 자재명
         ICON  TYPE ICON-ID,              " 가용 여부
         COLOR TYPE LVC_T_SCOL,           " Color 속성 컬럼
       END OF GS_SO_ITEM,
       GT_SO_ITEM LIKE TABLE OF GS_SO_ITEM.

*-- 유통채널 Search Help(F4)
DATA : BEGIN OF GS_CHNL_F4,
         CHNL  TYPE ZC302SDT0003-CHANNEL,   " 유통채널
         CTEXT TYPE ZC302E_SD_TEXT,         " 유통채널 텍스트
       END OF GS_CHNL_F4,
       GT_CHNL_F4 LIKE TABLE OF GS_CHNL_F4.

*-- BP코드 Search Help(F4)
DATA : BEGIN OF GS_BP_F4,
         BPCODE TYPE ZC302MT0001-BPCODE,    " BP코드
         CNAME  TYPE ZC302MT0001-CNAME,     " BP명
       END OF GS_BP_F4,
       GT_BP_F4 LIKE TABLE OF GS_BP_F4.

*-- 스크린 100번 Layout & Field Catalog
DATA : GS_LAYOUT   TYPE LVC_S_LAYO,   " 공통 Layout
       GS_FCAT_FST TYPE LVC_S_FCAT,   " [전체] 탭 Field Catalog WA
       GT_FCAT_FST TYPE LVC_T_FCAT,   " [전체] 탭 Field Catalog ITAB
       GS_FCAT_PEN TYPE LVC_S_FCAT,   " [대기] 탭 Field Catalog WA
       GT_FCAT_PEN TYPE LVC_T_FCAT,   " [대기] 탭 Field Catalog ITAB
       GS_FCAT_APP TYPE LVC_S_FCAT,   " [승인] 탭 Field Catalog WA
       GT_FCAT_APP TYPE LVC_T_FCAT,   " [승인] 탭 Field Catalog ITAB
       GS_FCAT_REJ TYPE LVC_S_FCAT,   " [반려] 탭 Field Catalog WA
       GT_FCAT_REJ TYPE LVC_T_FCAT.   " [반려] 탭 Field Catalog ITAB

*-- 결재 팝업 Layout & Field Catalog
DATA : GS_FCAT_POP       TYPE LVC_S_FCAT,   " 판매오더 아이템 Field Catalog WA
       GT_FCAT_POP       TYPE LVC_T_FCAT,   " 판매오더 아이템 Field Catalog ITAB
       GS_FCAT_QTY_MAT   TYPE LVC_S_FCAT,   " 자재별 재고 Field Catalog WA
       GT_FCAT_QTY_MAT   TYPE LVC_T_FCAT,   " 자재별 재고 Field Catalog ITAB
       GS_FCAT_QTY_DAT   TYPE LVC_S_FCAT,   " 자재/생성일별 재고 Field Catalog WA
       GT_FCAT_QTY_DAT   TYPE LVC_T_FCAT,   " 자재/생성일별 재고 Field Catalog ITAB
       GS_LAYOUT_QTY_MAT TYPE LVC_S_LAYO,   " 자재별 재고 Layout
       GS_LAYOUT_QTY_DAT TYPE LVC_S_LAYO.   " 자재/생성일별 재고 Layout

*-- 자재코드, 생성일별 재고 정보 (재고관리 Item)
DATA : BEGIN OF GS_DETAIL_QTY.
         INCLUDE STRUCTURE ZC302MMT0002.
DATA :   AVQTY TYPE ZC302MMT0002-I_RTPTQUA, " 가용 재고(현재재고 - 예약재고)
       END OF GS_DETAIL_QTY,
       GT_DETAIL_QTY LIKE TABLE OF GS_DETAIL_QTY.

*-- 자재코드별 재고 정보(재고관리 Header)
DATA : BEGIN OF GS_QTY.
         INCLUDE STRUCTURE ZC302MMT0013.
DATA :   AVQTY TYPE ZC302MMT0013-H_RTPTQUA, " 가용 재고(현재재고 - 예약재고)
       END OF GS_QTY,
       GT_QTY LIKE TABLE OF GS_QTY.

*-- 판매오더 상세 팝업 Field Catalog
DATA : GS_FCAT_DETAIL TYPE LVC_S_FCAT,
       GT_FCAT_DETAIL TYPE LVC_T_FCAT.

*-- ALV 정렬을 위한 WA & ITAB
DATA : GS_SORT TYPE LVC_S_SORT,
       GT_SORT TYPE LVC_T_SORT.

*-- Text Editor 입력 내용을 위한 WA & ITAB
DATA : BEGIN OF GS_CONTENT,
         TDLINE TYPE TDLINE,
       END OF GS_CONTENT,
       GT_CONTENT LIKE TABLE OF GS_CONTENT.


**********************************************************************
* COMMON VARIABLE
**********************************************************************
DATA : GV_OKCODE TYPE SY-UCOMM, " OKCODE
       GV_OOS.                  " OOS 여부

DATA : GV_SORG         TYPE ZC302SDT0003-SONUM,   " 판매오더번호
       GV_CHNL_FROM    TYPE ZC302SDT0003-CHANNEL, " 유통채널 From
       GV_BPCODE_FROM  TYPE ZC302SDT0003-BPCODE,  " BP코드 From
       GV_CHNL_TO      TYPE ZC302SDT0003-CHANNEL, " 유통채널 To
       GV_BPCODE_TO    TYPE ZC302SDT0003-BPCODE,  " BP코드 To
       GV_DATE_FROM    TYPE ZC302SDT0003-SDATE,   " 판매오더생성일 From
       GV_DATE_TO      TYPE ZC302SDT0003-SDATE,   " 판매오더생성일 To
       GV_PEN          TYPE I,                    " 결재 대기 상태의 판매오더 개수
       GV_APP          TYPE I,                    " 승인 상태의 판매오더 개수
       GV_REJ          TYPE I,                    " 반려 상태의 판매오더 개수
       GV_CLOSE_OPT(1),                           " 창 닫기 옵션
       GV_READ_MODE(1),                           " 조회/편집 모드
       GV_GUBUN(3).                               " 반려 사유 불러올 ITAB 종류
