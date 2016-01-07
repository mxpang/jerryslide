class ZCL_CRM_TASK_DOC_HISTORY_TOOL definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR .
  methods GET_HISTORIES_ORIGIN
    importing
      !IT_TASK_GUIDS type CRMT_OBJECT_GUID_TAB_UNSORTED
    returning
      value(RT_DOC_LINKS) type CRMT_DOC_FLOW_DB_WRKT .
  methods GET_HISTORIES_WITH_NUMBER
    importing
      !IV_NUM type INT4
    returning
      value(RT_DOC_LINKS) type CRMT_DOC_FLOW_DB_WRKT .
  methods GET_HISTORIES_OPT
    importing
      !IT_TASK_GUIDS type SWO_TYPEID_LIST
    returning
      value(RT_DOC_LINKS) type CRMT_DOC_FLOW_LINK .
  methods COMPARE
    importing
      !IT_ORIGIN type CRMT_DOC_FLOW_DB_WRKT
      !IT_OPT type CRMT_DOC_FLOW_LINK
    returning
      value(RV_EQUAL) type ABAP_BOOL .
  methods START .
  methods STOP .
protected section.
private section.

  data MT_GUID_TABS type CRMT_OBJECT_GUID_TAB_UNSORTED .
  data MV_START type I .
  data MV_STOP type I .
ENDCLASS.



CLASS ZCL_CRM_TASK_DOC_HISTORY_TOOL IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_TASK_DOC_HISTORY_TOOL->COMPARE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_ORIGIN                      TYPE        CRMT_DOC_FLOW_DB_WRKT
* | [--->] IT_OPT                         TYPE        CRMT_DOC_FLOW_LINK
* | [<-()] RV_EQUAL                       TYPE        ABAP_BOOL
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method COMPARE.
    rv_equal = abap_false.
    CHECK lines( it_origin ) = lines( it_opt ).

    LOOP AT it_origin ASSIGNING FIELD-SYMBOL(<origin>).
      READ TABLE it_opt ASSIGNING FIELD-SYMBOL(<opt>) WITH KEY objkey_a = <origin>-objkey_a
       objkey_b = <origin>-objkey_b.
      IF sy-subrc <> 0.
         RETURN.
      ENDIF.
    ENDLOOP.

    rv_equal = abap_true.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_TASK_DOC_HISTORY_TOOL->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method CONSTRUCTOR.
    append 'FA163EE56C3A1EE5AD89008F1DBB0B45' TO  mt_guid_tabs. "31318"
    append 'FA163EE56C3A1EE5ADA0457B58202108' tO  mt_guid_tabs. "31331
    append 'FA163EE56C3A1EE5A5E673B95A344AC5' TO  mt_guid_tabs. "29944
    APPEND 'FA163EE56C3A1EE5AD8901590BA7CB46' TO mt_guid_tabs.  "31319
    APPEND 'FA163EE56C3A1EE5ADA0AD5FB303C1DF' TO mt_guid_tabs.  "31332
    APPEND 'FA163EE56C3A1EE5ADA0AE5AB83B01E1' TO mt_guid_Tabs.  "31333
    append 'FA163EE56C3A1EE5ADA0D8608C98A232' TO mt_guid_tabs.  "31335
    append 'FA163EE56C3A1EE5ADA0D92F87C10232' TO mt_guid_tabs.  "31336
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_TASK_DOC_HISTORY_TOOL->GET_HISTORIES_OPT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_TASK_GUIDS                  TYPE        SWO_TYPEID_LIST
* | [<-()] RT_DOC_LINKS                   TYPE        CRMT_DOC_FLOW_LINK
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_histories_opt.
    DATA: lt_orbreltyp  TYPE TABLE OF orbreltyp,
          lt_relrange   TYPE relrange,
          lt_bor_object TYPE trl_borid,
          lt_rolrange   TYPE rolrange,
          ls_orbreltyp  LIKE LINE OF lt_orbreltyp,
          ls_relrange   LIKE LINE OF lt_relrange.

    SELECT reltype FROM orbreltyp INTO CORRESPONDING FIELDS OF TABLE lt_orbreltyp WHERE dbtable = 'SMW0REL'.

    ls_relrange-sign   = 'E'.
    ls_relrange-option = 'EQ'.

    LOOP AT lt_orbreltyp INTO ls_orbreltyp.
      ls_relrange-low    = ls_orbreltyp-reltype.
      INSERT ls_relrange INTO TABLE lt_relrange.
    ENDLOOP.

    SELECT objkey objtype logsys
         FROM srrelroles
         INTO TABLE lt_bor_object
         FOR ALL ENTRIES IN it_task_guids
         WHERE objkey = it_task_guids-table_line.

    CALL FUNCTION 'NREL_GET_RELATIONS_FOR_OBJLIST'
      EXPORTING
        it_object    = lt_bor_object
        it_rolerange = lt_rolrange
        it_relrange  = lt_relrange
      TABLES
        links        = rt_doc_links.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_TASK_DOC_HISTORY_TOOL->GET_HISTORIES_ORIGIN
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_TASK_GUIDS                  TYPE        CRMT_OBJECT_GUID_TAB_UNSORTED
* | [<-()] RT_DOC_LINKS                   TYPE        CRMT_DOC_FLOW_DB_WRKT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD GET_HISTORIES_ORIGIN.
    DATA: lt_docs LIKE rt_doc_links.

    LOOP AT it_task_guids ASSIGNING FIELD-SYMBOL(<guid>).
      CALL FUNCTION 'CRM_DOC_FLOW_READ_DB'
        EXPORTING
          iv_header_guid = <guid>
        IMPORTING
          et_doc_links   = lt_docs
        EXCEPTIONS
          error_occurred = 1
          OTHERS         = 2.

      CHECK sy-subrc = 0.
      INSERT LINES OF lt_docs INTO TABLE rt_doc_links.
    ENDLOOP.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_TASK_DOC_HISTORY_TOOL->GET_HISTORIES_WITH_NUMBER
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_NUM                         TYPE        INT4
* | [<-()] RT_DOC_LINKS                   TYPE        CRMT_DOC_FLOW_DB_WRKT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_HISTORIES_WITH_NUMBER.

    DATA: lt_guid LIKE mt_guid_tabs.

    LOOP AT mt_guid_tabs ASSIGNING FIELD-SYMBOL(<guid>) FROM 1 TO iv_num.
       APPEND <guid> TO lt_guid.
    ENDLOOP.

    WRITE: / 'guid counts: ' , lines( lt_guid ).
    rt_doc_links = GET_HISTORIES_origin( lt_guid ).
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_TASK_DOC_HISTORY_TOOL->START
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method START.
    GET RUN TIME FIELD mv_start.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_TASK_DOC_HISTORY_TOOL->STOP
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method STOP.
     GET RUN TIME FIELD mv_stop.
     mv_stop = mv_stop - mv_start.
     WRITE:/ 'time consumed: ' COLOR COL_NEGATIVE, mv_stop.
  endmethod.
ENDCLASS.