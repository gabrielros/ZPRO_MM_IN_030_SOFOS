class ZOCEAM_DELITEMCO_SAP_CANCELAR definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CANCELAR_LINEA
    importing
      !INPUT type ZOCEAM_DELITEMCANCELAR_LINEA_1
    exporting
      !OUTPUT type ZOCEAM_DELITEMCANCELAR_LINEA_R
    raising
      CX_AI_SYSTEM_FAULT .
  methods CONSTRUCTOR
    importing
      !DESTINATION type ref to IF_PROXY_DESTINATION optional
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    preferred parameter LOGICAL_PORT_NAME
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZOCEAM_DELITEMCO_SAP_CANCELAR IMPLEMENTATION.


  method CANCELAR_LINEA.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'INPUT' kind = '0' value = ref #( INPUT ) )
    ( name = 'OUTPUT' kind = '1' value = ref #( OUTPUT ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'CANCELAR_LINEA'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZOCEAM_DELITEMCO_SAP_CANCELAR'
    logical_port_name   = logical_port_name
    destination         = destination
  ).

  endmethod.
ENDCLASS.
