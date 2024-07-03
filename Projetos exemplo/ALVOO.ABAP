
*&---------------------------------------------------------------------*
REPORT ZABAP_ALN037_14.

TABLES: ZTABAP_ALN037_41.

  TYPES: BEGIN OF tp_alv,
          id_filme         TYPE ZTABAP_ALN037_41-id_filme,
          Nome_Filme       TYPE ZTABAP_ALN037_41-nome_filme,
          Data_lancamento  TYPE ZTABAP_ALN037_41-ano_filme,
          genero           TYPE ZTABAP_ALN037_41-genero,
        END OF tp_alv,

       BEGIN OF tp_filmes,
         id_filme         TYPE ZTABAP_ALN037_41-id_filme,
         Nome_Filme       TYPE ZTABAP_ALN037_41-nome_filme,
         Data_lancamento  TYPE ZTABAP_ALN037_41-ano_filme,
         genero           TYPE ZTABAP_ALN037_41-genero,
       END OF tp_filmes.


DATA: tg_filmes       TYPE TABLE OF tp_filmes,
      tg_alv          TYPE TABLE OF tp_alv,
      tg_fieldcatalog TYPE lvc_t_fcat,
      ls_exclude TYPE ui_func,
      pt_exclude TYPE ui_functions.

DATA: og_grid TYPE REF TO cl_gui_alv_grid.

SELECTION-SCREEN BEGIN OF LINE.

  SELECTION-SCREEN POSITION 10.
  PARAMETERS : rb_1  RADIOBUTTON GROUP r1 USER-COMMAND USE_UP DEFAULT 'X'.
  SELECTION-SCREEN COMMENT 12(8) INS." Insert

  SELECTION-SCREEN POSITION 32.
  PARAMETERS : rb_2 RADIOBUTTON GROUP r1.
  SELECTION-SCREEN COMMENT 34(8) MOD." Update

  SELECTION-SCREEN POSITION 53.
  PARAMETERS : rb_3 RADIOBUTTON GROUP r1.
  SELECTION-SCREEN COMMENT 55(8) DEL." delete
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_id       TYPE ZTABAP_ALN037_41-id_filme MODIF ID INS,
              p_Filme    TYPE ZTABAP_ALN037_41-nome_filme  MODIF ID INS,
              p_Ano      TYPE ZTABAP_ALN037_41-ano_filme MODIF ID INS,
              p_Genero   TYPE ZTABAP_ALN037_41-genero MODIF ID INS.
  SELECT-OPTIONS: s_Filme FOR  ZTABAP_ALN037_41-nome_filme NO INTERVALS MODIF ID UPD.


SELECTION-SCREEN END OF BLOCK b1.



INITIALIZATION.
  INS = TEXT-f01. " Insert
  MOD = TEXT-f02. " Update
  DEL = TEXT-f03. " Delete


AT SELECTION-SCREEN OUTPUT.

LOOP AT SCREEN.
   CASE abap_true.
   	WHEN rb_1.
      IF screen-group1 = 'UPD'.
          screen-active = '0'.
          MODIFY SCREEN.
          CALL FUNCTION 'NUMBER_GET_NEXT' "Função de auto incremento da coluna ID"
            EXPORTING
              nr_range_nr             = '01'
              object                  = 'ZRANGE' "object criado na snro"
              quantity                = '1'
            IMPORTING
              number                  = p_id
            EXCEPTIONS
              interval_not_found      = 1
              number_range_not_intern = 2
              object_not_found        = 3
              quantity_is_0           = 4
              quantity_is_not_1       = 5
              interval_overflow       = 6
              buffer_overflow         = 7
              OTHERS                  = 8.
             ENDIF.
             IF screen-name = 'P_ID'.
                 screen-input = 0.
                 MODIFY SCREEN.
              ENDIF.
   	WHEN rb_2.
      IF screen-group1 = 'INS'.
      screen-active = '0'.
      MODIFY SCREEN.
      ENDIF.
        CASE SY-UCOMM.
          WHEN 'ENTER'.
            MESSAGE 'teste' type 'I'.
        ENDCASE.
   	WHEN rb_3.
      IF screen-group1 = 'INS'
      OR screen-group1 = 'UPD'.
      screen-active = '0'.
      MODIFY SCREEN.
       ls_exclude = cl_gui_alv_grid=>MC_FC_LOC_INSERT_ROW.
       APPEND ls_exclude TO pt_exclude.
      PERFORM ALVVIEW.
      ENDIF.
   ENDCASE.
ENDLOOP.


START-OF-SELECTION.

LOOP AT SCREEN.
  CASE abap_true.
    WHEN rb_1.
         ZTABAP_ALN037_41-id_filme = p_id.
         IF p_Filme = ''.
           MESSAGE 'Digite um nome de Filme' TYPE 'I'.
           RETURN.
           ELSE.
          ZTABAP_ALN037_41-nome_filme = p_Filme.
         ENDIF.
         IF p_Ano = ''.
           MESSAGE 'Digite o ano de lançamento do Filme' TYPE 'I'.
           RETURN.
           ELSE.
           ZTABAP_ALN037_41-ano_filme = p_Ano.
         ENDIF.
         IF p_Genero = ''.
           MESSAGE 'Digite o genero do Filme' TYPE 'I'.
           RETURN.
           ELSE.
           ZTABAP_ALN037_41-genero = p_Genero.
         ENDIF.
         MODIFY ztabap_aln037_41 FROM ztabap_aln037_41.
         COMMIT WORK.
         SET SCREEN 0.
    WHEN rb_2.
             ls_exclude = cl_gui_alv_grid=>MC_FC_LOC_DELETE_ROW.
             APPEND ls_exclude TO pt_exclude.
      PERFORM ALVFILTER.
      IF SY-UCOMM EQ 'SALVE'.
        MESSAGE 'oi' TYPE 'I'.
      ENDIF.
     WHEN rb_3.

  ENDCASE.
ENDLOOP.

FORM ALVFILTER.
  PERFORM f_seleciona_filtro.
  PERFORM f_trata_filtro.

  IF tg_alv[] IS NOT INITIAL.
    CALL SCREEN 9001.
  ENDIF.
ENDFORM.

FORM ALVVIEW.
  PERFORM f_seleciona_dados.
  PERFORM f_trata_dados.

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
    CREATE OBJECT og_grid "Criação do objeto que exibirá o alv
      EXPORTING
        i_parent = cl_gui_container=>default_screen.

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
      CALL TRANSACTION 'ZABAP_ALN037_14'.
      LEAVE SCREEN.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'SALVE'.
      PERFORM EDITATABLE.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command INPUT.
  IF sy-ucomm EQ 'CANCEL'.
    LEAVE SCREEN.
    CALL TRANSACTION 'ZABAP_ALN037_14'.
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
FORM f_seleciona_filtro.

 SELECT id_filme
        nome_filme
        ano_filme
        genero
   FROM ZTABAP_ALN037_41
   INTO table tg_filmes
   WHERE ZTABAP_ALN037_41~nome_filme IN s_Filme.
ENDFORM.


FORM f_seleciona_dados.

 SELECT id_filme
        nome_filme
        ano_filme
        genero
   FROM ZTABAP_ALN037_41
   INTO table tg_filmes.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form f_trata_dados
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_trata_filtro.
 DATA: wl_filmes  TYPE tp_filmes,
        wl_alv   TYPE tp_alv.

  LOOP AT tg_filmes INTO wl_filmes.
    CLEAR: wl_alv.
    MOVE-CORRESPONDING wl_filmes TO wl_alv.
    APPEND wl_alv TO tg_alv.
  ENDLOOP.
ENDFORM.


FORM f_trata_dados.
 DATA: wl_filmes  TYPE tp_filmes,
        wl_alv   TYPE tp_alv.

  LOOP AT tg_filmes INTO wl_filmes.
    CLEAR: wl_alv.
    MOVE-CORRESPONDING wl_filmes TO wl_alv.
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
        wl_variant TYPE disvariant.

  IF tg_fieldcatalog[] IS INITIAL.
    PERFORM f_cria_fieldcatalog USING: 'TG_ALV' 'ID_FILME' 'id_filme'                      '' '',
                                       'TG_ALV' 'NOME_FILME' 'Nome do Filme:'              'X' '',
                                       'TG_ALV' 'DATA_LANCAMENTO' 'Data de lançamento'     'X' '',
                                       'TG_ALV' 'GENERO' 'Genero'                          'X' ''.

  ENDIF.

  wl_layout-zebra      = 'X'.
  wl_layout-cwidth_opt = 'X'.
  wl_layout-grid_title = 'Exercicio ALV'.
  wl_variant-report    = sy-repid.

  CALL METHOD og_grid->set_table_for_first_display
    EXPORTING
      is_layout       = wl_layout
      is_variant      = wl_variant
      i_save          = 'A'
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
          vp_dosum         TYPE lvc_s_fcat-do_sum.

  DATA: wl_fieldcatalog TYPE lvc_s_fcat.

  wl_fieldcatalog-tabname      = vp_tabname.
  wl_fieldcatalog-fieldname    = vp_fieldname.
  wl_fieldcatalog-reptext      = vp_reptext.
  wl_fieldcatalog-edit         = vp_edit.
  wl_fieldcatalog-do_sum       = vp_dosum.

  APPEND wl_fieldcatalog TO tg_fieldcatalog.
ENDFORM.

FORM EDITATABLE.
  DATA:  wl_alv   TYPE tp_alv.

  LOOP AT tg_alv INTO wl_alv.
    BREAK-POINT.
  ENDLOOP.
ENDFORM.