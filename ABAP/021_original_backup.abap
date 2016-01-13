  METHOD get_expanded_entityset_origin.
    DATA: lr_entityset             TYPE REF TO data,
          lt_expanded_nodes        TYPE /iwbep/if_mgw_odata_expand=>ty_t_node_children,
          ls_expanded_node         LIKE LINE OF lt_expanded_nodes,
          lv_entity_set            TYPE string,
          lv_entity_type           TYPE string,
          lt_key_tab               TYPE /iwbep/t_mgw_name_value_pair,
          ls_key_tab               TYPE /iwbep/s_mgw_name_value_pair,
          lr_expanded_entityset    TYPE REF TO data,
          ls_response_context      TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_mgw_response_entity_cntxt,
          ls_response_context2     TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_mgw_response_context,
          lt_expanded_clauses	     TYPE string_table,
          lt_expanded_tech_clauses TYPE string_table,
          lo_tech_request_context  TYPE REF TO /iwbep/if_mgw_req_entity,
          lo_tech_request_context2 TYPE REF TO /iwbep/if_mgw_req_entityset,
          lr_task_impl             TYPE REF TO cl_crm_task_rt,
          lt_doc_history           TYPE cl_crm_task_mpc=>tt_documenthistory,
          lr_doc_history           TYPE REF TO data,
          lt_task_status           TYPE cl_crm_task_mpc=>tt_taskstatus,
          lr_task_status           TYPE REF TO data,
          lr_log                   TYPE REF TO data,
          lr_followup_proc         TYPE REF TO data,
          ls_expanded_tech_clauses TYPE LINE OF string_table,
          lo_expand_node           TYPE REF TO /iwbep/cl_mgw_expand_node,
          lv_nav_tech_name         TYPE string,
          lv_obj_guid              TYPE crmt_object_guid,
          lt_log                   TYPE crmt_odata_task_logst,
          lt_attachment            TYPE crmt_odata_task_attachmentt,
          lr_attachment            TYPE REF TO data,
          lt_followup_proc_list    TYPE crmt_odata_task_followup_typet.

    FIELD-SYMBOLS: <lt_entity_set>          TYPE ANY TABLE,
                   <lt_expanded_entity_set> TYPE ANY TABLE,
                   <ls_expanded_entity_set> TYPE any,
                   <lr_entity_set>          TYPE any,
                   <lv_temp>                TYPE any,
                   <lv_temp2>               TYPE any,
                   <ls_data>                TYPE any.

    me->/iwbep/if_mgw_appl_srv_runtime~get_entityset(
      EXPORTING
        iv_entity_name               =     iv_entity_name
        iv_entity_set_name           =     iv_entity_set_name
        iv_source_name               =     iv_source_name
        it_filter_select_options     =     it_filter_select_options
        it_order                     =     it_order
        is_paging                    =     is_paging
        it_navigation_path           =     it_navigation_path
        it_key_tab                   =     it_key_tab
        iv_filter_string             =     iv_filter_string
        iv_search_string             =     iv_search_string
        io_tech_request_context      =     io_tech_request_context
      IMPORTING
        er_entityset                 =     lr_entityset
        es_response_context          =     es_response_context
    ).

    ASSIGN lr_entityset->* TO <lt_entity_set>.
    ASSIGN er_entityset->* TO <lt_expanded_entity_set>.
    MOVE-CORRESPONDING <lt_entity_set> TO <lt_expanded_entity_set>.

    IF <lt_entity_set> IS INITIAL.
      RETURN.
    ENDIF.

    lo_tech_request_context ?= io_tech_request_context.

    lt_expanded_nodes = io_expand->get_children( ).
    LOOP AT lt_expanded_nodes INTO ls_expanded_node.
      lv_entity_type = ls_expanded_node-node->get_tech_entity_type( ).
      lv_entity_set = ls_expanded_node-node->get_tech_entity_set( ).
      lo_expand_node ?= ls_expanded_node-node.
      lv_nav_tech_name = lo_expand_node->/iwbep/if_mgw_tech_expand_node~get_nav_prop_name( ).
      TRANSLATE lv_nav_tech_name TO UPPER CASE.

      LOOP AT <lt_expanded_entity_set> ASSIGNING <ls_expanded_entity_set>.
        CLEAR: lt_key_tab, ls_key_tab.
        ls_key_tab-name = 'Guid'.
        ASSIGN COMPONENT 'GUID' OF STRUCTURE <ls_expanded_entity_set> TO <lv_temp>.
        ls_key_tab-value =  <lv_temp>.
        APPEND ls_key_tab TO lt_key_tab.
        IF lv_entity_type EQ 'ComplexNotes'.
          CLEAR: lr_expanded_entityset,ls_response_context,lt_expanded_clauses,lt_expanded_tech_clauses.
          me->/iwbep/if_mgw_appl_srv_runtime~get_expanded_entity(
            EXPORTING
              iv_entity_name               =     iv_entity_name
              iv_entity_set_name           =     iv_entity_set_name
              iv_source_name               =     iv_source_name
              it_key_tab                   =     lt_key_tab
              it_navigation_path           =     it_navigation_path
              io_expand                    =     io_expand
              io_tech_request_context      =     lo_tech_request_context
            IMPORTING
              er_entity                    =     lr_expanded_entityset
              es_response_context          =     ls_response_context
              et_expanded_clauses          =     lt_expanded_clauses
              et_expanded_tech_clauses     =     lt_expanded_tech_clauses
          ).

          IF lr_expanded_entityset IS NOT INITIAL.
            ASSIGN lr_expanded_entityset->* TO <lr_entity_set>.
            IF <lr_entity_set> IS NOT INITIAL.
              ASSIGN COMPONENT 'COMPLEXNOTES' OF STRUCTURE <lr_entity_set> TO <lv_temp>.
              IF sy-subrc EQ 0.
                ASSIGN COMPONENT 'DOCUMENTNOTES' OF STRUCTURE <ls_expanded_entity_set> TO <lv_temp2>.
                IF sy-subrc EQ 0.
                  MOVE-CORRESPONDING <lv_temp> TO <lv_temp2>.
                ENDIF.
              ENDIF.
            ENDIF.

          ENDIF.

          APPEND LINES OF lt_expanded_clauses TO et_expanded_clauses.
          APPEND LINES OF lt_expanded_tech_clauses TO et_expanded_tech_clauses.

          DELETE ADJACENT DUPLICATES FROM et_expanded_clauses.
          DELETE ADJACENT DUPLICATES FROM et_expanded_tech_clauses.

        ELSEIF lv_entity_type EQ 'DocumentHistory'.
          CLEAR: lt_doc_history,ls_response_context2.
          IF lr_task_impl  IS NOT BOUND.
            CREATE OBJECT lr_task_impl.
          ENDIF.

          CALL METHOD lr_task_impl->get_document_history
            EXPORTING
              iv_entity_name           = lv_entity_type
              iv_entity_set_name       = lv_entity_set
              iv_source_name           = iv_source_name
              it_filter_select_options = it_filter_select_options
              is_paging                = is_paging
              it_key_tab               = lt_key_tab
              it_navigation_path       = it_navigation_path
              it_order                 = it_order
              iv_filter_string         = iv_filter_string
              iv_search_string         = iv_search_string
              io_tech_request_context  = io_tech_request_context
            IMPORTING
              et_entityset             = lt_doc_history
              es_response_context      = ls_response_context2.

          IF lt_doc_history IS NOT INITIAL.
            CREATE DATA lr_doc_history LIKE lt_doc_history.
            ASSIGN lr_doc_history->* TO <ls_data>.
            <ls_data> = lt_doc_history.

            ASSIGN COMPONENT 'DOCUMENTHISTORIES' OF STRUCTURE <ls_expanded_entity_set> TO <lv_temp>.
            MOVE-CORRESPONDING <ls_data> TO <lv_temp>.
          ENDIF.

          ls_expanded_tech_clauses = lv_nav_tech_name. "'DOCUMENTHISTORIES'.
          APPEND ls_expanded_tech_clauses TO et_expanded_tech_clauses.
          DELETE ADJACENT DUPLICATES FROM et_expanded_tech_clauses.

        ELSEIF lv_entity_type EQ 'Attachment'.
          CLEAR: lt_attachment,ls_response_context2.
          CALL METHOD me->taskattachmentse_get_entityset
            EXPORTING
              iv_entity_name           = lv_entity_type
              iv_entity_set_name       = lv_entity_set
              iv_source_name           = iv_source_name
              it_key_tab               = lt_key_tab
              it_filter_select_options = it_filter_select_options
              is_paging                = is_paging
              it_navigation_path       = it_navigation_path
              it_order                 = it_order
              iv_filter_string         = iv_filter_string
              iv_search_string         = iv_search_string
              io_tech_request_context  = lo_tech_request_context2
            IMPORTING
              et_entityset             = lt_attachment
              es_response_context      = ls_response_context2.

          IF lt_attachment IS NOT INITIAL.
            CREATE DATA lr_attachment LIKE lt_attachment.
            ASSIGN lr_attachment->* TO <ls_data>.
            <ls_data> = lt_attachment.
          ENDIF.

          IF <ls_data> IS ASSIGNED.
            ASSIGN COMPONENT 'ATTACHMENTS' OF STRUCTURE <ls_expanded_entity_set> TO <lv_temp>.
            MOVE-CORRESPONDING <ls_data> TO <lv_temp>.
          ENDIF.

          ls_expanded_tech_clauses = lv_nav_tech_name."Attachments"
          APPEND ls_expanded_tech_clauses TO et_expanded_tech_clauses.
          DELETE ADJACENT DUPLICATES FROM et_expanded_tech_clauses.

        ELSEIF lv_entity_type EQ 'TaskLog'.
          CLEAR: lt_log,ls_response_context2.
          me->tasklogs_get_entityset(
            EXPORTING
              iv_entity_name               = lv_entity_type
              iv_entity_set_name           = lv_entity_set
              iv_source_name               = iv_source_name
              it_filter_select_options     = it_filter_select_options
              is_paging                    = is_paging
              it_key_tab                   = lt_key_tab
              it_navigation_path           = it_navigation_path
              it_order                     = it_order
              iv_filter_string             = iv_filter_string
              iv_search_string             = iv_search_string
              io_tech_request_context      = lo_tech_request_context2
            IMPORTING
              et_entityset                 = lt_log
              es_response_context          = ls_response_context2
          ).

          IF lt_log IS NOT INITIAL.
            CREATE DATA lr_log LIKE lt_log.
            ASSIGN lr_log->* TO <ls_data>.
            <ls_data> = lt_log.
          ENDIF.

          IF <ls_data> IS ASSIGNED.
            ASSIGN COMPONENT 'DocumentApplicationLogs' OF STRUCTURE <ls_expanded_entity_set> TO <lv_temp>.
            MOVE-CORRESPONDING <ls_data> TO <lv_temp>.
          ENDIF.

          ls_expanded_tech_clauses = lv_nav_tech_name."'TASKLOGSET'.
          APPEND ls_expanded_tech_clauses TO et_expanded_tech_clauses.
          DELETE ADJACENT DUPLICATES FROM et_expanded_tech_clauses.

        ELSEIF lv_entity_type EQ 'TaskStatus'.

          CLEAR: lt_task_status,ls_response_context2.
          me->taskstatuses_get_entityset(
            EXPORTING
              iv_entity_name           = lv_entity_type
              iv_entity_set_name       = lv_entity_set
              iv_source_name           = iv_source_name
              it_filter_select_options = it_filter_select_options
              is_paging                = is_paging
              it_key_tab               = lt_key_tab
              it_navigation_path       = it_navigation_path
              it_order                 = it_order
              iv_filter_string         = iv_filter_string
              iv_search_string         = iv_search_string
              io_tech_request_context  = io_tech_request_context
            IMPORTING
              et_entityset             = lt_task_status
              es_response_context      = ls_response_context2
             ).

          IF lt_task_status IS NOT INITIAL.
            CREATE DATA lr_task_status LIKE lt_task_status.
            ASSIGN lr_task_status->* TO <ls_data>.
            <ls_data> = lt_task_status.

            ASSIGN COMPONENT 'DocumentNextUserStatuses' OF STRUCTURE <ls_expanded_entity_set> TO <lv_temp>.
            MOVE-CORRESPONDING <ls_data> TO <lv_temp>.
          ENDIF.

          ls_expanded_tech_clauses = lv_nav_tech_name."'DocumentNextUserStatuses'.
          APPEND ls_expanded_tech_clauses TO et_expanded_tech_clauses.
          DELETE ADJACENT DUPLICATES FROM et_expanded_tech_clauses.

        ELSEIF lv_entity_type EQ 'TaskFollowUpTransactionTypeCollection'.
          CLEAR: lt_followup_proc_list,ls_response_context2.
          me->get_taks_followup_tanstypes(
            EXPORTING
              iv_entity_name           = lv_entity_type
              iv_entity_set_name       = lv_entity_set
              iv_source_name           = iv_source_name
              it_filter_select_options = it_filter_select_options
              is_paging                = is_paging
              it_key_tab               = lt_key_tab
              it_navigation_path       = it_navigation_path
              it_order                 = it_order
              iv_filter_string         = iv_filter_string
              iv_search_string         = iv_search_string
              io_tech_request_context  = io_tech_request_context
            IMPORTING
              et_entityset             = lt_followup_proc_list
              es_response_context      = ls_response_context2
             ).
          IF lt_followup_proc_list IS NOT INITIAL.
            CREATE DATA lr_followup_proc LIKE lt_followup_proc_list.
            ASSIGN lr_followup_proc->* TO <ls_data>.
            <ls_data> = lt_followup_proc_list.
          ENDIF.

          ls_expanded_tech_clauses = lv_nav_tech_name.
          APPEND ls_expanded_tech_clauses TO et_expanded_tech_clauses.
          DELETE ADJACENT DUPLICATES FROM et_expanded_tech_clauses.

        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.