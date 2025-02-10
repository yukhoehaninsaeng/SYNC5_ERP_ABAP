*&---------------------------------------------------------------------*
*& Report ZC302RPPP0006
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc302rppp0005top.

INCLUDE zc302rppp0005s01.
INCLUDE zc302rppp0005c01.
INCLUDE zc302rppp0005o01.
INCLUDE zc302rppp0005i01.
INCLUDE zc302rppp0005f01.

**********************************************************************
*&& INITIALIZATION
**********************************************************************
INITIALIZATION.
  PERFORM set_init_value.

**********************************************************************
*&& START-OF-SELECTION
**********************************************************************
START-OF-SELECTION.
  PERFORM get_batch_data.
  PERFORM make_display_batch.
  PERFORM get_base_data.

  IF sy-batch EQ 'X'.
    PERFORM process_progress.
    PERFORM set_batch_job.
  ELSE.
    CALL SCREEN 100.
  ENDIF.
