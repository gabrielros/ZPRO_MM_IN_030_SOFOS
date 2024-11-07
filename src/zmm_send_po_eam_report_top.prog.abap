*&---------------------------------------------------------------------*
*& Include          ZMM_SEND_PO_ARIES_REPORT_TOP
*&---------------------------------------------------------------------*
TABLES ekko.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
  SELECT-OPTIONS: s_bukrs FOR ekko-bukrs,
                  s_bsart FOR ekko-bsart,
                  s_aedat FOR ekko-aedat OBLIGATORY DEFAULT sy-datum,
                  s_ebeln FOR ekko-ebeln.
SELECTION-SCREEN END OF BLOCK b1.
