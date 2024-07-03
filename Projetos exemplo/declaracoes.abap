************************************************************************
*                 Cast Group - Produtos e Aceleradores                 *
************************************************************************
* ID Modif.: CFR01
* Autor    : T112484 - Marcelo Araújo
* Data     : 24.01.2022
* Especifi.: DEVK9AKDSH   4000038715   CHG0070812
* Descrição: Relatório de Rendimentos
* Solicit. : Karen Regina Pikina Moraes <karen.moraes@castgroup.com.br>
*            Lindomar Basilio Soares <lindomar.soares@castgroup.com.br>
* Projeto  : Projeto Automatização Processos Ingredients
***********************************************************************
* ID Modif.: <sigla>
* Autor    : <autor da alteração>
* Data     : <data da alteração>
* Especifi.: <Nº GAP,Request e Change no SOLMAN, ID da EF com Versão>
* Descrição: <descrição da alteração>
* Solicit. : <funcional/usuário responsável>
* Projeto  : <Nome do Projeto>
***********************************************************************
*----------------------------------------------------------------------*
* Tabelas Transparentes
*----------------------------------------------------------------------*
TABLES: z06551006, z06551007.
*----------------------------------------------------------------------*
* Type-Pools
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Types: TY_*
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_1007,
         docnum       TYPE z06551007-docnum,
         nfenum       TYPE z06551007-nfenum,
         series       TYPE z06551007-series,
         documento    TYPE z06551007-documento,
         status       TYPE z06551007-status,
         centro       TYPE z06551007-centro,
         dt_documento TYPE z06551007-dt_documento,
         parceiro     TYPE z06551007-parceiro,
       END OF ty_1007,

       BEGIN OF ty_1006,
         docnum           TYPE z06551006-docnum,
         mat_generico     TYPE z06551006-mat_generico,
         perc_rendimento  TYPE z06551006-perc_rendimento,
         menge_rendimento TYPE z06551006-menge_rendimento,
       END OF ty_1006,

       BEGIN OF ty_1007_1006,
         docnum           TYPE z06551007-docnum,
         nfenum           TYPE z06551007-nfenum,
         series           TYPE z06551007-series,
         documento        TYPE z06551007-documento,
         status           TYPE z06551007-status,
         centro           TYPE z06551007-centro,
         dt_documento     TYPE z06551007-dt_documento,
         parceiro         TYPE z06551007-parceiro,
         mat_generico     TYPE z06551006-mat_generico,
         perc_rendimento  TYPE z06551006-perc_rendimento,
         menge_rendimento TYPE z06551006-menge_rendimento,
       END OF ty_1007_1006,

       BEGIN OF ty_t021_t022,
         documento TYPE /sprognf/t021-documento,
         item      TYPE /sprognf/t022-item,
         branch    TYPE /sprognf/t021-branch,
         bukrs     TYPE /sprognf/t021-bukrs,
         cfop      TYPE /sprognf/t022-cfop,
       END OF ty_t021_t022,

       BEGIN OF ty_doc,
         docnum TYPE j_1bnfdoc-docnum,
         regio  TYPE j_1bnfdoc-regio,
         pstdat TYPE j_1bnfdoc-pstdat,
       END OF ty_doc,

       BEGIN OF ty_lfa1,
         lifnr TYPE lfa1-lifnr,
         name1 TYPE lfa1-name1,
       END OF ty_lfa1,

       BEGIN OF ty_1001,
         mat_generico      TYPE z06551001-mat_generico,
         desc_mat_generico TYPE z06551001-desc_mat_generico,
       END OF ty_1001,

       BEGIN OF ty_rendimento,
         mat_generico    TYPE z06551004-mat_generico,
         werks           TYPE z06551004-werks,
         dt_ativacao     TYPE z06551004-dt_ativacao,
         lifnr           TYPE z06551004-lifnr,
         perc_rendimento TYPE z06551004-perc_rendimento,
         brwtr           TYPE z06551004-brwtr,
         meins           TYPE z06551004-meins,
         waers           TYPE z06551004-waers,
       END OF ty_rendimento,

       BEGIN OF ty_1008,
         docnum         TYPE z06551008-docnum,
         ebeln_pedido   TYPE z06551008-ebeln_pedido,
         item_pedido    TYPE z06551008-item_pedido,
         ebeln_contrato TYPE z06551008-ebeln_contrato,
         matnr_pa       TYPE z06551008-matnr_pa,
         qte_prev_pa    TYPE z06551008-qte_prev_pa,
         mat_generico   TYPE z06551008-mat_generico,
       END OF ty_1008,

       BEGIN OF ty_ekpo,
         ebeln TYPE ekpo-ebeln,
         ebelp TYPE ekpo-ebelp,
         brtwr TYPE ekpo-brtwr,
         menge TYPE ekpo-menge,
         ktpnr TYPE ekpo-ktpnr,
       END OF ty_ekpo.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Tebelas
*----------------------------------------------------------------------*
DATA: t_1007       TYPE TABLE OF ty_1007,
      t_1006       TYPE TABLE OF ty_1006,
      t_1007_1006  TYPE TABLE OF ty_1007_1006,
      t_t021_t022  TYPE TABLE OF ty_t021_t022,
      t_doc        TYPE TABLE OF ty_doc,
      t_lfa1       TYPE TABLE OF ty_lfa1,
      t_1001       TYPE TABLE OF ty_1001,
      t_rendimento TYPE TABLE OF ty_rendimento,
      t_1008       TYPE TABLE OF ty_1008,
      t_ekpo       TYPE TABLE OF ty_ekpo,
      t_alv        TYPE TABLE OF z06551010.

*----------------------------------------------------------------------*
* Work areas
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
CONSTANTS: c_sign   TYPE char1 VALUE 'I',
           c_option TYPE char2 VALUE 'EQ'.

*----------------------------------------------------------------------*
* Tela de Seleção: Parameter - P_* / Select-Options S_*
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-t01.
SELECT-OPTIONS: s_nfenum FOR  z06551007-nfenum.
PARAMETERS: p_series TYPE z06551007-series,
            p_werks  TYPE z06551007-centro.
SELECT-OPTIONS: s_gnf    FOR  z06551007-documento,
                s_dt_doc FOR  z06551007-dt_documento,
                s_docnum FOR  z06551007-docnum,
                s_parc   FOR  z06551007-parceiro,
                s_mat_ge FOR  z06551006-mat_generico.
SELECTION-SCREEN END   OF BLOCK b01.
SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME.
PARAMETERS: r_pend  RADIOBUTTON GROUP a1,
            r_concl RADIOBUTTON GROUP a1,
            r_ambos RADIOBUTTON GROUP a1.
SELECTION-SCREEN END   OF BLOCK b02.


SELECT kurst gdatu ukurs
FROM tcurr
INTO  TABLE t_tcurr
WHERE kurst = 'B'
AND fcurr = p_waers
AND tcurr = x_waers
AND gdatu >= x_data1
AND gdatu <= x_data2
OR  kurst = 'M'
AND fcurr = p_waers
AND tcurr = x_waers
AND gdatu >= x_data1 "Funciona somente com as datas invertidas
AND gdatu <= x_data2 "Funciona somente com as datas
ORDER BY gdatu. "Funciona somente com o order by invertido