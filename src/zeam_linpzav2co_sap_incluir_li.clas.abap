class ZEAM_LINPZAV2CO_SAP_INCLUIR_LI definition
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
  methods INCLUIR_LINEA_PIEZA_OC
    importing
      !INPUT type ZEAM_LINPZAV2INCLUIR_LINEA_PI1
    exporting
      !OUTPUT type ZEAM_LINPZAV2INCLUIR_LINEA_PIE
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZEAM_LINPZAV2CO_SAP_INCLUIR_LI IMPLEMENTATION.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZEAM_LINPZAV2CO_SAP_INCLUIR_LI'
    logical_port_name   = logical_port_name
    destination         = destination
  ).

  endmethod.


  method INCLUIR_LINEA_PIEZA_OC.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'INPUT' kind = '0' value = ref #( INPUT ) )
    ( name = 'OUTPUT' kind = '1' value = ref #( OUTPUT ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'INCLUIR_LINEA_PIEZA_OC'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.