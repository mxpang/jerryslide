REPORT zget_assigned_unit.

DATA: lt_org_tab TYPE hrsettab OCCURS 0.
CALL FUNCTION 'RH_GET_ASSIGNED_OBJECTS'
  EXPORTING
    otype            = 'CP'
    objid            = '50003657'
    wegid            = 'CP_012_O'
    sbegd            = '20150702'
    sendd            = '20150702'
  TABLES
    assigned_objects = lt_org_tab.
BREAK-POINT.