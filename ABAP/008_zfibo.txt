*&---------------------------------------------------------------------*
*& Report ZFIBO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFIBO.

TYPES: zcd_int_tab TYPE STANDARD TABLE OF i WITH key TABLE_LINE.

CLASS lcl_fibonacci DEFINITION.
  PUBLIC SECTION.
  METHODS fibonacci
    IMPORTING !n TYPE i
    RETURNING
      VALUE(fib_numbers) TYPE zcd_int_tab.
ENDCLASS.

CLASS lcl_fibonacci IMPLEMENTATION.
  METHOD fibonacci.
    fib_numbers = COND #( WHEN n = 0
                            THEN VALUE #( ( |0| ) )
                          WHEN n = 1
                            THEN VALUE #( ( |0| ) ( |1| ) )
                          ELSE
                            VALUE #( LET fn1 = fibonacci( n - 1 )
                                         x   = fn1[ lines( fn1 ) ]
                                         y   = fn1[ lines( fn1 ) - 1 ]
                                      IN
                                      ( LINES OF fn1 ) ( x + y ) ) ).
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  cl_demo_output=>display( NEW lcl_fibonacci( )->fibonacci( 10 ) ).