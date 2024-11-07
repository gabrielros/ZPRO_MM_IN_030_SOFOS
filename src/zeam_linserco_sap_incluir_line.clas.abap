class ZEAM_LINSERCO_SAP_INCLUIR_LINE definition
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
  methods INCLUIR_LINEA_SERVICIO_OC
    importing
      !INPUT type ZEAM_LINSERINCLUIR_LINEA_SER34
    exporting
      !OUTPUT type ZEAM_LINSERINCLUIR_LINEA_SER33
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZEAM_LINSERCO_SAP_INCLUIR_LINE IMPLEMENTATION.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZEAM_LINSERCO_SAP_INCLUIR_LINE'
    logical_port_name   = logical_port_name
    destination         = destination
  ).

  endmethod.


  method INCLUIR_LINEA_SERVICIO_OC.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'INPUT' kind = '0' value = ref #( INPUT ) )
    ( name = 'OUTPUT' kind = '1' value = ref #( OUTPUT ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'INCLUIR_LINEA_SERVICIO_OC'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.