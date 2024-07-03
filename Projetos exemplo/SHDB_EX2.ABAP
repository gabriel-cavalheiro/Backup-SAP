TYPES y_bdcdata_tab TYPE STANDARD TABLE OF bdcdata.
DATA: t_bdcdata TYPE STANDARD TABLE OF bdcdata,
      l_fval    TYPE bdcdata-fval.
DATA w_opt      TYPE ctu_params.
DATA t_bdcmsgcoll TYPE STANDARD TABLE OF bdcmsgcoll.

w_opt-dismode   = 'A'.
w_opt-updmode   = 'A'.
w_opt-cattmode  = ' '.
w_opt-defsize   = 'X'.
w_opt-racommit  = 'X'.
w_opt-nobinpt   = 'X'.
w_opt-nobiend   = 'X'.

PERFORM zf_fill_prog_and_screen USING 'SAPLBAS0'                '0300'                        t_bdcdata.
PERFORM zf_fill_field_and_value USING 'BDC_CURSOR'              'ASMD-ASNUM'                  t_bdcdata.
PERFORM zf_fill_field_and_value USING 'BDC_OKCODE'              '=SWTM'                       t_bdcdata.
PERFORM zf_fill_field_and_value USING 'BDC_SUBSCR'              '0320'                        t_bdcdata.
PERFORM zf_fill_field_and_value USING 'RM63T-SPRAS'             'PT'                          t_bdcdata.
PERFORM zf_fill_field_and_value USING 'BDC_SUBSCR'              '0350'                        t_bdcdata.

PERFORM zf_fill_prog_and_screen USING 'SAPLBAS0'                '0300'                        t_bdcdata.
PERFORM zf_fill_field_and_value USING 'BDC_CURSOR'              'ASMD-ASNUM'                  t_bdcdata.
PERFORM zf_fill_field_and_value USING 'BDC_OKCODE'              '=GRUPOFORN'                  t_bdcdata.
PERFORM zf_fill_field_and_value USING 'BDC_SUBSCR'              '0320'                        t_bdcdata.
PERFORM zf_fill_field_and_value USING 'BDC_SUBSCR'              '0350'                        t_bdcdata.

l_fval = 23456.

PERFORM zf_fill_prog_and_screen USING 'SAPLZGMM_GRP_FORNECEDOR' '9001'           t_bdcdata.
PERFORM zf_fill_field_and_value USING 'BDC_OKCODE'              '=BTN_OK'        t_bdcdata.
PERFORM zf_fill_field_and_value USING 'BDC_CURSOR'              'V_ZZGRP_FORNEC' t_bdcdata.
PERFORM zf_fill_field_and_value USING 'V_ZZGRP_FORNEC'          l_fval           t_bdcdata.

CALL TRANSACTION 'AC02' USING         t_bdcdata          "#EC CI_CALLTA
              OPTIONS FROM  w_opt
              MESSAGES INTO t_bdcmsgcoll.

FORM zf_fill_prog_and_screen USING VALUE(p_program) TYPE bdcdata-program
                                   VALUE(p_dynpro)  TYPE bdcdata-dynpro
                                   p_bdcdata_tab    TYPE y_bdcdata_tab.

  DATA w_bdcdata TYPE bdcdata.
  w_bdcdata-program  = p_program.
  w_bdcdata-dynpro   = p_dynpro.
  w_bdcdata-dynbegin = abap_true.
  APPEND w_bdcdata TO p_bdcdata_tab.

ENDFORM.                    "ZF_FILL_PROG_AND_SCREEN

*&---------------------------------------------------------------------*
*&      Form  ZF_FILL_FIELD_AND_VALUE
*&---------------------------------------------------------------------*
*       Fill SHDB field name and value
*----------------------------------------------------------------------*
FORM zf_fill_field_and_value USING p_fnam        TYPE bdcdata-fnam
                                   p_fval        TYPE bdcdata-fval
                                   p_bdcdata_tab  TYPE y_bdcdata_tab.

  DATA w_bdcdata TYPE bdcdata.
  w_bdcdata-fnam  = p_fnam.
  w_bdcdata-fval  = p_fval.
  APPEND w_bdcdata TO p_bdcdata_tab.

ENDFORM.