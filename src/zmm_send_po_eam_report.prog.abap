*&---------------------------------------------------------------------*
*& Report ZMM_SEND_PO_ARIES_REPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_send_po_eam_report.

INCLUDE ZMM_SEND_PO_EAM_REPORT_TOP.
*INCLUDE zmm_send_po_aries_report_top.



START-OF-SELECTION.

  DATA(o_alv) = NEW zcl_mm_send_po_eam_report( ).

  o_alv->start( i_bukrs = s_bukrs[]
                i_bsart = s_bsart[]
                i_ebeln = s_ebeln[]
                i_aedat = s_aedat[] ).
