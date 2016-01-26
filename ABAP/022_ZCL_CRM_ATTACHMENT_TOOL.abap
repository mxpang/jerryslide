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

  data MT_BP_TEST_DATA type LTTY_OBJECT_KEY .

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
      value(RT_LINKS_A) type OBL_T_LINK .
  methods COMPARE_LINK
    importing
      !IT_BP type OBL_T_LINK
      !IT_JERRY type OBL_T_LINK
    returning
      value(RV_EQUAL) type ABAP_BOOL .
  methods GET_STORAGE_BY_REGULAR .
protected section.
private section.

  data MV_START type I .
  data MV_END type I .
  data MV_REGULAR_TEST_NUM type INT4 value 10000 ##NO_TEXT.
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

    APPEND INITIAL LINE TO mt_bp_test_data ASSIGNING <item>.
    <item>-typeid = 'BUS2000125'.
    <item>-instid = 'FA163EE56C3A1ED5AE9AE011B059611E'.

    APPEND <item> TO mt_bp_test_data.

    <item>-instid = 'FA163EE56C3A1EE5AD89008F1DBB0B45'.
    APPEND <item> TO mt_bp_test_data.

  endmethod.


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
* | [<-()] RT_LINKS_A                     TYPE        OBL_T_LINK
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_attachments_by_jerry_way.

    CHECK it_objects IS NOT INITIAL.

    READ TABLE it_objects ASSIGNING FIELD-SYMBOL(<object>) INDEX 1.

    DATA(lv_bor_type) = <object>-typeid.
    SELECT brelguid
                 instid_a typeid_a logsys_a catid_a arch_a
                 instid_b typeid_b logsys_b catid_b arch_b
                 reltype utctime homesys
            INTO CORRESPONDING FIELDS OF TABLE rt_links_a
             FROM skwg_brel
             FOR ALL ENTRIES IN it_objects
             WHERE instid_a  = it_objects-instid AND
                   typeid_a      = lv_bor_type AND
                   catid_a  = 'BO' AND
                   reltype  = 'WCM_LINK'.
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