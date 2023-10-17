SELECT SEGMENT1,
       LEDGER_NAME,
       CTA,
       CCENTER,
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
     LAST_UPDATED_BY
  FROM (
        --AP INVOICE - CAMBIO
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
               AIA.EXCHANGE_DATE,
               AIA.LAST_UPDATED_BY CREATED_BY,
         GJH.LAST_UPDATED_BY   
          FROM GL_JE_HEADERS            GJH, 
               GL_JE_LINES              GJL,
               GL_CODE_COMBINATIONS     GCC,
               GL_JE_BATCHES            GJB,
               AP_CHECKS_ALL            ACA,
               GL_JE_CATEGORIES_VL      JCV,
               GL_LEDGER_LE_V           GLLV,
               GL_IMPORT_REFERENCES     GIR,
               XLA_AE_LINES             XAL,
               XLA_AE_HEADERS           XAH,
               XLA_TRANSACTION_ENTITIES XTE,
               AP_INVOICES_ALL          AIA,
               POZ_SUPPLIERS_V              PSV,
               AP_PAYMENT_HISTORY_ALL    APHA,
               AP_INVOICE_PAYMENTS_ALL   AIP

         WHERE 1 = 1
           AND GJH.JE_HEADER_ID = GJL.JE_HEADER_ID
           AND GJL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
           AND GJH.JE_BATCH_ID = GJB.JE_BATCH_ID
           AND GJH.JE_CATEGORY = JCV.JE_CATEGORY_NAME(+)
           
           AND AIP.INVOICE_ID = AIA.INVOICE_ID
	   AND (XDL.APPLIED_TO_SOURCE_ID_NUM_1 = AIA.INVOICE_ID)
       
           AND GJH.LEDGER_ID = GLLV.LEDGER_ID
           AND GJL.JE_HEADER_ID = GIR.JE_HEADER_ID
           AND GJL.JE_LINE_NUM = GIR.JE_LINE_NUM
           AND GIR.GL_SL_LINK_TABLE = XAL.GL_SL_LINK_TABLE
           AND GIR.GL_SL_LINK_ID = XAL.GL_SL_LINK_ID
           AND XAL.AE_HEADER_ID = XAH.AE_HEADER_ID
           AND XAL.APPLICATION_ID = XAH.APPLICATION_ID
           AND XAH.APPLICATION_ID = XTE.APPLICATION_ID
           AND XAH.ENTITY_ID = XTE.ENTITY_ID
           AND NVL(XTE.SOURCE_ID_INT_1, -99) = AIA.INVOICE_ID
           
            AND ACA.VENDOR_NAME = PSV.VENDOR_NAME(+)
 	       AND ACA.CHECK_ID = APHA.CHECK_ID
           AND NVL(XTE.SOURCE_ID_INT_1, -99) = ACA.CHECK_ID
           AND ACA.CHECK_NUMBER = '204'
           AND ACA.CHECK_ID = APHA.CHECK_ID
           AND NVL(XTE.SOURCE_ID_INT_1, -99) = ACA.CHECK_ID

           AND GJH.JE_SOURCE = 'Payables'
           AND GJH.ACTUAL_FLAG = 'A'
           AND GJH.STATUS = 'P'
           AND XTE.ENTITY_CODE = 'AP_INVOICES'
           AND XAH.GL_TRANSFER_STATUS_CODE = 'Y'
           AND GJH.DEFAULT_EFFECTIVE_DATE >= :P_FECHA_INI
           AND GJH.DEFAULT_EFFECTIVE_DATE < :P_FECHA_FIN + 1
           
        UNION ALL
        --AP PAYMENTS


 SELECT  GCC.SEGMENT1,
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
               (SELECT AOS.VENDOR_VAT_REGISTRATION_NUM
                  FROM AP_OFR_SUPPLIERS_V AOS
                 WHERE AOS.VENDOR_ID = ACA.VENDOR_ID
                   AND ROWNUM = 1) AS VENDORID,
               TO_CHAR(ACA.CHECK_NUMBER) AS  PAY_NUMBER,
               AIA.INVOICE_NUM AS FACTURA,
               ACA.CHECK_DATE AS DATEENTERED,
               NVL(XDL.UNROUNDED_ACCOUNTED_CR, 0) AS LINECREDIT,
               NVL(XDL.UNROUNDED_ACCOUNTED_DR, 0) AS LINEDEBIT,
               NVL(XDL.UNROUNDED_ACCOUNTED_CR, 0) - NVL(XDL.UNROUNDED_ACCOUNTED_DR, 0) AS NETO,            
               GLLV.CURRENCY_CODE AS MONEDA,
               GJH.JE_HEADER_ID JOURNALID,
               TO_CHAR(GJH.DEFAULT_EFFECTIVE_DATE, 'YYYYMM') PERIODO,
               (SELECT PS.VENDOR_NAME
                  FROM POZ_SUPPLIERS_V PS
                 WHERE PS.VENDOR_ID = ACA.VENDOR_ID) AS PROVEEDOR,
               GJH.POSTED_DATE POSTDATE,
               /*(SELECT SUBSTR(HG.GEOGRAPHY_CODE,3)
                  FROM HZ_GEOGRAPHIES HG
                 WHERE UPPER(HG.GEOGRAPHY_NAME) = UPPER(ACA.CITY)
                   AND UPPER(HG.GEOGRAPHY_ELEMENT2) = UPPER(ACA.STATE)
                   AND HG.GEOGRAPHY_TYPE = 'MUNICIPIO'
                   AND HG.COUNTRY_CODE = ACA.COUNTRY)*/
         ACA.CITY AS MUNICIPIO,
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
        	   GJH.LAST_UPDATED_BY, 
         --ACA.CHECK_NUMBER,
                AIA.EXCHANGE_DATE AS  CONVERSION_DATE
                     
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
               XLA_DISTRIBUTION_LINKS    XDL -- -- --     
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
           AND GJH.JE_SOURCE = JSV.JE_SOURCE_NAME
           AND ACA.CHECK_NUMBER = '204'
           AND ACA.CHECK_ID = APHA.CHECK_ID
           AND NVL(XTE.SOURCE_ID_INT_1, -99) = ACA.CHECK_ID
           AND XAH.GL_TRANSFER_STATUS_CODE = 'Y'
           AND (NVL(XDL.UNROUNDED_ACCOUNTED_CR,0) <> 0 OR NVL(XDL.UNROUNDED_ACCOUNTED_DR,0) <> 0)
		   AND GJH.DEFAULT_EFFECTIVE_DATE >= :P_FECHA_INI
           AND GJH.DEFAULT_EFFECTIVE_DATE < :P_FECHA_FIN + 1

        UNION ALL
        ---AR TRANSACTIONS
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
               NVL(HP.PARTY_NUMBER,
                  (SELECT HP.PARTY_NUMBER
                     FROM HZ_CUST_ACCOUNTS  HCA,
                          HZ_PARTIES        HP
                    WHERE HCA.CUST_ACCOUNT_ID = TRX.BILL_TO_CUSTOMER_ID
                      AND HCA.PARTY_ID = HP.PARTY_ID)) AS VENDORID,
               TRX.TRX_NUMBER AS INVOICENO,
               TRX.TRX_DATE AS DATEENTERED,
               NVL(XAL.ACCOUNTED_CR, 0) AS LINECREDIT,
               NVL(XAL.ACCOUNTED_DR, 0) AS LINEDEBIT,
               NVL(XAL.ACCOUNTED_DR, 0) - NVL(XAL.ACCOUNTED_CR, 0) AS NETO,
               GLLV.CURRENCY_CODE AS MONEDA,
               GJH.JE_HEADER_ID JOURNALID,
               TO_CHAR(GJH.DEFAULT_EFFECTIVE_DATE, 'YYYYMM') PERIODO,
               NVL(HP.PARTY_NAME,
                  (SELECT HP.PARTY_NAME
                     FROM HZ_CUST_ACCOUNTS  HCA,
                          HZ_PARTIES        HP
                    WHERE HCA.CUST_ACCOUNT_ID = TRX.BILL_TO_CUSTOMER_ID
                      AND HCA.PARTY_ID = HP.PARTY_ID)) AS PROVEEDOR,
               GJH.POSTED_DATE POSTDATE,
                   NVL((SELECT ATTRIBUTE1
                  FROM RA_CUSTOMER_TRX_LINES_ALL TRXLIN
                 WHERE TRXLIN.CUSTOMER_TRX_ID = TRX.CUSTOMER_TRX_ID
                   AND LINE_TYPE = 'LINE'
                   AND ROWNUM = 1) , (SELECT LISTAGG(DISTINCT UPPER(HZ.CITY) , ' / ') FROM HZ_LOCATIONS HZ,
                                  RA_CUSTOMER_TRX_LINES_ALL RL
                                    WHERE HZ.LOCATION_ID = RL.FINAL_DISCHARGE_LOCATION_ID
                                    AND RL.CUSTOMER_TRX_ID = TRX.CUSTOMER_TRX_ID)) AS MUNICIPIO,
               (SELECT SUM(RCTLA.QUANTITY_INVOICED)
                  FROM RA_CUSTOMER_TRX_ALL          RCTA,
                       RA_CUSTOMER_TRX_LINES_ALL    RCTLA,
                       RA_CUST_TRX_LINE_GL_DIST_ALL DIST,
                       XLA_DISTRIBUTION_LINKS       XDL
                 WHERE RCTA.customer_trx_id = RCTLA.customer_trx_id
                   AND RCTLA.CUSTOMER_TRX_LINE_ID = dist.CUSTOMER_TRX_LINE_ID
                   AND XDL.SOURCE_DISTRIBUTION_TYPE = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
                   AND XDL.source_distribution_id_num_1 = DIST.cust_trx_line_gl_dist_id
                   AND XDL.AE_HEADER_ID = XAH.AE_HEADER_ID
                   AND XDL.AE_LINE_NUM = XAL.AE_LINE_NUM
                   AND RCTLA.line_type = 'LINE'
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
         GJH.LAST_UPDATED_BY 
          FROM GL_JE_HEADERS            GJH,
               GL_JE_LINES              GJL,
               GL_CODE_COMBINATIONS     GCC,
               GL_JE_BATCHES            GJB,
               GL_JE_CATEGORIES_VL      JCV,
               GL_LEDGER_LE_V           GLLV,
               GL_IMPORT_REFERENCES     GIR,
               XLA_AE_LINES             XAL,
               XLA_AE_HEADERS           XAH,
               XLA_TRANSACTION_ENTITIES XTE,
               RA_CUSTOMER_TRX_ALL      TRX,
               HZ_PARTIES               HP
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
           AND NVL(XTE.SOURCE_ID_INT_1, -99) = TRX.CUSTOMER_TRX_ID
           AND TRX.SOLD_TO_PARTY_ID = HP.PARTY_ID(+)
           AND GJH.JE_SOURCE = 'Receivables'
           AND GJH.ACTUAL_FLAG = 'A'
           AND GJH.STATUS = 'P'
           AND XTE.ENTITY_CODE = 'TRANSACTIONS'
           AND XAH.GL_TRANSFER_STATUS_CODE = 'Y'
           AND GJH.DEFAULT_EFFECTIVE_DATE >= :P_FECHA_INI
           AND GJH.DEFAULT_EFFECTIVE_DATE < :P_FECHA_FIN + 1
        UNION ALL
        ---AR  RECEIPTS


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
               HP.PARTY_NUMBER AS VENDORID,
               TRX.RECEIPT_NUMBER AS INVOICENO,
               TRX.RECEIPT_DATE AS DATEENTERED,
               NVL(XAL.ACCOUNTED_CR, 0) AS LINECREDIT,
               NVL(XAL.ACCOUNTED_DR, 0) AS LINEDEBIT,
               NVL(XAL.ACCOUNTED_DR, 0) - NVL(XAL.ACCOUNTED_CR, 0) AS NETO,
               GLLV.CURRENCY_CODE AS MONEDA,
               GJH.JE_HEADER_ID JOURNALID,
               TO_CHAR(GJH.DEFAULT_EFFECTIVE_DATE, 'YYYYMM') PERIODO,
               HP.PARTY_NAME AS PROVEEDOR,
               GJH.POSTED_DATE  POSTDATE,
               NULL AS MUNICIPIO,
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
               TRX.LAST_UPDATED_BY CREATED_BY,
         GJH.LAST_UPDATED_BY 
          FROM GL_JE_HEADERS            GJH,
               GL_JE_LINES              GJL,
               GL_CODE_COMBINATIONS     GCC,
               GL_JE_BATCHES            GJB,
               GL_JE_CATEGORIES_VL      JCV,
               GL_LEDGER_LE_V           GLLV,
               GL_IMPORT_REFERENCES     GIR,
               XLA_AE_LINES             XAL,
               XLA_AE_HEADERS           XAH,
               XLA_TRANSACTION_ENTITIES XTE,
               AR_CASH_RECEIPTS_ALL     TRX,
               HZ_CUST_ACCOUNTS         HCA,
               HZ_PARTIES               HP
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
           AND NVL(XTE.SOURCE_ID_INT_1, -99) = TRX.CASH_RECEIPT_ID
           AND TRX.PAY_FROM_CUSTOMER = HCA.CUST_ACCOUNT_ID
           AND HCA.PARTY_ID = HP.PARTY_ID
           AND GJH.JE_SOURCE = 'Receivables'
           AND GJH.ACTUAL_FLAG = 'A'
           AND GJH.STATUS = 'P'
           AND XTE.ENTITY_CODE = 'RECEIPTS'
           AND XAH.GL_TRANSFER_STATUS_CODE = 'Y'
           AND GJH.DEFAULT_EFFECTIVE_DATE >= :P_FECHA_INI
           AND GJH.DEFAULT_EFFECTIVE_DATE < :P_FECHA_FIN + 1
        UNION ALL
        ---AR  ADJUSTMENTS
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
               HP.PARTY_NUMBER AS VENDORID,
               TRX.TRX_NUMBER AS INVOICENO,
               TRX.TRX_DATE AS DATEENTERED,
               NVL(XAL.ACCOUNTED_CR, 0) AS LINECREDIT,
               NVL(XAL.ACCOUNTED_DR, 0) AS LINEDEBIT,
               NVL(XAL.ACCOUNTED_DR, 0) - NVL(XAL.ACCOUNTED_CR, 0) AS NETO,
               GLLV.CURRENCY_CODE AS MONEDA,
               GJH.JE_HEADER_ID JOURNALID,
               TO_CHAR(GJH.DEFAULT_EFFECTIVE_DATE, 'YYYYMM') PERIODO,
               NVL(HP.PARTY_NAME,
                  (SELECT HP.PARTY_NAME
                     FROM HZ_CUST_ACCOUNTS  HCA,
                          HZ_PARTIES        HP
                    WHERE HCA.CUST_ACCOUNT_ID = TRX.BILL_TO_CUSTOMER_ID
                      AND HCA.PARTY_ID = HP.PARTY_ID)) AS PROVEEDOR,
               GJH.POSTED_DATE POSTDATE,
               (SELECT ATTRIBUTE1
                  FROM RA_CUSTOMER_TRX_LINES_ALL TRXLIN
                 WHERE TRXLIN.CUSTOMER_TRX_ID = TRX.CUSTOMER_TRX_ID
                   AND LINE_TYPE = 'LINE'
                   AND ROWNUM = 1) AS MUNICIPIO,
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
               TRX.LAST_UPDATED_BY CREATED_BY,
         GJH.LAST_UPDATED_BY 
          FROM GL_JE_HEADERS            GJH,
               GL_JE_LINES              GJL,
               GL_CODE_COMBINATIONS     GCC,
               GL_JE_BATCHES            GJB,
               GL_JE_CATEGORIES_VL      JCV,
               GL_LEDGER_LE_V           GLLV,
               GL_IMPORT_REFERENCES     GIR,
               XLA_AE_LINES             XAL,
               XLA_AE_HEADERS           XAH,
               XLA_TRANSACTION_ENTITIES XTE,
               AR_ADJUSTMENTS_ALL       AAA,
               RA_CUSTOMER_TRX_ALL      TRX,
               HZ_PARTIES               HP
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
           AND NVL(XTE.SOURCE_ID_INT_1, -99) = AAA.ADJUSTMENT_ID
           AND AAA.CUSTOMER_TRX_ID = TRX.CUSTOMER_TRX_ID
           AND TRX.SOLD_TO_PARTY_ID = HP.PARTY_ID(+)
           AND GJH.JE_SOURCE = 'Receivables'
           AND GJH.ACTUAL_FLAG = 'A'
           AND GJH.STATUS = 'P'
           AND XTE.ENTITY_CODE = 'ADJUSTMENTS'
           AND XAH.GL_TRANSFER_STATUS_CODE = 'Y'
           AND GJH.DEFAULT_EFFECTIVE_DATE >= :P_FECHA_INI
           AND GJH.DEFAULT_EFFECTIVE_DATE < :P_FECHA_FIN + 1
        UNION ALL
        --GL
        SELECT GCC.SEGMENT1,
               GCC.SEGMENT2 CTA,
               GCC.SEGMENT3 CCENTER,
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
               CASE
                 WHEN GJH.JE_SOURCE IN ('Manual', 'Spreadsheet','300000004099074','300000004099076','300000004099078') THEN
                   (SELECT AOS.VENDOR_VAT_REGISTRATION_NUM
                      FROM POZ_SUPPLIERS_V     PSV,
                           AP_OFR_SUPPLIERS_V  AOS
                     WHERE PSV.VENDOR_ID = AOS.VENDOR_ID
                       AND PSV.PARTY_ID = GJL.ATTRIBUTE2
                       AND ROWNUM = 1)
                 ELSE
                   DECODE(JCV.USER_JE_CATEGORY_NAME,
                          'CNC-JV JOINT VENTURE', (SELECT PS.SEGMENT1 
                                                     FROM POZ_SUPPLIERS_V PS
                                                    WHERE PARTY_ID = GJL.ATTRIBUTE2
                                                      AND ROWNUM = 1),
                          NULL)
               END AS VENDORID,
               DECODE(JCV.USER_JE_CATEGORY_NAME, 
                      'CNC-JV JOINT VENTURE', 
                      GJL.ATTRIBUTE5, NULL) AS INVOICENO,
               GJH.DEFAULT_EFFECTIVE_DATE AS DATEENTERED,
               NVL(GJL.ACCOUNTED_CR, 0) AS LINECREDIT,
               NVL(GJL.ACCOUNTED_DR, 0) AS LINEDEBIT,
               NVL(GJL.ACCOUNTED_DR, 0) - NVL(GJL.ACCOUNTED_CR, 0) AS NETO,
               GLLV.CURRENCY_CODE AS MONEDA,
               GJH.JE_HEADER_ID JOURNALID,
               TO_CHAR(GJH.DEFAULT_EFFECTIVE_DATE, 'YYYYMM') PERIODO,
               CASE
                 WHEN GJH.JE_SOURCE IN ('Manual', 'Spreadsheet','300000004099074','300000004099076','300000004099078') THEN
                   GJL.ATTRIBUTE4
                 ELSE
                   DECODE(JCV.USER_JE_CATEGORY_NAME, 
                          'CNC-JV JOINT VENTURE', GJL.ATTRIBUTE4,
                          NULL)
               END AS PROVEEDOR,
               GJH.POSTED_DATE POSTDATE,
               CASE
                 WHEN GJH.JE_SOURCE IN ('Manual', 'Spreadsheet','300000004099074','300000004099076','300000004099078') THEN
                   GJL.ATTRIBUTE6
                 ELSE
                   NULL
               END AS MUNICIPIO,
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
         GJH.LAST_UPDATED_BY 
          FROM GL_JE_HEADERS         GJH,
               GL_JE_LINES           GJL,
               GL_CODE_COMBINATIONS  GCC,
               GL_JE_BATCHES         GJB,
               GL_JE_CATEGORIES_VL   JCV,
               GL_LEDGER_LE_V        GLLV
         WHERE 1 = 1
           AND GJH.JE_HEADER_ID = GJL.JE_HEADER_ID
           AND GJL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
           AND GJH.JE_BATCH_ID = GJB.JE_BATCH_ID
           AND GJH.JE_CATEGORY = JCV.JE_CATEGORY_NAME(+)
           AND GJH.LEDGER_ID = GLLV.LEDGER_ID
           AND GJH.JE_SOURCE NOT IN ('Payables','Receivables')
           AND GJH.ACTUAL_FLAG = 'A'
           AND GJH.STATUS = 'P'
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
   AND ( :P_AFE IS NULL OR AFE = :P_AFE)
 ORDER BY LEDGER_ID