class ZCL_ABAP_INTLOG_013 definition
  public
  final
  create public .

public section.

  interfaces ZIF_ABAP_INTLOG_PROCESS .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ABAP_INTLOG_013 IMPLEMENTATION.


  METHOD zif_abap_intlog_process~get_result.
    DATA: lv_xstring  TYPE xstring,
          lt_xml      TYPE STANDARD TABLE OF smum_xmltb,
          return      TYPE STANDARD TABLE OF bapiret2,
          lv_banfn    TYPE eban-banfn,
          lv_i        TYPE i,
          lv_132(132).

    DATA: lt_log            TYPE ztt_mm_eam_data03.

    e_doc_type = '01'.

    CALL TRANSFORMATION id SOURCE XML i_dataout RESULT table = lt_log .

    IF NOT line_exists( lt_log[ tipo = 'Error' ] ).
*          ls_data-send_oc = abap_true.
      e_doc_key = i_idext.
    ENDIF.

    LOOP AT lt_log ASSIGNING FIELD-SYMBOL(<log>).
      APPEND INITIAL LINE TO et_return ASSIGNING FIELD-SYMBOL(<return>).
      lv_132 = <log>-message.
      CASE <log>-tipo.
        WHEN 'Error'.
          DATA(lv_type) = 'E'.
        WHEN 'Exito'.
          lv_type = 'S'.
        WHEN OTHERS.
      ENDCASE.

      MESSAGE ID '00' TYPE lv_type NUMBER '398' WITH lv_132(33) lv_132+33(32) lv_132+66(32) lv_132+99(32) INTO <return>-message..
      <return>-id = '00'.
      <return>-number = '398'.
      <return>-message_v1 = lv_132(33).
      <return>-message_v2 = lv_132+33(32).
      <return>-message_v3 = lv_132+66(32).
      <return>-message_v4 = lv_132+99(32).
      <return>-type = lv_type.
    ENDLOOP.

*    CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
*      EXPORTING
*        text     = i_dataout
*        mimetype = 'SPACE '
**       ENCODING =
*      IMPORTING
*        buffer   = lv_xstring
*      EXCEPTIONS
*        failed   = 1
*        OTHERS   = 2.

**// FUNCTION MODULE TO UPLOAD DATA TO INTERNAL TABLE //**



  ENDMETHOD.
ENDCLASS.
