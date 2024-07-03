*&---------------------------------------------------------------------*
*& Report ZABAP_ZTCA37_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZABAP_ZTCA37_01.


TABLES:  ZTABAP_ALN037_T1, ZTABAP_ALN037_T2.

*Tipos de estrutura de Tabelas ---------------------------------------------------------------------------------------------------------

TYPES: BEGIN OF tp_alv,
        semaforo     TYPE CHAR8,
        id_cadastro  TYPE ZTABAP_ALN037_T1-id_cadastro,
        Nome         TYPE ZTABAP_ALN037_T1-nome,
        Endereco     TYPE ZTABAP_ALN037_T1-endereco,
        telefone     TYPE ZTABAP_ALN037_T1-telefone,
        e_mail       TYPE ZTABAP_ALN037_T1-e_mail,
        saldo        TYPE ZTABAP_ALN037_T2-saldo,
        limite       TYPE ZTABAP_ALN037_T2-limite,
        limite_total TYPE ZTABAP_ALN037_T2-limite_total,
        valor_compra TYPE ZTABAP_ALN037_T2-valor_compra,
        color(4)     TYPE c,
       END OF tp_alv,

       BEGIN OF tp_cad,
        id_cadastro  TYPE ZTABAP_ALN037_T1-id_cadastro,
        Nome         TYPE ZTABAP_ALN037_T1-nome,
        Endereco     TYPE ZTABAP_ALN037_T1-endereco,
        telefone     TYPE ZTABAP_ALN037_T1-telefone,
        e_mail       TYPE ZTABAP_ALN037_T1-e_mail,
        saldo        TYPE ZTABAP_ALN037_T2-saldo,
        limite       TYPE ZTABAP_ALN037_T2-limite,
        limite_total TYPE ZTABAP_ALN037_T2-limite_total,
        valor_compra TYPE ZTABAP_ALN037_T2-valor_compra,
       END OF tp_cad,

        BEGIN OF tp_Saldo,
        id_cadastro  TYPE ZTABAP_ALN037_T1-id_cadastro,
        Nome         TYPE ZTABAP_ALN037_T1-nome,
        Endereco     TYPE ZTABAP_ALN037_T1-endereco,
        telefone     TYPE ZTABAP_ALN037_T1-telefone,
        e_mail       TYPE ZTABAP_ALN037_T1-e_mail,
        saldo        TYPE ZTABAP_ALN037_T2-saldo,
        limite       TYPE ZTABAP_ALN037_T2-limite,
        limite_total TYPE ZTABAP_ALN037_T2-limite_total,
        valor_compra TYPE ZTABAP_ALN037_T2-valor_compra,
       END OF tp_Saldo.

*-------------------------------------------------------------------------------------------------------------------------

*Variaveis globais--------------------------------------------------------------------------------------------------------

DATA: tg_cadastro     TYPE TABLE OF ZTABAP_ALN037_T1,
      tg_saldos       TYPE TABLE OF ZTABAP_ALN037_T2,
      tg_alv          TYPE TABLE OF tp_alv,
      tg_cad          TYPE TABLE OF tp_cad,
      wl_cad          TYPE ZTABAP_ALN037_T1,
      wl_saldo        TYPE ZTABAP_ALN037_T2,
      tg_fieldcatalog TYPE lvc_t_fcat,
      ls_exclude      TYPE ui_func,
      pt_exclude      TYPE ui_functions.4



DATA: og_grid         TYPE REF TO cl_gui_alv_grid,
      og_container    TYPE REF TO cl_gui_custom_container,
      gc_custom_control_name TYPE scrfname VALUE 'ALV-SCREEN'.

*-----------------------------------------------------------------------------------------------------------------------------

SELECTION-SCREEN BEGIN OF LINE.

  SELECTION-SCREEN POSITION 10.
  PARAMETERS : rb_1  RADIOBUTTON GROUP r1 USER-COMMAND USE_UP DEFAULT 'X'.
  SELECTION-SCREEN COMMENT 12(20) CAD." Insert

  SELECTION-SCREEN POSITION 32.
  PARAMETERS : rb_2 RADIOBUTTON GROUP r1.
  SELECTION-SCREEN COMMENT 34(18) EDICAD." Update

  SELECTION-SCREEN POSITION 53.
  PARAMETERS : rb_3 RADIOBUTTON GROUP r1.
  SELECTION-SCREEN COMMENT 55(20) EDISALD." delete
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  SELECT-OPTIONS: s_Id FOR  ZTABAP_ALN037_T1-id_cadastro  MODIF ID EDC.

SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  CAD     = TEXT-f01. " Cadastro
  EDICAD  = TEXT-f02. " Editar_cadastro
  EDISALD = TEXT-f03. " Editar_Saldo

AT SELECTION-SCREEN OUTPUT.

LOOP AT SCREEN.
  CASE abap_true.
    WHEN rb_1.
            IF screen-group1 = 'EDC'.
            screen-active = '0'.
            MODIFY SCREEN.
           ENDIF.
    WHEN rb_2.
           IF screen-group1 = 'EDC'.
           screen-active = '1'.
            MODIFY SCREEN.
           ENDIF.
     WHEN rb_3.
       IF screen-group1 = 'EDC'.
           screen-active = '1'.
            MODIFY SCREEN.
           ENDIF.
  ENDCASE.
ENDLOOP.

START-OF-SELECTION.


CASE abap_true.
   WHEN rb_1.
           PERFORM ALVMOD.
   WHEN rb_2.
            PERFORM ALVMOD.
   WHEN rb_3.
            PERFORM ALVMOD.
ENDCASE.


FORM ALVMOD.
  PERFORM f_seleciona_cadastro.
  PERFORM f_trata_cadastro.

  IF tg_alv[] IS NOT INITIAL.
    CALL SCREEN 9001.
  ENDIF.
ENDFORM.




*&---------------------------------------------------------------------*
*& Module STATUS_9001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9001 OUTPUT.
  SET PF-STATUS 'STATUS_9001'.
  SET TITLEBAR 'TITLE_9001'.

      IF og_grid IS INITIAL.
        CREATE OBJECT og_container
            EXPORTING
              container_name = gc_custom_control_name.

        CREATE OBJECT og_grid "Criação do objeto que exibirá o alv
         EXPORTING
        i_parent = og_container.

    PERFORM: f_exibe_alv.
    ELSE.
      og_grid->refresh_table_display( ).
    ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
  IF rb_1 EQ 'X'.

    CASE SY-UCOMM.
       WHEN 'SALVE'.
       PERFORM CADASTRO.

    ENDCASE.
  ENDIF.
  IF rb_2 EQ 'X'.

    CASE SY-UCOMM.
       WHEN 'SALVE'.
       PERFORM EDITACADASTRO.
    ENDCASE.
  ENDIF.
  IF rb_3 EQ 'X'.

    CASE SY-UCOMM.
       WHEN 'SALVE'.
       PERFORM EDITASALDO.
       WHEN 'PRINT'.
       PERFORM IMPRIMIR.
    ENDCASE.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command INPUT.
  IF sy-ucomm EQ 'CANCEL'.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form f_seleciona_dados
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_seleciona_cadastro.
  DATA:  wl_alv  TYPE tp_alv,
         wl_cad  TYPE tp_cad.
CASE abap_true.
  WHEN rb_1.
    CALL FUNCTION 'NUMBER_GET_NEXT' "Função de auto incremento da coluna ID"
              EXPORTING
                nr_range_nr             = '01'
                object                  = 'ZCAD_ALN37' "object criado na snro"
                quantity                = '1'
              IMPORTING
                number                  = wl_cad-id_cadastro
              EXCEPTIONS
                interval_not_found      = 1
                number_range_not_intern = 2
                object_not_found        = 3
                quantity_is_0           = 4
                quantity_is_not_1       = 5
                interval_overflow       = 6
                buffer_overflow         = 7
                OTHERS                  = 8.

                MOVE-CORRESPONDING wl_cad TO wl_alv.
                APPEND wl_alv TO tg_alv.

  WHEN rb_2.

     SELECT ZTABAP_ALN037_T1~id_cadastro
        ZTABAP_ALN037_T1~nome
        ZTABAP_ALN037_T1~endereco
        ZTABAP_ALN037_T1~telefone
        ZTABAP_ALN037_T1~e_mail
        ZTABAP_ALN037_T2~saldo
        ZTABAP_ALN037_T2~limite
        ZTABAP_ALN037_T2~limite_total
        ZTABAP_ALN037_T2~valor_compra
        FROM ZTABAP_ALN037_T1
        INNER JOIN ZTABAP_ALN037_T2 AS ZTABAP_ALN037_T2
        ON ZTABAP_ALN037_T2~id_cadastro EQ ZTABAP_ALN037_T1~id_cadastro
        INTO table tg_cad
        WHERE ZTABAP_ALN037_T1~id_cadastro IN s_Id.



  WHEN rb_3.
     SELECT ZTABAP_ALN037_T1~id_cadastro
        ZTABAP_ALN037_T1~nome
        ZTABAP_ALN037_T1~endereco
        ZTABAP_ALN037_T1~telefone
        ZTABAP_ALN037_T1~e_mail
        ZTABAP_ALN037_T2~saldo
        ZTABAP_ALN037_T2~limite
        ZTABAP_ALN037_T2~limite_total
        ZTABAP_ALN037_T2~valor_compra
        FROM ZTABAP_ALN037_T1
        INNER JOIN ZTABAP_ALN037_T2 AS ZTABAP_ALN037_T2
        ON ZTABAP_ALN037_T2~id_cadastro EQ ZTABAP_ALN037_T1~id_cadastro
        INTO table tg_cad
        WHERE ZTABAP_ALN037_T1~id_cadastro IN s_Id.
ENDCASE.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form f_trata_dados
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_trata_cadastro.
 DATA: wl_cad         TYPE tp_cad,
       wl_alv         TYPE tp_alv,
       vl_valoraux    TYPE ZTABAP_ALN037_T2-limite_total.



CASE abap_true.
  WHEN rb_1.
  WHEN rb_2.
  WHEN rb_3.
ENDCASE.
 LOOP AT tg_cad INTO wl_cad.
    CLEAR: wl_alv.
    MOVE-CORRESPONDING wl_cad TO wl_alv.
    IF wl_cad-saldo GT 0.
      wl_alv-semaforo = '@S_TL_G@'.
    ELSEIF wl_cad-saldo = 0 AND wl_cad-limite GT 0.
      wl_alv-semaforo = '@S_TL_Y@'.
   ELSE.
     wl_alv-semaforo = '@S_TL_R@'.
    ENDIF.
    APPEND wl_alv TO tg_alv.
  ENDLOOP.
ENDFORM.


*&---------------------------------------------------------------------*
*& Form f_exibe_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_exibe_alv.
   DATA: wl_layout  TYPE lvc_s_layo,
        wl_variant  TYPE disvariant,
        v_edit_rb1  TYPE lvc_s_fcat-edit,
        v_edit_rb3  TYPE lvc_s_fcat-edit,
        v_outcolum  TYPE lvc_s_fcat-no_out.
  IF tg_fieldcatalog[] IS INITIAL.

     CASE abap_true.
     	WHEN rb_1 .
         v_edit_rb1 = abap_true.
         v_outcolum = abap_true.
     	WHEN rb_2.
         v_edit_rb1 = abap_true.
         v_outcolum = abap_false.
     	WHEN rb_3.
        v_edit_rb1 = abap_false.
        v_outcolum = abap_false.
        v_edit_rb3 = abap_true.
     ENDCASE.


    PERFORM f_cria_fieldcatalog USING: 'TG_ALV' 'SEMAFORO'     'Status'          ''         '' v_outcolum ''          ''    0   10,
                                       'TG_ALV' 'ID_CADASTRO'  'Id_cadastrado'   ''         '' ''         ''          ''    0   10,
                                       'TG_ALV' 'NOME'         'Nome'            v_edit_rb1 '' ''         ''          'X'   0   45,
                                       'TG_ALV' 'ENDERECO'     'Endereço'        v_edit_rb1 '' ''         ''          'X'   0   50,
                                       'TG_ALV' 'TELEFONE'     'Telefone'        v_edit_rb1 '' ''    'RR(__)_____-____' ''   0   14,
                                       'TG_ALV' 'E_MAIL'       'E-mail'          v_edit_rb1 '' ''         ''          'X'   0   120,
                                       'TG_ALV' 'SALDO'        'Saldo'           ''         '' ''         ''           ''   2   13,
                                       'TG_ALV' 'LIMITE'       'Limite'          ''         '' ''         ''           ''   2   13,
                                       'TG_ALV' 'LIMITE_TOTAL' 'Limite total'    ''         '' ''         ''           ''   2   13,
                                       'TG_ALV' 'VALOR_COMPRA' 'Valor da compra' v_edit_rb3 '' ''         ''           ''   2   13.

  ENDIF.

  wl_layout-zebra      = 'X'.
  wl_layout-cwidth_opt = 'X'.
  wl_layout-grid_title = 'Cadastro'.
  wl_variant-report    = sy-repid.

PERFORM EXCLUIRBOTOES.

CALL METHOD og_grid->set_ready_for_input.

  CALL METHOD og_grid->set_table_for_first_display
    EXPORTING
      is_layout            = wl_layout
      is_variant           = wl_variant
      i_save               = 'A'
      it_toolbar_excluding = pt_exclude[]
    CHANGING
      it_outtab       = tg_alv
      it_fieldcatalog = tg_fieldcatalog.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_cria_fieldcatalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f_cria_fieldcatalog
    USING vp_tabname       TYPE lvc_s_fcat-tabname
          vp_fieldname     TYPE lvc_s_fcat-fieldname
          vp_reptext       TYPE lvc_s_fcat-scrtext_m
          vp_edit          TYPE lvc_s_fcat-edit
          vp_dosum         TYPE lvc_s_fcat-do_sum
          vp_noout         TYPE lvc_s_fcat-no_out
          vp_editmask      TYPE lvc_s_fcat-edit_mask
          vp_lowercase     TYPE lvc_s_fcat-lowercase
          vp_decelfield    TYPE lvc_s_fcat-decimals
          vp_outlen        TYPE lvc_s_fcat-dd_outlen.

  DATA: wl_fieldcatalog TYPE lvc_s_fcat.


  wl_fieldcatalog-tabname      = vp_tabname.
  wl_fieldcatalog-fieldname    = vp_fieldname.
  wl_fieldcatalog-reptext      = vp_reptext.
  wl_fieldcatalog-edit         = vp_edit.
  wl_fieldcatalog-do_sum       = vp_dosum.
  wl_fieldcatalog-no_out       = vp_noout.
  wl_fieldcatalog-edit_mask    = vp_editmask.
  wl_fieldcatalog-lowercase    = vp_lowercase.
  wl_fieldcatalog-decimals     = vp_decelfield.
  wl_fieldcatalog-dd_outlen    = vp_outlen.

  APPEND wl_fieldcatalog TO tg_fieldcatalog.
ENDFORM.


FORM EXCLUIRBOTOES.

              ls_exclude = cl_gui_alv_grid=>MC_FC_LOC_APPEND_ROW.
              APPEND ls_exclude TO pt_exclude.
              ls_exclude = cl_gui_alv_grid=>MC_FC_LOC_COPY_ROW.
              APPEND ls_exclude TO pt_exclude.
              ls_exclude = cl_gui_alv_grid=>MC_FC_LOC_CUT.
              APPEND ls_exclude TO pt_exclude.
               ls_exclude = cl_gui_alv_grid=>MC_FC_LOC_INSERT_ROW.
              APPEND ls_exclude TO pt_exclude.
              ls_exclude = cl_gui_alv_grid=>MC_FC_LOC_DELETE_ROW.
              APPEND ls_exclude TO pt_exclude.
              ls_exclude = cl_gui_alv_grid=>MC_FC_LOC_UNDO.
              APPEND ls_exclude TO pt_exclude.

ENDFORM.


FORM CADASTRO.

    DATA:tl_alv         TYPE TABLE OF tp_alv,
         wl_cad         TYPE ZTABAP_ALN037_T1,
         wl_saldo       TYPE ZTABAP_ALN037_T2,
         wl_alv         TYPE tp_alv,
         t_fields       TYPE TABLE OF sval, "Atributos tabela para o pop up SALDO e LIMITE
         w_fields       TYPE          sval, "Atributos tabela para o pop up SALDO e LIMITE
         vl_limiteTotal TYPE ZTABAP_ALN037_T2-limite_total,
         vl_lenght      TYPE I,
         vl_fone        TYPE NUMC13,
         vl_valid TYPE c LENGTH 1.

og_grid->check_changed_data(
     IMPORTING
       e_valid = vl_valid ).
IF vl_valid = abap_true.

tl_alv = tg_alv.

LOOP AT tg_alv INTO wl_alv.

ENDLOOP.

* Codigo referente ao popup de inserção de valores de Saldo e Limite
w_fields-tabname   = 'ZTABAP_ALN037_T2'.
w_fields-fieldname = 'SALDO'.
w_fields-field_obl = abap_true.
      APPEND w_fields TO t_fields.
      CLEAR w_fields.

w_fields-tabname   = 'ZTABAP_ALN037_T2'.
w_fields-fieldname = 'LIMITE'.
w_fields-field_obl = abap_true.
      APPEND w_fields TO t_fields.
      CLEAR w_fields.

CALL FUNCTION 'POPUP_GET_VALUES'
  EXPORTING
    popup_title = 'Informe Saldo e Limite'
  TABLES
    fields      = t_fields.


LOOP AT t_fields INTO w_fields.
  READ TABLE t_fields into w_fields
                      WITH KEY fieldname = 'SALDO'.
  IF sy-subrc = 0.
    wl_alv-saldo = w_fields-value.
  ENDIF.
ENDLOOP.

LOOP AT t_fields INTO w_fields.
  READ TABLE t_fields into w_fields
                      WITH KEY fieldname = 'LIMITE'.
  IF sy-subrc = 0.
    wl_alv-limite = w_fields-value.
  ENDIF.
ENDLOOP.

* Valores de saldo e limite dos campos fields atribuidos a work area local da ALV.
*---------------------------------------------------------------------------------------------------------------------------------------------------

vl_limiteTotal = wl_alv-saldo + wl_alv-limite.
wl_alv-limite_total = vl_limiteTotal.

CLEAR tg_alv.
APPEND wl_alv TO tg_alv.

vl_fone = wl_alv-telefone.

wl_cad-id_cadastro = wl_alv-id_cadastro.
IF wl_alv-nome = ''.
  MESSAGE 'Favor digitar um nome para cadastro' TYPE 'E'.
  RETURN.
  ELSE.
    wl_cad-nome        = wl_alv-nome.
ENDIF.
IF wl_alv-endereco = ''.
 MESSAGE 'Favor digitar um endereço para cadastro' TYPE 'E'.
  RETURN.
  ELSE.
   wl_cad-endereco    = wl_alv-endereco.
ENDIF.
IF wl_alv-telefone = ''.
  MESSAGE 'Favor digitar um número de telefone para cadastro' TYPE 'E'.
  RETURN.
ELSEIF vl_lenght LE 12.
  MESSAGE 'Favor digitar um número de telefone valido para cadastro' TYPE 'E'.
  RETURN.
ELSE.
 wl_cad-telefone = wl_alv-telefone.
ENDIF.
IF wl_alv-e_mail = ''.
   MESSAGE 'Favor digitar um e-mail para cadastro' TYPE 'E'.
   RETURN.
   ELSE.
     wl_cad-e_mail      = wl_alv-e_mail.
ENDIF.

MODIFY ZTABAP_ALN037_T1 FROM wl_cad.
COMMIT WORK AND WAIT.

wl_saldo-id_cadastro   = wl_alv-id_cadastro.

IF wl_alv-saldo LE 0.
  MESSAGE 'Saldo 0, favor entrar com um saldo' TYPE 'E'.
  ELSE.
    wl_saldo-saldo         = wl_alv-saldo.
ENDIF.
IF wl_alv-limite LT 0.
  MESSAGE 'Não é possivel cadastro de saldo negativo' TYPE 'E'.
  ELSE.
    wl_saldo-limite = wl_alv-limite.
ENDIF.
wl_saldo-limite_total  = wl_alv-limite_total.

MODIFY ZTABAP_ALN037_T2 FROM wl_saldo.
COMMIT WORK AND WAIT.

MESSAGE 'Cliente cadastrado com sucesso!' TYPE 'S'.

Clear tg_alv.
PERFORM ALVMOD.
ENDIF.
ENDFORM.


FORM EDITACADASTRO.

   DATA: tl_alv         TYPE TABLE OF tp_alv,
         tl_cad        TYPE TABLE OF ZTABAP_ALN037_T1,
         wl_cad        TYPE ZTABAP_ALN037_T1,
         wl_alv        TYPE tp_alv,
         vl_fone       TYPE NUMC13.



CALL METHOD og_grid->check_changed_data( ).
og_grid->check_changed_data( ).

tl_alv = tg_alv.

LOOP AT tg_alv INTO wl_alv.
ENDLOOP.

vl_fone = wl_alv-telefone.

wl_cad-id_cadastro = wl_alv-id_cadastro.
IF wl_alv-nome = ''.
  MESSAGE 'Favor digitar um nome para cadastro' TYPE 'E'.
  RETURN.
  ELSE.
    wl_cad-nome        = wl_alv-nome.
ENDIF.
IF wl_alv-endereco = ''.
 MESSAGE 'Favor digitar um endereço para cadastro' TYPE 'E'.
  RETURN.
  ELSE.
   wl_cad-endereco    = wl_alv-endereco.
ENDIF.
IF wl_alv-telefone = ''.
  MESSAGE 'Favor digitar um número de telefone para cadastro' TYPE 'E'.
  RETURN.
ELSE.
  wl_cad-telefone = wl_alv-telefone.
ENDIF.
IF wl_alv-e_mail = ''.
   MESSAGE 'Favor digitar um e-mail para cadastro' TYPE 'E'.
   RETURN.
   ELSE.
     wl_cad-e_mail      = wl_alv-e_mail.
ENDIF.

LOOP AT tg_alv INTO wl_alv.
   MOVE-CORRESPONDING wl_alv TO wl_cad.
   APPEND wl_cad TO tl_cad.
ENDLOOP.


MODIFY ZTABAP_ALN037_T1 FROM TABLE tl_cad.
COMMIT WORK AND WAIT.

MESSAGE 'cadastrados modificados com sucesso!' TYPE 'S'.

tg_alv = tl_alv.

ENDFORM.

FORM EDITASALDO.
DATA:    vl_valid           TYPE c LENGTH 1,
         tl_alv             TYPE TABLE OF tp_alv,
         tl_cad             TYPE TABLE OF ZTABAP_ALN037_T2,
         wl_cad             TYPE ZTABAP_ALN037_T2,
         wl_alv             TYPE tp_alv,
         vl_compra          TYPE ZTABAP_ALN037_T2-valor_compra,
         vl_comprasaldo     TYPE ZTABAP_ALN037_T2-valor_compra,
         vl_compralimite    TYPE ZTABAP_ALN037_T2-valor_compra,
         vl_saldo           TYPE ZTABAP_ALN037_T2-saldo,
         vl_limite          TYPE ZTABAP_ALN037_T2-limite,
         vl_limitetotal     TYPE ZTABAP_ALN037_T2-limite_total.

CALL METHOD og_grid->check_changed_data( ).
og_grid->check_changed_data( ).

    LOOP AT tg_alv INTO wl_alv.
      vl_compra      = wl_alv-valor_compra.
      vl_saldo       = wl_alv-saldo.
      vl_limite      = wl_alv-limite.
      vl_limitetotal = wl_alv-saldo + wl_alv-limite.

       BREAK-POINT.

      IF vl_compra GT vl_limitetotal.
        MESSAGE 'O valor da compra ultrapassa o valor do limite total.' TYPE 'I'.
        RETURN.
        ELSEIF vl_compra LT 0.
          MESSAGE 'O valor da compra não pode ser negativo.' TYPE 'I'.
        RETURN.
      ENDIF.
      IF vl_compra LE vl_saldo.
        wl_alv-saldo = vl_saldo - vl_compra.
        wl_alv-valor_compra = 0.
        IF wl_alv-saldo = 0.
           wl_alv-semaforo = '@S_TL_Y@'. "amarelo.
           wl_alv-valor_compra = 0.
        ENDIF.
      ENDIF.

      IF vl_compra GT vl_saldo.
        vl_compralimite = vl_compra.
        vl_compralimite = vl_compralimite - vl_saldo.
        wl_alv-saldo = 0.
        wl_alv-limite = vl_limite - vl_compralimite.
        wl_alv-semaforo = '@S_TL_R@'. "vermelho.
        wl_alv-valor_compra = 0.
      ENDIF.

      MOVE-CORRESPONDING wl_alv TO wl_cad.
   	  APPEND wl_cad TO tl_cad.
      APPEND wl_alv TO tl_alv.
    ENDLOOP.

tg_alv = tl_alv.

MODIFY ZTABAP_ALN037_T2 FROM TABLE tl_cad.
COMMIT WORK AND WAIT.

MESSAGE 'Saldos modificados com sucesso!' TYPE 'S'.

ENDFORM.

FORM IMPRIMIR.

  DATA: tl_index_rows	TYPE lvc_t_row,
        wl_index_rows TYPE lvc_s_row,
        tl_alv         TYPE TABLE OF tp_alv,
        wl_cad         TYPE ZTABAP_ALN037_T1,
        wl_saldo       TYPE ZTABAP_ALN037_T2,
        wl_alv         TYPE tp_alv,
        vl_idcad       TYPE ZTABAP_ALN037_T1-id_cadastro,
        vl_nome        TYPE ZTABAP_ALN037_T1-nome.


  DATA: lv_fm_name  TYPE rs38l_fnam,
      lv_filesize TYPE i,
      lw_output   TYPE ssfcompop,
      lw_control  TYPE ssfctrlop,
      lv_name     TYPE string,
      lv_cef      TYPE char1,
      lt_docs     TYPE TABLE OF docs,
      lt_lines    TYPE TABLE OF tline,
      i_xstring   TYPE xstring,
      lw_jobinfo  TYPE ssfcrescl.

DATA: t_info       TYPE ZT_INFO,
      lw_info       LIKE LINE OF t_info,
      t_saldo       TYPE ZSALTCC,
      lw_saldo       LIKE LINE OF t_saldo,
      t_documento  TYPE ztdocumento,
      lw_documento LIKE LINE OF t_documento.

og_grid->get_selected_rows(
     IMPORTING
       et_index_rows = tl_index_rows ).

IF tl_index_rows[] IS NOT INITIAL.
    tl_alv[] = tg_alv[].
    LOOP AT tl_index_rows INTO wl_index_rows.
      READ TABLE tg_alv INTO wl_alv INDEX wl_index_rows-index.
      IF sy-subrc IS INITIAL.
        IF wl_alv-semaforo = '@S_TL_Y@' OR wl_alv-semaforo = '@S_TL_R@'.
          MESSAGE 'Não e possível imprimir relatorio de Saldo 0' TYPE 'I'.
          RETURN.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ELSE.
    MESSAGE 'Selecione ao menos uma linha' TYPE 'E'.
  ENDIF.




CONSTANTS: c_nome_formulario TYPE tdsfname VALUE 'ZSMARTFORMS_ABAP_ALN037'.


lw_info-inscricao = wl_alv-id_cadastro.
lw_info-nome      = wl_alv-nome.
lw_info-telefone  = wl_alv-telefone.
lw_info-email     = wl_alv-e_mail.
lw_info-endereco  = wl_alv-endereco.
APPEND lw_info TO t_info.
CLEAR: lw_info.

lw_saldo-saldo         = wl_alv-saldo.
lw_saldo-limite        = wl_alv-limite.
lw_saldo-limite_total  = wl_alv-limite_total.
APPEND lw_saldo TO t_saldo.
CLEAR: lw_saldo.

CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    formname           = c_nome_formulario
  IMPORTING
    fm_name            = lv_fm_name
  EXCEPTIONS
    no_form            = 1
    no_function_module = 2
    OTHERS             = 3.


lw_control-no_dialog = 'X'.
lw_control-preview = 'X'.
lw_output-tddest = 'LOCL'.
lw_output-tdprinter = 'LOCL'.



CALL FUNCTION lv_fm_name
  EXPORTING
    control_parameters = lw_control
    output_options     = lw_output
    user_settings      = ''
  TABLES
    t_documento        = t_documento
    t_info             = t_info
    t_saldo            = t_saldo
  EXCEPTIONS
    formatting_error   = 1
    internal_error     = 2
    send_error         = 3
    user_canceled      = 4
    OTHERS             = 5.
ENDFORM.