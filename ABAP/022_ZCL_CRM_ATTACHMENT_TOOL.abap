class ZCL_CRM_ATTACHMENT_TOOL definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF lty_object_key,
      instid   TYPE sibfboriid,
      typeid   TYPE sibftypeid,
    END OF lty_object_key .
  types:
    ltty_object_key TYPE TABLE OF lty_object_key .
  types:
    BEGIN OF ty_order_atta_link,
      order_guid   TYPE sibfboriid,
      order_bortype   TYPE sibftypeid,
      atta_type      TYPE skwf_ioty,
      attid_lo     TYPE sdok_docid,
      attid_ph     TYPE sdok_docid,
      END OF ty_order_atta_link .
  types:
    tt_order_atta_link TYPE STANDARD TABLE OF ty_order_atta_link .

  data MT_BP_TEST_DATA type LTTY_OBJECT_KEY .

  methods COMPARE_READ_RESULT
    importing
      !IT_ORIGIN type CRMT_ODATA_TASK_ATTACHMENTT
      !IT_JERRY type CRMT_ODATA_TASK_ATTACHMENTT
    returning
      value(RV_EQUAL) type ABAP_BOOL .
  methods GET_ATTACHMENTS_ORIGIN
    importing
      !IT_OBJECTS type LTTY_OBJECT_KEY
    returning
      value(RT_ATTACHMENTS) type CRMT_ODATA_TASK_ATTACHMENTT .
  methods GET_STORAGE_BY_FM .
  methods CONSTRUCTOR .
  methods GET_ATTACHMENT_BY_TASK_GUID
    importing
      !IV_TASK_GUID type CRMT_OBJECT_GUID
    returning
      value(RT_TASK_EXPAND) type CRMT_ODATA_TASK_HDR_EXPANDED .
  methods START .
  methods STOP
    importing
      !IV_MESSAGE type STRING optional .
  methods GET_ATTACHMENTS_BY_BP_WAY
    importing
      !IT_OBJECTS type LTTY_OBJECT_KEY
    returning
      value(RT_LINKS_A) type OBL_T_LINK .
  methods GET_ATTACHMENTS_BY_JERRY_WAY
    importing
      !IT_OBJECTS type LTTY_OBJECT_KEY
    returning
      value(RT_ATTACHMENTS) type CRMT_ODATA_TASK_ATTACHMENTT .
  methods COMPARE_LINK
    importing
      !IT_BP type OBL_T_LINK
      !IT_JERRY type OBL_T_LINK
    returning
      value(RV_EQUAL) type ABAP_BOOL .
  methods GET_STORAGE_BY_REGULAR .
  methods GET_IOS_BY_KEY
    importing
      !IV_KEY type SIBFBORIID
    returning
      value(RS_IOS) type SKWF_IO .
  methods PASS_BY_REF
    exporting
      !ES_RESULT type TADIR .
  methods PASS_BY_VALUE
    returning
      value(RS_RESULT) type TADIR .
  methods COMPARE_VALUE_REF .
protected section.
private section.

  data MT_ORDER_ATTA_LINK type TT_ORDER_ATTA_LINK .
  data MV_START type I .
  data MV_END type I .
  data MV_REGULAR_TEST_NUM type INT4 value 10000 ##NO_TEXT.

  methods GET_ALL_IOS_WITH_PROPERTIES
    importing
      !IT_LINKS type OBL_T_LINK
    exporting
      !ET_PROPERTY_RESULT type CRM_KW_PROPST
      !ET_FILE_ACCESS_INFO type SKWF_CPPRPS
      !ET_IP_LINKS type SDOKLOGPHYS .
  methods GET_LINKS
    importing
      !IT_OBJECTS type LTTY_OBJECT_KEY
    returning
      value(RT_LINKS_A) type OBL_T_LINK .
  methods GET_URL
    importing
      !IS_PROPERTIES type CRM_KW_PROPS
    returning
      value(RV_URL) type STRING .
  methods HANDLE_FOLDER
    importing
      !IT_FOLDERS type SKWF_IOS
    changing
      !CT_LOIOS type SKWF_IOS .
ENDCLASS.



CLASS ZCL_CRM_ATTACHMENT_TOOL IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_ATTACHMENT_TOOL->COMPARE_LINK
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_BP                          TYPE        OBL_T_LINK
* | [--->] IT_JERRY                       TYPE        OBL_T_LINK
* | [<-()] RV_EQUAL                       TYPE        ABAP_BOOL
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method COMPARE_LINK.
    CHECK lines( it_bp ) = lines( it_jerry ).

    LOOP AT it_bp ASSIGNING FIELD-SYMBOL(<bp>).
       READ TABLE it_jerry ASSIGNING FIELD-SYMBOL(<jerry>) WITH KEY brelguid = <bp>-brelguid.
       IF sy-subrc <> 0.
          RETURN.
       ENDIF.

       IF <bp>-instid_a <> <jerry>-instid_a OR <bp>-instid_b <> <jerry>-instid_b
          OR <bp>-utctime <> <jerry>-utctime.
          RETURN.
       ENDIF.
    ENDLOOP.

    rv_equal = abap_true.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_ATTACHMENT_TOOL->COMPARE_READ_RESULT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_ORIGIN                      TYPE        CRMT_ODATA_TASK_ATTACHMENTT
* | [--->] IT_JERRY                       TYPE        CRMT_ODATA_TASK_ATTACHMENTT
* | [<-()] RV_EQUAL                       TYPE        ABAP_BOOL
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method COMPARE_READ_RESULT.
    CHECK lines( it_origin ) = lines( it_jerry ).

    LOOP AT it_origin ASSIGNING FIELD-SYMBOL(<origin>).
      READ TABLE it_jerry ASSIGNING FIELD-SYMBOL(<jerry>) WITH KEY
        documentid = <origin>-documentid.

      IF <jerry> <> <origin>.
         RETURN.
      ENDIF.
    ENDLOOP.

    rv_equal = abap_true.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_ATTACHMENT_TOOL->COMPARE_VALUE_REF
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method COMPARE_VALUE_REF.
    DATA: ls_result TYPE tadir,
          lv_num TYPE int4 value 1000.

    start( ).
    DO lv_num TIMES.
       pass_by_ref( IMPORTING es_result = ls_result ).
    ENDDO.
    stop( 'Pass by reference: ' ).

    start( ).
    DO lv_num TIMES.
       ls_result = pass_by_value( ).
    ENDDO.
    stop( 'Pass by value: ' ).
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_ATTACHMENT_TOOL->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method CONSTRUCTOR.
    DATA: lt_guid TYPE STANDARD TABLE OF ztask_with_follo.

    SELECT * INTO TABLE lt_guid FROM ztask_with_follo.

    FIELD-SYMBOLS: <item> LIKE LINE OF mt_bp_test_data.

    LOOP AT lt_guid ASSIGNING FIELD-SYMBOL(<guid>).
       APPEND INITIAL LINE TO mt_bp_test_data ASSIGNING <item>.
       <item>-typeid = 'BUS2000125'.
       <item>-instid = <guid>-task_guid .
    ENDLOOP.

    APPEND INITIAL LINE TO mt_bp_test_data ASSIGNING FIELD-SYMBOL(<item1>).
    <item1>-typeid = 'BUS2000125'.
    <item1>-instid = 'FA163EE56C3A1ED5AE9AE011B059611E'.

    APPEND INITIAL LINE TO mt_bp_test_data ASSIGNING FIELD-SYMBOL(<seconditem>).
    <seconditem>-instid = 'FA163EE56C3A1EE5AD89008F1DBB0B45'.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_CRM_ATTACHMENT_TOOL->GET_ALL_IOS_WITH_PROPERTIES
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_LINKS                       TYPE        OBL_T_LINK
* | [<---] ET_PROPERTY_RESULT             TYPE        CRM_KW_PROPST
* | [<---] ET_FILE_ACCESS_INFO            TYPE        SKWF_CPPRPS
* | [<---] ET_IP_LINKS                    TYPE        SDOKLOGPHYS
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_all_ios_with_properties.

    DATA: lt_ios                  TYPE skwf_ios,
          lt_ios_auth             LIKE lt_ios,
          ls_ios                  LIKE LINE OF lt_ios,
          lt_loios                TYPE skwf_ios,
          lt_folders              TYPE TABLE OF skwf_io,
          ls_sdok_io              TYPE sdokobject,
          lt_sdok_loios           TYPE TABLE OF sdokobject,
          lt_phios                TYPE TABLE OF skwf_io,
          lt_phioloios            TYPE skwf_lpios,
          ls_ios_file_access_info TYPE skwf_cpprp.

    FIELD-SYMBOLS: <link>                 TYPE LINE OF obl_t_link,
                   <order_att_link>       LIKE LINE OF mt_order_atta_link,
                   <io>                   LIKE LINE OF lt_ios,
                   <phio>                 TYPE sdoklogphy,
                   <phiolo>               LIKE LINE OF lt_phioloios.

    LOOP AT it_links ASSIGNING <link>.
      ls_ios = get_ios_by_key( <link>-instid_b ).
      APPEND ls_ios TO lt_ios.

      APPEND INITIAL LINE TO mt_order_atta_link ASSIGNING <order_att_link>.
      <order_att_link>-order_guid = <link>-instid_a.
      <order_att_link>-order_bortype = <link>-typeid_a.
      <order_att_link>-atta_type = ls_ios-objtype.
      <order_att_link>-attid_lo = ls_ios-objid.
    ENDLOOP.

    CALL FUNCTION 'SKWF_AUTH_OBJECTS_CHECK'
      EXPORTING
        activity     = '03'
      TABLES
        objects      = lt_ios
        objects_auth = lt_ios_auth.

    lt_ios = lt_ios_auth.

    LOOP AT lt_ios ASSIGNING <io>.
      CASE <io>-objtype.
        WHEN 'L'.
          APPEND <io> TO lt_loios.
        WHEN 'F'.
          APPEND <io> TO lt_folders.
      ENDCASE.
    ENDLOOP.

*   I042416: 1. For all folders: read all documents in subtree
*   2.adjust ID-mapping (currently order_guid<->folder key are present in mapping and need
*   to be replaced by objid of single document)

    IF lt_folders IS NOT INITIAL.
      handle_folder( EXPORTING it_folders = lt_folders CHANGING ct_loios = lt_loios ).
    ENDIF.

*   Now get all phios (property-records, object-type "P") to all loios
*   (object-type "L")
    SORT mt_order_atta_link BY attid_lo.
    LOOP AT lt_loios ASSIGNING <io>.
      ls_sdok_io = <io>-object.
      APPEND ls_sdok_io TO lt_sdok_loios.
    ENDLOOP.
    CALL FUNCTION 'SDOK_LOIOS_PHIOS_GET'
      EXPORTING
        x_reduce_to_one  = 'X'
      TABLES
        object_list      = lt_sdok_loios
        physical_objects = et_ip_links.

    LOOP AT et_ip_links ASSIGNING <phio>.
      APPEND INITIAL LINE TO lt_phios ASSIGNING <io>.
      <io>-class  = <phio>-class_ph.
      <io>-objid  = <phio>-objid_ph.
      <io>-objtype = 'P'.

      APPEND INITIAL LINE TO lt_phioloios ASSIGNING <phiolo>.
      <phiolo>-classph   = <phio>-class_ph.
      <phiolo>-objidph   = <phio>-objid_ph.
      <phiolo>-objtypeph = 'P'.
      <phiolo>-classlo   = <phio>-class_lo.
      <phiolo>-objidlo   = <phio>-objid_lo.
      <phiolo>-objtypelo = 'L'.
    ENDLOOP.

    APPEND LINES OF lt_loios TO lt_ios.
    APPEND LINES OF lt_phios TO lt_ios.

    CALL FUNCTION 'CRM_KW_PROPERTIES_GET'
      EXPORTING
        ios                   = lt_ios
      IMPORTING
        ios_properties_result = et_property_result.

    LOOP AT lt_phios INTO ls_ios_file_access_info-io WHERE class <> 'CRM_P_URL'.
      APPEND ls_ios_file_access_info TO et_file_access_info.
    ENDLOOP.

    CALL FUNCTION 'SKWF_PHIOS_FILE_PROPERTIES_GET'
      TABLES
        components = et_file_access_info.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_ATTACHMENT_TOOL->GET_ATTACHMENTS_BY_BP_WAY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_OBJECTS                     TYPE        LTTY_OBJECT_KEY
* | [<-()] RT_LINKS_A                     TYPE        OBL_T_LINK
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD GET_ATTACHMENTS_BY_BP_WAY.
    DATA:
      lt_business_objects TYPE sibflporbt,
      ls_relation_option  TYPE obl_s_relt,
      ls_business_object  TYPE sibflporb,
      lt_relation_options TYPE obl_t_relt.

    FIELD-SYMBOLS: <ls_object>  TYPE lty_object_key.

    DATA(lo_tool) = NEW cl_crm_bp_odata_rt_attachment( ).

    ls_business_object-catid = 'BO'.

    LOOP AT it_objects ASSIGNING <ls_object>.
      ls_business_object-instid = <ls_object>-instid.
      ls_business_object-typeid = <ls_object>-typeid.
      APPEND ls_business_object TO lt_business_objects.
    ENDLOOP.

    ls_relation_option-option = 'EQ'.
    ls_relation_option-sign = 'I'.
    ls_relation_option-low = 'WCM_LINK'.
    APPEND ls_relation_option TO lt_relation_options.

    CALL METHOD lo_tool->read_links_of_objects
      EXPORTING
        it_objects          = lt_business_objects
        it_relation_options = lt_relation_options
      IMPORTING
        et_links_a          = rt_links_a.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_ATTACHMENT_TOOL->GET_ATTACHMENTS_BY_JERRY_WAY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_OBJECTS                     TYPE        LTTY_OBJECT_KEY
* | [<-()] RT_ATTACHMENTS                 TYPE        CRMT_ODATA_TASK_ATTACHMENTT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_attachments_by_jerry_way.

    DATA: lt_links            TYPE obl_t_link,
          lt_ios              TYPE skwf_ios,
          lt_iplinks          TYPE sdoklogphys,
          lt_property_result  TYPE crm_kw_propst,
          lt_file_access_info TYPE skwf_cpprps,
          lv_dummy.

    lt_links = get_links( it_objects ).

    CALL METHOD get_all_ios_with_properties
      EXPORTING
        it_links            = lt_links
      IMPORTING
        et_property_result  = lt_property_result
        et_file_access_info = lt_file_access_info
        et_ip_links         = lt_iplinks.

************* assemble
    FIELD-SYMBOLS: <property_result>  LIKE LINE OF lt_property_result,
                   <order_att_link>   LIKE LINE OF mt_order_atta_link,
                   <file_access_info> LIKE LINE OF lt_file_access_info,
                   <ip_link> LIKE LINE OF lt_iplinks.

    DATA: ls_attachment TYPE crmt_odata_task_attachment,
          ls_property   TYPE sdokproptl,
          ls_bupa_addr  TYPE bapiaddr3,
          lt_return     TYPE bapirettab,
          lv_username   TYPE bapibname-bapibname.

    LOOP AT lt_property_result ASSIGNING <property_result> WHERE objtype = 'P'.
      CLEAR: ls_attachment.
      READ TABLE lt_iplinks ASSIGNING <ip_link> WITH KEY objid_ph = <property_result>-objid.
      ASSERT sy-subrc = 0.
      READ TABLE mt_order_atta_link ASSIGNING <order_att_link> WITH KEY
         attid_lo = <ip_link>-objid_lo.
      ASSERT sy-subrc = 0.
      ls_attachment-header_guid = <order_att_link>-order_guid.
      ls_attachment-documentid = <property_result>-objid.
      ls_attachment-documentclass = <property_result>-class.

      READ TABLE lt_file_access_info WITH KEY objtype = <property_result>-objtype
          class = <property_result>-class objid = <property_result>-objid
          ASSIGNING <file_access_info>.
      IF sy-subrc = 0. " not an url
        ls_attachment-mime_type     = <file_access_info>-mimetype.
      ENDIF.
      READ TABLE <property_result>-properties WITH KEY name = 'KW_RELATIVE_URL' INTO ls_property. "#EC *
      IF sy-subrc = 0.
        ls_attachment-name = ls_property-value.
      ENDIF.

      READ TABLE <property_result>-properties WITH KEY name = 'CREATED_AT' INTO ls_property. "#EC *
      IF sy-subrc = 0.
        ls_attachment-created_at = ls_property-value.
      ENDIF.

      READ TABLE <property_result>-properties WITH KEY name = 'CREATED_BY' INTO ls_property. "#EC *
      IF sy-subrc = 0.
        lv_username = ls_property-value.
        CALL FUNCTION 'BAPI_USER_GET_DETAIL'
          EXPORTING
            username = lv_username
          IMPORTING
            address  = ls_bupa_addr
          TABLES
            return   = lt_return.
        IF ls_bupa_addr-fullname IS NOT INITIAL.
          ls_attachment-created_by = ls_bupa_addr-fullname.
        ELSE.
          ls_attachment-created_by = ls_property-value.
        ENDIF.
      ENDIF.

      ls_attachment-url = get_url( is_properties = <property_result> ).
      ls_attachment-typeid = <order_att_link>-order_bortype.
      ls_attachment-instid = <order_att_link>-order_guid.

      APPEND ls_attachment TO rt_attachments.
    ENDLOOP.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_ATTACHMENT_TOOL->GET_ATTACHMENTS_ORIGIN
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_OBJECTS                     TYPE        LTTY_OBJECT_KEY
* | [<-()] RT_ATTACHMENTS                 TYPE        CRMT_ODATA_TASK_ATTACHMENTT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_attachments_origin.
    DATA: lt_key_tab TYPE /iwbep/t_mgw_name_value_pair,
          ls_expand  TYPE crmt_odata_task_hdr_expanded.

    DATA(lo_tool) = NEW cl_crm_task_rt( ).

    LOOP AT it_objects ASSIGNING FIELD-SYMBOL(<object>).
      CLEAR: lt_key_tab, ls_expand.

      DATA(ls_key) = VALUE /iwbep/s_mgw_name_value_pair( name = 'Guid'
        value = <object>-instid ).

      APPEND ls_key TO lt_key_tab.
      CALL METHOD lo_tool->get_task_attachments
        EXPORTING
          iv_entity_name     = space
          iv_entity_set_name = space
          iv_source_name     = space
          it_key_tab         = lt_key_tab
        IMPORTING
          et_task_expanded   = ls_expand.

      APPEND LINES OF ls_expand-attachments TO rt_attachments.
    ENDLOOP.


  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_ATTACHMENT_TOOL->GET_ATTACHMENT_BY_TASK_GUID
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_TASK_GUID                   TYPE        CRMT_OBJECT_GUID
* | [<-()] RT_TASK_EXPAND                 TYPE        CRMT_ODATA_TASK_HDR_EXPANDED
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_attachment_by_task_guid.
    DATA: lt_key_tab TYPE /iwbep/t_mgw_name_value_pair.

    DATA(lo_tool) = NEW cl_crm_task_rt( ).
    DATA(ls_key) = VALUE /iwbep/s_mgw_name_value_pair( name = 'Guid' value = iv_task_guid ).
    APPEND ls_key TO lt_key_tab.
    CALL METHOD lo_tool->get_task_attachments
      EXPORTING
        iv_entity_name     = space
        iv_entity_set_name = space
        iv_source_name     = space
        it_key_tab         = lt_key_tab
      IMPORTING
        et_task_expanded   = rt_task_expand.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_ATTACHMENT_TOOL->GET_IOS_BY_KEY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_KEY                         TYPE        SIBFBORIID
* | [<-()] RS_IOS                         TYPE        SKWF_IO
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_IOS_BY_KEY.
    FIND REGEX '([FLP])/([\w]+)/([\w]+)' IN iv_key SUBMATCHES
       rs_ios-objtype rs_ios-class rs_ios-objid.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_CRM_ATTACHMENT_TOOL->GET_LINKS
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_OBJECTS                     TYPE        LTTY_OBJECT_KEY
* | [<-()] RT_LINKS_A                     TYPE        OBL_T_LINK
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_LINKS.
    DATA: lv_bor_type TYPE sibftypeid.
    FIELD-SYMBOLS: <object> LIKE LINE OF it_objects.

    CHECK it_objects IS NOT INITIAL.

    READ TABLE it_objects ASSIGNING <object> INDEX 1.

    lv_bor_type = <object>-typeid.
    SELECT brelguid instid_a typeid_a logsys_a catid_a arch_a
      instid_b typeid_b logsys_b catid_b arch_b reltype utctime homesys
            INTO CORRESPONDING FIELDS OF TABLE rt_links_a
             FROM skwg_brel
             FOR ALL ENTRIES IN it_objects
             WHERE instid_a  = it_objects-instid AND
                   typeid_a      = lv_bor_type AND
                   catid_a  = 'BO' AND
                   reltype  = 'WCM_LINK'.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_ATTACHMENT_TOOL->GET_STORAGE_BY_FM
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_storage_by_fm.
    DATA: ls_key TYPE skwf_key,
          ls_io  TYPE skwf_io.

    ls_key-key_text = 'L/CRM_L_ORD/FA163EE56C3A1EE5AFCAF9FF31FFFE64'.

    start( ).
    DO mv_regular_test_num TIMES.
      CALL FUNCTION 'SKWF_UTIL_IO_FIND_BY_KEY'
        EXPORTING
          key = ls_key
        IMPORTING
          io  = ls_io.
    ENDDO.

    stop( 'Function call performance with testing loop number: ' && mv_regular_test_num ).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_ATTACHMENT_TOOL->GET_STORAGE_BY_REGULAR
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_storage_by_regular.
    DATA: lv_input TYPE string VALUE 'L/CRM_L_ORD/FA163EE56C3A1EE5AFCAF9FF31FFFE64',
          lv_type  TYPE skwf_ioty,
          lv_class TYPE sdok_class,
          lv_guid  TYPE sdok_docid.

    start( ).
    DO mv_regular_test_num TIMES.
       FIND REGEX '([FLP])/([\w]+)/([\w]+)$' IN lv_input SUBMATCHES lv_type lv_class lv_guid.
    ENDDO.
    stop( 'Regular expression performance with testing loop number: ' && mv_regular_test_num ).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_CRM_ATTACHMENT_TOOL->GET_URL
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_PROPERTIES                  TYPE        CRM_KW_PROPS
* | [<-()] RV_URL                         TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_url.
    DATA: lt_url TYPE sdokcompurls,
          ls_url TYPE sdokcomurl.

    CHECK is_properties-class = crmkw_class-phio_url.  "document of type URL

    CALL FUNCTION 'SDOK_PHIO_GET_URL_FOR_GET'
      EXPORTING
        object_id                  = is_properties-object
        web_applic_server_url_only = 'X'
      IMPORTING
        urls                       = lt_url
      EXCEPTIONS
        not_existing               = 1
        not_authorized             = 2
        no_content                 = 3
        bad_storage_type           = 4
        no_urls_available          = 5
        OTHERS                     = 6.

    IF sy-subrc <> 0.
      CLEAR rv_url.
      RETURN.
    ENDIF.

    READ TABLE lt_url INTO ls_url INDEX 1.
    IF sy-subrc = 0.
      rv_url = ls_url-url.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_CRM_ATTACHMENT_TOOL->HANDLE_FOLDER
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_FOLDERS                     TYPE        SKWF_IOS
* | [<-->] CT_LOIOS                       TYPE        SKWF_IOS
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD handle_folder.
    DATA: lt_ios        TYPE skwf_ios,
          lv_order_guid TYPE ty_order_atta_link-order_guid,
          lv_order_type TYPE ty_order_atta_link-order_bortype.

    FIELD-SYMBOLS: <folder>               LIKE LINE OF it_folders,
                   <io>                   LIKE LINE OF lt_ios,
                   <order_att_link>       LIKE LINE OF mt_order_atta_link,
                   <link_for_folder_file> LIKE <order_att_link>.

    LOOP AT it_folders ASSIGNING <folder>.
      CLEAR: lt_ios.
      READ TABLE mt_order_atta_link ASSIGNING <order_att_link>
        WITH KEY attid_lo = <folder>-objid.
      ASSERT sy-subrc = 0.
      lv_order_guid = <order_att_link>-order_guid.
      lv_order_type = <order_att_link>-order_bortype.

      CALL FUNCTION 'SKWF_FOLDER_SUB_IOS_GET'
        EXPORTING
          folder     = <folder>
          io_type    = 'L'
          x_attached = 'X'
          x_linked   = 'X'
          x_hidden   = 'X'
        TABLES
          ios        = lt_ios.
      LOOP AT lt_ios ASSIGNING <io>.
*         Remove mapping-record Order<->Folder (only one time)
        AT FIRST.
          DELETE mt_order_atta_link WHERE attid_lo = <order_att_link>-attid_lo.
        ENDAT.

        IF <io>-objtype = 'L'.
          APPEND <io> TO ct_loios.
* I042416: construct link between one order and attachment which is NESTED in the folder
          APPEND INITIAL LINE TO mt_order_atta_link ASSIGNING <link_for_folder_file>.
          <link_for_folder_file>-atta_type = <io>-objtype.
          <link_for_folder_file>-attid_lo = <io>-objid.
          <link_for_folder_file>-order_guid = lv_order_guid.
          <link_for_folder_file>-order_bortype = lv_order_type.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_ATTACHMENT_TOOL->PASS_BY_REF
* +-------------------------------------------------------------------------------------------------+
* | [<---] ES_RESULT                      TYPE        TADIR
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method PASS_BY_REF.
    CLEAR: es_result.

    es_result-obj_name = 'ZJERRY'.
    es_result-author = 'WANGJER'.
    es_result-devclass = '$TMP'.
    es_result-object = 'CLAS'.
    es_result-cproject = 'TEST'.
    es_result-component = 'CSS'.
    es_result-created_on = '20110111'.
    es_result-masterlang = 'EN'.
    es_result-srcsystem = 'AG3'.
    es_result-pgmid = 'R3TR'.


  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_ATTACHMENT_TOOL->PASS_BY_VALUE
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RS_RESULT                      TYPE        TADIR
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method PASS_BY_VALUE.
    CLEAR: rs_result.

    rs_result-obj_name = 'ZJERRY'.
    rs_result-author = 'WANGJER'.
    rs_result-devclass = '$TMP'.
    rs_result-object = 'CLAS'.
    rs_result-cproject = 'TEST'.
    rs_result-component = 'CSS'.
    rs_result-created_on = '20110111'.
    rs_result-masterlang = 'EN'.
    rs_result-srcsystem = 'AG3'.
    rs_result-pgmid = 'R3TR'.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_ATTACHMENT_TOOL->START
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method START.
    GET RUN TIME FIELD mv_start.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_ATTACHMENT_TOOL->STOP
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_MESSAGE                     TYPE        STRING(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method STOP.
    GET RUN TIME FIELD mv_end.

    mv_end = mv_end - mv_start.

    DATA: lv_text TYPE string.

    IF iv_message IS SUPPLIED.
       lv_text = iv_message.
    ENDIF.

    lv_text = lv_text && ' consumed time: ' && mv_end.

    WRITE: / lv_text COLOR COL_NEGATIVE.
  endmethod.
ENDCLASS.