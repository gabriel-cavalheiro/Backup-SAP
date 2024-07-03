*&---------------------------------------------------------------------*
*&  Include           Z080608A
*&---------------------------------------------------------------------*
TABLES: Z080601,
        Z080611.
*----------------------------------------------------------------------*
* Tabelas Internas: T_*
*----------------------------------------------------------------------*
DATA: t_data      TYPE TABLE OF Z080601.
DATA: t_data2     TYPE TABLE OF Z080611.
*----------------------------------------------------------------------*
* Tela de Seleção: Parameter - P_* / Select-Options S_*
*----------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1.
PARAMETERS: p_cusobj   TYPE objs-objectname OBLIGATORY,
            P_dbeg     TYPE tlog_begdat     OBLIGATORY,
            P_tbeg     TYPE tlog_begtime,
            p_dend     TYPE tlog_enddat     OBLIGATORY,
            p_tend     TYPE tlog_endtime.
SELECTION-SCREEN END OF BLOCK b1.
