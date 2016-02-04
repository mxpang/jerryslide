CLASS zcl_crm_offline_product_tool DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_origin,
        orderadm_i TYPE crmt_orderadm_i_wrkt,
        product_i  TYPE crmt_product_i_wrkt,
        schedlin_i TYPE crmt_schedlin_i_wrkt,
        price_i    TYPE crmt_pricing_i_wrkt,
        price      TYPE crmt_pricing_wrkt,

      END OF ty_origin .

    TYPES: BEGIN OF ty_opt_line,
             guid             TYPE crmd_orderadm_i-guid,
             header           TYPE crmd_orderadm_i-header,
             product          TYPE crmd_orderadm_i-product,
             ordered_prod     TYPE crmd_orderadm_i-ordered_prod,
             description      TYPE crmd_orderadm_i-description,
             process_qty_unit TYPE crmd_product_i-process_qty_unit,
             prod_hierarchy   TYPE crmd_product_i-prod_hierarchy,
             quantity         TYPE crmd_schedlin-quantity,
             net_value        TYPE crmd_pricing_i-net_value,
             net_value_man    TYPE crmd_pricing_i-net_value_man,
             currency         TYPE crmd_pricing-currency,
           END OF ty_opt_line.

    TYPES: BEGIN OF ty_opt,
             data TYPE STANDARD TABLE OF ty_opt_line WITH KEY guid,
           END OF ty_opt.

    METHODS compare
      IMPORTING
        !is_origin      TYPE ty_origin
        !is_opt         TYPE ty_opt
      RETURNING
        VALUE(rv_equal) TYPE abap_bool .
    METHODS constructor
      IMPORTING
        !iv_test_number TYPE i .
    METHODS get_expand_prod_by_guid_origin
      IMPORTING
        !iv_guid           TYPE crmt_object_guid
      RETURNING
        VALUE(rs_expanded) TYPE crmt_odata_oppt_hdr_expanded .
    METHODS start .
    METHODS stop
      IMPORTING
        !iv_message TYPE string OPTIONAL .
    METHODS get_item_data_origin
      IMPORTING
        !it_header_guid_tab TYPE crmt_object_guid_tab OPTIONAL
      RETURNING
        VALUE(es_data)      TYPE ty_origin .
    METHODS get_item_data_opt
      IMPORTING
        !it_header_guid_tab TYPE crmt_object_guid_tab OPTIONAL
      RETURNING
        VALUE(es_data)      TYPE ty_opt .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mv_start TYPE int4 .
    DATA mv_end TYPE i .
    CONSTANTS gc_orderadm_i TYPE crmt_object_name VALUE 'ORDERADM_I' ##NO_TEXT.
    CONSTANTS gc_pricing TYPE crmt_object_name VALUE 'PRICING' ##NO_TEXT.
    CONSTANTS gc_pricing_i TYPE crmt_object_name VALUE 'PRICING_I' ##NO_TEXT.
    CONSTANTS gc_product_i TYPE crmt_object_name VALUE 'PRODUCT_I' ##NO_TEXT.
    CONSTANTS gc_schedlin_i TYPE crmt_object_name VALUE 'SCHEDLIN_I' ##NO_TEXT.
    DATA mt_test_guid_tab TYPE crmt_object_guid_tab .

    METHODS get_test_data
      RETURNING
        VALUE(rt_data) TYPE crmt_object_guid_tab .
    METHODS get_expand_node
      RETURNING
        VALUE(ro_node) TYPE REF TO /iwbep/cl_mgw_expand_node .
    METHODS compare_admin_i
      IMPORTING
        !is_origin      TYPE ty_origin
        !is_opt         TYPE ty_opt
      RETURNING
        VALUE(rv_equal) TYPE abap_bool .
    METHODS compare_field
      IMPORTING
        !iv_stru1       TYPE any
        !iv_stru2       TYPE any
        !iv_field       TYPE string
      RETURNING
        VALUE(rv_equal) TYPE abap_bool .
    METHODS compare_product_i
      IMPORTING
        !is_origin      TYPE ty_origin
        !is_opt         TYPE ty_opt
      RETURNING
        VALUE(rv_equal) TYPE abap_bool .
    METHODS compare_schedule_i
      IMPORTING
        !is_origin      TYPE ty_origin
        !is_opt         TYPE ty_opt
      RETURNING
        VALUE(rv_equal) TYPE abap_bool .
    METHODS compare_price_i
      IMPORTING
        !is_origin      TYPE ty_origin
        !is_opt         TYPE ty_opt
      RETURNING
        VALUE(rv_equal) TYPE abap_bool .
    METHODS compare_price
      IMPORTING
        !is_origin      TYPE ty_origin
        !is_opt         TYPE ty_opt
      RETURNING
        VALUE(rv_equal) TYPE abap_bool .
ENDCLASS.



CLASS ZCL_CRM_OFFLINE_PRODUCT_TOOL IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_OFFLINE_PRODUCT_TOOL->COMPARE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_ORIGIN                      TYPE        TY_ORIGIN
* | [--->] IS_OPT                         TYPE        TY_OPT
* | [<-()] RV_EQUAL                       TYPE        ABAP_BOOL
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD compare.

    CHECK lines( is_origin-orderadm_i ) = lines( is_opt-data ).

    CHECK compare_admin_i(    is_origin = is_origin is_opt = is_opt ) = abap_true.
    CHECK compare_product_i(  is_origin = is_origin is_opt = is_opt ) = abap_true.
    CHECK compare_schedule_i( is_origin = is_origin is_opt = is_opt ) = abap_true.
    CHECK compare_price_i(    is_origin = is_origin is_opt = is_opt ) = abap_true.
    CHECK compare_price(      is_origin = is_origin is_opt = is_opt ) = abap_true.

    rv_equal = abap_true.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_CRM_OFFLINE_PRODUCT_TOOL->COMPARE_ADMIN_I
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_ORIGIN                      TYPE        TY_ORIGIN
* | [--->] IS_OPT                         TYPE        TY_OPT
* | [<-()] RV_EQUAL                       TYPE        ABAP_BOOL
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD compare_admin_i.

    LOOP AT is_origin-orderadm_i ASSIGNING FIELD-SYMBOL(<origin>).
      READ TABLE is_opt-data ASSIGNING FIELD-SYMBOL(<opt>)
        WITH KEY guid = <origin>-guid.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

      IF compare_field( iv_stru1 = <origin> iv_stru2 = <opt> iv_field = 'HEADER' ) = abap_false.
        RETURN.
      ENDIF.

      IF compare_field( iv_stru1 = <origin> iv_stru2 = <opt> iv_field = 'PRODUCT' ) = abap_false.
        RETURN.
      ENDIF.

      IF compare_field( iv_stru1 = <origin> iv_stru2 = <opt> iv_field = 'ORDERED_PROD' ) = abap_false.
        RETURN.
      ENDIF.

      IF compare_field( iv_stru1 = <origin> iv_stru2 = <opt> iv_field = 'DESCRIPTION' ) = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.

    rv_equal = abap_true.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_CRM_OFFLINE_PRODUCT_TOOL->COMPARE_FIELD
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_STRU1                       TYPE        ANY
* | [--->] IV_STRU2                       TYPE        ANY
* | [--->] IV_FIELD                       TYPE        STRING
* | [<-()] RV_EQUAL                       TYPE        ABAP_BOOL
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD compare_field.
    FIELD-SYMBOLS: <value1> TYPE any,
                   <value2> TYPE any.

    ASSIGN COMPONENT iv_field OF STRUCTURE iv_stru1 TO <value1>.
    ASSIGN COMPONENT iv_field OF STRUCTURE iv_stru2 TO <value2>.

    IF <value1> = <value2>.
      rv_equal = abap_true.
    ENDIF.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_CRM_OFFLINE_PRODUCT_TOOL->COMPARE_PRICE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_ORIGIN                      TYPE        TY_ORIGIN
* | [--->] IS_OPT                         TYPE        TY_OPT
* | [<-()] RV_EQUAL                       TYPE        ABAP_BOOL
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD compare_price.

    LOOP AT is_origin-price ASSIGNING FIELD-SYMBOL(<origin>).
      READ TABLE is_opt-data ASSIGNING FIELD-SYMBOL(<opt>)
        WITH KEY guid = <origin>-guid.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

      IF compare_field( iv_stru1 = <origin> iv_stru2 = <opt> iv_field = 'CURRENCY' ) = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.

    rv_equal = abap_true.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_CRM_OFFLINE_PRODUCT_TOOL->COMPARE_PRICE_I
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_ORIGIN                      TYPE        TY_ORIGIN
* | [--->] IS_OPT                         TYPE        TY_OPT
* | [<-()] RV_EQUAL                       TYPE        ABAP_BOOL
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD compare_price_i.

    LOOP AT is_origin-price_i ASSIGNING FIELD-SYMBOL(<origin>).
      READ TABLE is_opt-data ASSIGNING FIELD-SYMBOL(<opt>)
        WITH KEY guid = <origin>-guid.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

      IF compare_field( iv_stru1 = <origin> iv_stru2 = <opt> iv_field = 'NET_VALUE' ) = abap_false.
        RETURN.
      ENDIF.

      IF compare_field( iv_stru1 = <origin> iv_stru2 = <opt> iv_field = 'NET_VALUE_MAN' ) = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.

    rv_equal = abap_true.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_CRM_OFFLINE_PRODUCT_TOOL->COMPARE_PRODUCT_I
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_ORIGIN                      TYPE        TY_ORIGIN
* | [--->] IS_OPT                         TYPE        TY_OPT
* | [<-()] RV_EQUAL                       TYPE        ABAP_BOOL
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD compare_product_i.

    LOOP AT is_origin-product_i ASSIGNING FIELD-SYMBOL(<origin>).
      READ TABLE is_opt-data ASSIGNING FIELD-SYMBOL(<opt>)
        WITH KEY guid = <origin>-guid.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

      IF compare_field( iv_stru1 = <origin> iv_stru2 = <opt> iv_field = 'PROCESS_QTY_UNIT' ) = abap_false.
        RETURN.
      ENDIF.

      IF compare_field( iv_stru1 = <origin> iv_stru2 = <opt> iv_field = 'PROD_HIERARCHY' ) = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.

    rv_equal = abap_true.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_CRM_OFFLINE_PRODUCT_TOOL->COMPARE_SCHEDULE_I
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_ORIGIN                      TYPE        TY_ORIGIN
* | [--->] IS_OPT                         TYPE        TY_OPT
* | [<-()] RV_EQUAL                       TYPE        ABAP_BOOL
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD compare_schedule_i.

    LOOP AT is_origin-schedlin_i ASSIGNING FIELD-SYMBOL(<origin>).
      READ TABLE is_opt-data ASSIGNING FIELD-SYMBOL(<opt>)
        WITH KEY guid = <origin>-guid.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

*      IF compare_field( iv_stru1 = <origin> iv_stru2 = <opt> iv_field = 'ORDER_QTY' ) = abap_false.
*        RETURN.
*      ENDIF.
      IF <origin>-order_qty <> <opt>-quantity.
        RETURN.
      ENDIF.

    ENDLOOP.

    rv_equal = abap_true.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_OFFLINE_PRODUCT_TOOL->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_TEST_NUMBER                 TYPE        I
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD constructor.

    SELECT guid INTO TABLE mt_test_guid_tab FROM crmd_orderadm_h UP TO iv_test_number ROWS
    ."   WHERE process_type = 'OPPT'.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_CRM_OFFLINE_PRODUCT_TOOL->GET_EXPAND_NODE
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RO_NODE                        TYPE REF TO /IWBEP/CL_MGW_EXPAND_NODE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_expand_node.
    DATA:
      lo_model       TYPE REF TO /iwbep/if_mgw_odata_fw_model,
      lo_expand_tree TYPE REF TO /iwbep/cl_mgw_expand_tree,
      lo_root        TYPE REF TO /iwbep/cl_mgw_expand_node.

    lo_expand_tree = /iwbep/cl_mgw_expand_tree=>create(
                   iv_entity_set       = 'OpportunityCollection'
                   iv_entity_type      = 'Opportunity'
                   iv_tech_entity_set  = 'OpportunityCollection'
                   iv_tech_entity_type = 'Opportunity'
                   iv_multiplicity     = 'M'
                   iv_expand           = 'PRODUCTS'"'DocumentItems'
                   iv_tech_expand      = 'PRODUCTS'"'DOCUMENTITEMS'
                   io_model            = lo_model ).

    lo_expand_tree->get_root( IMPORTING eo_root = ro_node ).

    "lo_root->get_child( EXPORTING iv_nav_prop_name = 'DocumentItems'
    "                    IMPORTING eo_child = ro_node ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_OFFLINE_PRODUCT_TOOL->GET_EXPAND_PROD_BY_GUID_ORIGIN
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_GUID                        TYPE        CRMT_OBJECT_GUID
* | [<-()] RS_EXPANDED                    TYPE        CRMT_ODATA_OPPT_HDR_EXPANDED
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_expand_prod_by_guid_origin.
    DATA: lt_key_tab               TYPE /iwbep/t_mgw_name_value_pair,
          lo_expand                TYPE REF TO /iwbep/cl_mgw_expand_node,
          lt_expanded_clauses      TYPE string_table,
          lt_expanded_tech_clauses TYPE string_table,
          lo_request               TYPE REF TO /iwbep/cl_mgw_request,
          lt_path                  TYPE /iwbep/t_mgw_navigation_path.

    DATA(go_oppt_impl) = NEW cl_crm_opportunity_impl( ).
    DATA(ls_key) = VALUE /iwbep/s_mgw_name_value_pair( name = 'Guid'
       value = iv_guid ).
    APPEND ls_key TO lt_key_tab.
    lo_expand = get_expand_node( ).

    go_oppt_impl->get_oppt_expanded_entity(
      EXPORTING
        iv_entity_name               = space
        iv_entity_set_name           = space
        iv_source_name               = space
        it_key_tab                   = lt_key_tab
        it_navigation_path           = lt_path
        io_expand                    = lo_expand
        io_tech_request_context      = lo_request
      IMPORTING
        et_oppt_expanded             = rs_expanded
        "et_expanded_clauses          = lt_expanded_clauses
        "et_expanded_tech_clauses     = lt_expanded_tech_clauses
    ).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_OFFLINE_PRODUCT_TOOL->GET_ITEM_DATA_OPT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_HEADER_GUID_TAB             TYPE        CRMT_OBJECT_GUID_TAB(optional)
* | [<-()] ES_DATA                        TYPE        TY_OPT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_item_data_opt.

    DATA: lt_option LIKE it_header_guid_tab.

    lt_option = it_header_guid_tab.
    IF it_header_guid_tab IS NOT SUPPLIED.
      lt_option = get_test_data( ).
    ENDIF.

SELECT a~guid a~header  a~product a~ordered_prod a~description b~process_qty_unit b~prod_hierarchy
      c~quantity d~net_value d~net_value_man e~currency FROM crmd_orderadm_i AS a
      LEFT JOIN crmd_product_i AS b ON a~guid = b~guid
      LEFT JOIN crmd_schedlin AS c ON a~guid  = c~item_guid
      LEFT JOIN crmd_pricing_i AS d ON a~guid = d~guid
      LEFT JOIN crmd_pricing AS e ON a~guid = e~guid
      INTO CORRESPONDING FIELDS OF TABLE es_data-data
      FOR ALL ENTRIES IN lt_option WHERE header = lt_option-table_line.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_OFFLINE_PRODUCT_TOOL->GET_ITEM_DATA_ORIGIN
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_HEADER_GUID_TAB             TYPE        CRMT_OBJECT_GUID_TAB(optional)
* | [<-()] ES_DATA                        TYPE        TY_ORIGIN
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_item_data_origin.
    DATA: lt_input             TYPE crmt_object_guid_tab,
          lt_requested_objects TYPE crmt_object_name_tab,
          lt_orderadm_i        TYPE crmt_orderadm_i_wrkt,
          lt_product_i         TYPE crmt_product_i_wrkt,
          lt_price_i           TYPE crmt_pricing_i_wrkt,
          lt_price             TYPE crmt_pricing_wrkt,
          lt_schedlin_i        TYPE crmt_schedlin_i_wrkt,
          lt_option            LIKE lt_input.

    lt_option = it_header_guid_tab.
    IF it_header_guid_tab IS NOT SUPPLIED.
      lt_option = get_test_data( ).
    ENDIF.

    LOOP AT lt_option ASSIGNING FIELD-SYMBOL(<guid>).
      CLEAR: lt_input, lt_requested_objects,lt_orderadm_i, lt_product_i,lt_schedlin_i,
             lt_price_i, lt_price.

      APPEND <guid> TO lt_input.
      INSERT gc_orderadm_i INTO TABLE lt_requested_objects.
      INSERT gc_product_i INTO TABLE lt_requested_objects.
      INSERT gc_schedlin_i INTO TABLE lt_requested_objects.
      INSERT gc_pricing_i INTO TABLE lt_requested_objects.
      INSERT gc_pricing INTO TABLE lt_requested_objects.

      CALL FUNCTION 'CRM_ORDER_READ'
        EXPORTING
          it_header_guid       = lt_input
          it_requested_objects = lt_requested_objects
        IMPORTING
          et_orderadm_i        = lt_orderadm_i
          et_product_i         = lt_product_i
          et_pricing           = lt_price
          et_pricing_i         = lt_price_i
          et_schedlin_i        = lt_schedlin_i
        EXCEPTIONS
          document_not_found   = 1
          error_occurred       = 2
          document_locked      = 3
          no_change_authority  = 4
          no_display_authority = 5
          no_change_allowed    = 6
          OTHERS               = 7.
      IF lt_orderadm_i IS NOT INITIAL.
        INSERT LINES OF lt_orderadm_i INTO TABLE es_data-orderadm_i.
      ENDIF.

      IF lt_product_i IS NOT INITIAL.
        INSERT LINES OF lt_product_i INTO TABLE es_data-product_i.
      ENDIF.

      IF lt_schedlin_i IS NOT INITIAL.
        INSERT LINES OF lt_schedlin_i INTO TABLE es_data-schedlin_i.
      ENDIF.

      IF lt_price_i IS NOT INITIAL.
        INSERT LINES OF lt_price_i INTO TABLE es_data-price_i.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_CRM_OFFLINE_PRODUCT_TOOL->GET_TEST_DATA
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RT_DATA                        TYPE        CRMT_OBJECT_GUID_TAB
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_test_data.
    rt_data = mt_test_guid_tab.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_OFFLINE_PRODUCT_TOOL->START
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD start.
    GET RUN TIME FIELD mv_start.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_OFFLINE_PRODUCT_TOOL->STOP
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_MESSAGE                     TYPE        STRING(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD stop.
    GET RUN TIME FIELD mv_end.

    mv_end = mv_end - mv_start.

    DATA: lv_text TYPE string.

    IF iv_message IS SUPPLIED.
      lv_text = iv_message.
    ENDIF.

    lv_text = lv_text && ' consumed time: ' && mv_end.

    WRITE: / lv_text COLOR COL_NEGATIVE.
  ENDMETHOD.
ENDCLASS.