*--------------------------------------------------------------------------------
* Empresa..: GLOBAL
* Módulo...: HR
* Transação: PAXX
* Descrição: User-Exit utilizada nas transações de HR, PAXX
* Autor....: Luiz Fernando Massami Saito - T3LUIZFMS - CPM Braxis
* Data.....: 14/05/2009
* User Exit: Include ZXPADU02 projeto ZJHR_001
*
* [HISTÓRICO]
* ========  ========= ========== ================================================
* Data      Autor     Request    Descrição
* ========  ========= ========== ================================================
* 14/05/09  T3LUIZFMS E03K9A3JIT Projeto Minhas Informações - Alteração
*                                Na exclusão dos Infotipos 0022 e 0023, será
*                                gerado uma cópia do registros em uma tabela Z.
*                                Procedimento adotado para informar ao EFV que
*                                ocorreu uma deleção no SAP.
* ========  ========= ========== ================================================
* 10/06/09  T3LUIZFMS E03K9A3M5J Infotipo 0023, consistência se ENDDA for <> de
*                                31.12.9999. Infotipo 0022 e 0023, se houver
*                                alteração dos campos chaves do IT, gerar um
*                                log do registro anterior e outro do novo
*                                na tabela ZTBHR_PA0022 ou 0023.
* ========  ========= ========== ================================================
* 22/06/10 T3RAFAELFD E03K9A4OF9 ACRESCENTADO A EXIT ZXPADU02 DO AMBIENTE ARACRUZ
*                                COMO INCLUDE ZIHR0040_ZXPADU02_FIBRIA
* ======== =========    ========== ================================================
* 27/08/10 T3WELLINGTOV E03K9A50IH Validação da Posição (PLANS)
*
* 07/07/11 T3KATHYV   E03K9A62NU For VCNA do not hard code company use the table
*                                ZTBSD_BUKRS_GRP     SSTI 6022
* ======== ========== ========== ================================================
* 04/09/12 T3ISRAELS  E03K9B0ZR4 ACRESCENTADO A EXIT ZXPADU02 A INCLUDE
*                                ZIHR0093_VALID_PLANOS_ELEGIB
* ======== ========== ========== ================================================
* 15/03/13 T3GUILHERF E03K9B1MF4 Include ZIHR0219_PREENCHE_DEPENDENTES para
*                                preenchimento dos dependentes no infotipo 0167
* ======== ========== ========== ================================================
* 17/08/15 T3MOISESRT E03K9XYJ3E Melhoria INC000002971630
* ======== ========== ========== ================================================
* ======== ========== ========== ================================================
* 16/09/15 T3JOILSORJ E03K9XYN5J Adequações projeto eSocial
* ======== ========== ========== ================================================
* ======== ========== ========== ================================================
* 25/10/16 T3ROLANDOME  E03K9ZZZXJ VM.HR: 4028397: AJUSTES INFOTIPO HR
* ======== ========== ========== ================================================
* 18/11/16 T3JESUSRG  E03K9ZZZTD @0001 : Ajustes Infotipos HR : Proyecto ID 14222
* ======== ========== ========== ================================================
* 22/12/16 T3JESUSRG  T3PAOLAMJ  @0002 : Ajustes Infotipos HR : Proyecto ID 14222
* ======== ========== ========== ================================================
* 01/03/17 T3JESUSRG  T3PAOLAMJ  @0003 : Validacion IT0009 transaccion  PRAA
*                                : Proyecto ID 14222
* ======== ========== ========== ================================================
* 17/03/17 T3JESUSRG  T3PAOLAMJ  @0004 : Regularizacion version PRD.
*                                : Proyecto ID 14222
* ======== ========== ========== ================================================
* 28/09/17 T3CARLOSCT E03K9A77PM @0007 : Ajustes Varios
* ======== ========== ========== ================================================
* 28/03/18 T3SIDNEIMRF           INC 000044607 - Ler elegibilidade válida
* ======== ========== ========== ================================================
* 17/09/20 T3LUISGG              VM.HR: 4050462 Mejora Adelanto de Vacaciones
*                                @0008
* ======== ========== ========== ================================================
*--------------------------------------------------------------------------------

*&---------------------------------------------------------------------*
*&  Include           ZXPADU02                                         *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
* Tables
*&---------------------------------------------------------------------*
TABLES: pa0002, pa0006, pa0008, pa0014, pa0015, pa0167, pa0168,
pa0170, ztbhr_pa0002,ztbhr_pa0006, ztbhr_pa0008, ztbhr_pa0014,
ztbhr_pa0015, ztbhr_pa0167, ztbhr_pa0168, ztbhr_pa0170,
ztbhr_pa0022, ztbhr_pa0023.
*          hrp9230. "- @0004

*&---------------------------------------------------------------------*
* Internal Tables
*&---------------------------------------------------------------------*

* T3CARLOSCT  @0007 Inicio 29.09.2017
DATA: t_t52ocw TYPE STANDARD TABLE OF t52ocw.
* T3CARLOSCT  @0007 Fin 29.09.2017

** @0008 - CC-20200917 - Inicio
DATA: t_p2006 LIKE p2006 OCCURS 0 WITH HEADER LINE.
** @0008 - CC-20200917 - Fin

*&---------------------------------------------------------------------*
* Field-Symbols
*&---------------------------------------------------------------------*
FIELD-SYMBOLS: <f_werks>   TYPE pa0001-werks,   "T3DEBORACJ 25.09.08
       <f_bukrs>   TYPE pa0001-bukrs,   "T3DEBORACJ 25.09.08
       <f_btrtl>   TYPE pa0001-btrtl,   "T3DEBORACJ 25.09.08
       <f_vdsk1>   TYPE pa0001-vdsk1,   "T3DEBORACJ 25.09.08
       <f_ficha>   TYPE p0695-fichanr,   "T3DEBORACJ 25.09.08
       <f_mil_cat> TYPE p0465-mil_cat,   "T3DEBORACJ 25.09.08
       <f_mil_nr>  TYPE p0465-mil_nr,   "T3DEBORACJ 25.09.08
       <fs_0001>   TYPE p0001,
       <fs_0695>   TYPE p0695,
       <fs_0465>   TYPE p0465,
***Inicio de Inclusão - T3WELLINGTOV - 27.08.2010
       <f_plans>   TYPE pa0001-plans,
***Fim de Inclusão - T3WELLINGTOV - 27.08.2010
       <f_s1>,                       "@0002
       <inf>       TYPE any,

* T3CARLOSCT  @0007 Inicio 29.09.2017
       <f_t52ocw>  LIKE LINE OF t_t52ocw.
* T3CARLOSCT  @0007 Fin 29.09.2017

*&---------------------------------------------------------------------*
* Variáveis
*&---------------------------------------------------------------------*
DATA: v_vdsk1 TYPE pa0001-vdsk1.    "T3DEBORACJ 25.09.08
*** Begin of Inclusion - T3KATHYV - 07/07/2011 E03K9A62NU
DATA: v_control_group LIKE ztbsd_bukrs_grp-control_group.
***   End of Inclusion - T3KATHYV - 07/07/2011 E03K9A62NU

***T3PAOLAMJ  @0002 Inicio
DATA: v_campos(22) TYPE c VALUE '(MP000000)PSPAR-PERSG',
w0000        LIKE p0000.
***T3PAOLAMJ  @0002 Fin

***T3CARLOSCT  @0007 Inicio
DATA: t_t511k TYPE STANDARD TABLE OF t511k.
***T3CARLOSCT  @0007 Fin

DATA: t_p0008_pkge TYPE TABLE OF p0008,
w_p0008_pkge TYPE p0008,
t_p0377      TYPE TABLE OF p0377, "T3MOISESRT 04/09/22
l_pltyp      TYPE pa0377-pltyp, "T3MOISESRT 04/09/22
l_find       TYPE c, "T3MOISESRT 04/09/22
l_slgrp      TYPE t710-slgrp.

* Begin of mod T3RONALDN - Roll Out Milpo 18.06.2013
DATA: v_bname  TYPE sy-uname,
v_parva  TYPE usr05-parva,
v_zvlpar TYPE zdegl_vlpar.

RANGES: r_bukrs FOR t001-bukrs,
* >>> Início das alterações - HCMx - SSTI 13739
r_empresa FOR t001-bukrs,
r_lgart FOR pa0015-lgart,
r_werks FOR pa0001-werks. "area de RH 08/09/22
* <<< Fim das alterações - HCMx - SSTI 13739

DATA: BEGIN OF t_bukrs OCCURS 0,
valor(4) TYPE c,
END OF t_bukrs.

TYPES: BEGIN OF ty_p0000,
 begda TYPE pa0000-begda,
 massn TYPE pa0000-massn,
 stat2 TYPE pa0000-stat2,
END OF ty_p0000.

DATA: t_p000       TYPE TABLE OF ty_p0000,
w_p000       TYPE ty_p0000,
*        w_file  TYPE y_file,
*        w_header TYPE y_header,
*        w_footer  TYPE y_footer,
w_param      TYPE ztbhr_par_infoca,
w_int        TYPE ztbhr_int_infoca,
t_zinfoca    TYPE TABLE OF ztbhr_int_infoca,
t_param      TYPE TABLE OF ztbhr_par_infoca WITH HEADER LINE,
l_valor(200) TYPE c,
l_campo(50)  TYPE c,
l_var(30)    TYPE c,
l_bukrs      TYPE pa0001-bukrs,
l_werks      TYPE pa0001-werks,
l_x(1)       TYPE c,
l_linea(10)  TYPE n,
l_path(16)   TYPE c VALUE '(MPNNNN00)PNNNN-',
l_fecha      TYPE pa0167-begda,
l_bopti      TYPE pa0167-bopti,
l_bplan      TYPE pa0168-bplan,
t_parametros TYPE TABLE OF ztbhr_ben_377,
t_unidade    TYPE TABLE OF ztbhr_ben_377,
t_atribui    TYPE TABLE OF ztbhr_ben_377,
t_area       TYPE TABLE OF ztbhr_ben_377,
t_valper     TYPE TABLE OF ztbhr_ben_377,
t_empresa    TYPE TABLE OF ztbhr_ben_377,
w_parametros TYPE ztbhr_ben_377,
w_unidade    TYPE ztbhr_ben_377,
l_param      TYPE zdegl_param,
l_len        TYPE i,
l_erro       TYPE c,
l_line       TYPE i,
l_str        TYPE i,
l_val(10)    TYPE c.

* End of mod T3RONALDN - Roll Out Milpo 18.06.2013

* Inicio / modificação - Giovanni Mileo

DATA : t_file               TYPE TABLE OF y_file,
*          t_p0001 TYPE TABLE OF p0001,
t_p0002              TYPE TABLE OF p0002,
t_p0465              TYPE TABLE OF p0465,
t_p0105              TYPE TABLE OF p0105,
t_tab_converted_data TYPE truxs_t_text_data,

*          w_p0001 LIKE LINE OF t_p0001,
w_p0002              LIKE LINE OF t_p0002,
w_p0465              LIKE LINE OF t_p0465,
w_p0105              LIKE LINE OF t_p0105,
w_file               TYPE y_file,
w_header             TYPE y_header,
w_footer             TYPE y_footer,
w_interloc           TYPE ztbhr_interloc.

*Fim modificação

*** Fabio Cesar - INC000050782206 - 12/09/2014 - Início
DATA: w_pa0001 TYPE pa0001.
*** Fabio Cesar - INC000050782206 - 12/09/2014 - Fim
* >>> Início das alterações - HCMx
DATA: w_pa0167       TYPE p0167.
* <<< Fim das alterações - HCMx

* T3CARLOSCT  @0007 Inicio 29.09.2017
DATA: w_p0267   TYPE p0267.
*        w_p0008   TYPE p0008.

* T3CARLOSCT  @0007 Fin 29.09.2017

*** Strong iT - 22.07.2021 - Início
*** Mudança: 4055674 - Chamado RITM0202844
*Variáveis
DATA: l_pernr   TYPE p0167-pernr,
l_nr(02),
l_dty(15),
l_did(15).

*Tabelas
DATA: t_0167 TYPE TABLE OF pa0167.
*** Strong iT - 22.07.2021 - FIM

*&---------------------------------------------------------------------*
* Constants
*&---------------------------------------------------------------------*
CONSTANTS: c_0              TYPE c VALUE '0',
   c_4047(4)        TYPE c VALUE '4047',
   c_4048(4)        TYPE c VALUE '4048',
   c_4049(4)        TYPE c VALUE '4049',
   c_4050(4)        TYPE c VALUE '4050',
   c_4051(4)        TYPE c VALUE '4051',
   c_4052(4)        TYPE c VALUE '4052',
   c_4053(4)        TYPE c VALUE '4053',
   c_4054(4)        TYPE c VALUE '4054',
   c_0002(4)        TYPE c VALUE '0002',
   c_0006(4)        TYPE c VALUE '0006',
   c_0008(4)        TYPE c VALUE '0008',
   c_0014(4)        TYPE c VALUE '0014',
   c_0015(4)        TYPE c VALUE '0015',
   c_0167(4)        TYPE c VALUE '0167',
   c_0168(4)        TYPE c VALUE '0168',
   c_0170(4)        TYPE c VALUE '0170',
   c_ins(3)         TYPE c VALUE 'INS' ,    "T3DEBORACJ 25.09.08
   c_mod(3)         TYPE c VALUE 'MOD' ,    "T3DEBORACJ 25.09.08
   c_upd(3)         TYPE c VALUE 'UPD' ,    "T3DEBORACJ 25.09.08
   c_cop(3)         TYPE c VALUE 'COP' ,    "T3DEBORACJ 25.09.08
   c_pa30(4)        TYPE c VALUE 'PA30',    "T3DEBORACJ 25.09.08
   c_0001(4)        TYPE c VALUE '0001',    "T3DEBORACJ 25.09.08
*** Inicio de Inclusão - <T3LUIZFMS> - <14.05.2009> - <Minhas Informações>
   c_0022(4)        TYPE c VALUE '0022',
   c_0023(4)        TYPE c VALUE '0023',
   c_ksbez(132)     TYPE c VALUE 'P0022-KSBEZ',
   c_ausbi(132)     TYPE c VALUE 'P0022-AUSBI',
   c_endda(132)     TYPE c VALUE 'P0022-ENDDA',
   c_i(1)           TYPE c VALUE 'I',
   c_eq(02)         TYPE c VALUE 'EQ',
   c_06(02)         TYPE c VALUE '06',
   c_25(02)         TYPE c VALUE '25',
   c_d(01)          TYPE c VALUE 'D',
   c_pa20(4)        TYPE c VALUE 'PA20',
   c_del(3)         TYPE c VALUE 'DEL',
*** Final de Inclusão  - <T3LUIZFMS> - <14.05.2009> - <Minhas Informações>
   c_9              TYPE pa0001-persg VALUE '9',        "T3DEBORACJ 25.09.08
* >>> Início das alterações - INC000002971630 - HCMx
   c_5              TYPE pa0001-persg VALUE '5',
   c_8              TYPE pa0001-persk VALUE '08',
   c_09             TYPE pa0001-persk VALUE '09',
   c_13             TYPE pa0001-persk VALUE '13',
   c_persg(132)     TYPE c VALUE 'PSPAR-PERSG',
* <<< Fim das alterações - INC000002971630 - HCMx
   c_terceiro       TYPE pa0001-vdsk1 VALUE 'TERCEIRO', "T3DEBORACJ 25.09.08
*** inicio grupo assa - natalino 26082008
   c_pa40(4)        TYPE c VALUE 'PA40',
   c_19(2)          TYPE c VALUE '19',
   c_01(2)          TYPE c VALUE '01',
   c_0598(4)        TYPE c VALUE '0598',
   c_37(2)          TYPE c VALUE '37',
   c_3(1)           TYPE c VALUE '3',
*** fim grupo assa - na talino 26082008
* Begin of mod T3RONALDN - Roll Out Milpo 18.06.2013
   c_ugr(3)         TYPE c VALUE 'UGR',
   c_buk(3)         TYPE c VALUE 'BUK',
   c_pe(2)          TYPE c VALUE 'MP',
   c_pe2(2)         TYPE c VALUE 'PE', "@0001 INSERT
   c_pv(1)          TYPE c VALUE ';',
   c_program(40)    TYPE c VALUE 'LZGHR_BADI_HRPAD00INFTYU01',
   c_zparam(20)     TYPE c VALUE 'BUKRS',
   c_x(1)           TYPE c VALUE 'X',
   c_uno(1)         TYPE c VALUE '1',
   c_m(1)           TYPE c VALUE 'M',
   c_f(1)           TYPE c VALUE 'F',
   c_eps(3)         TYPE c VALUE 'EPS',
   c_z0465(4)       TYPE c VALUE '0465',
   c_z0105(4)       TYPE c VALUE '0105',
   c_z0022(4)       TYPE c VALUE '0022',
   c_z0002(4)       TYPE c VALUE '0002',
   c_z0000(4)       TYPE c VALUE '0000',
   c_z0007(4)       TYPE c VALUE '0007',
   c_z0009(4)       TYPE c VALUE '0009',
   c_z0016(4)       TYPE c VALUE '0016',
   c_z0167(4)       TYPE c VALUE '0167',
   c_z0168(4)       TYPE c VALUE '0168',
   c_z0021(4)       TYPE c VALUE '0021',
   c_z0397(4)       TYPE c VALUE '0397',
   c_z9000(4)       TYPE c VALUE '9000',
   c_z0003(4)       TYPE c VALUE '0003',
   c_z0010(4)       TYPE c VALUE '0010',
   c_z9006(4)       TYPE c VALUE '9006',
   c_pe01(4)        TYPE c VALUE 'PE01',
   c_pe02(4)        TYPE c VALUE 'PE02',
   c_pe03(4)        TYPE c VALUE 'PE03',
* Begin @0001 T3jesusrg
   c_pe5(4)         TYPE c VALUE '5',
   c_pe0(4)         TYPE c VALUE '0',
* end @0001 t3jesusrg
   c_ctrp(4)        TYPE c VALUE 'CTRP',
   c_ctrs(4)        TYPE c VALUE 'CTRS',
   c_slart(5)       TYPE c VALUE 'SLART',
   c_gesch(5)       TYPE c VALUE 'GESCH',
   c_usrty(5)       TYPE c VALUE 'USRTY',
   c_tpdoc(5)       TYPE c VALUE 'TPDOC',
   c_bnksa(5)       TYPE c VALUE 'BNKSA',
   c_bankl(5)       TYPE c VALUE 'BANKL',
   c_waers(5)       TYPE c VALUE 'WAERS',
   c_bankn(5)       TYPE c VALUE 'BANKN',
   c_bkont(5)       TYPE c VALUE 'BKONT',
   c_ctedt(5)       TYPE c VALUE 'CTEDT',
   c_aedtm(5)       TYPE c VALUE 'AEDTM',
   c_bopti(5)       TYPE c VALUE 'BOPTI',
   c_begda(5)       TYPE c VALUE 'BEGDA',
   c_zendda(5)      TYPE c VALUE 'ENDDA',
   c_bplan(5)       TYPE c VALUE 'BPLAN',
   c_stat2(5)       TYPE c VALUE 'STAT2',
   c_mil_nr(6)      TYPE c VALUE 'MIL_NR',
   c_ident_nr(8)    TYPE c VALUE 'IDENT_NR',
   c_fecha(10)      TYPE c VALUE '31.12.9999',
   c_usrid_long(10) TYPE c VALUE 'USRID_LONG',
   c_initial(10)    TYPE c VALUE '00000000',
   c_bukrs          TYPE zdegl_param VALUE 'BUKRS',
* >>> Início das alterações - HCMx - SSTI 13739
   c_lgart          TYPE zdegl_param VALUE 'LGART',
   c_pa_30          TYPE programm VALUE 'PA30',
   c_pa_70          TYPE programm VALUE 'PA70',
* <<< Fim das alterações - HCMx - SSTI 13739
* >>> Início das alterações - Moises - T3MOISESRT - 04/09/2022
   "Beneficios de
   c_benrub         TYPE programm     VALUE 'ZGLHR_ECC_0377_',
   c_valfol         TYPE zdegl_param  VALUE 'VALIDA_FOLHA',
   c_empre          TYPE zdegl_param  VALUE 'EMPRESA',
   c_area           TYPE zdegl_param  VALUE 'AREA',
   c_unid           TYPE zdegl_param  VALUE 'UNIDADE',
   c_atri           TYPE zdegl_param  VALUE 'ATRIBUICAO',
   c_dep            TYPE zdegl_param  VALUE 'DEPENDENTE',
* >>> Fim das alterações - Moises - T3MOISESRT - 04/09/2022
   c_ennda(8)       TYPE c VALUE '99991231',

*** Fabio Cesar - INC000050782206 - 12/09/2014 - Início
   c_msg1(33)       TYPE c VALUE 'Funcionário não elegível ao plano',
   c_msg2(32)       TYPE c VALUE 'pois centro de custo é diferente',
   c_dez(2)         TYPE c VALUE '10',
*** Fabio Cesar - INC000050782206 - 12/09/2014 - Fim

* Ini @0007 Castro 16.11.2017
   c_z2001          TYPE infty VALUE '2001',
   c_inse(15)       TYPE c VALUE 'C',
   c_modi(15)       TYPE c VALUE 'M',
   c_dele(15)       TYPE c VALUE 'E',
   c_bloq(15)       TYPE c VALUE 'EDQ'.
* Fin @0007 Castro 16.11.2017

FIELD-SYMBOLS: <f_info>, <f_campo>, <f_var>.
* End of mod T3RONALDN - Roll Out Milpo 18.06.2013
***Inicio de Inclusão - T3WELLINGTOV - 27.08.2010
DATA: l_sobid    TYPE hrp1001-sobid,
l_cname    TYPE pa0002-cname,
l_oper     TYPE pspar-actio,
l_programn TYPE programm.

CONSTANTS: c_posicao(2) TYPE c VALUE 'S',
   c_p(2)       TYPE c VALUE 'P',
   c_0000(4)    TYPE c VALUE '0000',
   c_fibria(1)  TYPE c VALUE '3',
   c_4002(4)    TYPE c VALUE '4002',
   c_a008       TYPE subtyp VALUE 'A008',
   c_pb40(4)    TYPE c VALUE 'PB40',
   c_pb30(4)    TYPE c VALUE 'PB30'.
***Fim de Inclusão - T3WELLINGTOV - 27.08.2010

***BEGIN @0001 T3JESUSRG
CONSTANTS: c_z0001(4) TYPE c VALUE '0001',
   c_z0034(4) TYPE c VALUE '0034',
   c_z0037(4) TYPE c VALUE '0037',
   c_z9051(4) TYPE c VALUE '9051',
   c_z0171(4) TYPE c VALUE '0171',
   c_z0008(4) TYPE c VALUE '0008'.

CONSTANTS: c_f1ansvh(5)             TYPE c VALUE 'ANSVH',           "For IT0001
   c_cttyp(5)               TYPE c VALUE 'CTTYP',                         "For IT0016
   c_f34zztipotrabsunat(15) TYPE c VALUE 'ZZTIPOTRABSUNAT', "For IT0034
   c_f34funkt(5)            TYPE c VALUE 'FUNKT',           "For IT0034
   c_v34subty(4)            TYPE c VALUE '17',              "For IT0034
   c_f37subty(5)            TYPE c VALUE 'SUBTY',           "For IT0037
   c_f37vsges(5)            TYPE c VALUE 'VSGES',           "For IT0037
   c_f37zz_riesgo(8)        TYPE c VALUE 'ZZRIESGO',       "For IT0037
   c_f37emfsl(5)            TYPE c VALUE 'EMFSL',           "For IT9051
   c_f37budat(5)            TYPE c VALUE 'BUDAT',           "For IT9051
   c_barea(5)               TYPE c VALUE 'BAREA',          "For IT0167
   c_bengr(5)               TYPE c VALUE 'BENGR',          "For IT0167
   c_bstat(5)               TYPE c VALUE 'BSTAT',          "For IT0167
   c_pltyp(5)               TYPE c VALUE 'PLTYP',   "For IT0167
   c_massg(5)               TYPE c VALUE 'MASSG',   "For IT0001
   c_ps01(4)                TYPE c VALUE 'PS01',   "for It167
   c_trfgb(5)               TYPE c VALUE 'TRFGB', "for IT0008
   c_depcv(5)               TYPE c VALUE 'DEPCV',   "For IT0167
   c_persk(5)               TYPE c VALUE 'PERSK'. "FOR it001

** @0008 - CC-20200917 - Inicio
CONSTANTS: c_pe_awart_1000 TYPE p2001-awart VALUE '1000',
   c_pe_ktart_90   TYPE p2006-ktart VALUE '90'.

DATA: l_anzhl_vac   LIKE p2006-anzhl,
l_anzhl_tope  LIKE p2006-anzhl,
l_anzhl_qtneg LIKE t556a-qtneg.
** @0008 - CC-20200917 - Fin


DATA: v_vaux(50)    TYPE c,
v_0034flag(1) TYPE c,
l_abkrs       LIKE t549a-abkrs,
l_permo       LIKE t549a-permo,
l_begda       LIKE t549q-begda,
l_endda       LIKE t549q-endda,
l_pabrp       LIKE t549q-pabrp,
l_pabrj       LIKE t549q-pabrj.

DATA: w_p9051    TYPE p9051,
w_p0167n   TYPE p0167,
w_p0009    TYPE p0009,                              "+@0003
w_p9004    TYPE p9004,
w_p0661    TYPE p0661,
w_p0105n   TYPE p0105,
l_fec_cese TYPE sy-datum. "@0003

*** end @0001 t3jesusrg

* begin of TMARCELOSM - 27.07.2020
IF sy-tcode = c_pa30.
IF ipsyst-ioper = c_cop OR
ipsyst-ioper = c_mod.
"Se for transação PA30
"Se for modificação ou cópia
"Se for infotipo 0168
IF innnn-infty = '0168'.
IF innnn-endda < sy-datum.
"Não é permitido delimitar o seguro de vida
"pois é obrigatório para todos os funcionário
MESSAGE e016(rp)
WITH 'Não é permitido delimitar o seguro de vida pois é obrigatório para todos os funcionários'
RAISING error_occured.
ENDIF.
ENDIF.
ENDIF.
ENDIF.

IF innnn-infty = '2001'.
IF ipsyst-ioper = c_cop OR
ipsyst-ioper = c_mod OR
ipsyst-ioper = c_ins OR
ipsyst-ioper = c_upd.
IF ipsyst-persk = c_8  OR
ipsyst-persk = c_09 OR
ipsyst-persk = c_13.
IF innnn-subty = '0100' OR
 innnn-subty = '0120' OR
 innnn-subty = '0130' OR
 innnn-subty = '0150'.
MESSAGE e016(rp)
WITH 'Não é permitido lançamento de férias para estagiário. Utilize os tipos de ausência apropriados.'
RAISING error_occured.
ENDIF.
ENDIF.
ENDIF.
ENDIF.
* end of TMARCELOSM - 27.07.2020

*** Fabio Cesar - INC000050387655 - 08/09/2014 - Início
DATA: w_pa0000 TYPE pa0000.

*  DATA: t_dynpfields2  TYPE dynpread OCCURS 0 WITH HEADER LINE. " - @0004
*  DATA: w_dynpfields2  LIKE LINE OF t_dynpfields2.  " - @0004

IF innnn-infty EQ '0015'.
SELECT SINGLE *
   FROM pa0000
   INTO w_pa0000
  WHERE pernr EQ innnn-pernr
    AND endda EQ c_ennda.


IF sy-subrc IS INITIAL AND w_pa0000-massn = c_dez.
IF innnn-begda > w_pa0000-begda.
MESSAGE e474(pg) WITH w_pa0000-begda.
ENDIF.
ENDIF.
ENDIF.
*** Fabio Cesar - INC000050387655 - 08/09/2014 - Fim

*   Inicio alteração - Interface de verbas - Giovanni Mileo
IF innnn-infty EQ '0015' AND sy-ucomm = 'UPD'.
innnn-flag4 = ' '.
ELSEIF innnn-infty EQ '2001' AND sy-ucomm = 'UPD'.
innnn-flag4 = ' '.
ENDIF.
*   Fim alteração - Interface de verbas - Giovanni Mileo

* >>> Início das alterações - INC000002971630 - HCMx
IF sy-tcode = c_pa40.
IF innnn-infty = c_0000.
IF ipsyst-ioper = c_cop OR ipsyst-ioper = c_mod OR
 ipsyst-ioper = c_ins OR ipsyst-ioper = c_upd.
IF ipsyst-massn = '10' AND sy-ucomm = 'UPD'.
  PERFORM f_deleta_interlocutor USING  innnn.
ENDIF.
IF ( ipsyst-persk = c_8 OR ipsyst-persk = c_09 OR
   ipsyst-persk = c_13 ) AND ipsyst-persg <> c_5.
  PERFORM zf_atrbiutos_tela USING c_persg.
  SET CURSOR FIELD c_persg.
  MESSAGE e001(zhr10).
ENDIF.
ENDIF.
******* INICIO @0002
IF ipsyst-land EQ 'PE'.  "VALIDACIONES PERÚ E03K9A1HYS
CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
  EXPORTING
    prelp = innnn
  IMPORTING
    pnnnn = w0000.

" Grupo de Personal de Cesados
ASSIGN (v_campos) TO <f_s1>.
IF w0000-stat2 EQ 0.          "Cese
  <f_s1> = '4'.  "Cesados
ELSE.                         "En periodo activo
  IF <f_s1> EQ '4'.
    MESSAGE e016(rp) WITH 'Debe actualizar Grupo de Personal' RAISING error_occurd.
  ENDIF.
ENDIF.
ENDIF.
******* FIN @0002
ENDIF.
ENDIF.
* <<< Fim das alterações - INC000002971630 - HCMx

*** Fabio Cesar - PDCA Melhoria - 16/05/2014 - Início
DATA: v_plano   TYPE ztbhr_eleg_custo-bplan,
v_benef   TYPE ztbhr_eleg_custo-bopti,
v_data_f  TYPE sy-datum,
v_kostl_v TYPE ztbhr_eleg_custo-kostl,
v_data_b  TYPE sy-datum.

IF  sy-tcode = c_pa30.
CASE innnn-infty.
WHEN '0167'.
v_plano = innnn-data1+6(4).
v_benef = innnn-data1+42(4).
WHEN '0377'.
v_plano = innnn-data1+6(4).
v_benef = innnn-data1+39(4).
WHEN '0168'.
v_plano = innnn-data1+2(4).
v_benef = innnn-data1+42(4).
WHEN '0169'.
v_plano = innnn-data1+6(4).
ENDCASE.

* Cancela verificação de Autorização para leitura do infotipo
CALL FUNCTION 'HR_READ_INFOTYPE_AUTHC_DISABLE'.
* Leitura Infotipo 0008
CALL FUNCTION 'HR_READ_INFOTYPE'
EXPORTING
pernr           = innnn-pernr
infty           = '0008'
begda           = innnn-begda
endda           = innnn-endda
TABLES
infty_tab       = t_p0008_pkge
EXCEPTIONS
infty_not_found = 1
OTHERS          = 2.

IF sy-subrc IS INITIAL.
READ TABLE t_p0008_pkge INTO w_p0008_pkge WITH KEY endda = c_ennda.
IF sy-subrc IS INITIAL.
l_slgrp = w_p0008_pkge-trfgr.
ENDIF.
ENDIF.

*** Fabio Cesar - INC000050782206 - 12/09/2014 - Início
CLEAR w_pa0001.
SELECT SINGLE *
     FROM pa0001
     INTO w_pa0001
    WHERE pernr = innnn-pernr
      AND endda = c_99993112.
*** Fabio Cesar - INC000050782206 - 12/09/2014 - Fim

SELECT endda kostl
FROM ztbhr_eleg_custo
INTO (v_data_f,v_kostl_v)
WHERE bukrs = w_pa0001-bukrs
  AND werks = w_pa0001-werks
  AND persg = w_pa0001-persg
  AND persk = w_pa0001-persk
  AND pltyp = ipsyst-dsubt
  AND min_slgrp LE l_slgrp
  AND max_slgrp GE l_slgrp
  AND bplan = v_plano
  AND bopti = v_benef
* Início - Evox - Sidnei - INC 000044607
  AND endda = c_99993112.
* Fim - INC 000044607
ENDSELECT.
IF sy-subrc IS INITIAL.

* >>> Início das alterações - HCMx
*** Converte INNNN para Work Área
CLEAR: w_pa0167.
IF innnn-infty = '0167'.
  CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
    EXPORTING
      prelp = innnn
    IMPORTING
      pnnnn = w_pa0167.
* Felipe Eidam - FH: Correção de condição - 12.01.2016 - Início
  IF w_pa0167-zz_excecao <> 'X'.
    IF innnn-endda > v_data_f.
      MESSAGE ID 'ZHR' TYPE 'E' NUMBER '000' WITH 'Data fora do range permitido'.
    ENDIF.
  ENDIF.
ENDIF.
* Felipe Eidam - FH: Correção de condição - 12.01.2016 - Fim
* <<< Fim das alterações - HCMx

*** Fabio Cesar - INC000050782206 - 12/09/2014 - Início
IF NOT v_kostl_v IS INITIAL.
  IF v_kostl_v <> w_pa0001-kostl.
    MESSAGE ID 'ZHR' TYPE 'E' NUMBER '000' WITH c_msg1 c_msg2.
  ENDIF.
ENDIF.
*** Fabio Cesar - INC000050782206 - 12/09/2014 - Início
ENDIF.

*INI-fceridono- 03/07/2014 - ajuste na PA30 no BEGDA

SELECT SINGLE begda
 FROM ztbhr_eleg_custo
 INTO v_data_b
 WHERE bukrs = ipsyst-bukrs
   AND werks = ipsyst-werks
   AND persg = ipsyst-persg
   AND persk = ipsyst-persk
   AND pltyp = ipsyst-dsubt
   AND min_slgrp LE l_slgrp
   AND max_slgrp GE l_slgrp
   AND bplan = v_plano
   AND bopti = v_benef
* Início - Evox - Sidnei - INC 000044607
  AND endda = c_99993112.
* Fim - INC 000044607

IF sy-subrc IS INITIAL.
* >>> Início das alterações - HCMx
*** Converte INNNN para Work Área
  CLEAR: w_pa0167.
  IF innnn-infty = '0167'.
    CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
      EXPORTING
        prelp = innnn
      IMPORTING
        pnnnn = w_pa0167.
  ENDIF.

  IF w_pa0167-zz_excecao <> 'X'.
    IF innnn-begda < v_data_b.
      MESSAGE ID 'ZHR' TYPE 'E' NUMBER '000' WITH 'Data de Inicio fora do range permitida'.
    ENDIF.
  ENDIF.
* <<< Fim das alterações - HCMx
ENDIF.
ENDIF.

*FIM-fceridono- 03/07/2014 - ajuste na PA30 no BEGDA


*** Fabio Cesar - PDCA Melhoria - 16/05/2014 - Fim



* Liberar cadastro IT09 mais uma conta
*  IF ( innnn-infty EQ '0009' )           AND
*       ( innnn-subty EQ '9000' )         AND
*       ( ipsyst-bukrs(1) NE c_fibria ).
*    MESSAGE ID 'ZHR' TYPE 'E' NUMBER '012' WITH ipsyst-bukrs.
*  ENDIF.


*** inicio grupo assa - natalino 26082008

*** Inicio de Inclusão - <T3LUIZFMS> - <14.05.2009> - <Minhas Informações>
RANGES: r_slart FOR p0022-slart.
*** Final de Inclusão  - <T3LUIZFMS> - <14.05.2009> - <Minhas Informações>

* Inicio de alteração - Fernanda Araujo - 16.04.2015
** Inicio Alteracao - T3RICARDORMS - 15.05.2015
** Verifica se é o desligamento do funcionário, se sim, chama servico do forponto para atualização no BPM
IF (     sy-tcode     EQ c_pa40
   AND ipsyst-massn EQ '10'
   AND sy-ucomm     EQ 'UPD'  ).
INCLUDE zihr0228_processo_forponto.
ENDIF.
** Final Alteracao - T3RICARDORMS - 15.05.2015
* Fim de alteração - Fernanda Araujo - 16.04.2015

*** NA TRANSACAO PA40 E NA MEDIDA 19 - MOVIMENTACAO DE PESSOAL SERAO TODOS OS INFOTIPOS  COM A DATA INICIAL DO DIA 01
IF sy-tcode = c_pa40 AND ipsyst-massn   = c_19 AND  innnn-infty  NE c_0598 AND i001p-molga = c_37.

innnn-begda+6(2) = c_01.

ENDIF.
*** fim grupo assa - natalino 26082008
* begin @0001 t3jesusrg
IF ipsyst-land EQ 'PE'.
CASE innnn-infty.
* Infotipo 9051: Sistemas Previsionales
  WHEN '9051'.
*   Validación 1: Advertencia en Caso de Cambios de Sistema Previsional.

    CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
      EXPORTING
        prelp = innnn
      IMPORTING
        pnnnn = w_p9051.

    SELECT SINGLE abkrs INTO l_abkrs
                        FROM pa0001
                       WHERE pernr EQ innnn-pernr
                         AND begda LE innnn-endda
                         AND endda GE innnn-begda.

      CALL FUNCTION 'CD_GET_PERMO'
        EXPORTING
          payroll_area              = l_abkrs
        IMPORTING
          period_modifier           = l_permo
        EXCEPTIONS
          period_modifier_not_found = 1
          OTHERS                    = 2.
      IF sy-subrc <> 0.
      ENDIF.

      IF l_permo EQ '01'.
        IF w_p9051-begda+6(2) NE '01'.
          MESSAGE w016(rp) WITH 'Cambios deberían ser con Fecha 1ro. del Mes'.
        ENDIF.
      ENDIF.


      IF l_permo EQ '03'.
        CALL FUNCTION 'HRAR_GET_PAYROLL_PERIOD'
          EXPORTING
            permo = l_permo
            date  = w_p9051-begda
          IMPORTING
            begda = l_begda
            endda = l_endda
            pabrj = l_pabrj
            pabrp = l_pabrp.

        IF w_p9051-begda NE l_begda.
          MESSAGE w016(rp) WITH 'Cambios deberían ser con Fecha Inicio de Mes'.
        ENDIF.
      ENDIF.
* inicio @0003 01032017
    WHEN '0009'.
      CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
        EXPORTING
          prelp = innnn
        IMPORTING
          pnnnn = w_p0009.

      IF w_p0009-subty = '0'.
        IF w_p0009-bkont IS INITIAL.
          MESSAGE w016(rp) WITH 'Completar Campo Clave de Control de Bancos'.
        ENDIF.
        IF w_p0009-zweck IS INITIAL.
          MESSAGE w016(rp) WITH 'Completar Campo Cuenta Interbancaria'.
        ENDIF.
      ENDIF.
* fin @0003 01032017

* T3CARLOSCT  @0007 Inicio 29.09.2017
    WHEN '0267'.
      DATA: l_mess TYPE char100.
      CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
        EXPORTING
          prelp = innnn
        IMPORTING
          pnnnn = w_p0267.

      REFRESH: t_t52ocw[].

      IF w_p0267-ocrsn NE 'ZVAC'.
        SELECT * FROM t52ocw INTO TABLE t_t52ocw
        WHERE molga EQ ipsyst-land   AND ocrsn EQ w_p0267-ocrsn
          AND lgart EQ w_p0267-lgart AND begda LE w_p0267-endda
          AND endda GE w_p0267-begda.

          READ TABLE t_t52ocw ASSIGNING <f_t52ocw> INDEX 1.
          IF sy-subrc NE 0.
            CONCATENATE 'Concepto No Válido Para Nómina Especial ' space w_p0267-ocrsn INTO l_mess.
            MESSAGE e045(zhr02) WITH l_mess.
          ENDIF.
        ELSE.
          IF ( w_p0267-lgart EQ '8V14' OR w_p0267-lgart EQ '4D12' ).
*            CONCATENATE 'Concepto No Válido Para Nómina Especial ' space w_p0267-ocrsn INTO l_mess.
*            MESSAGE e045(zhr02) WITH l_mess.
          ELSE.
            CONCATENATE 'Concepto No Válido Para Nómina Especial ' space w_p0267-ocrsn INTO l_mess.
            MESSAGE e045(zhr02) WITH l_mess.
          ENDIF.
        ENDIF.


* T3CARLOSCT  @0007 Fin 29.09.2017
*     {Insert @0007
      WHEN '2012'.
* types
        TYPES: BEGIN OF y_lics,
                 pernr LIKE p2012-pernr,
                 anzhl LIKE p2012-anzhl,
                 trfgb LIKE p0008-trfgb,
                 begda LIKE p2012-begda,
               END OF y_lics.

* tablas internas
        DATA: t_lics TYPE STANDARD TABLE OF y_lics INITIAL SIZE 0.
        DATA: t_rangos  LIKE zsthr_erangos OCCURS 10 WITH HEADER LINE.
        DATA: t_rangos_dm  LIKE zsthr_erangos OCCURS 10 WITH HEADER LINE.
        DATA: t_p0008_lics TYPE TABLE OF p0008.

        DATA: w_p0008_lics   TYPE  p0008,
              t_p8_sindicato TYPE STANDARD TABLE OF p0008,
              l_kwert        TYPE t511k-kwert,
              l_trfgb        TYPE p0008-trfgb,
              l_anzhl        TYPE p2012-anzhl,
              l_mensaje      TYPE c LENGTH 100,
              l_mensaje1     TYPE c LENGTH 100,
              l_sindi        TYPE ztbhr_9906-const,
              w_p2012        TYPE p2012,
              w_p2001        TYPE p2001,
              w_lics         TYPE y_lics,
              v_lics(4)      TYPE c,
              l_fechaini     LIKE sy-datum,
              l_fechafin     LIKE sy-datum.



        CONSTANTS: c_lics    TYPE ztbhr_9906-field VALUE 'LICS',

                   c_desm    TYPE ztbhr_9906-const VALUE 'DESM',
                   c_tope    TYPE ztbhr_9906-field VALUE 'TOPE',
                   c_7042(4) TYPE c VALUE '7042',
                   c_7022(4) TYPE c VALUE '7022',
                   c_7053(4) TYPE c VALUE '7053',
                   c_subty   TYPE ztbhr_9906-const VALUE 'SUBTY'.


        FIELD-SYMBOLS: <f_p0008>        TYPE p0008,
                       <f_t511k>        TYPE t511k,
                       <f_p2001>        TYPE pa2001,
                       <f_p2012>        TYPE p2012,
                       <f_p8_sindicato> TYPE p0008.


* obtiene lo registrado en el infotipo
        CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
          EXPORTING
            prelp = innnn
          IMPORTING
            pnnnn = w_p2012.

* obtiene constante subtipo licencia sindical
        CALL FUNCTION 'ZFHR_HCC99_LEER_VALOR_CONSTANT'
          EXPORTING
            p_molga             = c_pe2
            p_agrup             = 'ZXPADU02'
            p_field             = c_lics
            p_seqnr             = '001'
            p_const             = c_subty
            p_signo             = 'I'
            p_opcion            = 'EQ'
            p_begda             = w_p2012-begda
            p_endda             = w_p2012-endda
          IMPORTING
            p_low               = v_lics
*                     P_HIGH              =
          EXCEPTIONS
            no_existe_constante = 1
            OTHERS              = 2.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.


* solo para licencia sindical
        CHECK w_p2012-subty EQ v_lics.

* se arma fecha con inicio y fin del año en proceso.
        IF ipsyst-bukrs = c_7042.
          CONCATENATE w_p2012-begda+0(6) '01' INTO l_fechaini.

          CALL FUNCTION 'LAST_DAY_OF_MONTHS'
            EXPORTING
              day_in            = l_fechaini
            IMPORTING
              last_day_of_month = l_fechafin
            EXCEPTIONS
              day_in_no_date    = 1
              OTHERS            = 2.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.

        ELSE.
          CONCATENATE w_p2012-begda+0(4) '0101' INTO l_fechaini.
          CONCATENATE w_p2012-begda+0(4) '1231' INTO l_fechafin.
        ENDIF.
* se obtiene datos del sindicato al que pertenece la persona.
        CALL FUNCTION 'HR_READ_INFOTYPE'
          EXPORTING
            tclas           = 'A'
            pernr           = w_p2012-pernr
            infty           = '0008'
            begda           = w_p2012-begda
            endda           = w_p2012-begda
            bypass_buffer   = 'X'
          TABLES
            infty_tab       = t_p0008_lics
          EXCEPTIONS
            infty_not_found = 1
            OTHERS          = 2.
        IF sy-subrc EQ 0.
*          SORT t_p12001 BY
          READ TABLE t_p0008_lics INDEX 1 INTO w_p0008_lics.
          l_sindi = w_p0008_lics-trfgb.
        ENDIF.

*obtner todo el personal activo, que pertenezca al mismo
*sindicato y que tengan licencia sindical en el año de proceso

        CLEAR w_lics-anzhl.
        SELECT  SUM( a~anzhl )
          INTO w_lics-anzhl
          FROM
         ( pa2012 AS a INNER JOIN pa0008   AS b
          ON a~pernr EQ b~pernr )
          INNER JOIN pa0000 AS c
          ON a~pernr EQ c~pernr
          WHERE  a~begda >= l_fechaini AND
                a~begda <= l_fechafin AND
                a~subty = v_lics AND
                b~trfgb = w_p0008_lics-trfgb AND
                c~stat2 EQ '3' AND
                c~endda EQ '99991231'.

          IF sy-subrc = 0.
* se sumariza lo acumulado + lo que se desea ingresar
            w_lics-anzhl = w_lics-anzhl + w_p2012-anzhl.

          ENDIF.



*obtengo constantes
          CALL FUNCTION 'ZFHR_HCC99_LEER_RANGO_CONSTANT'
            EXPORTING
              p_molga             = c_pe2
              p_agrup             = 'ZXPADU02'
              p_field             = c_tope
              p_const             = l_sindi
              p_begda             = w_p2012-begda
              p_endda             = w_p2012-begda
            TABLES
              pt_rango            = t_rangos
            EXCEPTIONS
              no_existe_constante = 1
              OTHERS              = 2.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.

* lectura del sindicato
          READ TABLE t_rangos INDEX 1.
* si es CJM
          IF w_lics-anzhl GT t_rangos-low  .
            IF ipsyst-bukrs = c_7022 OR ipsyst-bukrs = c_7053.
              MESSAGE i368(00) WITH TEXT-067.
            ELSE .
              MESSAGE i368(00) WITH TEXT-067.
            ENDIF.


          ENDIF.

        WHEN '2001'. "Guardas datos de absentismos en tabla para spring

          " CHECK sy-ucomm IS NOT INITIAL AND sy-ucomm NE sy-pfkey.
          .
          IF sy-tcode EQ c_pa30.

            IF sy-pfkey NE 'EDQ'.
              IF innnn-sprps IS NOT INITIAL.
                DATA: l_flag TYPE xfeld.
                l_flag = 'X'.
                CHECK l_flag IS INITIAL.
              ENDIF.
            ENDIF.

            DATA: w_data    TYPE ztbhr_time_sprin,
                  l_cod_dms TYPE char4.
            DATA: lp_mozko LIKE t556a-mozko,
                  l_low    LIKE ztbhr_9906-low,
                  l_high   LIKE ztbhr_9906-high.
            DATA: t_p0014 LIKE p0014 OCCURS 10 WITH HEADER LINE.
            RANGES: r_lgart2 FOR t512t-lgart.

            FIELD-SYMBOLS: <fs1>, <fs2>.
*
            CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
              EXPORTING
                prelp = innnn
              IMPORTING
                pnnnn = w_p2001.

            REFRESH t_p0014. CLEAR: t_p0014.
            rp-read-infotype w_p2001-pernr 0014 t_p0014 w_p2001-begda w_p2001-begda.


** @0008 - CC-20200917 - Inicio
*         Crear o Modificar registro
*         IF sy-pfkey EQ c_ins OR sy-pfkey EQ c_mod.
            IF sy-pfkey+4(3) EQ c_ins OR sy-pfkey+4(3) EQ c_mod  OR sy-pfkey+4(3) EQ c_cop.

*           Vacaciones Perú
              IF w_p2001-awart EQ c_pe_awart_1000.
                CLEAR: l_anzhl_qtneg.
                CLEAR: lp_mozko.
                "PERFORM zcambiar_agrup_sdp_tipo_cont USING    <fs2> <fs1> innnn-begda
                "                             CHANGING lp_mozko.
                REFRESH: r_lgart2.
                r_lgart2-sign = 'I'.
                r_lgart2-option = 'EQ'.
                r_lgart2-low = '1F27'.
                APPEND r_lgart2.

                lp_mozko = i001p-mozko.

                LOOP AT t_p0014 WHERE lgart IN r_lgart2.
*                 PERFORM zobtener_mozko USING    'PE' t_p0014-lgart w_p2012-begda
*                                         CHANGING lp_mozko. "p_mozko.
                  CALL FUNCTION 'ZFHR_HCC99_LEER_VALOR_CONSTANT'
                    EXPORTING
                      p_molga             = 'PE' "p_molga
                      p_agrup             = 'MP200100' "w_const-agrup
                      p_field             = 'MOZKO' "w_const-field
                      p_seqnr             = '000' "w_const-seqnr
                      p_const             = 'AGRUP_TIPO_CONT' "w_const-const
                      p_signo             = '' "w_const-signo
                      p_opcion            = '' "w_const-opcio
                      p_begda             = w_p2001-begda
                      p_endda             = w_p2001-begda
                    IMPORTING
                      p_low               = l_low
                      p_high              = l_high
                    EXCEPTIONS
                      no_existe_constante = 1
                      OTHERS              = 2.

                  IF l_low EQ space.
                  ELSE.
                    lp_mozko = l_low.
                  ENDIF.

                  EXIT.
                ENDLOOP.

                SELECT SINGLE qtneg INTO l_anzhl_qtneg FROM t556a
                                                      WHERE mopgk EQ i503-konty
                                                        AND mozko EQ lp_mozko "i001p-mozko
                                                        AND ktart EQ c_pe_ktart_90
                                                        AND endda GE innnn-begda
                                                        AND begda LE innnn-endda.
                  IF sy-subrc EQ 0 AND l_anzhl_qtneg NE 0.
                    IF l_anzhl_qtneg LT 0.
                      l_anzhl_qtneg =  l_anzhl_qtneg * -1.
                    ENDIF.

*               Obtener registros de contingente
                    REFRESH: t_p2006. CLEAR: t_p2006, l_anzhl_vac.
                    rp-read-infotype w_p2001-pernr 2006 t_p2006 '19000101' '99991231'.
*               Leer registros y sumar cantidad
                    LOOP AT t_p2006.
                      IF t_p2006-ktart EQ '90'. "OR t_p2006-ktart EQ '91' OR t_p2006-ktart EQ '92'.
                        l_anzhl_vac = l_anzhl_vac + ( t_p2006-anzhl - t_p2006-kverb ).
                      ELSE.
                        DELETE t_p2006.
                      ENDIF.
                    ENDLOOP.

*               Si es negativo, ya tiene vacaciones negativas
                    IF l_anzhl_vac LT 0.
                      l_anzhl_tope = l_anzhl_qtneg - ( l_anzhl_vac * -1 ).

                      IF l_anzhl_tope LT w_p2001-kaltg.
                        MESSAGE e014(hrtim00rec).
                      ENDIF.
                    ELSE.
                      IF l_anzhl_vac LT l_anzhl_qtneg.
                        IF w_p2001-kaltg GT l_anzhl_qtneg.
                          MESSAGE e014(hrtim00rec) WITH '10' ' ' ' ' w_p2001-pernr.
                        ENDIF.
                      ENDIF.
                    ENDIF. "IF l_anzhl_vac LT 0
                  ENDIF. "IF sy-subrc EQ 0

                ENDIF. "IF w_p2001 EQ c_pe_awart_1000
              ENDIF. "IF sy-pfkey EQ c_ins OR sy-pfkey EQ c_mod.
** @0008 - CC-20200917 - Fin

* Obtenemos sociedad del empleado
              CLEAR w_pa0001.
              SELECT SINGLE *
                       FROM pa0001
                       INTO w_pa0001
                      WHERE pernr = innnn-pernr
                        AND endda GE w_p2001-begda AND
                            begda LE w_p2001-endda.

* Validamos solo cajamarquilla
                CHECK w_pa0001-bukrs EQ c_7042.

* Obtenemos quivalencia de conceptos
                SELECT SINGLE con_dms FROM ztbhr_depara_tim INTO l_cod_dms
                     WHERE
                           bukrs EQ c_7042 AND
                           infty EQ c_z2001 AND
                           con_sap EQ w_p2001-subty.

* Obtenemos datos del absentismo para guardar en tabla

                  SELECT MAX( cod_corr ) INTO w_data-cod_corr FROM ztbhr_time_sprin CLIENT SPECIFIED.

                    ADD 1 TO w_data-cod_corr.
                    w_data-mandt = sy-mandt.
                    w_data-cod_abs = l_cod_dms.
                    w_data-pernr = w_p2001-pernr.
                    w_data-fecha_ini = w_p2001-begda.
                    w_data-fecha_fin = w_p2001-endda.

                    CASE sy-pfkey.
                      WHEN c_ins.
                        IF w_p2001-sprps IS INITIAL.
                          w_data-accion = c_inse.
                        ENDIF.
                      WHEN c_mod.
                        w_data-accion = c_modi.
                      WHEN c_del.
                        w_data-accion = c_dele.
*              DELETE FROM ZTBHR_TIME_SPRIN.
                      WHEN c_bloq.
                        IF w_p2001-sprps IS NOT INITIAL.
                          w_data-accion = c_dele.
                        ELSE.
                          w_data-accion = c_inse.
                        ENDIF.
                      WHEN OTHERS.
                    ENDCASE.

                    TRY .
                        INSERT INTO ztbhr_time_sprin VALUES w_data.
                        IF sy-subrc EQ 0.

                        ENDIF.
                      CATCH cx_sy_open_sql_db.
                        MESSAGE 'Error al insertar en tabla' TYPE 'S' DISPLAY LIKE 'E'.
                    ENDTRY.
                  ENDIF.

*     }Insert @0007


              ENDCASE.
            ENDIF.
* end @0001 t3jesusrg


* Begin of mod T3RONALDN - Roll Out Milpo 18.06.2013
            v_bname = sy-uname.

* verificamos que el USUARIO sea de Perú
            SELECT SINGLE parva INTO v_parva FROM usr05
              WHERE bname EQ v_bname
                AND parid EQ c_ugr.

              IF v_parva EQ c_pe OR v_parva EQ c_pe2. "@0001 T3JESUSRG INSERT
* buscamos la empresa del usuario
                SELECT SINGLE parva INTO v_parva FROM usr05
                    WHERE bname EQ v_bname
                      AND parid EQ c_buk.

                  IF sy-subrc EQ 0.
* accedemos a las constantes de empresas
                    SELECT SINGLE zvlpar FROM ztbbc_parametros INTO v_zvlpar
                      WHERE programm EQ c_program
                        AND zparam   EQ c_zparam.

*   asignamos las empresas a la tabla de empresas
                      SPLIT v_zvlpar AT c_pv INTO TABLE t_bukrs.
                      MOVE: c_i TO r_bukrs-sign,
                            c_eq TO r_bukrs-option.

*   recorremos la tabla sociedades para completar el rango
                      LOOP AT t_bukrs.
                        IF NOT t_bukrs IS INITIAL.
                          MOVE: t_bukrs-valor TO r_bukrs-low.
                          APPEND r_bukrs.
                        ENDIF.
                      ENDLOOP.

*   si empresa de usuario existe en el rango ..........
                      IF v_parva IN r_bukrs.
* Begin of mod T3MARIAGF - Roll Out Milpo 07.08.2013

                        " verificamos que estemos en la trx PA40 o PA30
                        IF sy-tcode = c_pa40 OR sy-tcode = c_pa30 AND sy-ucomm = c_upd.

                          CALL FUNCTION 'ZFSD_CONSTANTES1'
                            EXPORTING
                              i_code           = sy-repid
                              i_param          = c_bukrs
                            TABLES
                              ztbbc_parametros = t_parametros.

                          SORT t_parametros BY zvlpar.

                          READ TABLE t_parametros WITH KEY zvlpar = ipsyst-bukrs BINARY SEARCH TRANSPORTING NO FIELDS.
                          IF sy-subrc = 0.

                            " accedemos a la tabla de parametros filtrando con infotipo
                            SELECT * FROM ztbhr_par_infoca
                              INTO TABLE t_param
                              WHERE infty EQ innnn-infty.

                              IF sy-subrc EQ 0.
                                " si encontramos parametros accedemos a la tabla de salida y traemos el
                                " último idlinea.
                                SELECT MAX( idlinea ) AS max FROM ztbhr_int_infoca INTO l_linea.

                                  " recorremos la tabla de parametros
                                  LOOP AT t_param INTO w_param.
                                    " incrementamos de a uno el idlinea
                                    l_linea = l_linea + 1.

                                    " armamos path para obtener valor
                                    l_path+3(4)  = w_param-infty(4).
                                    l_path+11(4) = w_param-infty(4).
                                    " concatenamos path con nombre de campo
                                    CONCATENATE l_path w_param-fname INTO l_campo.
                                    ASSIGN (l_campo) TO <f_campo>.
                                    l_valor = <f_campo>.

                                    " segun infotipo validamos para grabar
                                    CASE w_param-infty.

                                      WHEN c_z0105.
                                        " armamos path para obtener valor
                                        l_path+3(4)  = w_param-infty(4).
                                        l_path+11(4) = w_param-infty(4).
                                        " concatenamos path con nombre de campo
                                        CONCATENATE l_path c_usrty INTO l_campo.
                                        ASSIGN (l_campo) TO <f_var>.
                                        CHECK <f_var> IS ASSIGNED.
                                        l_var = <f_var>.

                                        CASE w_param-fname.
                                          WHEN c_usrid_long.
                                            IF l_var EQ c_z9000 OR  "9000
                                               l_var EQ c_z0003 OR  "0003
                                               l_var EQ c_z0010.    "0010
                                              l_x = c_x.
                                            ELSE.
                                              l_linea = l_linea - 1.
                                            ENDIF.
                                          WHEN OTHERS.
                                            l_x = c_x.
                                        ENDCASE.

                                      WHEN c_0022.
                                        CASE w_param-fname.
                                          WHEN c_slart.
                                            " cargamos el nivel de formacion mas alta
                                            SELECT MAX( slart ) AS max FROM pa0022 INTO l_valor
                                              WHERE pernr EQ innnn-pernr.
                                              IF sy-subrc EQ 0.
                                                l_x = c_x.
                                              ELSE.
                                                l_linea = l_linea - 1.
                                              ENDIF.
                                            WHEN OTHERS.
                                              l_x = c_x.
                                          ENDCASE.

                                        WHEN c_0002.
                                          CASE w_param-fname.
                                            WHEN c_gesch.
                                              IF l_valor EQ c_uno.
                                                l_valor = c_m.
                                              ELSE.
                                                l_valor = c_f.
                                              ENDIF.
                                              l_x = c_x.
                                            WHEN  c_aedtm.
                                              IF l_valor = c_initial.
                                                l_valor = sy-datum.
                                              ENDIF.
                                            WHEN OTHERS.
                                              l_x = c_x.
                                          ENDCASE.

                                        WHEN c_z0465.
                                          " armamos path para obtener valor
                                          l_path+3(4)  = w_param-infty(4).
                                          l_path+11(4) = w_param-infty(4).
                                          " concatenamos path con nombre de campo
                                          CONCATENATE l_path c_tpdoc INTO l_campo.
                                          ASSIGN (l_campo) TO <f_var>.
                                          CHECK <f_var> IS ASSIGNED.
                                          l_var = <f_var>.

                                          CASE w_param-fname.
                                            WHEN c_ident_nr.
                                              IF l_var EQ c_z0002 OR
                                                 l_var EQ c_z9006 OR
                                                 l_var EQ c_z0007.
                                                l_x = c_x.
                                              ELSE.
                                                l_linea = l_linea - 1.
                                              ENDIF.
                                            WHEN c_mil_nr.
                                              IF l_var EQ c_z0007.
                                                l_x = c_x.
                                              ELSE.
                                                l_linea = l_linea - 1.
                                              ENDIF.
                                            WHEN c_tpdoc.
                                              IF l_var EQ c_z0002 OR
                                                 l_var EQ c_z9006.
                                                l_x = c_x.
                                              ELSE.
                                                l_linea = l_linea - 1.
                                              ENDIF.
                                            WHEN OTHERS.
                                              l_x = c_x.
                                          ENDCASE.

                                        WHEN c_z0009.
                                          " armamos path para obtener valor
                                          l_path+3(4)  = w_param-infty(4).
                                          l_path+11(4) = w_param-infty(4).
                                          " concatenamos path con nombre de campo
                                          CONCATENATE l_path c_bnksa INTO l_campo.
                                          ASSIGN (l_campo) TO <f_var>.
                                          CHECK <f_var> IS ASSIGNED.
                                          l_var = <f_var>.
*begin @0001 T3JESUSRG  delete
*                    CASE w_param-fname.
*                      WHEN c_bankl.
*                        IF l_var EQ c_pe02 OR
*                           l_var EQ c_pe03 OR
*                           l_var EQ c_pe01.
*                          l_x = c_x.
*                        ELSE.
*                          l_linea = l_linea - 1.
*                        ENDIF.
*                      WHEN c_waers.
*                        IF l_var EQ c_pe02 OR
*                           l_var EQ c_pe03 OR
*                           l_var EQ c_pe01.
*                          l_x = c_x.
*                        ELSE.
*                          l_linea = l_linea - 1.
*                        ENDIF.
*                      WHEN c_bankn.
*                        IF l_var EQ c_pe02 OR
*                           l_var EQ c_pe03 OR
*                           l_var EQ c_pe01.
*                          l_x = c_x.
*                        ELSE.
*                          l_linea = l_linea - 1.
*                        ENDIF.
*                      WHEN c_bkont.
*                        IF l_var EQ c_pe02 OR
*                           l_var EQ c_pe03 OR
*                           l_var EQ c_pe01.
*                          l_x = c_x.
*                        ELSE.
*                          l_linea = l_linea - 1.
*                        ENDIF.
*                      WHEN OTHERS.
*                        l_x = c_x.
*                    ENDCASE.
* @0001 T3JESUSRG END DELETE
* @0001 T3JESUSRG BEGIN INSERT 29112016
                                          CASE w_param-fname.

                                            WHEN c_bankl.
                                              IF l_var EQ c_pe0 OR
                                                 l_var EQ c_pe5 .
                                                l_x = c_x.
                                              ELSE.
                                                l_linea = l_linea - 1.
                                              ENDIF.
                                            WHEN c_waers.
                                              IF l_var EQ c_pe0 OR
                                                l_var EQ c_pe5 .
                                                l_x = c_x.
                                              ELSE.
                                                l_linea = l_linea - 1.
                                              ENDIF.
                                            WHEN c_bankn.
                                              IF l_var EQ c_pe0 OR
                                                 l_var EQ c_pe5 .
                                                l_x = c_x.
                                              ELSE.
                                                l_linea = l_linea - 1.
                                              ENDIF.
                                            WHEN c_bkont.
                                              IF l_var EQ c_pe0 OR
                                                l_var EQ c_pe5 .
                                                l_x = c_x.
                                              ELSE.
                                                l_linea = l_linea - 1.
                                              ENDIF.
                                            WHEN OTHERS.
                                              l_x = c_x.
                                          ENDCASE.
*@0001 T3JESUSRG end insert
                                        WHEN c_z0016.
                                          CASE w_param-fname.
                                            WHEN c_ctedt.
                                              " si campo esta vacio le asignamos valor
                                              IF l_valor IS INITIAL.
                                                l_valor = c_fecha. "'31.12.9999'.
                                              ENDIF.
                                              l_x = c_x.
                                            WHEN c_aedtm.
                                              IF l_valor =  c_initial.
                                                l_valor = sy-datum.
                                              ENDIF.
                                              l_x = c_x.
*    @0001 T3JESUSRG BEGIN INSERT
                                            WHEN c_cttyp.
                                              CLEAR:v_vaux.
                                              SELECT SINGLE val_dest INTO v_vaux
                                                FROM ztbhr_depara_int
                                                WHERE field EQ c_cttyp  AND
                                                      val_orig EQ l_valor.
                                                IF sy-subrc EQ '0'.
                                                  CONDENSE v_vaux NO-GAPS.
                                                  l_valor = v_vaux.
                                                  l_x = c_x.
                                                ELSE.
                                                  l_linea = l_linea - 1.
                                                ENDIF.
*   @0001 T3JESUSRG end insert

                                              WHEN OTHERS.
                                                l_x = c_x.
                                            ENDCASE.

                                          WHEN c_z0167.
                                            CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
                                              EXPORTING
                                                prelp = innnn
                                              IMPORTING
                                                pnnnn = w_p0167n.

                                            CASE w_param-fname.
* @0001 T3JESUSRG begin insert
                                              WHEN c_pltyp.
                                                IF w_p0167n-sprps = 'X'.
                                                  l_valor = 'MED1'.
                                                  l_x = c_x.
                                                ELSE.
                                                  CLEAR:v_vaux.
                                                  SELECT SINGLE val_dest INTO v_vaux
                                                    FROM ztbhr_depara_int
                                                    WHERE field EQ c_pltyp  AND
                                                          val_orig EQ l_valor.
                                                    IF sy-subrc EQ '0'.
                                                      CONDENSE v_vaux NO-GAPS.
                                                      l_valor = v_vaux.
                                                      l_x = c_x.
                                                    ELSE.
                                                      l_linea = l_linea - 1.
                                                    ENDIF.
                                                  ENDIF.
                                                WHEN c_bplan.
                                                  IF w_p0167n-sprps = 'X'.
                                                    l_valor = 'SIS'.
                                                    l_x = c_x.
                                                  ELSE.
                                                    CLEAR:v_vaux.
                                                    SELECT SINGLE val_dest INTO v_vaux
                                                      FROM ztbhr_depara_int
                                                      WHERE field EQ c_bplan  AND
                                                            val_orig EQ l_valor.
                                                      IF sy-subrc EQ '0'.
                                                        CONDENSE v_vaux NO-GAPS.
                                                        l_valor = v_vaux.
                                                        l_x = c_x.
                                                      ELSE.
                                                        l_linea = l_linea - 1.
                                                      ENDIF.
                                                    ENDIF.

                                                  WHEN c_bopti.
                                                    IF w_p0167n-sprps = 'X'.
                                                      l_valor = 'ESS'.
                                                      l_x = c_x.
                                                    ELSE.
                                                      CLEAR:v_vaux.
                                                      SELECT SINGLE val_dest INTO v_vaux
                                                        FROM ztbhr_depara_int
                                                        WHERE field EQ c_bopti  AND
                                                              val_orig EQ l_valor.
                                                        IF sy-subrc EQ '0'.
                                                          CONDENSE v_vaux NO-GAPS.
                                                          l_valor = v_vaux.
                                                          l_x = c_x.
                                                        ELSE.
                                                          l_linea = l_linea - 1.
                                                        ENDIF.
                                                      ENDIF.
                                                    WHEN c_depcv.
                                                      IF w_p0167n-sprps = 'X'.
                                                        l_valor = 'ESS'.
                                                        l_x = c_x.
                                                      ELSE.
                                                        CLEAR:v_vaux.
                                                        SELECT SINGLE val_dest INTO v_vaux
                                                          FROM ztbhr_depara_int
                                                          WHERE field EQ c_depcv  AND
                                                                val_orig EQ l_valor.
                                                          IF sy-subrc EQ '0'.
                                                            CONDENSE v_vaux NO-GAPS.
                                                            l_valor = v_vaux.
                                                            l_x = c_x.
                                                          ELSE.
                                                            l_linea = l_linea - 1.
                                                          ENDIF.
                                                        ENDIF.
                                                      WHEN c_barea.
                                                        CLEAR:v_vaux.
                                                        SELECT SINGLE val_dest INTO v_vaux
                                                          FROM ztbhr_depara_int
                                                          WHERE field EQ c_barea  AND
                                                                val_orig EQ l_valor.
                                                          IF sy-subrc EQ '0'.
                                                            CONDENSE v_vaux NO-GAPS.
                                                            l_valor = v_vaux.
                                                            l_x = c_x.
                                                          ELSE.
                                                            l_linea = l_linea - 1.
                                                          ENDIF.


* @0001 T3JESUSRG end insert
*                      WHEN C_BOPTI.
*                        SELECT SINGLE BOPTI FROM PA0167 INTO L_BOPTI
*                          WHERE BPLAN EQ C_EPS    AND
*                                BEGDA LT SY-DATUM AND
*                                ENDDA GT SY-DATUM AND
*                                PERNR EQ INNNN-PERNR.
*                        IF SY-SUBRC IS INITIAL.
*                          L_X = C_X.
*                        ELSE.
*                          L_LINEA = L_LINEA - 1.
*                        ENDIF.

                                                        WHEN c_begda.
                                                          SELECT SINGLE begda FROM pa0167 INTO l_fecha
*                          WHERE bplan EQ c_eps    AND "-@0001 T3JESUSRG
                                                             WHERE bplan EQ c_ps01   AND "+@0001 t3jesusrg
                                                                  begda LT sy-datum AND
                                                                  endda GT sy-datum AND
                                                                  pernr EQ innnn-pernr.
                                                            IF sy-subrc IS INITIAL.
                                                              l_x = c_x.
                                                            ELSE.
*                          l_linea = l_linea - 1.  "-@0001 t3jesusrg
                                                              l_x = c_x.
                                                            ENDIF.
                                                          WHEN c_endda.
                                                            SELECT SINGLE endda FROM pa0167 INTO l_fecha
*                          WHERE bplan EQ c_eps    AND "-@0001 t3jesusrg
                                                                WHERE bplan EQ   c_ps01    AND "+@0001 t3jesusrg
                                                                    begda LT sy-datum AND
                                                                    endda GT sy-datum AND
                                                                    pernr EQ innnn-pernr.
                                                              IF sy-subrc IS INITIAL.
                                                                l_x = c_x.
                                                              ELSE.
                                                                l_linea = l_linea - 1.
                                                              ENDIF.
                                                            WHEN OTHERS.
                                                              l_x = c_x.
                                                          ENDCASE.

***@00001 BEGIN DELETE
*                  WHEN c_z0168.
*                    CASE w_param-fname.
*                      WHEN c_bplan.
*                        SELECT SINGLE bplan FROM pa0168 INTO l_bplan
*                          WHERE ( pltyp EQ c_ctrp OR
*                                pltyp EQ c_ctrs ) AND
*                                begda LT sy-datum AND
*                                endda GT sy-datum AND
*                                pernr EQ innnn-pernr.
*                        IF sy-subrc IS INITIAL.
*                          l_x = c_x.
*                        ELSE.
*                          l_linea = l_linea - 1.
*                        ENDIF.
*                      WHEN c_begda.
*                        SELECT SINGLE begda FROM pa0168 INTO l_fecha
*                          WHERE ( pltyp EQ c_ctrp OR
*                                pltyp EQ c_ctrs ) AND
*                                begda LT sy-datum AND
*                                endda GT sy-datum AND
*                                pernr EQ innnn-pernr.
*                        IF sy-subrc IS INITIAL.
*                          l_x = c_x.
*                        ELSE.
*                          l_linea = l_linea - 1.
*                        ENDIF.
*                      WHEN c_endda.
*                        SELECT SINGLE endda FROM pa0168 INTO l_fecha
*                          WHERE ( pltyp EQ c_ctrp OR
*                                pltyp EQ c_ctrs ) AND
*                                begda LT sy-datum AND
*                                endda GT sy-datum AND
*                                pernr EQ innnn-pernr.
*                        IF sy-subrc IS INITIAL.
*                          l_x = c_x.
*                        ELSE.
*                          l_linea = l_linea - 1.
*                        ENDIF.
*                      WHEN OTHERS.
*                        l_x = c_x.
*                    ENDCASE.
***@00001 END DELETE

                                                        WHEN c_z0000.
                                                          CASE w_param-fname.
                                                            WHEN c_begda.
                                                              " fecha de ingreso y cese
                                                              SELECT begda massn stat2 FROM pa0000
                                                                INTO TABLE t_p000
                                                                  WHERE pernr EQ innnn-pernr AND
                                                                        massn EQ c_01       OR
                                                                        stat2 EQ c_0.

                                                                IF sy-subrc IS INITIAL.

                                                                  SORT t_p000 BY begda ASCENDING.
                                                                  READ TABLE t_p000 INTO w_p000 WITH KEY massn = c_01.
                                                                  IF sy-subrc IS INITIAL.
*                      l_valor = w_p000-begda.
                                                                    l_x = c_x.
                                                                  ELSE.
                                                                    READ TABLE t_p000 INTO w_p000 WITH KEY stat2 = c_0.
                                                                    IF sy-subrc IS INITIAL.
*                        l_valor = w_p000-begda.
                                                                      l_valor = w_p000-begda -  1. "+@0001
                                                                      l_x = c_x.
                                                                    ELSE.
                                                                      l_linea = l_linea - 1.
                                                                    ENDIF.
                                                                  ENDIF.
                                                                ENDIF.
* inicio +{@0001
                                                                IF ipsyst-massn =  '10'.
                                                                  l_fec_cese = ipsyst-ddate - 1.
                                                                  l_valor = l_fec_cese.
                                                                ENDIF.
* fin +@0001}
                                                              WHEN c_stat2.  " estado del trabajador
                                                                IF l_valor EQ c_3 OR
                                                                   l_valor EQ c_0 OR
                                                                   l_valor EQ c_uno.
                                                                  l_x = c_x.
                                                                ELSE.
                                                                  l_linea = l_linea - 1.
                                                                ENDIF.
**                  @0001 T3JESUSRG BEGIN INSERT
                                                              WHEN c_massg.
                                                                CLEAR:v_vaux.
                                                                SELECT SINGLE val_dest INTO v_vaux
                                                                  FROM ztbhr_depara_int
                                                                  WHERE field EQ c_massg  AND
                                                                        val_orig EQ l_valor.
                                                                  IF sy-subrc EQ '0'.
                                                                    CONDENSE v_vaux NO-GAPS.
                                                                    l_valor = v_vaux.
                                                                    l_x = c_x.
                                                                  ELSE.
                                                                    l_linea = l_linea - 1.
                                                                  ENDIF.
**                  @0001 T3JESUSRG end INSERT
                                                                WHEN OTHERS.
                                                                  l_x = c_x.
                                                              ENDCASE.
*             when c_0021.
*             when c_0397.

**                  @0001 T3JESUSRG BEGIN INSERT
                                                            WHEN c_z0001.
                                                              CASE w_param-fname.
                                                                WHEN c_f1ansvh.
                                                                  CLEAR:v_vaux.
                                                                  SELECT SINGLE val_dest INTO v_vaux
                                                                    FROM ztbhr_depara_int
                                                                    WHERE field EQ c_f1ansvh  AND
                                                                          val_orig EQ l_valor.
                                                                    IF sy-subrc EQ '0'.
                                                                      CONDENSE v_vaux NO-GAPS.
                                                                      l_valor = v_vaux.
                                                                      l_x = c_x.
                                                                    ELSE.
                                                                      l_linea = l_linea - 1.
                                                                    ENDIF.
                                                                  WHEN c_persk.
                                                                    CLEAR:v_vaux.
                                                                    SELECT SINGLE val_dest INTO v_vaux
                                                                      FROM ztbhr_depara_int
                                                                      WHERE field EQ c_persk AND
                                                                            val_orig EQ l_valor.
                                                                      IF sy-subrc EQ '0'.
                                                                        CONDENSE v_vaux NO-GAPS.
                                                                        l_valor = v_vaux.
                                                                        l_x = c_x.
                                                                      ELSE.
                                                                        l_linea = l_linea - 1.
                                                                      ENDIF.
                                                                    WHEN OTHERS.
                                                                      l_x = c_x.
                                                                  ENDCASE.

                                                                WHEN c_z0008.
                                                                  CASE w_param-fname.
                                                                    WHEN c_trfgb.
                                                                      CLEAR:v_vaux.
                                                                      SELECT SINGLE val_dest INTO v_vaux
                                                                        FROM ztbhr_depara_int
                                                                        WHERE field EQ c_trfgb  AND
                                                                              val_orig EQ l_valor.
                                                                        IF sy-subrc EQ '0'.
                                                                          CONDENSE v_vaux NO-GAPS.
                                                                          l_valor = v_vaux.
                                                                          l_x = c_x.
                                                                        ELSE.
                                                                          l_linea = l_linea - 1.
                                                                        ENDIF.
                                                                      WHEN OTHERS.
                                                                        l_x = c_x.
                                                                    ENDCASE.


                                                                  WHEN c_z0034.
                                                                    CASE w_param-fname.
                                                                      WHEN c_f34funkt.
                                                                        CLEAR v_0034flag.
                                                                        IF l_valor EQ c_v34subty.
                                                                          v_0034flag = 'X'.
                                                                        ENDIF.
                                                                        l_x = c_x.
                                                                      WHEN c_f34zztipotrabsunat.
                                                                        IF v_0034flag EQ 'X'.
                                                                          l_x = c_x.
                                                                        ELSE.
                                                                          l_linea = l_linea - 1.
                                                                        ENDIF.
                                                                      WHEN OTHERS.
                                                                        l_x = c_x.
                                                                    ENDCASE.

                                                                  WHEN c_z0037.

                                                                    CASE w_param-fname.


                                                                      WHEN c_f37vsges.
                                                                        CLEAR:v_vaux.
                                                                        SELECT SINGLE val_dest INTO v_vaux
                                                                          FROM ztbhr_depara_int
                                                                          WHERE field EQ c_f37vsges  AND
                                                                                val_orig EQ l_valor.
                                                                          IF sy-subrc EQ '0'.
                                                                            CONDENSE v_vaux NO-GAPS.
                                                                            l_valor = v_vaux.
                                                                            l_x = c_x.
                                                                          ELSE.
                                                                            l_linea = l_linea - 1.
                                                                          ENDIF.

                                                                        WHEN c_f37zz_riesgo.
                                                                          CLEAR:v_vaux.
                                                                          SELECT SINGLE val_dest INTO v_vaux
                                                                            FROM ztbhr_depara_int
                                                                            WHERE field EQ c_f37zz_riesgo  AND
                                                                                  val_orig EQ l_valor.
                                                                            IF sy-subrc EQ '0'.
                                                                              CONDENSE v_vaux NO-GAPS.
                                                                              l_valor = v_vaux.
                                                                              l_x = c_x.
                                                                            ELSE.
                                                                              l_linea = l_linea - 1.
                                                                            ENDIF.

                                                                          WHEN OTHERS.
                                                                            l_x = c_x.
                                                                        ENDCASE.

                                                                      WHEN c_z9051.
                                                                        CASE w_param-fname.
                                                                          WHEN c_f37emfsl.
                                                                            CLEAR:v_vaux.
                                                                            SELECT SINGLE val_dest INTO v_vaux
                                                                              FROM ztbhr_depara_int
                                                                              WHERE field EQ c_f37emfsl  AND
                                                                                    val_orig EQ l_valor.
                                                                              IF sy-subrc EQ '0'.
                                                                                CONDENSE v_vaux NO-GAPS.
                                                                                l_valor = v_vaux.
                                                                                l_x = c_x.
                                                                              ELSE.
                                                                                l_linea = l_linea - 1.
                                                                              ENDIF.

                                                                            WHEN OTHERS.
                                                                              l_x = c_x.
                                                                          ENDCASE.

                                                                        WHEN c_z0171.
                                                                          CASE w_param-fname.
                                                                            WHEN c_barea.
                                                                              CLEAR:v_vaux.
                                                                              SELECT SINGLE val_dest INTO v_vaux
                                                                                FROM ztbhr_depara_int
                                                                                WHERE field EQ c_barea  AND
                                                                                      val_orig EQ l_valor.
                                                                                IF sy-subrc EQ '0'.
                                                                                  CONDENSE v_vaux NO-GAPS.
                                                                                  l_valor = v_vaux.
                                                                                  l_x = c_x.
                                                                                ELSE.
                                                                                  l_linea = l_linea - 1.
                                                                                ENDIF.
                                                                              WHEN c_bengr.
                                                                                CLEAR:v_vaux.
                                                                                SELECT SINGLE val_dest INTO v_vaux
                                                                                  FROM ztbhr_depara_int
                                                                                  WHERE field EQ c_bengr  AND
                                                                                        val_orig EQ l_valor.
                                                                                  IF sy-subrc EQ '0'.
                                                                                    CONDENSE v_vaux NO-GAPS.
                                                                                    l_valor = v_vaux.
                                                                                    l_x = c_x.
                                                                                  ELSE.
                                                                                    l_linea = l_linea - 1.
                                                                                  ENDIF.
                                                                                WHEN c_bstat.
                                                                                  CLEAR:v_vaux.
                                                                                  SELECT SINGLE val_dest INTO v_vaux
                                                                                    FROM ztbhr_depara_int
                                                                                    WHERE field EQ c_bstat  AND
                                                                                          val_orig EQ l_valor.
                                                                                    IF sy-subrc EQ '0'.
                                                                                      CONDENSE v_vaux NO-GAPS.
                                                                                      l_valor = v_vaux.
                                                                                      l_x = c_x.
                                                                                    ELSE.
                                                                                      l_linea = l_linea - 1.
                                                                                    ENDIF.

                                                                                  WHEN OTHERS.
                                                                                    l_x = c_x.
                                                                                ENDCASE.



**                  @0001 T3JESUSRG END INSERT
                                                                              WHEN OTHERS.
                                                                                IF w_param-fname = c_aedtm AND l_valor =  c_initial.
                                                                                  l_valor = sy-datum.
                                                                                ENDIF.
                                                                                l_x = c_x.
                                                                            ENDCASE.

                                                                            IF l_x IS NOT INITIAL.
                                                                              w_int-idlinea          = l_linea.
                                                                              w_int-pernr            = innnn-pernr.
                                                                              w_int-infty            = innnn-infty.
                                                                              w_int-subty            = innnn-subty.
                                                                              w_int-objps            = innnn-objps.
                                                                              w_int-campo_sap        = w_param-fname.
                                                                              w_int-valor_sap        = l_valor.
                                                                              w_int-begda            = innnn-begda.
                                                                              w_int-endda            = innnn-endda.
                                                                              w_int-fecha_modi       = sy-datum.
                                                                              w_int-hora_modi        = sy-uzeit.
                                                                              w_int-usuario_sap_modi = sy-uname.
* >>> Início das alterações - T3ROLANDOME 25.10.2016
                                                                              INSERT INTO ztbhr_int_infoca VALUES w_int.
* <<< Fim das alterações - T3ROLANDOME 25.10.2016

                                                                              "El insert se realiza en la badi  ZJHR_INT_INTRANET


*                  IF sy-subrc IS NOT INITIAL.
*                    MESSAGE 'Error al actualizar la tabla ZTBHR_INT_INFOCA' TYPE 'E'.
*                  ENDIF.
                                                                              APPEND w_int TO t_zinfoca.
                                                                            ENDIF.
                                                                            CLEAR l_x.
                                                                          ENDLOOP.

* >>> Início das alterações - T3ROLANDOME 25.10.2016
*"El insert se realiza en la badi  ZJHR_INT_INTRANET/INCLUDE ZIHR0220_INTERFAZ_VM
* <<< Fim das alterações - T3ROLANDOME 25.10.2016
*              EXPORT t_zinfoca TO MEMORY ID 'GRABAR_REGISTRO'.
                                                                        ENDIF.
                                                                      ENDIF.
                                                                    ENDIF.
* End of mod T3MARIAGF - Roll Out Milpo 07.08.2013

                                                                  ENDIF.
                                                                ENDIF.
                                                              ENDIF.
* End of mod T3RONALDN - Roll Out Milpo 18.06.2013

*** Inicio de Inclusão - T3DEBORACJ - 25.09.08
* Validar Chave Organizacional
                                                              IF ( sy-tcode = c_pa40 OR
                                                                   sy-tcode = c_pa30 ) AND
                                                                 ( ipsyst-ioper = c_ins OR
                                                                   ipsyst-ioper = c_mod OR
                                                                   ipsyst-ioper = c_upd ) AND
                                                                   innnn-infty = c_0001 AND
                                                                   i001p-molga = c_37   AND
                                                                   innnn-endda = c_99993112.

* Tenta obter os valores da tela do infotipo 0001
                                                                ASSIGN ('(MP000100)P0001-BUKRS') TO <f_bukrs>.
                                                                IF sy-subrc EQ 0.
                                                                  ASSIGN ('(MP000100)P0001-WERKS') TO <f_werks>.
                                                                  IF sy-subrc EQ 0.
                                                                    ASSIGN ('(MP000100)P0001-BTRTL') TO <f_btrtl>.
                                                                    IF sy-subrc EQ 0.
                                                                      ASSIGN ('(MP000100)P0001-VDSK1') TO <f_vdsk1>.
                                                                      IF sy-subrc EQ 0.

*           Busca Chaves Organizacionais válidas
                                                                        SELECT SINGLE vdsk1
                                                                          FROM ztbhr_lotacao
                                                                          INTO v_vdsk1
                                                                         WHERE vdsk1 EQ <f_vdsk1>
                                                                           AND bukrs EQ <f_bukrs>
                                                                           AND werks EQ <f_werks>
                                                                           AND btrtl EQ <f_btrtl>.
* Inicio de alteração - Fernanda Araujo - 16.04.2015
*            IF sy-subrc EQ 0.
**             Se Chave = Terceiro, deve ser Grupo de Empregado 9
*              IF v_vdsk1 EQ c_terceiro AND ipsyst-persg NE c_9.
*                MESSAGE e045(zhr02) WITH 'Chave Organizacional inválida'.
*              ENDIF.
*            ELSE.
*              MESSAGE e045(zhr02) WITH 'Chave Organizacional inválida'.
*            ENDIF.
* Fim de alteração - Fernanda Araujo - 16.04.2015
                                                                        ENDIF.
                                                                      ENDIF.
                                                                    ENDIF.
                                                                  ENDIF.
                                                                ENDIF.



* AJUSTE EC.
* chave organizacional CBA.
* 4050702, INC0228966 - CHAVE ORGANIZACIONAL

                                                                DATA w_p0001c TYPE p0001.
                                                                DATA w_p0695 TYPE p0695.
                                                                RANGES r_bukrs_cba FOR t001-bukrs.

                                                                CALL FUNCTION 'ZFBC_RANGES_PARAMETROS'
                                                                  EXPORTING
                                                                    i_programm      = 'ZXPADU02'
                                                                    i_zparam        = 'BUKRS_CBA'
                                                                  TABLES
                                                                    ranges          = r_bukrs_cba
                                                                  EXCEPTIONS
                                                                    const_not_found = 1
                                                                    wrong_selection = 2
                                                                    OTHERS          = 3.
                                                                IF sy-subrc <> 0.
* Implement suitable error handling here
                                                                ENDIF.

                                                                IF innnn-infty = c_0001 AND
                                                                   i001p-molga = c_37   AND
                                                                   innnn-endda = c_99993112.

                                                                  CLEAR w_p0001c.
                                                                  CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
                                                                    EXPORTING
                                                                      prelp = innnn
                                                                    IMPORTING
                                                                      pnnnn = w_p0001c.

                                                                  IF w_p0001c-bukrs IN r_bukrs_cba[] AND
                                                                     r_bukrs_cba[] IS NOT INITIAL.

*  Busca Chaves Organizacionais válidas
                                                                    CLEAR v_vdsk1.
                                                                    SELECT SINGLE vdsk1
                                                                      FROM ztbhr_lotacao
                                                                      INTO v_vdsk1
                                                                     WHERE
                                                                       bukrs EQ w_p0001c-bukrs
                                                                       AND werks EQ w_p0001c-werks
                                                                       AND btrtl EQ w_p0001c-btrtl.

                                                                      IF v_vdsk1 IS NOT INITIAL.

                                                                        w_p0001c-vdsk1 = v_vdsk1.

                                                                        CALL METHOD cl_hr_pnnnn_type_cast=>pnnnn_to_prelp
                                                                          EXPORTING
                                                                            pnnnn = w_p0001c
                                                                          IMPORTING
                                                                            prelp = innnn.

                                                                      ENDIF.

                                                                    ENDIF.

                                                                  ENDIF.

* AJUSTE EC.
* chave organizacional CBA.
* 4050702, INC0228966 - CHAVE ORGANIZACIONAL

*  IF INNNN-INFTY = '0465' AND
*     INNNN-SUBTY = '0007' AND
*         I001P-MOLGA = C_37   AND
*         INNNN-ENDDA = C_99993112.
*
*    CLEAR W_P0465.
*    CALL METHOD CL_HR_PNNNN_TYPE_CAST=>PRELP_TO_PNNNN
*      EXPORTING
*        PRELP = INNNN
*      IMPORTING
*        PNNNN = W_P0465.
*
*    IF W_P0465-MIL_NR IS NOT INITIAL
*      AND W_P0465-MIL_CAT IS INITIAL.
*
*      W_P0465-MIL_CAT = 'RA'.
*
*      CALL METHOD CL_HR_PNNNN_TYPE_CAST=>PNNNN_TO_PRELP
*        EXPORTING
*          PNNNN = W_P0465
*        IMPORTING
*          PRELP = INNNN.
*
*    ENDIF.
*
*  ENDIF.

***Inicio de Inclusão - T3WELLINGTOV - 27.08.2010
                                                                  IF ipsyst-bukrs(1) = c_3.
                                                                    IF sy-tcode = c_pa40 AND
                                                                       ( ipsyst-ioper = c_ins OR
                                                                         ipsyst-ioper = c_mod OR
                                                                         ipsyst-ioper = c_upd OR
                                                                         ipsyst-ioper = c_cop ) AND
                                                                         innnn-infty  = c_0000  AND
                                                                         innnn-endda  = c_99993112.

                                                                      ASSIGN ('(MP000000)PSPAR-PLANS') TO <f_plans>.
                                                                    ENDIF.

                                                                    IF ( sy-tcode = c_pb40 OR sy-tcode = c_pb30 ) AND
                                                                       ( ipsyst-ioper = c_ins OR
                                                                         ipsyst-ioper = c_mod OR
                                                                         ipsyst-ioper = c_upd OR
                                                                         ipsyst-ioper = c_cop ) AND
                                                                         innnn-infty  = c_4002  AND
                                                                         innnn-endda  = c_99993112.

                                                                      ASSIGN ('(MP400200)P4002-OBJID') TO <f_plans>.
                                                                    ENDIF.

                                                                    IF <f_plans> IS ASSIGNED.
                                                                      IF NOT <f_plans> IS INITIAL.

                                                                        CLEAR: l_sobid,
                                                                               l_cname.

*     Procura por outro Pessoa Ligada à Posição
                                                                        SELECT sobid UP TO 1 ROWS
                                                                          FROM hrp1001
                                                                          INTO l_sobid
                                                                         WHERE otype EQ c_posicao
                                                                           AND objid EQ <f_plans>
                                                                           AND plvar EQ c_01
                                                                           AND endda EQ c_99993112
                                                                           AND subty EQ c_a008
                                                                           AND sclas EQ c_p
                                                                           AND sobid NE innnn-pernr.
                                                                        ENDSELECT.

                                                                        IF sy-subrc EQ 0.
                                                                          SELECT cname UP TO 1 ROWS
                                                                            FROM pa0002
                                                                            INTO l_cname
                                                                           WHERE pernr EQ l_sobid
                                                                             AND endda EQ c_99993112.
                                                                          ENDSELECT.

                                                                          MESSAGE e045(zhr02) WITH 'Posição já ocupada por' l_sobid
                                                                                                   ' - ' l_cname.
                                                                        ENDIF.
                                                                      ENDIF.
                                                                    ENDIF.
                                                                  ENDIF.
***Fim de Inclusão - T3WELLINGTOV - 27.08.2010

** Inicio de Inclusão - <T3LUIZFMS> - <14.05.2009> - <Minhas Informações>
                                                                  IF ( sy-tcode <> c_pa20 ) AND
                                                                     ( ipsyst-ioper = c_ins OR
                                                                       ipsyst-ioper = c_mod OR
                                                                       ipsyst-ioper = c_upd OR
                                                                       ipsyst-ioper = c_cop ) AND
                                                                       innnn-infty = c_0022.

                                                                    r_slart-sign   = c_i.
                                                                    r_slart-option = c_eq.
                                                                    r_slart-low    = c_01.
                                                                    APPEND r_slart.
                                                                    r_slart-low    = c_06.
                                                                    APPEND r_slart.
                                                                    r_slart-low    = c_25.
                                                                    APPEND r_slart.

*-- Move os dados do Infotipo 0022 da estrutura INNNN para P0022
                                                                    PERFORM zf_gera_pxxxx USING innnn w_p0022.

*-- Verifica se a data ENDDA é igual a 31.12.9999
                                                                    IF w_p0022-endda <> c_99993112.
                                                                      PERFORM zf_atrbiutos_tela USING c_endda.
                                                                      SET CURSOR FIELD c_endda.
                                                                      MESSAGE e368(00) WITH TEXT-004.
                                                                    ENDIF.

*-- Para os subtipos abaixo, poderão ser selecionados apenas a opção outros:
*-- Cursos Técnicos, Cursos/Seminários e Certificação.
                                                                    IF w_p0022-slart IN r_slart.
                                                                      IF w_p0022-ausbi IS NOT INITIAL.
                                                                        PERFORM zf_atrbiutos_tela USING c_ausbi.
                                                                        SET CURSOR FIELD c_ausbi.
                                                                        MESSAGE e368(00) WITH TEXT-003.
                                                                      ENDIF.
                                                                    ENDIF.

*-- Checa o tipo de Formação é igual a 0(Outros). Se for igual a Outros será
*-- obrigatório o preenchimento do campo KSBEZ será obrigatório.
                                                                    IF w_p0022-ausbi IS INITIAL.
                                                                      IF w_p0022-ksbez IS INITIAL.
                                                                        PERFORM zf_atrbiutos_tela USING c_ksbez.
                                                                        SET CURSOR FIELD c_ksbez.
                                                                        MESSAGE e368(00) WITH TEXT-001.
                                                                      ENDIF.
                                                                    ELSE.
*-- Caso contrario o campo não poderá ser preenchido.
                                                                      IF w_p0022-ksbez IS NOT INITIAL.
                                                                        PERFORM zf_atrbiutos_tela USING c_ksbez.
                                                                        SET CURSOR FIELD c_ksbez.
                                                                        MESSAGE e368(00) WITH TEXT-002.
                                                                      ENDIF.

                                                                    ENDIF.

                                                                  ENDIF.
* Final de Inclusão  - <T3LUIZFMS> - <14.05.2009> - <Minhas Informações>

*&---------------------------------------------------------------------*
* Main
*&---------------------------------------------------------------------*
* Check company for record deletions

*** Begin of Inclusion - T3KATHYV - 07/07/2011 E03K9A62NU
* check for the company code in the VCNA table
*  IF ipsyst-bukrs EQ c_4047 OR
*     ipsyst-bukrs EQ c_4048 OR
*     ipsyst-bukrs EQ c_4049 OR
*     ipsyst-bukrs EQ c_4050 OR
*     ipsyst-bukrs EQ c_4051 OR
*     ipsyst-bukrs EQ c_4052 OR
*     ipsyst-bukrs EQ c_4053 OR
*     ipsyst-bukrs EQ c_4054.
                                                                  SELECT SINGLE control_group INTO v_control_group
                                                                        FROM ztbsd_bukrs_grp
                                                                        WHERE bukrs EQ ipsyst-bukrs.
                                                                    IF sy-subrc EQ c_0.
***   End of Inclusion - T3KATHYV - 07/07/2011 E03K9A62NU


                                                                      IF ipsyst-ioper EQ 'DEL' OR
                                                                         ipsyst-ioper EQ 'MOD'.

                                                                        CASE psave-infty.
                                                                          WHEN c_0002.
                                                                            SELECT SINGLE * FROM pa0002
                                                                              WHERE pernr EQ psave-pernr
                                                                                AND endda EQ psave-endda
                                                                                AND begda EQ psave-begda
                                                                                AND aedtm EQ psave-aedtm.
                                                                              IF sy-subrc EQ c_0.
                                                                                ztbhr_pa0002       = pa0002. " + @0004
*            MOVE-CORRESPONDING pa0002 TO ztbhr_pa0002. " -@0004
                                                                                ztbhr_pa0002-aedtm = sy-datum.
                                                                                IF ipsyst-ioper EQ 'DEL'.
                                                                                  ztbhr_pa0002-flag1 = 'D'.
                                                                                ELSE.
                                                                                  ztbhr_pa0002-flag1 = 'M'.
                                                                                ENDIF.
                                                                                MODIFY ztbhr_pa0002.
                                                                              ENDIF.
                                                                            WHEN c_0006.
                                                                              SELECT SINGLE * FROM pa0006
                                                                                WHERE pernr EQ psave-pernr
                                                                                  AND endda EQ psave-endda
                                                                                  AND begda EQ psave-begda
                                                                                  AND aedtm EQ psave-aedtm.
                                                                                IF sy-subrc EQ c_0.
                                                                                  ztbhr_pa0006       = pa0006.
                                                                                  ztbhr_pa0006-aedtm = sy-datum.
                                                                                  IF ipsyst-ioper EQ 'DEL'.
                                                                                    ztbhr_pa0006-flag1 = 'D'.
                                                                                  ELSE.
                                                                                    ztbhr_pa0006-flag1 = 'M'.
                                                                                  ENDIF.
                                                                                  MODIFY ztbhr_pa0006.
                                                                                ENDIF.
                                                                              WHEN c_0008.
                                                                                SELECT SINGLE * FROM pa0008
                                                                                  WHERE pernr EQ psave-pernr
                                                                                    AND endda EQ psave-endda
                                                                                    AND begda EQ psave-begda
                                                                                    AND aedtm EQ psave-aedtm.
                                                                                  IF sy-subrc EQ c_0.
                                                                                    ztbhr_pa0008       = pa0008.
                                                                                    ztbhr_pa0008-aedtm = sy-datum.
                                                                                    IF ipsyst-ioper EQ 'DEL'.
                                                                                      ztbhr_pa0008-flag1 = 'D'.
                                                                                    ELSE.
                                                                                      ztbhr_pa0008-flag1 = 'M'.
                                                                                    ENDIF.
                                                                                    MODIFY ztbhr_pa0008.
                                                                                  ENDIF.
                                                                                WHEN c_0014.
                                                                                  SELECT SINGLE * FROM pa0014
                                                                                    WHERE pernr EQ psave-pernr
                                                                                      AND endda EQ psave-endda
                                                                                      AND begda EQ psave-begda
                                                                                      AND aedtm EQ psave-aedtm.
                                                                                    IF sy-subrc EQ c_0.
                                                                                      ztbhr_pa0014       = pa0014.
                                                                                      ztbhr_pa0014-aedtm = sy-datum.
                                                                                      IF ipsyst-ioper EQ 'DEL'.
                                                                                        ztbhr_pa0014-flag1 = 'D'.
                                                                                      ELSE.
                                                                                        ztbhr_pa0014-flag1 = 'M'.
                                                                                      ENDIF.
                                                                                      MODIFY ztbhr_pa0014.
                                                                                    ENDIF.
                                                                                  WHEN c_0015.
                                                                                    SELECT SINGLE * FROM pa0015
                                                                                      WHERE pernr EQ psave-pernr
                                                                                        AND endda EQ psave-endda
                                                                                        AND begda EQ psave-begda
                                                                                        AND aedtm EQ psave-aedtm.
                                                                                      IF sy-subrc EQ c_0.
                                                                                        ztbhr_pa0015       = pa0015.
                                                                                        ztbhr_pa0015-aedtm = sy-datum.
                                                                                        IF ipsyst-ioper EQ 'DEL'.
                                                                                          ztbhr_pa0015-flag1 = 'D'.
                                                                                        ELSE.
                                                                                          ztbhr_pa0015-flag1 = 'M'.
                                                                                        ENDIF.
                                                                                        MODIFY ztbhr_pa0015.
                                                                                      ENDIF.
                                                                                    WHEN c_0167.
                                                                                      SELECT SINGLE * FROM pa0167
                                                                                        WHERE pernr EQ psave-pernr
                                                                                          AND endda EQ psave-endda
                                                                                          AND begda EQ psave-begda
                                                                                          AND aedtm EQ psave-aedtm.
                                                                                        IF sy-subrc EQ c_0 AND
                                                                                           ipsyst-ioper EQ 'DEL'.
                                                                                          ztbhr_pa0167       = pa0167.
                                                                                          ztbhr_pa0167-aedtm = sy-datum.
                                                                                          ztbhr_pa0167-flag1 = 'D'.
                                                                                          INSERT ztbhr_pa0167.
                                                                                        ENDIF.
                                                                                      WHEN c_0168.
                                                                                        SELECT SINGLE * FROM pa0168
                                                                                          WHERE pernr EQ psave-pernr
                                                                                            AND endda EQ psave-endda
                                                                                            AND begda EQ psave-begda
                                                                                            AND aedtm EQ psave-aedtm.
                                                                                          IF sy-subrc EQ c_0 AND
                                                                                             ipsyst-ioper EQ 'DEL'.
                                                                                            ztbhr_pa0168       = pa0168.
                                                                                            ztbhr_pa0168-aedtm = sy-datum.
                                                                                            ztbhr_pa0168-flag1 = 'D'.
                                                                                            INSERT ztbhr_pa0168.
                                                                                          ENDIF.
                                                                                        WHEN c_0170.
                                                                                          SELECT SINGLE * FROM pa0170
                                                                                            WHERE pernr EQ psave-pernr
                                                                                              AND endda EQ psave-endda
                                                                                              AND begda EQ psave-begda
                                                                                              AND aedtm EQ psave-aedtm.
                                                                                            IF sy-subrc EQ c_0 AND
                                                                                               ipsyst-ioper EQ 'DEL'.
                                                                                              ztbhr_pa0170       = pa0170.
                                                                                              ztbhr_pa0170-aedtm = sy-datum.
                                                                                              ztbhr_pa0170-flag1 = 'D'.
                                                                                              INSERT ztbhr_pa0170.
                                                                                            ENDIF.
                                                                                        ENDCASE.

                                                                                      ENDIF.

                                                                                    ENDIF.

***-- Quando ocorre a alteração de datas BEGDA ou ENDDA os campos chave podem mudar
***-- Exemplo: 3 registros com mesma validade e mesmo subtipo, o que diferencia é o SEQNR,
***-- pois a cada chave duplicada ele adiciona 1 ao sequêncial.
***-- Se um desses registros, tiver uma alteração de data e as novas data não possuirem outro
***-- registro gravado no SAP, o campo SEQNR será zerado.
***-- Neste caso, iremos gravar o registro anterior e o registro atual na ZTBHR_PA0022 ou
***-- 0023, pois se ocorrer alguma alteração do registro no EFV, será possível identificar qual era
***-- o registro anterior e qual é o atual, para atualização dos dados

                                                                                    IF ipsyst-ioper EQ c_mod.
                                                                                      IF sy-ucomm IS INITIAL AND
                                                                                         sy-tcode IS NOT INITIAL.
*-- Estrutura PSAVE possui os dados originais. Este estrutura é informada apenas 1 vez, se 2 eventos forem
*-- executados na tela, na segunda chamada esta esrutura vem em branco. Por este motivo estamos utilizando
*-- IMPORT e EXPORT. O ID PSAVE é limpo a cada chamada da PA30, portanto não corremos risco de recuperar
*-- dados antigo(Exit ZXPADU03).
                                                                                        IF psave-pernr IS NOT INITIAL.
                                                                                          EXPORT psave FROM psave TO MEMORY ID c_psave.
                                                                                        ENDIF.

                                                                                      ELSEIF sy-ucomm     EQ c_upd AND
                                                                                             sy-tcode     IS NOT INITIAL.

                                                                                        IF psave-infty IS INITIAL.
                                                                                          IMPORT psave TO psave FROM MEMORY ID c_psave.
                                                                                        ENDIF.

                                                                                        IF psave-infty = c_0023.
*-- Move os dados do Infotipo 0023 da estrutura INNNN para P0023
                                                                                          PERFORM zf_gera_pxxxx USING innnn w_p0023.
                                                                                        ENDIF.

                                                                                        CASE psave-infty.
                                                                                          WHEN c_0022.
*-- Move os dados do Infotipo 0022 da estrutura INNNN para P0022
                                                                                            PERFORM zf_gera_pxxxx USING psave w_p0022_old.
*-- Verifica se ocorre um alteração da data inicial e final
                                                                                            IF w_p0022-begda       <> w_p0022_old-begda OR
                                                                                               w_p0022-endda       <> w_p0022_old-endda OR
                                                                                               w_p0022-zendda_form <> w_p0022_old-zendda_form.

                                                                                              IF w_p0022-begda      <> w_p0022_old-begda OR
                                                                                                 w_p0022-endda      <> w_p0022_old-endda.
                                                                                                PERFORM zf_leitura_pa0022.
                                                                                              ELSE.
                                                                                                v_nxt_seqnr = w_p0022-seqnr.
                                                                                              ENDIF.

                                                                                              SELECT SINGLE * FROM ztbhr_pa0022
                                                                                                WHERE pernr EQ w_p0022_old-pernr
                                                                                                  AND endda EQ w_p0022_old-endda
                                                                                                  AND begda EQ w_p0022_old-begda
                                                                                                  AND seqnr EQ w_p0022_old-seqnr
                                                                                                  AND sprps EQ c_n
                                                                                                  AND flag1 EQ c_n.

                                                                                                IF sy-subrc = 0.
                                                                                                  SELECT SINGLE * FROM ztbhr_pa0022
                                                                                                    WHERE insti EQ ztbhr_pa0022-insti
                                                                                                      AND flag1 EQ c_a.

                                                                                                    IF sy-subrc = 0.
                                                                                                      ztbhr_pa0022-insti = sy-uzeit.
                                                                                                      UPDATE ztbhr_pa0022.
                                                                                                    ENDIF.
                                                                                                  ELSE.
                                                                                                    MOVE-CORRESPONDING w_p0022_old TO ztbhr_pa0022.
                                                                                                    ztbhr_pa0022-mandt = sy-mandt.
                                                                                                    ztbhr_pa0022-aedtm = sy-datum.
                                                                                                    ztbhr_pa0022-flag1 = ztbhr_pa0022-sprps = c_a.
                                                                                                    ztbhr_pa0022-insti = sy-uzeit.
                                                                                                    INSERT ztbhr_pa0022.
                                                                                                  ENDIF.

                                                                                                  DELETE FROM ztbhr_pa0022 WHERE pernr = w_p0022-pernr AND
                                                                                                                                 begda = w_p0022-begda AND
                                                                                                                                 endda = w_p0022-endda AND
                                                                                                                                 subty = w_p0022-subty AND
                                                                                                                                 seqnr = w_p0022-seqnr AND
                                                                                                                                 sprps = c_n.

                                                                                                  MOVE-CORRESPONDING w_p0022 TO ztbhr_pa0022.
                                                                                                  ztbhr_pa0022-mandt = sy-mandt.
                                                                                                  ztbhr_pa0022-aedtm = sy-datum.
                                                                                                  ztbhr_pa0022-flag1 = ztbhr_pa0022-sprps = c_n.
                                                                                                  ztbhr_pa0022-seqnr = v_nxt_seqnr.
                                                                                                  ztbhr_pa0022-insti = sy-uzeit.
                                                                                                  INSERT ztbhr_pa0022.

                                                                                                ENDIF.
                                                                                              WHEN c_0023.

                                                                                                DATA: v_arbgb LIKE p0023-arbgb.
*-- move os dados do infotipo 0023 da estrutura innnn para p0023
                                                                                                PERFORM zf_gera_pxxxx USING psave w_p0023_old.
*-- Verifica se ocorre um alteração da data inicial e final
                                                                                                IF w_p0023-begda <> w_p0023_old-begda OR
                                                                                                   w_p0023-endda <> w_p0023_old-endda.
                                                                                                  PERFORM zf_leitura_pa0023.

                                                                                                  SELECT SINGLE * FROM ztbhr_pa0023
                                                                                                    WHERE pernr EQ w_p0023_old-pernr
                                                                                                      AND endda EQ w_p0023_old-endda
                                                                                                      AND begda EQ w_p0023_old-begda
                                                                                                      AND seqnr EQ w_p0023_old-seqnr
                                                                                                      AND flag1 EQ c_n.

                                                                                                    IF sy-subrc = 0.
                                                                                                      v_arbgb = ztbhr_pa0023-arbgb.

                                                                                                      SELECT SINGLE * FROM ztbhr_pa0023
                                                                                                        WHERE arbgb EQ v_arbgb
                                                                                                          AND flag1 EQ c_a.

                                                                                                        IF sy-subrc = 0.
                                                                                                          ztbhr_pa0023-arbgb = sy-uzeit.
                                                                                                          UPDATE ztbhr_pa0023.
                                                                                                        ENDIF.

                                                                                                      ELSE.
                                                                                                        MOVE-CORRESPONDING w_p0023_old TO ztbhr_pa0023.
                                                                                                        ztbhr_pa0023-mandt = sy-mandt.
                                                                                                        ztbhr_pa0023-aedtm = sy-datum.
                                                                                                        ztbhr_pa0023-flag1 = c_a.
                                                                                                        ztbhr_pa0023-arbgb = sy-uzeit.
                                                                                                        INSERT ztbhr_pa0023.
                                                                                                      ENDIF.

                                                                                                      MOVE-CORRESPONDING w_p0023 TO ztbhr_pa0023.
                                                                                                      ztbhr_pa0023-mandt = sy-mandt.
                                                                                                      ztbhr_pa0023-aedtm = sy-datum.
                                                                                                      ztbhr_pa0023-flag1 = c_n.
                                                                                                      ztbhr_pa0023-seqnr = v_nxt_seqnr.
                                                                                                      ztbhr_pa0023-arbgb = sy-uzeit.
                                                                                                      INSERT ztbhr_pa0023.
                                                                                                    ENDIF.
                                                                                                ENDCASE.
                                                                                              ENDIF.
                                                                                            ENDIF.

*** Inicio de Inclusão - <T3LUIZFMS> - <15.05.2009> - <Minhas Informações>
*-- Se for uma exclusão de um registro do Infotipo 0022 será gravado na tabela ZTBHR_PA0022.
*-- Tabela criada para que em caso de deleção seja possível indicar e atualizar os dados no
*-- BD EFV.
                                                                                            IF ipsyst-ioper EQ c_del.
                                                                                              CASE psave-infty.
                                                                                                WHEN c_0022.
*-- Move os dados do Infotipo 0022 da estrutura INNNN para P0022
                                                                                                  PERFORM zf_gera_pxxxx USING innnn w_p0022.
                                                                                                  DELETE FROM ztbhr_pa0022 WHERE pernr = w_p0022-pernr AND
                                                                                                                                 begda = w_p0022-begda AND
                                                                                                                                 endda = w_p0022-endda AND
                                                                                                                                 subty = w_p0022-subty AND
                                                                                                                                 seqnr = w_p0022-seqnr AND
                                                                                                                                 sprps = c_n.
                                                                                                  MOVE-CORRESPONDING w_p0022 TO ztbhr_pa0022.
                                                                                                  ztbhr_pa0022-mandt = sy-mandt.
                                                                                                  ztbhr_pa0022-aedtm = sy-datum.
                                                                                                  ztbhr_pa0022-flag1 = ztbhr_pa0022-sprps = c_d.
                                                                                                  INSERT ztbhr_pa0022.
                                                                                                WHEN c_0023.
*-- Move os dados do Infotipo 0022 da estrutura INNNN para P0022
                                                                                                  PERFORM zf_gera_pxxxx USING innnn w_p0023.
                                                                                                  MOVE-CORRESPONDING w_p0023 TO ztbhr_pa0023.
                                                                                                  ztbhr_pa0023-mandt = sy-mandt.
                                                                                                  ztbhr_pa0023-aedtm = sy-datum.
                                                                                                  ztbhr_pa0023-flag1 = c_d.
                                                                                                  MODIFY ztbhr_pa0023.
                                                                                              ENDCASE.
                                                                                            ENDIF.
*** Final da Inclusão - <T3LUIZFMS> - <15.05.2009> - <Minhas Informações>

***Inicio de Inclusão - T3WELLINGTOV - 11.02.2011
                                                                                            INCLUDE zihr0047_valid_0021.
***Fim de Inclusão - T3WELLINGTOV - 11.02.2011

***Inicio de Inclusão - T3JEFFERSONM - 27.05.2011
* Validar dados bancários no infotipo 0009
                                                                                            INCLUDE zihr0049_valid_0009.
***Fim de Inclusão - T3JEFFERSONM - 27.05.2011

*** Início de Inclusão - T3ISRAELS - 04.09.2012
                                                                                            IF ( innnn-infty  EQ '0167'  "Infotipo 0167
                                                                                            OR   innnn-infty  EQ '0168'  "Infotipo 0168
                                                                                            OR   innnn-infty  EQ '0169'  "Infotipo 0169
                                                                                            OR   innnn-infty  EQ '0377' ) "Infotipo 0377
                                                                                            AND ( sy-pfkey    EQ 'INS'   "Inserir
                                                                                             OR   sy-pfkey    EQ 'COP'   "Cópia
                                                                                             OR   sy-pfkey    EQ 'MOD' ) "Modificação
                                                                                            AND ( sy-ucomm    EQ 'UPD'   "Gravação
                                                                                             OR   sy-ucomm    EQ 'OK'    "OK Popup
                                                                                             OR   sy-ucomm    EQ space   "Enter
                                                                                             OR   sy-ucomm    EQ 'Z_CANC' )"Cancelamento Popup
                                                                                            AND   i001p-molga EQ c_37.   "Molga
                                                                                              INCLUDE zihr0093_valid_planos_elegib.
                                                                                            ENDIF.
*** Fim    de Inclusão - T3ISRAELS - 04.09.2012

* Início de Inclusão - T3GUILHERF - 15.03.2013
                                                                                            IF ( innnn-infty  EQ '0167'  "Infotipo 0167
                                                                                              )
                                                                                             AND ( sy-pfkey    EQ 'INS'   "Inserir
* Início de Inclusão - T3ELIASOC - 25.06.2013
                                                                                              OR   sy-pfkey    EQ 'COP'   "Cópia
                                                                                              OR   sy-pfkey    EQ 'MOD'   "Modificação
* Fim de Inclusão - T3ELIASOC - 25.06.2013
                                                                                              )
                                                                                             AND ( sy-ucomm    EQ 'UPD'   "Gravação
*    OR   sy-ucomm    EQ 'OK'    "OK Popup
                                                                                              OR   sy-ucomm    EQ space   "Enter
*    OR   sy-ucomm    EQ 'Z_CANC'"Cancelamento Popup
                                                                                              )
                                                                                             AND   i001p-molga EQ c_37.   "Molga
                                                                                              INCLUDE zihr0219_preenche_dependentes.
                                                                                            ENDIF.
* Fim de Inclusão - T3GUILHERF - 15.03.2013


* Início de Inclusão - T3JOILSORJ - 16.09.2015

                                                                                            CONSTANTS: c_resi     TYPE c LENGTH 4 VALUE 'RESI',
                                                                                                       c_cell     TYPE c LENGTH 4 VALUE 'CELL',
                                                                                                       c_data_fim TYPE datum VALUE '99991231'.

                                                                                            DATA:
*        w_p0002 TYPE p0002,
                                                                                              w_p0006   TYPE p0006,
*    w_p0000   TYPE p0000, " -@0004
*        w_p0105 TYPE p0105,
*    w_p0021_1 TYPE p0021, " -@0004
                                                                                              w_p0021_1 TYPE p0021. " +@0004
*    w_hrp1001 TYPE hrp1001, -@0004
*    w_clas    TYPE zvwhr_cons_clas. -@0004
*        w_p0465 TYPE p0465.

                                                                                            DATA: l_num_carac TYPE i,
                                                                                                  l_tel       TYPE n LENGTH 20,
                                                                                                  l_var_aux   TYPE c LENGTH 50,
                                                                                                  l_anos      TYPE i. " +@0004
*        l_anos      TYPE i, " -@0004
*        l_data3      TYPE prel_daten, " -@0004
*        l_data4      TYPE prel_daten, " -@0004
*        l_data5      TYPE prel_daten, " -@0004
*        l_data6      TYPE prel_data4, " -@0004
*        l_data7      TYPE prel_daten, " -@0004
*        l_cnhobg    TYPE xflag. " -@0004
**        l_sobid     TYPE HROBJID. " -@0004
*  DATA: t_hrp1001 TYPE TABLE OF hrp1001, " -@0004
*        t_clas    TYPE TABLE OF zvwhr_cons_clas. " -@0004
**  DATA: t_hrp9230   TYPE TABLE OF hrp9230. " -@0004


                                                                                            FIELD-SYMBOLS: <f_0397> TYPE p0397.



                                                                                            CASE innnn-infty.
* inicio  -@0004 {
*    WHEN '0000'.
*      CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
*        EXPORTING
*          prelp = innnn
*        IMPORTING
*          pnnnn = w_p0000.
*      IF w_p0000-massn EQ '09' OR
*         w_p0000-massn EQ '01'.
*
*        CLEAR t_dynpfields2.
*        REFRESH t_dynpfields2.
*        t_dynpfields2-fieldname = 'PSPAR-PLANS'.
*        APPEND t_dynpfields2.
*
*        CALL FUNCTION 'DYNP_VALUES_READ'
*          EXPORTING
*            dyname     = sy-cprog
*            dynumb     = sy-dynnr
*            request    = 'A'
*          TABLES
*            dynpfields = t_dynpfields2.
*
*        READ TABLE t_dynpfields2 WITH KEY fieldname = 'PSPAR-PLANS'
*                                 INTO w_dynpfields2.
*        SELECT * FROM hrp1001 INTO TABLE t_hrp1001
*                              WHERE plvar EQ '01'
*                                AND otype EQ 'S'
*                                AND objid EQ w_dynpfields2-fieldvalue
*                                AND rsign EQ 'B'
*                                AND relat EQ '007'
*                                AND endda EQ '99991231'.
*        SORT t_hrp1001 DESCENDING BY endda.
*        READ TABLE t_hrp1001 INDEX 1 INTO w_hrp1001.
*        l_sobid = w_hrp1001-sobid.
*
*        SELECT * FROM hrp9230 WHERE plvar EQ '01'
*                                AND otype EQ 'C'
*                                AND objid EQ l_sobid
*                                AND endda EQ '99991231'.
*          l_cnhobg = hrp9230-cnh_obrg.
*        ENDSELECT.
*        IF NOT l_cnhobg IS INITIAL.
*          CLEAR t_p0465.
*          REFRESH t_p0465.
*          CALL FUNCTION 'HR_READ_INFOTYPE'
*            EXPORTING
**             TCLAS           = 'A'
*              pernr           = w_p0000-pernr
*              infty           = '0465'
*              begda           = w_p0000-begda
*              endda           = w_p0000-endda
**             BYPASS_BUFFER   = ' '
**             LEGACY_MODE     = ' '
**                IMPORTING
**             SUBRC           =
*            TABLES
*              infty_tab       = t_p0465
*            EXCEPTIONS
*              infty_not_found = 1
*              OTHERS          = 2.
*          IF sy-subrc <> 0.
**         Implement suitable error handling here
*          ENDIF.
*          DELETE t_p0465 WHERE subty NE '0004'.
*          SORT t_p0465 DESCENDING BY endda.
*          READ TABLE t_p0465 INDEX 1
*                             INTO w_p0465.
**          CALL FUNCTION 'VIEW_GET_DATA'
**            EXPORTING
**              view_name                    = 'ZVWHR_CONS_CLAS'
***             WITHOUT_SUBSET               = ' '
***             WITHOUT_EXITS                = ' '
***             COMPLEX_SELCONDS_USED        = ' '
***             WITH_AUTHORITY_CHECK         = ' '
***             CHECK_LINEDEP_AUTH           = ' '
***             DATA_CONT_TYPE_X             = ' '
**            tables
***             DBA_SELLIST                  =
**              data                         = t_CLAS
***             X_HEADER                     =
***             X_NAMTAB                     =
***           CHANGING
***             ORG_CRIT_INST                =
**            EXCEPTIONS
**              NO_VIEWMAINT_TOOL            = 1
**              NO_AUTHORITY                 = 2
**              NO_AUTH_FOR_SEL              = 3
**              DATA_ACCESS_RESTRICTED       = 4
**              NO_FUNCTIONGROUP             = 5
**              OTHERS                       = 6
**                    .
**          IF sy-subrc <> 0.
*** Implement suitable error handling here
**          ENDIF.
**          P0465-CREG_NR "numero do conselho
**          P0465-CREG_NAME "nome do conselho w_clas-DESCRICAO
**          P0465-CREG_INIT "Sigla do conselho w_clas-ENTIDADE
**          P0465-DT_EMIS   "Data de emissão
**          Q0465-OCORG     "orgão emissor w_clas-ENTIDADE
*        ENDIF.
*        CLEAR t_p0465.
*        REFRESH t_p0465.
*      ENDIF.
*

* fin  -@0004 }
                                                                                              WHEN '0002'.

                                                                                                CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
                                                                                                  EXPORTING
                                                                                                    prelp = innnn
                                                                                                  IMPORTING
                                                                                                    pnnnn = w_p0002.
*      CLEAR: w_p0002-cname, l_num_carac, "-@0004
*             l_data3, l_data4, l_data5, l_data6, l_data7. " -@0004

*      l_data3 = innnn-data3." -@0004
*      l_data4 = innnn-data4." -@0004
*      l_data5 = innnn-data5." -@0004
*      l_data6 = innnn-data6." -@0004
*      l_data7 = innnn-data7." -@0004

*      CONCATENATE w_p0002-vorna w_p0002-nachn INTO w_p0002-cname SEPARATED BY space. -@0004
*      "alteração GAPs esocial -@0004
                                                                                                l_num_carac = strlen( w_p0002-cname ).
*      IF l_num_carac > 70. "-@0004
                                                                                                IF l_num_carac > 60. "+@0004
                                                                                                  MESSAGE e045(zhr02) WITH TEXT-042.
*      ELSE. "-@0004
*        CALL METHOD cl_hr_pnnnn_type_cast=>pnnnn_to_prelp "-@0004
*          EXPORTING "-@0004
*            pnnnn = w_p0002 "-@0004
*          IMPORTING "-@0004
*            prelp = innnn. "-@0004
*
*        innnn-data3 = l_data3. "-@0004
*        innnn-data4 = l_data4."-@0004
*        innnn-data5 = l_data5. "-@0004
*        innnn-data6 = l_data6."-@0004
*        innnn-data7 = l_data7."-@0004
                                                                                                ENDIF.

                                                                                              WHEN '0006'.
                                                                                                CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
                                                                                                  EXPORTING
                                                                                                    prelp = innnn
                                                                                                  IMPORTING
                                                                                                    pnnnn = w_p0006.
*      "alteração GAPs esocial "-@0004
*      IF NOT w_p0006-com01 IS INITIAL. "-@0004
*        w_p0006-com01 = c_resi OR "-@0004
*         w_p0006-com01 = c_cell."-@0004
*        CONCATENATE w_p0006-num01 w_p0006-com01 INTO l_tel. "-@0004
                                                                                                IF      w_p0006-com01 = c_resi OR "+@0004
                                                                                                       w_p0006-com01 = c_cell. " "+@0004
                                                                                                  l_tel = w_p0006-num01.

                                                                                                  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
                                                                                                    EXPORTING
                                                                                                      input  = l_tel
                                                                                                    IMPORTING
                                                                                                      output = l_var_aux.

                                                                                                  l_num_carac = strlen( l_var_aux ).
                                                                                                  IF l_num_carac > 13.
                                                                                                    MESSAGE e045(zhr02) WITH TEXT-043.
                                                                                                  ENDIF.
                                                                                                ENDIF.

                                                                                                CLEAR: l_tel, l_var_aux, l_num_carac.

*      IF NOT w_p0006-com02 IS INITIAL. "-@0004
*        w_p0006-com02 = c_resi OR "-@0004
*         w_p0006-com02 = c_cell. "-@0004
                                                                                                IF       w_p0006-com02 = c_resi OR "+@0004
                                                                                                       w_p0006-com02 = c_cell. "+@0004
                                                                                                  l_tel = w_p0006-num02.
* inicio "+@0004 {
*        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*          EXPORTING
*            input  = l_tel
*          IMPORTING
*            output = l_var_aux.

*        l_num_carac = strlen( l_var_aux ).
*        IF l_num_carac > 13.
*          MESSAGE e045(zhr02) WITH text-043.
*        ENDIF.
*
*      ENDIF.
*
*      CLEAR: l_tel, l_var_aux, l_num_carac.
*
*      IF NOT w_p0006-com03 IS INITIAL.
**        w_p0006-com02 = c_resi OR
**         w_p0006-com02 = c_cell.
*        l_tel = w_p0006-num03.
* fin "+@0004 }
                                                                                                  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
                                                                                                    EXPORTING
                                                                                                      input  = l_tel
                                                                                                    IMPORTING
                                                                                                      output = l_var_aux.

                                                                                                  l_num_carac = strlen( l_var_aux ).
                                                                                                  IF l_num_carac > 13.
                                                                                                    MESSAGE e045(zhr02) WITH TEXT-043.
                                                                                                  ENDIF.

                                                                                                ENDIF.

                                                                                              WHEN '0105'.
                                                                                                CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
                                                                                                  EXPORTING
                                                                                                    prelp = innnn
                                                                                                  IMPORTING
                                                                                                    pnnnn = w_p0105.
                                                                                                "MRB
                                                                                                DATA: w_p0105n_aux TYPE pa0105.

                                                                                                CONSTANTS: c_arroba(1)       TYPE c  VALUE '@',
                                                                                                           c_0105(4)         TYPE c  VALUE '0105',
                                                                                                           c_subty_o365      TYPE subty VALUE 'O365',
                                                                                                           c_subty_0010      TYPE subty VALUE '0010',
                                                                                                           c_tvarv_empr_o365 TYPE rvari_vnam VALUE 'ZFHR_ATUALIZA_O365_EMPRESA'.
                                                                                                DATA: r_empr_o365 TYPE RANGE OF bukrs.
* Verifica empresa do empregado
                                                                                                SELECT SINGLE pernr, bukrs
                                                                                                  FROM pa0001
                                                                                                  INTO @DATA(wa_emp)
                                                                                                  WHERE pernr EQ @w_p0105-pernr
                                                                                                    AND endda GE @w_p0105-endda
                                                                                                    AND begda LE @w_p0105-begda.

* Verifica empresa TVARV
                                                                                                  SELECT sign opti low high
                                                                                                    FROM  tvarvc
                                                                                                    INTO  TABLE r_empr_o365
                                                                                                    WHERE name  EQ  c_tvarv_empr_o365.

                                                                                                    IF w_p0105-subty = '0010'
                                                                                                      AND wa_emp-bukrs IN r_empr_o365. "Somente empresas que estiverem

                                                                                                      CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
                                                                                                        EXPORTING
                                                                                                          prelp = innnn
                                                                                                        IMPORTING
                                                                                                          pnnnn = w_p0105n.

                                                                                                      IF sy-pfkey EQ 'MOD'.
                                                                                                        TRY.
                                                                                                            CALL FUNCTION 'ZFHR_ATUALIZA_TAG' DESTINATION 'NONE'
                                                                                                              EXPORTING
                                                                                                                e_p0105 = w_p0105n
                                                                                                                act     = sy-pfkey.
                                                                                                        ENDTRY.
                                                                                                      ENDIF.

                                                                                                      IF sy-pfkey EQ 'INS'.
                                                                                                        TRY.
                                                                                                            CALL FUNCTION 'ZFHR_ATUALIZA_TAG' DESTINATION 'NONE'
                                                                                                              EXPORTING
                                                                                                                e_p0105 = w_p0105n
                                                                                                                act     = sy-pfkey.
                                                                                                        ENDTRY.
                                                                                                      ENDIF.
                                                                                                    ENDIF.
                                                                                                    "ENDMRB

                                                                                                    "MRB
                                                                                                    DATA w_0006 TYPE pa0006.

                                                                                                  WHEN '0009'.

                                                                                                    CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
                                                                                                      EXPORTING
                                                                                                        prelp = innnn
                                                                                                      IMPORTING
                                                                                                        pnnnn = w_p0009.

                                                                                                    IF w_p0009-pernr IS NOT INITIAL.

                                                                                                      SELECT SINGLE *
                                                                                                        FROM pa0006 INTO w_0006
                                                                                                        WHERE pernr EQ w_p0009-pernr
                                                                                                        AND   endda EQ '99991231'.

                                                                                                        IF w_0006 IS NOT INITIAL.

                                                                                                          IF w_p0009-bkplz IS INITIAL.
                                                                                                            w_p0009-bkplz = w_0006-pstlz.
                                                                                                            CALL METHOD cl_hr_pnnnn_type_cast=>pnnnn_to_prelp
                                                                                                              EXPORTING
                                                                                                                pnnnn = w_p0009
                                                                                                              IMPORTING
                                                                                                                prelp = innnn.
                                                                                                          ENDIF.
                                                                                                          IF  w_p0009-bkort IS INITIAL.
                                                                                                            w_p0009-bkort = w_0006-ort01.
                                                                                                            CALL METHOD cl_hr_pnnnn_type_cast=>pnnnn_to_prelp
                                                                                                              EXPORTING
                                                                                                                pnnnn = w_p0009
                                                                                                              IMPORTING
                                                                                                                prelp = innnn.
                                                                                                          ENDIF.

                                                                                                        ENDIF.
                                                                                                      ENDIF.
                                                                                                      "ENDMRB

                                                                                                      "MRB - INC0220592

                                                                                                      DATA w_0661 TYPE pa0661.

                                                                                                    WHEN '0661'.

                                                                                                      CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
                                                                                                        EXPORTING
                                                                                                          prelp = innnn
                                                                                                        IMPORTING
                                                                                                          pnnnn = w_p0661.

                                                                                                      IF w_p0661-preav IS NOT INITIAL.

                                                                                                        CALL METHOD cl_hr_pnnnn_type_cast=>pnnnn_to_prelp
                                                                                                          EXPORTING
                                                                                                            pnnnn = w_p0661
                                                                                                          IMPORTING
                                                                                                            prelp = innnn.

                                                                                                      ELSEIF w_p0661-preav EQ space.
                                                                                                        MOVE '0' TO w_p0661-preav.
                                                                                                        CALL METHOD cl_hr_pnnnn_type_cast=>pnnnn_to_prelp
                                                                                                          EXPORTING
                                                                                                            pnnnn = w_p0661
                                                                                                          IMPORTING
                                                                                                            prelp = innnn.
                                                                                                      ENDIF.
                                                                                                      "ENDMRB

*****    "MRB - INC0232543
*****    DATA: W_P0021_AUX TYPE P0021,
*****          T_P0021_AUX TYPE TABLE OF P0021,
*****          W_P0397_AUX TYPE P0397,
*****          T_P0397_AUX TYPE TABLE OF P0397.
*****
*****    FIELD-SYMBOLS: <PNNNN> TYPE ANY TABLE.
*****    FIELD-SYMBOLS: <F_AUX> TYPE ANY.
*****    FIELD-SYMBOLS: <F_FLS> TYPE ANY.
*****
*****    DATA: LT_PRELP_0021 TYPE PRELP_TAB,
*****          LT_PRELP_0391 TYPE PRELP_TAB.
*****
*****    WHEN '0021'.
*****
*****        CALL METHOD CL_HR_PNNNN_TYPE_CAST=>PRELP_TO_PNNNN
*****        EXPORTING
*****          PRELP = INNNN
*****        IMPORTING
*****          PNNNN = W_P0021_AUX.
*****
*****       CALL METHOD CL_HR_PNNNN_TYPE_CAST=>PRELP_TO_PNNNN
*****        EXPORTING
*****          PRELP = INNNN
*****        IMPORTING
*****          PNNNN = W_P0397_AUX.
*****
*****         ASSIGN ('(MP002100)P0397-MOTHE') TO <F_AUX>.
*****         ASSIGN ('(MP002100)P0021-ZZNMMAE') TO <F_FLS>.
*****
*****         <F_FLS> = <F_AUX>.
*****
*****      IF <F_AUX> IS NOT INITIAL AND
*****         <F_AUX> IS ASSIGNED AND
*****         SY-PFKEY EQ 'MOD'.
*****
*****         W_P0021_AUX-ZZNMMAE = <F_AUX>.
*****         W_P0397_AUX-MOTHE = <F_FLS>.
*****
*****        IF SY-UCOMM EQ 'UPD'.
*****             CALL METHOD CL_HR_PNNNN_TYPE_CAST=>PNNNN_TO_PRELP
*****              EXPORTING
*****                PNNNN = W_P0021_AUX
*****              IMPORTING
*****                PRELP = INNNN.
*****          EXIT.
*****        ENDIF.
*****         APPEND W_P0021_AUX TO T_P0021_AUX.
*****         APPEND W_P0397_AUX TO T_P0397_AUX.
*****
*****
*****
*****      IF W_P0021_AUX-ZZNMMAE IS NOT INITIAL.
*****           CALL METHOD CL_HR_PNNNN_TYPE_CAST=>PNNNN_TO_PRELP_TAB
*****              EXPORTING
*****                PNNNN_TAB = T_P0021_AUX
*****              IMPORTING
*****                PRELP_TAB = LT_PRELP_0021.
*****
*****
*****            CALL METHOD CL_HR_PNNNN_TYPE_CAST=>PNNNN_TO_PRELP_TAB
*****              EXPORTING
*****                PNNNN_TAB = T_P0397_AUX
*****              IMPORTING
*****                PRELP_TAB = LT_PRELP_0391.
*****      ENDIF.
*****     ENDIF.
*****        TRY.
*****              CALL FUNCTION 'ZFHR_UPD_0397' DESTINATION 'NONE'
*****                EXPORTING
*****                  E_P0397 = W_P0397_AUX
*****                  E_P0021 = W_P0021_AUX
*****                  E_MOTHE = W_P0021_AUX-ZZNMMAE
*****                  ACT     = SY-PFKEY.
*****        ENDTRY.
                                                                                                      "ENDMRB

                                                                                                      "MRB - INC0224029
                                                                                                      DATA: t_9004 TYPE TABLE OF pa9004,
                                                                                                            w_9004 TYPE pa9004,
                                                                                                            l_peri TYPE pa9004-periodo.
                                                                                                    WHEN '9004'.

                                                                                                      IF sy-pfkey EQ 'INS' AND sy-ucomm EQ 'UPD'.
                                                                                                        CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
                                                                                                          EXPORTING
                                                                                                            prelp = innnn
                                                                                                          IMPORTING
                                                                                                            pnnnn = w_p9004.

                                                                                                        IF w_p9004-pernr IS NOT INITIAL.
                                                                                                          SELECT * FROM pa9004
                                                                                                          INTO TABLE t_9004
                                                                                                          WHERE pernr EQ w_p9004-pernr.

                                                                                                            SORT t_9004 BY begda DESCENDING.
                                                                                                            LOOP AT t_9004 INTO DATA(wa_aux).
                                                                                                              IF sy-tabix GT 3.
                                                                                                                DELETE t_9004 INDEX sy-tabix.
                                                                                                              ENDIF.
                                                                                                            ENDLOOP.

                                                                                                            SORT t_9004 BY periodo DESCENDING.
                                                                                                            READ TABLE t_9004 INTO DATA(wa_9004) INDEX 1.

                                                                                                            IF wa_9004-periodo IS NOT INITIAL.
                                                                                                              l_peri = wa_9004-periodo + 001.
                                                                                                              MOVE l_peri TO w_p9004-periodo.

                                                                                                              CALL METHOD cl_hr_pnnnn_type_cast=>pnnnn_to_prelp
                                                                                                                EXPORTING
                                                                                                                  pnnnn = w_p9004
                                                                                                                IMPORTING
                                                                                                                  prelp = innnn.
                                                                                                            ENDIF.
                                                                                                          ENDIF.
                                                                                                        ENDIF.
                                                                                                        "ENDMRB

                                                                                                        "MRB - INC0228117
                                                                                                        DATA: t_p0001_p TYPE TABLE OF pa0001,
                                                                                                              w_p0057   TYPE p0057.

                                                                                                      WHEN '0057'.

                                                                                                        IF sy-pfkey EQ 'INS'.
                                                                                                          CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
                                                                                                            EXPORTING
                                                                                                              prelp = innnn
                                                                                                            IMPORTING
                                                                                                              pnnnn = w_p0057.

                                                                                                          IF w_p0057-pernr IS NOT INITIAL.
                                                                                                            SELECT * FROM pa0001
                                                                                                            INTO TABLE t_p0001_p
                                                                                                            WHERE pernr EQ w_p0057-pernr.

                                                                                                              SORT t_p0001_p BY begda DESCENDING.
                                                                                                              READ TABLE t_p0001_p INTO DATA(w_p0001_p) INDEX 1.

                                                                                                              IF w_p0001_p-persg EQ '5'.
                                                                                                                MESSAGE 'Não é permitido lançamento no IT0057' TYPE 'E'.
                                                                                                                EXIT.
                                                                                                              ENDIF.
                                                                                                            ENDIF.
                                                                                                          ENDIF.
                                                                                                          "ENDMRB

                                                                                                          "alteração GAPs esocial
                                                                                                          IF w_p0105-subty = '9016' OR
                                                                                                             w_p0105-subty = '0010'.
                                                                                                            l_num_carac = strlen( w_p0105-usrid_long ).
                                                                                                            IF l_num_carac > 60.
                                                                                                              MESSAGE e045(zhr02) WITH TEXT-044.
                                                                                                            ENDIF.
                                                                                                          ENDIF.

**    WHEN '0021'.
**      CALL METHOD CL_HR_PNNNN_TYPE_CAST=>PRELP_TO_PNNNN
**        EXPORTING
**          PRELP = INNNN
**        IMPORTING
**          PNNNN = W_P0021_1.

** nome
*      CLEAR: w_p0021_1-fcnam, l_num_carac, "-@0004
*             l_data3, l_data4, l_data5, l_data6, l_data7. "-@0004

*      l_data3 = innnn-data3. "-@0004
*      l_data4 = innnn-data4. "-@0004
*      l_data5 = innnn-data5. "-@0004
*      l_data6 = innnn-data6. "-@0004
*      l_data7 = innnn-data7. "-@0004
                                                                                                          "alteração GAPs esocial
*      CONCATENATE w_p0021_1-favor w_p0021_1-fanam INTO w_p0021_1-fcnam SEPARATED BY space. "-@0004
*      l_num_carac = strlen( w_p0021_1-fcnam ). "-@0004
* inicio  +@0004
*      IF l_num_carac GT 70.
*        "Nome Completo deve conter no máximo 70 caracteres.
*        MESSAGE e045(zhr02) WITH text-045.
*      ELSE.
*        CALL METHOD cl_hr_pnnnn_type_cast=>pnnnn_to_prelp
*          EXPORTING
*            pnnnn = w_p0021_1
*          IMPORTING
*            prelp = innnn.
*
*        innnn-data3 = l_data3.
*        innnn-data4 = l_data4.
*        innnn-data5 = l_data5.
*        innnn-data6 = l_data6.
*        innnn-data7 = l_data7.
*
*      ENDIF.

** idade
*      IF w_p0021_1-subty = '2' OR
*         w_p0021_1-subty = '3' OR
*         w_p0021_1-subty = '5' OR
*         w_p0021_1-subty = '6'.
*
*        CALL FUNCTION 'COMPUTE_YEARS_BETWEEN_DATES'
*          EXPORTING
*            first_date                  = sy-datum
**           MODIFY_INTERVAL             = ' '
*            second_date                 = w_p0021_1-fgbdt
*          IMPORTING
*            years_between_dates         = l_anos
*          EXCEPTIONS
*            sequence_of_dates_not_valid = 1
*            OTHERS                      = 2.
*
*        ASSIGN ('(MP039700)P0397') TO <f_0397>.
*        IF <f_0397> IS ASSIGNED.
*          IF l_anos >= 18 AND <f_0397>-icnum IS INITIAL.
*            MESSAGE e045(zhr02) WITH text-046.
*          ENDIF.
*
** cpf - formato já está sendo validado
** validar apenas duplicidade
*          IF NOT <f_0397>-icnum IS INITIAL.
*            SELECT COUNT(*)
*              FROM pa0397
*             WHERE icnum = <f_0397>-icnum
*               AND endda = c_data_fim.
*
*            IF sy-subrc = 0.
*              MESSAGE e045(zhr02) WITH text-047.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*      ENDIF.
* fin -@0004 }
                                                                                                        WHEN '0465'.
* inicio -@0004 {
*      CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
*        EXPORTING
*          prelp = innnn
*        IMPORTING
*          pnnnn = w_p0465.
*
*
*      CASE w_p0465-subty.
*        WHEN '0002'. "identidade
*          l_num_carac = strlen( w_p0465-ident_nr ).
*          IF l_num_carac > 14.
*            MESSAGE e045(zhr02) WITH text-048.
*          ENDIF.
*        WHEN '0003'. "ctps
*          l_num_carac = strlen( w_p0465-ctps_serie ).
*          IF l_num_carac > 5.
*            MESSAGE e045(zhr02) WITH text-057.
*          ENDIF.
*        WHEN '0004'. " órgão de classe
*          CLEAR   t_dynpfields2.
*          REFRESH t_dynpfields2.
*          t_dynpfields2-fieldname = 'Q0465-OCORG'.
*          APPEND t_dynpfields2.
*
*          CALL FUNCTION 'DYNP_VALUES_READ'
*            EXPORTING
*              dyname     = sy-cprog
*              dynumb     = sy-dynnr
*              request    = 'A'
*            TABLES
*              dynpfields = t_dynpfields2.
*
*          READ TABLE t_dynpfields2 WITH KEY fieldname = 'Q0465-OCORG'
*                                   INTO w_dynpfields2.
*
*          IF w_dynpfields2-fieldvalue IS NOT INITIAL.
*            l_num_carac = strlen( w_dynpfields2-fieldvalue  ).
*            IF l_num_carac > 14.
*              MESSAGE e045(zhr02) WITH text-050.
*            ENDIF.
*          ENDIF.
*
*
*          l_num_carac = strlen( w_p0465-creg_nr  ).
*          IF l_num_carac > 14.
*            MESSAGE e045(zhr02) WITH text-050.
*          ENDIF.
*
*          l_num_carac = strlen( w_p0465-creg_name ).
*          IF l_num_carac > 60.
*            MESSAGE e045(zhr02) WITH text-051.
*          ENDIF.
*        WHEN '0006'." número de inscrição do segurado
*          l_num_carac = strlen( w_p0465-pis_nr ).
*          IF l_num_carac > 11.
*            MESSAGE e045(zhr02) WITH text-052.
*          ENDIF.
*        WHEN '0008'."rne
*          l_num_carac = strlen( w_p0465-idfor_nr ).
*          IF l_num_carac > 14.
*            MESSAGE e045(zhr02) WITH text-053.
*          ENDIF.
*        WHEN '0010'.
*
**          "CNH Obrigatória.
**          IF sy-tcode EQ 'PA40'.
**            CALL FUNCTION 'HR_READ_INFOTYPE'
**              EXPORTING
***               TCLAS           = 'A'
**                pernr           = w_p0465-pernr
**                infty           = '0001'
***               BEGDA           = '18000101'
***               ENDDA           = '99991231'
***               BYPASS_BUFFER   = ' '
***               LEGACY_MODE     = ' '
***           IMPORTING
***               SUBRC           =
**              TABLES
**                infty_tab       = t_p0001
**              EXCEPTIONS
**                infty_not_found = 1
**                OTHERS          = 2.
**            IF sy-subrc <> 0.
*** Implement suitable error handling here
**            ENDIF.
***          DELETE t_p0001 WHERE subty NE '0010'.
**            SORT t_p0001 DESCENDING BY endda.
**            READ TABLE t_p0001 INTO w_p0001 INDEX 1.
**
***          SELECT * FROM hrp1001 INTO TABLE t_hrp1001
***                                WHERE plvar EQ '01'
***                                  AND otype EQ 'S'
***                                  AND objid EQ w_p0001-stell
***                                  AND rsign EQ 'B'
***                                  AND relat EQ '007'
***                                  AND endda EQ '99991231'.
***          SORT t_hrp1001 DESCENDING BY endda.
***          READ TABLE t_hrp1001 INDEX 1 INTO w_hrp1001.
***          l_sobid = w_hrp1001-sobid.
**
**            SELECT * FROM hrp9230 WHERE plvar EQ '01'
**                                    AND otype EQ 'C'
**                                    AND objid EQ w_p0001-stell
**                                    AND endda EQ '99991231'.
**              l_cnhobg = hrp9230-cnh_obrg.
**            ENDSELECT.
**            IF sy-ucomm NE 'UPD' AND
**               w_p0465-DRIVE_NR IS NOT INITIAL.
**              IF sy-ucomm NE 'INS'.
**                MESSAGE e045(zhr02) WITH text-060.
**              ENDIF.
**            ENDIF.
**          ENDIF.
*          IF w_p0465-drive_cat NE 'A' AND
*             w_p0465-drive_cat NE 'B' AND
*             w_p0465-drive_cat NE 'C' AND
*             w_p0465-drive_cat NE 'D' AND
*             w_p0465-drive_cat NE 'E' AND
*             w_p0465-drive_cat NE 'AB' AND
*             w_p0465-drive_cat NE 'AC' AND
*             w_p0465-drive_cat NE 'AD' AND
*             w_p0465-drive_cat NE 'AE'.
*            MESSAGE e045(zhr02) WITH text-054.
*          ENDIF.
*          l_num_carac = strlen( w_p0465-drive_cat ).
*          IF l_num_carac > 2.
*            MESSAGE e045(zhr02) WITH text-058.
*          ENDIF.
*        WHEN '0014'.
*          CLEAR t_dynpfields2.
*          REFRESH t_dynpfields2.
*          t_dynpfields2-fieldname = 'Q0465-RICNR'.
*          APPEND t_dynpfields2.
*
*          CALL FUNCTION 'DYNP_VALUES_READ'
*            EXPORTING
*              dyname     = sy-cprog
*              dynumb     = sy-dynnr
*              request    = 'A'
*            TABLES
*              dynpfields = t_dynpfields2.
*
*          READ TABLE t_dynpfields2 WITH KEY fieldname = 'Q0465-RICNR'
*                                   INTO w_dynpfields2.
*
*          IF w_dynpfields2-fieldvalue IS NOT INITIAL.
*            l_num_carac = strlen( w_dynpfields2-fieldvalue  ).
*            IF l_num_carac > 14.
*              MESSAGE e045(zhr02) WITH text-055.
*            ENDIF.
*          ENDIF.
*
*
*          l_num_carac = strlen( w_p0465-creg_nr  ).
*          IF l_num_carac > 14.
*            MESSAGE e045(zhr02) WITH text-050.
*          ENDIF.
*
*          l_num_carac = strlen( w_p0465-creg_name ).
*          IF l_num_carac > 60.
*            MESSAGE e045(zhr02) WITH text-051.
*          ENDIF.
* fin - @0004 }
* inicio + @0004 {
                                                                                                          CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
                                                                                                            EXPORTING
                                                                                                              prelp = innnn
                                                                                                            IMPORTING
                                                                                                              pnnnn = w_p0465.


                                                                                                          CASE w_p0465-subty.
                                                                                                            WHEN '0002'. "identidade
*          l_num_carac = strlen( w_p0465-ident_nr ).
*          if l_num_carac > 14.
*            message e045(zhr02) with text-048.
*          endif.
                                                                                                            WHEN '0003'. "ctps
*          l_num_carac = strlen( w_p0465-ctps_serie ).
*          if l_num_carac > 5.
*            message e045(zhr02) with text-049.
*          endif.
                                                                                                            WHEN '0004'. " órgão de classe
*          l_num_carac = strlen( w_p0465-creg_nr  ).
*          if l_num_carac > 14.
*            message e045(zhr02) with text-050.
*          endif.

*          l_num_carac = strlen( w_p0465-creg_name ).
*          if l_num_carac > 60.
*            message e045(zhr02) with text-051.
*          endif.
                                                                                                            WHEN '0006'." número de inscrição do segurado
*          l_num_carac = strlen( w_p0465-pis_nr ).
*          if l_num_carac > 11.
*            message e045(zhr02) with text-052.
*          endif.
                                                                                                            WHEN '0008'."rne
*          l_num_carac = strlen( w_p0465-idfor_nr ).
*          if l_num_carac > 14.
*            message e045(zhr02) with text-053.
*          endif.
                                                                                                            WHEN '0010'.
*          if w_p0465-drive_cat ne 'A' and
*             w_p0465-drive_cat ne 'B' and
*             w_p0465-drive_cat ne 'C' and
*             w_p0465-drive_cat ne 'D' and
*             w_p0465-drive_cat ne 'E' and
*             w_p0465-drive_cat ne 'AB' and
*             w_p0465-drive_cat ne 'AC' and
*             w_p0465-drive_cat ne 'AD' and
*             w_p0465-drive_cat ne 'AE'.
*            message e045(zhr02) with text-054.
*          endif.
                                                                                                            WHEN '9012'."ric
*          l_num_carac = strlen( w_p0465-ident_nr ).
*          if l_num_carac > 14.
*            message e045(zhr02) with text-055.
*          endif.
* fin + @0004 }
                                                                                                            WHEN '9012'."ric
*          l_num_carac = strlen( w_p0465-ident_nr ).
*          if l_num_carac > 14.
*            message e045(zhr02) with text-055.
*          endif.
                                                                                                          ENDCASE.



                                                                                                      ENDCASE.

* >>> Início das alterações - HCMx - SSTI 13739
                                                                                                      IF ( sy-tcode EQ c_pa30 OR sy-tcode = c_pa_70 )
                                                                                                         AND ( innnn-infty  EQ c_0014 OR innnn-infty  EQ c_0015 )
                                                                                                         AND ( sy-pfkey EQ 'INS' OR  sy-pfkey EQ 'MOD' ).

                                                                                                        REFRESH: t_parametros.
                                                                                                        CALL FUNCTION 'ZFSD_CONSTANTES1'
                                                                                                          EXPORTING
                                                                                                            i_code           = c_pa_30
                                                                                                            i_param          = c_bukrs
                                                                                                          TABLES
                                                                                                            ztbbc_parametros = t_parametros.

                                                                                                        LOOP AT t_parametros INTO w_parametros.
                                                                                                          r_empresa-sign = 'I'.
                                                                                                          r_empresa-option = 'EQ'.
                                                                                                          r_empresa-low = w_parametros-zvlpar.
                                                                                                          APPEND r_empresa.
                                                                                                        ENDLOOP.

                                                                                                        REFRESH: t_parametros.
                                                                                                        CALL FUNCTION 'ZFSD_CONSTANTES1'
                                                                                                          EXPORTING
                                                                                                            i_code           = c_pa_30
                                                                                                            i_param          = c_lgart
                                                                                                          TABLES
                                                                                                            ztbbc_parametros = t_parametros.

                                                                                                        LOOP AT t_parametros INTO w_parametros.
                                                                                                          r_lgart-sign = 'I'.
                                                                                                          r_lgart-option = 'EQ'.
                                                                                                          r_lgart-low = w_parametros-zvlpar.
                                                                                                          APPEND r_lgart.
                                                                                                        ENDLOOP.

                                                                                                        IF w_pa0001-bukrs NOT IN r_empresa AND innnn-data1(4) IN r_lgart.
                                                                                                          MESSAGE e368(00) WITH TEXT-056.
                                                                                                        ENDIF.

                                                                                                      ENDIF.
* <<< Fim das alterações - HCMx - SSTI 13739

* Fim de Inclusão - T3JOILSORJ - 16.09.2015


*** Strong iT - 22.07.2021 - Início
*** Mudança: 4055674 - Chamado RITM0202844
                                                                                                      IF innnn-infty  EQ '0167' AND innnn-subty EQ 'MEDI'.
                                                                                                        DATA: t_0397  TYPE TABLE OF p0397,
                                                                                                              w_p0397 TYPE pa0397,
                                                                                                              w_0465  TYPE pa0465.


                                                                                                        CLEAR: w_p0397, w_0465, t_0397[], t_0167[].
*       Ler infotipo 0397
                                                                                                        CALL FUNCTION 'HR_READ_INFOTYPE'
                                                                                                          EXPORTING
                                                                                                            pernr           = innnn-pernr
                                                                                                            infty           = '0397'
                                                                                                            begda           = innnn-begda
                                                                                                            endda           = innnn-endda
                                                                                                          TABLES
                                                                                                            infty_tab       = t_0397
                                                                                                          EXCEPTIONS
                                                                                                            infty_not_found = 1
                                                                                                            OTHERS          = 2.
                                                                                                        IF sy-subrc <> 0.
                                                                                                          CLEAR: t_0397[].
                                                                                                        ENDIF.

*Seleção da tela dependentes com flag
                                                                                                        ASSIGN ('(MP016700)POSS_DEPENDENTS[]') TO <f_z_dep>.
                                                                                                        IF <f_z_dep> IS NOT INITIAL.
                                                                                                          LOOP AT <f_z_dep> ASSIGNING <f_zs_dep> WHERE seldp EQ 'X'.
                                                                                                            READ TABLE t_0397 ASSIGNING FIELD-SYMBOL(<f_z_0397>) WITH KEY subty = <f_zs_dep>-dep_type
                                                                                                                                                                           objps = <f_zs_dep>-dep_id.
*Procura no infotipo 0397 se existe outro PERNR com o mesmo dependente
                                                                                                            IF sy-subrc EQ 0.
                                                                                                              SELECT SINGLE *
                                                                                                                FROM pa0397
                                                                                                                INTO w_p0397
                                                                                                                WHERE pernr NE innnn-pernr
                                                                                                                AND   icnum EQ <f_z_0397>-icnum
                                                                                                                AND   endda EQ '99991231'.
                                                                                                                IF sy-subrc EQ 0.

                                                                                                                  " Se encontrar outro PERNR com o mesmo Dependente
                                                                                                                  " verifica se o dependente está com o flag
                                                                                                                  SELECT *
                                                                                                                    FROM pa0167
                                                                                                                    INTO TABLE t_0167
                                                                                                                    WHERE pernr EQ w_p0397-pernr
                                                                                                                    AND   subty EQ 'MEDI'
                                                                                                                    AND   endda EQ '99991231'.

                                                                                                                    IF sy-subrc EQ 0.
                                                                                                                      LOOP AT t_0167 ASSIGNING FIELD-SYMBOL(<fs_0167>).
                                                                                                                        CLEAR l_nr.
                                                                                                                        DO 9 TIMES.
                                                                                                                          l_nr = l_nr + 1.
                                                                                                                          CONCATENATE '<fs_0167>-DTY0' l_nr INTO l_dty.
                                                                                                                          CONCATENATE '<fs_0167>-DID0' l_nr INTO l_did.
                                                                                                                          ASSIGN (l_dty) TO FIELD-SYMBOL(<fs_dty>).
                                                                                                                          ASSIGN (l_did) TO FIELD-SYMBOL(<fs_did>).
                                                                                                                          IF sy-subrc EQ 0.
                                                                                                                            IF <fs_dty> EQ w_p0397-subty AND
                                                                                                                               <fs_did> EQ w_p0397-objps.
                                                                                                                              MESSAGE i000(zhr10) WITH TEXT-072 w_p0397-pernr RAISING error_occured.
                                                                                                                            ENDIF.
                                                                                                                          ELSE.
                                                                                                                            EXIT.
                                                                                                                          ENDIF.
                                                                                                                        ENDDO.
                                                                                                                      ENDLOOP.
                                                                                                                    ENDIF.
                                                                                                                  ELSE.
                                                                                                                    " se não encontrar o CPF como dependente verifica se não se trata de um funcionário
                                                                                                                    SELECT SINGLE *
                                                                                                                      FROM pa0465
                                                                                                                      INTO w_0465
                                                                                                                      WHERE tpdoc  EQ '0001'
                                                                                                                      AND   cpf_nr EQ <f_z_0397>-icnum.
                                                                                                                      IF sy-subrc EQ 0.

*** ***checagem se matricula está ativa.
                                                                                                                        SELECT *
                                                                                                                          FROM pa0000
                                                                                                                          INTO TABLE @DATA(t_0000)
                                                                                                                          WHERE pernr EQ @w_0465-pernr.

                                                                                                                          SORT t_0000 BY endda DESCENDING.

                                                                                                                          READ TABLE t_0000 INTO DATA(w_0000) INDEX 1.

                                                                                                                          IF w_0000-stat2 = c_3.

*** ***checagem se matricula está ativa.

                                                                                                                            MESSAGE i000(zhr10) WITH TEXT-072 w_0465-pernr RAISING error_occured.

                                                                                                                          ENDIF.
                                                                                                                        ENDIF.
                                                                                                                      ENDIF.
                                                                                                                    ENDIF.
                                                                                                                  ENDLOOP.
                                                                                                                ELSE.
                                                                                                                  " se titular for dependente de funcionário (contratação de filho dependendte de funcionário)
                                                                                                                  SELECT SINGLE *
                                                                                                                    FROM pa0465
                                                                                                                    INTO w_0465
                                                                                                                    WHERE pernr EQ innnn-pernr
                                                                                                                    AND   tpdoc  EQ '0001'.
                                                                                                                    IF sy-subrc EQ 0.
                                                                                                                      "Procura no infotipo 0397 se existe  PERNR com titular cadastrado como dependente
                                                                                                                      SELECT SINGLE *
                                                                                                                        FROM pa0397
                                                                                                                        INTO w_p0397
                                                                                                                        WHERE pernr NE innnn-pernr
                                                                                                                        AND   icnum EQ w_0465-cpf_nr
                                                                                                                        AND   endda EQ '99991231'.
                                                                                                                        IF sy-subrc EQ 0.
                                                                                                                          MESSAGE i000(zhr10) WITH TEXT-073 w_p0397-pernr RAISING error_occured.
                                                                                                                        ENDIF.
                                                                                                                      ENDIF.
                                                                                                                    ENDIF.
                                                                                                                  ENDIF.
*** Strong iT - 22.07.2021 - FIM

*----------------------------------------*
* Inicio alteração - Renato - 07.06.2022 *
*----------------------------------------*

                                                                                                                  DATA: it_p0001 TYPE TABLE OF pa0001,
                                                                                                                        wa_p0001 TYPE pa0001.

                                                                                                                  DATA: it_p0016  TYPE TABLE OF p0016,
                                                                                                                        it_pa0016 TYPE TABLE OF pa0016,
                                                                                                                        wa_p0016  LIKE LINE OF it_p0016,
                                                                                                                        wa_pa0016 LIKE LINE OF it_pa0016.

                                                                                                                  DATA: it_p0014 TYPE TABLE OF p0014,
                                                                                                                        it_p0377 TYPE TABLE OF p0377,
                                                                                                                        wa_p0014 LIKE LINE OF it_p0014,
                                                                                                                        wa_p0377 LIKE LINE OF it_p0377.

                                                                                                                  DATA: it_p0465  TYPE TABLE OF p0465,
                                                                                                                        it_pa0465 TYPE TABLE OF pa0465,
                                                                                                                        wa_p0465  LIKE LINE OF it_p0465,
                                                                                                                        wa_pa0465 LIKE LINE OF it_pa0465.

* Rubrica Salarial.
                                                                                                                  DATA: lv_lgart TYPE pa0014-lgart.

* Mensagem de Erro.
                                                                                                                  DATA: lv_msg_erro(50) TYPE c.

* Porcentagem FGTS.
                                                                                                                  FIELD-SYMBOLS: <fs_fgtsp> TYPE pa0398-fgtsp.
                                                                                                                  DATA: lv_fgtsp_old TYPE pa0398-fgtsp,
                                                                                                                        lv_fgtsp_new TYPE pa0398-fgtsp.

* Insalubridade.
                                                                                                                  FIELD-SYMBOLS: <fs_insac> TYPE pa0398-insac.
                                                                                                                  DATA: lv_insac_old TYPE pa0398-insac,
                                                                                                                        lv_insac_new TYPE pa0398-insac.

* Periculosidade.
                                                                                                                  FIELD-SYMBOLS: <fs_percc> TYPE pa0398-percc.
                                                                                                                  DATA: lv_percc_old TYPE pa0398-percc,
                                                                                                                        lv_percc_new TYPE pa0398-percc.

* Cód. exp. ag. noc.
                                                                                                                  FIELD-SYMBOLS: <fs_agnoc> TYPE pa0398-agnoc.
                                                                                                                  DATA: lv_agnoc_old TYPE pa0398-agnoc,
                                                                                                                        lv_agnoc_new TYPE pa0398-agnoc.


* Verifica se é PA30 / IT0016 em execução.
                                                                                                                  IF sy-tcode = 'PA30' AND innnn-infty  = '0016'.

                                                                                                                    CLEAR: it_p0001[], it_p0016[],
                                                                                                                           wa_p0001,   wa_p0016.

                                                                                                                    CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
                                                                                                                      EXPORTING
                                                                                                                        prelp = innnn
                                                                                                                      IMPORTING
                                                                                                                        pnnnn = wa_p0016.

                                                                                                                    IF wa_p0016-pernr <> '00000000'.

                                                                                                                      SELECT * FROM pa0001
                                                                                                                        INTO TABLE it_p0001
                                                                                                                       WHERE pernr = wa_p0016-pernr
                                                                                                                         AND endda = '99991231'.

                                                                                                                        IF sy-subrc = 0.

                                                                                                                          READ TABLE it_p0001 INTO wa_p0001 INDEX 1.

*       Obtem valor gravado no infotipo.
                                                                                                                          SELECT SINGLE fgtsp insac percc FROM pa0398
                                                                                                                            INTO (lv_fgtsp_old, lv_insac_old, lv_percc_old)
                                                                                                                           WHERE pernr = wa_p0016-pernr
                                                                                                                             AND endda = wa_p0016-endda
                                                                                                                             AND begda = wa_p0016-begda.

*       Obtem valor digitado em tela => Insalubridade.
                                                                                                                            ASSIGN ('(MP039800)P0398-INSAC') TO <fs_insac>.
                                                                                                                            IF <fs_insac> IS ASSIGNED.
                                                                                                                              lv_insac_new = <fs_insac>.
                                                                                                                            ENDIF.

*       Obtem valor digitado em tela -> Periculosidade
                                                                                                                            ASSIGN ('(MP039800)P0398-PERCC') TO <fs_percc>.
                                                                                                                            IF <fs_percc> IS ASSIGNED.
                                                                                                                              lv_percc_new = <fs_percc>.
                                                                                                                            ENDIF.

*       Obtem valor digitado em tela => Porcentagem FGTS.
                                                                                                                            ASSIGN ('(MP039800)P0398-FGTSP') TO <fs_fgtsp>.
                                                                                                                            IF <fs_fgtsp> IS ASSIGNED.
                                                                                                                              lv_fgtsp_new = <fs_fgtsp>.
                                                                                                                            ENDIF.

*       Obtem valor digitado em tela => Cód. exp. ag. noc.
                                                                                                                            ASSIGN ('(MP039800)P0398-AGNOC') TO <fs_agnoc>.
                                                                                                                            IF <fs_agnoc> IS ASSIGNED.
                                                                                                                              lv_agnoc_new = <fs_agnoc>.
                                                                                                                            ENDIF.

*       REGRAS:
*
*       FGTS deverá ser 0% para: Grupo = 5 ( Estagiário )
*
*       FGTS deverá ser 2% para: Grupo = 1 ( Efetivo CLT )
*                                Subgrupo = 14 ( Aprendiz Horista )
*                                Subgrupo = 06 ( Aprendiz Mensalista )
*
*       FGTS deverá ser 8% para: Grupo = 1 ( Efetivo CLT )
*                                Subgrupo <> 14 ( Aprendiz Horista )
*                                Subgrupo <> 06 ( Aprendiz Mensalista )

                                                                                                                            IF wa_p0001-persg = '5'.

                                                                                                                              IF lv_fgtsp_new > 0.
                                                                                                                                IF sy-ucomm = 'UPD'.
                                                                                                                                  IF lv_fgtsp_old <> lv_fgtsp_new.
                                                                                                                                    MESSAGE ID 'ZHR' TYPE 'E' NUMBER '000' WITH 'FGTS deverá ser 0% para estagiário.' RAISING error_occured.
                                                                                                                                  ENDIF.
                                                                                                                                ELSE.
                                                                                                                                  MESSAGE ID 'ZHR' TYPE 'W' NUMBER '000' WITH 'FGTS deverá ser 0% para estagiário.' RAISING error_occured.
                                                                                                                                ENDIF.
                                                                                                                              ENDIF.

                                                                                                                            ELSEIF wa_p0001-persg = '1'.

                                                                                                                              IF ( wa_p0001-persk = '14' OR wa_p0001-persk = '06' ).

                                                                                                                                IF lv_fgtsp_new <> 2.
                                                                                                                                  IF sy-ucomm = 'UPD'.
                                                                                                                                    IF lv_fgtsp_old <> lv_fgtsp_new.
                                                                                                                                      MESSAGE ID 'ZHR' TYPE 'E' NUMBER '000' WITH 'FGTS deverá ser 2% para esse funcionário.' RAISING error_occured.
                                                                                                                                    ENDIF.
                                                                                                                                  ELSE.
                                                                                                                                    MESSAGE ID 'ZHR' TYPE 'W' NUMBER '000' WITH 'FGTS deverá ser 2% para esse funcionário.' RAISING error_occured.
                                                                                                                                  ENDIF.
                                                                                                                                ENDIF.

                                                                                                                              ELSEIF ( wa_p0001-persk <> '14' AND wa_p0001-persk <> '06' ).

                                                                                                                                IF lv_fgtsp_new <> 8.
                                                                                                                                  IF sy-ucomm = 'UPD'.
                                                                                                                                    IF lv_fgtsp_old <> lv_fgtsp_new.
                                                                                                                                      MESSAGE ID 'ZHR' TYPE 'E' NUMBER '000' WITH 'FGTS deverá ser 8% para esse funcionário.' RAISING error_occured.
                                                                                                                                    ENDIF.
                                                                                                                                  ELSE.
                                                                                                                                    MESSAGE ID 'ZHR' TYPE 'W' NUMBER '000' WITH 'FGTS deverá ser 8% para esse funcionário.' RAISING error_occured.
                                                                                                                                  ENDIF.
                                                                                                                                ENDIF.

                                                                                                                              ENDIF.

                                                                                                                            ENDIF.

*       Exceção da Nexa 7005 e 7044 que permanecerá sem essa consistência.
                                                                                                                            IF ( wa_p0001-bukrs <> '7005' AND wa_p0001-bukrs <> '7044' ).

*         Não permitirá que um empregado tenha periculosidade e insalubridade ao mesmo
*         tempo, apenas uma das opções poderá ser concedida, ou nenhuma delas.
                                                                                                                              IF ( lv_insac_new = 'X' AND lv_percc_new = 'X' ).

                                                                                                                                IF sy-ucomm = 'UPD'.
                                                                                                                                  MESSAGE ID 'ZHR' TYPE 'E' NUMBER '000'
                                                                                                                                     WITH 'Peric. e Insal. ao mesmo tempo não permitido.' RAISING error_occured.
                                                                                                                                ELSE.
                                                                                                                                  MESSAGE ID 'ZHR' TYPE 'W' NUMBER '000'
                                                                                                                                     WITH 'Peric. e Insal. ao mesmo tempo não permitido.' RAISING error_occured.
                                                                                                                                ENDIF.

                                                                                                                              ENDIF.

                                                                                                                            ENDIF.

*       Será obrigatório informar o campo “Cód. Exp. Ag. Noc.” para os empregados que tenham insalubridade.
                                                                                                                            IF lv_insac_new = 'X' AND lv_agnoc_new IS INITIAL.

                                                                                                                              IF sy-ucomm = 'UPD'.
                                                                                                                                MESSAGE ID 'ZHR' TYPE 'E' NUMBER '000'
                                                                                                                                   WITH 'Obrigatório informar "Cód. Exp. Ag. Noc.".' RAISING error_occured.
                                                                                                                              ELSE.
                                                                                                                                MESSAGE ID 'ZHR' TYPE 'W' NUMBER '000'
                                                                                                                                   WITH 'Obrigatório informar "Cód. Exp. Ag. Noc.".' RAISING error_occured.
                                                                                                                              ENDIF.

*       Não pode aceitar campo vazio ou preenchido com  “Não exposição a agente nocivo”
                                                                                                                            ELSEIF lv_insac_new = 'X' AND ( lv_agnoc_new = '01' OR lv_agnoc_new = '05' ).

                                                                                                                              IF sy-ucomm = 'UPD'.
                                                                                                                                MESSAGE ID 'ZHR' TYPE 'E' NUMBER '000'
                                                                                                                                   WITH 'Cód. Exp. Ag. Noc. informado não permitido.' RAISING error_occured.
                                                                                                                              ELSE.
                                                                                                                                MESSAGE ID 'ZHR' TYPE 'W' NUMBER '000'
                                                                                                                                   WITH 'Cód. Exp. Ag. Noc. informado não permitido.' RAISING error_occured.
                                                                                                                              ENDIF.

                                                                                                                            ENDIF.

                                                                                                                          ENDIF.
                                                                                                                        ENDIF.
* Verifica se é PA30 / IT0014 em execução.
                                                                                                                      ELSEIF ( sy-tcode = 'PA30' OR sy-tcode = 'PA40' ) AND innnn-infty  = '0014'.

                                                                                                                        CLEAR: it_p0014[], it_pa0016[],
                                                                                                                               wa_p0014,   wa_pa0016.

                                                                                                                        CLEAR: lv_insac_old, lv_percc_old.

*   Obtem valor digitado em tela => IT0014.
                                                                                                                        CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
                                                                                                                          EXPORTING
                                                                                                                            prelp = innnn
                                                                                                                          IMPORTING
                                                                                                                            pnnnn = wa_p0014.

                                                                                                                        IF wa_p0014-pernr NE '00000000'.

*     Obtem valor gravado no infotipo IT0016.
                                                                                                                          SELECT * FROM pa0016
                                                                                                                            INTO TABLE it_pa0016
                                                                                                                           WHERE pernr EQ wa_p0014-pernr
                                                                                                                             AND endda GE wa_p0014-begda
                                                                                                                             AND begda LE wa_p0014-endda.

                                                                                                                            IF sy-subrc = 0.

                                                                                                                              READ TABLE it_pa0016 INTO wa_pa0016 INDEX 1.

*       Obtem valor gravado no infotipo IT0398.
                                                                                                                              SELECT SINGLE insac percc FROM pa0398
                                                                                                                                INTO (lv_insac_old, lv_percc_old)
                                                                                                                               WHERE pernr EQ wa_pa0016-pernr
                                                                                                                                 AND endda GE wa_pa0016-endda
                                                                                                                                 AND begda LE wa_pa0016-begda.

                                                                                                                                IF sy-subrc = 0.

*         Haverá uma consistência no infotipo 14 permitindo que seja adicionado:
*         - Rubrica 6730 para os empregados que tenham periculosidade no IT0016.
                                                                                                                                  IF ( wa_p0014-lgart = '6730' AND lv_percc_old = '' ).

                                                                                                                                    IF sy-ucomm = 'UPD'.
                                                                                                                                      MESSAGE ID 'ZHR' TYPE 'E' NUMBER '000'
                                                                                                                                         WITH 'Rubrica para empregados com periculosidade.' RAISING error_occured.
                                                                                                                                    ELSE.
                                                                                                                                      MESSAGE ID 'ZHR' TYPE 'W' NUMBER '000'
                                                                                                                                         WITH 'Rubrica para empregados com periculosidade.' RAISING error_occured.
                                                                                                                                    ENDIF.

*         - Rubrica 6731 para os empregados que tenham insalubridade no IT0016.
                                                                                                                                  ELSEIF ( wa_p0014-lgart = '6731' AND lv_insac_old = '' ).

                                                                                                                                    IF sy-ucomm = 'UPD'.
                                                                                                                                      MESSAGE ID 'ZHR' TYPE 'E' NUMBER '000'
                                                                                                                                         WITH 'Rubrica para empregados com insalubridade.' RAISING error_occured.
                                                                                                                                    ELSE.
                                                                                                                                      MESSAGE ID 'ZHR' TYPE 'W' NUMBER '000'
                                                                                                                                         WITH 'Rubrica para empregados com insalubridade.' RAISING error_occured.
                                                                                                                                    ENDIF.

                                                                                                                                  ENDIF.

                                                                                                                                ENDIF.
                                                                                                                              ENDIF.
*** Início de Inclusão - T3MOISESRT - 04.09.2022
*     Verifica se a é rubrica de beneficio
                                                                                                                              IF sy-ucomm = 'UPD' OR sy-ucomm = 'INS' OR sy-ucomm = 'DEL' OR sy-ucomm = 'LIS' .

                                                                                                                                CLEAR: t_parametros[].
                                                                                                                                l_param = wa_p0014-lgart.
                                                                                                                                CONCATENATE '%' c_benrub '%' INTO l_programn.
                                                                                                                                SELECT * INTO TABLE t_parametros
                                                                                                                                FROM ztbhr_ben_377
                                                                                                                                WHERE programm LIKE l_programn
                                                                                                                                AND zparam EQ l_param.

                                                                                                                                  IF t_parametros[] IS NOT INITIAL .
*          c_benef
                                                                                                                                    t_valper[] = t_parametros[].
                                                                                                                                    t_area[] = t_parametros[].
                                                                                                                                    t_empresa[] = t_parametros[].
                                                                                                                                    t_atribui[] = t_parametros[].
                                                                                                                                    t_unidade[] = t_parametros[].


*       Busca dados da empresa e da empresa
*       leitura infotipo 0001
                                                                                                                                    CALL FUNCTION 'HR_READ_INFOTYPE'
                                                                                                                                      EXPORTING
                                                                                                                                        pernr           = innnn-pernr
                                                                                                                                        infty           = '0001'
                                                                                                                                        begda           = innnn-begda
                                                                                                                                        endda           = innnn-endda
                                                                                                                                      TABLES
                                                                                                                                        infty_tab       = t_p0001
                                                                                                                                      EXCEPTIONS
                                                                                                                                        infty_not_found = 1
                                                                                                                                        OTHERS          = 2.
                                                                                                                                    IF sy-subrc EQ 0.
                                                                                                                                      READ TABLE t_p0001 INTO w_p0001 INDEX 1.
                                                                                                                                      IF sy-subrc EQ 0.
                                                                                                                                        l_bukrs = w_p0001-bukrs.
                                                                                                                                        l_werks = w_p0001-werks.
                                                                                                                                      ENDIF.  "IF sy-subrc EQ 0.
                                                                                                                                    ENDIF.

*       Verifica a empresa
                                                                                                                                    CLEAR: l_find.
                                                                                                                                    LOOP AT t_parametros INTO w_parametros.
                                                                                                                                      IF w_parametros-zvlpar CS l_bukrs OR w_parametros-zvlpar CS '*' .
                                                                                                                                        l_find = 'X'.
                                                                                                                                        l_len = strlen( w_parametros-programm ).
                                                                                                                                        l_len = l_len - 4.
                                                                                                                                        l_pltyp = w_parametros-programm+l_len(4).
                                                                                                                                        EXIT.
                                                                                                                                      ENDIF.  "IF w_parametros-zvlpar CS l_bukrs.
                                                                                                                                    ENDLOOP.  "LOOP AT t_parametros INTO w_parametros.
                                                                                                                                    IF l_find IS INITIAL.
                                                                                                                                      LOOP AT t_parametros INTO w_parametros.
                                                                                                                                        IF w_parametros-zvlpar CS l_werks.
                                                                                                                                          l_find = 'X'.
                                                                                                                                          l_len = strlen( w_parametros-programm ).
                                                                                                                                          l_len = l_len - 4.
                                                                                                                                          l_pltyp = w_parametros-programm+l_len(4).
                                                                                                                                          EXIT.
                                                                                                                                        ENDIF.  "IF w_parametros-zvlpar CS l_bukrs.
                                                                                                                                      ENDLOOP.  "LOOP AT t_parametros INTO w_parametros.
                                                                                                                                    ENDIF. "IF l_find IS INITIAL.
                                                                                                                                    IF l_find IS INITIAL.
                                                                                                                                      MESSAGE ID 'ZHR' TYPE 'E' NUMBER '000'
                                                                                                                                                       WITH 'Rubrica não elegível.' RAISING error_occured.
                                                                                                                                    ENDIF.
                                                                                                                                    CLEAR l_find.
*        Verifica se deve ser tratado a unidade
                                                                                                                                    DELETE t_unidade  WHERE zdesc NE c_unid.
                                                                                                                                    IF t_unidade[] IS NOT INITIAL.
                                                                                                                                      READ TABLE t_unidade INTO w_unidade INDEX 1.
                                                                                                                                      IF sy-subrc EQ 0.
                                                                                                                                        IF l_werks EQ '7351' OR  l_werks EQ '7352'.
                                                                                                                                          IF wa_p0014-anzhl NE 1 AND wa_p0014-anzhl NE 2.
                                                                                                                                            MESSAGE ID 'ZHR' TYPE 'E' NUMBER '000'
                                                                                                                                            WITH 'Campo Nº/Unidade deve ser 1 ou 2' RAISING error_occured.
                                                                                                                                          ENDIF.  "IF wa_p0014-anzhl EQ 0.
                                                                                                                                        ELSE.
                                                                                                                                          l_str = wa_p0014-anzhl.
                                                                                                                                          IF wa_p0014-anzhl EQ 0.
                                                                                                                                            MESSAGE ID 'ZHR' TYPE 'E' NUMBER '000'
                                                                                                                                            WITH 'Campo Nº/Unidade é obrigatório' RAISING error_occured.
                                                                                                                                          ELSEIF w_unidade-zvlpar EQ c_dep. "verifica se tem que calcular o dep
*               leitura infotipo 0021
                                                                                                                                            CLEAR: t_p0021[].
                                                                                                                                            CALL FUNCTION 'HR_READ_INFOTYPE'
                                                                                                                                              EXPORTING
                                                                                                                                                pernr           = innnn-pernr
                                                                                                                                                infty           = '0021'
                                                                                                                                                begda           = innnn-begda
                                                                                                                                                endda           = innnn-endda
                                                                                                                                              TABLES
                                                                                                                                                infty_tab       = t_p0021
                                                                                                                                              EXCEPTIONS
                                                                                                                                                infty_not_found = 1
                                                                                                                                                OTHERS          = 2.
                                                                                                                                            IF t_p0021[] IS NOT INITIAL.
                                                                                                                                              DESCRIBE TABLE t_p0021 LINES l_line.
                                                                                                                                              IF wa_p0014-anzhl > l_line .
                                                                                                                                                MESSAGE ID 'ZHR' TYPE 'E' NUMBER '000'
                                                                                                                                                WITH 'Campo Nº/Atribuição é obrigatório' RAISING error_occured.
*                      Campo Nº/Unidade pode ter no máximo a qtd de dep.
                                                                                                                                              ENDIF.

                                                                                                                                            ENDIF.
                                                                                                                                          ELSE.
                                                                                                                                            l_val = l_str.
                                                                                                                                            REPLACE  '.' WITH '' INTO l_val.
                                                                                                                                            CONDENSE l_val NO-GAPS.
                                                                                                                                            IF w_unidade-zvlpar NS l_val.
                                                                                                                                              MESSAGE ID 'ZHR' TYPE 'E' NUMBER '000'
                                                                                                                                              WITH 'Campo Nº/Unidade não permitido' RAISING error_occured.
                                                                                                                                            ENDIF.
                                                                                                                                          ENDIF.
                                                                                                                                        ENDIF.
                                                                                                                                      ENDIF.  "IF sy-subr EQ 0.
                                                                                                                                    ENDIF.
                                                                                                                                    DELETE t_atribui  WHERE zdesc NE c_atri .
                                                                                                                                    IF t_atribui[] IS NOT INITIAL.
                                                                                                                                      IF wa_p0014-zuord IS INITIAL .
                                                                                                                                        MESSAGE ID 'ZHR' TYPE 'E' NUMBER '000'
                                                                                                                                           WITH 'Campo Nº/Atribuição é obrigatório' RAISING error_occured.

                                                                                                                                      ENDIF.

                                                                                                                                    ENDIF.
                                                                                                                                    IF  sy-tcode NE 'PA40' .
*       leitura infotipo 377
                                                                                                                                      CALL FUNCTION 'HR_READ_INFOTYPE'
                                                                                                                                        EXPORTING
                                                                                                                                          pernr           = innnn-pernr
                                                                                                                                          infty           = '0377'
                                                                                                                                          begda           = innnn-begda
                                                                                                                                          endda           = innnn-endda
                                                                                                                                        TABLES
                                                                                                                                          infty_tab       = t_p0377
                                                                                                                                        EXCEPTIONS
                                                                                                                                          infty_not_found = 1
                                                                                                                                          OTHERS          = 2.

                                                                                                                                      IF sy-subrc EQ 0.

                                                                                                                                        SORT t_p0377 BY pltyp.
                                                                                                                                        READ TABLE t_p0377 TRANSPORTING NO FIELDS WITH KEY bplan = l_pltyp
                                                                                                                                                                                  BINARY SEARCH.
                                                                                                                                        IF sy-subrc NE 0.
*           Se não achar significa que a rubrica não pode ser gravada.
                                                                                                                                          MESSAGE ID 'ZHR' TYPE 'E' NUMBER '000'
                                                                                                                                             WITH 'Rubrica não elegível.' RAISING error_occured.

                                                                                                                                        ENDIF.  "IF sy-subrc NE 0.

                                                                                                                                      ENDIF.  "IF sy-subrc EQ 0.
                                                                                                                                    ENDIF.
                                                                                                                                  ENDIF.
                                                                                                                                ENDIF.
                                                                                                                              ENDIF.

* Verifica se é PA30 / IT0465 em execução.
                                                                                                                            ELSEIF sy-tcode = 'PA30' AND innnn-infty  = '0465'.

                                                                                                                              CLEAR: it_p0465[], it_pa0465[],
                                                                                                                                     wa_p0465,   wa_pa0465.

*   Obtem valor digitado em tela => IT0465.
                                                                                                                              CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
                                                                                                                                EXPORTING
                                                                                                                                  prelp = innnn
                                                                                                                                IMPORTING
                                                                                                                                  pnnnn = wa_p0465.

                                                                                                                              IF ( wa_p0465-pernr NE '00000000' AND wa_p0465-subty EQ '0006' ).

*     Obtem valor gravado no infotipo IT0465.
                                                                                                                                SELECT * FROM pa0465
                                                                                                                                  INTO TABLE it_pa0465
                                                                                                                                 WHERE pis_nr EQ wa_p0465-pis_nr
                                                                                                                                   AND endda  EQ '99991231'.

                                                                                                                                  IF sy-subrc = 0.

                                                                                                                                    READ TABLE it_pa0465 INTO wa_pa0465 INDEX 1.

                                                                                                                                    CONCATENATE 'Nr PIS já cadastrado para:' wa_pa0465-pernr INTO lv_msg_erro SEPARATED BY space.

                                                                                                                                    IF sy-ucomm = 'UPD'.
                                                                                                                                      MESSAGE ID 'ZHR' TYPE 'E' NUMBER '000' WITH lv_msg_erro RAISING error_occured.
                                                                                                                                    ELSE.
                                                                                                                                      MESSAGE ID 'ZHR' TYPE 'W' NUMBER '000' WITH lv_msg_erro RAISING error_occured.
                                                                                                                                    ENDIF.

                                                                                                                                  ENDIF.
                                                                                                                                ENDIF.
                                                                                                                              ELSEIF innnn-infty  = '0377'.
*   Obtem valor digitado em tela => IT0014.
                                                                                                                                CALL METHOD cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
                                                                                                                                  EXPORTING
                                                                                                                                    prelp = innnn
                                                                                                                                  IMPORTING
                                                                                                                                    pnnnn = wa_p0377.
*    busca dados da empresa e da empresa
                                                                                                                                DATA: l_ano   TYPE t569v-pabrj,
                                                                                                                                      l_per   TYPE t569v-pabrp,
                                                                                                                                      t_t569v TYPE TABLE OF t569v,
                                                                                                                                      w_t569v TYPE t569v.

                                                                                                                                CONCATENATE c_benrub wa_p0377-bplan INTO l_programn.
                                                                                                                                SELECT * INTO TABLE t_parametros
                                                                                                                                FROM ztbbc_parametros
                                                                                                                                WHERE programm EQ l_programn.
                                                                                                                                  IF sy-subrc EQ 0.
                                                                                                                                    READ TABLE t_parametros INTO w_parametros WITH KEY zdesc = c_valfol.
                                                                                                                                    IF sy-subrc EQ 0.
*     Leitura infotipo 0001
                                                                                                                                      CALL FUNCTION 'HR_READ_INFOTYPE'
                                                                                                                                        EXPORTING
                                                                                                                                          pernr           = wa_p0377-pernr
                                                                                                                                          infty           = '0001'
                                                                                                                                          begda           = wa_p0377-begda
                                                                                                                                          endda           = wa_p0377-endda
                                                                                                                                        TABLES
                                                                                                                                          infty_tab       = t_p0001
                                                                                                                                        EXCEPTIONS
                                                                                                                                          infty_not_found = 1
                                                                                                                                          OTHERS          = 2.
                                                                                                                                      IF sy-subrc EQ 0.
                                                                                                                                        READ TABLE t_p0001 INTO w_p0001 INDEX 1.
                                                                                                                                        IF sy-subrc EQ 0.
                                                                                                                                          l_abkrs = w_p0001-abkrs.
                                                                                                                                          l_ano = wa_p0377-begda(4).
                                                                                                                                          l_per = wa_p0377-begda+4(2).

                                                                                                                                          SELECT * INTO TABLE t_t569v
                                                                                                                                          FROM t569v
                                                                                                                                          WHERE abkrs = l_abkrs
                                                                                                                                            AND pabrj = l_ano
                                                                                                                                            AND pabrp = l_per.
                                                                                                                                            IF sy-subrc EQ 0.
                                                                                                                                              READ TABLE t_t569v INTO w_t569v INDEX 1.
                                                                                                                                              IF sy-subrc EQ 0.
                                                                                                                                                "Verifica se a folha esta fechada.
                                                                                                                                                IF w_t569v-state EQ '3'.
                                                                                                                                                  MESSAGE ID 'ZHR' TYPE 'E' NUMBER '000'
                                                                                                                                                         WITH 'Folha Bloqueada para Lançamento' RAISING error_occured.
                                                                                                                                                ENDIF.
                                                                                                                                              ENDIF.
                                                                                                                                            ENDIF.

                                                                                                                                          ENDIF.  "IF sy-subrc EQ 0.

                                                                                                                                        ENDIF.  "IF sy-subrc EQ 0.
                                                                                                                                      ENDIF.
                                                                                                                                    ENDIF.  "IF sy-subrc EQ 0.

                                                                                                                                  ENDIF.

*----------------------------------------*
* Fim da alteração - Renato - 07.06.2022 *
*----------------------------------------*

* TFELIPEGE - 04/11/2020


*   LÓGICA PARA A SOLUÇÃO DE DELIMITAÇÃO E ATIVAÇÃO DE INFOTIPOS CONFORME
* AFASTAMENTO OU RETORNO DE AFASTAMENTO DE EMPREGADO.
*   Provavelmente a chamada do include vai pra produção pela request
* E03K9ACNN6 da mudança 4052554 com a instrução IF FOUND para não gerar
* impacto, mas na verdade a solução como um todo está no próprio include
* na mudança 2013455: Afastamento e Retorno de Afastamento

                                                                                                                                  INCLUDE  zihr0314_afastam_e_retorno IF FOUND.

* TFELIPEGE - 04/11/2020 }

***Inicio de Alteração - T3WELLINGTOV - 30.08.2010
*  IF ipsyst-bukrs(1) = c_3.
*    INCLUDE zihr0040_zxpadu02_fibria.
*  ENDIF.
                                                                                                                                  INCLUDE zihr0040_zxpadu02_fibria.
***Fim de Alteração - T3WELLINGTOV - 30.08.2010


**&---------------------------------------------------------------------*
**&      Form  ZCAMBIAR_AGRUP_SDP_TIPO_CONT
**&---------------------------------------------------------------------*
*FORM zcambiar_agrup_sdp_tipo_cont  USING    p_molga p_pernr p_sdate
*                                   CHANGING p_mozko.
*  DATA: t_p0014 LIKE p0014 OCCURS 10 WITH HEADER LINE.
*  RANGES: r_lgart FOR t512t-lgart.
*
*  REFRESH t_p0014. CLEAR: t_p0014.
*  rp-read-infotype p_pernr 0014 t_p0014 p_sdate p_sdate.
*
*  REFRESH: r_lgart.
*  r_lgart-sign = 'I'.
*  r_lgart-option = 'EQ'.
*  r_lgart-low = '1F27'.
*  APPEND r_lgart.
*
*  LOOP AT t_p0014 WHERE lgart IN r_lgart.
*    PERFORM zobtener_mozko USING    p_molga t_p0014-lgart p_sdate
*                           CHANGING p_mozko.
*    EXIT.
*  ENDLOOP.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  ZOBTENER_MOZKO
**&---------------------------------------------------------------------*
*FORM zobtener_mozko  USING    p_molga p_lgart p_sdate
*                     CHANGING p_mozko.
*  DATA: BEGIN OF w_const.
*  DATA: agrup LIKE ztbhr_9906-agrup,
*        field LIKE ztbhr_9906-field,
*        seqnr LIKE ztbhr_9906-seqnr,
*        const LIKE ztbhr_9906-const,
*        signo LIKE ztbhr_9906-signo,
*        opcio LIKE ztbhr_9906-opcion,
*        low   LIKE ztbhr_9906-low,
*        high  LIKE ztbhr_9906-high.
*  DATA: END   OF w_const.
*
*  CLEAR: w_const.
*  w_const-agrup = 'MP200100'.
*  w_const-field = 'MOZKO'.
*  w_const-const = 'AGRUP_TIPO_CONT'.
*
*  CALL FUNCTION 'ZFHR_HCC99_LEER_VALOR_CONSTANT'
*    EXPORTING
*      p_molga             = p_molga
*      p_agrup             = w_const-agrup
*      p_field             = w_const-field
*      p_seqnr             = w_const-seqnr
*      p_const             = w_const-const
*      p_signo             = w_const-signo
*      p_opcion            = w_const-opcio
*      p_begda             = p_sdate
*      p_endda             = p_sdate
*    IMPORTING
*      p_low               = w_const-low
*      p_high              = w_const-high
*    EXCEPTIONS
*      no_existe_constante = 1
*      OTHERS              = 2.
*
*  IF w_const-low EQ space.
*  ELSE.
*    p_mozko = w_const-low.
*  ENDIF.
*
*ENDFORM.