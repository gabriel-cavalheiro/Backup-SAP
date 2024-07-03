************************************************************************
*** Empresas Randon ***
************************************************************************
* Programa: ZFIR032
* Transação: ZFI036
* Data Solicitação: 07/12/2010
* Funcional: Marcelo Passaglia
* Parceira de Desenvolvimento: FH Consulting
* Desenvolvedor: Luiz Ferreira
* Contato: luiz.ferreira@fh.com.br
*-----------------------------------------------------------------------
* Versão do Manual de Desenvolvimento: 1.0
*Descrição do Desenvolvimento:
* Envio de email ao fornecedor das partidas pagas de forma detalhada.
*
*--------------------------------------------------------------------*
* Controle de Alterações
*--------------------------------------------------------------------*
* Usuário | Data       | Contato       | GAP/Chamado | Manual Obs.
***********************************************************************
* Miranda | 26.03.2013 | CDM01         | 8000012545  | Correcao E-mail
***********************************************************************
* Bruno F.| 08.10.2013 | BFB01         | 8000063458  | CCP-8-16633
* B. Luz  |            | Pelissari     |             | Remetente Email
************************************************************************
* Alteração : RC01                                                     *
* Autor : Rafael Caziraghi                                             *
* Data : 06/08/2020                                                    *
* Descrição : Sprint 5 US 59 - Envio de emails para clientes           *
************************************************************************
* Alteração : RC02                                                     *
* Autor : Rafael Caziraghi                                             *
* Data : 06/08/2020                                                    *
* Descrição : Sprint 6 US 59 - Ajuste para buscar email do cliente no  *
*             seu respectivo cadastro de fornecedor.                   *
************************************************************************

REPORT  zfir032 MESSAGE-ID zmfi.

DATA vl_tabix TYPE sy-tabix.                                "11/3
DATA lv_tabix LIKE sy-tabix.
DATA: vl_posicin  TYPE sy-tabix,
      vl_posicfn  TYPE sy-tabix,
      vl_contador TYPE n LENGTH 2 VALUE 00.

* tabelas
TABLES: regup.
* estruturas
TYPES:

*estrutura cabecalho
  BEGIN OF tp_cabecalho,
    lifnr     TYPE reguh-lifnr, "Fornecedor
    kunnr     TYPE reguh-kunnr, "Cliente      "RC01
    vblnr     TYPE reguh-vblnr, "Pagamento
    name1     TYPE reguh-name1, "Nome Fornecedor
    hbkid     TYPE reguh-hbkid, "Banco da empresa
    hktid     TYPE reguh-hktid, "ID conta
    koinh     TYPE reguh-koinh, "Titular da conta
    rbet3     TYPE reguh-rbet3, "Montante pago em Mi-3
    waers     TYPE reguh-waers, "Moeda
    ausfd     TYPE reguh-ausfd, "Dt. Vencimento
    zstc1     TYPE reguh-zstc1, "
    znme1     TYPE reguh-znme1, "
    zaldt     TYPE reguh-zaldt, "
    zbnkl     TYPE reguh-zbnkl, "
    zbnkn     TYPE reguh-zbnkn, "
    adrnr     TYPE reguh-adrnr, "
    zbukr     TYPE reguh-zbukr, "Empresa Pagadora,
    smtp_addr TYPE adr6-smtp_addr, "emails
    expand,
    laufd     TYPE reguh-laufd,
    laufi     TYPE reguh-laufi,
    empfg     TYPE reguh-empfg,                                 " CDM01
    stcd1     TYPE reguh-stcd1,                                 " CDM01
    chave(28) TYPE c,
  END OF tp_cabecalho,

*estrutura item
  BEGIN OF tp_item,
    lifnr     TYPE reguh-lifnr, "Fornecedor
    kunnr     TYPE reguh-kunnr, "Cliente      "RC01
    vblnr     TYPE regup-vblnr, "Pagamento
    gsber     TYPE regup-gsber, "Divisão
    bukrs     TYPE regup-bukrs, "Empresa
    belnr     TYPE regup-belnr, "Número Documento
    buzei     TYPE regup-buzei,
    blart     TYPE regup-blart, "Tipo de documento
    bldat     TYPE regup-bldat, "Data documento
    budat     TYPE regup-budat, "Data lançamento
    zfbdt     TYPE regup-zfbdt, "Data base
    zterm     TYPE regup-zterm, "Condições Pgto
    bschl     TYPE regup-bschl, "chave de lançto
    dmbtr     TYPE regup-dmbtr, "Montante bruto MI
    mwsts     TYPE regup-mwsts, "Imposto MI
    wrbtr     TYPE regup-wrbtr, "Montante liquido
    waers     TYPE regup-waers, "Moeda
    xblnr     TYPE regup-xblnr, "
    qbshb     TYPE regup-qbshb, "
    sknto     TYPE regup-sknto, "
    shkzg     TYPE regup-shkzg, "Débito/Crédito
    zlsch     TYPE regup-zlsch, "Débito/Crédito
    chave(28) TYPE c,
  END OF tp_item,

  BEGIN OF tp_item_aux,
    chave(28) TYPE c,
    lifnr     TYPE reguh-lifnr, "Fornecedor
    kunnr     TYPE reguh-kunnr, "Cliente      "RC01
    vblnr     TYPE regup-vblnr, "Pagamento
    gsber     TYPE regup-gsber, "Divisão
    bukrs     TYPE regup-bukrs, "Empresa
    belnr     TYPE regup-belnr, "Número Documento
    blart     TYPE regup-blart, "Tipo de documento
    bldat     TYPE regup-bldat, "Data documento
    budat     TYPE regup-budat, "Data lançamento
    zfbdt     TYPE regup-zfbdt, "Data base
    zterm     TYPE regup-zterm, "Condições Pgto
    bschl     TYPE regup-bschl, "chave de lançto
    dmbtr     TYPE regup-dmbtr, "Montante bruto MI
    mwsts     TYPE regup-mwsts, "Imposto MI
    wrbtr     TYPE regup-wrbtr, "Montante liquido
    waers     TYPE regup-waers, "Moeda
    xblnr     TYPE regup-xblnr, "
    qbshb     TYPE regup-qbshb, "
    sknto     TYPE regup-sknto, "
    shkzg     TYPE regup-shkzg, "Débito/Crédito
    laufi     TYPE regup-laufi,
    laufd     TYPE regup-laufd,
  END OF tp_item_aux,

*estrutura adrc
  BEGIN OF tp_adrc,
    addrnumber TYPE adrc-addrnumber, "num. endereco
    tel_number TYPE adrc-tel_number, "telefone
  END OF tp_adrc,

*estrutura adr6
  BEGIN OF tp_adr6,
*      addrnumber TYPE adr6-addrnumber, "num.endereco
*      smtp_addr  TYPE adr6-smtp_addr, " e-mail
    bukrs TYPE lfb1-bukrs,
    lifnr TYPE lfb1-lifnr,
    kunnr TYPE knb1-kunnr,  "RC01
    intad TYPE lfb1-intad,
  END OF tp_adr6,

*estrutura reguh
  BEGIN OF tp_reguh,
    zbukr TYPE reguh-zbukr,
    lifnr TYPE reguh-lifnr,
    kunnr TYPE reguh-kunnr, "Cliente      "RC01
    zaldt TYPE reguh-zaldt,
    vblnr TYPE reguh-vblnr,
  END OF tp_reguh,

*estrutura t001
  BEGIN OF tp_t001,
    bukrs      TYPE t001-bukrs,
*       butxt type t001-butxt,
    butxt      TYPE adrc-name1,
    tel_number TYPE adrc-tel_number,
  END OF tp_t001,
*estrutura texto email
  BEGIN OF tp_desc_textos_email,
    assunto(100)              TYPE c,
    mensagem_sobre_anexo(255) TYPE c,
    spras                     TYPE sy-langu,
  END OF tp_desc_textos_email.

DATA: BEGIN OF t_pdfdata OCCURS 0.
*INCLUDE STRUCTURE solisti1.
        INCLUDE STRUCTURE tline.
DATA: END OF t_pdfdata.

DATA:
  st_zfie009              TYPE TABLE OF   zfie009 WITH HEADER LINE,
  st_job_output_info      TYPE ssfcrescl,
  st_document_output_info TYPE ssfcrespd,
  st_job_output_options   TYPE ssfcresop,
  st_output_options       TYPE ssfcompop,
  st_control_parameters   TYPE ssfctrlop,
* Objects to send mail.
  st_objpack              LIKE sopcklsti1 OCCURS 0 WITH HEADER LINE,
  st_objtxt               LIKE solisti1   OCCURS 0 WITH HEADER LINE,
  st_objbin               LIKE solisti1   OCCURS 0 WITH HEADER LINE,
  st_objbin2              LIKE solisti1   OCCURS 0 WITH HEADER LINE, "10/3
  st_reclist              LIKE somlreci1  OCCURS 0 WITH HEADER LINE,
  st_objhead              TYPE soli_tab,

* Work Area declarations
  wa_doc_chng             TYPE sodocchgi1.
*tabelas internas
DATA:
  it_cabecalho         TYPE STANDARD TABLE OF tp_cabecalho WITH HEADER LINE,
  it_cab_aux           TYPE STANDARD TABLE OF tp_cabecalho WITH HEADER LINE,
  wa_cabecalho         TYPE tp_cabecalho,
  it_reguh             TYPE STANDARD TABLE OF tp_cabecalho WITH HEADER LINE,
  wa_reguh             TYPE tp_cabecalho,
  it_item              TYPE STANDARD TABLE OF tp_item_aux  WITH HEADER LINE,
  it_item_aux          TYPE STANDARD TABLE OF tp_item      WITH HEADER LINE,
  it_adrc              TYPE STANDARD TABLE OF tp_adrc      WITH HEADER LINE,
*    it_adr6      TYPE STANDARD TABLE OF tp_adr6      WITH HEADER LINE,
  it_adr6              TYPE STANDARD TABLE OF tp_adr6      WITH HEADER LINE,
  it_adr6_cliente      TYPE STANDARD TABLE OF tp_adr6      WITH HEADER LINE,  "RC02
  it_t001              TYPE STANDARD TABLE OF tp_t001      WITH HEADER LINE,
  it_desc_textos_email TYPE STANDARD TABLE OF tp_desc_textos_email
                                              WITH HEADER LINE.

*========================ALV=====================================================
DATA : it_fieldcat TYPE slis_t_fieldcat_alv,
       wa_fieldcat TYPE slis_fieldcat_alv,
       it_layout   TYPE slis_layout_alv,
       key         TYPE slis_keyinfo_alv.

*variáveis globais
DATA:
  v_fm_name   TYPE rs38l_fnam,
  v_language  TYPE sflangu VALUE 'P',
  v_e_devtype TYPE rspoptype,
  v_spool_nr  TYPE tsp01-rqident,
  v_lines_txt TYPE i,
  n           TYPE i VALUE 1,
  g_n         TYPE i VALUE 1,
  lv_rbet3    TYPE reguh-rbet3. "Montante pago em Mi-3

*constants
CONSTANTS:
  c_formname             TYPE tdsfname VALUE 'ZFIF002',
  c_cinquenta_asteriscos TYPE c VALUE '*'.


* Cargas de parametros ----------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE text-s01.
PARAMETERS:     p_bukrs  TYPE regup-bukrs.
SELECT-OPTIONS: so_budat FOR  regup-budat,
                so_lifnr FOR  regup-lifnr,
                so_kunnr FOR  regup-kunnr.  "RC01
PARAMETERS:     p_email AS CHECKBOX,
                p_lifnr AS CHECKBOX,       "RC01
                p_kunnr AS CHECKBOX.       "RC01
*campo check box com descritivo “Gerar Email”. (*)

SELECTION-SCREEN END OF BLOCK b01.

*limpa as tableas e os headers
PERFORM f_inicializa.
*seleciona os dados
PERFORM f_seleciona_dados.
* monta dados para o smartform
PERFORM f_monta_dados.
IF p_email IS INITIAL.
* chama alv
  DELETE ADJACENT DUPLICATES FROM it_cabecalho COMPARING chave.

  PERFORM f_hierarchyalv_build.
ENDIF.

*&---------------------------------------------------------------------*
*&      Form  f_hierarchyalv_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_hierarchyalv_build .

*fieldcatalogue
  PERFORM f_build_fieldcat.

*layout
  PERFORM f_build_layout.

*key information for hierarchy
  PERFORM f_build_key.

*output
  PERFORM f_list_display.

ENDFORM.                    " f_hierarchyalv_build

*&---------------------------------------------------------------------*
*&      Form  f_build_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_build_fieldcat .

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 1.
  wa_fieldcat-fieldname = 'VBLNR'.
  wa_fieldcat-tabname   = 'IT_CABECALHO'.
  wa_fieldcat-seltext_m = 'Pagamento'.
  wa_fieldcat-key       = 'X'.
*  wa_fieldcat-emphasize = 'C610'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 2.
  wa_fieldcat-fieldname = 'LIFNR'.
  wa_fieldcat-tabname   = 'IT_CABECALHO'.
  wa_fieldcat-seltext_m = 'Fornecedor'.
  wa_fieldcat-key       = 'X'.
*  wa_fieldcat-emphasize = 'C610'.
  APPEND wa_fieldcat TO it_fieldcat.

*-- RC01 Inicio
  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 3.
  wa_fieldcat-fieldname = 'KUNNR'.
  wa_fieldcat-tabname   = 'IT_CABECALHO'.
  wa_fieldcat-seltext_m = 'Cliente'.
  wa_fieldcat-key       = 'X'.
*  wa_fieldcat-emphasize = 'C610'.
  APPEND wa_fieldcat TO it_fieldcat.
*-- RC01 Fim

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 4.
  wa_fieldcat-fieldname = 'NAME1'.
  wa_fieldcat-tabname   = 'IT_CABECALHO'.
  wa_fieldcat-seltext_m = 'Nome Fornecedor'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 5.
  wa_fieldcat-fieldname = 'HBKID'.
  wa_fieldcat-tabname   = 'IT_CABECALHO'.
  wa_fieldcat-seltext_m = 'Banco Empresa'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 6.
  wa_fieldcat-fieldname = 'HKTID'.
  wa_fieldcat-tabname   = 'IT_CABECALHO'.
  wa_fieldcat-seltext_m = 'ID Conta'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 7.
  wa_fieldcat-fieldname = 'KOINH'.
  wa_fieldcat-tabname   = 'IT_CABECALHO'.
  wa_fieldcat-seltext_m = 'Titular da conta'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 8.
  wa_fieldcat-fieldname = 'RBET3'.
  wa_fieldcat-tabname   = 'IT_CABECALHO'.
  wa_fieldcat-seltext_m = 'Montante pago'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 9.
  wa_fieldcat-fieldname = 'WAERS'.
  wa_fieldcat-tabname   = 'IT_CABECALHO'.
  wa_fieldcat-seltext_m = 'Moeda'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 10.
  wa_fieldcat-fieldname = 'AUSFD'.
  wa_fieldcat-tabname   = 'IT_CABECALHO'.
  wa_fieldcat-seltext_m = 'Dt. Vencimento'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 11.
  wa_fieldcat-fieldname = 'SMTP_ADDR'.
  wa_fieldcat-tabname   = 'IT_CABECALHO'.
  wa_fieldcat-seltext_m = 'Email'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 12.
  wa_fieldcat-fieldname = 'GSBER'.
  wa_fieldcat-tabname   = 'IT_ITEM'.
  wa_fieldcat-seltext_m = 'Divisão'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 13.
  wa_fieldcat-fieldname = 'BUKRS'.
  wa_fieldcat-tabname   = 'IT_ITEM'.
  wa_fieldcat-seltext_m = 'Empresa'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 14.
  wa_fieldcat-fieldname = 'BELNR'.
  wa_fieldcat-tabname   = 'IT_ITEM'.
  wa_fieldcat-seltext_m = 'Num. Documento'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 15.
  wa_fieldcat-fieldname = 'BLART'.
  wa_fieldcat-tabname   = 'IT_ITEM'.
  wa_fieldcat-seltext_m = 'Tp. documento'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 16.
  wa_fieldcat-fieldname = 'BLDAT'.
  wa_fieldcat-tabname   = 'IT_ITEM'.
  wa_fieldcat-seltext_m = 'Dt. do documento'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 17.
  wa_fieldcat-fieldname = 'BUDAT'.
  wa_fieldcat-tabname   = 'IT_ITEM'.
  wa_fieldcat-seltext_m = 'Dt. de lançamento'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 18.
  wa_fieldcat-fieldname = 'ZFBDT'.
  wa_fieldcat-tabname   = 'IT_ITEM'.
  wa_fieldcat-seltext_m = 'Dt. Base'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 19.
  wa_fieldcat-fieldname = 'ZTERM'.
  wa_fieldcat-tabname   = 'IT_ITEM'.
  wa_fieldcat-seltext_m = 'Condições de pgto.'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 20.
  wa_fieldcat-fieldname = 'BSCHL'.
  wa_fieldcat-tabname   = 'IT_ITEM'.
  wa_fieldcat-seltext_m = 'CL'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 21.
  wa_fieldcat-fieldname = 'DMBTR'.
  wa_fieldcat-tabname   = 'IT_ITEM'.
  wa_fieldcat-seltext_m = 'Montante bruto'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 22.
  wa_fieldcat-fieldname = 'QBSHB'.
  wa_fieldcat-tabname   = 'IT_ITEM'.
  wa_fieldcat-seltext_m = 'Imposto'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 23.
  wa_fieldcat-fieldname = 'WRBTR'.
  wa_fieldcat-tabname   = 'IT_ITEM'.
  wa_fieldcat-seltext_m = 'Montante líquido'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 24.
  wa_fieldcat-fieldname = 'WAERS'.
  wa_fieldcat-tabname   = 'IT_ITEM'.
  wa_fieldcat-seltext_m = 'Moeda'.
  APPEND wa_fieldcat TO it_fieldcat.

ENDFORM.                    " f_build_fieldcat

*&---------------------------------------------------------------------*
*&      Form  f_build_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_layout .

*to expand the header table for item details
  it_layout-expand_fieldname  = 'EXPAND'.
  it_layout-window_titlebar   = 'Relatorio das Partidas Pagas'.
  it_layout-lights_tabname    = 'IT_ITEM'.
  it_layout-colwidth_optimize = 'X'.

ENDFORM.                    " f_build_layout

*&---------------------------------------------------------------------*
*&      Form  f_build_key
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_build_key .

*key infomation for the header and item table
  key-header01 = 'CHAVE'. "'LIFNR'.
  key-item01   = 'CHAVE'. "'LIFNR'.
ENDFORM.                    " f_build_key

*&---------------------------------------------------------------------*
*&      Form  f_list_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_list_display .

*ALV output
  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      i_callback_program      = sy-cprog
      is_layout               = it_layout
      it_fieldcat             = it_fieldcat
      i_tabname_header        = 'IT_CABECALHO'
      i_tabname_item          = 'IT_ITEM'
      i_callback_user_command = 'USER_COMMAND'
      is_keyinfo              = key
    TABLES
      t_outtab_header         = it_cabecalho
      t_outtab_item           = it_item.

ENDFORM.                    " f_list_display


*&---------------------------------------------------------------------*
*&      Form  F_INICIALIZA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_inicializa .

  CLEAR: it_cabecalho[], it_item[],
         it_cabecalho,   it_item.

ENDFORM.                    " F_INICIALIZA
*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_DADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_seleciona_dados .

  DATA: lt_cab_lifnr TYPE STANDARD TABLE OF tp_cabecalho,   "RC01
        lt_cab_kunnr TYPE STANDARD TABLE OF tp_cabecalho.   "RC01

  IF p_lifnr IS NOT INITIAL.
* seleciona dados REGUH (Cabecalho)
    SELECT lifnr vblnr name1 hbkid hktid koinh rbet3 waers ausfd
           zstc1 znme1 zaldt zbnkl zbnkn adrnr zbukr laufd laufi
      FROM reguh
    INTO CORRESPONDING FIELDS OF TABLE it_reguh
      WHERE zaldt IN so_budat
        AND zbukr EQ p_bukrs
        AND lifnr IN so_lifnr
        AND xvorl EQ ''.

    IF sy-subrc IS NOT INITIAL.
      MESSAGE s006(zmfi).
      STOP.
    ENDIF.

* { FH/IvanB - Início Alteração - 01/07/2011 - parte 1/4
    DELETE it_reguh WHERE lifnr IS INITIAL.

*-- RC01 Inicio
  ENDIF.

  IF p_kunnr IS NOT INITIAL.
* seleciona dados REGUH (Cabecalho)
    SELECT h~kunnr, h~vblnr, h~name1, h~hbkid, h~hktid, h~koinh, h~rbet3, h~waers, h~ausfd,
           h~zstc1, h~znme1, h~zaldt, h~zbnkl, h~zbnkn, h~adrnr, h~zbukr, h~laufd, h~laufi
      FROM reguh AS h
      INNER JOIN regut AS t
      ON  h~laufd = t~laufd
      AND h~laufi = t~laufi
      AND h~xvorl = t~xvorl
      AND h~zbukr = t~zbukr
*    AND h~landl = t~banks
    APPENDING CORRESPONDING FIELDS OF TABLE @it_reguh
      WHERE h~zaldt IN @so_budat
        AND h~zbukr EQ @p_bukrs
        AND h~kunnr IN @so_kunnr
        AND h~kunnr NE ''
        AND h~xvorl EQ ''
        AND t~report = 'RFFOBR_U'.

  ENDIF.
*-- RC01 Fim

  IF it_reguh[] IS INITIAL.
    MESSAGE s006(zmfi).
    STOP.
  ENDIF.
* } FH/IvanB - Início Alteração - 01/07/2011 - parte 1/4

* seleciona dados REGUP (item)
  SELECT lifnr kunnr vblnr gsber bukrs belnr buzei blart bldat budat zfbdt zterm "RC01
         bschl wrbtr mwsts dmbtr waers xblnr qbshb sknto shkzg zlsch laufi laufd
    FROM regup
    INTO CORRESPONDING FIELDS OF TABLE it_item_aux "it_item
    FOR ALL ENTRIES IN it_reguh
   WHERE xvorl EQ ''
     AND lifnr EQ it_reguh-lifnr
     AND kunnr EQ it_reguh-kunnr     "RC01
     AND vblnr EQ it_reguh-vblnr
     AND bukrs EQ it_reguh-zbukr.

  IF sy-subrc IS INITIAL.
* seleciona dados REGUH (cabecalho)
    SELECT lifnr kunnr vblnr name1 hbkid hktid koinh rbet3 waers ausfd  "RC01
           zstc1 znme1 zaldt zbnkl zbnkn adrnr zbukr laufd laufi
           empfg stcd1                                      " CDM01
      FROM reguh
      INTO CORRESPONDING FIELDS OF TABLE it_cabecalho
      FOR ALL ENTRIES IN it_item_aux "it_item
     WHERE vblnr EQ it_item_aux-vblnr
       AND lifnr EQ it_item_aux-lifnr
       AND kunnr EQ it_item_aux-kunnr "RC01
       AND xvorl EQ ''.
    IF sy-subrc IS  INITIAL.

* { FH/IvanB - Início Alteração - 01/07/2011 - parte 2/4
*      DELETE it_cabecalho WHERE lifnr IS INITIAL.        "RC01

      IF it_cabecalho[] IS INITIAL.
        MESSAGE s006(zmfi).
        STOP.
      ENDIF.
* } FH/IvanB - Início Alteração - 01/07/2011 - parte 2/4
      LOOP AT it_cabecalho.
        CLEAR: it_cabecalho-rbet3.
        MODIFY it_cabecalho.
      ENDLOOP.

      SELECT addrnumber tel_number
        FROM adrc
        INTO TABLE it_adrc
        FOR ALL ENTRIES IN it_cabecalho
       WHERE addrnumber EQ it_cabecalho-adrnr.

* { FH/IvanB - Início Alteração - 01/07/2011 - parte 3/4
* } FH/IvanB - Início Alteração - 01/07/2011 - parte 3/4
*-- RC01 Inicio
      CLEAR: lt_cab_lifnr, lt_cab_kunnr.

      lt_cab_lifnr = VALUE #( FOR wal IN it_cabecalho
                                    WHERE ( lifnr IS NOT INITIAL )
                                    ( wal ) ).

      IF lt_cab_lifnr IS NOT INITIAL.

        SELECT bukrs lifnr intad
          FROM lfb1
          INTO CORRESPONDING FIELDS OF TABLE it_adr6    "RC01
          FOR ALL ENTRIES IN lt_cab_lifnr
         WHERE bukrs EQ lt_cab_lifnr-zbukr
           AND lifnr EQ lt_cab_lifnr-lifnr.

      ENDIF.

      lt_cab_kunnr = VALUE #( FOR wak IN it_cabecalho
                                  WHERE ( kunnr IS NOT INITIAL )
                                  ( wak ) ).

      IF lt_cab_kunnr IS NOT INITIAL.

*-- RC02 Inicio
        "Busca o email do cliente no cadastro do cliente
        SELECT b~bukrs,
               k~kunnr,
               a~smtp_addr AS intad
          FROM kna1 AS k
          INNER JOIN knb1 AS b
          ON k~kunnr = b~kunnr
          INNER JOIN adr6 AS a
          ON k~adrnr = a~addrnumber
          INTO CORRESPONDING FIELDS OF TABLE @it_adr6_cliente
          FOR ALL ENTRIES IN @lt_cab_kunnr
         WHERE b~bukrs EQ @lt_cab_kunnr-zbukr
           AND k~kunnr EQ @lt_cab_kunnr-kunnr.

        "busca email do cliente no cadastro de
        "fornecedor que ele mesmo possui
        SELECT b~bukrs,
               k~kunnr,
               a~smtp_addr AS intad
          FROM kna1 AS k
          INNER JOIN lfa1 AS l
          ON k~kunnr = l~kunnr
          INNER JOIN lfb1 AS b
          ON b~lifnr = l~lifnr
          INNER JOIN adr6 AS a
          ON l~adrnr = a~addrnumber
          APPENDING CORRESPONDING FIELDS OF TABLE @it_adr6
          FOR ALL ENTRIES IN @lt_cab_kunnr
         WHERE b~bukrs EQ @lt_cab_kunnr-zbukr
           AND k~kunnr EQ @lt_cab_kunnr-kunnr.
*-- RC02 Fim

      ENDIF.
*-- RC01 Fim

    ENDIF.

    DELETE it_adr6 WHERE intad IS INITIAL.  "RC02
    DELETE it_adr6_cliente WHERE intad IS INITIAL.  "RC02

* { FH/IvanB - Início Alteração - 01/07/2011 - parte 4/4
* } FH/IvanB - Início Alteração - 01/07/2011 - parte 4/4
    SELECT bukrs name1 tel_number
          FROM t001 AS t
      INNER JOIN adrc AS a
      ON t~adrnr = a~addrnumber
          INTO TABLE it_t001
          FOR ALL ENTRIES IN it_item
         WHERE bukrs EQ it_item-bukrs
           AND spras EQ sy-langu.

  ENDIF.

  SORT it_cabecalho BY lifnr vblnr.
  SORT it_item BY lifnr vblnr.


ENDFORM.                    " F_SELECIONA_DADOS
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_DADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_monta_dados .

  DATA: l_tot_vlr_ir LIKE zfie009-tot_vlr_liquido,
        l_tot_vlr_jd LIKE zfie009-tot_vlr_liquido,
        vl_name      TYPE reguh-name1,                      " CDM01
        vl_stcd1     TYPE reguh-stcd1.                      " CDM01

  LOOP AT it_cabecalho.
    lv_tabix = sy-tabix.

    CLEAR it_cabecalho-chave.

    IF it_cabecalho-lifnr IS NOT INITIAL. "RC01

      CONCATENATE it_cabecalho-laufd
                  it_cabecalho-laufi
                  it_cabecalho-zbukr
                  it_cabecalho-lifnr
               INTO it_cabecalho-chave.

*-- RC01 Inicio
    ELSEIF it_cabecalho-kunnr IS NOT INITIAL.

      CONCATENATE it_cabecalho-laufd
            it_cabecalho-laufi
            it_cabecalho-zbukr
            it_cabecalho-kunnr
         INTO it_cabecalho-chave.

    ENDIF.
*-- RC01 Fim

    MODIFY it_cabecalho INDEX lv_tabix TRANSPORTING chave.
  ENDLOOP.


*Montar Chave
  LOOP AT it_item_aux.
    lv_tabix = sy-tabix.
    MOVE-CORRESPONDING it_item_aux TO it_item.
    APPEND it_item.

*-- RC01 Inicio
*    READ TABLE it_cabecalho WITH KEY vblnr = it_item_aux-vblnr
*                                     lifnr = it_item_aux-lifnr.

    IF it_item_aux-lifnr IS NOT INITIAL.

      it_item-chave = it_cabecalho[ vblnr = it_item_aux-vblnr lifnr = it_item_aux-lifnr ]-chave.
      MODIFY it_item INDEX lv_tabix TRANSPORTING chave.

    ELSEIF it_item_aux-kunnr IS NOT INITIAL.

      it_item-chave = it_cabecalho[ vblnr = it_item_aux-vblnr kunnr = it_item_aux-kunnr ]-chave.
      MODIFY it_item INDEX lv_tabix TRANSPORTING chave.

    ENDIF.
*    IF sy-subrc IS INITIAL.
*      it_item-chave = it_cabecalho-chave.
*      MODIFY it_item INDEX lv_tabix TRANSPORTING chave.
*    ENDIF.
*-- RC01 Fim

  ENDLOOP.

  CLEAR vl_contador.

  SORT it_item BY chave. "GFB01
*  f.	Montar os dados para cada fornecedor
  LOOP AT it_item.
    it_item-qbshb = - it_item-qbshb.

*-- RC01 Inicio
    CLEAR: st_zfie009.

    IF it_item-lifnr IS NOT INITIAL.
      READ TABLE it_cabecalho WITH KEY vblnr = it_item-vblnr
                                       lifnr = it_item-lifnr
                                       chave = it_item-chave.

      lv_tabix = sy-tabix.
      IF sy-subrc IS INITIAL.

* CDM01 - Inicio
        CLEAR: vl_name, vl_stcd1.

        IF it_cabecalho-empfg IS NOT INITIAL AND
           it_cabecalho-empfg <> it_cabecalho-lifnr.
          vl_name  = it_cabecalho-name1.
          vl_stcd1 = it_cabecalho-stcd1.
        ELSE.
          vl_name  = it_cabecalho-znme1.
          vl_stcd1 = it_cabecalho-zstc1.
        ENDIF.
* CDM01 - Fim

        CALL FUNCTION 'CONVERSION_EXIT_CGCBR_OUTPUT'
          EXPORTING
            input  = vl_stcd1                                 " CDM01
          IMPORTING
            output = st_zfie009-zstc1.

        st_zfie009-zstc1      = st_zfie009-zstc1+0(18).
        st_zfie009-znme1      = vl_name.                      " CDM01
        st_zfie009-zaldt      = it_cabecalho-zaldt.

        READ TABLE it_reguh INTO wa_reguh
                            WITH KEY laufi = it_item-chave+8(5) "it_item-laufi
                                     laufd = it_item-chave(8) "it_item-laufd
                                     lifnr = it_item-lifnr
                                     vblnr = it_item-vblnr.
        IF sy-subrc EQ 0.
          st_zfie009-zbnkl      = wa_reguh-zbnkl.
          st_zfie009-zbnkn      = wa_reguh-zbnkn.
        ENDIF.

*     Nota Fiscal
        IF it_item-xblnr IS INITIAL.
          st_zfie009-xblnr      = 'Adto'.
        ELSE.
          st_zfie009-xblnr      = it_item-xblnr.
        ENDIF.

        IF it_item-shkzg EQ 'S'.
          it_item-dmbtr      = - it_item-dmbtr.
        ENDIF.
        st_zfie009-dmbtr      = it_item-dmbtr.
        st_zfie009-qbshb      = it_item-qbshb.
        st_zfie009-sknto      = it_item-sknto.
*      READ TABLE it_adr6 WITH KEY addrnumber = it_cabecalho-adrnr.
        READ TABLE it_adr6 WITH KEY bukrs = it_cabecalho-zbukr
                                    lifnr = it_cabecalho-lifnr.

        it_cabecalho-rbet3 = it_cabecalho-rbet3 + it_item-dmbtr + it_item-qbshb.
        IF sy-subrc IS INITIAL.
          st_zfie009-smtp_addr   =  it_adr6-intad.
          it_cabecalho-smtp_addr =  it_adr6-intad.

        ENDIF.
        MODIFY it_cabecalho INDEX lv_tabix.
        READ TABLE it_t001 WITH KEY bukrs = it_item-bukrs.
        IF sy-subrc IS INITIAL.
          st_zfie009-butxt      = it_t001-butxt.
          CONCATENATE '(' it_t001-tel_number(1) it_t001-tel_number+1(1) ')' it_t001-tel_number+2 INTO it_t001-tel_number.
          st_zfie009-tel_number      = it_t001-tel_number.
        ENDIF.
      ENDIF.
**********************************************************************'
*-- RC01 Inicio
      "Tratar informacoes de clientes
    ELSEIF it_item-kunnr IS NOT INITIAL.

      READ TABLE it_cabecalho WITH KEY vblnr = it_item-vblnr
                                       kunnr = it_item-kunnr
                                       chave = it_item-chave.

      lv_tabix = sy-tabix.

      IF sy-subrc IS INITIAL.

        CLEAR: vl_name, vl_stcd1.

        IF it_cabecalho-empfg IS NOT INITIAL AND
          it_cabecalho-empfg <> it_cabecalho-kunnr.
          vl_name  = it_cabecalho-name1.
          vl_stcd1 = it_cabecalho-stcd1.
        ELSE.
          vl_name  = it_cabecalho-znme1.
          vl_stcd1 = it_cabecalho-zstc1.
        ENDIF.

        CALL FUNCTION 'CONVERSION_EXIT_CGCBR_OUTPUT'
          EXPORTING
            input  = vl_stcd1                                 " CDM01
          IMPORTING
            output = st_zfie009-zstc1.

        st_zfie009-zstc1      = st_zfie009-zstc1+0(18).
        st_zfie009-znme1      = vl_name.                      " CDM01
        st_zfie009-zaldt      = it_cabecalho-zaldt.

        READ TABLE it_reguh INTO wa_reguh
                      WITH KEY laufi = it_item-chave+8(5) "it_item-laufi
                               laufd = it_item-chave(8) "it_item-laufd
                               kunnr = it_item-kunnr
                               vblnr = it_item-vblnr.
        IF sy-subrc EQ 0.
          st_zfie009-zbnkl      = wa_reguh-zbnkl.
          st_zfie009-zbnkn      = wa_reguh-zbnkn.
        ENDIF.

*     Nota Fiscal
        IF it_item-xblnr IS INITIAL.
          st_zfie009-xblnr      = 'Adto'.
        ELSE.
          st_zfie009-xblnr      = it_item-xblnr.
        ENDIF.

        IF it_item-shkzg EQ 'S'.
          it_item-dmbtr      = - it_item-dmbtr.
        ENDIF.
        st_zfie009-dmbtr      = it_item-dmbtr.
        st_zfie009-qbshb      = it_item-qbshb.
        st_zfie009-sknto      = it_item-sknto.

        READ TABLE it_adr6 WITH KEY bukrs = it_cabecalho-zbukr
                                    kunnr = it_cabecalho-kunnr.

        it_cabecalho-rbet3 = it_cabecalho-rbet3 + it_item-dmbtr + it_item-qbshb.
        IF sy-subrc IS INITIAL.
          st_zfie009-smtp_addr   =  it_adr6-intad.
          it_cabecalho-smtp_addr =  it_adr6-intad.

*-- RC02 Inicio
        "Caso não encontre o email no cadastro do cliente pois não possui
        "cadastro de fornecedor
        ELSEIF line_exists( it_adr6_cliente[ bukrs = it_cabecalho-zbukr
                                             kunnr = it_cabecalho-kunnr ] ).

          st_zfie009-smtp_addr   =  it_adr6_cliente[ bukrs = it_cabecalho-zbukr
                                             kunnr = it_cabecalho-kunnr ]-intad.
          it_cabecalho-smtp_addr =  it_adr6_cliente[ bukrs = it_cabecalho-zbukr
                                             kunnr = it_cabecalho-kunnr ]-intad.
*-- RC02 Fim

        ENDIF.
        MODIFY it_cabecalho INDEX lv_tabix.
        READ TABLE it_t001 WITH KEY bukrs = it_item-bukrs.
        IF sy-subrc IS INITIAL.
          st_zfie009-butxt      = it_t001-butxt.
          CONCATENATE '(' it_t001-tel_number(1) it_t001-tel_number+1(1) ')' it_t001-tel_number+2 INTO it_t001-tel_number.
          st_zfie009-tel_number      = it_t001-tel_number.
        ENDIF.
      ENDIF.
    ENDIF.
*-- RC01 Fim
**********************************************************************

    IF it_item-dmbtr LT '0'.
      it_item-wrbtr = - it_item-dmbtr + it_item-qbshb.
      it_item-wrbtr = - it_item-wrbtr.
    ELSE.
      it_item-wrbtr = it_item-dmbtr + it_item-qbshb.
    ENDIF.

    l_tot_vlr_ir      = l_tot_vlr_ir + st_zfie009-qbshb.
    l_tot_vlr_jd      = l_tot_vlr_jd + st_zfie009-sknto.

    st_zfie009-rbetr       = it_item-wrbtr.
    st_zfie009-vlr_bruto   = it_item-dmbtr.
    st_zfie009-vlr_liquido = it_item-wrbtr + st_zfie009-sknto.

*   Vlr total bruto
    st_zfie009-tot_vlr_bruto   = st_zfie009-tot_vlr_bruto + st_zfie009-vlr_bruto."st_zfie009-tot_vlr_bruto + st_zfie009-vlr_bruto.
    st_zfie009-tot_vlr_liquido = st_zfie009-tot_vlr_liquido + st_zfie009-vlr_liquido.

    st_zfie009-vlr_bruto   = l_tot_vlr_ir.
    st_zfie009-vlr_liquido = l_tot_vlr_jd.

    MODIFY it_item.
    APPEND st_zfie009.

    AT END OF chave.
      vl_tabix = sy-tabix.                                  "11/3

      IF NOT p_email IS INITIAL.

        PERFORM f_chama_smartform USING 'X'.

        PERFORM f_limpa_variaveis_email.

        PERFORM f_converte_otf_em_pdf USING st_job_output_info.

        PERFORM f_carrega_textos_email.

        PERFORM f_cria_texto_corpo_e_descricao.

        PERFORM f_cria_texto_principal.

        PERFORM f_anexa_o_arquivo_2.

        PERFORM f_pega_destinatarios_email.

        CLEAR: st_zfie009-tot_vlr_bruto,
               st_zfie009-tot_vlr_liquido.

        PERFORM f_dispara_o_email USING it_t001-bukrs.     "BFB01

      ENDIF.
    ENDAT.

  ENDLOOP.

  SORT it_cabecalho BY chave.
  it_cab_aux[] = it_cabecalho[].

  REFRESH it_cabecalho[].

  LOOP AT it_cab_aux.

    IF wa_cabecalho-chave NE it_cab_aux-chave.

      IF lv_rbet3 IS NOT INITIAL.
        wa_cabecalho-rbet3 = lv_rbet3.
        APPEND wa_cabecalho TO it_cabecalho.
        CLEAR: wa_cabecalho, lv_rbet3.
        wa_cabecalho = it_cab_aux.
      ENDIF.

      wa_cabecalho = it_cab_aux.

    ENDIF.

    lv_rbet3 = lv_rbet3 + it_cab_aux-rbet3.
    wa_cabecalho-rbet3 = lv_rbet3.

  ENDLOOP.

  APPEND wa_cabecalho TO it_cabecalho.


  SORT it_cabecalho BY lifnr vblnr.


*  perform f_dispara_o_email.

ENDFORM.                    " F_MONTA_DADOS
*&---------------------------------------------------------------------*
*&      Form  F_CHAMA_SMARTFORM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_chama_smartform USING p_momento TYPE c.
*.................GET SMARTFORM FUNCTION MODULE NAME.................
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = c_formname
*     VARIANT            = ' '
*     DIRECT_CALL        = ' '
    IMPORTING
      fm_name            = v_fm_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CLEAR v_e_devtype.
  IF p_momento = 'X'.
    CALL FUNCTION 'SSF_GET_DEVICE_TYPE'
      EXPORTING
        i_language    = v_language
        i_application = 'SAPDEFAULT'
      IMPORTING
        e_devtype     = v_e_devtype.

    st_output_options-tdprinter     = v_e_devtype.
  ENDIF.

  st_output_options-tdnewid       = 'X'.
  st_control_parameters-getotf    = p_momento.
  st_control_parameters-no_dialog = p_momento.

*...........................CALL SMARTFORM............................

  CALL FUNCTION v_fm_name
    EXPORTING
      control_parameters   = st_control_parameters
      output_options       = st_output_options
    IMPORTING
      document_output_info = st_document_output_info
      job_output_info      = st_job_output_info
      job_output_options   = st_job_output_options
    TABLES
      itab                 = st_zfie009
    EXCEPTIONS
      formatting_error     = 1
      internal_error       = 2
      send_error           = 3
      user_canceled        = 4
      OTHERS               = 5.
  IF sy-subrc <> 0.

    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  FREE st_zfie009[].                                        "11/3

ENDFORM.                    " F_CHAMA_SMARTFORM
*&---------------------------------------------------------------------*
*&      Form  F_LIMPA_VARIAVEIS_EMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_limpa_variaveis_email .

  CLEAR:   st_reclist[],    "RC01
           st_objhead[],
           st_objtxt[],
           st_objbin[],
           st_objpack[].

  CLEAR: st_objhead[],
         wa_doc_chng.

ENDFORM.                    " F_LIMPA_VARIAVEIS_EMAIL
*&---------------------------------------------------------------------*
*&      Form  F_CONVERTE_OTF_EM_PDF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_converte_otf_em_pdf  USING    pt_email_job_info TYPE ssfcrescl.

  DATA: l_max_linewidth(3),
        l_bin_filesize     LIKE sood-objlen,
        lw_buffer          TYPE string,
        lt_otf             TYPE itcoo OCCURS 0 WITH HEADER LINE,
        lt_lines           TYPE TABLE OF tline WITH HEADER LINE,
        lt_record          LIKE solisti1 OCCURS 0 WITH HEADER LINE.

  REFRESH lt_otf.
  lt_otf[] = pt_email_job_info-otfdata[].

  l_max_linewidth = 132.

  CALL FUNCTION 'CONVERT_OTF'
    EXPORTING
      format                = 'PDF'
      max_linewidth         = l_max_linewidth
    IMPORTING
      bin_filesize          = l_bin_filesize
    TABLES
      otf                   = lt_otf
      lines                 = lt_lines
    EXCEPTIONS
      err_max_linewidth     = 1
      err_format            = 2
      err_conv_not_possible = 3
      OTHERS                = 4.
  IF sy-subrc <> 0.
  ENDIF.

  LOOP AT lt_lines.
    TRANSLATE lt_lines USING '~'.
    CONCATENATE lw_buffer lt_lines INTO lw_buffer.
  ENDLOOP.

  TRANSLATE lw_buffer USING '~'.

  DO.
    lt_record = lw_buffer.
    APPEND lt_record.
    SHIFT lw_buffer LEFT BY 255 PLACES.
    IF lw_buffer IS INITIAL.
      EXIT.
    ENDIF.
  ENDDO.

* Attachment
  LOOP AT lt_record.
    APPEND lt_record TO st_objbin.
  ENDLOOP.
  FREE lt_record[].


ENDFORM.                    " F_CONVERTE_OTF_EM_PDF
*&---------------------------------------------------------------------*
*&      Form  F_CARREGA_TEXTOS_EMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_carrega_textos_email .

  it_desc_textos_email-assunto = st_zfie009-butxt.
  it_desc_textos_email-spras        = 'PT'.
  APPEND it_desc_textos_email.

ENDFORM.                    " F_CARREGA_TEXTOS_EMAIL
*&---------------------------------------------------------------------*
*&      Form  F_CRIA_TEXTO_CORPO_E_DESCRICAO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_cria_texto_corpo_e_descricao .

  DESCRIBE TABLE st_objtxt LINES v_lines_txt.
  READ TABLE st_objtxt INDEX v_lines_txt.
  wa_doc_chng-obj_name = 'smartform'.
  wa_doc_chng-expiry_dat = sy-datum + 10.                   " + 10.

* 'Certificado de Qualidade - Providência'
  READ TABLE it_desc_textos_email
       WITH KEY spras = sy-langu.
  wa_doc_chng-obj_descr = it_desc_textos_email-assunto.

  wa_doc_chng-sensitivty = 'F'.
  wa_doc_chng-doc_size = v_lines_txt * 255.
ENDFORM.                    " F_CRIA_TEXTO_CORPO_E_DESCRICAO
*&---------------------------------------------------------------------*
*&      Form  F_CABEC_CORPO_EMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_cabec_corpo_email .
  DATA: l_texto TYPE char100.

  CLEAR st_objtxt.
  APPEND st_objtxt.
  APPEND st_objtxt.

  CONCATENATE c_cinquenta_asteriscos
              c_cinquenta_asteriscos
         INTO st_objtxt.

  APPEND st_objtxt.
  CLEAR st_objtxt.

  CONDENSE st_objtxt NO-GAPS.

  READ TABLE it_desc_textos_email
       WITH KEY spras = sy-langu.

  CONCATENATE c_cinquenta_asteriscos
              it_desc_textos_email-assunto
         INTO l_texto
         RESPECTING BLANKS.

  st_objtxt = l_texto.
  APPEND st_objtxt.

  CONCATENATE c_cinquenta_asteriscos
              c_cinquenta_asteriscos
         INTO st_objtxt.

  APPEND st_objtxt.

ENDFORM.                    " F_CABEC_CORPO_EMAIL
*&---------------------------------------------------------------------*
*&      Form  F_FECHA_LAYOUT_CORPO_EMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_fecha_layout_corpo_email .
  CLEAR st_objtxt.
  APPEND st_objtxt.

  CONCATENATE c_cinquenta_asteriscos
              c_cinquenta_asteriscos
         INTO st_objtxt.

  APPEND st_objtxt.
ENDFORM.                    " F_FECHA_LAYOUT_CORPO_EMAIL
*&---------------------------------------------------------------------*
*&      Form  F_CRIA_TEXTO_PRINCIPAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_cria_texto_principal .

*  read table st_objpack index 1.
*  if st_objpack-doc_type is initial.

* Main Text
  CLEAR st_objpack-transf_bin.
  st_objpack-head_start = 1.
  st_objpack-head_num = 0.
  st_objpack-body_start = 1.
  st_objpack-body_num = v_lines_txt.
  st_objpack-doc_type = 'RAW'.
  APPEND st_objpack.

*  endif.

ENDFORM.                    " F_CRIA_TEXTO_PRINCIPAL
*&---------------------------------------------------------------------*
*&      Form  F_PEGA_DESTINATARIOS_EMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_pega_destinatarios_email .

* Carrega destinatários do email
  IF it_cabecalho-lifnr IS NOT INITIAL.  "RC01

    LOOP AT it_adr6 WHERE bukrs = it_cabecalho-zbukr
                      AND lifnr = it_cabecalho-lifnr.

      CLEAR st_reclist.
      st_reclist-receiver = it_adr6-intad.
      st_reclist-rec_type = 'U'.
      st_reclist-com_type = 'INT'."Send via Internet

      APPEND st_reclist.

    ENDLOOP.

*-- RC01 Inicio
  ELSEIF it_cabecalho-kunnr IS NOT INITIAL.

    LOOP AT it_adr6 WHERE bukrs = it_cabecalho-zbukr
                    AND kunnr = it_cabecalho-kunnr.

      CLEAR st_reclist.
      st_reclist-receiver = it_adr6-intad.
      st_reclist-rec_type = 'U'.
      st_reclist-com_type = 'INT'."Send via Internet

      APPEND st_reclist.

    ENDLOOP.

*-- RC02 Inicio
    "Caso não encontre o email no cadastro do cliente pois não possui
    "cadastro de fornecedor
    IF st_reclist IS INITIAL.

      LOOP AT it_adr6_cliente WHERE bukrs = it_cabecalho-zbukr
                              AND kunnr = it_cabecalho-kunnr.

        CLEAR st_reclist.
        st_reclist-receiver = it_adr6_cliente-intad.
        st_reclist-rec_type = 'U'.
        st_reclist-com_type = 'INT'."Send via Internet

        APPEND st_reclist.

      ENDLOOP.

    ENDIF.
*-- RC02 Fim
  ENDIF.
*-- RC01 Fim

ENDFORM.                    " F_PEGA_DESTINATARIOS_EMAIL
*&---------------------------------------------------------------------*
*&      Form  F_DISPARA_O_EMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_dispara_o_email USING i_bukrs TYPE bukrs.           "BFB01
* BFB01 - Início
* Constantes locais
  CONSTANTS:
    BEGIN OF c_sender_type,
      email TYPE soextreci1-adr_typ VALUE 'SMTP',
    END OF c_sender_type.

* Tipos locais
  TYPES:
    BEGIN OF tp_sender,
      bukrs TYPE zfit109-bukrs,
      email TYPE zfit109-email,
    END OF tp_sender,
    tp_t_sender TYPE HASHED TABLE OF tp_sender
                     WITH UNIQUE KEY bukrs.

* Tabelas estaticas
  STATICS:
    ts_sender      TYPE tp_t_sender.

* Workareas locais
  DATA:
    wl_sender      LIKE LINE OF ts_sender.

* Variaveis estaticas
  DATA:
    vl_sender      TYPE soextreci1-receiver.

  READ TABLE ts_sender INTO wl_sender
    WITH TABLE KEY bukrs = i_bukrs.
  IF sy-subrc <> 0.
    "leitura do remetente
    SELECT SINGLE bukrs email
      FROM zfit109
      INTO wl_sender
     WHERE bukrs = i_bukrs.

    INSERT wl_sender INTO TABLE ts_sender.
  ENDIF.

  vl_sender = wl_sender-email.
* BFB01 - Fim


***********************************************************************
*Send the e-mail by using this function module
***********************************************************************
* BFB01 - Início
  "efetuar chamada direta da função SO_NEW_DOCUMENT_SEND_API1 devido à
  "possibilidade de informar um remetente
*  CALL FUNCTION  'SO_NEW_DOCUMENT_ATT_SEND_API1' "'SO_DOCUMENT_SEND_API1'"  ''
*     EXPORTING
*       document_data              = wa_doc_chng
*       put_in_outbox              = 'X'
*       commit_work                = 'X'
*     TABLES
*       packing_list               = st_objpack
*       object_header              = st_objhead
*       contents_bin               = st_objbin
*       contents_txt               = st_objtxt
*       receivers                  = st_reclist
*     EXCEPTIONS
*       too_many_receivers         = 1
*       document_not_sent          = 2
*       document_type_not_exist    = 3
*       operation_no_authorization = 4
*       parameter_error            = 5
*       x_error                    = 6
*       enqueue_error              = 7
*       OTHERS                     = 8.

  IF vl_sender IS INITIAL.
    CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
      EXPORTING
        document_data              = wa_doc_chng
        put_in_outbox              = 'X'
        commit_work                = 'X'
      TABLES
        packing_list               = st_objpack
        object_header              = st_objhead
        contents_bin               = st_objbin
        contents_txt               = st_objtxt
        receivers                  = st_reclist
      EXCEPTIONS
        too_many_receivers         = 1
        document_not_sent          = 2
        document_type_not_exist    = 3
        operation_no_authorization = 4
        parameter_error            = 5
        x_error                    = 6
        enqueue_error              = 7
        OTHERS                     = 8.
  ELSE.
    CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
      EXPORTING
        document_data              = wa_doc_chng
        put_in_outbox              = 'X'
        sender_address             = vl_sender
        sender_address_type        = c_sender_type-email
        commit_work                = 'X'
      TABLES
        packing_list               = st_objpack
        object_header              = st_objhead
        contents_bin               = st_objbin
        contents_txt               = st_objtxt
        receivers                  = st_reclist
      EXCEPTIONS
        too_many_receivers         = 1
        document_not_sent          = 2
        document_type_not_exist    = 3
        operation_no_authorization = 4
        parameter_error            = 5
        x_error                    = 6
        enqueue_error              = 7
        OTHERS                     = 8.
  ENDIF.
* BFB01 - Fim

  IF sy-subrc <> 0.
*  Erro no envio de email
*    MESSAGE e017(zlqm01).
  ELSE.
*  Email enviado com sucesso!
    MESSAGE s003(zmfi).
  ENDIF.

ENDFORM.                    " F_DISPARA_O_EMAIL

*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
FORM user_command USING r_ucomm     LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  CASE r_ucomm.
    WHEN '&IC1'. "Hiperlink

      PERFORM exibe_form USING rs_selfield-tabname
                               rs_selfield-tabindex.

    WHEN OTHERS.

  ENDCASE.


ENDFORM.                    "user_command
*&---------------------------------------------------------------------*
*&      Form  EXIBE_FORM
*&---------------------------------------------------------------------*
FORM exibe_form  USING    p_tabname
                          p_tabindex.


  CHECK p_tabname = 'IT_CABECALHO'.

  READ TABLE it_cabecalho INDEX p_tabindex.
  CHECK sy-subrc = 0.

  REFRESH st_zfie009.

*variaveis locais
  DATA: l_tot_vlr_bruto   LIKE zfie009-tot_vlr_bruto,
        l_tot_vlr_liquido LIKE zfie009-tot_vlr_liquido,
        l_tot_vlr_ir      LIKE zfie009-tot_vlr_liquido,
        l_tot_vlr_jd      LIKE zfie009-tot_vlr_liquido,
        vl_name           TYPE reguh-name1,                 " CDM01
        vl_stcd1          TYPE reguh-stcd1.                 " CDM01

  CLEAR st_zfie009.

  LOOP AT it_item WHERE chave = it_cabecalho-chave.

    l_tot_vlr_bruto   = st_zfie009-tot_vlr_bruto.
    l_tot_vlr_liquido = st_zfie009-tot_vlr_liquido.

    CLEAR st_zfie009.

    st_zfie009-tot_vlr_bruto   = l_tot_vlr_bruto .
    st_zfie009-tot_vlr_liquido = l_tot_vlr_liquido.

    CLEAR: l_tot_vlr_bruto, l_tot_vlr_liquido.

    it_item-qbshb = - it_item-qbshb.

* CDM01 - Inicio
    CLEAR: vl_name, vl_stcd1.

    IF it_cabecalho-empfg IS NOT INITIAL AND
       it_cabecalho-empfg <> it_cabecalho-lifnr.
      vl_name  = it_cabecalho-name1.
      vl_stcd1 = it_cabecalho-stcd1.
    ELSE.
      vl_name  = it_cabecalho-znme1.
      vl_stcd1 = it_cabecalho-zstc1.
    ENDIF.
* CDM01 - Fim

    CALL FUNCTION 'CONVERSION_EXIT_CGCBR_OUTPUT'
      EXPORTING
        input  = vl_stcd1                                   " CDM01
      IMPORTING
        output = st_zfie009-zstc1.

    st_zfie009-zstc1 = st_zfie009-zstc1+0(18).
    st_zfie009-znme1 = vl_name.                             " CDM01
    st_zfie009-zaldt = it_cabecalho-zaldt.

    READ TABLE it_reguh INTO wa_reguh
                        WITH KEY laufi = it_item-chave+8(5) "it_item-laufi
                                 laufd = it_item-chave(8) "it_item-laufd
                                 lifnr = it_item-lifnr
                                 vblnr = it_item-vblnr.
    IF sy-subrc EQ 0.
      st_zfie009-zbnkl      = wa_reguh-zbnkl.
      st_zfie009-zbnkn      = wa_reguh-zbnkn.
    ENDIF.

*     Nota Fiscal
    IF it_item-xblnr IS INITIAL.
      st_zfie009-xblnr      = 'Adto'.
    ELSE.
      st_zfie009-xblnr      = it_item-xblnr.
    ENDIF.
    IF it_item-shkzg EQ 'S'.
      it_item-dmbtr      = - it_item-dmbtr.
    ENDIF.
    st_zfie009-dmbtr      = it_item-dmbtr.
    st_zfie009-qbshb      = - it_item-qbshb.
    st_zfie009-sknto      = it_item-sknto.
    READ TABLE it_adr6 WITH KEY bukrs = it_cabecalho-zbukr
                                lifnr = it_cabecalho-lifnr.
    IF sy-subrc IS INITIAL.
      st_zfie009-smtp_addr   =  it_adr6-intad.
    ENDIF.
    READ TABLE it_t001 WITH KEY bukrs = it_item-bukrs.
    IF sy-subrc IS INITIAL.
      st_zfie009-butxt           = it_t001-butxt.
      CONCATENATE '(' it_t001-tel_number(1) it_t001-tel_number+1(1) ')' it_t001-tel_number+2 INTO it_t001-tel_number.
      st_zfie009-tel_number      = it_t001-tel_number.
    ENDIF.

*   Impostos Retidos
    it_item-qbshb = - it_item-qbshb. "Vlr negativo

    IF it_item-dmbtr LT '0'.
      it_item-wrbtr = - it_item-dmbtr + it_item-qbshb.
      it_item-wrbtr = - it_item-wrbtr.
    ELSE.
      it_item-wrbtr = it_item-dmbtr + it_item-qbshb.
    ENDIF.
    st_zfie009-rbetr       = it_item-wrbtr.
    st_zfie009-vlr_bruto   = st_zfie009-vlr_bruto   + it_item-dmbtr.
    st_zfie009-vlr_liquido = st_zfie009-vlr_liquido + it_item-wrbtr + st_zfie009-sknto.

*   Verificar Debito/Credito
    IF it_item-shkzg EQ 'S'. "Negativo
      st_zfie009-vlr_bruto   = - st_zfie009-vlr_bruto.
      st_zfie009-vlr_liquido = - st_zfie009-vlr_liquido.
      st_zfie009-rbetr       = - st_zfie009-rbetr.
      st_zfie009-dmbtr       = - st_zfie009-dmbtr.
    ENDIF.

    l_tot_vlr_ir      = l_tot_vlr_ir + st_zfie009-qbshb.
    l_tot_vlr_jd      = l_tot_vlr_jd + st_zfie009-sknto.

*    st_zfie009-rbetr       = it_item-wrbtr.
*    st_zfie009-vlr_bruto   = st_zfie009-rbetr.
*    st_zfie009-vlr_liquido = st_zfie009-rbetr +  st_zfie009-sknto.

*   Vlr total bruto
    st_zfie009-tot_vlr_bruto   = st_zfie009-tot_vlr_bruto + st_zfie009-vlr_bruto."st_zfie009-tot_vlr_bruto + st_zfie009-vlr_bruto.
    st_zfie009-tot_vlr_liquido = st_zfie009-tot_vlr_liquido + st_zfie009-vlr_liquido.

    st_zfie009-vlr_bruto   = l_tot_vlr_ir.
    st_zfie009-vlr_liquido = l_tot_vlr_jd.

*   Vlr total bruto
*    l_tot_vlr_bruto = l_tot_vlr_bruto + st_zfie009-vlr_bruto.
*    st_zfie009-tot_vlr_bruto   = l_tot_vlr_bruto.
*
**   Vlr total liquido
*    l_tot_vlr_liquido = l_tot_vlr_liquido + st_zfie009-vlr_liquido.
*    st_zfie009-tot_vlr_liquido = l_tot_vlr_liquido.

    APPEND st_zfie009.

  ENDLOOP.

  PERFORM f_chama_smartform USING space.

ENDFORM.                    " EXIBE_FORM



*&---------------------------------------------------------------------*
*&      Form  F_ANEXA_O_ARQUIVO_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_anexa_o_arquivo_2 .

  DATA: l_lines_bin TYPE i.
  DATA n TYPE i VALUE 1.

  vl_contador = vl_contador + 1.

* Attachment (pdf-Attachment)
  st_objpack-transf_bin = 'X'.
  st_objpack-head_start = 1.
  st_objpack-head_num = 1. "0
  st_objpack-body_start = 1.

  DESCRIBE TABLE st_objbin LINES l_lines_bin.
*  read table st_objbin index l_lines_bin.

*  if vl_tabix eq 1.
*    vl_posicin = l_lines_bin + 1.
*    vl_posicfn = ( vl_posicin +  ( l_lines_bin - 1 ) ).
*  else.
*    IF vl_posicfn IS NOT INITIAL.
*      vl_posicin = vl_posicfn .
*    ELSE.
*      vl_posicin = vl_posicfn + 1.
*    ENDIF.
*
**    vl_posicfn =  ( vl_posicin +  ( l_lines_bin - 1 ) ).
*    vl_posicfn =  l_lines_bin .
*  endif.

  vl_posicin =  1 .
  vl_posicfn =  l_lines_bin .

*  st_objpack-head_start = vl_posicin .
  st_objpack-body_start = vl_posicin. " 1. "vl_posicin
*  st_objpack-body_start = l_lines_bin.


*  st_objpack-doc_size = l_lines_bin * 255 .
  st_objpack-doc_size = ( vl_posicfn - vl_posicin + 1 ) * 255 .
  st_objpack-body_num = vl_posicfn. "l_lines_bin.
  st_objpack-doc_type = 'PDF'.
  CONCATENATE 'smart' vl_contador INTO st_objpack-obj_name.
  st_objpack-obj_descr = 'notificacao_de_pagamento'.


  APPEND st_objpack.

ENDFORM.                    " F_ANEXA_O_ARQUIVO_2
