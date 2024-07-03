*&---------------------------------------------------------------------*
*& Report Z_TESTE_GILSON3
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_teste_gilson3.

TABLES: pa0008.

*&------------------------------------------------------------------*
*& Definição da(s) Estrutura(s)                                     *
*&------------------------------------------------------------------*
TYPES: BEGIN OF ty_0008,
         pernr TYPE pa0008-pernr,
         trfgr TYPE pa0008-trfgr,
         ansal TYPE pa0008-ansal,
         divgv TYPE pa0008-divgv,
         bet01 TYPE pa0008-bet01,
       END OF ty_0008,

       BEGIN OF ty_alv,
         pernr TYPE pa0008-pernr,
         trfgr TYPE pa0008-trfgr,
         ansal TYPE pa0008-ansal,
         divgv TYPE pa0008-divgv,
         bet01 TYPE pa0008-bet01,
         mostd TYPE pa0007-mostd,
         wostd TYPE pa0007-wostd,
         arbst TYPE pa0007-arbst,
         jrstd TYPE pa0007-jrstd,
         bonus TYPE pa0008-bet01,
       END OF ty_alv,

       BEGIN OF ty_0007,
         pernr TYPE pa0008-pernr,
         mostd TYPE pa0007-mostd,
         wostd TYPE pa0007-wostd,
         arbst TYPE pa0007-arbst,
         jrstd TYPE pa0007-jrstd,
       END OF ty_0007,

       BEGIN OF ty_0009,
         pernr TYPE pa0008-pernr,
         begda TYPE pa0009-begda,
         banks TYPE pa0009-banks,
         bankl TYPE pa0009-bankl,
         bankn TYPE pa0009-bankn,
       END OF ty_0009.



*&------------------------------------------------------------------*
*& Definição da(s) Variáveis                                        *
*&------------------------------------------------------------------*
DATA: lv_pernr  TYPE pa0008-pernr,
      lv_column TYPE string.     "SM2
*&------------------------------------------------------------------*
*& Definição da(s) Contante(s)                                      *
*&------------------------------------------------------------------*
*CONSTANTS:


*&------------------------------------------------------------------*
*& Definição da(s) Work-Areas                                       *
*&------------------------------------------------------------------*
DATA: w_0008 TYPE ty_0008,
      w_0007 TYPE ty_0007,
      w_0009 TYPE ty_0009,
      w_alv  TYPE ty_alv.



*&------------------------------------------------------------------*
*& Definição da(s) Tabela(s) Interna(s)                             *
*&------------------------------------------------------------------*
DATA: t_0008 TYPE TABLE OF ty_0008,
      t_0007 TYPE TABLE OF ty_0007,
      t_0009 TYPE TABLE OF ty_0009,
      t_alv  TYPE TABLE OF ty_alv,
      go_alv TYPE REF TO cl_salv_table.
*&------------------------------------------------------------------*
*& Definição da Tela de Seleção                                     *
*&------------------------------------------------------------------*

SELECTION-SCREEN: BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-t01. " LAR-29.07.2022-ECDK9A3COI-SM001-Inclisão dos filtros.

SELECT-OPTIONS:
  s_pernr FOR pa0008-pernr NO INTERVALS.
SELECTION-SCREEN: END OF BLOCK b2.

START-OF-SELECTION.

  PERFORM selecoes.

  PERFORM monta_saida.

  IF t_alv[] IS INITIAL.
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
    CLEAR lv_pernr.
    READ TABLE t_alv INTO w_alv
    INDEX row.
    lv_pernr = w_alv-pernr.
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

  IF s_pernr[] IS NOT INITIAL.
    SELECT pernr
         trfgr
         ansal
         divgv
         bet01
    FROM pa0008
    INTO TABLE t_0008
    WHERE pernr IN s_pernr.

  ELSE.

    SELECT pernr
        trfgr
        ansal
        divgv
        bet01
   FROM pa0008
   INTO TABLE t_0008
   UP TO 10 ROWS.

  ENDIF.

  IF t_0008[] IS NOT INITIAL.

    SELECT pernr
           mostd
           wostd
           arbst
           jrstd
      FROM pa0007
      INTO TABLE t_0007
      FOR ALL ENTRIES IN t_0008
      WHERE pernr = t_0008-pernr.

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

  LOOP AT t_0008 INTO w_0008.

    w_alv-pernr = w_0008-pernr.
    w_alv-trfgr = w_0008-trfgr.
    w_alv-ansal = w_0008-ansal.
    w_alv-divgv = w_0008-divgv.
    w_alv-bet01 = w_0008-bet01.

    READ TABLE t_0007 INTO w_0007 WITH KEY pernr = w_0008-pernr.
    IF sy-subrc = 0.

      w_alv-mostd = w_0007-mostd.
      w_alv-wostd = w_0007-wostd.
      w_alv-arbst = w_0007-arbst.
      w_alv-jrstd = w_0007-jrstd.

    ENDIF.

    APPEND w_alv TO t_alv.
  ENDLOOP.

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


  DATA:
    lr_columns    TYPE REF TO cl_salv_columns_table,
    lr_column     TYPE REF TO cl_salv_column_table,
    lo_functions  TYPE REF TO cl_salv_functions_list,
    gr_display    TYPE REF TO cl_salv_display_settings,
    gr_selections TYPE REF TO cl_salv_selections.

  IF go_alv IS NOT INITIAL.

    go_alv->refresh( ).

  ENDIF.

  TRY.

      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = go_alv
        CHANGING
          t_table      = t_alv ). "Internal Table

    CATCH cx_salv_msg.

  ENDTRY.


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
      lr_column ?= lr_columns->get_column( 'PERNR' ).
    CATCH cx_salv_not_found.

  ENDTRY.
  lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).

**hotspot SM2
  TRY.
      lr_column ?= lr_columns->get_column( 'TRFGR' ).
    CATCH cx_salv_not_found.

  ENDTRY.
  lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).

**hotspot SM2
  TRY.
      lr_column ?= lr_columns->get_column( 'BONUS' ).
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
*&      Form  Z_DETALHES_ITENS
*&---------------------------------------------------------------------*
FORM z_detalhes_itens .




  DATA: go_alv2       TYPE REF TO cl_salv_table,
        lr_columns    TYPE REF TO cl_salv_columns_table,
        lr_column     TYPE REF TO cl_salv_column_table,
        lo_functions  TYPE REF TO cl_salv_functions_list,
        gr_display    TYPE REF TO cl_salv_display_settings,
        gr_selections TYPE REF TO cl_salv_selections,
        l_modif       TYPE pa0008-trfgr,
        l_bonus       TYPE pa0008-ANZ04,
        ivals         TYPE TABLE OF sval,
        xvals         TYPE sval.

  CASE lv_column.
    WHEN 'PERNR'.

      SELECT pernr
             begda
             banks
             bankl
             bankn
        FROM pa0009
        INTO TABLE t_0009
        WHERE pernr = lv_pernr.


      TRY.
          cl_salv_table=>factory(
                   IMPORTING
                     r_salv_table = go_alv2
                   CHANGING
                     t_table      = t_0009 ). "Internal Table

        CATCH cx_salv_msg.

      ENDTRY.

      DATA(lo_function) = go_alv2->get_functions( ).
      lo_function->set_all( abap_true ).


      DATA(ls_layout_key) = VALUE salv_s_layout_key(
        report = sy-repid
        handle = 'TOP'
      ).

**Optimize Column
      lr_columns = go_alv2->get_columns( ).
      lr_columns->set_optimize( 'X' ).

      DATA(lo_layout) = go_alv2->get_layout( ).
      lo_layout->set_key( value = ls_layout_key ).
      lo_layout->set_save_restriction( if_salv_c_layout=>restrict_user_dependant ).

      go_alv2->display( ).

    WHEN 'TRFGR'.

      xvals-tabname   = 'PA0008'.
      xvals-fieldname = 'TRFGR'.
      APPEND xvals TO ivals.

      CALL FUNCTION 'POPUP_GET_VALUES'
        EXPORTING
          popup_title     = 'Novo GS'
        TABLES
          fields          = ivals
        EXCEPTIONS
          error_in_fields = 1
          OTHERS          = 2.

      READ TABLE ivals INTO xvals WITH KEY fieldname = 'TRFGR'.

      l_modif = xvals-value.

      READ TABLE t_alv ASSIGNING FIELD-SYMBOL(<f_alv>) WITH  KEY pernr = lv_pernr.

      IF sy-subrc = 0.
        <f_alv>-trfgr = l_modif.

        go_alv->display( ).
        go_alv->refresh( ).
      ENDIF.

    WHEN 'BONUS'.

      xvals-tabname   = 'PA0008'.
      xvals-fieldname = 'ANZ04'.
      APPEND xvals TO ivals.

      CALL FUNCTION 'POPUP_GET_VALUES'
        EXPORTING
          popup_title     = 'Valor do bonus'
        TABLES
          fields          = ivals
        EXCEPTIONS
          error_in_fields = 1
          OTHERS          = 2.

      READ TABLE ivals INTO xvals WITH KEY fieldname = 'ANZ04'.

      l_bonus = xvals-value.

      READ TABLE t_alv ASSIGNING <f_alv> WITH  KEY pernr = lv_pernr.

      IF sy-subrc = 0.
        <f_alv>-bonus = l_bonus.

        go_alv->display( ).
        go_alv->refresh( ).
      ENDIF.

  ENDCASE.