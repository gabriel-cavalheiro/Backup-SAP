*&---------------------------------------------------------------------*
*& Report  ZTESTE_GILSON
*&
*&---------------------------------------------------------------------*
*& upload de um csv e conversão em tabela interna
*&
*&---------------------------------------------------------------------*

REPORT ZTESTE_GILSON NO STANDARD PAGE HEADING LINE-SIZE 85.


TYPE-POOLS: truxs.

DATA: BEGIN OF gt_contatos OCCURS 0,
      nome(20)  TYPE c,
      email(60) TYPE c,
  END OF gt_contatos.

PARAMETERS: p_arq TYPE rlgrap-filename OBLIGATORY,
            p_sep TYPE char01 OBLIGATORY DEFAULT ';'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_arq.

  PERFORM f_selecionar_arquivo.

START-OF-SELECTION.

  PERFORM f_importar_csv.

  IF gt_contatos[] IS INITIAL.
    MESSAGE 'Nenhum contato importado!!' TYPE 'I'.
    STOP.
  ENDIF.

  PERFORM f_imprimir_contatos.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  F_SELECIONAR_ARQUIVO
*&---------------------------------------------------------------------*
*       Abre a janela para selecionar um aqruivo CSV
*----------------------------------------------------------------------*
FORM f_selecionar_arquivo .
  DATA: lt_arquivos TYPE filetable,
        ls_arquivos TYPE file_table.

  DATA: lv_rc TYPE i.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = 'Selecione o arquivo o CSV a ser importado'
      file_filter             = 'Arquivos CSV (*.CSV) | *.csv'
    CHANGING
      file_table              = lt_arquivos
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc EQ 0.
    READ TABLE lt_arquivos INTO ls_arquivos INDEX 1.

    IF sy-subrc EQ 0.
      p_arq = ls_arquivos-filename.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_SELECIONAR_ARQUIVO
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_CSV
*&---------------------------------------------------------------------*
*  Importa o arquivo CSV para a tabela interna de contatos (GT_CONTATOS)
*----------------------------------------------------------------------*
FORM f_importar_csv .

  DATA: lt_raw TYPE truxs_t_text_data.

  DATA: lv_arquivo TYPE string.

  lv_arquivo = p_arq.

  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename = lv_arquivo
    CHANGING
      data_tab = lt_raw
    EXCEPTIONS
      OTHERS   = 1.

  CHECK sy-subrc EQ 0.

  CALL FUNCTION 'TEXT_CONVERT_TEX_TO_SAP'
    EXPORTING
      i_field_seperator    = p_sep
      i_tab_raw_data       = lt_raw
    TABLES
      i_tab_converted_data = gt_contatos
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.

ENDFORM.                    " F_UPLOAD_CSV
*&---------------------------------------------------------------------*
*&      Form  F_IMPRIMIR_CONTATOS
*&---------------------------------------------------------------------*
*       Escreve na tela a os dados dos contatos importados
*----------------------------------------------------------------------*
FORM f_imprimir_contatos .

  LOOP AT gt_contatos.
    WRITE sy-uline.

    WRITE: / '|',(81) 'CONTATO'(001) CENTERED COLOR COL_HEADING,'|'.

    WRITE sy-uline.

    PERFORM f_imprimir_campo USING 'Nome'(002)  gt_contatos-nome.

    PERFORM f_imprimir_campo USING 'Email'(003) gt_contatos-email.

    WRITE sy-uline.
  ENDLOOP.

ENDFORM.                    " F_IMPRIMIR_CONTATOS
*&---------------------------------------------------------------------*
*&      Form  F_IMPRIMIR_CAMPO
*&---------------------------------------------------------------------*
*       Escreve um campo da tabela de contatos
*----------------------------------------------------------------------*
*      -->P_TITULO   Título do campo
*      -->P_CONTEUDO Conteúdo do campo
*----------------------------------------------------------------------*
FORM f_imprimir_campo  USING   value(p_titulo)
                                     p_conteudo.

  WRITE: / '|' ,(20) p_titulo   COLOR COL_HEADING,
                (60) p_conteudo COLOR COL_NORMAL,
           '|'.

ENDFORM.                    " F_IMPRIMIR_CAMPO.