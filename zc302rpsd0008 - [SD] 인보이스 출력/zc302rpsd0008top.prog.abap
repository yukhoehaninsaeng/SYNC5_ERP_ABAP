*&---------------------------------------------------------------------*
*& Include ZC302RPSD0008TOP                         - Report ZC302RPSD0008
*&---------------------------------------------------------------------*
REPORT ZC302RPSD0008 MESSAGE-ID K5.

**********************************************************************
* CLASS INSTANCE
**********************************************************************
DATA : GO_TOP_CONTAINER TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_DYNDOC_ID     TYPE REF TO CL_DD_DOCUMENT,
       GO_HTML_CNTRL    TYPE REF TO CL_GUI_HTML_VIEWER.

DATA : GO_CONT TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_ALV  TYPE REF TO CL_GUI_ALV_GRID.

DATA : GO_CONT_POP TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
       GO_ALV_POP  TYPE REF TO CL_GUI_ALV_GRID.


*-- For file browser
DATA : OBJFILE       TYPE REF TO CL_GUI_FRONTEND_SERVICES,
       PICKEDFOLDER  TYPE STRING,
       INITIALFOLDER TYPE STRING,
       " FULLINFO      TYPE STRING, " << 없어도 되는듯??
       PFOLDER       TYPE RLGRAP-FILENAME. "MEMORY ID mfolder.

DATA: EXCEL       TYPE OLE2_OBJECT,
      WORKBOOK    TYPE OLE2_OBJECT,
      BOOKS       TYPE OLE2_OBJECT,
      BOOK        TYPE OLE2_OBJECT,
      SHEETS      TYPE OLE2_OBJECT,
      SHEET       TYPE OLE2_OBJECT,
      ACTIVESHEET TYPE OLE2_OBJECT,
      APPLICATION TYPE OLE2_OBJECT,
      PAGESETUP   TYPE OLE2_OBJECT,
      CELLS       TYPE OLE2_OBJECT,
      CELL        TYPE OLE2_OBJECT,
      ROW         TYPE OLE2_OBJECT,
      BUFFER      TYPE OLE2_OBJECT,
      FONT        TYPE OLE2_OBJECT,
      RANGE       TYPE OLE2_OBJECT,  " Range
      BORDERS     TYPE OLE2_OBJECT.

DATA: CELL1 TYPE OLE2_OBJECT,
      CELL2 TYPE OLE2_OBJECT.

**********************************************************************
* WA & ITAB
**********************************************************************
*-- 판매오더 Header & Item
DATA : GS_HEADER TYPE ZC302SDT0003,
       GT_HEADER TYPE TABLE OF ZC302SDT0003.

DATA : BEGIN OF GS_ITEM.
         INCLUDE STRUCTURE ZC302SDT0004.
DATA :   MAKTX     TYPE ZC302MT0007-MAKTX,
         NETWR_MAT TYPE ZC302MT0007-NETWR,
       END OF GS_ITEM,
       GT_ITEM LIKE TABLE OF GS_ITEM.

*-- BP 코드 Search Help(F4)
DATA : BEGIN OF GS_BP_F4,
         BPCODE TYPE ZC302MT0001-BPCODE,
         CNAME  TYPE ZC302MT0001-CNAME,
       END OF GS_BP_F4,
       GT_BP_F4 LIKE TABLE OF GS_BP_F4.

DATA : GS_FCAT   TYPE LVC_S_FCAT,
       GT_FCAT   TYPE LVC_T_FCAT,
       GS_LAYOUT TYPE LVC_S_LAYO.

DATA : GS_FCAT_POP TYPE LVC_S_FCAT,
       GT_FCAT_POP TYPE LVC_T_FCAT.

**********************************************************************
* COMMON VARIABLE
**********************************************************************
DATA : GV_OKCODE TYPE SY-UCOMM,
       GV_PDF.

*-- For Excel
DATA: GV_TOT_PAGE   LIKE SY-PAGNO,          " Total page
      GV_PERCENT(3) TYPE N,                 " Reading percent
      GV_FILE       LIKE RLGRAP-FILENAME .  " File name

DATA : GV_TEMP_FILENAME     LIKE RLGRAP-FILENAME,
       GV_TEMP_FILENAME_PDF LIKE RLGRAP-FILENAME,
       GV_FORM(40).
