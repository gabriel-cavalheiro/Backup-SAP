
Conforme ALV da transação ar01.

LOOP AT p_fieldcat ASSIGNING <fs_fcat>.

    CASE <fs_fcat>-fieldname.
      WHEN 'AQUISICAO'.
            <fs_fcat>-cfieldname = 'MOEDA'. " campo referencia para assumir qunt de casas decimais
            <fs_fcat>-do_sum     = 'X'.
            <fs_fcat>-outputlen  = 16.
            <fs_fcat>-datatype = 'CURR'.
      WHEN 'DPRN'.
            <fs_fcat>-cfieldname = 'MOEDA'.
            <fs_fcat>-do_sum     = 'X'.
            <fs_fcat>-outputlen  = 16.
            <fs_fcat>-datatype = 'CURR'.
      WHEN 'DPR_ESP'.
            <fs_fcat>-cfieldname = 'MOEDA'.
            <fs_fcat>-do_sum     = 'X'.
            <fs_fcat>-outputlen  = 16.
            <fs_fcat>-datatype = 'CURR'.
      WHEN 'MONT_MOEDA_LOCAL'.
            <fs_fcat>-cfieldname = 'MOEDA'.
            <fs_fcat>-do_sum     = 'X'.
            <fs_fcat>-outputlen  = 16.
            <fs_fcat>-datatype = 'CURR'.
      WHEN 'DEPRECIACAO_01'.
            <fs_fcat>-cfieldname = 'MOEDA'.
            <fs_fcat>-do_sum     = 'X'.
            <fs_fcat>-outputlen  = 16.
            <fs_fcat>-datatype = 'CURR'.
      WHEN 'DEPRECIACAO_04'.
            <fs_fcat>-cfieldname = 'MOEDA'.
            <fs_fcat>-do_sum     = 'X'.
            <fs_fcat>-outputlen  = 16.
            <fs_fcat>-datatype = 'CURR'.
      WHEN 'DEPRECIACAO_20'.
            <fs_fcat>-cfieldname = 'MOEDA'.
            <fs_fcat>-do_sum     = 'X'.
            <fs_fcat>-outputlen  = 16.
            <fs_fcat>-datatype = 'CURR'.
      WHEN 'DEPRECIACAO_21'.
            <fs_fcat>-cfieldname = 'MOEDA'.
            <fs_fcat>-do_sum     = 'X'.
            <fs_fcat>-outputlen  = 16.
            <fs_fcat>-datatype = 'CURR'.
      WHEN 'DEPRECIACAO_65'.
            <fs_fcat>-cfieldname = 'MOEDA'.
            <fs_fcat>-do_sum     = 'X'.
            <fs_fcat>-outputlen  = 16.
            <fs_fcat>-datatype = 'CURR'.
      WHEN 'DEPRECIACAO_68'.
            <fs_fcat>-cfieldname = 'MOEDA'.
            <fs_fcat>-do_sum     = 'X'.
            <fs_fcat>-outputlen  = 16.
            <fs_fcat>-datatype = 'CURR'.
      WHEN 'DEPRECIACAO_69'.
            <fs_fcat>-cfieldname = 'MOEDA'.
            <fs_fcat>-outputlen  = 16.
            <fs_fcat>-datatype = 'CURR'.
      WHEN 'DEPRECIACAO_70'.
            <fs_fcat>-cfieldname = 'MOEDA'.
            <fs_fcat>-do_sum     = 'X'.
            <fs_fcat>-outputlen  = 16.
            <fs_fcat>-datatype = 'CURR'.
      WHEN 'DIF_FISC_CONTAB'.
            <fs_fcat>-cfieldname = 'MOEDA'.
            <fs_fcat>-do_sum     = 'X'.
            <fs_fcat>-outputlen  = 16.
            <fs_fcat>-datatype = 'CURR'.
      WHEN 'DIF_REA_FISCONT'.
            <fs_fcat>-cfieldname = 'MOEDA'.
            <fs_fcat>-do_sum     = 'X'.
            <fs_fcat>-outputlen  = 16.
            <fs_fcat>-datatype = 'CURR'.
      WHEN OTHERS.
*        não altera nada
    ENDCASE.
  ENDLOO