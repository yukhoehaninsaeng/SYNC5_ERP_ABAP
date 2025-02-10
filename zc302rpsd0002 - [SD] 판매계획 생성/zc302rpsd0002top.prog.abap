*&---------------------------------------------------------------------*
*& Include ZC302RPSD0002TOP                         - Report ZC302RPSD0002
*&---------------------------------------------------------------------*
REPORT ZC302RPSD0002 MESSAGE-ID K5.

**********************************************************************
* WA & ITAB
**********************************************************************
DATA : GS_PLAN TYPE ZC302SDT0001,
       GT_PLAN TYPE TABLE OF ZC302SDT0001.
DATA : BEGIN OF GS_ITEM.
         INCLUDE STRUCTURE ZC302SDT0002.
DATA :   MAKTX TYPE ZC302MT0007-MAKTX,
       END OF GS_ITEM,
       GT_ITEM LIKE TABLE OF GS_ITEM.

DATA : GS_LAYOUT TYPE LVC_S_LAYO,
       GS_FCAT   TYPE LVC_S_FCAT,
       GT_FCAT   TYPE LVC_T_FCAT.

DATA : GS_BUTTON TYPE STB_BUTTON.

**********************************************************************
* RANGES
**********************************************************************
RANGES : GR_CHANNEL FOR ZC302SDT0001-CHANNEL,
         GR_YEAR FOR ZC302SDT0001-PYEAR,
         GR_MONTH FOR ZC302SDT0001-PMONTH.

**********************************************************************
* CLASS INSTANCE
**********************************************************************
DATA : GO_CONT TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       GO_ALV  TYPE REF TO CL_GUI_ALV_GRID.

*-- For Top-of-page
DATA : GO_TOP_CONTAINER TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_DYNDOC_ID     TYPE REF TO CL_DD_DOCUMENT,
       GO_HTML_CNTRL    TYPE REF TO CL_GUI_HTML_VIEWER.

**********************************************************************
* COMMON VARIABLE
**********************************************************************
DATA : GV_OKCODE    TYPE SY-UCOMM,
       GV_ANSWER,
       GV_PRE_SPNUM TYPE ZC302SDT0001-SPNUM,
       GV_SAVED.

DATA : GV_ITEM_NUM TYPE I VALUE 10. " 아이템 번호
