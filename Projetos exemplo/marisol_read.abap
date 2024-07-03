*&---------------------------------------------------------------------*
*& Report  ZPLM_ERP_021
*
* Autor      : Gilson Bormann Arruda
* Consultoria: CASTGROUP
* Descrição  : Relatório de Composição de produto acabado
* DATA: 25/02/2022
*&
*&---------------------------------------------------------------------*

REPORT  zplm_erp_021.
TABLES: mara,
        j_3amsea.

*---------------------------------------------------------------------*
*Declarações Globais de variáveis e types tp_t_tabelas internas
*---------------------------------------------------------------------*

TYPE-POOLS slis.

TYPES: BEGIN OF tp_t_alv,
       matnr           TYPE mara-matnr,
       maktx           TYPE makt-maktx,
       j_3asean        TYPE j_3amsea-j_3asean,
       text            TYPE j_3aseant-text,
       composicao(200) TYPE c,
       END OF tp_t_alv,

       BEGIN OF tp_t_dados,
       matnr           TYPE mara-matnr,
       maktx           TYPE makt-maktx,
       j_3asean        TYPE j_3amsea-j_3asean,
       j_3asize        TYPE j_3amsea-j_3asize,
       text            TYPE j_3aseant-text,
       composicao(200) TYPE c,
       END OF tp_t_dados,

       BEGIN OF tp_t_material,
       matnr           TYPE mara-matnr,
       maktx           TYPE makt-maktx,
       END OF tp_t_material,

       BEGIN OF tp_t_3amsea,
       matnr               TYPE mara-matnr,
       j_3asean            TYPE j_3amsea-j_3asean,
       END OF tp_t_3amsea,

       BEGIN OF tp_t_3aseant,
       j_3asean            TYPE j_3amsea-j_3asean,
       text                TYPE j_3aseant-text,
       END OF tp_t_3aseant.

FIELD-SYMBOLS: <fl_item> TYPE tp_t_material.

DATA: tg_alv          TYPE STANDARD TABLE OF tp_t_alv,
      tg_material     TYPE STANDARD TABLE OF tp_t_material,
      tg_3amsea       TYPE TABLE OF tp_t_3amsea,
      tg_3aseant      TYPE TABLE OF tp_t_3aseant,
      tg_dados        TYPE STANDARD TABLE OF tp_t_dados,
      tg_fieldcatalog TYPE lvc_t_fcat,
      tl_texto        TYPE STANDARD TABLE OF tline,
      wa_alv          TYPE tp_t_alv,
      wa_material     TYPE tp_t_material,
      wa_3amsea       TYPE tp_t_3amsea,
      wa_3aseant      TYPE tp_t_3aseant,
      wa_dados        TYPE tp_t_dados,
      wa_texto        TYPE tline,
      vl_comps        TYPE tp_t_alv-composicao,
      vl_material     TYPE thead-tdname,
      vl_descricao    TYPE tp_t_alv-composicao,
      og_grid         TYPE REF TO cl_gui_alv_grid,
      ls_exclude      TYPE ui_func,
      pt_exclude      TYPE ui_functions.

*---------------------------------------------------------------------*
* Tela de seleção
*---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK bl01 WITH FRAME.
SELECT-OPTIONS: s_matnr   FOR mara-matnr        NO INTERVALS,
                s_est     FOR j_3amsea-j_3asean NO INTERVALS.
SELECTION-SCREEN END OF BLOCK bl01.

SELECTION-SCREEN BEGIN OF BLOCK bl02 WITH FRAME.
PARAMETERS: rb_comp  RADIOBUTTON GROUP rb01 DEFAULT 'X',
            rb_scomp RADIOBUTTON GROUP rb01,
            rb_ambos RADIOBUTTON GROUP rb01.
SELECTION-SCREEN END OF BLOCK bl02.


*---------------------------------------------------------------------*
*Inicio da seleção
*---------------------------------------------------------------------*
START-OF-SELECTION.

  IF s_est IS NOT INITIAL.

    SELECT j_3amsea~matnr
           makt~maktx
    INTO CORRESPONDING FIELDS OF TABLE tg_material
    FROM j_3amsea AS j_3amsea
    INNER JOIN makt AS makt
    ON j_3amsea~matnr = makt~matnr
    AND spras = 'P'
    WHERE j_3amsea~j_3asean IN s_est
    AND   j_3amsea~j_4krcat = ''
    AND   j_3amsea~matnr IN s_matnr.

    SORT tg_material BY matnr ASCENDING.
    DELETE ADJACENT DUPLICATES FROM tg_material COMPARING matnr.

    SELECT matnr
           j_3asean
      FROM j_3amsea
      INTO CORRESPONDING FIELDS OF TABLE tg_3amsea
      FOR ALL ENTRIES IN tg_material
      WHERE matnr = tg_material-matnr
      AND j_4krcat = ''
      AND j_3asize = ''.

    SELECT j_3asean
           text
          FROM j_3aseant
          INTO TABLE tg_3aseant
          FOR ALL ENTRIES IN tg_3amsea
          WHERE j_3asean = tg_3amsea-j_3asean
          AND /afs/collection = ''
          AND /afs/theme = ''
          AND spras = 'P'.

  ELSE.
    SELECT mara~matnr
           makt~maktx
      INTO CORRESPONDING FIELDS OF TABLE tg_material
      FROM mara AS mara
      INNER JOIN makt AS makt
      ON mara~matnr = makt~matnr
      AND spras = 'P'
      WHERE mara~matnr IN s_matnr.

    SORT tg_material BY matnr ASCENDING.
    DELETE ADJACENT DUPLICATES FROM tg_material COMPARING matnr.

    SELECT matnr
           j_3asean
    FROM j_3amsea
    INTO CORRESPONDING FIELDS OF TABLE tg_3amsea
    FOR ALL ENTRIES IN tg_material
    WHERE matnr = tg_material-matnr
    AND j_4krcat = ''
    AND j_3asize = ''.

    SELECT j_3asean
           text
          FROM j_3aseant
          INTO TABLE tg_3aseant
          FOR ALL ENTRIES IN tg_3amsea
          WHERE j_3asean = tg_3amsea-j_3asean
          AND /afs/collection = ''
          AND /afs/theme = ''
          AND spras = 'P'.

  ENDIF.

  IF tg_material[] IS NOT INITIAL.
    LOOP AT tg_material ASSIGNING <fl_item>.
      vl_material    = <fl_item>-matnr.
      wa_dados-matnr = <fl_item>-matnr.
      wa_dados-maktx = <fl_item>-maktx.

      READ TABLE tg_3amsea INTO wa_3amsea
         WITH KEY matnr = <fl_item>-matnr
                           BINARY SEARCH.
         IF sy-subrc IS INITIAL .
          READ TABLE tg_3aseant INTO wa_3aseant
           WITH KEY  J_3ASEAN = wa_3amsea-j_3asean.

           wa_dados-j_3asean = wa_3aseant-j_3asean.
           wa_dados-text     = wa_3aseant-text.
         ENDIF.


      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          client                  = sy-mandt
          id                      = 'GRUN'
          language                = sy-langu
          name                    = vl_material
          object                  = 'MATERIAL'
          archive_handle          = 0
          local_cat               = ' '
        TABLES
          lines                   = tl_texto
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.

      IF sy-subrc = 0.
        LOOP AT tl_texto INTO wa_texto.
          IF wa_texto-tdline = ''.
            wa_dados-composicao = '*'.
          ELSE.
            wa_dados-composicao = wa_texto-tdline.
          ENDIF.
          APPEND wa_dados TO tg_dados.
          wa_dados-j_3asean      = wa_3aseant-j_3asean.
          wa_dados-matnr         =  ''.
          wa_dados-maktx         =  ''.
        ENDLOOP.
      ELSE.
        wa_dados-composicao = ''.
        APPEND wa_dados TO tg_dados.
      ENDIF.

    ENDLOOP.
  ENDIF.

  IF rb_comp = 'X'.
    LOOP AT tg_dados INTO wa_dados
          WHERE composicao NE ''..
      wa_alv-matnr      =  wa_dados-matnr.
      wa_alv-maktx      =  wa_dados-maktx.
      wa_alv-j_3asean   =  wa_dados-j_3asean.
      wa_alv-text       =  wa_dados-text.
      wa_alv-composicao =  wa_dados-composicao.

      APPEND wa_alv TO tg_alv.
    ENDLOOP.
  ELSEIF rb_scomp = 'X'.
    LOOP AT tg_dados INTO wa_dados
         WHERE composicao EQ ''.
      wa_alv-matnr      =  wa_dados-matnr.
      wa_alv-maktx      =  wa_dados-maktx.
      wa_alv-j_3asean   =  wa_dados-j_3asean.
      wa_alv-text       =  wa_dados-text.

      APPEND wa_alv TO tg_alv.
    ENDLOOP.

  ELSE.
    LOOP AT tg_dados INTO wa_dados.
      wa_alv-matnr      =  wa_dados-matnr.
      wa_alv-maktx      =  wa_dados-maktx.
      wa_alv-j_3asean   =  wa_dados-j_3asean.
      wa_alv-text       =  wa_dados-text.
      wa_alv-composicao =  wa_dados-composicao.

      APPEND wa_alv TO tg_alv.
    ENDLOOP.

  ENDIF.

*---------------------------------------------------------------------*
*Inicio da chamado do ALVOO
*---------------------------------------------------------------------*

  IF tg_alv[] IS NOT INITIAL.
    CALL SCREEN 9001.
  ELSE.
    MESSAGE 'Sem dados para o filtro definido' TYPE 'I'.
  ENDIF.

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
ENDMODULE.                    "status_9001 OUTPUT
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
ENDMODULE.                    "user_command_9001 INPUT
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
ENDMODULE.                    "exit_command INPUT
*&---------------------------------------------------------------------*
*&      Form  F_EXECUTA_ALV
*&---------------------------------------------------------------------*
FORM f_exibe_alv.
  DATA: wl_layout  TYPE lvc_s_layo,
        wl_variant TYPE disvariant.

  IF tg_fieldcatalog[] IS INITIAL.
    PERFORM f_cria_fieldcatalog USING: 'TG_ALV' 'MATNR     ' 'Material'                  '' '' 'X',
                                       'TG_ALV' 'MAKTX     ' 'Desc do material'          '' '' '',
                                       'TG_ALV' 'J_3ASEAN  ' 'Estação'                   '' '' '',
                                       'TG_ALV' 'TEXT      ' 'Desc da estação'           '' '' '',
                                       'TG_ALV' 'COMPOSICAO' 'Composição'                '' '' ''.
  ENDIF.

  wl_layout-zebra      = 'X'.
  wl_layout-cwidth_opt = 'X'.
  wl_layout-grid_title = 'Composição de Material'.
  wl_variant-report    = sy-repid.

  PERFORM excluirbotoes.

  CALL METHOD og_grid->set_table_for_first_display
    EXPORTING
      is_layout       = wl_layout
      is_variant      = wl_variant
      i_save          = 'A'
    CHANGING
      it_outtab       = tg_alv
      it_fieldcatalog = tg_fieldcatalog.

ENDFORM.                    "EXECUTA_ALV

*&---------------------------------------------------------------------*
*&      Form  f_cria_fieldcatalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->VP_TABNAME    text
*      -->VP_FIELDNAME  text
*      -->VP_REPTEXT    text
*      -->VP_EDIT       text
*      -->VP_DOSUM      text
*      -->VP_NO_ZERO    text
*----------------------------------------------------------------------*
FORM f_cria_fieldcatalog
    USING vp_tabname       TYPE lvc_s_fcat-tabname
          vp_fieldname     TYPE lvc_s_fcat-fieldname
          vp_reptext       TYPE lvc_s_fcat-scrtext_m
          vp_edit          TYPE lvc_s_fcat-edit
          vp_dosum         TYPE lvc_s_fcat-do_sum
          vp_no_zero       TYPE lvc_s_fcat-no_zero.

  DATA: wl_fieldcatalog TYPE lvc_s_fcat.

  wl_fieldcatalog-tabname      = vp_tabname.
  wl_fieldcatalog-fieldname    = vp_fieldname.
  wl_fieldcatalog-reptext      = vp_reptext.
  wl_fieldcatalog-edit         = vp_edit.
  wl_fieldcatalog-do_sum       = vp_dosum.
  wl_fieldcatalog-no_zero      = vp_no_zero.

  APPEND wl_fieldcatalog TO tg_fieldcatalog.
ENDFORM.                    "f_cria_fieldcatalog

*&---------------------------------------------------------------------*
*&      Form  EXCLUIRBOTOES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM excluirbotoes.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO pt_exclude.

ENDFORM.                    "EXCLUIRBOTOES