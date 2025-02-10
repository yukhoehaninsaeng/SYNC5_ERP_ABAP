*&---------------------------------------------------------------------*
*& Report ZC302RPPP0006
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc302rppp0006top                        .    " Global Data

INCLUDE zc302rppp0006s01                        .
INCLUDE zc302rppp0006c01                        .
INCLUDE zc302rppp0006o01                        .  " PBO-Modules
INCLUDE zc302rppp0006i01                        .  " PAI-Modules
INCLUDE zc302rppp0006f01                        .  " FORM-Routines

**********************************************************************
* INITIALIZATION
**********************************************************************
INITIALIZATION.
  PERFORM set_init_value.

**********************************************************************
* START-OF-SELECTION
**********************************************************************
START-OF-SELECTION.
 PERFORM get_batch_data.
 PERFORM make_display_batch.
 PERFORM get_base_data.


 IF sy-batch EQ 'X'.
   PERFORM process_progress.
 ELSE.
   CALL SCREEN 100.
 ENDIF.
