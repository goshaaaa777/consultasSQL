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
       TO_CHAR(CONVERSION_DATE, 'DD/MM/YYYY') CONVERSION_DATE,
       PAY_NUMBER,
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
        SELECT GCC.SEGMENT1,  --1
                GCC.SEGMENT2    CTA,  --2
                GCC.SEGMENT3    CCENTER, --3 
                GJL.CURRENCY_CODE   CURRENCY_ORG, --4
                (SELECT FFVL.ATTRIBUTE1
                   FROM FND_FLEX_VALUES_VL FFVL
                  WHERE FFVL.VALUE_CATEGORY = 'CNC_CENTRO_COSTO'
                    AND FFVL.FLEX_VALUE = GCC.SEGMENT3) AS CC_CGU, --5
                (SELECT FFVL.ATTRIBUTE2
                   FROM FND_FLEX_VALUES_VL FFVL
                  WHERE FFVL.VALUE_CATEGORY = 'CNC_CENTRO_COSTO'
                    AND FFVL.FLEX_VALUE = GCC.SEGMENT3) AS CC_DDA, --6
                GCC.SEGMENT4    AFE,  --7
                (SELECT FFVL.ATTRIBUTE1
                   FROM FND_FLEX_VALUES_VL FFVL
                  WHERE FFVL.VALUE_CATEGORY = 'CNC_AFE'
                    AND FFVL.FLEX_VALUE = GCC.SEGMENT4) AS TIPO_PROY, --8
                (SELECT FFVL.ATTRIBUTE2 
                   FROM FND_FLEX_VALUES_VL FFVL
                  WHERE FFVL.VALUE_CATEGORY = 'CNC_AFE'
                    AND FFVL.FLEX_VALUE = GCC.SEGMENT4) AS AFE_AREA, --9
                GCC.SEGMENT5    BCODE,  --10
                GCC.SEGMENT6    PM, --11
                GCC.SEGMENT7    PUC,  --12
                GJL.DESCRIPTION LINEDESC, --13 
                XAL.DESCRIPTION INVLINEDESC, --14
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
                         WHERE PS.VENDOR_ID = AIA.VENDOR_ID)) AS VENDORID,  --15
                AIA.INVOICE_DATE AS DATEENTERED,  --16
                NVL(XAL.ACCOUNTED_CR, 0) AS LINECREDIT, --17
                NVL(XAL.ACCOUNTED_DR, 0) AS LINEDEBIT, --18
                NVL(XAL.ACCOUNTED_DR, 0) - NVL(XAL.ACCOUNTED_CR, 0) AS NETO, --19
                GLLV.CURRENCY_CODE AS MONEDA,  --20
                GJH.JE_HEADER_ID JOURNALID,  --21
                TO_CHAR(GJH.DEFAULT_EFFECTIVE_DATE, 'YYYYMM') PERIODO, --22
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
                         WHERE PS.VENDOR_ID = AIA.VENDOR_ID)) AS PROVEEDOR,  --23
                GJH.POSTED_DATE POSTDATE,  --24
                (SELECT ATTRIBUTE15
                   FROM AP_INVOICE_LINES_ALL AIL
                  WHERE AIL.INVOICE_ID = AIA.INVOICE_ID
                    AND AIL.LINE_TYPE_LOOKUP_CODE = 'ITEM'
                    AND ROWNUM = 1) AS MUNICIPIO,  --25
                (SELECT SUM(AIL.QUANTITY_INVOICED)
                   FROM AP_INVOICE_LINES_ALL AIL
                  WHERE AIL.INVOICE_ID = AIA.INVOICE_ID
                    AND AIL.LINE_TYPE_LOOKUP_CODE = 'ITEM') AS CANTIDAD,  --26
                GCC.SEGMENT1 || '-' || GCC.SEGMENT2 || '-' || GCC.SEGMENT3 || '-' || --27
                GCC.SEGMENT4 || '-' || GCC.SEGMENT5 || '-' || GCC.SEGMENT6 || '-' ||  --28
                GCC.SEGMENT7 AS FQA,  --29 
                GJB.JE_BATCH_ID BATCHNO,  --30 
                GJH.LEDGER_ID AS LEDGER_ID,  --31
                GJH.JE_HEADER_ID,  --32
                GJL.JE_LINE_NUM,  --33
                XAH.AE_HEADER_ID || '-' || XAL.AE_LINE_NUM GL_HL, --34
                JCV.USER_JE_CATEGORY_NAME CAT_ASIENTO,  --35
                GJH.JE_CATEGORY,  --36
                GJB.NAME LOTE,  --37 
                GLLV.LEDGER_NAME,  --38
                AIA.LAST_UPDATED_BY CREATED_BY,  --39
               NULL AS  CONVERSION_DATE,  --40
               NULL AS  PAY_NUMBER,   --41
               AIA.INVOICE_NUM AS INVOICENO,   --42
                 GJH.JE_SOURCE ORIGEN   --43

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
                AP_INVOICES_ALL          AIA
         WHERE 1 = 1
           AND GJH.JE_SOURCE = 'Payables'
           AND XTE.ENTITY_CODE = 'AP_INVOICES'
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
           AND NVL(XTE.SOURCE_ID_INT_1, -99) = AIA.INVOICE_ID(+)
           AND GJH.DEFAULT_EFFECTIVE_DATE >= :P_FECHA_INI
           AND GJH.DEFAULT_EFFECTIVE_DATE < :P_FECHA_FIN + 1

 

        UNION ALL
        --AP PAYMENTS
 SELECT         distinct
GCC.SEGMENT1,
                GCC.SEGMENT2    CTA,--1
                GCC.SEGMENT3    CCENTER, --2
                GJL.CURRENCY_CODE   CURRENCY_ORG, --3
                (SELECT FFVL.ATTRIBUTE1
                   FROM FND_FLEX_VALUES_VL FFVL
                  WHERE FFVL.VALUE_CATEGORY = 'CNC_CENTRO_COSTO'
                    AND FFVL.FLEX_VALUE = GCC.SEGMENT3) AS CC_CGU, --4
                (SELECT FFVL.ATTRIBUTE2
                   FROM FND_FLEX_VALUES_VL FFVL
                  WHERE FFVL.VALUE_CATEGORY = 'CNC_CENTRO_COSTO'
                    AND FFVL.FLEX_VALUE = GCC.SEGMENT3) AS CC_DDA, --5
                GCC.SEGMENT4    AFE, --6
                (SELECT FFVL.ATTRIBUTE1
                   FROM FND_FLEX_VALUES_VL FFVL
                  WHERE FFVL.VALUE_CATEGORY = 'CNC_AFE'
                    AND FFVL.FLEX_VALUE = GCC.SEGMENT4) AS TIPO_PROY, --7
                (SELECT FFVL.ATTRIBUTE2
                   FROM FND_FLEX_VALUES_VL FFVL
                  WHERE FFVL.VALUE_CATEGORY = 'CNC_AFE'
                    AND FFVL.FLEX_VALUE = GCC.SEGMENT4) AS AFE_AREA, --8
                GCC.SEGMENT5    BCODE, --9
                GCC.SEGMENT6    PM,   --10
                GCC.SEGMENT7    PUC,  --11
                GJL.DESCRIPTION LINEDESC, --12
                XAL.DESCRIPTION INVLINEDESC, --13
                (SELECT PS.SEGMENT1 --|| '-' || PS.ATTRIBUTE5
                   FROM POZ_SUPPLIERS_V PS
                  WHERE PS.VENDOR_ID = ACA.VENDOR_ID) AS VENDORID,--14
                ACA.CHECK_DATE AS DATEENTERED, --15
                NVL(XDL.UNROUNDED_ACCOUNTED_CR, 0) AS LINECREDIT, --16
                NVL(XDL.UNROUNDED_ACCOUNTED_DR, 0) AS LINEDEBIT,  --17 
                NVL(XDL.UNROUNDED_ACCOUNTED_DR, 0) - NVL(XDL.UNROUNDED_ACCOUNTED_CR, 0) AS NETO, --18
                GLLV.CURRENCY_CODE AS MONEDA, --19 
                GJH.JE_HEADER_ID JOURNALID, --20
                TO_CHAR(GJH.DEFAULT_EFFECTIVE_DATE, 'YYYYMM') PERIODO,  --21
                (SELECT PS.VENDOR_NAME
                   FROM POZ_SUPPLIERS_V PS
                  WHERE PS.VENDOR_ID = ACA.VENDOR_ID) AS PROVEEDOR, --22
                GJH.POSTED_DATE POSTDATE, --23
                (SELECT SUBSTR(HG.GEOGRAPHY_CODE,3)
                   FROM HZ_GEOGRAPHIES HG
                  WHERE UPPER(HG.GEOGRAPHY_NAME) = UPPER(ACA.CITY)
                    AND UPPER(HG.GEOGRAPHY_ELEMENT2) = UPPER(ACA.STATE)
                    AND HG.GEOGRAPHY_TYPE = 'MUNICIPIO'
                    AND HG.COUNTRY_CODE = ACA.COUNTRY) AS MUNICIPIO,  --24
                NULL AS CANTIDAD,   --25
                GCC.SEGMENT1 || '-' || GCC.SEGMENT2 || '-' || GCC.SEGMENT3 || '-' ||  --26
                GCC.SEGMENT4 || '-' || GCC.SEGMENT5 || '-' || GCC.SEGMENT6 || '-' ||  --17
                GCC.SEGMENT7 AS FQA,  --28
                GJB.JE_BATCH_ID BATCHNO,  --29
                GJH.LEDGER_ID AS LEDGER_ID,  --30
                GJH.JE_HEADER_ID,  --31
                GJL.JE_LINE_NUM, --32
                XAH.AE_HEADER_ID || '-' || XAL.AE_LINE_NUM GL_HL, --33
                JCV.USER_JE_CATEGORY_NAME CAT_ASIENTO,  --34
                GJH.JE_CATEGORY,  --35
                GJB.NAME LOTE,  --36
                GLLV.LEDGER_NAME,  --37
                ACA.LAST_UPDATED_BY CREATED_BY, --38
                AIA.EXCHANGE_DATE AS  CONVERSION_DATE,  --39
                ACA.CHECK_NUMBER AS  PAY_NUMBER,  --40
               AIA.INVOICE_NUM AS INVOICENO,  --41
               GJH.JE_SOURCE ORIGEN  --43

         FROM GL_JE_HEADERS            GJH, -- -- -- --
               GL_JE_LINES              GJL, -- --
               GL_JE_BATCHES            GJB, --
               GL_JE_CATEGORIES_VL      JCV, --
               GL_JE_SOURCES_VL         JSV,--
               GL_LEDGER_LE_V           GLLV, --
               GL_CODE_COMBINATIONS     GCC, --
               GL_IMPORT_REFERENCES     GIR, -- -- -- --
               XLA_AE_LINES             XAL, -- -- --
               XLA_AE_HEADERS           XAH, -- --
               XLA_TRANSACTION_ENTITIES XTE, -- --
               AP_CHECKS_ALL            ACA, --
               POZ_SUPPLIERS_V              PSV,
               AP_PAYMENT_HISTORY_ALL    APHA, --
               AP_PAYMENT_HIST_DISTS      APHD, --
               AP_INVOICE_PAYMENTS_ALL   AIP, --
               AP_INVOICES_ALL           AIA, -- --
               xle_le_ou_ledger_v        XLE, --
               hr_all_organization_units HR, --
               XLA_DISTRIBUTION_LINKS    XDL, -- -- --   
			         XLA_EVENTS XE
 

          
 

         WHERE 1 = 1
           AND GJH.JE_HEADER_ID = GJL.JE_HEADER_ID --
           AND GJL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID --
           AND GJH.JE_BATCH_ID = GJB.JE_BATCH_ID --
           AND GJH.JE_CATEGORY = JCV.JE_CATEGORY_NAME(+) --
         --AND NVL(AH.JE_CATEGORY_NAME, JH.JE_CATEGORY) = JCV.JE_CATEGORY_NAME
           AND GJH.LEDGER_ID = GLLV.LEDGER_ID --
           AND GJH.ledger_id = XLE.ledger_id
           AND HR.organization_id = XLE.operating_unit_id
           AND GJL.JE_HEADER_ID = GIR.JE_HEADER_ID -------
           AND GJL.JE_LINE_NUM = GIR.JE_LINE_NUM ------
           AND GIR.GL_SL_LINK_TABLE = XAL.GL_SL_LINK_TABLE -------
           AND GIR.GL_SL_LINK_ID = XAL.GL_SL_LINK_ID ------
           AND XAL.AE_HEADER_ID = XAH.AE_HEADER_ID
           AND XAL.AE_HEADER_ID = XDL.AE_HEADER_ID
           AND XAL.AE_LINE_NUM = XDL.AE_LINE_NUM    
           AND XAL.APPLICATION_ID = XAH.APPLICATION_ID ---
           AND XAH.APPLICATION_ID = XTE.APPLICATION_ID ---
           AND XAH.ENTITY_ID = XTE.ENTITY_ID -------
           AND XAH.EVENT_ID = XDL.EVENT_ID -----
           AND APHD.PAYMENT_HIST_DIST_ID = XDL.SOURCE_DISTRIBUTION_ID_NUM_1  
           AND APHD.PAYMENT_HISTORY_ID = APHA.PAYMENT_HISTORY_ID
           AND ACA.VENDOR_NAME = PSV.VENDOR_NAME(+)
           AND GJH.JE_SOURCE = 'Payables' ---   
           AND GJH.ACTUAL_FLAG = 'A' --
           AND GJH.STATUS = 'P' --
           AND XTE.ENTITY_CODE = 'AP_PAYMENTS'
           AND APHD.INVOICE_PAYMENT_ID = AIP.INVOICE_PAYMENT_ID
           AND AIP.INVOICE_ID = AIA.INVOICE_ID
           AND (XDL.APPLIED_TO_SOURCE_ID_NUM_1 = AIA.INVOICE_ID)
           AND GJH.JE_SOURCE = JSV.JE_SOURCE_NAME  --
           AND XTE.ENTITY_ID = XE.ENTITY_ID
           AND ACA.CHECK_ID = APHA.CHECK_ID
           AND NVL(XTE.SOURCE_ID_INT_1, -99) = ACA.CHECK_ID
           AND XAH.GL_TRANSFER_STATUS_CODE = 'Y'
           AND (NVL(XDL.UNROUNDED_ACCOUNTED_CR,0) <> 0 OR NVL(XDL.UNROUNDED_ACCOUNTED_DR,0) <> 0)
           AND GJH.DEFAULT_EFFECTIVE_DATE >= :P_FECHA_INI
           AND GJH.DEFAULT_EFFECTIVE_DATE < :P_FECHA_FIN + 1
           AND XTE.APPLICATION_ID = XE.APPLICATION_ID
        UNION ALL
        --AR
        SELECT GCC.SEGMENT1,  --1
               GCC.SEGMENT2    CTA,  --2
               GCC.SEGMENT3    CCENTER,  --3
               GJL.CURRENCY_CODE   CURRENCY_ORG,  --4
               (SELECT FFVL.ATTRIBUTE1
                   FROM FND_FLEX_VALUES_VL FFVL
                  WHERE FFVL.VALUE_CATEGORY = 'CNC_CENTRO_COSTO'
                    AND FFVL.FLEX_VALUE = GCC.SEGMENT3) AS CC_CGU, --5
                (SELECT FFVL.ATTRIBUTE2
                   FROM FND_FLEX_VALUES_VL FFVL
                  WHERE FFVL.VALUE_CATEGORY = 'CNC_CENTRO_COSTO'
                    AND FFVL.FLEX_VALUE = GCC.SEGMENT3) AS CC_DDA, --6
                GCC.SEGMENT4    AFE, --7
                (SELECT FFVL.ATTRIBUTE1
                   FROM FND_FLEX_VALUES_VL FFVL
                  WHERE FFVL.VALUE_CATEGORY = 'CNC_AFE'
                    AND FFVL.FLEX_VALUE = GCC.SEGMENT4) AS TIPO_PROY, --8
                (SELECT FFVL.ATTRIBUTE2
                   FROM FND_FLEX_VALUES_VL FFVL
                  WHERE FFVL.VALUE_CATEGORY = 'CNC_AFE'
                    AND FFVL.FLEX_VALUE = GCC.SEGMENT4) AS AFE_AREA, --9
               GCC.SEGMENT5    BCODE,  --10
               GCC.SEGMENT6    PM, --11 
               GCC.SEGMENT7    PUC,  --12
               GJL.DESCRIPTION LINEDESC, --13 
               XAL.DESCRIPTION INVLINEDESC, --14
               HP.PARTY_NUMBER AS VENDORID, --15
               TRX.TRX_DATE AS DATEENTERED, --17
               NVL(XAL.ACCOUNTED_CR, 0) AS LINECREDIT, --18
               NVL(XAL.ACCOUNTED_DR, 0) AS LINEDEBIT, --19
               NVL(XAL.ACCOUNTED_DR, 0) - NVL(XAL.ACCOUNTED_CR, 0) AS NETO, --20
               GLLV.CURRENCY_CODE AS MONEDA, --21
               GJH.JE_HEADER_ID JOURNALID, --22
               TO_CHAR(GJH.DEFAULT_EFFECTIVE_DATE, 'YYYYMM') PERIODO, --23
               HP.PARTY_NAME AS PROVEEDOR, --24
               GJH.POSTED_DATE POSTDATE, --25
               (SELECT ATTRIBUTE1
                  FROM RA_CUSTOMER_TRX_LINES_ALL TRXLIN
                 WHERE TRXLIN.CUSTOMER_TRX_ID = TRX.CUSTOMER_TRX_ID
                   AND LINE_TYPE = 'LINE'
                   AND ROWNUM = 1) AS MUNICIPIO, --26
               (SELECT SUM(TRXLIN.QUANTITY_INVOICED)
                  FROM RA_CUSTOMER_TRX_LINES_ALL TRXLIN
                 WHERE TRXLIN.CUSTOMER_TRX_ID = TRX.CUSTOMER_TRX_ID
                   AND TRXLIN.LINE_TYPE = 'LINE'
                   --AND XAL.ACCOUNTING_CLASS_CODE = 'RECEIVABLE'
                   ) AS CANTIDAD, --27
               GCC.SEGMENT1 || '-' || GCC.SEGMENT2 || '-' || GCC.SEGMENT3 || '-' || --28
               GCC.SEGMENT4 || '-' || GCC.SEGMENT5 || '-' || GCC.SEGMENT6 || '-' || --29
               GCC.SEGMENT7 AS FQA, --30
               GJB.JE_BATCH_ID BATCHNO,  --31
               GJH.LEDGER_ID AS LEDGER_ID, -- 32
               GJH.JE_HEADER_ID, --33
               GJL.JE_LINE_NUM, --34
               XAH.AE_HEADER_ID || '-' || XAL.AE_LINE_NUM GL_HL, --35
               JCV.USER_JE_CATEGORY_NAME CAT_ASIENTO, --36 
               GJH.JE_CATEGORY, --37 
               GJB.NAME LOTE, --38 
               GLLV.LEDGER_NAME,  --39 
               TRX.LAST_UPDATED_BY CREATED_BY, --40 
               NULL AS  CONVERSION_DATE,  --41
               NULL AS  PAY_NUMBER,  --42
               TRX.TRX_NUMBER AS INVOICENO, --16 --43  
               GJH.JE_SOURCE ORIGEN  --44
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
               GJH.DEFAULT_EFFECTIVE_DATE AS DATEENTERED,
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
               NULL AS  CONVERSION_DATE,
               NULL AS  PAY_NUMBER,
                DECODE(JCV.USER_JE_CATEGORY_NAME, 'CNC-JV JOINT VENTURE', GJL.ATTRIBUTE1, NULL) AS INVOICENO,
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