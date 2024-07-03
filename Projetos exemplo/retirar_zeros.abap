LOOP AT t_z3003 ASSIGNING FIELD-SYMBOL(<fs_z3003>).
    <fs_z3003>-aufnr = |{ <fs_z3003>-aufnr ALPHA = OUT }|.
ENDLOOP.