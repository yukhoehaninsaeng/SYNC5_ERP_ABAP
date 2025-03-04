*&---------------------------------------------------------------------*
*& Include ZC302RPSD0004TOP                         - Report ZC302RPSD0004
*&---------------------------------------------------------------------*
REPORT ZC302RPSD0004 MESSAGE-ID K5.

**********************************************************************
* TABLES
**********************************************************************
*-- For Excel Upload
TABLES : SSCRFIELDS.

**********************************************************************
* CLASS INSTANCE
**********************************************************************
DATA :GO_CONT_ITEM TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GO_ALV_ITEM  TYPE REF TO CL_GUI_ALV_GRID,
      GO_CONT_PREV TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GO_ALV_PREV  TYPE REF TO CL_GUI_ALV_GRID,
      GO_CONT_SO   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GO_ALV_SO    TYPE REF TO CL_GUI_ALV_GRID.

*-- For Previous SO
DATA : GO_PRE_CONT   TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_PRE_SPLIT  TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
       GO_PRE_CONT_T TYPE REF TO CL_GUI_CONTAINER,
       GO_PRE_CONT_B TYPE REF TO CL_GUI_CONTAINER,
       GO_PRE_ALV_T  TYPE REF TO CL_GUI_ALV_GRID,
       GO_PRE_ALV_B  TYPE REF TO CL_GUI_ALV_GRID.

*-- For Top-of-page
DATA : GO_TOP_CONTAINER TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_DYNDOC_ID     TYPE REF TO CL_DD_DOCUMENT,
       GO_HTML_CNTRL    TYPE REF TO CL_GUI_HTML_VIEWER.

*-- For Text Editor
DATA : GO_TEXT_CONT TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       GO_TEXT_EDIT TYPE REF TO CL_GUI_TEXTEDIT.

**********************************************************************
* WA & ITAB
**********************************************************************

*-- Search Help(F4) for BP Code
DATA : BEGIN OF GS_BPCODE,
         BPCODE TYPE ZC302MT0001-BPCODE,
         CNAME  TYPE ZC302MT0001-CNAME,
       END OF GS_BPCODE,
       GT_BPCODE LIKE TABLE OF GS_BPCODE.

*-- Search Help(F4) for Distribution Channel
DATA : BEGIN OF GS_CHNL,
         CHNL  TYPE ZC302SDT0001-CHANNEL,
         CTEXT TYPE ZC302E_SD_TEXT,
       END OF GS_CHNL,
       GT_CHNL LIKE TABLE OF GS_CHNL.

*-- For Excel Upload
DATA : BEGIN OF GS_EXCEL,
         SORG   TYPE ZC302SDT0003-SALE_ORG,   " 영업 조직
         CHNL   TYPE ZC302SDT0003-CHANNEL,    " 유통 채널
         BPCODE TYPE ZC302SDT0003-BPCODE,     " BP 코드
         PDATE  TYPE ZC302SDT0003-PDATE,      " 주문 일자
         MATNR  TYPE ZC302SDT0004-MATNR,      " 자재 코드
         MENGE  TYPE ZC302SDT0004-MENGE,      " 수량
         MEINS  TYPE ZC302SDT0004-MEINS,      " 단위
       END OF GS_EXCEL,
       GT_EXCEL LIKE TABLE OF GS_EXCEL.

*-- For Direct Input
DATA : GS_HEADER TYPE ZC302SDT0003,
       GT_HEADER TYPE TABLE OF ZC302SDT0003.
DATA : BEGIN OF GS_ITEM.
         INCLUDE STRUCTURE ZC302SDT0004.
DATA :   MAKTX   TYPE ZC302MT0007-MAKTX,
         BTN     TYPE ICON-ID,
         CELLTAB TYPE LVC_T_STYL,
       END OF GS_ITEM,
       GT_ITEM LIKE TABLE OF GS_ITEM.

*-- For previous SO
DATA : BEGIN OF GS_PRE_HEADER.
         INCLUDE STRUCTURE ZC302SDT0003.
DATA :   BTN(30),
         ICON    TYPE ICON-ID,
       END OF GS_PRE_HEADER,
       GT_PRE_HEADER LIKE TABLE OF GS_PRE_HEADER.

DATA : BEGIN OF GS_PRE_ITEM.
         INCLUDE STRUCTURE ZC302SDT0004.
DATA :   MAKTX TYPE ZC302MT0007-MAKTX,
       END OF GS_PRE_ITEM,
       GT_PRE_ITEM LIKE TABLE OF GS_PRE_ITEM.

*-- For Screen 102
DATA : BEGIN OF GS_RESULT.
         INCLUDE STRUCTURE ZC302SDT0004.
DATA :   MAKTX TYPE ZC302MT0007-MAKTX,
       END OF GS_RESULT,
       GT_RESULT LIKE TABLE OF GS_RESULT.

*-- For Text Editor
DATA : BEGIN OF GS_CONTENT,
         TDLINE TYPE TDLINE,
       END OF GS_CONTENT,
       GT_CONTENT LIKE TABLE OF GS_CONTENT.

*-- For ALV
DATA : GS_FCAT_ITEM TYPE LVC_S_FCAT,
       GT_FCAT_ITEM TYPE LVC_T_FCAT,
       GS_FCAT_PREV TYPE LVC_S_FCAT,
       GT_FCAT_PREV TYPE LVC_T_FCAT,
       GS_FCAT_SO   TYPE LVC_S_FCAT,
       GT_FCAT_SO   TYPE LVC_T_FCAT,
       GS_LAYOUT    TYPE LVC_S_LAYO.

DATA: GS_FCAT_PRE_T TYPE LVC_S_FCAT,
      GT_FCAT_PRE_T TYPE LVC_T_FCAT,
      GS_FCAT_PRE_B TYPE LVC_S_FCAT,
      GT_FCAT_PRE_B TYPE LVC_T_FCAT,
      GS_LAYOUT_PRE TYPE LVC_S_LAYO.

DATA : GT_SAVE TYPE TABLE OF ZC302SDT0004,
       GS_SAVE TYPE ZC302SDT0004.

* For ALV
DATA : GS_BUTTON       TYPE STB_BUTTON,
       GT_UI_FUNCTIONS TYPE UI_FUNCTIONS.

DATA : BEGIN OF GS_MAT,
         MATNR TYPE ZC302MT0007-MATNR,
         MAKTX TYPE ZC302MT0007-MAKTX,
         NETWR TYPE ZC302MT0007-NETWR,
         WAERS TYPE ZC302MT0007-WAERS,
       END OF GS_MAT,
       GT_MAT LIKE TABLE OF GS_MAT.

**********************************************************************
* COMMON VARIABLE
**********************************************************************
DATA : GV_OKCODE  TYPE SY-UCOMM,
       GV_IS_SAVE.

*-- For Excel Upload
DATA : GV_FILE LIKE RLGRAP-FILENAME.
*       GV_TCODE  TYPE SY-TCODE.

DATA : W_PICKEDFOLDER  TYPE STRING,
       W_INITIALFOLDER TYPE STRING,
*       W_FULLINFO      TYPE STRING,
       W_PFOLDER       TYPE RLGRAP-FILENAME.

*-- For 1000 screen button
DATA : W_FUNCTXT TYPE SMP_DYNTXT,
       IT_FILES  TYPE FILETABLE.
*       ST_FILES  LIKE LINE OF IT_FILES,
*       W_RC      TYPE I,
*       W_DIR     TYPE STRING.
