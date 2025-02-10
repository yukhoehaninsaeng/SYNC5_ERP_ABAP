*&---------------------------------------------------------------------*
*& Report ZC302RPFI0004
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc302rpfi0004top                        .    " Global Data

INCLUDE ZC302RPFI0004c01                        .  " EVENT
INCLUDE ZC302RPFI0004s01                        .  " PBO-Modules
INCLUDE zc302rpfi0004o01                        .  " PBO-Modules
INCLUDE zc302rpfi0004i01                        .  " PAI-Modules
INCLUDE zc302rpfi0004f01                        .  " FORM-Routines

**********************************************************************
*INITIALIZATION
**********************************************************************
INITIALIZATION.
  PERFORM set_init_value.

**********************************************************************
* AT SELECTION-SCREEN
**********************************************************************
AT SELECTION-SCREEN.
  PERFORM set_condition.

**********************************************************************
*START-OF-SELECTION
**********************************************************************
START-OF-SELECTION.
  PERFORM fill_tree_info.
  PERFORM get_base_data.

  CALL SCREEN 100.

*  cl_demo_output=>display( gt_body ).
