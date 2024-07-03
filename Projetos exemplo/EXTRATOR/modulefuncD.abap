*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM f_consistir_autorizacao.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM f_busca_scu3.

*&---------------------------------------------------------------------*
*&      Form  F_CONSISTIR_AUTORIZACAO
*&---------------------------------------------------------------------*
FORM f_consistir_autorizacao .

  CHECK sy-sysid NE 'DEV'.
* -- Controle de horário e tipo de processamento (On line/Background)
  CALL FUNCTION 'Z8_VERIFICA_PERMISSAO_COMPL'
    EXPORTING
      x_cprog    = sy-cprog
      x_dtinicio = sy-datum
      x_hrinicio = sy-uzeit
    EXCEPTIONS
      OTHERS     = 1.

  AUTHORITY-CHECK OBJECT 'Z:Z080608'
            ID 'ACTVT' FIELD '16'.

  IF sy-subrc NE 0.
    MESSAGE e163(zp) WITH sy-tcode.
  ENDIF.

ENDFORM.                    " F_CONSISTIR_AUTORIZACAO

*&---------------------------------------------------------------------*
*&      Form  F_BUSCA_SCU3
*&---------------------------------------------------------------------*
FORM f_busca_scu3 .
  DATA: r_data               TYPE REF TO data.

*----------------------------------------------------------------------*
* WORK AREA
*----------------------------------------------------------------------*
  DATA: wl_data  TYPE z080601,
        wl_data2 TYPE z080611.


  FIELD-SYMBOLS: <tl_data> TYPE ANY TABLE,
                 <fs_data> TYPE any,
                 <campo>   TYPE any.



  cl_salv_bs_runtime_info=>set(
  EXPORTING display  = abap_false
            metadata = abap_false
            data     = abap_true ).

  FREE: r_data.
  UNASSIGN: <tl_data>.

  SUBMIT rsvtprot
    WITH cusobj    EQ p_cusobj
    WITH dbeg      EQ p_dbeg
    WITH tbeg      EQ p_tbeg
    WITH dend      EQ p_dend
    WITH tend      EQ p_tend
    WITH objfirst  EQ abap_false
    WITH tabfirst  EQ abap_true
    WITH alv_grid  EQ abap_true
   EXPORTING LIST TO MEMORY
  AND RETURN.
  TRY.

      " Captura resultado
      cl_salv_bs_runtime_info=>get_data_ref( IMPORTING r_data = DATA(rl_data) ).
      ASSIGN rl_data->* TO <tl_data>.

      IF <tl_data> IS ASSIGNED.

        CASE p_cusobj.
          WHEN 'T001B'.
            LOOP AT <tl_data> ASSIGNING <fs_data>.
              CLEAR wl_data.

              ASSIGN COMPONENT 'TLOG_LOGDATE' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data-logdate  = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'TLOG_USERNAME' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data-usnam  = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'TLOG_LOGTIME' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data-logtime   = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'TCODE' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data-tcode  = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'PROGNAME' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data-progname   = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'TLOG_OPTYPE_TEXT' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data-tipmod   = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'TLOG_OPTYPE' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data-tipreg   = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data-bukrs   = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'MKOAR' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data-mkoar  = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'BKONT' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data-bkont   = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'VKONT' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data-vkont   = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'FRYE1' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data-frye1   = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'FRPE1' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data-frpe1   = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'TOYE1' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data-toye1   = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'TOPE1' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data-tope1   = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'FRYE2' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data-frye2   = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'FRPE2' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data-frpe2  = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'TOYE2' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data-toye2   = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'TOPE2' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data-tope2   = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'BRGRU' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data-brgru   = <campo>.
              ENDIF.

              APPEND wl_data TO t_data.
            ENDLOOP.
            MODIFY z080601 FROM TABLE t_data.
            COMMIT WORK AND WAIT.
          WHEN 'T000'.

            LOOP AT <tl_data> ASSIGNING <fs_data>.
              CLEAR wl_data2.
              ASSIGN COMPONENT 'TLOG_LOGDATE' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data2-logdate   = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'TLOG_USERNAME' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data2-usnam   = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'TLOG_LOGTIME' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data2-logtime   = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'TCODE' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data2-tcode   = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'PROGNAME' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data2-progname   = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'TLOG_OPTYPE_TEXT' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data2-tipmod   = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'MANDT' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data2-mandt   = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'MTEXT' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data2-mtext   = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'ORT01' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data2-ort01   = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'MWAER' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data2-mwaer  = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'CCCATEGORY' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data2-cccategory  = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'CCCORACTIV' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data2-cccoractiv  = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'CCNOCLIIND' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data2-ccnocliind  = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'CCCOPYLOCK' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data2-cccopylock  = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'CCNOCASCAD' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data2-ccnocascad  = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'CCSOFTLOCK' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data2-ccsoftlock  = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'CCORIGCONT' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data2-ccorigcont  = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'CCIMAILDIS' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data2-ccimaildis  = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'CCTEMPLOCK' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data2-cctemplock  = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'CHANGEUSER' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data2-changeuser  = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'CHANGEDATE' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data2-changedate  = <campo>.
              ENDIF.

              ASSIGN COMPONENT 'LOGSYS' OF STRUCTURE <fs_data> TO <campo>.
              IF <campo> IS ASSIGNED.
                wl_data2-logsys  = <campo>.
              ENDIF.

              APPEND wl_data2 TO t_data2.
            ENDLOOP.
            MODIFY z080611 FROM TABLE t_data2.
            COMMIT WORK AND WAIT.
        ENDCASE.
      ENDIF.
      " Limpa variaveis da memoria
      cl_salv_bs_runtime_info=>clear_all( ).

    CATCH cx_salv_bs_sc_runtime_info.
  ENDTRY.
ENDFORM.