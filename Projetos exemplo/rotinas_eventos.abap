************************************************************************
*                 Cast Group - Produtos e Aceleradores                 *
************************************************************************
* ID Modif.: CFR01
* Autor    : T112484 - Marcelo Araújo
* Data     : 24.01.2022
* Especifi.: DEVK9AKDSH   4000038715   CHG0070812
* Descrição: Relatório de Rendimentos
* Solicit. : Karen Regina Pikina Moraes <karen.moraes@castgroup.com.br>
*            Lindomar Basilio Soares <lindomar.soares@castgroup.com.br>
* Projeto  : Projeto Automatização Processos Ingredients
***********************************************************************
* ID Modif.: <sigla>
* Autor    : <autor da alteração>
* Data     : <data da alteração>
* Especifi.: <Nº GAP,Request e Change no SOLMAN, ID da EF com Versão>
* Descrição: <descrição da alteração>
* Solicit. : <funcional/usuário responsável>
* Projeto  : <Nome do Projeto>
***********************************************************************
*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
*  PERFORM f_consistir_autorizacao.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.

  IF s_nfenum IS INITIAL AND
     p_series IS INITIAL AND
     p_werks  IS INITIAL AND
     s_gnf    IS INITIAL AND
     s_dt_doc IS INITIAL AND
     s_docnum IS INITIAL AND
     s_parc   IS INITIAL AND
     s_mat_ge IS INITIAL.

    " Obrigatório informar ao menos o campo de data..
    MESSAGE ID 'ZCLPP02' TYPE 'S' NUMBER 089 DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.

  ELSE.
*    PERFORM f_consistir_autorizacao.
    PERFORM f_seleciona_dados.
    PERFORM f_monta_dados.
    PERFORM f_executa_alv.

  ENDIF.
*&---------------------------------------------------------------------*
*&      Form  F_CONSISTIR_AUTORIZACAO
*&---------------------------------------------------------------------*
FORM f_consistir_autorizacao.

* -- Controle de horário e tipo de processamento (On line/Background)
  CALL FUNCTION 'Z8_VERIFICA_PERMISSAO_COMPL'
    EXPORTING
      x_cprog    = sy-cprog
      x_dtinicio = sy-datum
      x_hrinicio = sy-uzeit
    EXCEPTIONS
      OTHERS     = 1.

  AUTHORITY-CHECK OBJECT 'Z:SEU_OBJETO'
            ID 'ACTVT' FIELD '*'.

  IF sy-subrc NE 0.
    MESSAGE e163(zp) WITH sy-tcode.
  ENDIF.

ENDFORM.        "F_CONSISTIR_AUTORIZACAO
*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_DADOS
*&---------------------------------------------------------------------*
FORM f_seleciona_dados.
  DATA: rl_status    TYPE RANGE OF z06551007-status,
        wl_1007_1006 TYPE ty_1007_1006,
        wl_status    LIKE LINE OF rl_status.

  wl_status-sign      = c_sign.
  wl_status-option    = c_option.

  IF r_pend IS NOT INITIAL.
    wl_status-low = 3. " Pendente
    APPEND wl_status TO rl_status.

  ELSEIF r_concl IS NOT INITIAL.
    wl_status-low = 1. " Concluído
    APPEND wl_status TO rl_status.

  ELSE.
    wl_status-low = 1. " Concluído
    APPEND wl_status TO rl_status.

    wl_status-low = 3. " Pendente
    APPEND wl_status TO rl_status.

  ENDIF.

  SELECT docnum
         nfenum
         series
         documento
         status
         centro
         dt_documento
         parceiro
    FROM z06551007
    INTO TABLE t_1007
    WHERE docnum       IN s_docnum
      AND nfenum       IN s_nfenum
      AND documento    IN s_gnf
      AND status       IN rl_status
      AND dt_documento IN s_dt_doc
      AND parceiro     IN s_parc.

  IF sy-subrc IS INITIAL.
    IF p_series IS NOT INITIAL.
      DELETE t_1007 WHERE series NE p_series.
    ENDIF.

    IF p_werks IS NOT INITIAL.
      DELETE t_1007 WHERE centro NE p_werks.
    ENDIF.

    DELETE t_1007 WHERE status EQ 2.

    IF t_1007[] IS NOT INITIAL.
      SORT t_1007 BY docnum.

      SELECT docnum
             mat_generico
             perc_rendimento
             menge_rendimento
         FROM z06551006
         INTO TABLE t_1006
        FOR ALL ENTRIES IN t_1007
         WHERE docnum       EQ t_1007-docnum
           AND mat_generico IN s_mat_ge
           AND status       NE 4.

      IF sy-subrc IS INITIAL.
        SORT t_1006 BY docnum.

        LOOP AT t_1006 INTO DATA(wl_1006).
          READ TABLE t_1007 INTO DATA(wl_1007)
            WITH KEY docnum = wl_1006-docnum
                     BINARY SEARCH.

          IF sy-subrc IS INITIAL.
            wl_1007_1006-docnum           = wl_1007-docnum.
            wl_1007_1006-nfenum           = wl_1007-nfenum.
            wl_1007_1006-series           = wl_1007-series.
            wl_1007_1006-documento        = wl_1007-documento.
            wl_1007_1006-status           = wl_1007-status.
            wl_1007_1006-centro           = wl_1007-centro.
            wl_1007_1006-dt_documento     = wl_1007-dt_documento.
            wl_1007_1006-parceiro         = wl_1007-parceiro.
            wl_1007_1006-mat_generico     = wl_1006-mat_generico.
            wl_1007_1006-perc_rendimento  = wl_1006-perc_rendimento.
            wl_1007_1006-menge_rendimento = wl_1006-menge_rendimento.

            APPEND wl_1007_1006 TO t_1007_1006.
            CLEAR wl_1007_1006.

          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

    IF t_1007_1006[] IS NOT INITIAL.

      SORT t_1007_1006 BY docnum.

      DATA(tl_1007_1006) = t_1007_1006[].
      SORT tl_1007_1006 BY documento.
      DELETE ADJACENT DUPLICATES FROM tl_1007_1006 COMPARING documento.

      IF tl_1007_1006[] IS NOT INITIAL.
        SELECT t021~documento
               t022~item
               t021~branch
               t021~bukrs
               t022~cfop
          FROM       /sprognf/t021 AS t021
          INNER JOIN /sprognf/t022 AS t022
                  ON t022~documento EQ t021~documento
          INTO TABLE t_t021_t022
          FOR ALL ENTRIES IN tl_1007_1006
            WHERE t021~documento EQ tl_1007_1006-documento.

        IF sy-subrc IS INITIAL.
          SORT t_t021_t022 BY documento.

        ENDIF.
        tl_1007_1006[] = t_1007_1006[].
        SORT tl_1007_1006 BY docnum.
        DELETE ADJACENT DUPLICATES FROM tl_1007_1006 COMPARING docnum.

        SELECT docnum
               regio
               pstdat
          FROM j_1bnfdoc
          INTO TABLE t_doc
          FOR ALL ENTRIES IN t_1007_1006
            WHERE docnum EQ t_1007_1006-docnum.

        IF sy-subrc IS INITIAL.
          SORT t_doc BY docnum.

        ENDIF.

        SELECT docnum
               ebeln_pedido
               item_pedido
               ebeln_contrato
               matnr_pa
               qte_prev_pa
               mat_generico
          FROM z06551008
          INTO TABLE t_1008
          FOR ALL ENTRIES IN tl_1007_1006
            WHERE docnum EQ tl_1007_1006-docnum.

        IF sy-subrc IS INITIAL.
          SORT: t_1008 BY docnum
                          mat_generico.

          DATA(tl_1008) = t_1008[].
          SORT tl_1008 BY ebeln_pedido
                          item_pedido.
          DELETE ADJACENT DUPLICATES FROM tl_1008
                                COMPARING ebeln_pedido
                                          item_pedido.

          IF tl_1008[] IS NOT INITIAL.
            SELECT ebeln
                   ebelp
                   brtwr
                   menge
                   ktpnr
              FROM ekpo
              INTO TABLE t_ekpo
              FOR ALL ENTRIES IN tl_1008
                WHERE ebeln EQ tl_1008-ebeln_pedido
                  AND ebelp EQ tl_1008-item_pedido.

            IF sy-subrc IS INITIAL.
              SORT t_ekpo BY ebeln.

            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      tl_1007_1006 = t_1007_1006[].
      SORT tl_1007_1006 BY parceiro.
      DELETE ADJACENT DUPLICATES FROM tl_1007_1006 COMPARING parceiro.

      IF tl_1007_1006[] IS NOT INITIAL.
        SELECT lifnr
               name1
          FROM lfa1
          INTO TABLE t_lfa1
          FOR ALL ENTRIES IN tl_1007_1006
            WHERE lifnr EQ tl_1007_1006-parceiro.

        IF sy-subrc IS INITIAL.
          SORT t_lfa1 BY lifnr.

        ENDIF.
      ENDIF.

      tl_1007_1006 = t_1007_1006[].
      SORT tl_1007_1006 BY mat_generico.
      DELETE ADJACENT DUPLICATES FROM tl_1007_1006 COMPARING mat_generico.

      IF tl_1007_1006[] IS NOT INITIAL.
        SELECT mat_generico
               desc_mat_generico
          FROM z06551001
          INTO TABLE t_1001
          FOR ALL ENTRIES IN tl_1007_1006
            WHERE mat_generico EQ tl_1007_1006-mat_generico.

        IF sy-subrc IS INITIAL.
          SORT t_1001 BY mat_generico.

        ENDIF.

      ENDIF.

      tl_1007_1006 = t_1007_1006[].
      SORT tl_1007_1006 BY mat_generico
                           centro
                           parceiro.

      DELETE ADJACENT DUPLICATES FROM tl_1007_1006 COMPARING mat_generico
                                                             centro
                                                             parceiro.
      " Tira Zeros à esquerda
      LOOP AT tl_1007_1006 ASSIGNING FIELD-SYMBOL(<fl_1007_1006>).
        <fl_1007_1006>-mat_generico = |{ <fl_1007_1006>-mat_generico ALPHA = OUT }|.
        <fl_1007_1006>-parceiro     = |{ <fl_1007_1006>-parceiro     ALPHA = OUT }|.
      ENDLOOP.

      IF tl_1007_1006[] IS NOT INITIAL.
        SELECT mat_generico
               werks
               dt_ativacao
               lifnr
               perc_rendimento
               brwtr
               meins
               waers
          FROM z06551004
          INTO TABLE t_rendimento
           FOR ALL ENTRIES IN tl_1007_1006
           WHERE mat_generico EQ tl_1007_1006-mat_generico
             AND werks        EQ tl_1007_1006-centro
             AND lifnr        EQ tl_1007_1006-parceiro.

        IF sy-subrc IS INITIAL.
          SORT t_rendimento BY mat_generico
                               werks
                               lifnr
                               dt_ativacao DESCENDING.

          " Põe Zeros à esquerda
          LOOP AT t_rendimento ASSIGNING FIELD-SYMBOL(<fl_rendimento>).
            <fl_rendimento>-mat_generico = |{ <fl_rendimento>-mat_generico ALPHA = IN }|.
            <fl_rendimento>-lifnr        = |{ <fl_rendimento>-lifnr        ALPHA = IN }|.
          ENDLOOP.

        ENDIF.
      ENDIF.

    ELSE.
*     Não há dados para os critérios de seleção especificados.
      MESSAGE ID 'ZCLPP02' TYPE 'S' NUMBER 053 DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.

    ENDIF.
  ENDIF.

ENDFORM.        "F_SELECIONA_DADOS
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_DADOS
*&---------------------------------------------------------------------*
FORM f_monta_dados .
  DATA: tl_1008     TYPE TABLE OF ty_1008,
        wl_1008_aux TYPE ty_1008,
        wl_alv      TYPE z06551010.

  tl_1008 = t_1008[].
  SORT tl_1008 BY docnum
                  mat_generico.

  LOOP AT t_1007_1006 INTO DATA(wl_1007_1006).

    READ TABLE t_rendimento TRANSPORTING NO FIELDS
      WITH KEY mat_generico = wl_1007_1006-mat_generico
               werks        = wl_1007_1006-centro
               lifnr        = wl_1007_1006-parceiro.

    IF sy-subrc IS INITIAL.
      LOOP AT t_rendimento INTO DATA(wl_rendimento) FROM sy-tabix.
        DATA(vl_dt_documento) = wl_rendimento-dt_ativacao.

        IF wl_1007_1006-dt_documento >= wl_rendimento-dt_ativacao.
          EXIT.

        ELSE.
          CLEAR: vl_dt_documento.
        ENDIF.

      ENDLOOP.
    ENDIF.

    IF vl_dt_documento IS NOT INITIAL.
      wl_alv-documento          = wl_1007_1006-documento.
      wl_alv-docnum             = wl_1007_1006-docnum.
      wl_alv-nfenum             = wl_1007_1006-nfenum.
      wl_alv-series             = wl_1007_1006-series.
      wl_alv-werks              = wl_1007_1006-centro.
      wl_alv-parceiro           = wl_1007_1006-parceiro.
      wl_alv-ano                = wl_1007_1006-dt_documento(4).
      wl_alv-mes                = wl_1007_1006-dt_documento+4(2).
      wl_alv-dt_documento       = wl_1007_1006-dt_documento.
      wl_alv-mat_generico       = wl_1007_1006-mat_generico.
      wl_alv-perc_rendimento    = wl_1007_1006-perc_rendimento.
      wl_alv-qte_inicial        = wl_1007_1006-menge_rendimento.

      wl_alv-moeda_inicial      = wl_rendimento-waers.
      wl_alv-moeda_retornada    = wl_rendimento-waers.
      wl_alv-unid_inicial       = wl_rendimento-meins.
      wl_alv-unid_pendente      = wl_rendimento-meins.
      wl_alv-unid_retornada     = wl_rendimento-meins.

      READ TABLE t_t021_t022 INTO DATA(wl_t021_t022)
        WITH KEY documento = wl_1007_1006-documento
                 BINARY SEARCH.

      IF sy-subrc IS INITIAL.
        wl_alv-bukrs   = wl_t021_t022-bukrs.
        wl_alv-branch  = wl_t021_t022-branch.
        wl_alv-cfop    = wl_t021_t022-cfop.

      ENDIF.

      READ TABLE t_lfa1 INTO DATA(wl_lfa1)
        WITH KEY lifnr = wl_1007_1006-parceiro
                 BINARY SEARCH.

      IF sy-subrc IS INITIAL.
        wl_alv-name1   = wl_lfa1-name1.
      ENDIF.

      READ TABLE t_doc INTO DATA(wl_doc)
         WITH KEY docnum = wl_1007_1006-docnum
                  BINARY SEARCH.

      IF sy-subrc IS INITIAL.
        wl_alv-regio    = wl_doc-regio.
        wl_alv-pstdat   = wl_doc-pstdat.
      ENDIF.

      READ TABLE t_1001 INTO DATA(wl_1001)
         WITH KEY mat_generico = wl_1007_1006-mat_generico
                  BINARY SEARCH.

      IF sy-subrc IS INITIAL.
        wl_alv-desc_mat_generico  = wl_1001-desc_mat_generico.
      ENDIF.

      READ TABLE t_1008 INTO DATA(wl_1008)
         WITH KEY docnum       = wl_1007_1006-docnum
                  mat_generico = wl_1007_1006-mat_generico
                  BINARY SEARCH.

      IF sy-subrc IS INITIAL.
        DATA(vl_tabix) = sy-tabix.

        wl_alv-ebeln_pedido     = wl_1008-ebeln_pedido.
        wl_alv-item_pedido      = wl_1008-item_pedido.
        wl_alv-ebeln_contrato   = wl_1008-ebeln_contrato.

        READ TABLE t_ekpo INTO DATA(wl_ekpo)
          WITH KEY ebeln = wl_1008-ebeln_pedido
                   ebelp = wl_1008-item_pedido
                   BINARY SEARCH.

        IF sy-subrc IS INITIAL.
          wl_alv-ktpnr          = wl_ekpo-ktpnr.

          IF wl_1007_1006-menge_rendimento IS NOT INITIAL.
            wl_alv-preco_tonelada = ( wl_ekpo-brtwr / wl_ekpo-menge ) * 1000 .

            wl_alv-preco_total    = ( wl_alv-preco_tonelada *
                                      wl_1007_1006-menge_rendimento ) / 1000.

          ENDIF.
        ENDIF.

        LOOP AT tl_1008 INTO wl_1008_aux FROM vl_tabix.

          IF wl_1008_aux-docnum       NE wl_1007_1006-docnum      OR
             wl_1008_aux-mat_generico NE wl_1007_1006-mat_generico.
            EXIT.

          ELSE.
            wl_alv-qte_retornada = wl_alv-qte_retornada + wl_1008_aux-qte_prev_pa.

          ENDIF.
        ENDLOOP.

      ELSE.
        IF wl_1007_1006-menge_rendimento IS NOT INITIAL.
          wl_alv-preco_tonelada = wl_rendimento-brwtr * 1000.

          wl_alv-preco_total    = ( wl_rendimento-brwtr *
                                    wl_1007_1006-menge_rendimento ).

        ENDIF.
      ENDIF.

      IF wl_alv-qte_retornada IS NOT INITIAL.
        wl_alv-preco_ton_retorn = wl_alv-preco_total.

        wl_alv-preco_total_retorn = ( wl_alv-preco_tonelada *
                                      wl_alv-qte_retornada ) / 1000.

      ENDIF.

      wl_alv-qte_pendente      = wl_alv-qte_inicial - wl_alv-qte_retornada.
      wl_alv-preco_ton_pend    = wl_alv-preco_tonelada.
      wl_alv-preco_total_pend  = ( wl_alv-preco_tonelada *
                                   wl_alv-qte_pendente     ) / 1000.

      APPEND wl_alv TO t_alv.
      CLEAR: wl_alv,  wl_t021_t022, wl_rendimento, wl_lfa1, wl_doc, wl_1001,
             wl_1008, wl_ekpo, vl_dt_documento.

    ENDIF.
  ENDLOOP.

  SORT t_alv BY documento docnum mat_generico.

ENDFORM.        "F_MONTA_DADOS
*&---------------------------------------------------------------------*
*&      Form  F_EXECUTA_ALV
*&---------------------------------------------------------------------*
FORM f_executa_alv .

  DATA: wl_layout TYPE slis_layout_alv,
        tl_fcat   TYPE slis_t_fieldcat_alv.

  wl_layout-zebra             = abap_true.
  wl_layout-colwidth_optimize = abap_true.



  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      it_fieldcat   = tl_fcat
      is_layout     = wl_layout
    TABLES
      t_outtab      = t_alv
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.

ENDFORM.