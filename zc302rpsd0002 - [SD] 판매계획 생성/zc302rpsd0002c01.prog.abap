*&---------------------------------------------------------------------*
*& Class LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS : TOP_OF_PAGE FOR EVENT TOP_OF_PAGE OF CL_GUI_ALV_GRID
                                    IMPORTING E_DYNDOC_ID.
ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.
  METHOD TOP_OF_PAGE.
    PERFORM EVENT_TOP_OF_PAGE.
  ENDMETHOD.
ENDCLASS.
