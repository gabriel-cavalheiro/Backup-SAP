DATA: r_dtsolic   TYPE RANGE OF zfi097-dtsolic,
r_hrsolic   TYPE RANGE OF zfi097-hrsolic,
t_fieldcat  TYPE TABLE OF slis_fieldcat_alv,
wa_fieldcat TYPE          slis_fieldcat_alv,
wa_layout   TYPE          slis_layout_alv,
lv_repid    TYPE          sy-repid.


FIELD-SYMBOLS: <fl_logs>  TYPE ty_logs.

APPEND VALUE #( sign = 'I' option = 'BT' low = v_datainicio high = v_datafim ) TO r_dtsolic.

APPEND VALUE #( sign = 'I' option = 'BT' low = v_horainicio high = v_horafim ) TO r_hrsolic.

CLEAR t_logs[].

SELECT mandt
 nrsol
 origem
 tipo
 kunnr
 belnr
 buzei
 gjahr
 bukrs
 blart
 gsber
 xblnr
 knkli
 wrbtr
 dtsolic
 hrsolic
 dtaprov
 hraprov
 stasol
 motpro
 idsolic
 nomsol
 dtvenc
 nvvenc
 idaprov
 nmaprov
FROM zfi097
INTO TABLE t_logs
WHERE dtsolic IN r_dtsolic
AND hrsolic IN r_hrsolic.

IF t_logs IS NOT INITIAL .
LOOP AT t_logs ASSIGNING <fl_logs>.
CONCATENATE <fl_logs>-mandt <fl_logs>-bukrs <fl_logs>-belnr <fl_logs>-gjahr INTO v_objectid.
<fl_logs>-objectid = v_objectid.
ENDLOOP.
ENDIF.

IF t_logs IS NOT INITIAL.


SELECT objectid changenr username udate utime tcode
FROM cdhdr
INTO TABLE t_cdhdr
FOR ALL ENTRIES IN t_logs
WHERE objectid = t_logs-objectid
AND tcode      = 'ZFI0181'.

SORT t_cdhdr BY objectid.

IF sy-subrc IS INITIAL.
LOOP AT t_logs ASSIGNING <fl_logs>.
READ TABLE t_cdhdr INTO wa_cdhdr
WITH KEY objectid = <fl_logs>-objectid
                     BINARY SEARCH.
IF sy-subrc IS INITIAL.
  <fl_logs>-changenr  = wa_cdhdr-changenr.
  <fl_logs>-tcode     = wa_cdhdr-tcode.
  <fl_logs>-udate     = wa_cdhdr-udate.
  <fl_logs>-utime     = wa_cdhdr-utime.
  <fl_logs>-username  = wa_cdhdr-username.
  DELETE TABLE t_cdhdr FROM wa_cdhdr.
ENDIF.
ENDLOOP.
ENDIF.


CLEAR t_cdhdr[].

SELECT objectid changenr username udate utime tcode
FROM cdhdr
INTO TABLE t_cdhdr
FOR ALL ENTRIES IN t_logs
WHERE objectid = t_logs-objectid
AND tcode      = 'FB09'
OR objectid = t_logs-objectid
AND tcode      = ''.

SORT t_cdhdr BY objectid.

IF sy-subrc IS INITIAL.
LOOP AT t_logs ASSIGNING <fl_logs>.
READ TABLE t_cdhdr INTO wa_cdhdr
WITH KEY objectid = <fl_logs>-objectid
                     BINARY SEARCH.
IF sy-subrc IS INITIAL.
  IF <fl_logs>-tcode = 'ZFI0181'.
    CONTINUE.
  ELSE.
    <fl_logs>-changenr = wa_cdhdr-changenr.
    <fl_logs>-tcode    = wa_cdhdr-tcode.
    <fl_logs>-udate    = wa_cdhdr-udate.
    <fl_logs>-utime    = wa_cdhdr-utime.
    <fl_logs>-username = wa_cdhdr-username.
  ENDIF.
ENDIF.
ENDLOOP.
ENDIF.
ENDIF.

IF t_logs IS NOT INITIAL.

SELECT objectid changenr value_new value_old
FROM cdpos
INTO TABLE t_cdpos
FOR ALL ENTRIES IN t_logs
WHERE objectid = t_logs-objectid
AND changenr   = t_logs-changenr
AND fname = 'AEDAT'.

SORT t_cdpos BY changenr.

IF sy-subrc IS INITIAL.
LOOP AT t_logs ASSIGNING <fl_logs>.
READ TABLE t_cdpos INTO wa_cdpos
WITH KEY changenr = <fl_logs>-changenr
                     BINARY SEARCH.
IF sy-subrc IS INITIAL.
  <fl_logs>-value_new = wa_cdpos-value_new.
  <fl_logs>-value_old = wa_cdpos-value_old.
ENDIF.

ENDLOOP.
ENDIF.

ENDIF.


LOOP AT t_logs ASSIGNING <fl_logs>.
IF <fl_logs>-udate IS NOT INITIAL.
<fl_logs>-color = 'C510'.
ENDIF.
ENDLOOP.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'MANDT'.
wa_fieldcat-seltext_m = 'Mandante'.
wa_fieldcat-tabname   = 'T_LOGS'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'NRSOL'.
wa_fieldcat-seltext_m = 'Número de solicitação'.
wa_fieldcat-tabname   = 'T_LOGS'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'ORIGEM'.
wa_fieldcat-seltext_m = 'Origem solicitação'.
wa_fieldcat-tabname   = 'T_LOGS'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'TIPO'.
wa_fieldcat-seltext_m = 'Tipo de solicitação'.
wa_fieldcat-tabname   = 'T_LOGS'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'KUNNR'.
wa_fieldcat-seltext_m = 'Cliente'.
wa_fieldcat-tabname   = 'T_LOGS'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'BELNR'.
wa_fieldcat-seltext_m = 'N de Doc'.
wa_fieldcat-tabname   = 'T_LOGS'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'BUZEI'.
wa_fieldcat-seltext_m = 'Itm'.
wa_fieldcat-tabname   = 'T_LOGS'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'GJAHR'.
wa_fieldcat-seltext_m = 'Ano'.
wa_fieldcat-tabname   = 'T_LOGS'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'BUKRS'.
wa_fieldcat-seltext_m = 'Empre'.
wa_fieldcat-tabname   = 'T_LOGS'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'BLART'.
wa_fieldcat-seltext_m = 'tp.doc'.
wa_fieldcat-tabname   = 'T_LOGS'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'GSBER'.
wa_fieldcat-seltext_m = 'Div'.
wa_fieldcat-tabname   = 'T_LOGS'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'XBLNR'.
wa_fieldcat-seltext_m = 'Referência'.
wa_fieldcat-tabname   = 'T_LOGS'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'KNKLI'.
wa_fieldcat-seltext_m = 'Cta.créd'.
wa_fieldcat-tabname   = 'T_LOGS'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'WRBTR'.
wa_fieldcat-seltext_m = 'Montante'.
wa_fieldcat-tabname   = 'T_LOGS'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'DTSOLIC'.
wa_fieldcat-seltext_m = 'Data da solicitação'.
wa_fieldcat-tabname   = 'T_LOGS'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'HRSOLIC'.
wa_fieldcat-seltext_m = 'Hora da solicitação'.
wa_fieldcat-tabname   = 'T_LOGS'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'DTAPROV'.
wa_fieldcat-seltext_m = 'Data da aprovação'.
wa_fieldcat-tabname   = 'T_LOGS'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'HRAPROV'.
wa_fieldcat-seltext_m = 'Hora da aprovação'.
wa_fieldcat-tabname   = 'T_LOGS'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'STASOL'.
wa_fieldcat-seltext_m = 'Status da solicitação'.
wa_fieldcat-tabname   = 'T_LOGS'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'MOTPRO'.
wa_fieldcat-seltext_m = 'Motivo da prorrogação'.
wa_fieldcat-tabname   = 'T_LOGS'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'IDSOLIC'.
wa_fieldcat-seltext_m = 'Usúario solicitação'.
wa_fieldcat-tabname   = 'T_LOGS'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'NOMSOL'.
wa_fieldcat-seltext_m = 'Nome completo'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'DTVENC'.
wa_fieldcat-seltext_m = 'Data de vencimento'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'NVVENC'.
wa_fieldcat-seltext_m = 'Novo vencimento'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'IDAPROV'.
wa_fieldcat-seltext_m = 'Aprovador'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'NMAPROV'.
wa_fieldcat-seltext_m = 'Nome Aprovador'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'OBJECTID'.
wa_fieldcat-seltext_m = 'valor objeto'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'VALUE_NEW'.
wa_fieldcat-seltext_m = 'valor novo'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'VALUE_OLD'.
wa_fieldcat-seltext_m = 'valor antigo'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'USERNAME'.
wa_fieldcat-seltext_m = 'Usúario'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'UDATE'.
wa_fieldcat-seltext_m = 'Data'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'UTIME'.
wa_fieldcat-seltext_m = 'Hora'.
APPEND wa_fieldcat TO t_fieldcat.

*  CLEAR wa_fieldcat.
*  wa_fieldcat-fieldname = 'TCODE'.
*  wa_fieldcat-seltext_m = 'Cód transação'.
*  APPEND wa_fieldcat TO t_fieldcat.

wa_layout-expand_all        = 'X'.
wa_layout-colwidth_optimize = 'X'.
wa_layout-zebra             = 'X'.
wa_layout-info_fieldname    = 'COLOR'.

lv_repid = sy-repid.

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
EXPORTING
i_callback_program = lv_repid
is_layout          = wa_layout
it_fieldcat        = t_fieldcat[]
TABLES
t_outtab           = t_logs
EXCEPTIONS
program_error      = 1
OTHERS             = 2.

IF sy-subrc <> 0.
LEAVE LIST-PROCESSING.
ENDIF.
ENDFORM.