*&---------------------------------------------------------------------*
*& Report ZC302RPFI0009
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zc302rpfi0009top                        .    " Global Data
INCLUDE zc302rpfi0009s01                        .    " Selection Screen
INCLUDE zc302rpfi0009c01                        .    " Class
INCLUDE ZC302RPFI0009O01                        .    " PBO-Modules
INCLUDE ZC302RPFI0009I01                        .    " PAI-Modules
INCLUDE ZC302RPFI0009F01                        .    " FORM-Routines

*--------------------------------------------------------------------*
* Selection Screen F4 Help
*--------------------------------------------------------------------*
  AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_bpcd-low.
    PERFORM on_f4_bpcode USING 'low'.

  AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_bpcd-high.
    PERFORM on_f4_bpcode using 'high'.

*--------------------------------------------------------------------*
* Selection Screen
*--------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM get_base_data.
  PERFORM set_sub_data.

  call screen 100.
