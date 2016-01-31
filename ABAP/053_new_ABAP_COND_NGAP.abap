*&---------------------------------------------------------------------*
*& Report ZCOND
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZCOND.

DATA: lv_string TYPE string,
      lv_count TYPE int4 value 1.

lv_string = 'Jerry' &&  COND #( WHEN lv_count = 1 THEN ' Hello' ELSE 'default'  ).

WRITE:/ lv_string.

RETURN.
cl_demo_output=>display(
  VALUE string_table(
    FOR i = 1 WHILE i <= 100 (
      COND string( LET r3 = i MOD 3
                       r5 = i MOD 5 IN
                   WHEN r3 = 0 AND r5 = 0 THEN |FIZZBUZZ|
                   WHEN r3 = 0            THEN |FIZZ|
                   WHEN r5 = 0            THEN |BUZZ|
                   ELSE i ) ) ) ).