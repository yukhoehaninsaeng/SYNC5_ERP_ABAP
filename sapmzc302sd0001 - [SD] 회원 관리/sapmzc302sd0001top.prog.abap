*&---------------------------------------------------------------------*
*& Include SAPMZC302SD0001TOP                       - Module Pool      SAPMZC302SD0001
*&---------------------------------------------------------------------*
PROGRAM SAPMZC302SD0001 MESSAGE-ID K5.

**********************************************************************
* SCREEN ELEMENT
**********************************************************************
DATA : GV_CUSNUM_FROM(10),
       GV_CUSNUM_TO(10),
       GV_CUSNAME(35),
       GV_NUM             TYPE I,
       GV_TOTAL           TYPE I.

**********************************************************************
* WA & ITAB
**********************************************************************
*-- 회원번호 Search Help
DATA : BEGIN OF GS_CUST_F4,
         CUST_NUM  TYPE ZC302MT0002-CUST_NUM,
         CUST_NAME TYPE ZC302MT0002-CUST_NAME,
       END OF GS_CUST_F4,
       GT_CUST_F4 LIKE TABLE OF GS_CUST_F4.

DATA : GS_FCAT   TYPE LVC_S_FCAT,
       GT_FCAT   TYPE LVC_T_FCAT,
       GS_LAYOUT TYPE LVC_S_LAYO.

DATA : GT_MAIN TYPE TABLE OF ZC302MT0002.

**********************************************************************
* RANGES
**********************************************************************
RANGES : GR_CUSNUM FOR ZC302MT0002-CUST_NUM.

**********************************************************************
* CLASS INSTANCE
**********************************************************************
DATA : GO_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       GO_ALV_GRID  TYPE REF TO CL_GUI_ALV_GRID.

**********************************************************************
* COMMON VARIABLE
**********************************************************************
DATA : GV_OKCODE TYPE SY-UCOMM.
