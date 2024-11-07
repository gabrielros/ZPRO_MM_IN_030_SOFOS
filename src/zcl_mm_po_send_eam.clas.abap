class ZCL_MM_PO_SEND_EAM definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_ME_PROCESS_PO_CUST .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MM_PO_SEND_EAM IMPLEMENTATION.


  method IF_EX_ME_PROCESS_PO_CUST~CHECK.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~CLOSE.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~FIELDSELECTION_HEADER.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~FIELDSELECTION_HEADER_REFKEYS.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~FIELDSELECTION_ITEM.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~FIELDSELECTION_ITEM_REFKEYS.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~INITIALIZE.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~OPEN.
  endmethod.


  METHOD if_ex_me_process_po_cust~post.

    DATA(o_send) = NEW zcl_mm_send_po_eam_report( ).

    DATA(ls_header) = im_header->get_data( ).

    IF ls_header-memory IS INITIAL AND ( ls_header-memorytype NE 'P' AND ls_header-memorytype NE 'H' ).
      o_send->send_po_to_eam( EXPORTING im_ebeln  = im_ebeln
                                        im_header = im_header ).
    ENDIF.

  ENDMETHOD.


  method IF_EX_ME_PROCESS_PO_CUST~PROCESS_ACCOUNT.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~PROCESS_HEADER.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~PROCESS_ITEM.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~PROCESS_SCHEDULE.
  endmethod.
ENDCLASS.
