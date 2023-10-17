 SELECT GCC.SEGMENT1,
               GCC.SEGMENT2    CTA,
               GCC.SEGMENT3    CCENTER,
               (SELECT FFVL.ATTRIBUTE1
                  FROM FND_FLEX_VALUES_VL FFVL
                 WHERE FFVL.VALUE_CATEGORY = 'CNC_CENTRO_COSTO'
                   AND FFVL.FLEX_VALUE = GCC.SEGMENT3) AS CC_CGU,
               (SELECT FFVL.ATTRIBUTE2
                  FROM FND_FLEX_VALUES_VL FFVL
                 WHERE FFVL.VALUE_CATEGORY = 'CNC_CENTRO_COSTO'
                   AND FFVL.FLEX_VALUE = GCC.SEGMENT3) AS CC_DDA,
               GCC.SEGMENT4    AFE,
               (SELECT FFVL.ATTRIBUTE1
                  FROM FND_FLEX_VALUES_VL FFVL
                 WHERE FFVL.VALUE_CATEGORY = 'CNC_AFE'
                   AND FFVL.FLEX_VALUE = GCC.SEGMENT4) AS TIPO_PROY,
               (SELECT FFVL.ATTRIBUTE2
                  FROM FND_FLEX_VALUES_VL FFVL
                 WHERE FFVL.VALUE_CATEGORY = 'CNC_AFE'
                   AND FFVL.FLEX_VALUE = GCC.SEGMENT4) AS AFE_AREA,
               GCC.SEGMENT5    BCODE,
               GCC.SEGMENT6    PM,
               GCC.SEGMENT7    PUC,
               GJL.DESCRIPTION LINEDESC,
               XAL.DESCRIPTION INVLINEDESC,
               DECODE(AIA.SOURCE,
                      'CWK_EXPENSE_REPORT',
                      DECODE((SELECT DISTINCT AILS.ATTRIBUTE1
                                FROM AP_INVOICE_LINES_ALL         AILS,
                                     AP_INVOICE_DISTRIBUTIONS_ALL AIDAS
                               WHERE AILS.INVOICE_ID = AIDAS.INVOICE_ID
                                 AND AILS.LINE_NUMBER = AIDAS.INVOICE_LINE_NUMBER
                                 AND AILS.INVOICE_ID = AIA.INVOICE_ID
                                 AND AILS.ATTRIBUTE1 <> NULL),
                              NULL,
                              (SELECT DISTINCT AILSY.ATTRIBUTE1
                                 FROM AP_INVOICE_LINES_ALL         AILSY,
                                      AP_INVOICE_DISTRIBUTIONS_ALL AIDASY
                                WHERE AILSY.INVOICE_ID = AIDASY.INVOICE_ID
                                  AND AILSY.LINE_NUMBER = AIDASY.INVOICE_LINE_NUMBER
                                  AND AIDASY.INVOICE_DISTRIBUTION_ID =
                                      (SELECT AIDASZ.CHARGE_APPLICABLE_TO_DIST_ID
                                         FROM AP_INVOICE_LINES_ALL         AILSZ,
                                              AP_INVOICE_DISTRIBUTIONS_ALL AIDASZ
                                        WHERE AILSZ.INVOICE_ID = AIDASZ.INVOICE_ID
                                          AND AILSZ.LINE_NUMBER =
                                              AIDASZ.INVOICE_LINE_NUMBER
                                          AND AIDASZ.CHARGE_APPLICABLE_TO_DIST_ID <> NULL
                                          AND AILSZ.INVOICE_ID = AIA.INVOICE_ID)),
                              (SELECT DISTINCT AILS.ATTRIBUTE1
                                 FROM AP_INVOICE_LINES_ALL         AILS,
                                      AP_INVOICE_DISTRIBUTIONS_ALL AIDAS
                                WHERE AILS.INVOICE_ID = AIDAS.INVOICE_ID
                                  AND AILS.LINE_NUMBER = AIDAS.INVOICE_LINE_NUMBER
                                  AND AILS.INVOICE_ID = AIA.INVOICE_ID
                                  AND AILS.ATTRIBUTE1 <> NULL)),
                       (SELECT AOS.VENDOR_VAT_REGISTRATION_NUM
                          FROM AP_OFR_SUPPLIERS_V AOS
                         WHERE AOS.VENDOR_ID = AIA.VENDOR_ID
                           AND ROWNUM = 1)) AS VENDORID,
                AIA.INVOICE_NUM AS INVOICENO,
                AIA.INVOICE_DATE AS DATEENTERED,
                NVL(XAL.ACCOUNTED_CR, 0) AS LINECREDIT,
                NVL(XAL.ACCOUNTED_DR, 0) AS LINEDEBIT,
                NVL(XAL.ACCOUNTED_DR, 0) - NVL(XAL.ACCOUNTED_CR, 0) AS NETO,
                GLLV.CURRENCY_CODE AS MONEDA,
                GJH.JE_HEADER_ID JOURNALID,
                TO_CHAR(GJH.DEFAULT_EFFECTIVE_DATE, 'YYYYMM') PERIODO,
                DECODE(AIA.SOURCE,
                       'CWK_EXPENSE_REPORT',
                       DECODE((SELECT DISTINCT AILS.ATTRIBUTE2
                                 FROM AP_INVOICE_LINES_ALL         AILS,
                                      AP_INVOICE_DISTRIBUTIONS_ALL AIDAS
                                WHERE AILS.INVOICE_ID = AIDAS.INVOICE_ID
                                  AND AILS.LINE_NUMBER = AIDAS.INVOICE_LINE_NUMBER
                                  AND AILS.INVOICE_ID = AIA.INVOICE_ID
                                  AND AILS.ATTRIBUTE2 <> NULL),
                               NULL,
                              (SELECT DISTINCT AILSY.ATTRIBUTE2
                                 FROM AP_INVOICE_LINES_ALL         AILSY,
                                      AP_INVOICE_DISTRIBUTIONS_ALL AIDASY
                                WHERE AILSY.INVOICE_ID = AIDASY.INVOICE_ID
                                  AND AILSY.LINE_NUMBER = AIDASY.INVOICE_LINE_NUMBER
                                  AND AILSY.INVOICE_ID = AIA.INVOICE_ID
                                  AND AILSY.ATTRIBUTE2 <> NULL
                                  AND AIDASY.INVOICE_DISTRIBUTION_ID =
                                      (SELECT AIDASZ.CHARGE_APPLICABLE_TO_DIST_ID
                                         FROM AP_INVOICE_LINES_ALL         AILSZ,
                                              AP_INVOICE_DISTRIBUTIONS_ALL AIDASZ
                                        WHERE AILSZ.INVOICE_ID = AIDASZ.INVOICE_ID
                                          AND AILSZ.LINE_NUMBER = AIDASZ.INVOICE_LINE_NUMBER
                                          AND AIDASZ.CHARGE_APPLICABLE_TO_DIST_ID <> NULL
                                          AND AILSZ.INVOICE_ID = AIA.INVOICE_ID)),
                             (SELECT DISTINCT AILS.ATTRIBUTE2
                                FROM AP_INVOICE_LINES_ALL         AILS,
                                     AP_INVOICE_DISTRIBUTIONS_ALL AIDAS
                               WHERE AILS.INVOICE_ID = AIDAS.INVOICE_ID
                                 AND AILS.LINE_NUMBER = AIDAS.INVOICE_LINE_NUMBER
                                 AND AILS.INVOICE_ID = AIA.INVOICE_ID
                                 AND AILS.ATTRIBUTE2 <> NULL)),
                      (SELECT PS.VENDOR_NAME
                         FROM POZ_SUPPLIERS_V PS
                        WHERE PS.VENDOR_ID = AIA.VENDOR_ID)) AS PROVEEDOR,
               GJH.POSTED_DATE POSTDATE,
                       NVL(( SELECT LISTAGG( DISTINCT paf.address_line_1 , ' / ')
            FROM per_location_details_f  pldf
      ,per_addresses_f paf
      ,AP_INVOICE_LINES_ALL AIL
      WHERE pldf.main_address_id = paf.address_id
      AND pldf.location_id = AIL.FINAL_DISCHARGE_LOCATION_ID
      AND AIA.INVOICE_ID = AIL.INVOICE_ID) , (SELECT LISTAGG(DISTINCT UPPER(HZ.CITY) , ' / ') FROM HZ_LOCATIONS HZ, AP_INVOICE_LINES_ALL AIL
                                    WHERE HZ.LOCATION_ID = AIL.FINAL_DISCHARGE_LOCATION_ID
                                    AND AIA.INVOICE_ID = AIL.INVOICE_ID)) AS MUNICIPIO,
               (SELECT SUM(AIL.QUANTITY_INVOICED)
                  FROM AP_INVOICE_LINES_ALL AIL
                 WHERE AIL.INVOICE_ID = AIA.INVOICE_ID
                   AND AIL.LINE_TYPE_LOOKUP_CODE = 'ITEM') AS CANTIDAD,
               GCC.SEGMENT1 || '-' || GCC.SEGMENT2 || '-' || GCC.SEGMENT3 || '-' ||
               GCC.SEGMENT4 || '-' || GCC.SEGMENT5 || '-' || GCC.SEGMENT6 || '-' ||
               GCC.SEGMENT7 AS FQA,
               GJB.JE_BATCH_ID BATCHNO,
               GJH.LEDGER_ID AS LEDGER_ID,
               GJH.JE_HEADER_ID,
               GJL.JE_LINE_NUM,
               XAH.AE_HEADER_ID || '-' || XAL.AE_LINE_NUM GL_HL,
               JCV.USER_JE_CATEGORY_NAME CAT_ASIENTO,
               GJH.JE_CATEGORY,
               GJB.NAME LOTE,
               GLLV.LEDGER_NAME,
               AIA.LAST_UPDATED_BY CREATED_BY,
         GJH.LAST_UPDATED_BY 
          FROM GL_JE_HEADERS            GJH,
               GL_JE_LINES              GJL,
               GL_CODE_COMBINATIONS     GCC,
               GL_JE_BATCHES            GJB,
               GL_JE_CATEGORIES_VL      JCV,
               GL_JE_SOURCES_VL          JSV, --n
               GL_LEDGER_LE_V           GLLV,
               GL_IMPORT_REFERENCES     GIR,
               XLA_AE_LINES             XAL,
               XLA_AE_HEADERS           XAH,
               XLA_TRANSACTION_ENTITIES XTE,
               AP_INVOICES_ALL          AIA,
               RA_CUSTOMER_TRX_ALL       CTA, --
               HZ_CUST_ACCOUNTS          HCA,
               HZ_PARTIES                HP,
			   HZ_ORGANIZATION_PROFILES  HOP,
               HZ_PERSON_PROFILES        HPP,
               xle_le_ou_ledger_v        xle,
               hr_all_organization_units hr

               
         WHERE 1 = 1
           AND GJH.JE_HEADER_ID = GJL.JE_HEADER_ID
           AND GJL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
           AND GJH.JE_BATCH_ID = GJB.JE_BATCH_ID
           AND GJH.JE_CATEGORY = JCV.JE_CATEGORY_NAME(+)
           AND GJH.LEDGER_ID = GLLV.LEDGER_ID
           AND GJL.JE_HEADER_ID = GIR.JE_HEADER_ID
           AND GJL.JE_LINE_NUM = GIR.JE_LINE_NUM
           AND GIR.GL_SL_LINK_TABLE = XAL.GL_SL_LINK_TABLE
           AND GIR.GL_SL_LINK_ID = XAL.GL_SL_LINK_ID
           AND XAL.AE_HEADER_ID = XAH.AE_HEADER_ID
           AND XAL.APPLICATION_ID = XAH.APPLICATION_ID
           AND XAH.APPLICATION_ID = XTE.APPLICATION_ID
           AND XAH.ENTITY_ID = XTE.ENTITY_ID
           
           AND NVL(XTE.SOURCE_ID_INT_1, GJH.JE_HEADER_ID) = CTA.CUSTOMER_TRX_ID
           AND CTA.BILL_TO_CUSTOMER_ID = HCA.CUST_ACCOUNT_ID                   --
           AND HCA.PARTY_ID = HP.PARTY_ID
		   AND HOP.PARTY_ID(+) = HP.PARTY_ID
           AND HPP.PARTY_ID(+) = HP.PARTY_ID
           AND GJH.ledger_id = XLE.ledger_id
           AND HR.organization_id = XLE.operating_unit_id
           AND HR.organization_id = XLE.operating_unit_id

           AND NVL(XTE.SOURCE_ID_INT_1, -99) = AIA.INVOICE_ID
           AND GJH.JE_SOURCE = 'Payables'
           AND GJH.ACTUAL_FLAG = 'A'
           AND GJH.STATUS = 'P'
           AND XTE.ENTITY_CODE = 'AP_INVOICES'
           AND XAH.GL_TRANSFER_STATUS_CODE = 'Y'
           AND GJH.DEFAULT_EFFECTIVE_DATE >= :P_FECHA_INI
           AND GJH.DEFAULT_EFFECTIVE_DATE < :P_FECHA_FIN + 1

---------------------------------------------------------------------------------------------------------
        
         SELECT JH.PERIOD_NAME PERIODO,
               CC.CODE_COMBINATION_ID CCID,
               (CC.SEGMENT1 || '.' || CC.SEGMENT2 || '.' || CC.SEGMENT3 || '.' ||
               CC.SEGMENT4 || '.' || CC.SEGMENT5 ||
               decode(CC.SEGMENT6, null, '', '.' || CC.SEGMENT6) ||
               decode(CC.SEGMENT7, null, '', '.' || CC.SEGMENT7)) COMBINACION,
			   LPAD(AL.displayed_line_number, 9, '0') CORRELATIVO,
               JSV.USER_JE_SOURCE_NAME ORIGEN,
               JCV.USER_JE_CATEGORY_NAME TIPO_OPERACION,
               NVL(TE.SOURCE_ID_INT_1, JH.JE_HEADER_ID) ID_DOCUMENTO,
               NVL(TE.TRANSACTION_NUMBER, JH.PERIOD_NAME || ' | ' || JH.NAME) NUM_DOCUMENTO,
               HP.PARTY_NAME CLIEN_PROV,
			   NVL(hop.attribute5, hpp.attribute5) TIPO_DOC_IDENT, 
               NVL(hop.attribute4, hpp.attribute4) RUC_DNI,
               NVL(AL.CURRENCY_CODE, JH.CURRENCY_CODE) DIVISA,
               --JH.DOC_SEQUENCE_VALUE NUMERO_ASIENTO,
               JH.POSTING_ACCT_SEQ_VALUE NUMERO_ASIENTO,
               CC.SEGMENT1 COMPANIA,
               CC.SEGMENT2 CUENTA,
               CC.SEGMENT3 CENTRO_COSTO,
               CC.SEGMENT4 PROYECTO,
               CC.SEGMENT5 CLASIFICADOR,
               CC.SEGMENT6 META,
               CC.SEGMENT7 FUTURO,
               JH.DEFAULT_EFFECTIVE_DATE FECHA_CONTABLE,
               TO_CHAR(CTA.TRX_DATE,'DD/MM/YYYY') FECHA_DOC,
               JH.NAME NOMBRE_ASIENTO,
               JL.DESCRIPTION DESCRIPCION_LINEA,
               CTA.DOC_SEQUENCE_VALUE NUMERO_VOUCHER,
               NVL(CTA.INTERFACE_HEADER_ATTRIBUTE1, JL.DESCRIPTION) DESCRIPCION,
               --NEGATIVO EN EL HABER Y POSITIVO DEBE
               DECODE(AL.GL_SL_LINK_ID,
                      NULL,
                      NVL(JL.ENTERED_DR, 0),
                      NVL(AL.ENTERED_DR, 0)) MONTO_DEBITO,
               DECODE(AL.GL_SL_LINK_ID,
                      NULL,
                      NVL(JL.ENTERED_CR, 0),
                      NVL(AL.ENTERED_CR, 0)) MONTO_CREDITO,
               --NEGATIVO EN EL HABER Y POSITIVO DEBE
               DECODE(AL.GL_SL_LINK_ID,
                      NULL,
                      NVL(JL.ACCOUNTED_DR, 0),
                      NVL(AL.ACCOUNTED_DR, 0)) MONTO_FUNCIONAL_DEBITO,
               DECODE(AL.GL_SL_LINK_ID,
                      NULL,
                      NVL(JL.ACCOUNTED_CR, 0),
                      NVL(AL.ACCOUNTED_CR, 0)) MONTO_FUNCIONAL_CREDITO,
               CTA.EXCHANGE_RATE TIPO_CAMBIO,
			   JL.STATUS ESTADO

          FROM GL_JE_HEADERS             JH, --
               GL_JE_CATEGORIES_VL       JCV, --
               GL_JE_SOURCES_VL          JSV, --
               GL_JE_LINES               JL, --
               GL_IMPORT_REFERENCES      IR, --
               XLA_AE_LINES              AL, --
               XLA_AE_HEADERS            AH, --
               XLA_TRANSACTION_ENTITIES  TE, --
               GL_CODE_COMBINATIONS      CC, --
               RA_CUSTOMER_TRX_ALL       CTA,
               HZ_CUST_ACCOUNTS          HCA,
               HZ_PARTIES                HP,
			   HZ_ORGANIZATION_PROFILES  HOP,
               HZ_PERSON_PROFILES        HPP,
               xle_le_ou_ledger_v        xle,
               hr_all_organization_units hr
               
         WHERE 1 = 1
           AND JH.ACTUAL_FLAG = 'A'
           AND JH.STATUS = 'P'
           AND JH.JE_HEADER_ID = JL.JE_HEADER_ID
           and jh.ledger_id = xle.ledger_id
           and hr.organization_id = xle.operating_unit_id
           and NVL(AL.CURRENCY_CODE, JH.CURRENCY_CODE) =
               NVL(:MONEDA, NVL(AL.CURRENCY_CODE, JH.CURRENCY_CODE))
           and hr.name = :ORGNAME
           AND JL.CODE_COMBINATION_ID = CC.CODE_COMBINATION_ID
           AND NVL(AH.JE_CATEGORY_NAME, JH.JE_CATEGORY) =
               JCV.JE_CATEGORY_NAME
           AND JH.JE_SOURCE = JSV.JE_SOURCE_NAME
           AND JL.JE_HEADER_ID = IR.JE_HEADER_ID(+)
           AND JL.JE_LINE_NUM = IR.JE_LINE_NUM(+)
           AND IR.GL_SL_LINK_ID = AL.GL_SL_LINK_ID(+)
           AND IR.GL_SL_LINK_TABLE = AL.GL_SL_LINK_TABLE(+)
           AND AL.AE_HEADER_ID = AH.AE_HEADER_ID(+)
           AND AH.ENTITY_ID = TE.ENTITY_ID(+)
           AND NVL(TE.SOURCE_ID_INT_1, JH.JE_HEADER_ID) = CTA.CUSTOMER_TRX_ID  --
           AND CTA.BILL_TO_CUSTOMER_ID = HCA.CUST_ACCOUNT_ID                   --
           AND HCA.PARTY_ID = HP.PARTY_ID
		   AND HOP.PARTY_ID(+) = HP.PARTY_ID
           AND HPP.PARTY_ID(+) = HP.PARTY_ID
           AND JH.JE_SOURCE = 'Receivables'
           AND JCV.JE_CATEGORY_NAME IN
               ('Sales Invoices', 'Credit Memos', 'Debit Memos')
           AND (DECODE(AL.GL_SL_LINK_ID,
                       NULL,
                       NVL(JL.ACCOUNTED_DR, 0),
                       NVL(AL.ACCOUNTED_DR, 0)) -
               DECODE(AL.GL_SL_LINK_ID,
                       NULL,
                       NVL(JL.ACCOUNTED_CR, 0),
                       NVL(AL.ACCOUNTED_CR, 0))) != 0
              --FILTROS
           AND CC.SEGMENT1 IN NVL(:SEGMENTO1, CC.SEGMENT1)
           AND CC.SEGMENT2 >= NVL(:SEGMENTO2_DESDE, '0')
           AND CC.SEGMENT2 <= NVL(:SEGMENTO2_HASTA, '9999999999')
           AND CC.SEGMENT3 IN NVL(:SEGMENTO3, CC.SEGMENT3)
           AND CC.SEGMENT4 IN NVL(:SEGMENTO4, CC.SEGMENT4)
           AND CC.SEGMENT5 IN NVL(:SEGMENTO5, CC.SEGMENT5)
              /*AND CC.SEGMENT6 IN NVL(:SEGMENTO6, CC.SEGMENT6)
              AND CC.SEGMENT7 IN NVL(:SEGMENTO7, CC.SEGMENT7)*/
           AND (SELECT GP1.START_DATE
                  FROM GL_PERIODS GP1
                 WHERE GP1.PERIOD_SET_NAME = 'EVOL - Calendar'
                   AND GP1.PERIOD_NAME = JH.PERIOD_NAME) BETWEEN
               (SELECT GP2.START_DATE
                  FROM GL_PERIODS GP2
                 WHERE GP2.PERIOD_SET_NAME = 'EVOL - Calendar'
                   AND GP2.PERIOD_NAME = :PERIODO_DESDE)
           AND (SELECT GP3.END_DATE
                  FROM GL_PERIODS GP3
                 WHERE GP3.PERIOD_SET_NAME = 'EVOL - Calendar'
                   AND GP3.PERIOD_NAME = :PERIODO_HASTA)