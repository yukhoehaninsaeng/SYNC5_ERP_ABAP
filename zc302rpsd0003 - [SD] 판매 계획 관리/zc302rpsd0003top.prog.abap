*&---------------------------------------------------------------------*
*& Include ZC302RPSD0003TOP                         - Report ZC302RPSD0003
*&---------------------------------------------------------------------*
REPORT ZC302RPSD0003 MESSAGE-ID K5.

**********************************************************************
* TABLES
**********************************************************************
TABLES : ZC302SDT0001.

**********************************************************************
* WA & ITAB
**********************************************************************
DATA : GS_LAYOUT      TYPE LVC_S_LAYO,
       GS_LAYOUT_ITEM TYPE LVC_S_LAYO,
       GS_FCAT_L      TYPE LVC_S_FCAT,
       GT_FCAT_L      TYPE LVC_T_FCAT,
       GS_FCAT_R      TYPE LVC_S_FCAT,
       GT_FCAT_R      TYPE LVC_T_FCAT.

DATA : GS_HEADER TYPE ZC302SDT0001,
       GT_HEADER TYPE TABLE OF ZC302SDT0001.
DATA : BEGIN OF GS_ITEM.
         INCLUDE STRUCTURE ZC302SDT0002.
DATA :   MAKTX    TYPE ZC302MT0007-MAKTX,
         MDFY_BTN TYPE ICON-ID,
       END OF GS_ITEM,
       GT_ITEM LIKE TABLE OF GS_ITEM.

DATA : BEGIN OF GS_MAT,
         MATNR TYPE ZC302MT0007-MATNR,
         MAKTX TYPE ZC302MT0007-MAKTX,
         NETWR TYPE ZC302MT0007-NETWR,
         WAERS TYPE ZC302MT0007-WAERS,
       END OF GS_MAT,
       GT_MAT LIKE TABLE OF GS_MAT.

DATA : GS_BUTTON TYPE STB_BUTTON.

DATA : GS_DELT TYPE ZC302SDT0002,
       GT_DELT LIKE TABLE OF GS_DELT.

**********************************************************************
* CLASS INSTANCE
**********************************************************************
DATA : "GO_CONT   TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_CONT   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       GO_SPLIT  TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
       GO_CONT_L TYPE REF TO CL_GUI_CONTAINER,
       GO_CONT_R TYPE REF TO CL_GUI_CONTAINER.

DATA : GO_ALV_L TYPE REF TO CL_GUI_ALV_GRID,
       GO_ALV_R TYPE REF TO CL_GUI_ALV_GRID.

*-- For Top-of-page
DATA : GO_TOP_CONTAINER TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_DYNDOC_ID     TYPE REF TO CL_DD_DOCUMENT,
       GO_HTML_CNTRL    TYPE REF TO CL_GUI_HTML_VIEWER.

**********************************************************************
* COMMON VARIABLE
**********************************************************************
DATA : GV_OKCODE TYPE SY-UCOMM.

DATA : GV_MATNR      TYPE ZC302SDT0002-MATNR,
       GV_MENGE      TYPE ZC302SDT0002-MENGE,
       GV_MEINS      TYPE ZC302SDT0002-MEINS,
       GV_MAKTX      TYPE ZC302MT0007-MAKTX,
       GV_NETWR      TYPE ZC302SDT0002-NETWR,
       GV_WAERS      TYPE ZC302SDT0002-WAERS,
       GV_ITEM_INDEX TYPE I.

DATA : GV_SPNUM   TYPE ZC302SDT0002-SPNUM,
       GV_POSNR   TYPE ZC302SDT0002-POSNR,
       GV_HINDEX  TYPE I,
       GV_MODE(1).        " 생성 & 수정 이벤트 구분 위함(Application toolbar 변경 위함)
