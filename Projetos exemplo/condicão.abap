DELETE FROM /rdsxescn/9099_1 WHERE pernr     IN pnppernr
AND begda     GE pn-begda
AND endda     LE pn-endda
AND ( tipo_conv EQ '1' OR tipo_conv EQ '3' ).