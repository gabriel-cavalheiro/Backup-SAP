*&------------------------------------------------------------------*
*& NOME DO PROGRAMA    : ZP_PLANEJADO_X_REALIZADO                   *
*& TÍTULO DO PROGRAMA  : Comparação Custos Plan x Real Projetos RTS *
*& DESCRIÇÃO           : Prog. Comparação Planejado X Realizado     *
*& EMPRESA             : CAST GROUP                                 *
*& PROGRAMADOR         : Rogério Madaleno                           *
*& DATA                : 16/03/2022                                 *
*& REQUEST             : ECDK9A37E8                                 *
*-------------------------------------------------------------------*
*& HISTÓRICO DE MUDANÇAS:                                           *
*-------------------------------------------------------------------*
*& INDICE|  DATA    |    AUTOR     |  REQUEST | DESCRIÇÃO           *
*& 001   |16/03/2022| RMADALENO    |ECDK9A37E9| CÓDIGO INICIAL      *
*&------------------------------------------------------------------*
*&------------------------------------------------------------------*
REPORT zp_planejado_x_realizado.

TABLES: prps, cosp.

*&------------------------------------------------------------------*
*& Definição da(s) Estrutura(s)                                     *
*&------------------------------------------------------------------*
TYPES: BEGIN OF ty_coss,
         objnr TYPE coss-objnr,
         horas TYPE coss-meg001,
         valor TYPE coss-wog001,
         uspob TYPE coss-uspob,
         ltext TYPE cskt-ltext,
       END OF ty_coss,

       BEGIN OF ty_qbew,
         pspnr   TYPE qbew-pspnr,
         estoque TYPE qbew-salk3,
       END OF ty_qbew,

       BEGIN OF ty_qbewh,
         matnr   TYPE qbewh-matnr,
         estoque TYPE qbewh-salk3,
         bwkey   TYPE qbewh-bwkey,
         beskz   TYPE marc-beskz,
       END OF ty_qbewh,

       BEGIN OF ty_qbewh_tot,
         pspnr   TYPE qbew-pspnr,
         estoque TYPE qbew-salk3,
       END OF ty_qbewh_tot,

       BEGIN OF ty_cooi,
         objnr       TYPE cooi-objnr,
         compromisso TYPE cooi-megbtr,
       END OF ty_cooi,

       BEGIN OF ty_coep_tot,
         objnr    TYPE coep-objnr,
         estoque2 TYPE coep-wogbtr,
       END OF ty_coep_tot,


       BEGIN OF ty_alv,
         pep             TYPE afpo-projn,
         material        TYPE afpo-matnr,
         projeto         TYPE prps-post1,
         horas           TYPE zhoras_atividade,
         valor           TYPE zvalor_atividade,
         estoque         TYPE zvalor_estoque,
         estoque2        TYPE zvalor_estoque2,
         compromisso     TYPE zcompromisso,
         disposto        TYPE zdisposto,
         orcado          TYPE zorcado,
         planejado       TYPE zplanejado,
         saldo_orcamento TYPE zsaldo_orcamento,
         saldo_planejado TYPE zsaldo_planejado,
       END OF ty_alv,

       BEGIN OF ty_cc,
         pep   TYPE afpo-projn,
         uspob TYPE coss-uspob,
         ltext TYPE cskt-ltext,
         horas TYPE zhoras_atividade,
         valor TYPE zvalor_atividade,
       END OF ty_cc.

*&------------------------------------------------------------------*
*& Definição da(s) Variáveis                                        *
*&------------------------------------------------------------------*
DATA: lv_pep    TYPE prps-poski,
      lv_pspnr  TYPE afpo-projn, "SM2
      lv_matnr  TYPE afpo-matnr, "SM2
      lv_column TYPE string.     "SM2
*&------------------------------------------------------------------*
*& Definição da(s) Contante(s)                                      *
*&------------------------------------------------------------------*
CONSTANTS: c_zp05  TYPE char4 VALUE 'ZP05',
           c_6000  TYPE char4 VALUE '6000',
           c_1     TYPE char1 VALUE '1',
           c_04    TYPE char2 VALUE '04',
           c_0003  TYPE char4 VALUE '0003',
           c_21    TYPE char2 VALUE '21',
           c_22    TYPE char2 VALUE '22',
           c_41    TYPE char2 VALUE '41',
           c_i0046 TYPE char5 VALUE 'I0046'.


*&------------------------------------------------------------------*
*& Definição da(s) Work-Areas                                       *
*&------------------------------------------------------------------*
DATA: w_aufk     TYPE aufk,
      w_afpo     TYPE afpo,
      w_coss     TYPE coss,
      w_prps     TYPE prps,
      w_qbew     TYPE qbew,
      w_qbewh    TYPE ty_qbewh,
      w_qbewh_dt TYPE qbewh,
      w_cooi     TYPE cooi,
      w_coep     TYPE coep,
      w_bpge_or  TYPE bpge,
      w_bpge_pl  TYPE bpge,
      w_jest     TYPE jest,
      w_cc       TYPE ty_cc,
      w_alv      TYPE ty_alv.

DATA: w_coss_tot     TYPE ty_coss,
      w_qbew_tot     TYPE ty_qbew,
      w_cooi_tot     TYPE ty_cooi,
      w_prps_projeto TYPE prps,
      w_qbewh_tot    TYPE ty_qbewh_tot,
      w_coep_tot     TYPE ty_coep_tot.


*&------------------------------------------------------------------*
*& Definição da(s) Tabela(s) Interna(s)                             *
*&------------------------------------------------------------------*
DATA: t_aufk     TYPE TABLE OF aufk,
      t_afpo     TYPE TABLE OF afpo,
      t_coss     TYPE TABLE OF coss,
      t_prps     TYPE TABLE OF prps,
      t_qbew     TYPE TABLE OF qbew,
      t_cooi     TYPE TABLE OF cooi,
      t_coep     TYPE TABLE OF coep,
      t_bpge_or  TYPE TABLE OF bpge,
      t_bpge_pl  TYPE TABLE OF bpge,
      t_jest     TYPE TABLE OF jest,
      t_cskt     TYPE TABLE OF cskt,
      t_qbewh    TYPE TABLE OF ty_qbewh,
      t_qbewh_dt TYPE TABLE OF qbewh,
      t_cc       TYPE TABLE OF ty_cc,
      t_alv      TYPE TABLE OF ty_alv.

DATA: t_coss_tot  TYPE TABLE OF ty_coss,
      t_qbew_tot  TYPE TABLE OF ty_qbew,
      t_qbewh_tot TYPE TABLE OF ty_qbewh_tot,
      t_cooi_tot  TYPE TABLE OF ty_cooi,
      t_coep_tot  TYPE TABLE OF ty_coep_tot.


*&------------------------------------------------------------------*
*& Definição da Tela de Seleção                                     *
*&------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE text-000.
PARAMETERS:
  p_ativo TYPE char1 RADIOBUTTON GROUP g1,
  p_encer TYPE char1 RADIOBUTTON GROUP g1,
  p_saldo TYPE char1 RADIOBUTTON GROUP g1.
SELECTION-SCREEN: END OF BLOCK b1.

SELECTION-SCREEN: BEGIN OF BLOCK b2 WITH FRAME TITLE text-t01. " LAR-29.07.2022-ECDK9A3COI-SM001-Inclisão dos filtros.

SELECT-OPTIONS:
  s_posid FOR prps-posid NO INTERVALS,
  s_perbl FOR cosp-perbl NO-EXTENSION,
  s_gjahr FOR cosp-gjahr.

SELECTION-SCREEN: END OF BLOCK b2.

START-OF-SELECTION.

  IF s_gjahr[] IS NOT INITIAL
    OR s_perbl[] IS NOT INITIAL
    OR s_posid[] IS NOT INITIAL.
    IF s_gjahr[]  IS INITIAL
     OR s_perbl[] IS INITIAL
     OR s_posid[] IS INITIAL.
      MESSAGE 'Informar Elemento PEP, Bloco de períodos e Exercício .' TYPE 'S' DISPLAY LIKE 'E'.
      STOP.
    ENDIF.
  ENDIF.

  PERFORM selecoes.

  PERFORM sumariza.

  PERFORM monta_saida.

  IF t_alv[] IS INITIAL AND t_cc IS INITIAL.
    MESSAGE 'Nenhum registro foi encontrado .' TYPE 'S' DISPLAY LIKE 'E'.
  ELSE.
    PERFORM exibe_alv.
  ENDIF.

*&------------------------------------------------------------------*
*& Definição do evento de click no ALV  SM2                         *
*&------------------------------------------------------------------*
CLASS lcl_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_link_click FOR EVENT link_click  "Hotspot Handler
                  OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.                    "lcl_events DEFINITION
*
*&------------------------------------------------------------------*
*& Implementação do evento de click no ALV SM2                      *
*&------------------------------------------------------------------*
CLASS lcl_events IMPLEMENTATION.
  METHOD on_link_click.

    lv_column = column.
    CLEAR lv_pspnr.
    CLEAR lv_matnr.
    READ TABLE t_alv INTO w_alv
    INDEX row.
    lv_pspnr = w_alv-pep.
    lv_matnr = w_alv-material.

    PERFORM z_detalhes_itens.

  ENDMETHOD.                    "on_link_click
*
ENDCLASS.
*&---------------------------------------------------------------------*
*&      Form  SELEÇÕES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM selecoes .
  "Ordens do tipo ZP05 e empresa 6000
  SELECT * FROM aufk
    INTO TABLE t_aufk
    WHERE auart EQ c_zp05
    AND bukrs EQ c_6000.

*  IF NOT p_ativo IS INITIAL.
*    "Projetos ativos
*    SELECT * FROM jest
*      INTO TABLE t_jest
*      FOR ALL ENTRIES IN t_aufk
*      WHERE objnr EQ t_aufk-objnr
*      AND stat NE c_i0046
*      AND inact EQ space.
*  ENDIF.

*  IF NOT p_encer IS INITIAL.
*    "Projetos encerrados
*    SELECT * FROM jest
*      INTO TABLE t_jest
*      FOR ALL ENTRIES IN t_aufk
*      WHERE objnr EQ t_aufk-objnr
*      AND stat EQ c_i0046.
*  ENDIF.

  IF t_aufk[] IS NOT INITIAL.

    "Buscar as ordens selecionadas
    SELECT * FROM afpo
      INTO TABLE t_afpo
      FOR ALL ENTRIES IN t_aufk
      WHERE aufnr EQ t_aufk-aufnr.

  ENDIF.

  IF t_afpo[] IS NOT INITIAL.

    "Números de objeto dos PEPs
    SELECT * FROM prps
      INTO TABLE t_prps
      FOR ALL ENTRIES IN t_afpo
      WHERE pspnr EQ t_afpo-projn
        AND posid IN s_posid[]. " LAR-29.07.2022-ECDK9A3COI-SM001-Inclusão de filtro.

    IF NOT p_ativo IS INITIAL.
      "Projetos ativos
      SELECT * FROM jest
        INTO TABLE t_jest
        FOR ALL ENTRIES IN t_prps
        WHERE objnr EQ t_prps-objnr
*        AND stat NE c_i0046
        AND inact EQ space.

      LOOP AT t_jest ASSIGNING FIELD-SYMBOL(<fs_jest>).

        IF <fs_jest>-stat EQ c_i0046.
          DELETE t_jest WHERE objnr EQ <fs_jest>-objnr.
        ENDIF.

      ENDLOOP.

    ENDIF.

    IF NOT p_encer IS INITIAL.
      "Projetos encerrados
      SELECT * FROM jest
        INTO TABLE t_jest
        FOR ALL ENTRIES IN t_prps
        WHERE objnr EQ t_prps-objnr
        AND stat EQ c_i0046
        AND inact EQ space.
    ENDIF.

*   " LAR-29.07.2022-ECDK9A3COI-SM001-Realiza o ajuste das tabelas selecionadas anteriormente.
    IF s_posid[] IS NOT INITIAL.
      PERFORM ajustar_tb_filtro_prps.
    ENDIF.

  ENDIF.

  IF t_prps[] IS NOT INITIAL.

    "Compromisso
    SELECT * FROM cooi
      INTO TABLE t_cooi
      FOR ALL ENTRIES IN t_prps
      WHERE objnr EQ t_prps-objnr
        AND wrttp IN (c_21,c_22)
        AND perio IN s_perbl[]  " LAR-29.07.2022-ECDK9A3COI-SM001-Inclusão de filtro.
        AND gjahr IN s_gjahr[]. " LAR-29.07.2022-ECDK9A3COI-SM001-Inclusão de filtro.

*   " LAR-29.07.2022-ECDK9A3COI-SM001-Realiza o ajuste das tabelas selecionadas anteriormente.
    IF s_perbl[] IS NOT INITIAL OR s_gjahr[] IS NOT INITIAL.
      PERFORM ajustar_tb_filtro_cooi.
      PERFORM ajustar_tb_filtro_prps.
    ENDIF.

    IF s_posid[] IS NOT INITIAL. "SM2

      SELECT *
      FROM coep
      INTO TABLE t_coep
      WHERE kokrs = 'R100'
      AND perio IN s_perbl
      AND gjahr IN s_gjahr
      AND objnr IN s_posid
      AND wrttp EQ '4'
      AND versn = 0.

      SORT t_coep BY matnr ASCENDING.

    ELSE.

      SELECT *
     FROM coep
     INTO TABLE t_coep
     FOR ALL ENTRIES IN t_prps
     WHERE objnr EQ t_prps-objnr
     AND wrttp EQ '4'
     AND versn = 0.

      SORT t_coep BY matnr ASCENDING.
    ENDIF.

  ENDIF.

  IF t_aufk[] IS NOT INITIAL.

    "Custo atividade, Horas e Valor
    SELECT * FROM coss
      INTO TABLE t_coss
      FOR ALL ENTRIES IN t_aufk
      WHERE objnr EQ t_aufk-objnr
        AND wrttp EQ c_04.

  ENDIF.

  IF t_afpo[] IS NOT INITIAL.


    IF s_posid[] IS INITIAL.

      "Matéria prima
      SELECT * FROM qbew
        INTO TABLE t_qbew
        FOR ALL ENTRIES IN t_afpo
        WHERE pspnr EQ t_afpo-projn.

      SORT t_qbew BY matnr ASCENDING.

    ELSE.
      "Matéria prima por periodo "SM2
      SELECT * FROM qbewh
        INTO TABLE t_qbewh_dt
        FOR ALL ENTRIES IN t_afpo
        WHERE pspnr EQ t_afpo-projn
         AND lfmon  IN s_perbl[]
         AND lfgja  IN s_gjahr[]
         AND lbkum > 0.

      SORT t_qbewh BY matnr ASCENDING.
    ENDIF.

  ENDIF.

  LOOP AT t_coep INTO w_coep. "SM2
    READ TABLE t_qbewh_dt INTO w_qbewh_dt WITH KEY  matnr = w_coep-matnr
                                                    BINARY SEARCH.
    IF sy-subrc = 0.
      IF w_coep-vrgng = 'RKL' OR w_coep-vrgng = 'KOAO'.
        DELETE TABLE t_coep FROM w_coep.
      ENDIF.
    ENDIF.

  ENDLOOP.

  IF t_qbewh_dt[] IS NOT INITIAL. "SM2

    LOOP AT t_qbewh_dt INTO w_qbewh_dt.
      CLEAR w_qbewh.
      w_qbewh-matnr  = w_qbewh_dt-matnr.
      w_qbewh-bwkey  = w_qbewh_dt-bwkey.
      w_qbewh-estoque = w_qbewh_dt-salk3.

      APPEND w_qbewh TO t_qbewh.
    ENDLOOP.

    SELECT beskz
      FROM marc
      INTO CORRESPONDING FIELDS OF TABLE t_qbewh
      FOR ALL ENTRIES IN t_qbewh
      WHERE matnr = t_qbewh-matnr.

  ENDIF.



  IF t_prps[] IS NOT INITIAL.

    "Orçado Planejado
    SELECT * FROM bpge
     INTO TABLE t_bpge_or
     FOR ALL ENTRIES IN t_prps
     WHERE objnr EQ t_prps-objnr
       AND wrttp EQ c_41
       AND lednr EQ c_0003.

    SELECT * FROM bpge
      INTO TABLE t_bpge_pl
      FOR ALL ENTRIES IN t_prps
      WHERE objnr EQ t_prps-objnr
        AND wrttp EQ c_1
        AND lednr EQ c_0003.

  ENDIF.

  IF NOT p_saldo IS INITIAL.
    SELECT * FROM cskt
      INTO TABLE t_cskt
      FOR ALL ENTRIES IN t_coss
      WHERE kostl EQ t_coss-uspob+6(10).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SUMARIZA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sumariza.

  SORT t_coss BY objnr ASCENDING.

  IF p_saldo IS INITIAL.

    "Custo Atividade
    LOOP AT t_coss INTO w_coss.

*      IF w_coss_tot-objnr IS INITIAL.
      w_coss_tot-objnr = w_coss-objnr.
*      ENDIF.

*      IF w_coss_tot-objnr NE w_coss-objnr.
*        APPEND w_coss_tot TO t_coss_tot.
      CLEAR: w_coss_tot-horas,
             w_coss_tot-valor.
*        w_coss_tot-objnr = w_coss-objnr.
*      ENDIF.

      IF w_coss-objnr EQ w_coss_tot-objnr.

        "Soma total de horas
        w_coss_tot-horas = w_coss_tot-horas +
                           w_coss-meg001 +
                           w_coss-meg002 +
                           w_coss-meg003 +
                           w_coss-meg004 +
                           w_coss-meg005 +
                           w_coss-meg006 +
                           w_coss-meg007 +
                           w_coss-meg008 +
                           w_coss-meg009 +
                           w_coss-meg010 +
                           w_coss-meg011 +
                           w_coss-meg012 +
                           w_coss-meg013 +
                           w_coss-meg014 +
                           w_coss-meg015 +
                           w_coss-meg016.

        "Soma total do Valor
        w_coss_tot-valor = w_coss_tot-valor +
                           w_coss-wog001 +
                           w_coss-wog002 +
                           w_coss-wog003 +
                           w_coss-wog004 +
                           w_coss-wog005 +
                           w_coss-wog006 +
                           w_coss-wog007 +
                           w_coss-wog008 +
                           w_coss-wog009 +
                           w_coss-wog010 +
                           w_coss-wog011 +
                           w_coss-wog012 +
                           w_coss-wog013 +
                           w_coss-wog014 +
                           w_coss-wog015 +
                           w_coss-wog016.

      ENDIF.

      COLLECT w_coss_tot INTO t_coss_tot.

    ENDLOOP.

    IF t_qbew[] IS NOT INITIAL.
      SORT t_qbew BY pspnr ASCENDING.

      " Matéria prima
      LOOP AT t_qbew INTO w_qbew.
*      AT NEW pspnr.
*        w_qbew_tot-pspnr = w_qbew-pspnr.
*      ENDAT.

        IF w_qbew_tot-pspnr IS INITIAL.
          w_qbew_tot-pspnr = w_qbew-pspnr.
        ENDIF.

        IF w_qbew_tot-pspnr NE w_qbew-pspnr.
          APPEND w_qbew_tot TO t_qbew_tot.
          CLEAR w_qbew_tot-estoque.
          w_qbew_tot-pspnr = w_qbew-pspnr.
        ENDIF.

        IF w_qbew_tot-pspnr EQ w_qbew-pspnr.
          w_qbew_tot-estoque = w_qbew_tot-estoque + w_qbew-salk3.
        ENDIF.
*
*      AT END OF pspnr.
*        APPEND w_qbew_tot TO t_qbew_tot.
*        CLEAR w_qbew_tot-estoque.
*      ENDAT.
      ENDLOOP.
    ENDIF.

    IF t_qbewh[] IS NOT INITIAL.

      SORT t_qbewh_dt BY pspnr ASCENDING.

      CLEAR w_qbewh.
      LOOP AT t_qbewh_dt INTO w_qbewh_dt.
        IF w_qbewh_tot-pspnr IS INITIAL.
          w_qbewh_tot-pspnr = w_qbewh_dt-pspnr.
        ENDIF.

        IF w_qbewh_tot-pspnr NE w_qbewh_dt-pspnr.
          APPEND w_qbewh_tot TO t_qbewh_tot.
          CLEAR w_qbewh_tot-estoque.
          w_qbewh_tot-pspnr = w_qbewh_dt-pspnr.
        ENDIF.

        IF w_qbewh_tot-pspnr EQ w_qbewh_dt-pspnr.
          w_qbewh_tot-estoque = w_qbewh_tot-estoque + w_qbewh_dt-salk3.
        ENDIF.
      ENDLOOP.

    ENDIF.

    "MP consumido

    LOOP AT t_coep INTO w_coep.

*      IF w_cosp_tot-objnr IS INITIAL.
      w_coep_tot-objnr = w_coep-objnr.
*      ENDIF.

*      IF w_cosp_tot-objnr NE w_cosp-objnr.
*        APPEND w_cosp_tot TO t_cosp_tot.
      CLEAR w_coep_tot-estoque2.
*        w_cosp_tot-objnr = w_cosp-objnr.
*      ENDIF.

      IF w_coep-objnr EQ w_coep_tot-objnr.

        w_coep_tot-estoque2 = w_coep_tot-estoque2 +
                                 w_coep-wogbtr.


      ENDIF.


      COLLECT w_cooi_tot INTO t_cooi_tot.

    ENDLOOP.


    SORT t_cooi BY objnr ASCENDING.

    " Compromisso
    LOOP AT t_cooi INTO w_cooi.

*      IF w_cosp_tot-objnr IS INITIAL.
      w_cooi_tot-objnr = w_cooi-objnr.
*      ENDIF.

*      IF w_cosp_tot-objnr NE w_cosp-objnr.
*        APPEND w_cosp_tot TO t_cosp_tot.
      CLEAR w_cooi_tot-compromisso.
*        w_cosp_tot-objnr = w_cosp-objnr.
*      ENDIF.

      IF w_cooi-objnr EQ w_cooi_tot-objnr.

        w_cooi_tot-compromisso = w_cooi_tot-compromisso +
                                 w_cooi-wogbtr.


      ENDIF.


      COLLECT w_cooi_tot INTO t_cooi_tot.

    ENDLOOP.

  ELSEIF NOT p_saldo IS INITIAL.

    LOOP AT t_coss INTO w_coss.

      READ TABLE t_aufk INTO w_aufk WITH KEY objnr = w_coss-objnr.

      IF NOT w_aufk IS INITIAL.
        READ TABLE t_afpo INTO w_afpo WITH KEY aufnr = w_aufk-aufnr.
        w_cc-pep = w_afpo-projn.
      ENDIF.

*      IF w_cc-uspob IS INITIAL.
      w_cc-uspob = w_coss-uspob+6(10).
*      ENDIF.

*      IF w_cc-uspob NE w_coss-uspob.
*      APPEND w_cc TO t_cc.
      CLEAR: w_cc-horas,
             w_cc-valor.
*      w_cc-uspob = w_coss-uspob.
*    ENDIF.

      IF w_cc-uspob EQ w_coss-uspob+6(10).

        "Soma total de horas
        w_cc-horas =  w_cc-horas +
                      w_coss-meg001 +
                      w_coss-meg002 +
                      w_coss-meg003 +
                      w_coss-meg004 +
                      w_coss-meg005 +
                      w_coss-meg006 +
                      w_coss-meg007 +
                      w_coss-meg008 +
                      w_coss-meg009 +
                      w_coss-meg010 +
                      w_coss-meg011 +
                      w_coss-meg012 +
                      w_coss-meg013 +
                      w_coss-meg014 +
                      w_coss-meg015 +
                      w_coss-meg016.

        "Soma total do Valor
        w_cc-valor =  w_cc-valor +
                      w_coss-wog001 +
                      w_coss-wog002 +
                      w_coss-wog003 +
                      w_coss-wog004 +
                      w_coss-wog005 +
                      w_coss-wog006 +
                      w_coss-wog007 +
                      w_coss-wog008 +
                      w_coss-wog009 +
                      w_coss-wog010 +
                      w_coss-wog011 +
                      w_coss-wog012 +
                      w_coss-wog013 +
                      w_coss-wog014 +
                      w_coss-wog015 +
                      w_coss-wog016.

        READ TABLE t_cskt INTO DATA(w_cskt) WITH KEY kostl = w_coss-uspob+6(10).
        IF sy-subrc IS INITIAL.
          w_cc-ltext = w_cskt-ltext.
        ENDIF.

      ENDIF.

      COLLECT w_cc INTO t_cc.

    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MONTA_SAIDA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM monta_saida.

  DATA lv_pspnr TYPE char20.

  IF p_saldo IS INITIAL.

    LOOP AT t_aufk INTO w_aufk.

      CLEAR: w_alv, w_jest, w_afpo, w_prps, w_coss_tot, w_cooi_tot, w_bpge_or, w_bpge_pl, w_qbew_tot, w_prps_projeto.
*
*      IF NOT p_ativo IS INITIAL.
*
*        READ TABLE t_jest INTO w_jest WITH KEY objnr = w_aufk-objnr.
*
*        IF w_jest IS INITIAL.
*          CONTINUE.
*        ENDIF.
*
*      ELSEIF NOT p_encer IS INITIAL.

      READ TABLE t_afpo INTO DATA(wl_afpo) WITH KEY aufnr = w_aufk-aufnr.
      READ TABLE t_prps INTO DATA(wl_prps) WITH KEY pspnr = wl_afpo-projn.
      READ TABLE t_jest INTO w_jest WITH KEY objnr = wl_prps-objnr.

      IF w_jest IS INITIAL.
        CONTINUE.
      ENDIF.

*      ENDIF.

      READ TABLE t_afpo INTO w_afpo WITH KEY aufnr = w_aufk-aufnr.

      IF NOT w_afpo IS INITIAL.
        w_alv-pep = w_afpo-projn.
        w_alv-material = w_afpo-matnr.

        READ TABLE t_prps INTO w_prps WITH KEY pspnr = w_afpo-projn.

        IF NOT w_prps IS INITIAL.

*        IF w_prps_projeto IS INITIAL.
          SELECT SINGLE *
            INTO w_prps_projeto
            FROM prps
            WHERE psphi EQ w_prps-psphi.
*        ENDIF.

          IF NOT w_prps_projeto IS INITIAL.
            w_alv-projeto = w_prps_projeto-post1.
          ENDIF.


          READ TABLE t_cooi_tot INTO w_cooi_tot WITH KEY objnr = w_prps-objnr.
          IF NOT w_cooi_tot IS INITIAL.
            w_alv-compromisso = w_cooi_tot-compromisso.
          ENDIF.

          READ TABLE t_bpge_or INTO w_bpge_or WITH KEY objnr = w_prps-objnr.

          w_alv-orcado = w_bpge_or-wlges.

          READ TABLE t_bpge_pl INTO w_bpge_pl WITH KEY objnr = w_prps-objnr.

          w_alv-planejado = w_bpge_pl-wlges.

        ENDIF.

        IF t_qbew_tot[] IS NOT INITIAL.
          READ TABLE t_qbew_tot INTO w_qbew_tot WITH KEY pspnr = w_afpo-projn.

          w_alv-estoque = w_qbew_tot-estoque.

        ELSE.
          READ TABLE t_qbewh_tot INTO w_qbewh_tot WITH KEY pspnr = w_afpo-projn.

          w_alv-estoque = w_qbewh_tot-estoque.
        ENDIF.

      ENDIF.

      READ TABLE t_coep_tot INTO w_coep_tot WITH KEY objnr = w_afpo-projn.
        w_alv-estoque2 = w_coep_tot-estoque2.

      READ TABLE t_coss_tot INTO w_coss_tot WITH KEY objnr = w_aufk-objnr.

      IF NOT w_coss_tot IS INITIAL.
        w_alv-horas = w_coss_tot-horas.
        w_alv-valor = w_coss_tot-valor.
      ENDIF.

      w_alv-disposto = w_alv-valor + w_alv-estoque + w_alv-estoque2 + w_alv-compromisso.

      w_alv-saldo_orcamento = w_alv-orcado - w_alv-disposto.

      w_alv-saldo_planejado = w_alv-planejado - w_alv-disposto.

      APPEND w_alv TO t_alv.


    ENDLOOP.

    DELETE t_alv WHERE pep IS INITIAL.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  EXIBE_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM exibe_alv.

  DATA: go_alv        TYPE REF TO cl_salv_table,
        lr_columns    TYPE REF TO cl_salv_columns_table,
        lr_column     TYPE REF TO cl_salv_column_table,
        lo_functions  TYPE REF TO cl_salv_functions_list,
        gr_display    TYPE REF TO cl_salv_display_settings,
        gr_selections TYPE REF TO cl_salv_selections.

  IF p_saldo IS INITIAL.

    TRY.

        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = go_alv
          CHANGING
            t_table      = t_alv ). "Internal Table

      CATCH cx_salv_msg.

    ENDTRY.

  ELSEIF NOT p_saldo IS INITIAL.

    DELETE t_cc WHERE uspob IS INITIAL.

    TRY.

        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = go_alv
          CHANGING
            t_table      = t_cc ). "Internal Table

      CATCH cx_salv_msg.

    ENDTRY.

  ENDIF.

***Optimize Column
  lr_columns = go_alv->get_columns( ).
  lr_columns->set_optimize( 'X' ).

***Enable Zebra style
  gr_display = go_alv->get_display_settings( ).
  gr_display->set_striped_pattern( cl_salv_display_settings=>true ).

* " LAR-29.07.2022-ECDK9A3COI-SM001-Inseri o padrão de toolbar do alv e a seleção de layout.
* " Funções padrão do cl_salv_table.
  DATA(lo_function) = go_alv->get_functions( ).
  lo_function->set_all( abap_true ).

* " Configurações de layout.
  DATA(ls_layout_key) = VALUE salv_s_layout_key(
    report = sy-repid
    handle = 'TOP'
  ).

  DATA(lo_layout) = go_alv->get_layout( ).
  lo_layout->set_key( value = ls_layout_key ).
  lo_layout->set_save_restriction( if_salv_c_layout=>restrict_user_dependant ).

**hotspot SM2
  TRY.
      lr_column ?= lr_columns->get_column( 'ESTOQUE' ).
    CATCH cx_salv_not_found.

  ENDTRY.
  lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).

  TRY.
      lr_column ?= lr_columns->get_column( 'ESTOQUE2' ).
    CATCH cx_salv_not_found.

  ENDTRY.
  lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).

  TRY.
      lr_column ?= lr_columns->get_column( 'COMPROMISSO' ).
    CATCH cx_salv_not_found.

  ENDTRY.
  lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).

* Handler event
  DATA: lo_events TYPE REF TO cl_salv_events_table.
  DATA: gr_event_handler TYPE REF TO lcl_events.

*   all events
  lo_events = go_alv->get_event( ).

  CREATE OBJECT gr_event_handler.
  SET HANDLER gr_event_handler->on_link_click   FOR lo_events.

* " LAR-29.07.2022-ECDK9A3COI-SM001- Por algum motivo, foi inserido para selecionar os botões inutilizados do alv standard.-REMOVIDO
****Enable function buttons
*  go_alv->set_screen_status(
*    pfstatus      =  'SALV_STANDARD'
*    report        =  'SALV_DEMO_TABLE_SELECTIONS'
*    set_functions = go_alv->c_functions_all ).

***Display ALV
  go_alv->display( ).

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  AJUSTAR_TB_FILTRO_PRPS
*&---------------------------------------------------------------------*
FORM ajustar_tb_filtro_prps .
  DATA:
    lr_projn TYPE RANGE OF afpo-projn,
    lr_aufnr TYPE RANGE OF aufk-aufnr.

* " Verifica se encontrou algum PEP na PRPS, de acordo com o filtro do PEP informado em tela.
* " Caso nao encontre, cancela toda a seleção.
  IF t_prps IS INITIAL.
    FREE: t_afpo, t_aufk.

    RETURN.
  ENDIF.

  lr_projn = VALUE #( FOR lw_prps IN t_prps ( sign = 'I' option = 'EQ' low = lw_prps-pspnr ) ).
  DELETE t_afpo WHERE projn NOT IN lr_projn.

  lr_aufnr = VALUE #( FOR lw_afpo IN t_afpo ( sign = 'I' option = 'EQ' low = lw_afpo-aufnr )   ).
  DELETE t_aufk WHERE aufnr NOT IN lr_aufnr.

ENDFORM. " AJUSTAR_TB_FILTRO_PRPS

*&---------------------------------------------------------------------*
*&      Form  AJUSTAR_TB_FILTRO_COSP
*&---------------------------------------------------------------------*
FORM ajustar_tb_filtro_cooi .
  DATA:
    lr_objnr TYPE RANGE OF prps-objnr.

  IF t_cooi IS INITIAL.
    FREE t_prps.
    RETURN.
  ENDIF.

  lr_objnr = VALUE #( FOR lw_cooi IN t_cooi ( sign = 'I' option = 'EQ' low = lw_cooi-objnr ) ).
  DELETE t_prps WHERE objnr NOT IN lr_objnr.

ENDFORM. " AJUSTAR_TB_FILTRO_COSP
*&---------------------------------------------------------------------*
*&      Form  Z_DETALHES_ITENS
*&---------------------------------------------------------------------*
FORM z_detalhes_itens .




  DATA: go_alv        TYPE REF TO cl_salv_table,
        lr_columns    TYPE REF TO cl_salv_columns_table,
        lr_column     TYPE REF TO cl_salv_column_table,
        lo_functions  TYPE REF TO cl_salv_functions_list,
        gr_display    TYPE REF TO cl_salv_display_settings,
        gr_selections TYPE REF TO cl_salv_selections,
        t_qbew_aux    TYPE TABLE OF qbew,
        t_qbewh_aux   TYPE TABLE OF qbewh,
        t_cooi_aux    TYPE TABLE OF cooi,
        t_coep_aux    TYPE TABLE OF coep.


  CASE lv_column.
    WHEN 'ESTOQUE'.

      IF t_qbew[] IS NOT INITIAL.
        READ TABLE t_qbew INTO w_qbew WITH KEY  pspnr = lv_pspnr
                                       matnr = lv_matnr.
        IF sy-subrc = 0.
          APPEND w_qbew TO t_qbew_aux.
        ENDIF.

        TRY.
            cl_salv_table=>factory(
                     IMPORTING
                       r_salv_table = go_alv
                     CHANGING
                       t_table      = t_qbew_aux ). "Internal Table

          CATCH cx_salv_msg.

        ENDTRY.
      ELSE.

        READ TABLE t_qbewh_dt INTO w_qbewh_dt WITH KEY  pspnr = lv_pspnr
                                                   matnr = lv_matnr.
        IF sy-subrc = 0.
          APPEND w_qbewh_dt TO t_qbewh_aux.
        ENDIF.
        TRY.
            cl_salv_table=>factory(
                     IMPORTING
                       r_salv_table = go_alv
                     CHANGING
                       t_table      = t_qbewh_aux ). "Internal Table

          CATCH cx_salv_msg.
        ENDTRY.
      ENDIF.

    WHEN 'ESTOQUE2'.

      LOOP AT t_coep ASSIGNING FIELD-SYMBOL(<f_coep>).
            REPLACE ALL OCCURRENCES OF
             REGEX '[A-Z]' IN <f_coep>-objnr
              WITH ''.
          ENDLOOP.

          READ TABLE t_coep INTO w_coep WITH KEY  objnr = lv_pspnr.

          IF sy-subrc = 0.
            APPEND w_coep TO t_coep_aux.
          ENDIF.

        TRY.
          cl_salv_table=>factory(
                   IMPORTING
                     r_salv_table = go_alv
                   CHANGING
                     t_table      = t_coep_aux ). "Internal Table

        CATCH cx_salv_msg.

      ENDTRY.

    WHEN 'COMPROMISSO'.
      TRY.
          LOOP AT t_cooi ASSIGNING FIELD-SYMBOL(<f_cooi>).
            REPLACE ALL OCCURRENCES OF
             REGEX '[A-Z]' IN <f_cooi>-objnr
              WITH ''.
          ENDLOOP.

          READ TABLE t_cooi INTO w_cooi WITH KEY  objnr = lv_pspnr.

          IF sy-subrc = 0.
            APPEND w_cooi TO t_cooi_aux.
          ENDIF.
          cl_salv_table=>factory(
                   IMPORTING
                     r_salv_table = go_alv
                   CHANGING
                     t_table      = t_cooi_aux ). "Internal Table

        CATCH cx_salv_msg.

      ENDTRY.

  ENDCASE.

  DATA(lo_function) = go_alv->get_functions( ).
  lo_function->set_all( abap_true ).


  DATA(ls_layout_key) = VALUE salv_s_layout_key(
    report = sy-repid
    handle = 'TOP'
  ).

***Optimize Column
  lr_columns = go_alv->get_columns( ).
  lr_columns->set_optimize( 'X' ).

  DATA(lo_layout) = go_alv->get_layout( ).
  lo_layout->set_key( value = ls_layout_key ).
  lo_layout->set_save_restriction( if_salv_c_layout=>restrict_user_dependant ).

  go_alv->display( ).

ENDFORM.