class ZCL_MM_SEND_PO_EAM_REPORT definition
  public
  final
  create public .

public section.

  methods START
    importing
      !I_BUKRS type FARR_RT_BUKRS
      !I_BSART type MMPUR_T_BSART
      !I_EBELN type MMPUR_T_EBELN
      !I_AEDAT type RANGE_T_DATS .
  methods SEND_PO_TO_EAM
    importing
      !IM_EBELN type EBELN
      !IM_HEADER type ref to IF_PURCHASE_ORDER_MM
      !I_XML type XSTRING optional
    exporting
      !E_RETURN type BAPIRET2_TAB .
protected section.
private section.

  types:
    BEGIN OF  ty_data,
      icon     TYPE icon_d,
*    INT_TYPE	ZABAPE_INTTYPE
*ID_EXT	ZABAPE_IDEXT
*ID_CPI	ZABAPE_IDCPI
      bukrs    TYPE ekko-bukrs,
      ebeln    TYPE ekko-ebeln,
      bsart    TYPE ekko-bsart,
      aedat    TYPE ekko-aedat,
      data_in  TYPE zabape_intdata,
      data_out TYPE  zabape_intdata,
      status   TYPE  zabape_status,
      datum    TYPE   sydatum,
      uzeit    TYPE   syuzeit,
      uname    TYPE   syuname,


    END OF ty_data .
  types:
    tyt_data TYPE TABLE OF ty_data .
  types:
    BEGIN OF ty_log,
      icon    TYPE icon_d,
      ebeln   TYPE ebeln,
      message TYPE bapi_msg,
    END OF ty_log .
  types:
    tyt_log TYPE TABLE OF ty_log .
  types:
    BEGIN OF ty_eban,
      banfn              TYPE eban-banfn,
      bnfpo              TYPE eban-bnfpo,
      menge              TYPE eban-menge,
      meins              TYPE eban-meins,
      erdat              TYPE eban-erdat,
      purreqndescription TYPE eban-purreqndescription,
      bsart              TYPE eban-bsart,
    END OF ty_eban .
  types:
    BEGIN OF ty_tcurc,
           waers TYPE tcurc-waers,
           isocd TYPE tcurc-isocd,
         END OF ty_tcurc .
  types:
    tyt_tcurc TYPE TABLE OF ty_tcurc .

  data RG_BUKRS type FARR_RT_BUKRS .
  data RG_BSART type MMPUR_T_BSART .
  data RG_EBELN type MMPUR_T_EBELN .
  data RG_AEDAT type RANGE_T_DATS .
  data O_ALV type ref to CL_SALV_TABLE .
  data GT_DATA type TYT_DATA .
  data GT_LOG type TYT_LOG .
  data GT_TCURC type TYT_TCURC .
  constants GC_LABOR type MARA-LABOR value 'OTR' ##NO_TEXT.
  constants GC_ME21N type SY-TCODE value 'ME21N' ##NO_TEXT.
  constants GC_ME22N type SY-TCODE value 'ME22N' ##NO_TEXT.
  constants GC_INTTYPE type ZABAPE_INTTYPE value '013' ##NO_TEXT.
  data GV_COMMIT type XFELD .

  methods SET_VACIO
    importing
      !I_TIPO type CHAR1 default '1'
      !I_FIELD type FIELDNAME optional
      !I_VALUE type PRX_CONTR optional
    changing
      !C_CONTROLLER type PRXCTRLTAB optional
    returning
      value(C_VALUE) type STRING .
  methods CANCEL_LINE
    importing
      !I_HEADER type MEPOHEADER
      !I_ITEM type MEPOITEM
      !I_ORGANIZATIONID type STRING
      !I_EBAN type TY_EBAN
      !I_ITEMS type PURCHASE_ORDER_ITEM
      !I_TIPO type STRING
    returning
      value(R_LINEA) type ZOCEAM_DELITEMCANCELAR_LINEA_1 .
  methods ADD_SERVICE_LINE
    importing
      !I_HEADER type MEPOHEADER
      !I_ITEM type MEPOITEM
      !I_ORGANIZATIONID type STRING
      !I_EBAN type TY_EBAN
      !I_ITEMS type PURCHASE_ORDER_ITEM
    returning
      value(R_LINEA) type ZEAM_LINSERINCLUIR_LINEA_SER34 .
  methods GET_NUMFDEC
    importing
      !I_VALUE type CHAR30
    exporting
      !E_VALUE type STRING
      !E_NUMOFDEC type STRING .
  methods GET_XML_FROM_DATA
    importing
      !ABAP_DATA type ANY
      !DDIC_TYPE type TYPENAME optional
      !EXT_XML type ABAP_BOOL optional
      !XML_HEADER type CSEQUENCE optional
      !ROOT_ELEMENT type QNAME optional
      !SVAR_NAME type PRX_R3NAME optional
    returning
      value(XML) type STRING .
  methods SHOW_LOG .
  methods GET_INSTANCE_PO
    importing
      !I_EBELN type EBELN
    returning
      value(O_HEADER) type ref to IF_PURCHASE_ORDER_MM .
  methods REPROCESS
    importing
      !IT_ROW type SALV_T_ROW .
  methods SHOW_PO
    importing
      !I_DATA type TY_DATA .
  methods GET_DATA .
  methods SHOW_ALV .
  methods HANDLE_USER_COMMAND
    for event ADDED_FUNCTION of CL_SALV_EVENTS
    importing
      !E_SALV_FUNCTION
      !SENDER .
  methods HANDLE_HOTSPOT
    for event LINK_CLICK of CL_SALV_EVENTS_TABLE
    importing
      !ROW
      !SENDER
      !COLUMN .
  methods ADD_PZA_LINE
    importing
      !I_HEADER type MEPOHEADER
      !I_ITEM type MEPOITEM
      !I_ORGANIZATIONID type STRING
      !I_EBAN type TY_EBAN
      !I_ITEMS type PURCHASE_ORDER_ITEM
    returning
      value(R_LINEA) type ZEAM_LINPZAV2INCLUIR_LINEA_PI1 .
ENDCLASS.



CLASS ZCL_MM_SEND_PO_EAM_REPORT IMPLEMENTATION.


  METHOD add_pza_line.
    DATA: lv_menge(30),
          lv_price(30),
          lv_iva(30),
          lv_amount_external TYPE  bapicurr-bapicurr,
          lv_value(30).


    r_linea-purchaseorderlineid-purchaseorderid-purchaseordercode = |{ i_header-ebeln ALPHA = OUT }|. CONDENSE r_linea-purchaseorderlineid-purchaseorderid-purchaseordercode.
    r_linea-purchaseorderlineid-purchaseorderid-organizationid-organizationcode = i_organizationid.
    r_linea-purchaseorderlineid-purchaseorderlinenum = |{ i_item-ebelp ALPHA = OUT }|. CONDENSE r_linea-purchaseorderlineid-purchaseorderlinenum.


    IF i_item-banfn IS NOT INITIAL. " and lv_saltar is INITIAL..
*      SELECT SINGLE banfn, bnfpo, menge, meins, erdat, purreqndescription FROM eban INTO @data(ls_eban) WHERE banfn = @i_item-banfn AND bnfpo = @i_item-bnfpo.

      r_linea-requisitionlineid-requisitionid-requisitioncode       = |{ i_eban-purreqndescription ALPHA = OUT }|. CONDENSE r_linea-requisitionlineid-requisitionid-requisitioncode    .
*      r_linea-requisitionlineid-requisitionid-organizationid-organizationcode = i_organizationid.
      r_linea-requisitionlineid-requisitionlinenum                 = |{ i_item-bnfpo ALPHA = OUT }|. CONDENSE r_linea-requisitionlineid-requisitionlinenum.


      cl_pco_utility=>convert_abap_timestamp_to_java( EXPORTING iv_date      = i_eban-erdat
                                                                iv_time      = sy-uzeit
                                                      IMPORTING ev_timestamp = r_linea-requestduedate-year ).

      r_linea-requestduedate-month     = i_eban-erdat+4(2).
      r_linea-requestduedate-day       = i_eban-erdat+6(2).
      r_linea-requestduedate-hour      = sy-datum(2).
      r_linea-requestduedate-minute    = sy-datum+2(2).
      r_linea-requestduedate-second    = sy-datum+4(2).
      r_linea-requestduedate-subsecond = '0'.
      r_linea-requestduedate-timezone  = '-0500'.
*      r_linea-requestduedate-qualifier = 'OTHER'.



      lv_menge = i_eban-menge. CONDENSE lv_menge.
      me->get_numfdec( EXPORTING i_value    = lv_menge
                       IMPORTING e_value    = r_linea-requestedqty-value
                                 e_numofdec = r_linea-requestedqty-numofdec ).
*                SPLIT lv_menge AT '.' INTO r_linea-requestedqty-value r_linea-requestedqty-value.
      r_linea-requestedqty-sign  = '+'.

      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
        EXPORTING
          input          = i_eban-meins
*         LANGUAGE       = SY-LANGU
        IMPORTING
*         LONG_TEXT      =
          output         = r_linea-requestedqty-uom
*         SHORT_TEXT     =
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.

*      r_linea-requestedqty-qualifier = 'OTHER'.

    ELSE.
*      r_linea-requestedqty-qualifier = 'OTHER'.
*      r_linea-requestduedate-qualifier = 'OTHER'.

      APPEND INITIAL LINE TO r_linea-controller ASSIGNING FIELD-SYMBOL(<controller>).
      <controller>-field = 'REQUISITIONLINEID'.
      <controller>-value = sai_ctrl_none.

      APPEND INITIAL LINE TO r_linea-controller ASSIGNING <controller>.
      <controller>-field = 'REQUESTDUEDATE'.
      <controller>-value = sai_ctrl_none.

      APPEND INITIAL LINE TO r_linea-controller ASSIGNING <controller>.
      <controller>-field = 'REQUESTEDQTY'.
      <controller>-value = sai_ctrl_none.
    ENDIF.

    r_linea-partid-partcode =  |{ i_item-matnr ALPHA = OUT }|. CONDENSE r_linea-partid-partcode .
    r_linea-partid-organizationid-organizationcode = '*'..

    r_linea-purchaseordertype-typecode = 'PS'.
    r_linea-status-statuscode = 'AP'.
*    r_linea-status-status = 'AP'.

    lv_menge = i_item-menge. CONDENSE lv_menge.
    me->get_numfdec( EXPORTING i_value    = lv_menge
                     IMPORTING e_value    = r_linea-purchaseqty-value
                               e_numofdec = r_linea-purchaseqty-numofdec ).

*              SPLIT lv_menge AT '.' INTO r_linea-purchaseqty-value r_linea-purchaseqty-numofdec.
    r_linea-purchaseqty-sign  = '+'.
    r_linea-purchaseqty-uom   = i_item-meins.
*    r_linea-purchaseqty-qualifier = 'OTHER'.

    r_linea-partquantity = r_linea-purchaseqty.

    r_linea-purchaseuom-uomcode = i_item-meins.
*    SELECT SINGLE msehl FROM t006a INTO @r_linea-purchaseuom-description WHERE spras = @sy-langu AND msehi = @i_item-meins.

    r_linea-partuom = r_linea-purchaseuom.

    DATA(lt_sched) = i_items-item->get_schedules( ).
    LOOP AT lt_sched ASSIGNING FIELD-SYMBOL(<sched>).
      DATA(ls_sched) = <sched>-schedule->get_data( ).
    ENDLOOP.

    cl_pco_utility=>convert_abap_timestamp_to_java( EXPORTING iv_date      = ls_sched-eindt
                                                              iv_time      = sy-uzeit
                                                    IMPORTING ev_timestamp = r_linea-duedate-year ).


    r_linea-duedate-month     = ls_sched-eindt+4(2).
    r_linea-duedate-day       = ls_sched-eindt+6(2).
    r_linea-duedate-hour      = sy-datum(2).
    r_linea-duedate-minute    = sy-datum+2(2).
    r_linea-duedate-second    = sy-datum+4(2).
    r_linea-duedate-subsecond = '0'.
    r_linea-duedate-timezone  = '-0500'.
*    r_linea-duedate-qualifier = 'OTHER'.


    i_items-item->get_conditions( IMPORTING ex_conditions = DATA(lt_cond) ).

    READ TABLE lt_cond INTO DATA(ls_cond) WITH KEY kschl = 'ZIV3'.
    IF sy-subrc NE 0.
      READ TABLE lt_cond INTO ls_cond WITH KEY kschl = 'ZIV4'.
    ENDIF.

    IF ls_cond IS NOT INITIAL.
*      APPEND INITIAL LINE TO r_linea-controller ASSIGNING <controller>.
*      <controller>-field = 'TAXID'.
*      <controller>-value = sai_ctrl_none.
*      r_linea-totaltaxamount-qualifier  = 'OTHER'.
*    ELSE.
      r_linea-taxid-taxcode = i_item-mwskz.
      r_linea-taxid-organizationid-organizationcode = '*'.
      "TOTALTAXAMOUNT": { "VALUE": 0, "NUMOFDEC": 0, "SIGN": "+", "CURRENCY": "XXX", "DRCR": "D", "qualifier": "OTHER", "type": null, "index": null

      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
        EXPORTING
          currency        = i_header-waers
          amount_internal = ls_cond-kwert
        IMPORTING
          amount_external = lv_amount_external.

      lv_iva = lv_amount_external. CONDENSE lv_iva.

      me->get_numfdec( EXPORTING i_value    = lv_iva
                       IMPORTING e_value    = DATA(lv_iva_ent)
                                 e_numofdec = r_linea-totaltaxamount-numofdec ).

      r_linea-totaltaxamount-value      = lv_iva_ent.
      r_linea-totaltaxamount-sign       = '+'.
      r_linea-totaltaxamount-currency   =  gt_tcurc[ waers = i_item-waers ]-isocd. . . .
      r_linea-totaltaxamount-drcr       = 'D'.
      r_linea-totaltaxamount-qualifier  = 'OTHER'.

    ELSE.
      r_linea-totaltaxamount-qualifier  = 'OTHER'.
    ENDIF.

    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
      EXPORTING
        currency        = i_header-waers
        amount_internal = i_item-netpr
      IMPORTING
        amount_external = lv_amount_external.

    lv_price = lv_amount_external. CONDENSE lv_price.

    me->get_numfdec( EXPORTING i_value    = lv_price
                     IMPORTING e_value    = DATA(lv_price_ent)
                               e_numofdec = r_linea-price-numofdec ).

    r_linea-price-value = lv_price_ent.

*              SPLIT lv_price AT '.' INTO lv_price_ent r_linea-price-numofdec.
*              r_linea-price-value = lv_price_ent.
    r_linea-price-sign = '+'.
    r_linea-price-currency =  gt_tcurc[ waers = i_item-waers ]-isocd. . . .
    r_linea-price-drcr = 'D'.
*    r_linea-price-qualifier = 'OTHER'.
*              r_linea-price-type = 'null'.
*              r_linea-price-index = 'null'.

    r_linea-currencyid-currencycode = gt_tcurc[ waers = i_item-waers ]-isocd. . . . .

    IF i_header-wkurs IS NOT INITIAL.
      lv_value = i_header-wkurs. CONDENSE lv_value.
      me->get_numfdec( EXPORTING i_value    = lv_value
                       IMPORTING e_value    = r_linea-exchrate-value
                                 e_numofdec = r_linea-exchrate-numofdec ).

*                SPLIT lv_value AT '.' INTO r_linea-exchrate-value r_linea-exchrate-numofdec.
      r_linea-exchrate-sign  = '+'.
      r_linea-exchrate-uom   = 'default'.
*      r_linea-exchrate-qualifier = 'OTHER'.
    ELSE.
      APPEND INITIAL LINE TO r_linea-controller ASSIGNING <controller>.
      <controller>-field = 'EXCHRATE'.
      <controller>-value = sai_ctrl_none.
    ENDIF.


    DATA(lt_accounts) = i_items-item->get_accountings( ).
    IF lt_accounts IS NOT INITIAL.
      LOOP AT lt_accounts ASSIGNING FIELD-SYMBOL(<ls_accounts>).
        DATA(ls_data_acc) = <ls_accounts>-accounting->get_data( ).
        IF ls_data_acc-kostl IS NOT INITIAL.
          ls_data_acc = <ls_accounts>-accounting->get_data( ).
          r_linea-costcodeid-costcode = ls_data_acc-kostl.
*          r_linea-costcodeid-organizationid-organizationcode = i_organizationid.
        ELSE.
          APPEND INITIAL LINE TO r_linea-controller ASSIGNING <controller>.
          <controller>-field = 'COSTCODEID'.
          <controller>-value = sai_ctrl_none.
        ENDIF.
        IF ls_data_acc-sakto IS NOT INITIAL.
          r_linea-user_defined_fiels-udfchar10 = ls_data_acc-sakto.
        ELSE.
          r_linea-user_defined_fiels-udfchar10 = set_vacio( )..
        ENDIF.

      ENDLOOP.
    ELSE.
      APPEND INITIAL LINE TO r_linea-controller ASSIGNING <controller>.
      <controller>-field = 'COSTCODEID'.
      <controller>-value = sai_ctrl_none.
    ENDIF.


    r_linea-conversionfactor-value     = i_item-umren. CONDENSE r_linea-conversionfactor-value.
    r_linea-conversionfactor-numofdec  = 0. " i_item-umrez.
    r_linea-conversionfactor-sign      = '+'.
    r_linea-conversionfactor-currency  = gt_tcurc[ waers = i_header-waers ]-isocd.
    r_linea-conversionfactor-drcr      = 'D'.
*    r_linea-conversionfactor-qualifier = 'OTHER'.
*r_linea-conversionfactor-TYPE      = i_item-
*r_linea-conversionfactor-INDEX     = i_item-

*    r_linea-recordid = 0.
*    r_linea-addplannedwopart = 'false'.

**********************************************************************
    r_linea-activityid-workorderid-jobnum = me->set_vacio( EXPORTING i_tipo = '2' i_field = 'ACTIVITYID' i_value = sai_ctrl_none CHANGING c_controller = r_linea-controller ).
*    r_linea-activityid-activitycode-value = me->set_vacio( EXPORTING i_tipo = '2' i_field = 'VALUE' i_value = sai_ctrl_initial CHANGING c_controller  = r_linea-activityid-activitycode-controller ).
**********************************************************************
  ENDMETHOD.


  METHOD add_service_line.
    DATA: lv_menge(30),
          lv_price(30),
          lv_total(30),
          lv_iva(30),
          lv_amount_external TYPE  bapicurr-bapicurr,
          lv_value(30).


    r_linea-purchaseorderlineid-purchaseorderid-purchaseordercode = i_header-ebeln.
    r_linea-purchaseorderlineid-purchaseorderid-organizationid-organizationcode = i_organizationid.
    r_linea-purchaseorderlineid-purchaseorderlinenum = |{ i_item-ebelp ALPHA = OUT }|. CONDENSE r_linea-purchaseorderlineid-purchaseorderlinenum.


    IF i_item-banfn IS NOT INITIAL.
*                  SELECT SINGLE banfn, bnfpo, menge, meins, erdat, purreqndescription FROM eban INTO @DATA(ls_eban) WHERE banfn = @i_item-banfn AND bnfpo = @i_item-bnfpo.

      r_linea-requisitionlineid-requisitionid-requisitioncode       = |{ i_eban-purreqndescription ALPHA = OUT }|.. CONDENSE r_linea-requisitionlineid-requisitionid-requisitioncode.
      r_linea-purchaseorderlineid-purchaseorderid-organizationid-organizationcode = i_organizationid.
      r_linea-requisitionlineid-requisitionlinenum                 = |{ i_item-bnfpo ALPHA = OUT }|. CONDENSE r_linea-requisitionlineid-requisitionlinenum  .

    ELSE.
      APPEND INITIAL LINE TO r_linea-controller ASSIGNING FIELD-SYMBOL(<controller>).
      <controller>-field = 'REQUISITIONLINEID'.
      <controller>-value = sai_ctrl_none.

      APPEND INITIAL LINE TO r_linea-controller ASSIGNING <controller>.
      <controller>-field = 'REQUESTDUEDATE'.
      <controller>-value = sai_ctrl_none.

      APPEND INITIAL LINE TO r_linea-controller ASSIGNING <controller>.
      <controller>-field = 'REQUESTEDQTY'.
      <controller>-value = sai_ctrl_none.
    ENDIF.

    cl_pco_utility=>convert_abap_timestamp_to_java( EXPORTING iv_date      = i_header-aedat
                                                              iv_time      = sy-uzeit
                                                    IMPORTING ev_timestamp = r_linea-daterequired-year ).

    r_linea-daterequired-month     = i_header-aedat+4(2).
    r_linea-daterequired-day       = i_header-aedat+6(2).
    r_linea-daterequired-hour      = sy-datum(2).
    r_linea-daterequired-minute    = sy-datum+2(2).
    r_linea-daterequired-second    = sy-datum+4(2).
    r_linea-daterequired-subsecond = '0'.
    r_linea-daterequired-timezone  = '-0500'.
*    r_linea-daterequired-qualifier = 'OTHER'.


    APPEND INITIAL LINE TO r_linea-controller ASSIGNING <controller>.
    <controller>-field = 'TRADEID'.
    <controller>-value = '1'.

*    r_linea-tradeid-tradecode = |{ i_item-matnr ALPHA = OUT }|. CONDENSE r_linea-tradeid-tradecode.
*    r_linea-tasklistid-taskcode = |{ i_item-matnr ALPHA = OUT }|. CONDENSE   r_linea-tasklistid-taskcode.
*              r_linea-partid-organizationid-organizationcode = lv_organizationid.

    i_items-item->if_longtexts_mm~get_text( EXPORTING im_tdid      = 'F04'
                                            IMPORTING ex_textlines = DATA(lt_text) ).

    IF lt_text IS NOT INITIAL .
      TRY.
          r_linea-activityid-workorderid-jobnum = lt_text[ 1 ]-tdline. CONDENSE r_linea-activityid-workorderid-jobnum.
        CATCH cx_root.

      ENDTRY.
    ENDIF.

    r_linea-activityid-activitycode-value = '40'.

    CLEAR lt_text.
    i_items-item->if_longtexts_mm~get_text( EXPORTING im_tdid      = 'F01'
                                            IMPORTING ex_textlines = lt_text ).

    IF lt_text IS NOT INITIAL .
      TRY.
          r_linea-tasklistid-taskcode = lt_text[ 1 ]-tdline. CONDENSE r_linea-tasklistid-taskcode .
          r_linea-tasklistid-taskrevision = '0'.
        CATCH cx_root.

      ENDTRY.
    ENDIF.

    r_linea-type-typecode = 'SF'.
    r_linea-status-statuscode =  'AP'.

    lv_menge = i_item-menge. CONDENSE lv_menge.
    me->get_numfdec( EXPORTING i_value    = lv_menge
                     IMPORTING e_value    = r_linea-hoursrequested-value
                               e_numofdec = r_linea-hoursrequested-numofdec ).

    r_linea-hoursrequested-sign  = '+'.
    r_linea-hoursrequested-uom   = i_item-meins.
    r_linea-hoursrequested-qualifier = 'OTHER'.

*              ls_input_pza-purchaseuom-uomcode = i_item-meins.
*              SELECT SINGLE msehl FROM t006a INTO @ls_input_pza-purchaseuom-description WHERE spras = @sy-langu AND msehi = @i_item-meins.

    DATA(lt_sched) = i_items-item->get_schedules( ).
    LOOP AT lt_sched ASSIGNING FIELD-SYMBOL(<sched>).
      DATA(ls_sched) = <sched>-schedule->get_data( ).
    ENDLOOP.

    cl_pco_utility=>convert_abap_timestamp_to_java( EXPORTING iv_date      = ls_sched-eindt
                                                              iv_time      = sy-uzeit
                                                    IMPORTING ev_timestamp = r_linea-duedate-year ).


    r_linea-duedate-month     = ls_sched-eindt+4(2).
    r_linea-duedate-day       = ls_sched-eindt+6(2).
    r_linea-duedate-hour      = sy-datum(2).
    r_linea-duedate-minute    = sy-datum+2(2).
    r_linea-duedate-second    = sy-datum+4(2).
    r_linea-duedate-subsecond = '0'.
    r_linea-duedate-timezone  = '-0500'.
*    r_linea-duedate-qualifier = 'OTHER'.

    r_linea-porstatus = 'AP'.
    i_items-item->get_conditions( IMPORTING ex_conditions = DATA(lt_cond) ).

    READ TABLE lt_cond INTO DATA(ls_cond) WITH KEY kschl = 'ZIV3'.
    IF sy-subrc NE 0.
      READ TABLE lt_cond INTO ls_cond WITH KEY kschl = 'ZIV4'.
    ENDIF.


    IF ls_cond IS NOT INITIAL.
*      APPEND INITIAL LINE TO r_linea-controller ASSIGNING <controller>.
*      <controller>-field = 'TAXID'.
*      <controller>-value = sai_ctrl_none.
*      r_linea-totaltaxamount-qualifier  = 'OTHER'.
*    ELSE.
      r_linea-taxid-taxcode = i_item-mwskz.
*      r_linea-taxid-organizationid-organizationcode = '*'.
      "TOTALTAXAMOUNT": { "VALUE": 0, "NUMOFDEC": 0, "SIGN": "+", "CURRENCY": "XXX", "DRCR": "D", "qualifier": "OTHER", "type": null, "index": null

      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
        EXPORTING
          currency        = i_header-waers
          amount_internal = ls_cond-kwert
        IMPORTING
          amount_external = lv_amount_external.

      lv_iva = lv_amount_external. CONDENSE lv_iva.

*      me->get_numfdec( EXPORTING i_value    = lv_iva
*                       IMPORTING e_value    = DATA(lv_iva_ent)
*                                 e_numofdec = r_linea-totaltaxamount-numofdec ).
*
*      r_linea-totaltaxamount-value      = lv_iva_ent.
*      r_linea-totaltaxamount-sign       = '+'.
*      r_linea-totaltaxamount-currency   =  gt_tcurc[ waers = i_item-waers ]-isocd. . . .
*      r_linea-totaltaxamount-drcr       = 'D'.
*      r_linea-totaltaxamount-qualifier  = 'OTHER'.

    ELSE.
*      r_linea-totaltaxamount-qualifier  = 'OTHER'.
    ENDIF.


    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
      EXPORTING
        currency        = i_header-waers
        amount_internal = i_item-netpr
      IMPORTING
        amount_external = lv_amount_external.

    lv_price = lv_amount_external. CONDENSE lv_price.


    me->get_numfdec( EXPORTING i_value    = lv_price
                     IMPORTING e_value    = r_linea-price-value
                               e_numofdec = r_linea-price-numofdec ).

    r_linea-price-sign = '+'.
    r_linea-price-currency = gt_tcurc[ waers = i_header-waers ]-isocd. .
    r_linea-price-drcr = 'D'.
    r_linea-price-qualifier = 'OTHER'.
*    r_linea-price-type = 'null'.
*    r_linea-price-index = 'null'.

    r_linea-currencyid-currencycode = gt_tcurc[ waers = i_item-waers ]-isocd. . .
**********************************************************************
    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
      EXPORTING
        currency        = i_header-waers
        amount_internal = i_item-netwr
      IMPORTING
        amount_external = lv_amount_external.

    lv_total = lv_amount_external. CONDENSE lv_total.

    me->get_numfdec( EXPORTING i_value    = lv_total
                     IMPORTING e_value    = r_linea-servicetotal-value
                               e_numofdec = r_linea-servicetotal-numofdec ).

    r_linea-servicetotal-sign = '+'.
    r_linea-servicetotal-currency = gt_tcurc[ waers = i_header-waers ]-isocd. .
    r_linea-servicetotal-drcr = 'D'.
    r_linea-servicetotal-qualifier = 'OTHER'.
*    r_linea-servicetotal-type = 'null'.
*    r_linea-servicetotal-index = 'null'.
**********************************************************************
*TASKQUANTITY

    lv_menge = i_eban-menge. CONDENSE lv_menge.
    me->get_numfdec( EXPORTING i_value    = lv_menge
                     IMPORTING e_value    = r_linea-taskquantity-value
                               e_numofdec = r_linea-taskquantity-numofdec ).
*                SPLIT lv_menge AT '.' INTO r_linea-requestedqty-value r_linea-requestedqty-value.
    r_linea-taskquantity-sign  = '+'.
    r_linea-taskquantity-qualifier = 'OTHER'.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input          = i_eban-meins
*       LANGUAGE       = SY-LANGU
      IMPORTING
*       LONG_TEXT      =
        output         = r_linea-taskquantity-uom
*       SHORT_TEXT     =
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.
**********************************************************************

    lv_value = i_header-wkurs. CONDENSE lv_value.
    SPLIT lv_value AT '.' INTO r_linea-exchrate-value r_linea-exchrate-numofdec.
    r_linea-exchrate-sign  = '+'.
    r_linea-exchrate-uom   = 'default'.
*    r_linea-exchrate-qualifier = 'OTHER'.
    r_linea-taxid-taxcode = i_item-mwskz.

    DATA(lt_accounts) = i_items-item->get_accountings( ).
    LOOP AT lt_accounts ASSIGNING FIELD-SYMBOL(<ls_accounts>).
      DATA(ls_data_acc) = <ls_accounts>-accounting->get_data( ).
      r_linea-costcodeid-costcode = ls_data_acc-kostl.
*      r_linea-costcodeid-organizationid-organizationcode = I_ORGANIZATIONID.
    ENDLOOP.

**********************************************************************
*ACCOUNTDETAIL": { "VALUE": 34616120, "NUMOFDEC": 1, "SIGN": "+",  "UOM": "default", "qualifier": "OTHER"
    r_linea-accountdetail-value = ls_data_acc-sakto.
    r_linea-accountdetail-numofdec = '1'.
    r_linea-accountdetail-sign =  '+'.
    r_linea-accountdetail-uom =  'default'.
    r_linea-accountdetail-qualifier =  'OTHER'.
**********************************************************************
*              ls_input_pza-recordid = 0.
*              ls_input_pza-addplannedwopart = 'false'.

*    APPEND INITIAL LINE TO ls_data-linea_servicio ASSIGNING FIELD-SYMBOL(<ws_ser>).
*    <ws_ser>-index = lv_tabix.
*    <ws_ser>-data = me->get_xml_from_data( abap_data  = r_linea
*                                           ddic_type  = 'ZEAM_LINSERINCLUIR_LINEA_SER34'
*                                           xml_header = 'full' ).

*    APPEND r_linea TO lt_input_ser.
  ENDMETHOD.


  METHOD cancel_line.
    r_linea-purchaseorderlineid-purchaseorderid-organizationid-organizationcode = i_organizationid.
    r_linea-purchaseorderlineid-purchaseorderid-purchaseordercode = i_header-ebeln.
    r_linea-purchaseorderlineid-purchaseorderlinenum = |{ i_item-bnfpo ALPHA = OUT }|. CONDENSE r_linea-purchaseorderlineid-purchaseorderlinenum.
    r_linea-status-statuscode = 'C'.
    r_linea-tipo = i_tipo.

    r_linea-info_alert          = zcl_34_utility=>set_vacio( ).
    r_linea-warning_alert       = zcl_34_utility=>set_vacio( ).
    r_linea-confirmation_alert  = zcl_34_utility=>set_vacio( ).

APPEND INITIAL LINE TO r_linea-error_alert ASSIGNING FIELD-SYMBOL(<error>).

  ENDMETHOD.


  METHOD get_data.
*      icon     TYPE icon_d,
**    INT_TYPE  ZABAPE_INTTYPE
**ID_EXT  ZABAPE_IDEXT
**ID_CPI  ZABAPE_IDCPI
*      bukrs    type ekko-bukrs,
*      ebeln    TYPE ekko-ebeln,
*      bsart    type ekko-bsart,
*      aedat    type ekko-aedat,
*      data_in  TYPE zabape_intdata,
*      data_out TYPE  zabape_intdata,
*      status   TYPE  zabape_status,
*      datum    TYPE   sydatum,
*      uzeit    TYPE   syuzeit,
*      uname    TYPE   syuname,

    SELECT CASE z~status WHEN 'P' THEN '@08@'
                         WHEN 'E' THEN '@0A@' END AS icon,
    e~bukrs, e~ebeln, e~bsart, e~aedat, z~data_in, z~data_out, z~status, z~datum, z~uzeit, z~uname
    FROM zabap_intlog01 AS z
    INNER JOIN ekko AS e ON e~ebeln = z~id_ext
    WHERE z~int_type = @gc_inttype
      AND datum IN @rg_aedat
      AND bsart IN @rg_bsart
      AND id_ext IN @rg_ebeln INTO TABLE @gt_data..



  ENDMETHOD.


  METHOD GET_INSTANCE_PO.
    DATA: gs_document TYPE mepo_document,
          go_po       TYPE REF TO cl_po_header_handle_mm,
          gs_header   TYPE mepoheader,
          gd_tcode    TYPE sy-tcode,
          gd_result   TYPE mmpur_bool.

*  prepare creation of PO instance
    gs_document-doc_type    = 'F'.
    gs_document-process     = mmpur_po_process.
    gs_document-trtyp       = 'A'.  " anz.  => display
    gs_document-doc_key(10) = i_ebeln.

    CREATE OBJECT go_po.
    CALL METHOD go_po->po_initialize( im_document = gs_document ).
    CALL METHOD go_po->set_po_number( im_po_number = i_ebeln ).
    CALL METHOD go_po->set_state( cl_po_header_handle_mm=>c_available ).

    gd_tcode = 'ME22N'.
    CALL METHOD go_po->po_read
      EXPORTING
        im_tcode     = gd_tcode
        im_trtyp     = gs_document-trtyp
        im_aktyp     = gs_document-trtyp
        im_po_number = i_ebeln
        im_document  = gs_document
      IMPORTING
        ex_result    = gd_result.

    o_header = go_po.
  ENDMETHOD.


  METHOD get_numfdec.

    SPLIT I_VALUE AT '.' INTO DATA(lv_ent) DATA(lv_dec).
    e_value = |{ lv_ent }{ lv_dec }|. CONDENSE e_value.
    e_numofdec = strlen( lv_dec ).
    CONDENSE e_numofdec.

  ENDMETHOD.


  METHOD get_xml_from_data.
    TRY.
        DATA(lv_xxml) = cl_proxy_xml_transform=>abap_to_xml_xstring(
          abap_data  = abap_data
          ddic_type  = ddic_type
          xml_header = xml_header ).

        CALL FUNCTION 'SSFH_XSTRINGUTF8_TO_STRING'
          EXPORTING
            ostr_output_data = lv_xxml
*           CODEPAGE         = '4110'
          IMPORTING
            cstr_output_data = xml
          EXCEPTIONS
            conversion_error = 1
            internal_error   = 2
            OTHERS           = 3.

      CATCH cx_root INTO DATA(o_error).
    ENDTRY.
  ENDMETHOD.


  method HANDLE_HOTSPOT.

    CASE column.
      WHEN 'EBELN'.
        TRY.
            DATA(ls_data) = gt_data[ row ].
            IF ls_data-ebeln IS NOT INITIAL.
              me->show_po( ls_data ).
            ENDIF.
          CATCH cx_root.
        ENDTRY.



      WHEN OTHERS.
    ENDCASE.


  endmethod.


  METHOD handle_user_command.
    DATA(lt_sel) = o_alv->get_selections( )..

    CASE e_salv_function.
      WHEN 'SHOW_XML'.
        IF lt_sel IS NOT INITIAL.
          DATA(lt_row) = lt_sel->get_selected_rows( ).
          IF lines( lt_row ) = 1.
            LOOP AT lt_row ASSIGNING FIELD-SYMBOL(<row>).
              TRY.
                  DATA(ls_data) = gt_data[ <row> ].
                  cl_abap_browser=>show_xml( EXPORTING xml_xstring = ls_data-data_in  ).
                CATCH cx_root.
              ENDTRY.
            ENDLOOP.
          ELSE.
            MESSAGE i001(zmm_aries).
          ENDIF.
        ENDIF.
      WHEN 'SHOW_LOG'.
        IF lt_sel IS NOT INITIAL.
          lt_row = lt_sel->get_selected_rows( ).
          IF lines( lt_row ) = 1.
            LOOP AT lt_row ASSIGNING <row>.
              TRY.
                  ls_data = gt_data[ <row> ].
                  cl_abap_browser=>show_xml( EXPORTING xml_xstring = ls_data-data_out  ).
*                  cl_abap_browser=>show_html( html_xstring = ls_data-data_out context_menu = abap_true ).,
                CATCH cx_root.
              ENDTRY.
            ENDLOOP.
          ELSE.
            MESSAGE i001(zmm_aries).
          ENDIF.
        ENDIF.

      WHEN 'GEN'.
        CLEAR: gt_log.
        BREAK abap06.

        IF lt_sel IS NOT INITIAL.
          lt_row = lt_sel->get_selected_rows( ).
          me->reprocess( lt_row ).
          IF gt_log IS NOT INITIAL.
            me->show_log( ).
          ENDIF.

        ENDIF.

    ENDCASE.
  ENDMETHOD.


  METHOD reprocess.
    LOOP AT it_row ASSIGNING FIELD-SYMBOL(<row>).
      TRY.
          DATA(ls_data) = gt_data[ <row> ].
          IF ls_data-icon = icon_red_light.
            DATA(lv_exec) = abap_true.
            DATA(o_header) = me->get_instance_po( ls_data-ebeln ).
            gv_commit = abap_true.
            me->send_po_to_eam( EXPORTING im_ebeln  = ls_data-ebeln
                                          im_header = o_header
                                          i_xml     = ls_data-data_in
                                IMPORTING e_return  = DATA(lt_return) ).

            LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<return>).
              APPEND INITIAL LINE TO gt_log ASSIGNING FIELD-SYMBOL(<log>).
              <log>-ebeln = ls_data-ebeln.
              <log>-message = <return>-message.
              CASE <return>-type.
                WHEN 'E'.
                  <log>-icon = icon_red_light.
                WHEN 'S'.
                  <log>-icon = icon_green_light.
                WHEN OTHERS.
              ENDCASE.
            ENDLOOP.
          ENDIF.
        CATCH cx_root.
      ENDTRY.
    ENDLOOP.
    IF lv_exec IS INITIAL.
      MESSAGE i000(zmm_aries).
    ENDIF.
  ENDMETHOD.


  METHOD send_po_to_eam.
    DATA: lv_type            TYPE  zabape_inttype,
          lv_idext           TYPE  zabape_idext,
          lv_idcpi           TYPE  zabape_idcpi,
          lv_data            TYPE  string,
          lv_dataout         TYPE  string,
          i_step             TYPE  numc2,
          lt_return          TYPE TABLE OF bapiret2,
          o_po_cab           TYPE REF TO zeam_cabocco_sap_creacion_cabe,
          o_po_pza           TYPE REF TO zeam_linpzav2co_sap_incluir_li, "zeam_linpzaco_sap_incluir_line,
          o_po_ser           TYPE REF TO zeam_linserco_sap_incluir_line,
          ls_input_cab       TYPE zeam_caboccreacion_cabecera_o1,
          ls_input_pza       TYPE zeam_linpzav2incluir_linea_pi1, "zeam_linpzaincluir_linea_pie32,
          lt_input_pza       TYPE TABLE OF zeam_linpzav2incluir_linea_pi1, "zeam_linpzaincluir_linea_pie32,
          ls_input_ser       TYPE zeam_linserincluir_linea_ser34,
          lt_input_ser       TYPE TABLE OF zeam_linserincluir_linea_ser34,
          ls_output_cab      TYPE zeam_caboccreacion_cabecera_oc,
          lt_output_pza	     TYPE TABLE OF zeam_linpzaincluir_linea_pie31,
          o_po_canc          TYPE REF TO zoceam_delitemco_sap_cancelar,
          ls_input_canc      TYPE zoceam_delitemcancelar_linea_1,
          lt_input_canc      TYPE TABLE OF zoceam_delitemcancelar_linea_1,
          ls_output_canc     TYPE zoceam_delitemcancelar_linea_r,
          lt_output_canc     TYPE TABLE OF zoceam_delitemcancelar_linea_r,
          lt_log             TYPE ztt_mm_eam_data03,
          lr_mtart_ser       TYPE RANGE OF mtart,
          lv_menge(30),
          lv_price(30),
          lv_value(30),
          lv_organizationid  TYPE string,
          ls_data            TYPE zsrt_mm_eam_data01,
          ls_data_old        TYPE zsrt_mm_eam_data01,
          lr_bsart           TYPE RANGE OF ekko-bsart,
          lv_amount_external TYPE  bapicurr-bapicurr,
          lv_ebelp type ekpo-ebelp.

*          ls_input     TYPE zenvioordencompraenvio_orden_1,
*          ls_output    TYPE zenvioordencompraenvio_orden_c,
*          ls_input_old TYPE zenvioordencompraenvio_orden_1.

*    CHECK sy-uname EQ 'ABAP06'.

    DATA lo_payload_protocol TYPE REF TO if_wsprotocol_payload. "payload Interface
    BREAK abap06.

    DATA(lt_items)  = im_header->get_items( ).
    DATA(ls_header) = im_header->get_data( ).

    SELECT 'I', 'EQ', bsart FROM zmmt_inteam02 INTO TABLE @lr_bsart.

    IF ls_header-bsart IN lr_bsart. " = 'ZEAM' OR ls_header-bsart = 'ZEXT'.

**********************************************************************
      SELECT SINGLE int_type, id_ext, id_cpi, data_in, data_out, status, datum, uzeit, uname FROM zabap_intlog01
      WHERE int_type = @gc_inttype
        AND id_ext   = @im_ebeln INTO @DATA(ls_intlog01).
      IF sy-subrc EQ 0.
        CALL TRANSFORMATION id SOURCE XML ls_intlog01-data_in RESULT table = ls_data_old .
      ENDIF.

**********************************************************************

**********************************************************************
*PRUEBAS
      DATA(lv_saltar) = abap_true.

**********************************************************************
      TRY.
          DATA(ls_items) = lt_items[ 1 ].
          DATA(ls_item) = ls_items-item->get_data( ).
          IF ls_item-lgort IS INITIAL.
            ls_item-lgort = 'R009'.
          ENDIF.
          lv_organizationid = ls_item-werks.

          DATA(lt_sched) = ls_items-item->get_schedules( ).
          LOOP AT lt_sched ASSIGNING FIELD-SYMBOL(<sched>).
            DATA(ls_sched) = <sched>-schedule->get_data( ).
          ENDLOOP.
        CATCH cx_root.
      ENDTRY.

      SELECT waers, isocd FROM tcurc INTO TABLE @gt_tcurc.

      SELECT 'I', 'EQ', mtart FROM zmmt_inteam01 INTO TABLE @lr_mtart_ser.
      IF sy-subrc NE 0.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = 'Z104' ) TO lr_mtart_ser.
      ENDIF.

*Cabecera
      TRY.
*ls_input_Cab-METODO
          ls_input_cab-metodo = 'POST'.
          ls_input_cab-purchaseorderid-purchaseordercode = ls_header-ebeln.
          ls_input_cab-purchaseorderid-organizationid-organizationcode = lv_organizationid.

          im_header->if_longtexts_mm~get_text( EXPORTING im_tdid      = 'F01'
                                               IMPORTING ex_textlines = DATA(lt_text_cab) ).

          IF lt_text_cab IS NOT INITIAL .
            TRY.
                ls_input_cab-purchaseorderid-description = lt_text_cab[ 1 ]-tdline. CONDENSE ls_input_cab-purchaseorderid-description.
              CATCH cx_root.
            ENDTRY.
          ELSE.
            ls_input_cab-purchaseorderid-description = ls_header-ebeln. CONDENSE ls_input_cab-purchaseorderid-description.
          ENDIF.

          ls_input_cab-supplierid-suppliercode = |{ ls_header-lifnr ALPHA = OUT } |.. CONDENSE ls_input_cab-supplierid-suppliercode.
          ls_input_cab-supplierid-organizationid-organizationcode = '*'.
          ls_input_cab-originator-personcode    = ls_header-ernam.
          ls_input_cab-currencycode             = gt_tcurc[ waers = ls_header-waers ]-isocd.
          ls_input_cab-status-statuscode        = 'U'.
          ls_input_cab-storeid-storecode        = ls_item-lgort.
          ls_input_cab-storeid-organizationid-organizationcode = lv_organizationid.

*

*          ls_input_cab-orderdate-year   = ls_header-aedat(4).

          cl_pco_utility=>convert_abap_timestamp_to_java( EXPORTING iv_date      = ls_header-aedat
                                                                    iv_time      = sy-uzeit
                                                          IMPORTING ev_timestamp = ls_input_cab-orderdate-year ).

          ls_input_cab-orderdate-month  = ls_header-aedat+4(2).
          ls_input_cab-orderdate-day    = ls_header-aedat+6(2).
          ls_input_cab-orderdate-hour   = '0'. "ls_header-AEDAT(4).
          ls_input_cab-orderdate-minute = '0'. "ls_header-AEDAT(4).
          ls_input_cab-orderdate-second = '0'. "ls_header-AEDAT(4).
          ls_input_cab-orderdate-subsecond = '0'.
          ls_input_cab-orderdate-qualifier  = 'ACCOUNTING'.
          ls_input_cab-orderdate-timezone   = 'TIMEZONE5'.

          cl_pco_utility=>convert_abap_timestamp_to_java( EXPORTING iv_date      = ls_sched-eindt
                                                                    iv_time      = sy-uzeit
                                                          IMPORTING ev_timestamp = ls_input_cab-duedate-year ).

          ls_input_cab-duedate-month     = ls_sched-eindt+4(2).
          ls_input_cab-duedate-day       = ls_sched-eindt+6(2).
          ls_input_cab-duedate-hour      = sy-datum(2).
          ls_input_cab-duedate-minute    = sy-datum+2(2).
          ls_input_cab-duedate-second    = sy-datum+4(2).
          ls_input_cab-duedate-subsecond = '0'.
          ls_input_cab-duedate-timezone  = '-0500'.
          ls_input_cab-duedate-qualifier = 'OTHER'.

*                ls_input_cab-duedate = ls_input_pza-requestduedate.

          ls_input_cab-type-typecode = 'P'.
*"VALUE": 2, "NUMOFDEC": 0, "SIGN": "+", "UOM": "default", "qualifier": "OTHER"
          ls_input_cab-user_defined_fields-udfnum01-value     = lines( lt_items ).
          ls_input_cab-user_defined_fields-udfnum01-numofdec  = '0'.
          ls_input_cab-user_defined_fields-udfnum01-sign      = '+'.
          ls_input_cab-user_defined_fields-udfnum01-uom       = 'default'.
          ls_input_cab-user_defined_fields-udfnum01-qualifier = 'OTHER'.

          ls_input_cab-recordid = '0'..
          ls_input_cab-autoid   = 'false'.
          ls_input_cab-is_batchpo = 'true'.

          ls_data-cabecera = me->get_xml_from_data( abap_data  = ls_input_cab
                                                    ddic_type  = 'ZEAM_CABOCCREACION_CABECERA_O1'
                                                    xml_header = 'full' ).


*Posicion
          LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<items>).
            DATA(lv_tabix) = sy-tabix.
            ls_item           = <items>-item->get_data( ).

*            <items>-item->get_previous_data( IMPORTING ex_data = DATA(ls_item_old) ).

            SELECT SINGLE banfn, bnfpo, menge, meins, erdat, purreqndescription, bsart FROM eban INTO @DATA(ls_eban)
            WHERE banfn = @ls_item-banfn
              AND bnfpo = @ls_item-bnfpo.
*            SELECT SINGLE bsart FROM eban INTO @DATA(lv_eban_bsart) WHERE banfn = @ls_item-banfn.
            IF ls_eban-bsart = 'ZEAM'.
              SELECT SINGLE matnr, mtart FROM mara INTO @DATA(ls_mara) WHERE matnr = @ls_item-matnr.

              IF ls_mara-mtart IN lr_mtart_ser. "Servicios
                IF ls_item-loekz IS INITIAL.
                  ls_input_ser = me->add_service_line( i_header         = ls_header
                                                       i_item           = ls_item
                                                       i_items          = <items>
                                                       i_eban           = ls_eban
                                                       i_organizationid = lv_organizationid ).

                  APPEND INITIAL LINE TO ls_data-linea_servicio ASSIGNING FIELD-SYMBOL(<ws_ser>).
                  <ws_ser>-index = lv_tabix.
                  <ws_ser>-data = me->get_xml_from_data( abap_data  = ls_input_ser
                                                         ddic_type  = 'ZEAM_LINSERINCLUIR_LINEA_SER34'
                                                         xml_header = 'full' ).
                  APPEND ls_input_ser TO lt_input_ser.
                ELSE.
                  ls_input_canc = me->cancel_line( i_header         = ls_header
                                                   i_item           = ls_item
                                                   i_items          = <items>
                                                   i_eban           = ls_eban
                                                   i_tipo           = 'S'
                                                   i_organizationid = lv_organizationid ).

                  APPEND INITIAL LINE TO ls_data-linea_canc ASSIGNING FIELD-SYMBOL(<ws_canc>).
                  <ws_canc>-index = lv_tabix.
                  <ws_canc>-ebelp = ls_item-ebelp.
                  <ws_canc>-data = me->get_xml_from_data( abap_data  = ls_input_canc
                                                          ddic_type  = 'ZOCEAM_DELITEMCANCELAR_LINEA_1'
                                                          xml_header = 'full' ).
                  <ws_canc>-del = abap_true.
                  APPEND ls_input_canc TO lt_input_canc .

                ENDIF.



              ELSE. "pza
                IF ls_item-loekz IS INITIAL.
                  ls_input_pza = me->add_pza_line( i_header         = ls_header
                                                   i_item           = ls_item
                                                   i_items          = <items>
                                                   i_eban           = ls_eban
                                                   i_organizationid = lv_organizationid ).

                  APPEND INITIAL LINE TO ls_data-linea_pieza ASSIGNING FIELD-SYMBOL(<ws_pza>).
                  <ws_pza>-index = lv_tabix.
                  <ws_pza>-data = me->get_xml_from_data( abap_data  = ls_input_pza
*                                                         ddic_type  = 'ZEAM_LINPZAINCLUIR_LINEA_PIE32'
                                                         ddic_type  = 'ZEAM_LINPZAV2INCLUIR_LINEA_PI1'
                                                         xml_header = 'full' ).

                  APPEND ls_input_pza TO lt_input_pza.
                ELSE.
                  ls_input_canc = me->cancel_line( i_header         = ls_header
                                                   i_item           = ls_item
                                                   i_items          = <items>
                                                   i_eban           = ls_eban
                                                   i_tipo           = 'P'
                                                   i_organizationid = lv_organizationid ).

                  APPEND INITIAL LINE TO ls_data-linea_canc ASSIGNING <ws_canc>.
                  <ws_canc>-index = lv_tabix.
                  <ws_canc>-ebelp = ls_item-ebelp.
                  <ws_canc>-data = me->get_xml_from_data( abap_data  = ls_input_canc
                                                          ddic_type  = 'ZOCEAM_DELITEMCANCELAR_LINEA_1'
                                                          xml_header = 'full' ).
                  <ws_canc>-del = abap_true.

                  APPEND ls_input_canc TO lt_input_canc .
                ENDIF.
              ENDIF.
            ELSE.
              DATA(lv_stop) = abap_true.
            ENDIF.
          ENDLOOP.


**********************************************************************
          DATA: lv_xml_s TYPE string.

          CHECK lv_stop IS INITIAL.

          TRY.
              IF ls_data_old-send_cab IS INITIAL.
                CREATE OBJECT o_po_cab EXPORTING logical_port_name = |{ sy-sysid }_{ sy-mandt }|.
                lo_payload_protocol ?= o_po_cab->get_protocol( if_wsprotocol=>payload ). " get proxy Protocol
                CALL METHOD lo_payload_protocol->set_extended_xml_handling( abap_true ). "Active Extended XML handling .


                o_po_cab->creacion_cabecera_oc( EXPORTING input  = ls_input_cab
                                                IMPORTING output = ls_output_cab ).

              ELSE.
                ls_output_cab-result-info_alert-message = 'Cabecera creada correctamente'.
              ENDIF.

              IF ls_output_cab-result-info_alert-message IS NOT INITIAL.
                ls_data-send_cab = abap_true.
                APPEND VALUE #( segmento = 'Cabecera' tipo = 'Exito' message = 'Cabecera creada correctamente' ) TO lt_log.

                LOOP AT lt_input_pza ASSIGNING FIELD-SYMBOL(<pza>)..
                  lv_tabix = sy-tabix.

                  TRY.
*                      IF ls_data-linea_pieza[ lv_tabix ]-del IS INITIAL.

                      CREATE OBJECT o_po_pza EXPORTING logical_port_name = |{ sy-sysid }_{ sy-mandt }|.
                      lo_payload_protocol ?= o_po_pza->get_protocol( if_wsprotocol=>payload ). " get proxy Protocol
                      CALL METHOD lo_payload_protocol->set_extended_xml_handling( abap_true ). "Active Extended XML handling .


                      o_po_pza->incluir_linea_pieza_oc( EXPORTING input  = <pza>
                                                        IMPORTING output = DATA(ls_output_pza) ).

                      IF ls_output_pza-result-info_alert-message IS NOT INITIAL.
                        ls_data-linea_pieza[ lv_tabix ]-send = abap_true.
                        APPEND VALUE #( segmento = |Posicion Pieza: { <pza>-purchaseorderlineid-purchaseorderlinenum }| tipo = 'Exito' message = ls_output_pza-result-info_alert-message ) TO lt_log.
                      ELSE.
                        LOOP AT ls_output_pza-error_alert ASSIGNING FIELD-SYMBOL(<error_alert>).
                          APPEND VALUE #( segmento = |Posicion Pieza: { <pza>-purchaseorderlineid-purchaseorderlinenum }| tipo = 'Error' message = <error_alert>-message ) TO lt_log.
                        ENDLOOP.

                      ENDIF.
*                      ELSE.
*
*                      ENDIF.

                    CATCH cx_root INTO DATA(o_error)..
                      ls_output_cab-error_alert-message = o_error->get_text( ).

                      APPEND VALUE #( segmento = |Posicion Pieza: { <pza>-purchaseorderlineid-purchaseorderlinenum }|  tipo = 'Error' message = ls_output_cab-error_alert-message ) TO lt_log.
                  ENDTRY.
                  CLEAR o_po_pza.
                ENDLOOP.

                LOOP AT lt_input_ser ASSIGNING FIELD-SYMBOL(<ser>)..
                  lv_tabix = sy-tabix.

                  TRY.
*                      IF ls_data-linea_servicio[ lv_tabix ]-del IS INITIAL.

                      CREATE OBJECT o_po_ser EXPORTING logical_port_name = |{ sy-sysid }_{ sy-mandt }|.
                      lo_payload_protocol ?= o_po_ser->get_protocol( if_wsprotocol=>payload ). " get proxy Protocol
                      CALL METHOD lo_payload_protocol->set_extended_xml_handling( abap_true ). "Active Extended XML handling .



                      o_po_ser->incluir_linea_servicio_oc( EXPORTING input  = <ser>
                                                           IMPORTING output = DATA(ls_output_ser) ).

                      IF ls_output_ser-result-info_alert-message IS NOT INITIAL.
                        ls_data-linea_servicio[ lv_tabix ]-send = abap_true.
                        APPEND VALUE #( segmento = |Posicion Servicio: { <ser>-purchaseorderlineid-purchaseorderlinenum }| tipo = 'Exito' message = ls_output_ser-result-info_alert-message ) TO lt_log.
                      ELSE.
                        APPEND VALUE #( segmento = |Posicion Servicio: { <ser>-purchaseorderlineid-purchaseorderlinenum }| tipo = 'Error' message = ls_output_ser-error_alert-message ) TO lt_log.
                      ENDIF.

*                      ELSE.

*                      ENDIF.

                    CATCH cx_root INTO o_error..
                      ls_output_cab-error_alert-message = o_error->get_text( ).
                      APPEND VALUE #( segmento = |Posicion Servicio: { <ser>-purchaseorderlineid-purchaseorderlinenum }|  tipo = 'Error' message = ls_output_cab-error_alert-message ) TO lt_log.

*                      lv_dataout = me->get_xml_from_data( abap_data  = ls_output_cab
*                                                          ddic_type  = 'ZEAM_CABOCCREACION_CABECERA_OC'
*                                                          xml_header = 'full' ).


                  ENDTRY.
                  CLEAR o_po_ser.
                ENDLOOP.

*Cancelar Posiciones
                LOOP AT lt_input_canc ASSIGNING FIELD-SYMBOL(<canc>).
                  lv_tabix = sy-tabix.
                  TRY.
                      lv_ebelp = |{ <canc>-purchaseorderlineid-purchaseorderlinenum ALPHA = IN }|.
                      DATA(ls_canc) = ls_data-linea_canc[ ebelp = lv_ebelp ].
                    CATCH cx_root..

                  ENDTRY.

                  IF ls_canc-send IS INITIAL.
                    TRY.

                        CREATE OBJECT o_po_canc EXPORTING logical_port_name = |{ sy-sysid }_{ sy-mandt }|.
                        lo_payload_protocol ?= o_po_canc->get_protocol( if_wsprotocol=>payload ). " get proxy Protocol
                        CALL METHOD lo_payload_protocol->set_extended_xml_handling( abap_true ). "Active Extended XML handling .

                        o_po_canc->cancelar_linea( EXPORTING input  = <canc>
                                                   IMPORTING output = ls_output_canc ).

                        IF ls_output_canc-result-info_alert-message IS NOT INITIAL.
                          ls_data-linea_canc[ ebelp = lv_ebelp ]-send = abap_true.
                          APPEND VALUE #( segmento = |Cancelar Posición: { <canc>-purchaseorderlineid-purchaseorderlinenum }| tipo = 'Exito' message = ls_output_canc-result-info_alert-message ) TO lt_log.
                        ELSE.
                          APPEND VALUE #( segmento = |Cancelar Posición: { <canc>-purchaseorderlineid-purchaseorderlinenum }| tipo = 'Error' message = ls_output_canc-error_alert-message ) TO lt_log.
                        ENDIF.

*                      ELSE.

*                      ENDIF.

                      CATCH cx_root INTO o_error..
                        ls_output_cab-error_alert-message = o_error->get_text( ).
                        APPEND VALUE #( segmento = |Cancelar Posición: { <ser>-purchaseorderlineid-purchaseorderlinenum }|  tipo = 'Error' message = ls_output_cab-error_alert-message ) TO lt_log.

*                      lv_dataout = me->get_xml_from_data( abap_data  = ls_output_cab
*                                                          ddic_type  = 'ZEAM_CABOCCREACION_CABECERA_OC'
*                                                          xml_header = 'full' ).


                    ENDTRY.
                    CLEAR o_po_canc.
                  ENDIF.
                ENDLOOP.
              ELSE.
*                lv_dataout = me->get_xml_from_data( abap_data  = ls_output_cab
*                                                    ddic_type  = 'ZEAM_CABOCCREACION_CABECERA_OC'
*                                                    xml_header = 'full' ).

                APPEND VALUE #( segmento = 'Cabecera' tipo = 'Error' message = ls_output_cab-error_alert-message ) TO lt_log.

              ENDIF.

            CATCH cx_root INTO o_error.
*              lv_idext = lv_idcpi = im_ebeln.
              ls_output_cab-error_alert-message = o_error->get_text( ).

              APPEND VALUE #( segmento = 'Cabecera' tipo = 'Error' message = ls_output_cab-error_alert-message ) TO lt_log.

*              lv_dataout = me->get_xml_from_data( abap_data  = ls_output_cab
*                                                  ddic_type  = 'ZEAM_CABOCCREACION_CABECERA_OC'
*                                                  xml_header = 'full' ).
*
*              CALL TRANSFORMATION id SOURCE table = ls_data RESULT XML lv_data.
*              CALL FUNCTION 'ZABAP_INTLOG'
*                EXPORTING
*                  i_type    = gc_inttype
*                  i_idext   = lv_idext
*                  i_idcpi   = lv_idcpi
*                  i_data    = lv_data
*                  i_dataout = lv_dataout
*                  i_step    = '01'
*                TABLES
*                  et_return = lt_return.
          ENDTRY.


        CATCH cx_root INTO o_error.
*          lv_idext = lv_idcpi = im_ebeln.
          ls_output_cab-error_alert-message = o_error->get_text( ).

          APPEND VALUE #( segmento = 'Cabecera' tipo = 'Error' message = ls_output_cab-error_alert-message ) TO lt_log.

*          lv_dataout = me->get_xml_from_data( abap_data  = ls_output_cab
*                                              ddic_type  = 'ZEAM_CABOCCREACION_CABECERA_OC'
*                                              xml_header = 'full' ).
*          CALL TRANSFORMATION id SOURCE table = ls_data RESULT XML lv_data.
*          CALL FUNCTION 'ZABAP_INTLOG'
*            EXPORTING
*              i_type    = gc_inttype
*              i_idext   = lv_idext
*              i_idcpi   = lv_idcpi
*              i_data    = lv_data
*              i_dataout = lv_dataout
*              i_step    = '01'
*            TABLES
*              et_return = lt_return.
      ENDTRY.

      IF lt_log IS NOT INITIAL.

        IF NOT line_exists( lt_log[ tipo = 'Error' ] ).
          ls_data-send_oc = abap_true.
        ENDIF.

        CALL TRANSFORMATION id SOURCE table = ls_data RESULT XML lv_data.
        CALL TRANSFORMATION id SOURCE table = lt_log  RESULT XML lv_dataout.

        lv_idext = lv_idcpi = im_ebeln.
        CALL FUNCTION 'ZABAP_INTLOG'
          EXPORTING
            i_type    = gc_inttype
            i_idext   = lv_idext
            i_idcpi   = lv_idcpi
            i_data    = lv_data
            i_dataout = lv_dataout
            i_step    = '01'
            i_commit  = gv_commit
          TABLES
            et_return = lt_return.

      ENDIF.



    ENDIF.

  ENDMETHOD.


  METHOD set_vacio.
    IF i_tipo = '1'.
      c_value = '#'.
      TRANSLATE c_value USING '# '.
    ELSE.
      APPEND INITIAL LINE TO C_CONTROLLER ASSIGNING FIELD-SYMBOL(<controller>).
      <controller>-field = I_FIELD.
      <controller>-value = I_VALUE.
    ENDIF.
  ENDMETHOD.


  METHOD SHOW_ALV.

    DATA: ls_key    TYPE salv_s_layout_key,
          ls_column TYPE REF TO cl_salv_column_table.


    TRY.
        cl_salv_table=>factory(
          EXPORTING
            list_display = space
          IMPORTING
            r_salv_table = o_alv
          CHANGING
            t_table      = gt_data ).

        DATA: lv_title TYPE lvc_title.
        lv_title = TEXT-001.
        DATA(lr_display_settings) = o_alv->get_display_settings( ).
        lr_display_settings->set_list_header( lv_title ).

        DATA(lr_functions) = o_alv->get_functions( ).
        lr_functions->set_all( 'X' ).


        DATA(lr_columns) = o_alv->get_columns( ).
        lr_columns->set_optimize( abap_true ).

        TRY.


*            ls_column ?= lr_columns->get_column( 'EAN_COMP' ).
*            ls_column->set_short_text( 'EAN Comp.' ).
*            ls_column->set_medium_text( 'EAN Comprador' ).
*            ls_column->set_long_text( 'EAN Comprador' ).
*
*            ls_column ?= lr_columns->get_column( 'EAN_DEST' ).
*            ls_column->set_short_text( 'EAN Dest.M' ).
*            ls_column->set_medium_text( 'EAN Dest. Merc.' ).
*            ls_column->set_long_text( 'EAN Dest. Merc.' ).
*
*            ls_column ?= lr_columns->get_column( 'EAN_ENTR' ).
*            ls_column->set_short_text( 'EAN Lug.En' ).
*            ls_column->set_medium_text( 'EAN Lugar Entr.' ).
*            ls_column->set_long_text( 'EAN Lugar Entrega' ).
*
*            ls_column ?= lr_columns->get_column( 'EANNR' ).
*            ls_column->set_short_text( 'EAN Arti.' ).
*            ls_column->set_medium_text( 'EAN del Articulo' ).
*            ls_column->set_long_text( 'EAN del Articulo' ).
*
*            ls_column ?= lr_columns->get_column( 'EBELN' ).
*            ls_column->set_short_text( 'Doc.compr.' ).
*            ls_column->set_medium_text( 'Doc.compras' ).
*            ls_column->set_long_text( 'Documento compras' ).
*
*            ls_column ?= lr_columns->get_column( 'ICON' ).
*            ls_column->set_short_text( 'Estatus' ).
*            ls_column->set_medium_text( 'Estatus' ).
*            ls_column->set_long_text( 'Estatus' ).
*
*            ls_column ?= lr_columns->get_column( 'LOG' ).
*            ls_column->set_short_text( 'Errores' ).
*            ls_column->set_medium_text( 'Errores' ).
*            ls_column->set_long_text( 'Errores' ).

            ls_column ?= lr_columns->get_column( 'DATA_IN' ).
            ls_column->set_visible( abap_false ).

            ls_column ?= lr_columns->get_column( 'DATA_OUT' ).
            ls_column->set_visible( abap_false ).

            ls_column ?= lr_columns->get_column( 'EBELN' ).
            ls_column->set_cell_type( if_salv_c_cell_type=>hotspot ).

            DATA(lo_layout) = o_alv->get_layout( ).
            lo_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
            ls_key-report = sy-repid.
            lo_layout->set_key( ls_key ).


          CATCH cx_salv_not_found .
        ENDTRY.

        DATA(lr_events) = o_alv->get_event( ).

*        CREATE OBJECT gr_events.

*... §6.1 register to the event USER_COMMAND
        SET HANDLER me->handle_user_command FOR lr_events.
*... §6.2 register to the event DOUBLE_CLICK
*      SET HANDLER gr_events->on_double_click FOR lr_events.
*... §6.3 register to the event LINK_CLICK
        SET HANDLER me->handle_hotspot FOR lr_events.

        DATA(lr_selections) = o_alv->get_selections( ).

*... §7.1 set selection mode
        lr_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ).

        o_alv->set_screen_status(
          pfstatus      = 'STANDARD'
          report        = 'ZMM_SEND_PO_ARIES_REPORT' "gs_test-repid
          set_functions = o_alv->c_functions_all ).



        o_alv->display( ).


      CATCH cx_salv_msg.                                "#EC NO_HANDLER
    ENDTRY.
  ENDMETHOD.


  METHOD SHOW_LOG.


    DATA alv TYPE REF TO cl_salv_table.

    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = alv
          CHANGING
            t_table      = gt_log ).



*... set list title
        DATA: lv_title TYPE lvc_title.
        lv_title = TEXT-001.
        DATA(lr_display_settings) = alv->get_display_settings( ).
        lr_display_settings->set_list_header( lv_title ).

        DATA(lr_functions) = alv->get_functions( ).
        lr_functions->set_all( 'X' ).

        alv->display( ).

      CATCH cx_salv_msg INTO DATA(message).
        " error handling
    ENDTRY.

  ENDMETHOD.


  METHOD SHOW_PO.
    SET PARAMETER ID 'BES' FIELD i_data-ebeln.

    CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

  ENDMETHOD.


  METHOD START.
    rg_bukrs = i_bukrs.
    rg_bsart = i_bsart.
    rg_ebeln = i_ebeln.
    rg_aedat = i_aedat.

    me->get_data( ).

    IF gt_data IS NOT INITIAL.
      me->show_alv( ).
    ELSE.
      MESSAGE s398(00) WITH 'No existen datos para la selección'.
    ENDIF.


  ENDMETHOD.
ENDCLASS.
