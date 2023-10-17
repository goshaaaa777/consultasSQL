--GN
SELECT DISTINCT
A.PERIODO,
       A.CCID,
       A.COMBINACION,
	   A.CORRELATIVO,
       A.ORIGEN,
       A.TIPO_OPERACION,
       A.ID_DOCUMENTO,
       A.NUM_DOCUMENTO,
       A.CLIEN_PROV,
	   A.TIPO_DOC_IDENT, -- 
       A.RUC_DNI, -- 
       A.DIVISA,
       A.NUMERO_ASIENTO,
       A.COMPANIA,
       A.CENTRO_COSTO,
       A.CUENTA,
       A.PROYECTO,
       A.CLASIFICADOR,
       A.META,
       A.FUTURO,
       A.FECHA_CONTABLE,
       A.FECHA_DOC,
       A.NOMBRE_ASIENTO,
       A.DESCRIPCION_LINEA,
       A.NUMERO_VOUCHER,
       A.DESCRIPCION,
       A.TIPO_CAMBIO,
       A.DESCRIPTION_CTA,
	   case 
       when A.ESTADO = 'P' THEN
       'CONTABILIZADO'
       ELSE
       'NO CONTABILIZADO'
       END ESTADO,
       A.MONTO_DEBITO MONTO_DEBITO,
       A.MONTO_CREDITO MONTO_CREDITO,
       A.MONTO_FUNCIONAL_DEBITO MONTO_FUNCIONAL_DEBITO,
       A.MONTO_FUNCIONAL_CREDITO MONTO_FUNCIONAL_CREDITO
 FROM (
Select T.PERIODO,
       T.CCID,
       T.COMBINACION,
	   T.CORRELATIVO,
       T.ORIGEN,
       T.TIPO_OPERACION,
       T.ID_DOCUMENTO,
	   CASE WHEN T.TIPO_OPERACION = 'Payments' THEN
       LISTAGG(T.NUM_DOCUMENTO, ',') WITHIN GROUP (ORDER BY T.NUM_DOCUMENTO) over (partition by T.COMBINACION,T.CORRELATIVO,T.ID_DOCUMENTO,T.NUMERO_ASIENTO) 
	   ELSE
	   T.NUM_DOCUMENTO END AS NUM_DOCUMENTO,
       T.CLIEN_PROV,
	   T.TIPO_DOC_IDENT, 
       T.RUC_DNI, 
       T.DIVISA,
       T.NUMERO_ASIENTO,
       T.COMPANIA,
       T.CENTRO_COSTO,
       T.CUENTA,
       T.PROYECTO,
       T.CLASIFICADOR,
       T.META,
       T.FUTURO,
       TO_CHAR(T.FECHA_CONTABLE, 'DD/MM/YYYY') FECHA_CONTABLE,
       T.FECHA_DOC,
       T.NOMBRE_ASIENTO,
       T.DESCRIPCION_LINEA,
       T.NUMERO_VOUCHER,
       T.DESCRIPCION,
       case
         when T.MONTO_DEBITO = 0 then
          null
         else
          T.MONTO_DEBITO
       end MONTO_DEBITO,
       case
         when T.MONTO_CREDITO = 0 then
          null
         else
          T.MONTO_CREDITO
       end MONTO_CREDITO,
       case
         when T.MONTO_FUNCIONAL_DEBITO = 0 then
          null
         else
          T.MONTO_FUNCIONAL_DEBITO
       end MONTO_FUNCIONAL_DEBITO,
       case
         when T.MONTO_FUNCIONAL_CREDITO = 0 then
          null
         else
          T.MONTO_FUNCIONAL_CREDITO
       end MONTO_FUNCIONAL_CREDITO,
       case
         when T.DIVISA = 'PEN' and T.TIPO_CAMBIO is null then
          1
         else
          T.TIPO_CAMBIO
       end TIPO_CAMBIO,
       T_CTAS.DESCRIPTION_CTA,
	   T.ESTADO
  from (
        ------------------------------Payables-------------------------------
        SELECT JH.PERIOD_NAME PERIODO,
                CC.CODE_COMBINATION_ID CCID,
                (CC.SEGMENT1 || '.' || CC.SEGMENT2 || '.' || CC.SEGMENT3 || '.' ||
                CC.SEGMENT4 || '.' || CC.SEGMENT5 ||
                decode(CC.SEGMENT6, null, '', '.' || CC.SEGMENT6) ||
                decode(CC.SEGMENT7, null, '', '.' || CC.SEGMENT7)) COMBINACION,
				LPAD(JL.JE_LINE_NUM, 9, '0') CORRELATIVO,
                JSV.USER_JE_SOURCE_NAME ORIGEN,
                JCV.USER_JE_CATEGORY_NAME TIPO_OPERACION, --TIPO DE OPERACION
                NVL(TE.SOURCE_ID_INT_1, JH.JE_HEADER_ID) ID_DOCUMENTO,
                NVL(TE.TRANSACTION_NUMBER, JH.PERIOD_NAME || ' | ' || JH.NAME) NUM_DOCUMENTO,
                SUP.VENDOR_NAME CLIEN_PROV,
				SUP.ATTRIBUTE9 TIPO_DOC_IDENT,               
                SUP.SEGMENT1 RUC_DNI,  
                NVL(AL.CURRENCY_CODE, JH.CURRENCY_CODE) DIVISA,
                JH.POSTING_ACCT_SEQ_VALUE NUMERO_ASIENTO,
                CC.SEGMENT1 COMPANIA,
                CC.SEGMENT2 CUENTA,
                CC.SEGMENT3 CENTRO_COSTO,
                CC.SEGMENT4 PROYECTO,
                CC.SEGMENT5 CLASIFICADOR,
                CC.SEGMENT6 META,
                CC.SEGMENT7 FUTURO,
                AL.ACCOUNTING_DATE FECHA_CONTABLE,
                TO_CHAR(AIA.INVOICE_DATE,'DD/MM/YYYY') FECHA_DOC,
                JH.NAME NOMBRE_ASIENTO,
                JL.DESCRIPTION DESCRIPCION_LINEA,
                AIA.DOC_SEQUENCE_VALUE NUMERO_VOUCHER,
                NVL(AIA.DESCRIPTION, JL.DESCRIPTION) DESCRIPCION,
                --POSITIVO EN EL HABER Y NEGATIVO DEBE
                DECODE(AL.GL_SL_LINK_ID,
                       NULL,
                       NVL(JL.ENTERED_DR, 0),
                       NVL(AL.ENTERED_DR, 0)) MONTO_DEBITO,
                DECODE(AL.GL_SL_LINK_ID,
                       NULL,
                       NVL(JL.ENTERED_CR, 0),
                       NVL(AL.ENTERED_CR, 0)) MONTO_CREDITO,
                --POSITIVO EN EL HABER Y NEGATIVO DEBE
                DECODE(AL.GL_SL_LINK_ID,
                       NULL,
                       NVL(JL.ACCOUNTED_DR, 0),
                       NVL(AL.ACCOUNTED_DR, 0)) MONTO_FUNCIONAL_DEBITO,
                DECODE(AL.GL_SL_LINK_ID,
                       NULL,
                       NVL(JL.ACCOUNTED_CR, 0),
                       NVL(AL.ACCOUNTED_CR, 0)) MONTO_FUNCIONAL_CREDITO,
                AIA.EXCHANGE_RATE TIPO_CAMBIO,
				JL.STATUS ESTADO
          FROM GL_JE_HEADERS            JH,
                GL_JE_CATEGORIES_VL      JCV,
                GL_JE_SOURCES_VL         JSV,
                GL_JE_LINES              JL,
                GL_IMPORT_REFERENCES     IR,
                XLA_AE_LINES             AL,
                XLA_AE_HEADERS           AH,
                XLA_TRANSACTION_ENTITIES TE,
                GL_CODE_COMBINATIONS     CC,
               /*AP_CHECKS_ALL           ACV,
                AP_INVOICE_PAYMENTS_ALL   AIP,*/
                AP_INVOICES_ALL           AIA,
                POZ_SUPPLIERS_V        SUP,
                xle_le_ou_ledger_v        xle,
                hr_all_organization_units hr
         WHERE 1 = 1
           AND JH.ACTUAL_FLAG = 'A'
           AND JH.STATUS = 'P'
           AND JH.JE_HEADER_ID = JL.JE_HEADER_ID
           and jh.ledger_id = xle.ledger_id
           and hr.organization_id = xle.operating_unit_id
           and aia.Invoice_currency_code =
               NVL(:MONEDA, aia.Invoice_currency_code)
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
           AND NVL(TE.SOURCE_ID_INT_1, JH.JE_HEADER_ID) = AIA.INVOICE_ID
           AND AIA.VENDOR_ID = SUP.VENDOR_ID
           --AND AIA.VENDOR_SITE_ID = SUP.VENDOR_SITE_ID
              --AND AIA.CANCELLED_DATE IS NULL
              /* AND ACV.CHECK_ID(+) = AIP.CHECK_ID
              AND AIP.INVOICE_ID(+) = AIA.INVOICE_ID
              AND AIP.REVERSAL_INV_PMT_ID IS NULL*/
           AND JH.JE_SOURCE = 'Payables'
           AND JCV.JE_CATEGORY_NAME IN ('Purchase Invoices')
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
        
        union all
        
		 ----------------------------------------Payables - Pagos-------------------    
        -----PAGO--------LIABILITY------------
        SELECT DISTINCT JH.PERIOD_NAME PERIODO,
                        CC.CODE_COMBINATION_ID CCID,
                        (CC.SEGMENT1 || '.' || CC.SEGMENT2 || '.' ||
                        CC.SEGMENT3 || '.' || CC.SEGMENT4 || '.' ||
                        CC.SEGMENT5 ||
                        decode(CC.SEGMENT6, null, '', '.' || CC.SEGMENT6) ||
                        decode(CC.SEGMENT7, null, '', '.' || CC.SEGMENT7)) COMBINACION,
						LPAD(AL.displayed_line_number, 9, '0') CORRELATIVO,
                        JSV.USER_JE_SOURCE_NAME ORIGEN,
                        JCV.USER_JE_CATEGORY_NAME TIPO_OPERACION, 
                        NVL(TE.SOURCE_ID_INT_1, JH.JE_HEADER_ID) ID_DOCUMENTO,
                        NVL(AIA.INVOICE_NUM,
                           JH.PERIOD_NAME || ' | ' || JH.NAME) NUM_DOCUMENTO, 
                        ACV.VENDOR_NAME CLIEN_PROV,
                        PSV.ATTRIBUTE9 TIPO_DOC_IDENT,               
                        PSV.SEGMENT1 RUC_DNI,  
                        NVL(AL.CURRENCY_CODE, JH.CURRENCY_CODE) DIVISA,
                        JH.POSTING_ACCT_SEQ_VALUE NUMERO_ASIENTO,
                        CC.SEGMENT1 COMPANIA,
                        CC.SEGMENT2 CUENTA,
                        CC.SEGMENT3 CENTRO_COSTO,
                        CC.SEGMENT4 PROYECTO,
                        CC.SEGMENT5 CLASIFICADOR,
                        CC.SEGMENT6 META,
                        CC.SEGMENT7 FUTURO,
                        JH.DEFAULT_EFFECTIVE_DATE FECHA_CONTABLE,
                        TO_CHAR(ACV.CHECK_DATE,'DD/MM/YYYY') FECHA_DOC,
                        JH.NAME NOMBRE_ASIENTO,
                        NULL DESCRIPCION_LINEA, --JL.DESCRIPTION DESCRIPCION_LINEA,
                        ACV.CHECK_NUMBER NUMERO_VOUCHER,
                        NVL(ACV.DESCRIPTION, /*JL.DESCRIPTION*/
                            (CASE
                              WHEN (SELECT COUNT(1)
                                      FROM AP_INVOICE_PAYMENTS_ALL AIP_C
                                     WHERE AIP_C.CHECK_ID = ACV.CHECK_ID) = 1 THEN
                               ACV.VENDOR_NAME || '-' ||
                               (SELECT AIA_C.INVOICE_NUM
                                  FROM AP_INVOICE_PAYMENTS_ALL AIP_C,
                                       AP_INVOICES_ALL         AIA_C
                                 WHERE AIP_C.CHECK_ID = ACV.CHECK_ID
                                   AND AIP_C.INVOICE_ID = AIA_C.INVOICE_ID)
                              WHEN (SELECT COUNT(1)
                                      FROM AP_INVOICE_PAYMENTS_ALL AIP_C
                                     WHERE AIP_C.CHECK_ID = ACV.CHECK_ID) = 0 THEN
                               'NO TIENE FACTURAS ASOCIADAS'
                              ELSE
                               'PAGOS VARIOS'
                            END)) DESCRIPCION,
                        DECODE(AL.GL_SL_LINK_ID,
                       NULL,
                       NVL(JL.ENTERED_DR, 0),
                       NVL(AL.ENTERED_DR, 0)) MONTO_DEBITO,
                DECODE(AL.GL_SL_LINK_ID,
                       NULL,
                       NVL(JL.ENTERED_CR, 0),
                       NVL(AL.ENTERED_CR, 0)) MONTO_CREDITO,
                --POSITIVO EN EL HABER Y NEGATIVO DEBE
                DECODE(AL.GL_SL_LINK_ID,
                       NULL,
                       NVL(JL.ACCOUNTED_DR, 0),
                       NVL(AL.ACCOUNTED_DR, 0)) MONTO_FUNCIONAL_DEBITO,
                DECODE(AL.GL_SL_LINK_ID,
                       NULL,
                       NVL(JL.ACCOUNTED_CR, 0),
                       NVL(AL.ACCOUNTED_CR, 0)) MONTO_FUNCIONAL_CREDITO,
                        ACV.EXCHANGE_RATE TIPO_CAMBIO,
						JL.STATUS ESTADO
          FROM GL_JE_HEADERS             JH,
               GL_JE_CATEGORIES_VL       JCV,
               GL_JE_SOURCES_VL          JSV,
               GL_JE_LINES               JL,
               GL_IMPORT_REFERENCES      IR,
               XLA_AE_LINES              AL,
               XLA_AE_HEADERS            AH,
               XLA_TRANSACTION_ENTITIES  TE,
               GL_CODE_COMBINATIONS      CC,
               AP_CHECKS_ALL             ACV,
			   POZ_SUPPLIERS_V PSV,
			   AP_PAYMENT_HISTORY_ALL APHA,
			   AP_PAYMENT_HIST_DISTS APHD,
               AP_INVOICE_PAYMENTS_ALL   AIP,
               AP_INVOICES_ALL           AIA,
               xle_le_ou_ledger_v        xle,
               hr_all_organization_units hr,
			   XLA_DISTRIBUTION_LINKS XDL
			   --xla_events xe
			   
         WHERE 1 = 1
		 
		   ----------------------------------------------------------------GL---------------------------------------------------------------------
           AND JH.ACTUAL_FLAG = 'A'
           AND JH.STATUS = 'P'
           AND JH.JE_HEADER_ID = JL.JE_HEADER_ID
           and jh.ledger_id = xle.ledger_id
           and hr.organization_id = xle.operating_unit_id
           and hr.name = :ORGNAME
           AND JL.CODE_COMBINATION_ID = CC.CODE_COMBINATION_ID
           AND NVL(AH.JE_CATEGORY_NAME, JH.JE_CATEGORY) = JCV.JE_CATEGORY_NAME
           AND JH.JE_SOURCE = JSV.JE_SOURCE_NAME
		   
           AND JL.JE_HEADER_ID = IR.JE_HEADER_ID(+)
           AND JL.JE_LINE_NUM = IR.JE_LINE_NUM(+)
		   ------------------------------------------------------------------XLA------------------------------------------------------------------
           AND IR.GL_SL_LINK_ID = AL.GL_SL_LINK_ID(+)
           AND IR.GL_SL_LINK_TABLE = AL.GL_SL_LINK_TABLE(+)
		   
		   AND AL.AE_HEADER_ID = XDL.AE_HEADER_ID
		   AND AL.AE_LINE_NUM = XDL.AE_LINE_NUM	
		   and xdl.source_distribution_type = 'AP_PMT_DIST'
		   
           AND AL.AE_HEADER_ID = AH.AE_HEADER_ID(+)
		   AND AL.APPLICATION_ID = AH.APPLICATION_ID
		   AND AH.EVENT_ID = XDL.EVENT_ID
		   
           AND AH.ENTITY_ID = TE.ENTITY_ID(+)
		   AND TE.application_id = 200 
		   
		   AND APHD.PAYMENT_HIST_DIST_ID = XDL.SOURCE_DISTRIBUTION_ID_NUM_1 
		   
		   AND APHD.PAYMENT_HISTORY_ID = APHA.PAYMENT_HISTORY_ID 
		   
		   AND TE.SOURCE_ID_INT_1 = ACV.CHECK_ID
		   
		  -- AND ACV.STATUS_LOOKUP_CODE <> 'VOIDED'
		   
		   AND ACV.VENDOR_NAME = PSV.VENDOR_NAME(+)
		   
		   AND ACV.CHECK_ID = APHA.CHECK_ID
		   
		   AND ((XDL.APPLIED_TO_SOURCE_ID_NUM_1 = AIA.INVOICE_ID) OR (XDL.APPLIED_TO_SOURCE_ID_NUM_1 = ACV.CHECK_ID))
		   
		   AND APHD.INVOICE_PAYMENT_ID = AIP.INVOICE_PAYMENT_ID
		   --AND APHD.INVOICE_ID = AIA.INVOICE_ID
		   --AND APHD.INVOICE_PAYMENT_ID = AIP.INVOICE_PAYMENT_ID
		   --AND ACV.CHECK_ID = AIP.CHECK_ID
           AND AIP.INVOICE_ID = AIA.INVOICE_ID
           --AND AIP.REVERSAL_INV_PMT_ID IS NULL
           --AND AIA.CANCELLED_DATE IS NULL
		   
		   
           AND JH.JE_SOURCE = 'Payables'
           AND JCV.USER_JE_CATEGORY_NAME IN ('Payments')
           AND NVL(AL.ACCOUNTING_CLASS_CODE, 0) IN ('LIABILITY')
           --AND AIA.ACCTS_PAY_CODE_COMBINATION_ID = CC.CODE_COMBINATION_ID
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
				   
				   
        
        UNION ALL
        ---------PAGO-------NO LIABLIITY---------------
        SELECT DISTINCT JH.PERIOD_NAME PERIODO,
                        CC.CODE_COMBINATION_ID CCID,
                        (CC.SEGMENT1 || '.' || CC.SEGMENT2 || '.' ||
                        CC.SEGMENT3 || '.' || CC.SEGMENT4 || '.' ||
                        CC.SEGMENT5 ||
                        decode(CC.SEGMENT6, null, '', '.' || CC.SEGMENT6) ||
                        decode(CC.SEGMENT7, null, '', '.' || CC.SEGMENT7)) COMBINACION,
						LPAD(AL.displayed_line_number, 9, '0') CORRELATIVO,
                        JSV.USER_JE_SOURCE_NAME ORIGEN,
                        JCV.USER_JE_CATEGORY_NAME TIPO_OPERACION, 
                        NVL(TE.SOURCE_ID_INT_1, JH.JE_HEADER_ID) ID_DOCUMENTO,
                        NVL(AIA.INVOICE_NUM,
                            JH.PERIOD_NAME || ' | ' || JH.NAME) NUM_DOCUMENTO, 
                        ACV.VENDOR_NAME CLIEN_PROV,
                        PSV.ATTRIBUTE9 TIPO_DOC_IDENT,               
                        PSV.SEGMENT1 RUC_DNI,  
                        NVL(AL.CURRENCY_CODE, JH.CURRENCY_CODE) DIVISA,
                        JH.POSTING_ACCT_SEQ_VALUE NUMERO_ASIENTO,
                        CC.SEGMENT1 COMPANIA,
                        CC.SEGMENT2 CUENTA,
                        CC.SEGMENT3 CENTRO_COSTO,
                        CC.SEGMENT4 PROYECTO,
                        CC.SEGMENT5 CLASIFICADOR,
                        CC.SEGMENT6 META,
                        CC.SEGMENT7 FUTURO,
                        JH.DEFAULT_EFFECTIVE_DATE FECHA_CONTABLE,
                        TO_CHAR(ACV.CHECK_DATE,'DD/MM/YYYY') FECHA_DOC,
                        JH.NAME NOMBRE_ASIENTO,
                        NULL DESCRIPCION_LINEA, --JL.DESCRIPTION DESCRIPCION_LINEA,
                        ACV.CHECK_NUMBER NUMERO_VOUCHER,
                        NVL(ACV.DESCRIPTION, /*JL.DESCRIPTION*/
                            (CASE
                              WHEN (SELECT COUNT(1)
                                      FROM AP_INVOICE_PAYMENTS_ALL AIP_C
                                     WHERE AIP_C.CHECK_ID = ACV.CHECK_ID) = 1 THEN
                               ACV.VENDOR_NAME || '-' ||
                               (SELECT AIA_C.INVOICE_NUM
                                  FROM AP_INVOICE_PAYMENTS_ALL AIP_C,
                                       AP_INVOICES_ALL         AIA_C
                                 WHERE AIP_C.CHECK_ID = ACV.CHECK_ID
                                   AND AIP_C.INVOICE_ID = AIA_C.INVOICE_ID)
                              WHEN (SELECT COUNT(1)
                                      FROM AP_INVOICE_PAYMENTS_ALL AIP_C
                                     WHERE AIP_C.CHECK_ID = ACV.CHECK_ID) = 0 THEN
                               'NO TIENE FACTURAS ASOCIADAS'
                              ELSE
                               'PAGOS VARIOS'
                            END)) DESCRIPCION,
                        DECODE(AL.GL_SL_LINK_ID,
                       NULL,
                       NVL(JL.ENTERED_DR, 0),
                       NVL(AL.ENTERED_DR, 0)) MONTO_DEBITO,
                DECODE(AL.GL_SL_LINK_ID,
                       NULL,
                       NVL(JL.ENTERED_CR, 0),
                       NVL(AL.ENTERED_CR, 0)) MONTO_CREDITO,
                --POSITIVO EN EL HABER Y NEGATIVO DEBE
                DECODE(AL.GL_SL_LINK_ID,
                       NULL,
                       NVL(JL.ACCOUNTED_DR, 0),
                       NVL(AL.ACCOUNTED_DR, 0)) MONTO_FUNCIONAL_DEBITO,
                DECODE(AL.GL_SL_LINK_ID,
                       NULL,
                       NVL(JL.ACCOUNTED_CR, 0),
                       NVL(AL.ACCOUNTED_CR, 0)) MONTO_FUNCIONAL_CREDITO,
                        ACV.EXCHANGE_RATE TIPO_CAMBIO,
						JL.STATUS ESTADO
						--LISTAGG(AIA.INVOICE_NUM, '; ') WITHIN GROUP (ORDER BY AIA.INVOICE_NUM) over (partition by JL.JE_LINE_NUM) FACTURAS
						--AIA.INVOICE_NUM FACTURA
						--JL.JE_LINE_NUM LINEA
          FROM GL_JE_HEADERS             JH,
               GL_JE_CATEGORIES_VL       JCV,
               GL_JE_SOURCES_VL          JSV,
               GL_JE_LINES               JL,
               GL_IMPORT_REFERENCES      IR,
               XLA_AE_LINES              AL,
               XLA_AE_HEADERS            AH,
               XLA_TRANSACTION_ENTITIES  TE,
               GL_CODE_COMBINATIONS      CC,
               AP_CHECKS_ALL             ACV,
			   POZ_SUPPLIERS_V PSV,
			   AP_PAYMENT_HISTORY_ALL APHA,
			   AP_PAYMENT_HIST_DISTS APHD,
               AP_INVOICE_PAYMENTS_ALL   AIP,
               AP_INVOICES_ALL           AIA,
               xle_le_ou_ledger_v        xle,
               hr_all_organization_units hr,
			   XLA_DISTRIBUTION_LINKS XDL
			   --xla_events xe
			   
         WHERE 1 = 1
		 
		   ----------------------------------------------------------------GL---------------------------------------------------------------------
           AND JH.ACTUAL_FLAG = 'A'
           AND JH.STATUS = 'P'
           AND JH.JE_HEADER_ID = JL.JE_HEADER_ID
           and jh.ledger_id = xle.ledger_id
           and hr.organization_id = xle.operating_unit_id
           and hr.name = :ORGNAME
           AND JL.CODE_COMBINATION_ID = CC.CODE_COMBINATION_ID
           AND NVL(AH.JE_CATEGORY_NAME, JH.JE_CATEGORY) = JCV.JE_CATEGORY_NAME
           AND JH.JE_SOURCE = JSV.JE_SOURCE_NAME
		   
           AND JL.JE_HEADER_ID = IR.JE_HEADER_ID(+)
           AND JL.JE_LINE_NUM = IR.JE_LINE_NUM(+)
		   ------------------------------------------------------------------XLA------------------------------------------------------------------
           AND IR.GL_SL_LINK_ID = AL.GL_SL_LINK_ID(+)
           AND IR.GL_SL_LINK_TABLE = AL.GL_SL_LINK_TABLE(+)
		   
		   AND AL.AE_HEADER_ID = XDL.AE_HEADER_ID
		   AND AL.AE_LINE_NUM = XDL.AE_LINE_NUM	
		   and xdl.source_distribution_type = 'AP_PMT_DIST'
		   
           AND AL.AE_HEADER_ID = AH.AE_HEADER_ID(+)
		   AND AL.APPLICATION_ID = AH.APPLICATION_ID
		   AND AH.EVENT_ID = XDL.EVENT_ID
		   
           AND AH.ENTITY_ID = TE.ENTITY_ID(+)
		   AND TE.application_id = 200 
		   
		   AND APHD.PAYMENT_HIST_DIST_ID = XDL.SOURCE_DISTRIBUTION_ID_NUM_1 
		   
		   AND APHD.PAYMENT_HISTORY_ID = APHA.PAYMENT_HISTORY_ID 
		   
		   AND TE.SOURCE_ID_INT_1 = ACV.CHECK_ID
		   
		  -- AND ACV.STATUS_LOOKUP_CODE <> 'VOIDED'
		   
		   AND ACV.VENDOR_NAME = PSV.VENDOR_NAME(+)
		   
		   AND ACV.CHECK_ID = APHA.CHECK_ID
		   
		   AND ((XDL.APPLIED_TO_SOURCE_ID_NUM_1 = AIA.INVOICE_ID) OR (XDL.APPLIED_TO_SOURCE_ID_NUM_1 = ACV.CHECK_ID))
		   AND APHD.INVOICE_PAYMENT_ID = AIP.INVOICE_PAYMENT_ID
		   --AND APHD.INVOICE_ID = AIA.INVOICE_ID
		   --AND APHD.INVOICE_PAYMENT_ID = AIP.INVOICE_PAYMENT_ID
		   --AND ACV.CHECK_ID = AIP.CHECK_ID
           AND AIP.INVOICE_ID = AIA.INVOICE_ID
           --AND AIP.REVERSAL_INV_PMT_ID IS NULL
           --AND AIA.CANCELLED_DATE IS NULL
		   
		   
           AND JH.JE_SOURCE = 'Payables'
           AND JCV.USER_JE_CATEGORY_NAME IN ('Payments')
           AND NVL(AL.ACCOUNTING_CLASS_CODE, 0) NOT IN ('LIABILITY')
           --AND AIA.ACCTS_PAY_CODE_COMBINATION_ID = CC.CODE_COMBINATION_ID
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
				   
		
		
		UNION ALL
        
        ----------------------------------------RECEIVABLES - FACTURAS DE VENTAS-----------------------------------------
        
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

          FROM GL_JE_HEADERS             JH,
               GL_JE_CATEGORIES_VL       JCV,
               GL_JE_SOURCES_VL          JSV,
               GL_JE_LINES               JL,
               GL_IMPORT_REFERENCES      IR,
               XLA_AE_LINES              AL,
               XLA_AE_HEADERS            AH,
               XLA_TRANSACTION_ENTITIES  TE,
               GL_CODE_COMBINATIONS      CC,
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
           AND NVL(TE.SOURCE_ID_INT_1, JH.JE_HEADER_ID) = CTA.CUSTOMER_TRX_ID
           AND CTA.BILL_TO_CUSTOMER_ID = HCA.CUST_ACCOUNT_ID
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
        
        UNION ALL
        ---------------------------------------------------------RECEIVABLES - RECIBOS-------------------------------------------        
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
               TO_CHAR(ACR.RECEIPT_DATE,'DD/MM/YYYY') FECHA_DOC,
               JH.NAME NOMBRE_ASIENTO,
               JL.DESCRIPTION DESCRIPCION_LINEA,
               ACR.DOC_SEQUENCE_VALUE NUMERO_VOUCHER,
               NVL(ACR.COMMENTS, /*JL.DESCRIPTION*/
                   (CASE
                     WHEN (SELECT COUNT(1)
                             FROM AR_RECEIVABLE_APPLICATIONS_ALL ARA
                            WHERE ARA.CASH_RECEIPT_ID = ACR.CASH_RECEIPT_ID
                              AND ARA.DISPLAY = 'Y') = 1 THEN
                      HP.PARTY_NAME || '-' ||
                      (SELECT CTA.TRX_NUMBER
                         FROM AR_RECEIVABLE_APPLICATIONS_ALL ARA,
                              RA_CUSTOMER_TRX_ALL            CTA
                        WHERE ARA.CASH_RECEIPT_ID = ACR.CASH_RECEIPT_ID
                          AND ARA.DISPLAY = 'Y'
                          AND CTA.CUSTOMER_TRX_ID = ARA.APPLIED_CUSTOMER_TRX_ID)
                     WHEN (SELECT COUNT(1)
                             FROM AR_RECEIVABLE_APPLICATIONS_ALL ARA
                            WHERE ARA.CASH_RECEIPT_ID = ACR.CASH_RECEIPT_ID
                              AND ARA.DISPLAY = 'Y') = 0 THEN
                      ''
                     ELSE
                      'COBROS VARIOS'
                   END)) DESCRIPCION,
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
               ACR.EXCHANGE_RATE TIPO_CAMBIO,
			   JL.STATUS ESTADO
          FROM GL_JE_HEADERS             JH,
               GL_JE_CATEGORIES_VL       JCV,
               GL_JE_SOURCES_VL          JSV,
               GL_JE_LINES               JL,
               GL_IMPORT_REFERENCES      IR,
               XLA_AE_LINES              AL,
               XLA_AE_HEADERS            AH,
               XLA_TRANSACTION_ENTITIES  TE,
               GL_CODE_COMBINATIONS      CC,
               AR_CASH_RECEIPTS_ALL      ACR,
               HZ_CUST_ACCOUNTS          HCA,
               HZ_PARTIES                HP,
			   HZ_ORGANIZATION_PROFILES  HOP,
               HZ_PERSON_PROFILES        HPP,
               xle_le_ou_ledger_v        xle,
               hr_all_organization_units hr
         WHERE 1 = 1
           AND JH.ACTUAL_FLAG = 'A'
           AND JH.STATUS = 'P'
           and NVL(AL.CURRENCY_CODE, JH.CURRENCY_CODE) =
               NVL(:MONEDA, NVL(AL.CURRENCY_CODE, JH.CURRENCY_CODE))
           AND JH.JE_HEADER_ID = JL.JE_HEADER_ID
           and jh.ledger_id = xle.ledger_id
           and hr.organization_id = xle.operating_unit_id
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
           AND NVL(TE.SOURCE_ID_INT_1, JH.JE_HEADER_ID) = ACR.CASH_RECEIPT_ID
           AND ACR.PAY_FROM_CUSTOMER = HCA.CUST_ACCOUNT_ID(+)
           AND HCA.PARTY_ID = HP.PARTY_ID(+)
		   AND HOP.PARTY_ID(+) = HP.PARTY_ID
           AND HPP.PARTY_ID(+) = HP.PARTY_ID
           AND JH.JE_SOURCE = 'Receivables'
           AND JCV.JE_CATEGORY_NAME IN ('Receipts', 'Misc Receipts')
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
        
        union all
        ---------------------------------------------------------Receivables - Ajuste-------------------------------------------          
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
			   NVL(hop.attribute1, hpp.attribute1) TIPO_DOC_IDENT, 
               NVL(hop.attribute2, hpp.attribute2) RUC_DNI,   
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
               TO_CHAR(ADJ.APPLY_DATE,'DD/MM/YYYY') FECHA_DOC,
               JH.NAME NOMBRE_ASIENTO,
               JL.DESCRIPTION DESCRIPCION_LINEA,
               ADJ.DOC_SEQUENCE_VALUE NUMERO_VOUCHER,
               NVL(ADJ.COMMENTS, JL.DESCRIPTION) DESCRIPCION,
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
          FROM GL_JE_HEADERS             JH,
               GL_JE_CATEGORIES_VL       JCV,
               GL_JE_SOURCES_VL          JSV,
               GL_JE_LINES               JL,
               GL_IMPORT_REFERENCES      IR,
               XLA_AE_LINES              AL,
               XLA_AE_HEADERS            AH,
               XLA_TRANSACTION_ENTITIES  TE,
               GL_CODE_COMBINATIONS      CC,
               AR_ADJUSTMENTS_ALL        ADJ,
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
           and hr.name = :ORGNAME
           and NVL(AL.CURRENCY_CODE, JH.CURRENCY_CODE) =
               NVL(:MONEDA, NVL(AL.CURRENCY_CODE, JH.CURRENCY_CODE))
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
           AND NVL(TE.SOURCE_ID_INT_1, JH.JE_HEADER_ID) = ADJ.ADJUSTMENT_ID
           AND ADJ.CUSTOMER_TRX_ID = CTA.CUSTOMER_TRX_ID
           AND CTA.BILL_TO_CUSTOMER_ID = HCA.CUST_ACCOUNT_ID
           AND HCA.PARTY_ID = HP.PARTY_ID
		   AND HOP.PARTY_ID(+) = HP.PARTY_ID
           AND HPP.PARTY_ID(+) = HP.PARTY_ID
           AND JH.JE_SOURCE = 'Receivables'
           AND JCV.JE_CATEGORY_NAME = 'Adjustment'
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
		
		
		
        
        union all
        
        ---------------------------------------------------------Otros-------------------------------------------          
        SELECT JH.PERIOD_NAME PERIODO,
               CC.CODE_COMBINATION_ID CCID,
               (CC.SEGMENT1 || '.' || CC.SEGMENT2 || '.' || CC.SEGMENT3 || '.' ||
               CC.SEGMENT4 || '.' || CC.SEGMENT5 ||
               decode(CC.SEGMENT6, null, '', '.' || CC.SEGMENT6) ||
               decode(CC.SEGMENT7, null, '', '.' || CC.SEGMENT7)) COMBINACION,
			   'M' || LPAD(JL.JE_LINE_NUM, 9, '0') CORRELATIVO,
               JSV.USER_JE_SOURCE_NAME ORIGEN,
               JCV.USER_JE_CATEGORY_NAME TIPO_OPERACION,
               NVL(TE.SOURCE_ID_INT_1, JH.JE_HEADER_ID) ID_DOCUMENTO,
               JL.ATTRIBUTE3 NUM_DOCUMENTO, 
               JL.ATTRIBUTE1 CLIEN_PROV, 
			   '' TIPO_DOC_IDENT, 
               JL.ATTRIBUTE4 RUC_DNI, 
               NVL(AL.CURRENCY_CODE, JH.CURRENCY_CODE) DIVISA,
               
               JH.POSTING_ACCT_SEQ_VALUE NUMERO_ASIENTO,
               CC.SEGMENT1               COMPANIA,
               CC.SEGMENT2               CUENTA,
               CC.SEGMENT3               CENTRO_COSTO,
               CC.SEGMENT4               PROYECTO,
               CC.SEGMENT5               CLASIFICADOR,
               CC.SEGMENT6               META,
               CC.SEGMENT7               FUTURO,
               JH.DEFAULT_EFFECTIVE_DATE FECHA_CONTABLE,
               JL.ATTRIBUTE2 FECHA_DOC,
               JH.NAME                   NOMBRE_ASIENTO,
               JL.DESCRIPTION            DESCRIPCION_LINEA,
               NULL                      NUMERO_VOUCHER,
               JL.DESCRIPTION            DESCRIPCION,
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
               AL.CURRENCY_CONVERSION_RATE TIPO_CAMBIO,
			   JL.STATUS ESTADO
          FROM GL_JE_HEADERS            JH,
               GL_JE_CATEGORIES_VL      JCV,
               GL_JE_SOURCES_VL         JSV,
               GL_JE_LINES              JL,
               GL_IMPORT_REFERENCES     IR,
               XLA_AE_LINES             AL,
               XLA_AE_HEADERS           AH,
               XLA_TRANSACTION_ENTITIES TE,
               GL_CODE_COMBINATIONS     CC,
               --Comentado por dsernaque
               /* POZ_SUPPLIERS_V          PV,
               AP_OFR_SUPPLIERS_V       SUP*/
               xle_le_ou_ledger_v        xle,
               hr_all_organization_units hr
         WHERE 1 = 1
           AND JH.ACTUAL_FLAG = 'A'
           and NVL(AL.CURRENCY_CODE, JH.CURRENCY_CODE) =
               NVL(:MONEDA, NVL(AL.CURRENCY_CODE, JH.CURRENCY_CODE))
           AND JH.STATUS = 'P'
           AND JH.JE_HEADER_ID = JL.JE_HEADER_ID
           and jh.ledger_id = xle.ledger_id
           and hr.organization_id = xle.operating_unit_id
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
              --AND JL.ATTRIBUTE1 = PV.SEGMENT1(+) --comentado por dsernaque
           AND ((JH.JE_SOURCE NOT IN ('Receivables', 'Payables')) 
		        OR (JH.REVERSED_JE_HEADER_ID IS NOT NULL) ) --GN080720
              --Consultar su uso con Eduardo
              --and nvl(jl.CONTEXT2, 0) = '0' --EVV19032016 Todos las lÃ­neas de mÃ³dulos y webadi sin modificar en GL
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
        
     
        ) T,
        
      (SELECT FVP_T.FLEX_VALUE  CUENTA,
               FVP_T.DESCRIPTION DESCRIPTION_CTA,
               FVP_T.FLEX_VALUE
          FROM FND_FLEX_VALUES_VL   FVP_T,
               FND_FLEX_VALUE_SETS  FVT_T,
               GL_CODE_COMBINATIONS CC
         WHERE 1 = 1
           AND FVT_T.FLEX_VALUE_SET_ID = FVP_T.FLEX_VALUE_SET_ID
           AND FVT_T.FLEX_VALUE_SET_NAME =
               ((SELECT D.FLEX_VALUE_SET_NAME
                   FROM FND_SEGMENT_ATTRIBUTE_VALUES A
                   JOIN FND_ID_FLEX_SEGMENTS_VL B
                     ON B.ID_FLEX_NUM = A.ID_FLEX_NUM
                   JOIN GL_LEDGERS C
                     ON A.ID_FLEX_NUM = C.CHART_OF_ACCOUNTS_ID
                   JOIN FND_FLEX_VALUE_SETS D
                     ON D.FLEX_VALUE_SET_ID = B.FLEX_VALUE_SET_ID
                  WHERE A.SEGMENT_ATTRIBUTE_TYPE = 'GL_ACCOUNT'
                    AND A.ATTRIBUTE_VALUE = 'Y'
                    AND A.ID_FLEX_CODE = 'GL#'
                    AND B.APPLICATION_COLUMN_NAME = A.APPLICATION_COLUMN_NAME
                    AND B.ID_FLEX_CODE = A.ID_FLEX_CODE
                    AND B.SEGMENT_NAME = 'Cuenta Contable'
                  GROUP BY D.FLEX_VALUE_SET_NAME))
           AND CC.SEGMENT2 = FVP_T.FLEX_VALUE
         GROUP BY FVP_T.FLEX_VALUE, FVP_T.DESCRIPTION
         ORDER BY FVP_T.FLEX_VALUE) T_CTAS
 WHERE T_CTAS.CUENTA = T.CUENTA
          ) A
          
        ORDER BY A.CUENTA,
          --A.NUM_DOCUMENTO,
          TO_DATE(A.FECHA_CONTABLE,'DD/MM/YYYY'),
          A.NUMERO_ASIENTO