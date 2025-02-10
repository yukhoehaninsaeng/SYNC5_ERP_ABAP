*&---------------------------------------------------------------------*
*& Include ZC302RPSD0007TOP                         - Report ZC302RPSD0007
*&---------------------------------------------------------------------*
REPORT ZC302RPSD0007 MESSAGE-ID K5.

**********************************************************************
* Class Instance
**********************************************************************
DATA : GO_CONT TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_ALV  TYPE REF TO CL_GUI_ALV_GRID.

**********************************************************************
* WA & ITAB
**********************************************************************
DATA : GS_SO_HEADER TYPE ZC302SDT0003,
       GT_SO_HEADER LIKE TABLE OF GS_SO_HEADER.

DATA : BEGIN OF GS_BATCH_JOB_LOG.
         INCLUDE STRUCTURE TBTCO.
DATA :   STATUS_DES(40),
         COLOR      TYPE LVC_T_SCOL,
       END OF GS_BATCH_JOB_LOG,
       GT_BATCH_JOB_LOG LIKE TABLE OF GS_BATCH_JOB_LOG.

DATA : GS_FCAT   TYPE LVC_S_FCAT,
       GT_FCAT   TYPE LVC_T_FCAT,
       GS_LAYOUT TYPE LVC_S_LAYO.

**********************************************************************
* Common Variable
**********************************************************************
DATA : GV_OKCODE TYPE SY-UCOMM.
