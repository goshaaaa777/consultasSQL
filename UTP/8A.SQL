SELECT
    aca.*
FROM
    ap_invoices_all aia,
    ap_invoice_payments_all aipa,
    ap_checks_all aca,
    POZ_SUPPLIER_SITES_ALL_M pssam,
    IBY_PAYEE_ALL_BANKACCT_V ipaav,
    IBY_EXT_BANK_ACCOUNTS ieba,
    IBY_DOCS_PAYABLE_ALL idpa, --solo es usado para la fecha de vencimiento de pago
    IBY_PAYMENTS_ALL ipa,
    gl_daily_conversion_types gdct,
    FND_LOOKUP_VALUES flv
WHERE
    1 = 1
    and aia.invoice_id = aipa.invoice_id
    and aipa.check_id = aca.check_id
    and aca.status_lookup_code <> 'VOIDED'
    and aia.vendor_site_id = pssam.vendor_site_id
    and aca.EXTERNAL_BANK_ACCOUNT_ID = ipaav.EXT_BANK_ACCOUNT_ID
    and ipaav.EXT_BANK_ACCOUNT_ID = ieba.EXT_BANK_ACCOUNT_ID
    and aca.payment_id = idpa.payment_id
    and idpa.CALLING_APP_DOC_REF_NUMBER = aia.invoice_num
    and idpa.DOCUMENT_TYPE = 'STANDARD'
    and aca.payment_id = ipa.payment_id
    and aca.X_CURR_RATE_TYPE = gdct.CONVERSION_TYPE
    and aca.PAYMENT_TYPE_FLAG = flv.LOOKUP_CODE
    and flv.LANGUAGE = 'US' --Tipo de pago en ingles
    --and flv.LANGUAGE = 'E' --Tipo de pago en español
    and flv.LOOKUP_TYPE = 'PAYMENT TYPE' --Casos
    and aia.invoice_num in ('DSMD-25')


    select * from IBY_FD_PAYMENTS_V



    select
    Nombre_BU,
    Nombre_LM,
    Cuenta_Desembolso,
    Propuesta_Pago,
    Numero_Pago,
    Estado_Pago,
    Tipo_Pago,
    Tipo_TC,
    Estado_Conciliacion,
    Fecha_Factura,
    Fecha_Vencimiento,
    Numero_Factura,
    Descripcion,
    Id_Contribuyente,
    Proveedor,
    Beneficiario_Pago,
    Sitio_Pago,
    Fecha_Pago,
    Valor_Pago,
    Moneda_Pago,
    TrmPago,
    Valor_Factura,
    Moneda_Factura,
    Trm_Factura,
    Banco_Beneficiario,
    Numero_Cuenta_Beneficiario
    
from
    (
        SELECT
            (
               select
                    xep.name
                from
                    xle_entity_profiles xep
                where
                    xep.LEGAL_ENTITY_ID = aia.LEGAL_ENTITY_ID
            ) as Nombre_BU,
            (
                select
                    gl.name
                from
                    gl_ledgers gl
                where
                    gl.LEDGER_ID = aia.SET_OF_BOOKS_ID
            ) as Nombre_LM,
            aca.BANK_ACCOUNT_NAME as Cuenta_Desembolso,
            (
                case
                    when aca.CHECKRUN_NAME like 'Quick payment:%' then 'N/A'
                    else aca.CHECKRUN_NAME
                end
            ) as Propuesta_Pago,
            aca.CHECK_NUMBER as Numero_Pago,
            aca.STATUS_LOOKUP_CODE as Estado_Pago,
            flv.MEANING as Tipo_Pago,
            gdct.USER_CONVERSION_TYPE as Tipo_TC,
            decode(aca.RECON_FLAG, 'Y', 'Yes', 'N', 'No') as Estado_Conciliacion,
            to_char(aia.INVOICE_DATE, 'dd/mm/yyyy') as Fecha_Factura,
            to_char(idpa.PAYMENT_DUE_DATE, 'dd/mm/yyyy') as Fecha_Vencimiento,
            aia.invoice_num as Numero_Factura,
            aia.DESCRIPTION as Descripcion,
            ipa.INV_PAYEE_LE_REG_NUM as Id_Contribuyente,
            aca.vendor_name as Proveedor,
            aca.REMIT_TO_SUPPLIER_NAME as Beneficiario_Pago,
            pssam.VENDOR_SITE_CODE as Sitio_Pago,
            to_char(aca.CHECK_DATE, 'dd/mm/yyyy') as Fecha_Pago,
            TRIM(
                to_char(aca.AMOUNT, '999G999G999G999G999G999G999D99')
            ) as Valor_Pago,
            aca.CURRENCY_CODE as Moneda_Pago,
            (
                case
                    when aipa.INVOICE_CURRENCY_CODE = aipa.PAYMENT_CURRENCY_CODE then (
                        select
                            CONVERSION_RATE
                        from
                            GL_DAILY_RATES
                        where
                            1 = 1
                            and conversion_date = aca.CHECK_DATE
                            and from_currency = 'USD'
                            and to_currency = 'COP'
                            and conversion_type = '300000004035333'
                    )
                    else aipa.X_CURR_RATE
                end
            ) as TrmPago, --RDSR
            TRIM(
                to_char(
                    aia.INVOICE_AMOUNT,
                    '999G999G999G999G999G999G999D99'
                )
            ) as Valor_Factura,
            aia.INVOICE_CURRENCY_CODE as Moneda_Factura,
            (
                select
                    CONVERSION_RATE
                from
                    GL_DAILY_RATES
                where
                    1 = 1
                    and conversion_date = aia.GL_DATE
                    and from_currency = 'USD'
                    and to_currency = 'COP'
                    and conversion_type = '300000004035333'
            ) as Trm_Factura, --RDSR
            ipaav.BANK_NAME as Banco_Beneficiario,
            ieba.MASKED_BANK_ACCOUNT_NUM as Numero_Cuenta_Beneficiario
        FROM
            ap_invoices_all aia,
            ap_invoice_payments_all aipa,
            ap_checks_all aca,
            POZ_SUPPLIER_SITES_ALL_M pssam,
            IBY_PAYEE_ALL_BANKACCT_V ipaav,
            IBY_EXT_BANK_ACCOUNTS ieba,
            IBY_DOCS_PAYABLE_ALL idpa,
            IBY_PAYMENTS_ALL ipa,
            gl_daily_conversion_types gdct,
            FND_LOOKUP_VALUES flv
        WHERE
            1 = 1
            and aia.invoice_id = aipa.invoice_id
            and aipa.check_id = aca.check_id
            and aca.status_lookup_code <> 'VOIDED'
            and aia.vendor_site_id = pssam.vendor_site_id
            and aca.EXTERNAL_BANK_ACCOUNT_ID = ipaav.EXT_BANK_ACCOUNT_ID
            and ipaav.EXT_BANK_ACCOUNT_ID = ieba.EXT_BANK_ACCOUNT_ID
            and aca.payment_id = idpa.payment_id
            and idpa.DOCUMENT_TYPE = 'STANDARD'
            and aca.payment_id = ipa.payment_id
            and aca.X_CURR_RATE_TYPE = gdct.CONVERSION_TYPE
            and aca.PAYMENT_TYPE_FLAG = flv.LOOKUP_CODE
            and flv.LANGUAGE = 'US' --Tipo de pago en ingles
            --and flv.LANGUAGE = 'E' --Tipo de pago en español
            and flv.LOOKUP_TYPE = 'PAYMENT TYPE' 
            --Casos
            /*and (
             aia.invoice_num = 'KSFM 561'
             or aia.invoice_num = '104514'
             or aia.invoice_num = 'UTI 32'
             )*/
    ) A
where 1=1
    and A.Nombre_BU IN (:P_BU)
ORDER BY
    A.Numero_Factura