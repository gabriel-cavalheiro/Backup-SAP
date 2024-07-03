TYPES: BEGIN OF y_log,
         message(256)  TYPE c,
       END OF y_log.

DATA: t_log    TYPE TABLE OF y_log,

" alimentar a T_log com as mensagens de erro "

FORM z4_log_popup.

    DATA: t_fieldcat_log TYPE slis_t_fieldcat_alv,
          w_fieldcat_log TYPE slis_fieldcat_alv.
    DATA: t_exclud TYPE slis_t_extab.
  
    IF NOT t_log[] IS INITIAL.
  
      CLEAR w_fieldcat_log.
      w_fieldcat_log-fieldname    = 'MESSAGE'.
      w_fieldcat_log-tabname      = 'T_LOG'.
      w_fieldcat_log-rollname     = 'MESSAGE'.
      w_fieldcat_log-outputlen    = 200.
      w_fieldcat_log-no_out       = space.
      APPEND w_fieldcat_log TO t_fieldcat_log.
  
      CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
        EXPORTING
          i_title               = TEXT-006
          i_selection           = space
          i_zebra               = 'X'
          i_tabname             = 'T_LOG'
          it_fieldcat           = t_fieldcat_log[]
          i_screen_start_line   = 5
          i_screen_end_line     = 25
          i_screen_start_column = 10
          i_screen_end_column   = 120
        TABLES
          t_outtab              = t_log
        EXCEPTIONS
          program_error         = 1
          OTHERS                = 2.
  
    ENDIF.

    l
ENDFORM.