*&---------------------------------------------------------------------*
*& Include          ZC302RPMM0001S01
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK pa1 WITH FRAME TITLE TEXT-i01.
 SELECTION-SCREEN SKIP.
 SELECTION-SCREEN BEGIN OF LINE.

     SELECTION-SCREEN POSITION 1.
     PARAMETERS : pa_rd01 RADIOBUTTON GROUP rd USER-COMMAND evt MODIF ID ALL.
                  SELECTION-SCREEN COMMENT (2) FOR FIELD PA_RD01.

     SELECTION-SCREEN POSITION 10.
     PARAMETERS : pa_rd02 RADIOBUTTON GROUP rd MODIF ID RM.
                  SELECTION-SCREEN COMMENT (3) FOR FIELD PA_RD02.

     SELECTION-SCREEN POSITION 20.
     PARAMETERS : pa_rd03 RADIOBUTTON GROUP rd MODIF ID SP.
                  SELECTION-SCREEN COMMENT (3) FOR FIELD PA_RD03.

     SELECTION-SCREEN POSITION 30.
     PARAMETERS : pa_rd04 RADIOBUTTON GROUP rd MODIF ID CP.
                  SELECTION-SCREEN COMMENT (3) FOR FIELD PA_RD04.

 SELECTION-SCREEN END OF LINE.
 SELECTION-SCREEN SKIP.
SELECTION-SCREEN END OF BLOCK pa1.
