" TIPO PREFIXO EXEMPLO 
" Parameters P_ PARAMETERS: 
" P_BUKRS LIKE T001-BUKRS. 

" Select-options S_ SELECTION-OPTIONS: 
" S_BELNR FOR BKPF-BELNR.

" Ranges R_ RANGES: 
" R_WERKS FOR T001W-WERKS.

" V_ Variável Global 
" L_ Local 
" DATA: V_CNT TYPE P. 
" DATA: L_CVV TYPE P. 
" Field groups/ 
" field symbols 
" F_ FIELD-GROUPS: 
" HEADER, 
" F_LINE. 
" Tabelas 
" internas 
" T_ DATA: BEGIN OF T_T001 OCCURS 0. 
"  INCLUDE STRUCTURE T001.’ 
" DATA: END OF T_T001. 
" DATA: BEGIN OF T_MATNR OCCURS 0, 
"  MATNR(8) TYPE C, 
"  END OF T_MATNR. 
" Field-String ou 
" Estruturas de 
" Dados/Workare
" as 
" W_ DATA: BEGIN OF W_PERSON, 
"  NAME(20) TYPE C, 
"  AGE TYPE I, 
"  END OF W_PERSON. 
" Types Y_ TYPES: BEGIN OF Y_PERSON, 
"  FIELD1 LIKE XFIELD1, 
"  FIELD2 LIKE XFIELD2, 
"  END OF Y_PERSON. 
" OR 
" TYPES: Y_FIELD1 TYPE C. 
" Constants C_ CONSTANTS: C_NBDAYS VALUE 7. 

Objetos de autorização.

" Objetos MM:
" M_BEST_EKO: Organização de Compras
" M_MATE_WRK: Centro
" M_MATE_BUK: Empresa
" M_BEST_BSA: Tipo de Documento no Pedido
" M_ANFR_BSA: Tipo De Documento na cotação
" M_ANFR_EKG: Grupo de compradores em solicitação de cotação
" M_ANFR_EKO: Organização de compras em solicitação de cotação
" M_ANFR_WRK: Centro em solicitação de cotação
" M_MRES_WWA: Reservas: centro
" M_BEST_WRK: centro no pedido

" Objetos SD:
" V_VBRK_VKO: Organização de Vendas
" V_KONH_VKO: Condição: Org de Vendas
" V_KNA1_VKO: Cliente: Org de Vendas
" V_VBRK_FKA: Tipo de Documento Compras
" V_VBAK_AAT: Tipo de Documento de Vendas
" V_VBRR_BUK: Empresa
" V_KONA_VKO: Canal de distribuição e setor de atividade.

" Objetos FI:
" F_BKPF_BUK: Empresa
" F_KNA1_BUK: Empresa/Cliente
" F_BKPF_BUP: períodos contábeis
" F_BKPF_GSB: Divisões
" F_BKPF_KOA: tipo de conta
" F_FAGL_LDR: Ledger
" F_FAGL_SEG: Segmento
" F_BKPF_KOA: Tipo de conta
" F_BKPF_BLA: Tipo de documento
" K_CBPR_PLA: Área Contabilidade Custos
" F_SKA1_KTP: Conta da razão: Plano de Contas
" F_SKA1_BES: Conta da razão acesso as contas
" A_S_KOSTL: Centro de custo

" Objetos PM:
" I_SWERK Centro
" I_AUART: Tipo de Ordem
" I_KOSTL PM: Centros de coste

