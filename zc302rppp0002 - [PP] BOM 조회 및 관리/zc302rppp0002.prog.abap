*&---------------------------------------------------------------------*
*& Report ZC302RPPP0003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc302rppp0002top.

INCLUDE zc302rppp0002s01.
INCLUDE zc302rppp0002c01.
INCLUDE zc302rppp0002o01.
INCLUDE zc302rppp0002i01.
INCLUDE zc302rppp0002f01.

**********************************************************************
* INITIALIZATION
**********************************************************************
INITIALIZATION.
 PERFORM set_init_value.

**********************************************************************
* AT SELECTION-SCREEN
**********************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_bomid-low.
  PERFORM f4_bomid USING 'LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_bomid-high.
  PERFORM f4_bomid USING 'HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_matnr-low.
  PERFORM f4_matnr USING 'LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_matnr-high.
  PERFORM f4_matnr USING 'HIGH'.



**********************************************************************
* START-OF-SELECTION
**********************************************************************
START-OF-SELECTION.
  PERFORM get_bom_data.
  PERFORM make_display_data.

  CALL SCREEN 100.
