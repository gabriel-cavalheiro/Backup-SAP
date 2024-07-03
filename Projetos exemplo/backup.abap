*----------------------------------------------------------------------*
***INCLUDE LZGFI_AUTOM_PGTOI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  ZIMPORT_EXCEL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE zimport_excel INPUT.

  TYPES: BEGIN OF ty_data,
           a TYPE  bukrs,
           b TYPE  saknr,
           c TYPE  string,
           d TYPE  string,
           e TYPE  string,
           f TYPE  string,
           g TYPE  string,
           h TYPE  string,
           i TYPE  string,
           j TYPE  string,
           k TYPE  string,
           l TYPE  string,
           m TYPE  string,
           n TYPE  string,
           o TYPE  string,
         END OF ty_data.

  TYPES: ty_it_itab TYPE STANDARD TABLE OF ty_data WITH DEFAULT KEY.

  DATA: tab_lines          TYPE i,
        it_files           TYPE filetable,
        lv_rc              TYPE i,
        lv_action          TYPE i,
        it_itab            TYPE ty_it_itab,
        wa                 LIKE LINE OF it_itab,
        ls_scarr           TYPE  scarr,
        t_ztbfi_autom_pgto TYPE TABLE OF ztbfi_autom_pgto,
        l_return(1)        TYPE c.

  tab_lines = 0.

  IF function EQ 'FILEIMP'.

    cl_gui_frontend_services=>file_open_dialog( EXPORTING
    file_filter = |xlsx (*.xlsx)\|*.xlsx\| { cl_gui_frontend_services=>filetype_all } |
    CHANGING
      file_table = it_files
      rc = lv_rc
      user_action = lv_action ).

    IF lv_action = cl_gui_frontend_services=>action_ok.
      IF lines( it_files ) > 0.

        DATA: lv_filesize TYPE w3param-cont_len,
              lv_filetype TYPE w3param-cont_type,
              it_bin_data TYPE w3mimetabtype.
        cl_gui_frontend_services=>gui_upload( EXPORTING
            filename = |{ it_files[ 1 ]-filename   }|
            filetype = 'BIN'
            IMPORTING
                filelength = lv_filesize
              CHANGING
                data_tab = it_bin_data ).

        DATA(lv_bin_data) = cl_bcs_convert=>solix_to_xstring( it_solix = it_bin_data ).

        DATA(o_excel) = NEW cl_fdt_xl_spreadsheet( document_name = CONV #( it_files[ 1 ]-filename )
                      xdocument = lv_bin_data ).

        DATA: it_worksheet_names TYPE if_fdt_doc_spreadsheet=>t_worksheet_names.
        o_excel->if_fdt_doc_spreadsheet~get_worksheet_names( IMPORTING worksheet_names = it_worksheet_names ).
        IF lines( it_worksheet_names ) > 0.

          DATA(o_worksheet_itab) = o_excel->if_fdt_doc_spreadsheet~get_itab_from_worksheet( it_worksheet_names[ 1 ] ).

          ASSIGN o_worksheet_itab->* TO FIELD-SYMBOL(<worksheet>).


          MOVE-CORRESPONDING <worksheet> TO  it_itab.
          DELETE it_itab INDEX 1.
        ENDIF.
      ENDIF.
    ENDIF.

    SELECT *
      FROM ztbfi_autom_pgto
      INTO TABLE t_ztbfi_autom_pgto.

    LOOP AT it_itab INTO DATA(w_itab).

      w_itab-b = |{ w_itab-b ALPHA = IN }|.

      READ TABLE t_ztbfi_autom_pgto INTO DATA(w_aut_pgto)
                                    WITH KEY bukrs = w_itab-a
                                             saknr = w_itab-b.
      IF sy-subrc = 0.

        CONCATENATE 'Deseja sobregravar os dados da empresa'
                     w_aut_pgto-bukrs 'e conta' w_aut_pgto-saknr INTO DATA(l_mss) SEPARATED BY space.

        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            titlebar              = 'Confirmação de Modificação'
            text_question         = l_mss
            text_button_1         = 'Sim'
            text_button_2         = 'Não'
            default_button        = '2'
            display_cancel_button = 'X'
          IMPORTING
            answer                = l_return " to hold the FM's return value
          EXCEPTIONS
            text_not_found        = 1
            OTHERS                = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        IF l_return EQ '1'.

          CLEAR w_aut_pgto.
          w_aut_pgto-bukrs        = w_itab-a.
          w_aut_pgto-saknr        = w_itab-b.
          w_aut_pgto-blart        = w_itab-c.
          w_aut_pgto-lifnr        = w_itab-d.
          w_aut_pgto-zahls        = w_itab-e.
          w_aut_pgto-zlsch        = w_itab-f.
          w_aut_pgto-dvenc        = w_itab-g.
          w_aut_pgto-antdutil     = w_itab-h.
          w_aut_pgto-tp_guia_pgto = w_itab-i.
          w_aut_pgto-rota_aprov   = w_itab-j.
          w_aut_pgto-wrbtr        = w_itab-k.
          w_aut_pgto-conta_aj     = w_itab-l.
          w_aut_pgto-conta_mu     = w_itab-m.
          w_aut_pgto-conta_ju     = w_itab-n.
          w_aut_pgto-kostl        = w_itab-o.
          w_aut_pgto-usuario      = sy-uname.
          w_aut_pgto-modificacao  = sy-datum.
          w_aut_pgto-hora         = sy-uzeit.

        ELSE.
          CONTINUE.
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDIF.
ENDMODULE.


*&---------------------------------------------------------------------*
*&  Include           ZF_AUTOM_PGTO_VERIF_TB
*&---------------------------------------------------------------------*
**********************************************************************
* Autor: Marcelo S Lopes
* Unid.: VSACWB
* Data : 06/03/2017
* Obs  : Objeto autorização por atividade para inserção de novos
*        registros na SM30 ZTBFI_AUTOM_PGTO
**********************************************************************
FORM zf_autom_pgto_verif_tb.

    CONSTANTS:
      c_actvt TYPE xufield     VALUE 'ACTVT',
      c_table TYPE char15      VALUE 'TABLE',
      c_namet TYPE char16      VALUE 'ZTBFI_AUTOM_PGTO',
      c_bukrs TYPE xufield     VALUE 'BUKRS',
      c_02    TYPE xuval       VALUE '02'.
  
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM'
      ID c_actvt FIELD c_02
      ID c_table FIELD c_namet.
  
    IF sy-subrc <> 0.
      MESSAGE e011(zfi01)
         WITH 'Sem autorização para inserção de novos registros.'(001).
      EXIT.
    ENDIF.
  
    AUTHORITY-CHECK OBJECT 'F_KNA1_BUK'
            ID c_bukrs FIELD ztbfi_autom_pgto-bukrs
            ID c_actvt FIELD c_02.
  
    IF sy-subrc <> 0.
      MESSAGE e011(zfi01)
         WITH 'Sem autorização para inserção de novos registros.'(001).
    ENDIF.
  ENDFORM.