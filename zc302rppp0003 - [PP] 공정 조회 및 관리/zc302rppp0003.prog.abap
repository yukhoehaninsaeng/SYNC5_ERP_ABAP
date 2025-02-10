*&---------------------------------------------------------------------*
*& Module Pool      ZC302RPPP0004
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc302rppp0003top.

INCLUDE zc302rppp0003s01.
INCLUDE zc302rppp0003c01.
INCLUDE zc302rppp0003o01.
INCLUDE zc302rppp0003i01.
INCLUDE zc302rppp0003f01.

**********************************************************************
*&& INITIALIZATION
**********************************************************************
INITIALIZATION.
  PERFORM set_init_value.

**********************************************************************
*&& AT SELECTION-SCREEN
**********************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_pco-low.
  PERFORM f4_pcode USING 'LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_pco-high.
  PERFORM f4_pcode USING 'HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_bom-low.
  PERFORM f4_bomid USING 'LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_bom-high.
  PERFORM f4_bomid USING 'HIGH'.

**********************************************************************
*&& START-OF-SELECTION
**********************************************************************
START-OF-SELECTION.
  PERFORM get_base_data.
  PERFORM make_display_body.

  CALL SCREEN 100.
