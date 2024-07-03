*****************************************************************************
***                      EMPRESAS RANDON                                  ***
*****************************************************************************
* Data Solicitação: 23.07.2019                                              *
* Funcional: Roberta Dalla Costa                                            *
* Parceira de Desenvolvimento: Castgroup                                    *
* Desenvolvedor: Guilherme Felipe Barcellos                                 *
* Observação: Report para automatizar a etapa do manifesto do Inbound       *
*****************************************************************************
REPORT znfir002.

TABLES: /xnfe/innfehd.

SELECT-OPTIONS: so_ghd FOR /xnfe/innfehd-guid_header.

START-OF-SELECTION.
  PERFORM executa.


FORM executa.

  CONSTANTS: cl_name             TYPE tvarvc-name VALUE 'ZNFI_DATAS_MANIFESTO',
             cl_sit_event        TYPE /xnfe/innfehd-sitopprg_status VALUE IS INITIAL,
             cl_txt_cancelamento TYPE /xnfe/infotext VALUE 'Nota fiscal finalizada'.

  DATA: vl_rfcdest       TYPE bdbapidst,
        vl_data          TYPE sy-datum,
        vl_xml           TYPE /xnfe/xmlstring,
        wl_inxml_nfe     TYPE /xnfe/inxml,
        tl_bapiret2      TYPE bapirettab,
        vl_nfenotexist   TYPE abap_bool,
        vl_nfenotmatch   TYPE abap_bool,
        tl_bapiretint    TYPE bapirettab,
        tl_/xnfe/innfeit TYPE /xnfe/innfeit_t.

  "Atribui a data do processamento
  vl_data = sy-datum.

  "Busca a quantidade de dias cadastrados
  SELECT SINGLE low
    FROM tvarvc
    INTO @DATA(vl_dias)
   WHERE name = @cl_name.

  IF sy-subrc IS INITIAL.
    "Se encontrou registro, faz a subtração para buscar para o passado
    vl_data = vl_data - vl_dias.
  ENDIF.

  "Converte a data para TIMESTAMP
  CONVERT DATE vl_data INTO TIME STAMP DATA(vl_timestamp) TIME ZONE 'BRAZIL'.

  "Busca os GUIDs com algum erro
  SELECT *
    FROM /xnfe/innfehd
    INTO TABLE @DATA(tl_/xnfe/innfehd)
   WHERE guid_header IN @so_ghd
     AND createtime GT @vl_timestamp
     AND ( ( last_step EQ 'SENDOPCO' AND actstat EQ '11' AND sitopprg_status EQ @cl_sit_event  ) "1º caso
     OR    ( last_step NE 'SENDOPCO' AND sitopprg_status EQ @cl_sit_event )  "2º caso
     OR    ( last_step EQ 'SENDOPCO' AND actstat EQ '11' AND sitopprg_status EQ '11' AND
             sitopprg  EQ '1'        AND last_step_status EQ '11' )  "3º caso
     OR    ( last_step EQ 'SENDOPCO' AND actstat EQ '11' AND sitopprg_status EQ '99' )  "4º Caso
     " Transferencias
     OR    ( last_step = 'GRMMCHCK' AND proctyp = 'STOCKTRF' AND actstat = '11' )
    ).

  "Se encontrou alguma coisa
  IF sy-subrc IS INITIAL.

    "Faz a busca dos itens dos GUIDs encontrados
    SELECT *
      FROM /xnfe/innfeit
      INTO TABLE tl_/xnfe/innfeit
     FOR ALL ENTRIES IN tl_/xnfe/innfehd
     WHERE guid_header = tl_/xnfe/innfehd-guid_header.

    LOOP AT tl_/xnfe/innfehd ASSIGNING FIELD-SYMBOL(<fl_header>).

      CALL FUNCTION '/XNFE/READ_RFC_DESTINATION'
        EXPORTING
          iv_logsys     = <fl_header>-logsys
        IMPORTING
          ev_rfcdest    = vl_rfcdest
        EXCEPTIONS
          no_dest_found = 1.

      IF sy-subrc IS INITIAL.
        EXIT.
      ENDIF.

    ENDLOOP.
  ENDIF.

  "Iteração para o 1º caso da consição da busca de ddos da HEADER
  LOOP AT tl_/xnfe/innfehd INTO DATA(wl_/xnfe/innfehd)
     WHERE last_step EQ 'SENDOPCO'
       AND actstat EQ '11'
       AND sitopprg_status EQ cl_sit_event.

    "Realiza o passo manual para as notas
    CALL FUNCTION '/XNFE/NFE_SET_STEP_MANUALLY'
      EXPORTING
        iv_guid           = wl_/xnfe/innfehd-guid_header
      EXCEPTIONS
        error_reading_nfe = 1
        technical_error   = 2
        OTHERS            = 3.

  ENDLOOP.

  "Iteração para o 2º caso da do select
  LOOP AT tl_/xnfe/innfehd INTO wl_/xnfe/innfehd
     WHERE last_step NE 'SENDOPCO'
       AND sitopprg_status EQ cl_sit_event.

    CLEAR: wl_inxml_nfe,
           tl_bapiret2,
           vl_nfenotexist,
           vl_nfenotmatch,
           tl_bapiretint.

    "Função para a busca do XML em XSTRING
    CALL FUNCTION '/XNFE/B2BNFE_READ_NFE_FOR_UPD'
      EXPORTING
        iv_guid_header     = wl_/xnfe/innfehd-guid_header
      IMPORTING
        es_xml_nfe         = wl_inxml_nfe
      EXCEPTIONS
        nfe_does_not_exist = 1
        nfe_locked         = 2
        technical_error    = 3
        OTHERS             = 4.

    "Caso de algum problema     "Ou o xstring está sem valor( sy-subrc retornado como 0 )
    IF sy-subrc IS NOT INITIAL OR wl_inxml_nfe-xmlstring IS INITIAL.
      CONTINUE. "Vai para a próxima iteração
    ENDIF.

    CALL FUNCTION 'ZCHECK_NFEINERP'
      DESTINATION vl_rfcdest
      EXPORTING
        iw_header           = wl_/xnfe/innfehd
      EXCEPTIONS
        chave_invalida      = 01
        nota_cancelada      = 02
        nota_nao_encontrada = 03
        OTHERS              = 04.


    "Verifica se não tem erro nas mensagens
*    IF NOT line_exists( tl_bapiret2[ type = 'E' ] ) AND
    IF sy-subrc IS INITIAL. "E se aconteceu algum problema sem mensagem

      "Executa a etapa de rejeição da nota
      CALL FUNCTION '/XNFE/NFE_SET_REJECTED'
        EXPORTING
          iv_guid_header       = wl_/xnfe/innfehd-guid_header
          iv_not_code          = 'PREÇO'
        EXCEPTIONS
          no_proc_allowed      = 1
          error_reading_nfe    = 2
          error_creating_event = 3
          technical_error      = 4
          OTHERS               = 5.

      IF sy-subrc IS INITIAL.

        "Cancela a rejeição
        CALL FUNCTION '/XNFE/NFE_RESET_REJECTED'
          EXPORTING
            iv_guid_header    = wl_/xnfe/innfehd-guid_header
          EXCEPTIONS
            no_proc_allowed   = 1
            error_reading_nfe = 2
            technical_error   = 3
            OTHERS            = 4.

        IF sy-subrc IS INITIAL.

          "Finaliza a NF manualmente
          CALL FUNCTION '/XNFE/NFE_SET_COMPLETED'
            EXPORTING
              iv_guid_header       = wl_/xnfe/innfehd-guid_header
              iv_infotext          = cl_txt_cancelamento
              iv_trig_opco_evnt    = 'X'
            EXCEPTIONS
              no_proc_allowed      = 1
              error_reading_nfe    = 2
              error_creating_event = 3
              technical_error      = 4
              OTHERS               = 5.

          IF sy-subrc EQ '3'. "Se deu erro ao criar o evento

            "Finaliza a NF manualmente, sem evento
            CALL FUNCTION '/XNFE/NFE_SET_COMPLETED'
              EXPORTING
                iv_guid_header       = wl_/xnfe/innfehd-guid_header
                iv_infotext          = cl_txt_cancelamento
                iv_trig_opco_evnt    = ' '
              EXCEPTIONS
                no_proc_allowed      = 1
                error_reading_nfe    = 2
                error_creating_event = 3
                technical_error      = 4
                OTHERS               = 5.

          ENDIF.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDLOOP.

  "Iteração para o 3º caso do select
  LOOP AT tl_/xnfe/innfehd INTO wl_/xnfe/innfehd
     WHERE last_step        EQ 'SENDOPCO'
       AND actstat          EQ '11'
       AND sitopprg_status  EQ '11'
       AND sitopprg         EQ '1'
       AND last_step_status EQ '11'.

    CLEAR: wl_inxml_nfe,
           tl_bapiret2,
           vl_nfenotexist,
           vl_nfenotmatch,
           tl_bapiretint.

    "Função para a busca do XML em XSTRING
    CALL FUNCTION '/XNFE/B2BNFE_READ_NFE_FOR_UPD'
      EXPORTING
        iv_guid_header     = wl_/xnfe/innfehd-guid_header
      IMPORTING
        es_xml_nfe         = wl_inxml_nfe
      EXCEPTIONS
        nfe_does_not_exist = 1
        nfe_locked         = 2
        technical_error    = 3
        OTHERS             = 4.

    "Caso de algum problema     "Ou o xstring está sem valor( sy-subrc retornado como 0 )
    IF sy-subrc IS NOT INITIAL OR wl_inxml_nfe-xmlstring IS INITIAL.
      CONTINUE. "Vai para a próxima iteração
    ENDIF.

    CALL FUNCTION 'ZCHECK_NFEINERP'
      DESTINATION vl_rfcdest
      EXPORTING
        iw_header           = wl_/xnfe/innfehd
      EXCEPTIONS
        chave_invalida      = 01
        nota_cancelada      = 02
        nota_nao_encontrada = 03
        OTHERS              = 04.

    IF sy-subrc IS INITIAL.

      CALL FUNCTION '/XNFE/NFE_SET_COMPLETED'
        EXPORTING
          iv_guid_header       = wl_/xnfe/innfehd-guid_header
          iv_infotext          = cl_txt_cancelamento
          iv_trig_opco_evnt    = 'X'
        EXCEPTIONS
          no_proc_allowed      = 1
          error_reading_nfe    = 2
          error_creating_event = 3
          technical_error      = 4
          OTHERS               = 5.
    ENDIF.

  ENDLOOP.

  "Iteração para o 4º caso do select
  LOOP AT tl_/xnfe/innfehd INTO wl_/xnfe/innfehd
    WHERE last_step EQ 'SENDOPCO'
      AND actstat EQ '11'
      AND sitopprg_status EQ '99'.

    CALL FUNCTION 'ZCHECK_NFEINERP'
      DESTINATION vl_rfcdest
      EXPORTING
        iw_header           = wl_/xnfe/innfehd
      EXCEPTIONS
        chave_invalida      = 01
        nota_cancelada      = 02
        nota_nao_encontrada = 03
        OTHERS              = 04.

    IF sy-subrc IS INITIAL.

      CALL FUNCTION '/XNFE/NFE_SET_COMPLETED'
        EXPORTING
          iv_guid_header       = wl_/xnfe/innfehd-guid_header
          iv_infotext          = cl_txt_cancelamento
          iv_trig_opco_evnt    = ' '
        EXCEPTIONS
          no_proc_allowed      = 1
          error_reading_nfe    = 2
          error_creating_event = 3
          technical_error      = 4
          OTHERS               = 5.
    ENDIF.

  ENDLOOP.

  "Iteração para o 5º caso do select (transferencias)
  LOOP AT tl_/xnfe/innfehd INTO wl_/xnfe/innfehd
    WHERE last_step = 'GRMMCHCK'
      AND actstat   = '11'
      AND proctyp   = 'STOCKTRF'.

    CALL FUNCTION 'ZCHECK_NFEINERP'
      DESTINATION vl_rfcdest
      EXPORTING
        iw_header           = wl_/xnfe/innfehd
      EXCEPTIONS
        chave_invalida      = 01
        nota_cancelada      = 02
        nota_nao_encontrada = 03
        OTHERS              = 04.

    IF sy-subrc IS INITIAL.

      CALL FUNCTION '/XNFE/NFE_SET_COMPLETED'
        EXPORTING
          iv_guid_header       = wl_/xnfe/innfehd-guid_header
          iv_infotext          = cl_txt_cancelamento
          iv_trig_opco_evnt    = ' '
        EXCEPTIONS
          no_proc_allowed      = 1
          error_reading_nfe    = 2
          error_creating_event = 3
          technical_error      = 4
          OTHERS               = 5.
    ENDIF.

  ENDLOOP.


ENDFORM.
