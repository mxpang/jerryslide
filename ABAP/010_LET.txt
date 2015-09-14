*&---------------------------------------------------------------------*
*& Report ZLET
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZLET.

CLASS demo DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS main.
ENDCLASS.

CLASS demo IMPLEMENTATION.
  METHOD main.
    TYPES text TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    cl_demo_output=>new( )->write(
     VALUE text( LET it = `Jerry` IN
                   ( |To { it } is to do|          )
                   ( |To { it }, or not to { it }| )
                   ( |To do is to { it }|          )
                   ( |Do { it } do { it } do|      ) )
    )->display( ).
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  demo=>main( ).