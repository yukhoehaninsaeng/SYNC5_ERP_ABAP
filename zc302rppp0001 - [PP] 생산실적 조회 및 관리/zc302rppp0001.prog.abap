*&---------------------------------------------------------------------*
*& Report ZC302RPPP0002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc302rppp0001top.

INCLUDE zc302rppp0001s01.
INCLUDE zc302rppp0001c01.
INCLUDE zc302rppp0001o01.
INCLUDE zc302rppp0001i01.
INCLUDE zc302rppp0001f01.

**********************************************************************
*&& INITIALIZATION
**********************************************************************
INITIALIZATION.
  PERFORM set_init_value.

**********************************************************************
*&& AT SELECTION-SCREEN
**********************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_qin-low.
  PERFORM f4_qinum USING 'LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_qin-high.
  PERFORM f4_qinum USING 'HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_pon-low.
  PERFORM f4_ponum USING 'LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_pon-high.
  PERFORM f4_ponum USING 'HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_mat-low.
  PERFORM f4_matnr USING 'LOW'.

**********************************************************************
*&& START-OF-SELECTION
**********************************************************************
START-OF-SELECTION.
  PERFORM get_base_data.
  PERFORM make_display_body.

  CALL SCREEN 100.
