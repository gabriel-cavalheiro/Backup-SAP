DATA : st_address TYPE usaddress,
       st_adr6    TYPE adr6.

CALL FUNCTION 'SUSR_USER_READ'
  EXPORTING
    user_name            = sy-uname
  IMPORTING
    user_address         = st_address
  EXCEPTIONS
    user_name_not_exists = 1
    internal_error       = 2
    OTHERS               = 3.


SELECT SINGLE *
  FROM adr6
  INTO st_adr6
  WHERE addrnumber = st_address-addrnumber
  AND   persnumber = st_address-persnumber.