*&---------------------------------------------------------------------*
*& Report Z_TESTE_GILSON
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_TESTE_GILSON.

TYPE-POOLS: bcwbn.

TABLES: cwbnthead.

DATA: LT_TADIR TYPE TABLE OF TADIR,
      t_fieldcat  TYPE TABLE OF slis_fieldcat_alv,
      wa_fieldcat TYPE          slis_fieldcat_alv,
      wa_layout   TYPE          slis_layout_alv,
      lv_repid    TYPE          sy-repid.


TYPES: BEGIN OF ty_controle,
         numm               TYPE cwbntnumm,
         numm_s             TYPE cwbntnumm,
         text               TYPE cwbntstxt-stext,
         status             TYPE cwbntcust-prstatus,
         manual             TYPE c,
         vista,
         snote,
         descri_status      TYPE string,
         color(4)           TYPE c,
       END OF   ty_controle.

DATA t_notes            TYPE TABLE OF bcwbn_note.
DATA wl_cwbnthead       TYPE cwbnthead.
DATA wl_cwbnthead_dep   TYPE cwbnthead.
DATA t_cwbnthead        TYPE TABLE OF cwbnthead.
DATA t_controle         TYPE TABLE OF ty_controle.
DATA t_saida            TYPE TABLE OF ty_controle.
DATA l_subrc            TYPE sy-subrc.
DATA ev_status          TYPE bcwbn_cinst_status.
DATA ev_overwritten     TYPE bcwbn_overwritten.
DATA l_status           TYPE cwbntcust-prstatus .
DATA r_aplicavel        TYPE RANGE OF cwbntcust-prstatus.
DATA l_tabix_ins        TYPE sy-tabix.
DATA v_oculta.

SELECT-OPTIONS s_note FOR cwbnthead-numm NO INTERVALS.
PARAMETERS p_ocult AS CHECKBOX.

INITIALIZATION.

  " Pode ser implementado
  APPEND 'IEQN' TO r_aplicavel.
  " Implementado de modo incompleto
  APPEND 'IEQU' TO r_aplicavel.
  " Versão antiga implementada
  APPEND 'IEQV' TO r_aplicavel.

AT USER-COMMAND.

  CASE sy-ucomm.
    WHEN 'BACK'.
      LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
    WHEN 'SELE'.
      PERFORM f_view_note_detail.
    WHEN 'SNOTE'.
      PERFORM f_view_snote.
  ENDCASE.

START-OF-SELECTION.

  SET PF-STATUS 'LIST'.

  v_oculta = p_ocult.

  " Efetua a seleção da nota... caso não encontre, faz o download dela...
  LOOP AT s_note.

    CLEAR: wl_cwbnthead, l_status.
    PERFORM f_get_cwbnthead USING s_note-low CHANGING wl_cwbnthead l_status.
    CHECK wl_cwbnthead IS NOT INITIAL.

    DATA o_note TYPE bcwbn_note.

    MOVE-CORRESPONDING wl_cwbnthead TO o_note-key.

    CLEAR l_subrc.
    PERFORM f_read_note CHANGING o_note l_subrc.
    IF l_subrc IS NOT INITIAL.
      CONTINUE.
    ENDIF.

    READ TABLE t_controle TRANSPORTING NO FIELDS
    WITH KEY numm = wl_cwbnthead-numm BINARY SEARCH.
    IF sy-subrc IS NOT INITIAL.
      INSERT INITIAL LINE INTO t_controle INDEX sy-tabix ASSIGNING FIELD-SYMBOL(<controle>).

      <controle>-numm = o_note-key-numm.

      IF l_status IN r_aplicavel.
        PERFORM f_recursivo_corr_ins CHANGING o_note <controle> .
      ENDIF.

      <controle>-text = o_note-stext.
      <controle>-status = l_status.

    ENDIF.

    APPEND o_note TO t_notes.
    APPEND INITIAL LINE TO t_saida ASSIGNING FIELD-SYMBOL(<saida>).
    <saida> = <controle>.
    <saida>-manual = o_note-post_proc_required.

  ENDLOOP.

  SORT t_notes BY key-numm.

  PERFORM f_criafieldcat.
  PERFORM f_exibe_alv.

*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD_NOTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_download_note  USING    p_note.

  DATA rl_notenr TYPE RANGE OF cwbnthead-numm.
  DATA wl_notenr LIKE LINE OF rl_notenr.

  wl_notenr-sign   = 'I'.
  wl_notenr-option = 'EQ'.
  wl_notenr-low    = p_note.
  APPEND wl_notenr TO rl_notenr.

  SUBMIT scwn_note_download WITH p_notenr IN rl_notenr AND RETURN.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_GET_CWBNTHEAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_cwbnthead  USING    p_note
                      CHANGING pw_cwbnthead TYPE cwbnthead
                               p_status.

  DO 2 TIMES.

    SELECT * UP TO 1 ROWS
      FROM cwbnthead
      INTO pw_cwbnthead
      WHERE numm EQ p_note
      ORDER BY versno DESCENDING.
    ENDSELECT.
    IF sy-subrc IS INITIAL.
      EXIT.
    ENDIF.

    PERFORM f_download_note USING p_note.

  ENDDO.

  IF pw_cwbnthead IS NOT INITIAL.
    SELECT SINGLE prstatus FROM cwbntcust INTO p_status WHERE numm = p_note.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_READ_NOTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_read_note  CHANGING po_note TYPE bcwbn_note
                           l_subrc TYPE sy-subrc.

  CALL FUNCTION 'SCWB_NOTE_READ'
    EXPORTING
      iv_read_attributes          = 'X'
      iv_read_short_text          = 'X'
      iv_read_all_texts           = 'X'
      iv_read_validity            = 'X'
      iv_read_corr_instructions   = 'X'
      iv_read_customer_logfile    = 'X'
      iv_use_fallback_languages   = 'X'
      iv_read_loghndl             = 'X'
      iv_read_fixes               = 'X'
      iv_read_customer_attributes = 'X'
      iv_read_read_by_user        = 'X'
      iv_read_sol_mgr_reference   = 'X'
      iv_read_sap_status          = 'X'
    CHANGING
      cs_note                     = po_note
    EXCEPTIONS
      note_not_found              = 1
      language_not_found          = 2
      unreadable_text_format      = 3
      corr_instruction_not_found  = 4
      OTHERS                      = 5.

  l_subrc = sy-subrc.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_READ_CINST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_<CORR_INSTRUCTIONS>  text
*----------------------------------------------------------------------*
FORM f_read_cinst  CHANGING pw_corr_instructions TYPE bcwbn_corr_instruction.

  CALL FUNCTION 'SCWB_CINST_READ'
    EXPORTING
      iv_read_header                = 'X'
      iv_read_deltas                = 'X'
      iv_read_validity              = 'X'
      iv_read_dependencies          = 'X'
      iv_read_successors            = 'X'
      iv_read_fixes                 = 'X'
      iv_read_related_note          = 'X'
      iv_read_related_note_versions = 'X'
      iv_read_object_list           = 'X'
      iv_read_cinstattr             = 'X'
    CHANGING
      cs_corr_instruction           = pw_corr_instructions
    EXCEPTIONS
      corr_instruction_not_found    = 1
      deltas_unreadable             = 2
      unknown_delta_format          = 3
      OTHERS                        = 4.

FIELD-SYMBOLS: <fl_object_list> TYPE bcwbn_object_key_with_tadir,
               <FL_LT_TADIR>    TYPE TADIR.

LOOP AT pw_corr_instructions-object_list ASSIGNING <fl_object_list>.
  APPEND INITIAL LINE TO LT_TADIR ASSIGNING <FL_LT_TADIR>.

<FL_LT_TADIR> = <fl_object_list>-tadir_key.

ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_GET_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_status  CHANGING pw_corr_instructions p_status p_overwritten.

  CLEAR: p_status, p_overwritten.

  CALL FUNCTION 'SCWB_CINST_GET_STATUS'
    IMPORTING
      ev_status                  = p_status
      ev_overwritten             = p_overwritten
    CHANGING
      cs_corr_instruction        = pw_corr_instructions
    EXCEPTIONS
      not_found                  = 1
      inconsistent_delivery_data = 2
      undefined                  = 3
      OTHERS                     = 4.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_RECURSIVO_CORR_INS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_recursivo_corr_ins  "USING    p_step
                           CHANGING po_note     TYPE bcwbn_note
                                    pw_controle  TYPE ty_controle.

  DATA l_status       TYPE cwbntcust-prstatus .
  DATA l_tabix_ins    TYPE sy-tabix.

  SORT po_note-corr_instructions BY note_key-numm.
  LOOP AT po_note-corr_instructions ASSIGNING FIELD-SYMBOL(<corr_instructions>).

    DATA(l_tabix) = sy-tabix.

    PERFORM f_read_cinst CHANGING <corr_instructions>.
    PERFORM f_get_status CHANGING <corr_instructions> ev_status ev_overwritten.

    CASE ev_status.
      WHEN 'I'." gc_implemented_completely  TYPE bcwbn_cinst_status VALUE 'I',
        DELETE po_note-corr_instructions INDEX l_tabix.
      WHEN 'O'." gc_obsolete                TYPE bcwbn_cinst_status VALUE 'O',
        DELETE po_note-corr_instructions INDEX l_tabix.
      WHEN 'R'." gc_reimplementation_needed TYPE bcwbn_cinst_status VALUE 'R',
        DELETE po_note-corr_instructions INDEX l_tabix.
      WHEN 'D'." gc_deimplementation_needed TYPE bcwbn_cinst_status VALUE 'D'.
        DELETE po_note-corr_instructions INDEX l_tabix.
      WHEN 'P'." gc_implementation_possible TYPE bcwbn_cinst_status VALUE 'P',

        IF <corr_instructions>-manual_activity IS NOT INITIAL.
          pw_controle-manual = 'X'.
        ENDIF.

        LOOP AT <corr_instructions>-dependencies ASSIGNING FIELD-SYMBOL(<dependencia>).

          READ TABLE t_controle TRANSPORTING NO FIELDS
          WITH KEY numm = <dependencia>-ntkey-numm BINARY SEARCH.
          CHECK sy-subrc IS NOT INITIAL.

          DATA(l_tabix_aux) = sy-tabix.

          CLEAR wl_cwbnthead_dep.
          PERFORM f_get_cwbnthead USING <dependencia>-ntkey-numm CHANGING wl_cwbnthead_dep l_status.

          IF wl_cwbnthead_dep IS NOT INITIAL.

            DATA o_note_dep TYPE bcwbn_note.

            MOVE-CORRESPONDING wl_cwbnthead_dep TO o_note_dep-key.

            CLEAR l_subrc.
            PERFORM f_read_note CHANGING o_note_dep l_subrc.
            IF l_subrc IS NOT INITIAL.
              CONTINUE.
            ENDIF.

            READ TABLE t_controle TRANSPORTING NO FIELDS
            WITH KEY numm = o_note_dep-key-numm BINARY SEARCH.
            IF sy-subrc IS NOT INITIAL.
              INSERT INITIAL LINE INTO t_controle INDEX sy-tabix ASSIGNING FIELD-SYMBOL(<controle>).

              <controle>-numm   = o_note_dep-key-numm.
              <controle>-numm_s = po_note-key-numm.
              <controle>-text = o_note_dep-stext.

              IF l_status IN r_aplicavel.
                PERFORM f_recursivo_corr_ins CHANGING o_note_dep <controle>.
              ENDIF.

              IF v_oculta IS INITIAL OR ( v_oculta IS NOT INITIAL AND l_status IN r_aplicavel ).

                <controle>-status = l_status.
                APPEND INITIAL LINE TO t_saida ASSIGNING FIELD-SYMBOL(<saida>).
                <saida> = <controle>.

              ENDIF.

            ENDIF.

          ENDIF.

          APPEND o_note_dep TO t_notes.

        ENDLOOP.

    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_VIEW_NOTE_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_view_note_detail .

  DATA(l_linha) = sy-lilli - 1.

  READ TABLE t_saida ASSIGNING FIELD-SYMBOL(<saida>) INDEX l_linha.
  CHECK sy-subrc IS INITIAL.

  READ TABLE t_notes INTO DATA(ol_note) WITH KEY key-numm = <saida>-numm BINARY SEARCH.
  CHECK sy-subrc IS INITIAL.

  DATA l_text TYPE string.
  l_text = ol_note-stext.

  DATA header TYPE thead.

  header-tdspras = sy-langu.

  CALL FUNCTION 'PRINT_TEXT'
    EXPORTING
      device = 'SCREEN'
      dialog = ''
      header = header
    TABLES
      lines  = ol_note-text.

  sy-lsind = 0.
  <saida>-vista = 'X'.
  SET PF-STATUS 'LIST'.

  PERFORM f_criafieldcat.
  PERFORM f_exibe_alv.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_VIEW_SNOTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_view_snote .

  DATA rl_numm TYPE RANGE OF cwbntnumm.
  DATA wl_numm LIKE LINE OF rl_numm.
  DATA(l_linha) = sy-lilli - 1.

  READ TABLE t_saida ASSIGNING FIELD-SYMBOL(<saida>) INDEX l_linha.
  CHECK sy-subrc IS INITIAL.

  wl_numm-sign   = 'I'.
  wl_numm-option = 'EQ'.
  wl_numm-low    = <saida>-numm.
  APPEND wl_numm TO rl_numm.

  SUBMIT scwn_note_browser WITH numm IN rl_numm AND RETURN.

  SELECT SINGLE prstatus FROM cwbntcust INTO <saida>-status WHERE numm = <saida>-numm.

  sy-lsind = 0.
  <saida>-snote = 'X'.
  SET PF-STATUS 'LIST'.

  PERFORM f_criafieldcat.
  PERFORM f_exibe_alv.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CRIAFIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_criafieldcat .

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'NUMM'.
wa_fieldcat-seltext_m = 'Note'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'NUMM_S'.
wa_fieldcat-seltext_m = 'Pré_requisito'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'TEXT'.
wa_fieldcat-seltext_m = 'Descrição'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'DESCRI_STATUS'.
wa_fieldcat-seltext_m = 'status'.
APPEND wa_fieldcat TO t_fieldcat.

CLEAR wa_fieldcat.
wa_fieldcat-fieldname = 'MANUAL'.
wa_fieldcat-seltext_m = 'Atividade_manual'.
APPEND wa_fieldcat TO t_fieldcat.

PERFORM f_crialayout.

ENDFORM.

FORM f_crialayout.

wa_layout-expand_all        = 'X'.
wa_layout-colwidth_optimize = 'X'.
wa_layout-zebra             = 'X'.
wa_layout-info_fieldname    = 'COLOR'.

lv_repid = sy-repid.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_EXIBE_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_exibe_alv .

LOOP AT t_saida ASSIGNING FIELD-SYMBOL(<fs_saida>).

  CASE <fs_saida>-status.
    WHEN '-'.
      <fs_saida>-descri_status = 'Cannot be implemented'.
      <fs_saida>-color         = 'C610'.
    WHEN 'O'.
       <fs_saida>-descri_status = 'Obsolete'.
       <fs_saida>-color         = 'C610'.
    WHEN 'E'.
       <fs_saida>-descri_status = 'Completely implemented'.
       <fs_saida>-color         = 'C310'.
    WHEN 'N'.
       <fs_saida>-descri_status = 'Can be implemented'.
       <fs_saida>-color         = 'C510'.
    WHEN OTHERS.
  ENDCASE.

ENDLOOP.

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
EXPORTING
i_callback_program = lv_repid
is_layout          = wa_layout
it_fieldcat        = t_fieldcat[]
TABLES
t_outtab           = t_saida
EXCEPTIONS
program_error      = 1
OTHERS             = 2.

ENDFORM.