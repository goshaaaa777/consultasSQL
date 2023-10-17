--AP PROVISION 2.0--
SELECT sec_comprobante
,orden_compra
,entidad_legal 
,cuenta_contable
,departamento
,producto
,unidad_explotacion
,futuro_1
,futuro_2
,ruc_proveedor
,proveedor
,num_comprobante
,fecha_emision
,fecha_contable
,fecha_recep_factura
,num_tipo_doc
,tipo_doc
,condi_pago
,antiguedad
,pagos
,fecha_vencimiento
,moneda
,importe_origen
,importe_base
,moneda_base
,saldo_x_pagar
,descripcion
,banco_proveedor
,num_cuenta
--,cc_banco
,num_prioridad
,desc_prioridad
,proyecto
,desc_proyecto
,retenido
,desc_retenido
,CANCELLED_DATE
,INVOICE_ID
,proyecto_gasto
FROM (

SELECT api.DOC_SEQUENCE_VALUE     sec_comprobante,
       POH.SEGMENT1               orden_compra,
       GLC.SEGMENT1               entidad_legal,
       GLC.SEGMENT2               cuenta_contable,
       GLC.SEGMENT3               departamento,
       GLC.SEGMENT4               producto,
       GLC.SEGMENT5               unidad_explotacion,
       GLC.SEGMENT7               futuro_1,
       GLC.SEGMENT8               futuro_2,
       POZ.SEGMENT1               ruc_proveedor,
       poz.VENDOR_NAME            proveedor,
       API.INVOICE_NUM            num_comprobante,
       TO_CHAR(API.INVOICE_DATE, 'dd/mm/yyyy') fecha_emision,
       TO_CHAR(API.GL_DATE, 'dd/mm/yyyy')               fecha_contable,
       TO_CHAR(API.INVOICE_RECEIVED_DATE, 'dd/mm/yyyy')  fecha_recep_factura,
       API.ATTRIBUTE1             num_tipo_doc,
       API.INVOICE_TYPE_LOOKUP_CODE tipo_doc,
       TER.NAME                   condi_pago,
       trunc(SYSDATE - API.INVOICE_RECEIVED_DATE) antiguedad,
       (select count(x.CHECK_NUMBER) from AP_CHECKS_ALL x 
        where x.check_id(+) = AIP.check_id) pagos,
       TO_CHAR(APS.DUE_DATE, 'dd/mm/yyyy') fecha_vencimiento,
       API.INVOICE_CURRENCY_CODE  moneda,
       nvl(API.INVOICE_AMOUNT,0)  importe_origen,
       APS.AMOUNT_REMAINING importe_base,
       'PEN'                      moneda_base,
       APS.AMOUNT_REMAINING * nvl(API.EXCHANGE_RATE,1)   saldo_x_pagar,
       nvl(API.EXCHANGE_RATE,1) tipo_cambio,
        API.DESCRIPTION            descripcion,
       (select HPBANK.PARTY_NAME
        from
        iby_account_owners IBACO,
        iby_ext_bank_accounts IBEBA,
        hz_parties           HPBANK,
        hz_parties           hp
        where 1=1
        AND HPBANK.PARTY_ID(+) = IBEBA.BANK_ID
        AND IBEBA.EXT_BANK_ACCOUNT_ID(+) = IBACO.EXT_BANK_ACCOUNT_ID
        AND IBACO.ACCOUNT_OWNER_PARTY_ID(+) = hp.party_id
        and hp.party_id = POZ.party_id
        and IBACO.EXT_BANK_ACCOUNT_ID = ie.ext_bank_account_id
        --AND ROWNUM = 1
        ) banco_proveedor,
       --IE.masked_bank_account_num num_cuenta,
       IE.BANK_ACCOUNT_NUM num_cuenta,
       /*(SELECT gcc.segment2
        FROM ce_bank_accounts cab
        ,gl_code_combinations gcc
        ,CE_BANK_ACCT_USES_ALL cbau
        where 1=1
        and APC.CE_BANK_ACCT_USE_ID= cbau.BANK_ACCT_USE_ID
        and cab.ASSET_CODE_COMBINATION_ID =gcc.code_combination_id 
        and cbau.bank_account_id = cab.bank_account_id) cc_banco,*/
       APS.PAYMENT_PRIORITY       num_prioridad,
       API.PAY_GROUP_LOOKUP_CODE  desc_prioridad,
       GLC.SEGMENT6               proyecto,
       gl_flexfields_pkg.get_description_sql(glc.chart_of_accounts_id,6,proy_gasto.SEGMENT6) desc_proyecto,
       APS.HOLD_FLAG retenido,
       APS.IBY_HOLD_REASON desc_retenido,
	API.CANCELLED_DATE,
	api.invoice_id,
    --'AP_INVOICES' xtype
      proy_gasto.SEGMENT6 proyecto_gasto
FROM
AP_INVOICES_ALL          API,
PO_HEADERS_ALL           POH,
GL_CODE_COMBINATIONS     GLC,
POZ_SUPPLIERS_V          POZ,
--POZ_SUPPLIER_SITES_V     PSS,
AP_TERMS_V               TER,
AP_INVOICE_PAYMENTS_ALL  AIP,
AP_CHECKS_ALL            APC,
AP_PAYMENT_SCHEDULES_ALL APS,
--AP_HOLDS_ALL             AHA,
iby_ext_bank_accounts    ie,
ce_bank_branches_v       cb,
--hz_parties               hp
xla_ae_lines             xal,
xla_ae_headers           xah,
xla_transaction_entities xte,
(select a.SEGMENT6, d.source_id_int_1, c.ae_line_num
from GL_CODE_COMBINATIONS     a,
       xla_ae_lines             c,
       xla_ae_headers           b,
       xla_transaction_entities d
where 1=1
AND c.CODE_COMBINATION_ID = a.CODE_COMBINATION_ID
AND c.ae_header_id = b.ae_header_id
AND c.application_id = b.application_id
AND b.entity_id = d.entity_id
AND b.application_id = d.application_id
AND d.entity_code = 'AP_PAYMENTS'
AND c.ACCOUNTING_CLASS_CODE = 'ITEM EXPENSE') proy_gasto,
(select d.source_id_int_1, min(c.ae_line_num) as ae_line_num
from GL_CODE_COMBINATIONS     a,
       xla_ae_lines             c,
       xla_ae_headers           b,
       xla_transaction_entities d
where 1=1
AND c.CODE_COMBINATION_ID = a.CODE_COMBINATION_ID
AND c.ae_header_id = b.ae_header_id
AND c.application_id = b.application_id
AND b.entity_id = d.entity_id
AND b.application_id = d.application_id
AND d.entity_code = 'AP_PAYMENTS'
AND c.ACCOUNTING_CLASS_CODE = 'ITEM EXPENSE'
group by d.source_id_int_1) min_line
where 1=1
AND proy_gasto.source_id_int_1 = APC.check_id
and proy_gasto.ae_line_num = min_line.ae_line_num
and proy_gasto.source_id_int_1 = min_line.source_id_int_1

AND API.PO_HEADER_ID = POH.PO_HEADER_ID(+)
AND xal.CODE_COMBINATION_ID = GLC.CODE_COMBINATION_ID
AND API.VENDOR_ID = POZ.VENDOR_ID(+)
--AND PSS.VENDOR_ID(+) = POZ.VENDOR_ID
AND API.TERMS_ID = TER.TERM_ID
AND API.invoice_id = AIP.invoice_id
AND AIP.check_id = APC.check_id
AND API.INVOICE_ID = APS.INVOICE_ID
--AND AIP.INVOICE_ID = APS.INVOICE_ID(+)
--AND AHA.INVOICE_ID = API.INVOICE_ID
--AND AHA.INVOICE_ID = APS.INVOICE_ID
--AND API.INVOICE_ID = HOLD.INVOICE_ID
--AND AIP.PAYMENT_NUM = APS.PAYMENT_NUM
AND API.PAYMENT_STATUS_FLAG IN ('P', 'N')
AND API.external_bank_account_id = ie.ext_bank_account_id(+)
AND ie.branch_id = cb.branch_party_id(+)
AND ie.bank_id = cb.bank_party_id(+)

AND xal.ae_header_id = xah.ae_header_id
AND xal.application_id = xah.application_id
AND xah.entity_id = xte.entity_id
AND xah.application_id = xte.application_id
AND xte.source_id_int_1 = APC.check_id
AND xte.entity_code = 'AP_PAYMENTS'
AND xal.ACCOUNTING_CLASS_CODE ='LIABILITY'
--AND hp.PARTY_ID(+) = ie.BANK_ID
--AND apc.VOID_DATE IS NULL
AND API.CANCELLED_DATE IS NULL
--AND APS.PAYMENT_STATUS_FLAG = 'N'
AND IE.BANK_ID = NVL(:P_BANK, IE.BANK_ID)
AND nvl(TO_CHAR(POZ.PARTY_ID),'1') = COALESCE(:P_PROV,TO_CHAR(POZ.PARTY_ID),'1')
AND TRUNC(API.INVOICE_DATE) BETWEEN NVL2(:P_FECHA_INI,:P_FECHA_INI, TRUNC(API.INVOICE_DATE)) 
     AND NVL2(:P_FECHA_FIN,:P_FECHA_FIN, TRUNC(API.INVOICE_DATE))
--and API.INVOICE_NUM  = 'E001-244'--'F001-0001589'  --F001-000046578 , F001-0001589(300000004452993)	 

UNION


SELECT api.DOC_SEQUENCE_VALUE     sec_comprobante,
       POH.SEGMENT1               orden_compra,
       GLC.SEGMENT1               entidad_legal,
       GLC.SEGMENT2               cuenta_contable,
       GLC.SEGMENT3               departamento,
       GLC.SEGMENT4               producto,
       GLC.SEGMENT5               unidad_explotacion,
       GLC.SEGMENT7               futuro_1,
       GLC.SEGMENT8               futuro_2,
       POZ.SEGMENT1               ruc_proveedor,
       poz.VENDOR_NAME            proveedor,
       API.INVOICE_NUM            num_comprobante,
       TO_CHAR(API.INVOICE_DATE, 'dd/mm/yyyy') fecha_emision,
       TO_CHAR(API.GL_DATE, 'dd/mm/yyyy')  fecha_contable,
       TO_CHAR(API.INVOICE_RECEIVED_DATE, 'dd/mm/yyyy')  fecha_recep_factura,
       API.ATTRIBUTE1             num_tipo_doc,
       API.INVOICE_TYPE_LOOKUP_CODE tipo_doc,
       TER.NAME                   condi_pago,
       trunc(SYSDATE - API.INVOICE_RECEIVED_DATE) antiguedad,
       0 pagos,
       TO_CHAR(APS.DUE_DATE, 'dd/mm/yyyy') fecha_vencimiento,
       API.INVOICE_CURRENCY_CODE  moneda,
       nvl(API.INVOICE_AMOUNT,0)  importe_origen,
	APS.AMOUNT_REMAINING importe_base,
       'PEN'                      moneda_base,
	APS.AMOUNT_REMAINING * nvl(API.EXCHANGE_RATE,1)   saldo_x_pagar,
	nvl(API.EXCHANGE_RATE,1) tipo_cambio,
        API.DESCRIPTION            descripcion,
       (select HPBANK.PARTY_NAME
        from
        iby_account_owners IBACO,
        iby_ext_bank_accounts IBEBA,
        hz_parties           HPBANK,
        hz_parties           hp
        where 1=1
        AND HPBANK.PARTY_ID(+) = IBEBA.BANK_ID
        AND IBEBA.EXT_BANK_ACCOUNT_ID(+) = IBACO.EXT_BANK_ACCOUNT_ID
        AND IBACO.ACCOUNT_OWNER_PARTY_ID(+) = hp.party_id
        and hp.party_id = POZ.party_id
        and IBACO.EXT_BANK_ACCOUNT_ID = ie.ext_bank_account_id
        --AND ROWNUM = 1
        ) banco_proveedor,
       --IE.masked_bank_account_num num_cuenta,
       IE.BANK_ACCOUNT_NUM num_cuenta,
       --'' cc_banco,
       APS.PAYMENT_PRIORITY       num_prioridad,
       API.PAY_GROUP_LOOKUP_CODE  desc_prioridad,
       GLC.SEGMENT6               proyecto,
       gl_flexfields_pkg.get_description_sql(glc.chart_of_accounts_id,6,proy_gasto.SEGMENT6) desc_proyecto,
       APS.HOLD_FLAG retenido,
	--'N' retenido,
       APS.IBY_HOLD_REASON desc_retenido,
		API.CANCELLED_DATE,
		api.invoice_id,
        --'AP_INVOICES' xtype
       proy_gasto.SEGMENT6 proyecto_gasto
       
       
FROM
AP_INVOICES_ALL          API,
PO_HEADERS_ALL           POH,
GL_CODE_COMBINATIONS     GLC,
POZ_SUPPLIERS_V          POZ,
AP_TERMS_V               TER,
--AP_INVOICE_PAYMENTS_ALL  AIP,
--AP_CHECKS_ALL            APC,
AP_PAYMENT_SCHEDULES_ALL APS,
--AP_HOLDS_ALL             AHA,
iby_ext_bank_accounts    ie,
ce_bank_branches_v       cb,
xla_ae_lines             xal,
xla_ae_headers           xah,
xla_transaction_entities xte,
(select a.SEGMENT6, d.source_id_int_1, c.ae_line_num
from GL_CODE_COMBINATIONS     a,
       xla_ae_lines             c,
       xla_ae_headers           b,
       xla_transaction_entities d
       
where 1=1
AND c.CODE_COMBINATION_ID = a.CODE_COMBINATION_ID
AND c.ae_header_id = b.ae_header_id
AND c.application_id = b.application_id
AND b.entity_id = d.entity_id
AND b.application_id = d.application_id
AND d.entity_code = 'AP_INVOICES'
AND c.ACCOUNTING_CLASS_CODE ='ITEM EXPENSE') proy_gasto,

(select d.source_id_int_1, min(c.ae_line_num) as ae_line_num
        from GL_CODE_COMBINATIONS     a,
            xla_ae_lines             c,
            xla_ae_headers           b,
            xla_transaction_entities d
        where 1=1
        AND c.CODE_COMBINATION_ID = a.CODE_COMBINATION_ID
        AND c.ae_header_id = b.ae_header_id
        AND c.application_id = b.application_id
        AND b.entity_id = d.entity_id
        AND b.application_id = d.application_id
        AND d.entity_code = 'AP_INVOICES'
        AND c.ACCOUNTING_CLASS_CODE ='ITEM EXPENSE'
        group by d.source_id_int_1) min_line
where 1=1
AND proy_gasto.source_id_int_1 = api.invoice_id

and proy_gasto.ae_line_num = min_line.ae_line_num
and proy_gasto.source_id_int_1 = min_line.source_id_int_1

AND API.PO_HEADER_ID = POH.PO_HEADER_ID(+)
AND xal.CODE_COMBINATION_ID = GLC.CODE_COMBINATION_ID
AND API.VENDOR_ID = POZ.VENDOR_ID(+)
AND API.TERMS_ID = TER.TERM_ID
AND API.INVOICE_ID = APS.INVOICE_ID

AND API.PAYMENT_STATUS_FLAG IN ('P', 'N' , 'Y')
AND API.external_bank_account_id = ie.ext_bank_account_id(+)
AND ie.branch_id = cb.branch_party_id(+)
AND ie.bank_id = cb.bank_party_id(+)

AND xal.ae_header_id = xah.ae_header_id
AND xal.application_id = xah.application_id
AND xah.entity_id = xte.entity_id
AND xah.application_id = xte.application_id
AND xte.source_id_int_1 = api.invoice_id
AND xte.entity_code = 'AP_INVOICES'
AND xal.ACCOUNTING_CLASS_CODE ='LIABILITY'

AND API.CANCELLED_DATE IS NULL
--AND apc.VOID_DATE IS NULL
--AND APS.PAYMENT_STATUS_FLAG = 'N'

--AND IE.BANK_ID = NVL(:P_BANK, IE.BANK_ID)
AND NVL(IE.BANK_ID, '1') = COALESCE( :P_BANK, TO_CHAR(IE.BANK_ID) , '1')

AND nvl(TO_CHAR(POZ.PARTY_ID),'1') = COALESCE(:P_PROV,TO_CHAR(POZ.PARTY_ID),'1')
AND TRUNC(API.INVOICE_DATE) BETWEEN NVL2(:P_FECHA_INI,:P_FECHA_INI, TRUNC(API.INVOICE_DATE)) 
     AND NVL2(:P_FECHA_FIN,:P_FECHA_FIN, TRUNC(API.INVOICE_DATE))
/*AND NOT EXISTS (select 1 
                from AP_INVOICE_PAYMENTS_ALL x
                    ,AP_CHECKS_ALL y
                where 1=1 
                and x.invoice_id = API.invoice_id
                and x.check_id = y.check_id
                and y.STATUS_LOOKUP_CODE = 'NEGOTIABLE')*/
--and API.INVOICE_NUM  = 'E001-244'
--and api.DOC_SEQUENCE_VALUE = '162'
)
--order by num_comprobante
where 1=1
and importe_base <> 0
--and num_comprobante = 'E001-244'