*&---------------------------------------------------------------------*
*& Report Z_TESTE_GILSON
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_teste_gilson.

TYPES:
  BEGIN OF ty_message, " Types para retorno de mensagem.
    v_xml_chave_nfe TYPE j_1b_nfe_access_key_dtel44,        " Código do cliente
    msgty           TYPE message-msgty,                     " Tipo da mensagem
    msgno           TYPE message-msgno,                     " Numero da mensagem
    msgtx           TYPE message-msgtx,                     " Descrição da mensagem
  END OF   ty_message.


" work area e tabela interna tipo BDC data SHDB
DATA: wa_bdcdata      TYPE bdcdata,
      it_bdcdata      TYPE TABLE OF bdcdata,
"variaveis dinamicas passadas a BDC data
      v_xml_chave_nfe TYPE j_1b_nfe_access_key_dtel44,
      v_bukrs         TYPE ztbmm_nf_forn_cb-bukrs.

DATA: vg_mode(1)    TYPE c VALUE 'A', " informa o Modo do Call Transaction
      vg_texto(100) TYPE c,        " Texto para o Indicator
      vg_s          TYPE c VALUE 'S',       " Informa o Update do call Transaction
      mensg         LIKE message VALUE IS INITIAL, " variavel que recebe retorno
      msgno         LIKE sy-msgno,
      it_msg        TYPE TABLE OF bdcmsgcoll WITH HEADER LINE,
      it_message    TYPE TABLE OF ty_message,
      st_message    TYPE ty_message.

v_xml_chave_nfe = '42210802263430000393550020000086101000087860'.
v_bukrs = '4014'.




PERFORM zf_shdb_zglmm436.
PERFORM zf_carrega_transacao.
PERFORM zf_imprime_mensagem.
*&---------------------------------------------------------------------*
*&      Form  Z_MONTA_SHDB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM zf_shdb_zglmm436 .

  PERFORM zf_bdc_zglmm436 USING:

     'X'    'ZGLRMM0194_CRIACAO_AUTOMA_MIRO'       '1000',
     ' '    'BDC_CURSOR'     'S_BUKRS-LOW',
     ' '    'BDC_OKCODE'     '=ONLI',
     ' '    'S_BUKRS-LOW'    v_bukrs, "retirar aspas,
     ' '    'S_CHAVE-LOW'    v_xml_chave_nfe, "retirar aspas,
     ' '    'S_ST_REC-LOW'    'S',
     'X'    'ZGLRMM0194_CRIACAO_AUTOMA_MIRO'       '1000',
     ' '    'BDC_OKCODE'     '/EE',
     ' '    'BDC_CURSOR'     'S_BUKRS-LOW'.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  Z_PREENCHE_BDC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0020   text
*      -->P_0021   text
*      -->P_0022   text
*----------------------------------------------------------------------*
FORM zf_bdc_zglmm436  USING    dynbegin
                               name
                               value.
  IF dynbegin = 'X'.
    MOVE: name      TO wa_bdcdata-program,
          value     TO wa_bdcdata-dynpro,
          dynbegin  TO wa_bdcdata-dynbegin.
    APPEND wa_bdcdata TO it_bdcdata.
  ELSE.
    MOVE: name  TO wa_bdcdata-fnam,
          value TO wa_bdcdata-fval.

    APPEND wa_bdcdata TO it_bdcdata.

  ENDIF.
  "  prepara a estrutura para o Loop.
  CLEAR wa_bdcdata.

ENDFORM.

FORM zf_carrega_transacao .
"  Chama a trasação informada usando a tabela 'IT_BDCDATA que na verdade
" é um shdb que vai automátiza o processo até o ultimo registro, existe
" dois metodos de ver o processo, no 'MODE se colocar 'N' vc não visualiza
" o processo, agora se vc coloca 'A' no 'MODE vc terá que apertar 'Enter
" por processo e depois de efetuar o processo por registro ele popula a
" tabela 'IT_MSG com os dados de retorno,se foi realizado com exito, ou se
" deu algum problema.
  CALL TRANSACTION 'ZGLMM436' USING it_bdcdata
                              MODE  vg_mode
                              UPDATE vg_s
                              MESSAGES INTO it_msg.


ENDFORM.

FORM zf_imprime_mensagem.
"  Dá 'Loop na tabela de retorno da chamada da transação e alimenta outra
" tabela com a retorno referenciado com o Cliente
  LOOP AT it_msg.
    msgno = it_msg-msgnr.
    "  Function que faz mostrar a mensagem
    CALL FUNCTION 'WRITE_MESSAGE'
      EXPORTING
        msgid         = it_msg-msgid
        msgno         = msgno
        msgty         = it_msg-msgtyp
        msgv1         = it_msg-msgv1
        msgv2         = it_msg-msgv2
        msgv3         = it_msg-msgv3
        msgv4         = it_msg-msgv4
        msgv5         = ' '
     IMPORTING
*       ERROR         =
        messg         = mensg
*       MSGLN         =
              .
  ENDLOOP.

  st_message-v_xml_chave_nfe = v_xml_chave_nfe.
  st_message-msgty           = mensg-msgty.
  st_message-msgno           = mensg-msgno.
  st_message-msgtx           = mensg-msgtx.
" popula a tabela principal de mensagem que será o Log de erro.
  APPEND st_message TO it_message.

  MESSAGE st_message-msgtx TYPE 'I'.
ENDFORM.