class ZCL_SADL_TOOL definition
  public
  final
  create public .

public section.

  methods GET_MODEL_BY_SRV_NAME
    importing
      !IV_SRV_NAME type /IWBEP/MED_GRP_TECHNICAL_NAME .
  methods GET_LAST_MODIFIED .
  methods GET_SADL_DEFINITION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SADL_TOOL IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SADL_TOOL->GET_LAST_MODIFIED
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_last_modified.
    DATA lt_paths TYPE string_table.

    APPEND 'CDS~ZFLIGHT_COM' TO lt_paths.
    DATA: lo_mp TYPE REF TO cl_sadl_mp_entity_exposure.

    lo_mp = CAST #( NEW cl_sadl_mp_entity_exposure( it_paths = lt_paths
                   iv_timestamp = 20160319014636 iv_expose_associations = abap_true ) ).

    cl_sadl_entity_mp_registry=>register_mp( lo_mp ).
    DATA(rv_last_modified) = cl_sadl_entity_load_handler=>get_latest_timestamp( lo_mp ).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SADL_TOOL->GET_MODEL_BY_SRV_NAME
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_SRV_NAME                    TYPE        /IWBEP/MED_GRP_TECHNICAL_NAME
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_MODEL_BY_SRV_NAME.

    DATA: RT_OBJECT_MODELS TYPE  /IWBEP/T_OBJECT_MODEL,
          ET_MSG_CONTAINER TYPE  /IWBEP/T_MESSAGE_CONTAINER,
          ES_MSG_CONTAINER_H TYPE  /IWBEP/S_MESSAGE_CONTAINER_H,
          ES_MODEL_USAGE TYPE  /IWBEP/S_MED_MDL_USAGE.

    CALL FUNCTION '/IWBEP/FM_MGW_GET_OBJ_MODELS'
      EXPORTING
       IV_LANGUAGE                    = 'E'
       IV_SERVICE_GROUP_NAME          = iv_srv_name
       IV_SERVICE_GROUP_VERSION       = '0001'
       "IV_CONTEXT                     =
       IV_INCLUDE_MODEL_USAGE         = 'X'
     IMPORTING
       RT_OBJECT_MODELS               = RT_OBJECT_MODELS
       ET_MSG_CONTAINER               = ET_MSG_CONTAINER
       ES_MSG_CONTAINER_H             = ES_MSG_CONTAINER_H
       ES_MODEL_USAGE                 = ES_MODEL_USAGE.
              .

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SADL_TOOL->GET_SADL_DEFINITION
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_SADL_DEFINITION.

    DATA: lt_paths TYPE string_table,
          lo_Context TYPE REF TO IF_BSA_SADL_MP_CONTEXT.
    DATA: ls_sadl_definition_orig TYPE if_sadl_types=>ty_sadl_definition.

    APPEND 'CDS~ZFLIGHT_COM' TO lt_paths.
    DATA: lo_mp TYPE REF TO cl_sadl_mp_entity_exposure.

    lo_mp = CAST #( NEW cl_sadl_mp_entity_exposure( it_paths = lt_paths
                   iv_timestamp = 20160319014636 iv_expose_associations = abap_true ) ).

    "cl_sadl_entity_mp_registry=>register_mp( lo_mp ).
    lo_context ?= lo_mp.

    lo_context->get_sadl_definition( IMPORTING
         es_sadl_definition = ls_sadl_definition_orig ).
    "DATA(rv_last_modified) = cl_sadl_entity_load_handler=>get_latest_timestamp( lo_mp ).

  endmethod.
ENDCLASS.