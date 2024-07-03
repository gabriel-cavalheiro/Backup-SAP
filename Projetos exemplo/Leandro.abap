&---------------------------------------------------------------------
*& Report Z_LCV_RELATORIODEMATERIAIS
&---------------------------------------------------------------------
*&
&---------------------------------------------------------------------
REPORT Z_LCV_RELATORIODEMATERIAIS.
&---------------------------------------------------------------------
*& declaração das tabelas
&---------------------------------------------------------------------
TABLES: mkpf,
        mseg,
        MAKT,
        T156T.
&---------------------------------------------------------------------
*&tela de seleção
&---------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-s01.

PARAMETERS: V_MATERI   TYPE MSEG-MATNR,
            V_Centro   TYPE MSEG-WERKS,
            V_Deposi   TYPE  MSEG-LGORT,
            V_Tipo     TYPE MSEG-BWART,
            V_Recebe   TYPE MSEG-WEMPF.

 SELECT-OPTIONS v_date for MKPF-BUDAT.

 SELECTION-SCREEN : skip.

 PARAMETERS executar AS CHECKBOX DEFAULT ''.

SELECTION-SCREEN end of block b1.

&---------------------------------------------------------------------
*& inicio do relatorio alv
&---------------------------------------------------------------------

type-POOLS: slis.

types: BEGIN OF ty_saida,
  MATNR  type MSEG-matnr,
  MAKTX  type MAKT-MAKTX,
  WERKS  type MSEG-WERKS,
  LGORT  type MSEG-LGORT,
  BWART  type MSEG-BWART,
  BTEXT  type T156T-BTEXT,
  BUDAT  type MkPF-BUDAT,
  SGTXT  type MSEG-SGTXT,
  WEMPF  type MSEG-WEMPF,
  MENGE  type MSEG-MENGE,
  MEINS  type MSEG-MEINS,
  MBLNR  type MSEG-MBLNR,
  CHARG  type MSEG-CHARG ,
  DMBTR  type MSEG-DMBTR,
  EXBWR  type MSEG-EXBWR,
  end of ty_saida.



data: t_fieldcat type slis_t_fieldcat_alv,
      t_mkpf   type TABLE OF mkpf,
      t_mseg   type TABLE OF mseg,
      t_makt   type TABLE OF makt,
      t_T156T  type TABLE OF T156T,
      ty_saida TYPE TABLE OF ty_saida.



data: w_layout   type slis_layout_alv,
      w_saida    type ty_saida.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-s02.

  SELECT-OPTIONS: s_MKPF  for mkpf-budat .




  SELECTION-SCREEN end of block b2.

START-OF-SELECTION.

PERFORM f_seleciona_dados.
PERFORM f_monta_fieldcat.
PERFORM f_exibe_alv.
&---------------------------------------------------------------------
*&      Form  F_SELECIONA_DADOS
&---------------------------------------------------------------------
*       text
----------------------------------------------------------------------
*  -->  p1        text
*  <--  p2        text
----------------------------------------------------------------------
FORM F_SELECIONA_DADOS .
      SELECT BUDAT
        FROM MKPF
        INTO TABLE T_MKPF.


        SELECT *
        FROM mseg
        INTO TABLE T_mseg.


        SELECT *
        FROM MAKT
        INTO TABLE T_MAKT.


        SELECT *
        FROM T156T
        INTO TABLE T_T156T.

        SELECT *
        FROM mkpf
        INTO TABLE t_mkpf.


ENDFORM.
&---------------------------------------------------------------------
*&      Form  F_MONTA_FIELDCAT
&---------------------------------------------------------------------
*       text
----------------------------------------------------------------------
*  -->  p1        text
*  <--  p2        text
----------------------------------------------------------------------
FORM F_MONTA_FIELDCAT



ENDFORM.
&---------------------------------------------------------------------
*&      Form  F_EXIBE_ALV
&---------------------------------------------------------------------
*       text
----------------------------------------------------------------------
*  -->  p1        text
*  <--  p2        text
----------------------------------------------------------------------
FORM F_EXIBE_ALV .




ENDFORM.