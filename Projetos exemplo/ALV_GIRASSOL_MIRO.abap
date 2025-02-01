REPORT zmm_rmiro_sr.

*----------------------------------------------------------------------*
* Tabelas                                                              *
*----------------------------------------------------------------------*
TABLES: ekko.

*----------------------------------------------------------------------*
* Types Globais                                                        *
*----------------------------------------------------------------------*
TYPES: BEGIN OF y_alv,
         ebeln       TYPE ekko-ebeln,
         bukrs       TYPE ekko-bukrs,
         lifnr       TYPE ekko-lifnr,
         zbd1t       TYPE ekko-zbd1t,
         matnr       TYPE ekpo-matnr,
         netpr       TYPE ekpo-netpr,
         werks       TYPE ekpo-werks,
         kostl       TYPE ekkn-kostl,
         netwr       TYPE ekkn-netwr,
         mwskz       TYPE ekpo-mwskz,
         frgke       TYPE ekko-frgke,
         name1       TYPE lfa1-name1,
         bldat       TYPE rbkp-bldat,
         icon_status TYPE ze_status_icon_miro,
       END OF y_alv,

       BEGIN OF y_alv_display, " Type para visualização dos campos do alv
         ebeln       TYPE ekko-ebeln,
         icon_status TYPE ze_status_icon_miro,
         bukrs       TYPE ekko-bukrs,
         lifnr       TYPE ekko-lifnr,
         name1       TYPE lfa1-name1,
         bldat       TYPE rbkp-bldat,
         zbd1t       TYPE ekko-zbd1t,
         matnr       TYPE ekpo-matnr,
         netpr       TYPE ekpo-netpr,
         werks       TYPE ekpo-werks,
         kostl       TYPE ekkn-kostl,
         netwr       TYPE ekkn-netwr,
         mwskz       TYPE ekpo-mwskz,
         frgke       TYPE ekko-frgke,
       END OF y_alv_display,

       BEGIN OF y_dados_bapi_miro,
         ebeln TYPE ekko-ebeln,
         ebelp TYPE ekpo-ebelp,
         bukrs TYPE ekko-bukrs,
         lifnr TYPE ekko-lifnr,
         zbd1t TYPE ekko-zbd1t,
         frgke TYPE ekko-frgke,
         matnr TYPE ekpo-matnr,
         netpr TYPE ekpo-netpr,
         menge TYPE ekpo-menge,
         waers TYPE ekko-waers,
         kostl TYPE ekkn-kostl,
         netwr TYPE ekkn-netwr,
         mwskz TYPE ekpo-mwskz,
       END OF y_dados_bapi_miro.

*----------------------------------------------------------------------*
* Classes e Objetos Globais                                            *
*----------------------------------------------------------------------*
DATA: v_o_table      TYPE REF TO cl_salv_table,
      v_o_columns    TYPE REF TO cl_salv_columns_table,
      v_o_column     TYPE REF TO cl_salv_column_table,
      v_o_selections TYPE REF TO cl_salv_selections,
      v_o_header     TYPE REF TO cl_salv_form_layout_grid,
      v_o_functions  TYPE REF TO cl_salv_functions,
      v_o_display    TYPE REF TO cl_salv_display_settings,
      v_o_grid       TYPE REF TO cl_salv_form_layout_grid,
      v_o_label      TYPE REF TO cl_salv_form_label,
      v_events       TYPE REF TO cl_salv_events_table,
      t_rows         TYPE salv_t_row.

*----------------------------------------------------------------------*
* Tabelas Internas Globais                                             *
*----------------------------------------------------------------------*
DATA: lt_alv         TYPE TABLE OF y_alv,
      lt_messages    TYPE TABLE OF bapiret2,
      lt_alv_display TYPE TABLE OF y_alv_display.

*----------------------------------------------------------------------*
* Váriaveis Globais                                                    *
*----------------------------------------------------------------------*
DATA: lv_ebeln  TYPE ekko-ebeln,
      lv_bukrs  TYPE ekko-bukrs,
      lv_column TYPE string,
      v_count   TYPE i,
      v_brcod   TYPE brcde.

*----------------------------------------------------------------------*
* Workareas Globais                                                    *
*----------------------------------------------------------------------*
DATA: ls_alv        TYPE y_alv,
      ls_param_bapi TYPE y_dados_bapi_miro,
      ls_message    TYPE bapiret2.

*----------------------------------------------------------------------*
* Constantes Globais                                                   *
*----------------------------------------------------------------------*
CONSTANTS: c_icon_liberado(4)  TYPE c      VALUE '@08@',
           c_icon_undefined(4) TYPE c      VALUE '@09@',
           c_icon_bloqueado(4) TYPE c      VALUE '@0A@',
           c_ernam_senior      TYPE string VALUE 'SENIOR',
           c_text_periodo      TYPE string VALUE 'Período:',
           c_text_relatorio    TYPE string VALUE 'Pedidos de Compras Sênior'.
*----------------------------------------------------------------------*

START-OF-SELECTION.

  PERFORM zf_seleciona_dados.
  PERFORM zf_display_alv.

CLASS lcl_alv_handler DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS: added_function FOR EVENT added_function OF cl_salv_events_table
      IMPORTING e_salv_function.
ENDCLASS.

CLASS lcl_alv_handler IMPLEMENTATION.
  METHOD added_function.
    t_rows = v_o_selections->get_selected_rows( ).
    PERFORM zf_create_miro USING t_rows.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_message_handler DEFINITION.
  PUBLIC SECTION.
    METHODS:
      add_and_display_message
        IMPORTING
          iv_type     TYPE bapi_mtype    " Tipo da mensagem (E, W, I, S)
          iv_message  TYPE string        " Texto da mensagem
        CHANGING
          ct_messages TYPE bapiret2_tab. " Tabela de mensagens para exibição
ENDCLASS.

CLASS lcl_message_handler IMPLEMENTATION.
  METHOD add_and_display_message.

    DATA(icon_msg) = COND #(
          WHEN iv_type = 'E' THEN '@1B@'
          WHEN iv_type = 'W' THEN '@1A@'
          WHEN iv_type = 'S' THEN '@5B@'
          WHEN iv_type = 'I' THEN '@19@' ).

    DATA(lv_formatted_message) = |{ icon_msg } { iv_message }|.

    APPEND VALUE #(
    type    = iv_type
    message = lv_formatted_message
    ) TO ct_messages.

    MESSAGE lv_formatted_message TYPE iv_type DISPLAY LIKE iv_type.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_link_click FOR EVENT link_click  "Hotspot Handler
                  OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.

*&------------------------------------------------------------------*
*& Implementação do evento de click no ALV SM2                      *
*&------------------------------------------------------------------*
CLASS lcl_events IMPLEMENTATION.
  METHOD on_link_click.

    lv_column = column.
    CLEAR lv_ebeln.
    READ TABLE lt_alv_display INTO DATA(w_alv) INDEX row.
    lv_ebeln = w_alv-ebeln.
    PERFORM z_detalhes_itens.

  ENDMETHOD.
ENDCLASS.
*---------------------------------------------------------------------*
*      Form  zf_seleciona_dados
*---------------------------------------------------------------------*
*      Seleção de Dados para ALV
*---------------------------------------------------------------------*
FORM zf_seleciona_dados.

  SELECT ekko~ebeln, ekko~bukrs, ekko~lifnr, ekko~zbd1t,
  ekpo~matnr, ekpo~netpr, ekpo~werks, ekkn~kostl,
  ekkn~netwr, ekpo~mwskz, ekko~frgke, lfa1~name1
  INTO TABLE @lt_alv
  FROM ekko
  INNER JOIN ekpo ON ekko~ebeln = ekpo~ebeln
  INNER JOIN ekkn ON ekpo~ebeln = ekkn~ebeln
   LEFT JOIN lfa1 ON ekko~lifnr = lfa1~lifnr
  WHERE ekko~ernam = @c_ernam_senior.

  LOOP AT lt_alv ASSIGNING FIELD-SYMBOL(<fs_alv>).
    <fs_alv>-icon_status = SWITCH #(
    <fs_alv>-frgke
    WHEN 'B' THEN c_icon_bloqueado
    WHEN 'G' OR 'R' THEN c_icon_liberado
    ELSE c_icon_undefined ).
  ENDLOOP.

  " Loop para ordernar as colunas conforme necessário pelo type y_alv_display
  LOOP AT lt_alv INTO DATA(ls_alv).
    DATA(ls_alv_display) = CORRESPONDING y_alv_display( ls_alv ).
    APPEND ls_alv_display TO lt_alv_display.
  ENDLOOP.
ENDFORM.
*---------------------------------------------------------------------*
*      Form  zf_display_alv
*---------------------------------------------------------------------*
*         Exibe ALV
*---------------------------------------------------------------------*
FORM zf_display_alv.
  DATA: l_dtini(10) TYPE c,
        l_dtfim(10) TYPE c.

  DATA: lo_events        TYPE REF TO cl_salv_events_table,
        gr_event_handler TYPE REF TO lcl_events.

  TRY.
      cl_salv_table=>factory(
      EXPORTING
        list_display = abap_true
      IMPORTING
        r_salv_table = v_o_table
      CHANGING
      t_table      = lt_alv_display ).

      v_o_selections = v_o_table->get_selections( ).
      v_o_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ).

      v_o_columns = v_o_table->get_columns( ).
      v_o_columns->set_optimize( abap_true ).

      DATA(lo_column) = v_o_columns->get_column( 'FRGKE' ).
      lo_column->set_visible( abap_false ).

      TRY .
          v_o_column ?= v_o_columns->get_column( 'BUKRS' ).
        CATCH cx_salv_not_found.
      ENDTRY.
      v_o_column->set_cell_type( if_salv_c_cell_type=>hotspot ).

      v_o_display = v_o_table->get_display_settings( ).
      v_o_display->set_striped_pattern( abap_true ).

      v_o_table->set_screen_status(
      EXPORTING
        report        = sy-repid
        pfstatus      = 'Z_STANDARD'
        set_functions = v_o_table->c_functions_all ).

      v_events = v_o_table->get_event( ).

      CREATE OBJECT gr_event_handler.
      SET HANDLER gr_event_handler->on_link_click FOR v_events.
*    SET HANDLER lcl_alv_handler=>added_function FOR v_events.

      v_o_functions = v_o_table->get_functions( ).
      v_o_functions->set_all( ).

      PERFORM zf_fcat_config.

      CREATE OBJECT v_o_grid.

      CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
        EXPORTING
          input  = sy-datum
        IMPORTING
          output = l_dtini.

      CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
        EXPORTING
          input  = sy-datum
        IMPORTING
          output = l_dtfim.

      " Texto info do alv
      DATA(lv_periodo_text)   = |{ c_text_periodo } { l_dtini } à { l_dtfim }|.
      DATA(lv_relatorio_text) = |{ c_text_relatorio }|.

      v_o_label = v_o_grid->create_label( row = 1 column = 1 text = lv_relatorio_text ).
      v_o_label = v_o_grid->create_label( row = 2 column = 1 text = lv_periodo_text ).

      v_o_table->set_top_of_list( value = v_o_grid ).
      v_o_table->display( ).

    CATCH cx_salv_msg INTO DATA(lx_salv_msg).
      DATA(lv_error_msg) = lx_salv_msg->get_text( ).
      MESSAGE lv_error_msg TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.
ENDFORM.
*---------------------------------------------------------------------*
*      Form  zf_fcat_config
*---------------------------------------------------------------------*
*      Configuração ALV
*---------------------------------------------------------------------*
FORM zf_fcat_config.
  v_o_display = v_o_table->get_display_settings( ).
  v_o_display->set_list_header( 'Relatório Pedidos Sênior x MIRO' ).
ENDFORM.

*---------------------------------------------------------------------*
*      Form  zf_create_miro
*---------------------------------------------------------------------*
*      Criação da MIRO pela BAPI_INCOMINGINVOICE_CREATE
*---------------------------------------------------------------------*
FORM zf_create_miro USING it_rows TYPE salv_t_row.

  DATA: lv_invoice TYPE bapi_incinv_create_header,
        lt_items   TYPE TABLE OF bapi_incinv_create_item,
        lt_return  TYPE TABLE OF bapiret2,
        lv_message TYPE string,
        lv_line    TYPE string.

  DATA(lo_message_handler) = NEW lcl_message_handler( ).

  LOOP AT it_rows INTO DATA(ls_row).
    READ TABLE lt_alv INTO DATA(ls_selected_row) INDEX ls_row.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    " Verifica se o pedido está bloqueado
    IF ls_selected_row-frgke = 'B'.
      lo_message_handler->add_and_display_message(
      EXPORTING
        iv_type    = 'E'
        iv_message = 'Pedido bloqueado, MIRO não pode ser gerada!!!'
      CHANGING
        ct_messages = lt_messages ).

      RETURN.

    ENDIF.

    CLEAR: lv_invoice,
    lt_items,
    ls_param_bapi,
    lt_return,
    ls_message,
    lt_messages.

    DATA(lv_param_ebeln) = ls_selected_row-ebeln.

    SELECT SINGLE
    ekko~ebeln, ekpo~ebelp, ekko~bukrs, ekko~lifnr, ekko~zbd1t,
    ekko~frgke, ekpo~matnr, ekpo~menge, ekpo~netpr, ekko~waers,
    ekkn~kostl, ekkn~netwr, ekpo~mwskz
    INTO @ls_param_bapi
    FROM ekko
    INNER JOIN ekpo ON ekko~ebeln = ekpo~ebeln
    INNER JOIN ekkn ON ekpo~ebeln = ekkn~ebeln
    WHERE ekko~ebeln = @lv_param_ebeln.

    " Dados parametro Headerdata BAPI
    lv_invoice = VALUE #(
    doc_date     = sy-datum
    pstng_date   = sy-datum
    ref_doc_no   = ls_param_bapi-ebeln
    comp_code    = ls_param_bapi-bukrs
    paymt_ref    = ls_param_bapi-zbd1t
    currency     = ls_param_bapi-waers
    currency_iso = ls_param_bapi-waers ).

    " Dados parametro Itemdata BAPI
    IF ls_param_bapi-menge > 0.
      lt_items = VALUE #( BASE lt_items (
      po_number        = ls_param_bapi-ebeln
      invoice_doc_item = ls_param_bapi-ebelp
      po_item          = ls_param_bapi-ebelp
      item_text        = 'MIRO criada automaticamente'
      quantity         = ls_param_bapi-menge
      item_amount      = ls_param_bapi-netwr
      ) ).
    ELSE.
      lo_message_handler->add_and_display_message(
      EXPORTING
        iv_type    = 'E'
        iv_message = 'Quantidade inválida para o item do pedido'
      CHANGING
        ct_messages = lt_messages ).

    ENDIF.

    CALL FUNCTION 'BAPI_INCOMINGINVOICE_CREATE'
      EXPORTING
        headerdata = lv_invoice
      TABLES
        itemdata   = lt_items
        return     = lt_return.

    LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<fs_return>) WHERE type = 'E'.
      APPEND VALUE #(
      type    = <fs_return>-type
      id      = <fs_return>-id
      number  = <fs_return>-number
      message = <fs_return>-message
      ) TO lt_messages.

    ENDLOOP.

    IF lt_messages IS INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.

      IF sy-subrc <> 0.
        lo_message_handler->add_and_display_message(
        EXPORTING
          iv_type    = 'E'
          iv_message = 'Erro ao confirmar a transação'
        CHANGING
          ct_messages = lt_messages ).

      ENDIF.
    ELSE.
      cl_rmsl_message=>display( lt_messages ). "Classe standart mensagem BAPI
    ENDIF.
  ENDLOOP.
ENDFORM.

FORM z_detalhes_itens.

  DATA: ivals TYPE TABLE OF sval,
        xvals TYPE sval.

  CASE lv_column.
    WHEN 'BUKRS'.

      xvals-tabname   = 'EKKO'.
      xvals-fieldname = 'BUKRS'.
      APPEND xvals TO ivals.

      CALL FUNCTION 'POPUP_GET_VALUES'
        EXPORTING
          popup_title     = 'Empresa teste edit'
        TABLES
          fields          = ivals
        EXCEPTIONS
          error_in_fields = 1
          OTHERS          = 2.

      READ TABLE ivals INTO xvals WITH KEY fieldname = 'BUKRS'.

      lv_bukrs = xvals-value.

      READ TABLE lt_alv_display ASSIGNING FIELD-SYMBOL(<f_alv>) WITH KEY ebeln = lv_ebeln.

      IF sy-subrc = 0.
        <f_alv>-bukrs = lv_bukrs.

        v_o_table->display( ).
        v_o_table->refresh( ).
      ENDIF.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.
