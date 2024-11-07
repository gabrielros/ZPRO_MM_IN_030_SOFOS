class ZEAM_CABOCCO_SAP_CREACION_CABE definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !DESTINATION type ref to IF_PROXY_DESTINATION optional
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    preferred parameter LOGICAL_PORT_NAME
    raising
      CX_AI_SYSTEM_FAULT .
  methods CREACION_CABECERA_OC
    importing
      !INPUT type ZEAM_CABOCCREACION_CABECERA_O1
    exporting
      !OUTPUT type ZEAM_CABOCCREACION_CABECERA_OC
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZEAM_CABOCCO_SAP_CREACION_CABE IMPLEMENTATION.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZEAM_CABOCCO_SAP_CREACION_CABE'
    logical_port_name   = logical_port_name
    destination         = destination
  ).

  endmethod.


  method CREACION_CABECERA_OC.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'INPUT' kind = '0' value = ref #( INPUT ) )
    ( name = 'OUTPUT' kind = '1' value = ref #( OUTPUT ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'CREACION_CABECERA_OC'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.
