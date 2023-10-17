SELECT SEGMENT1,
       LEDGER_NAME,
       CTA,
       CCENTER,
	   CURRENCY_ORG,
       CC_CGU,
       CC_DDA,
       AFE,
       TIPO_PROY,
       AFE_AREA,
       BCODE,
       PM,
       PUC,
       LINEDESC,
       INVLINEDESC,
       VENDORID,
       INVOICENO,
       TO_CHAR(DATEENTERED, 'DD/MM/YYYY') DATEENTERED,
       LINEDEBIT,
       LINECREDIT,
       NETO,
       MONEDA,
       JOURNALID,
       PERIODO,
       PROVEEDOR,
       TO_CHAR(POSTDATE, 'DD/MM/YYYY HH24:MM:SS') POSTDATE,
       MUNICIPIO,
       CANTIDAD,
       FQA,
       BATCHNO,
       JE_HEADER_ID,
       JE_LINE_NUM,
       CAT_ASIENTO,
       GL_HL,
       LOTE,
       CREATED_BY,
	   ORIGEN

  FROM (
        --AP INVOICE
        SELECT GCC.SEGMENT1,
                GCC.SEGMENT2    CTA,
                GCC.SEGMENT3    CCENTER,
                GJL.CURRENCY_CODE   CURRENCY_ORG,
                
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
                       (SELECT PS.SEGMENT1 --|| '-' || PS.ATTRIBUTE5
                          FROM POZ_SUPPLIERS_V PS
                         WHERE PS.VENDOR_ID = AIA.VENDOR_ID)) AS VENDORID,
                AIA.INVOICE_NUM AS INVOICENO,
                AIA.INVOICE_DATE AS DATEENTERED,
                --NVL(GJL.ENTERED_CR, 0) AS LINECREDIT,
                --NVL(GJL.ENTERED_DR, 0) AS LINEDEBIT,
                --NVL(GJL.ENTERED_DR, 0) - NVL(GJL.ENTERED_CR, 0) AS NETO,
                --XAL.CURRENCY_CODE AS MONEDA,
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
                                          AND AILSZ.LINE_NUMBER =
                                              AIDASZ.INVOICE_LINE_NUMBER
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
                (SELECT ATTRIBUTE15
                   FROM AP_INVOICE_LINES_ALL AIL
                  WHERE AIL.INVOICE_ID = AIA.INVOICE_ID
                    AND AIL.LINE_TYPE_LOOKUP_CODE = 'ITEM'
                    AND ROWNUM = 1) AS MUNICIPIO,
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
				GJH.JE_SOURCE ORIGEN
                
         FROM  GL_JE_HEADERS            GJH, ----
               GL_JE_LINES              GJL, --
               GL_IMPORT_REFERENCES     GIR,----
               GL_JE_BATCHES            GJB, -----
               GL_JE_CATEGORIES_VL      JCV, ---
               GL_LEDGER_LE_V           GLLV,
               GL_CODE_COMBINATIONS     GCC, --
               GL_JE_SOURCES_VL          JSV, --
               POZ_SUPPLIERS_V           PSV,
               XLA_AE_LINES             XAL,
               XLA_AE_HEADERS           XAH, --
               XLA_TRANSACTION_ENTITIES XTE,
               XLA_DISTRIBUTION_LINKS    XDL ----
               AP_INVOICES_ALL          AIA,
               AP_CHECKS_ALL             ACV,
			   AP_PAYMENT_HISTORY_ALL    APHA,
			   AP_PAYMENT_HIST_DISTS     APHD,
               AP_INVOICE_PAYMENTS_ALL   AIP,
               xle_le_ou_ledger_v        xle, --
               hr_all_organization_units hr --

         WHERE 1 = 1
                ---GL
           AND GJH.JE_SOURCE = 'Payables'
           AND XTE.ENTITY_CODE = 'AP_INVOICES'
           AND GJH.ACTUAL_FLAG = 'A'
           AND GJH.STATUS = 'P'
           AND GJH.JE_HEADER_ID = GJL.JE_HEADER_ID
           and GJH.ledger_id = xle.ledger_id --
        -  AND GJH.LEDGER_ID = GLLV.LEDGER_ID
           and hr.organization_id = xle.operating_unit_id --
           --and hr.name = :ORGNAME
           AND GJL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
           AND NVL(XAH.JE_CATEGORY_NAME, GJH.JE_CATEGORY) = JCV.JE_CATEGORY_NAME --
         --AND GJH.JE_CATEGORY = JCV.JE_CATEGORY_NAME(+)
           AND GJH.JE_SOURCE = JSV.JE_SOURCE_NAME
           AND GJL.JE_HEADER_ID = GIR.JE_HEADER_ID(+)
           AND GJL.JE_LINE_NUM = GIR.JE_LINE_NUM(+)
           AND GJH.JE_BATCH_ID = GJB.JE_BATCH_ID
                ----XLA
        AND GIR.GL_SL_LINK_ID = XAL.GL_SL_LINK_ID(+)
           AND GIR.GL_SL_LINK_TABLE = XAL.GL_SL_LINK_TABLE(+)
		   AND XAL.AE_HEADER_ID = XDL.AE_HEADER_ID
		   AND XAL.AE_LINE_NUM = XDL.AE_LINE_NUM	
		   and xdl.source_distribution_type = 'AP_PMT_DIST'
           AND XAL.AE_HEADER_ID = XAH.AE_HEADER_ID(+)
		   AND XAL.APPLICATION_ID = XAH.APPLICATION_ID
		   AND XAH.EVENT_ID = XDL.EVENT_ID
           AND XAH.ENTITY_ID = XTE.ENTITY_ID(+)
		   AND XTE.application_id = 200 
		   AND APHD.PAYMENT_HIST_DIST_ID = XDL.SOURCE_DISTRIBUTION_ID_NUM_1 
		   AND APHD.PAYMENT_HISTORY_ID = APHA.PAYMENT_HISTORY_ID 
		   AND XTE.SOURCE_ID_INT_1 = ACV.CHECK_ID
		   AND ACV.VENDOR_NAME = PSV.VENDOR_NAME(+)
		   AND ACV.CHECK_ID = APHA.CHECK_ID
		   AND ((XDL.APPLIED_TO_SOURCE_ID_NUM_1 = AIA.INVOICE_ID) OR (XDL.APPLIED_TO_SOURCE_ID_NUM_1  ACV.CHECK_ID))
		   AND APHD.INVOICE_PAYMENT_ID = AIP.INVOICE_PAYMENT_ID
           AND AIP.INVOICE_ID = AIA.INVOICE_ID

           /*AND XAH.GL_TRANSFER_STATUS_CODE = 'Y' -----
           AND XAL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
           AND XAH.APPLICATION_ID = XTE.APPLICATION_ID
           AND NVL(XTE.SOURCE_ID_INT_1, -99) = AIA.INVOICE_ID(+)
           AND GJH.DEFAULT_EFFECTIVE_DATE >= :P_FECHA_INI
           AND GJH.DEFAULT_EFFECTIVE_DATE < :P_FECHA_FIN + 1 */
        UNION ALL
        --AP PAYMENTS
        SELECT GCC.SEGMENT1,
                GCC.SEGMENT2    CTA,
                GCC.SEGMENT3    CCENTER,
                GJL.CURRENCY_CODE   CURRENCY_ORG,

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


                (SELECT PS.SEGMENT1 --|| '-' || PS.ATTRIBUTE5
                   FROM POZ_SUPPLIERS_V PS
                  WHERE PS.VENDOR_ID = ACA.VENDOR_ID) AS VENDORID,
                TO_CHAR(ACA.CHECK_NUMBER) AS INVOICENO,
                ACA.CHECK_DATE AS DATEENTERED,
                --NVL(GJL.ENTERED_CR, 0) AS LINECREDIT,
                --NVL(GJL.ENTERED_DR, 0) AS LINEDEBIT,
                --NVL(GJL.ENTERED_DR, 0) - NVL(GJL.ENTERED_CR, 0) AS NETO,
                --XAL.CURRENCY_CODE AS MONEDA,
                NVL(XAL.ACCOUNTED_CR, 0) AS     ,
                NVL(XAL.ACCOUNTED_DR, 0) AS LINEDEBIT,
                NVL(XAL.ACCOUNTED_DR, 0) - NVL(XAL.ACCOUNTED_CR, 0) AS NETO,
                GLLV.CURRENCY_CODE AS MONEDA,
                GJH.JE_HEADER_ID JOURNALID,
                TO_CHAR(GJH.DEFAULT_EFFECTIVE_DATE, 'YYYYMM') PERIODO,
                (SELECT PS.VENDOR_NAME
                   FROM POZ_SUPPLIERS_V PS
                  WHERE PS.VENDOR_ID = ACA.VENDOR_ID) AS PROVEEDOR,
                GJH.POSTED_DATE POSTDATE,
                (SELECT SUBSTR(HG.GEOGRAPHY_CODE,3)
                   FROM HZ_GEOGRAPHIES HG
                  WHERE UPPER(HG.GEOGRAPHY_NAME) = UPPER(ACA.CITY)
                    AND UPPER(HG.GEOGRAPHY_ELEMENT2) = UPPER(ACA.STATE)
                    AND HG.GEOGRAPHY_TYPE = 'MUNICIPIO'
                    AND HG.COUNTRY_CODE = ACA.COUNTRY) AS MUNICIPIO,
                NULL AS CANTIDAD,
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
                ACA.LAST_UPDATED_BY CREATED_BY,
				GJH.JE_SOURCE ORIGEN
          FROM GL_JE_HEADERS            GJH,
                GL_JE_LINES              GJL,
                GL_IMPORT_REFERENCES     GIR,
                GL_JE_BATCHES            GJB, -----
                GL_JE_CATEGORIES_VL      JCV,
                GL_LEDGER_LE_V           GLLV,
                XLA_AE_LINES             XAL,
                XLA_AE_HEADERS           XAH,
                GL_CODE_COMBINATIONS     GCC,
                XLA_TRANSACTION_ENTITIES XTE,
                AP_CHECKS_ALL            ACA
         WHERE 1 = 1
           AND GJH.JE_SOURCE = 'Payables'
           AND XTE.ENTITY_CODE = 'AP_PAYMENTS'
           AND GJH.ACTUAL_FLAG = 'A'
           AND GJH.STATUS = 'P'
           AND XAH.GL_TRANSFER_STATUS_CODE = 'Y'
           AND GJH.JE_HEADER_ID = GJL.JE_HEADER_ID
           AND GJL.JE_HEADER_ID = GIR.JE_HEADER_ID
           AND GJL.JE_LINE_NUM = GIR.JE_LINE_NUM
           AND GJH.JE_BATCH_ID = GJB.JE_BATCH_ID -----
           AND GJH.JE_CATEGORY = JCV.JE_CATEGORY_NAME(+)
           AND GJH.LEDGER_ID = GLLV.LEDGER_ID
           AND GIR.GL_SL_LINK_ID = XAL.GL_SL_LINK_ID
           AND GIR.GL_SL_LINK_TABLE = XAL.GL_SL_LINK_TABLE
           AND XAL.APPLICATION_ID = XAH.APPLICATION_ID
           AND XAL.AE_HEADER_ID = XAH.AE_HEADER_ID
           AND XAL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
           AND XAH.APPLICATION_ID = XTE.APPLICATION_ID
           AND XAH.ENTITY_ID = XTE.ENTITY_ID
           AND NVL(XTE.SOURCE_ID_INT_1, -99) = ACA.CHECK_ID(+)
           AND GJH.DEFAULT_EFFECTIVE_DATE >= :P_FECHA_INI
           AND GJH.DEFAULT_EFFECTIVE_DATE < :P_FECHA_FIN + 1
        
        UNION ALL
        --AR
        SELECT GCC.SEGMENT1,
               GCC.SEGMENT2    CTA,
               GCC.SEGMENT3    CCENTER,
               GJL.CURRENCY_CODE   CURRENCY_ORG,

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
               HP.PARTY_NUMBER AS VENDORID,
               TRX.TRX_NUMBER AS INVOICENO,
               TRX.TRX_DATE AS DATEENTERED,
               --NVL(GJL.ENTERED_CR, 0) AS LINECREDIT,
               --NVL(GJL.ENTERED_DR, 0) AS LINEDEBIT,
               --NVL(GJL.ENTERED_DR, 0) - NVL(GJL.ENTERED_CR, 0) AS NETO,
               --XAL.CURRENCY_CODE AS MONEDA,
               NVL(XAL.ACCOUNTED_CR, 0) AS LINECREDIT,
               NVL(XAL.ACCOUNTED_DR, 0) AS LINEDEBIT,
               NVL(XAL.ACCOUNTED_DR, 0) - NVL(XAL.ACCOUNTED_CR, 0) AS NETO,
               GLLV.CURRENCY_CODE AS MONEDA,
               GJH.JE_HEADER_ID JOURNALID,
               TO_CHAR(GJH.DEFAULT_EFFECTIVE_DATE, 'YYYYMM') PERIODO,
               HP.PARTY_NAME AS PROVEEDOR,
               GJH.POSTED_DATE POSTDATE,
               (SELECT ATTRIBUTE1
                  FROM RA_CUSTOMER_TRX_LINES_ALL TRXLIN
                 WHERE TRXLIN.CUSTOMER_TRX_ID = TRX.CUSTOMER_TRX_ID
                   AND LINE_TYPE = 'LINE'
                   AND ROWNUM = 1) AS MUNICIPIO,
               (SELECT SUM(TRXLIN.QUANTITY_INVOICED)
                  FROM RA_CUSTOMER_TRX_LINES_ALL TRXLIN
                 WHERE TRXLIN.CUSTOMER_TRX_ID = TRX.CUSTOMER_TRX_ID
                   AND TRXLIN.LINE_TYPE = 'LINE'
                   --AND XAL.ACCOUNTING_CLASS_CODE = 'RECEIVABLE'
                   ) AS CANTIDAD,
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
               TRX.LAST_UPDATED_BY CREATED_BY,
			   GJH.JE_SOURCE ORIGEN
          FROM GL_JE_HEADERS            GJH,
               GL_JE_LINES              GJL,
               GL_IMPORT_REFERENCES     GIR,
               GL_JE_BATCHES            GJB, -----
               GL_JE_CATEGORIES_VL      JCV,
               GL_LEDGER_LE_V           GLLV,
               XLA_AE_LINES             XAL,
               XLA_AE_HEADERS           XAH,
               GL_CODE_COMBINATIONS     GCC,
               XLA_TRANSACTION_ENTITIES XTE,
               RA_CUSTOMER_TRX_ALL      TRX,
               HZ_PARTIES               HP



         WHERE 1 = 1
           AND GJH.JE_SOURCE = 'Receivables'
           AND GJH.ACTUAL_FLAG = 'A'
           AND GJH.STATUS = 'P'
           AND XAH.GL_TRANSFER_STATUS_CODE = 'Y'
           AND GJH.JE_HEADER_ID = GJL.JE_HEADER_ID
           AND GJL.JE_HEADER_ID = GIR.JE_HEADER_ID
           AND GJL.JE_LINE_NUM = GIR.JE_LINE_NUM
           AND GJH.JE_BATCH_ID = GJB.JE_BATCH_ID -----
           AND GJH.JE_CATEGORY = JCV.JE_CATEGORY_NAME(+)
           AND GJH.LEDGER_ID = GLLV.LEDGER_ID
           AND GIR.GL_SL_LINK_ID = XAL.GL_SL_LINK_ID
           AND GIR.GL_SL_LINK_TABLE = XAL.GL_SL_LINK_TABLE
           AND XAL.APPLICATION_ID = XAH.APPLICATION_ID
           AND XAL.AE_HEADER_ID = XAH.AE_HEADER_ID
           AND XAL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
           AND XAH.APPLICATION_ID = XTE.APPLICATION_ID
           AND XAH.ENTITY_ID = XTE.ENTITY_ID
           AND TRX.TRX_NUMBER = XTE.TRANSACTION_NUMBER
           AND TRX.SOLD_TO_PARTY_ID = HP.PARTY_ID(+)
           AND GJH.DEFAULT_EFFECTIVE_DATE >= :P_FECHA_INI
           AND GJH.DEFAULT_EFFECTIVE_DATE < :P_FECHA_FIN + 1
        
        UNION ALL
        --GL
        SELECT GCC.SEGMENT1,
               GCC.SEGMENT2 CTA,
               GCC.SEGMENT3 CCENTER,
               GJL.CURRENCY_CODE   CURRENCY_ORG,
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
               GCC.SEGMENT5 BCODE,
               GCC.SEGMENT6 PM,
               GCC.SEGMENT7 PUC,
               GJL.DESCRIPTION LINEDESC,
               NULL AS INVLINEDESC,
               DECODE(JCV.USER_JE_CATEGORY_NAME,
                      'CNC-JV JOINT VENTURE', 
                      (SELECT PS.SEGMENT1 FROM POZ_SUPPLIERS_V PS
                        WHERE PARTY_ID = GJL.ATTRIBUTE2
                         AND ROWNUM = 1),
                      NULL) AS VENDORID,
               DECODE(JCV.USER_JE_CATEGORY_NAME, 'CNC-JV JOINT VENTURE', GJL.ATTRIBUTE1, NULL) AS INVOICENO,
               GJH.DEFAULT_EFFECTIVE_DATE AS DATEENTERED,
               --NVL(GJL.ENTERED_CR, 0) AS LINECREDIT,
               --NVL(GJL.ENTERED_DR, 0) AS LINEDEBIT,
               --NVL(GJL.ENTERED_DR, 0) - NVL(GJL.ENTERED_CR, 0) AS NETO,
               --XAL.CURRENCY_CODE AS MONEDA,
               NVL(GJL.ACCOUNTED_CR, 0) AS LINECREDIT,
               NVL(GJL.ACCOUNTED_DR, 0) AS LINEDEBIT,
               NVL(GJL.ACCOUNTED_DR, 0) - NVL(GJL.ACCOUNTED_CR, 0) AS NETO,
               GLLV.CURRENCY_CODE AS MONEDA,
               GJH.JE_HEADER_ID JOURNALID,
               TO_CHAR(GJH.DEFAULT_EFFECTIVE_DATE, 'YYYYMM') PERIODO,
               DECODE(JCV.USER_JE_CATEGORY_NAME, 'CNC-JV JOINT VENTURE', GJL.ATTRIBUTE4, NULL) AS PROVEEDOR,
               GJH.POSTED_DATE POSTDATE,
               NULL AS MUNICIPIO,
               NULL AS CANTIDAD,
               GCC.SEGMENT1 || '-' || GCC.SEGMENT2 || '-' || GCC.SEGMENT3 || '-' ||
               GCC.SEGMENT4 || '-' || GCC.SEGMENT5 || '-' || GCC.SEGMENT6 || '-' ||
               GCC.SEGMENT7 AS FQA,
               GJB.JE_BATCH_ID BATCHNO,
               GJH.LEDGER_ID AS LEDGER_ID,
               GJH.JE_HEADER_ID,
               GJL.JE_LINE_NUM,
               GJH.JE_HEADER_ID || '-' || GJL.JE_LINE_NUM GL_HL,
               JCV.USER_JE_CATEGORY_NAME CAT_ASIENTO,
               GJH.JE_CATEGORY,
               GJB.NAME LOTE,
               GLLV.LEDGER_NAME,
               GJH.LAST_UPDATED_BY CREATED_BY,
			   GJH.JE_SOURCE ORIGEN

          FROM GL_JE_HEADERS        GJH,
               GL_JE_LINES          GJL,
               GL_JE_BATCHES        GJB, -----
               GL_JE_CATEGORIES_VL  JCV,
               GL_LEDGER_LE_V           GLLV,
               GL_CODE_COMBINATIONS GCC

         WHERE 1 = 1
         
           AND GJH.JE_SOURCE NOT IN ('Payables', 'Receivables')
           AND GJH.ACTUAL_FLAG = 'A'
           AND GJH.STATUS = 'P'
           AND GJH.JE_HEADER_ID = GJL.JE_HEADER_ID
           AND GJH.JE_BATCH_ID = GJB.JE_BATCH_ID -----
           AND GJH.JE_CATEGORY = JCV.JE_CATEGORY_NAME(+)
           AND GJH.LEDGER_ID = GLLV.LEDGER_ID
           AND GJL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
           AND GJH.DEFAULT_EFFECTIVE_DATE >= :P_FECHA_INI
           AND GJH.DEFAULT_EFFECTIVE_DATE < :P_FECHA_FIN + 1
        )

 WHERE (LEDGER_ID IN (:P_LIBRO))
   AND (:P_PROVEEDOR IS NULL OR PROVEEDOR LIKE '%' || :P_PROVEEDOR || '%')
   AND (:P_NIT IS NULL OR VENDORID = :P_NIT)
   AND (:P_FACTURA IS NULL OR INVOICENO = :P_FACTURA)
   AND (:P_CATEGORIA IS NULL OR CAT_ASIENTO = :P_CATEGORIA)
   AND (:P_CUENTA_PUC IS NULL OR PUC LIKE :P_CUENTA_PUC)
   AND ((:P_CUENTA_PUC_INI IS NULL OR PUC >= :P_CUENTA_PUC_INI) AND 
       (:P_CUENTA_PUC_FIN IS NULL OR PUC <= :P_CUENTA_PUC_FIN))
   AND (:P_CUENTA IS NULL OR CTA LIKE :P_CUENTA) 
   AND ((:P_CUENTA_INI IS NULL OR CTA >= :P_CUENTA_INI) AND 
       (:P_CUENTA_FIN IS NULL OR CTA <= :P_CUENTA_FIN))
   AND CCENTER IN (:P_CENTRO_COSTO)
   AND BCODE IN (:P_BCODE)
   AND PM IN (:P_PM)
   
 ORDER BY LEDGER_ID