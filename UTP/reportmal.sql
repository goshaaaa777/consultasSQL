select v1.*,
       NVL(v1."ASC", 0) + NVL(v1."AOC", 0) + NVL(v1."AFNC", 0) +
       NVL(v1."AOT", 0) + NVL(v1."PSC", 0) + NVL(v1."POC", 0) +
       NVL(v1."PFNC", 0) + NVL(v1."POT", 0) as TC,
       NVL(v1."AFC", 0) + NVL(v1."ATOD", 0) + NVL(v1."AINV", 0) + NVL(v1."PFC", 0) +
       NVL(v1."PTOD", 0) + NVL(v1."PINV", 0) as TOTAL_OBL,
       (NVL(v1."ASC", 0) + NVL(v1."AOC", 0) + NVL(v1."AFNC", 0) +
       NVL(v1."AOT", 0) + NVL(v1."PSC", 0) + NVL(v1."POC", 0) +
       NVL(v1."PFNC", 0) + NVL(v1."POT", 0)) +
       (NVL(v1."AFC", 0) + NVL(v1."ATOD", 0) + NVL(v1."AINV", 0) + NVL(v1."PFC", 0) +
       NVL(v1."PTOD", 0) + NVL(v1."PINV", 0)) as SCO,
       NVL(v1."TB", 0) -
       (NVL(v1."ASC", 0) + NVL(v1."AOC", 0) + NVL(v1."AFNC", 0) +
        NVL(v1."AOT", 0) + NVL(v1."PSC", 0) + NVL(v1."POC", 0) +
        NVL(v1."PFNC", 0) + NVL(v1."POT", 0)) -
       (NVL(v1."AFC", 0) + NVL(v1."ATOD", 0) + NVL(v1."AINV", 0) + NVL(v1."PFC", 0) +
        NVL(v1."PTOD", 0) + NVL(v1."PINV", 0)) as FAVAM, --[TOTAL BUDGET - (TOTAL COMPROMISOS + TOTAL OBLIGACIONES)]
       --0 as FAVPE-- [(Funds Available Amount / Total Budget)*100]
       ((NVL(v1."TB", 0) -
       (NVL(v1."ASC", 0) + NVL(v1."AOC", 0) + NVL(v1."AFNC", 0) +
       NVL(v1."AOT", 0) + NVL(v1."PSC", 0) + NVL(v1."POC", 0) +
       NVL(v1."PFNC", 0) + NVL(v1."POT", 0)) -
       (NVL(v1."AFC", 0) + NVL(v1."ATOD", 0) + NVL(v1."AINV", 0) + NVL(v1."PFC", 0) +
       NVL(v1."PTOD", 0) + NVL(v1."PINV", 0))) / NVL(v1."TB", 1)) * 100 as FAVPE -- [(Funds Available Amount / Total Budget)*100]

  from (WITH TS_RATES AS (SELECT PCT_1.CMT_DISTRIBUTION_ID,
                                 GDR.CONVERSION_RATE,
                                 PTDT_1.DESCRIPTION
                            FROM PJC_COMMITMENT_TXNS PCT_1
                            JOIN PJF_TXN_DOCUMENT_TL PTDT_1
                              ON (PCT_1.DOCUMENT_ID = PTDT_1.DOCUMENT_ID AND
                                 PTDT_1.LANGUAGE = 'US')
                            JOIN AP_INVOICE_DISTRIBUTIONS_ALL AIDA
                              ON AIDA.INVOICE_DISTRIBUTION_ID =
                                 PCT_1.CMT_DISTRIBUTION_ID
                             AND PTDT_1.DESCRIPTION =
                                 'Supplier Invoice Commitment.'
                            JOIN AP_INVOICES_ALL AIA
                              ON AIA.INVOICE_ID = AIDA.INVOICE_ID
                            JOIN GL_DAILY_RATES GDR
                              ON GDR.FROM_CURRENCY = 'USD'
                             AND GDR.TO_CURRENCY = 'COP'
                             AND GDR.CONVERSION_TYPE = '300000004035333'
                             AND TRUNC(AIA.INVOICE_DATE) =
                                 TRUNC(GDR.CONVERSION_DATE)
                          
                          UNION ALL
                          
                          SELECT PCT_1.CMT_DISTRIBUTION_ID,
                                 GDR.CONVERSION_RATE,
                                 PTDT_1.DESCRIPTION
                            FROM PJC_COMMITMENT_TXNS PCT_1
                            JOIN PJF_TXN_DOCUMENT_TL PTDT_1
                              ON (PCT_1.DOCUMENT_ID = PTDT_1.DOCUMENT_ID AND
                                 PTDT_1.LANGUAGE = 'US')
                            JOIN POR_REQ_DISTRIBUTIONS_ALL PRDA
                              ON PRDA.DISTRIBUTION_ID =
                                 PCT_1.CMT_DISTRIBUTION_ID
                             AND PTDT_1.DESCRIPTION = 'Purchase Requisition.'
                            JOIN POR_REQUISITION_LINES_ALL PRLA
                              ON PRLA.REQUISITION_LINE_ID =
                                 PRDA.REQUISITION_LINE_ID
                            JOIN POR_REQUISITION_HEADERS_ALL PRHA
                              ON PRHA.REQUISITION_HEADER_ID =
                                 PRLA.REQUISITION_HEADER_ID
                            JOIN GL_DAILY_RATES GDR
                              ON GDR.FROM_CURRENCY = 'USD'
                             AND GDR.TO_CURRENCY = 'COP'
                             AND GDR.CONVERSION_TYPE = '300000004035333'
                             AND TRUNC(PRHA.CREATION_DATE) =
                                 TRUNC(GDR.CONVERSION_DATE)
                          
                          UNION ALL
                          
                          SELECT PCT_1.CMT_DISTRIBUTION_ID,
                                 GDR.CONVERSION_RATE,
                                 PTDT_1.DESCRIPTION
                            FROM PJC_COMMITMENT_TXNS PCT_1
                            JOIN PJF_TXN_DOCUMENT_TL PTDT_1
                              ON (PCT_1.DOCUMENT_ID = PTDT_1.DOCUMENT_ID AND
                                 PTDT_1.LANGUAGE = 'US')
                            JOIN PO_DISTRIBUTIONS_ALL PDA
                              ON PDA.PO_DISTRIBUTION_ID =
                                 PCT_1.CMT_DISTRIBUTION_ID
                             AND PTDT_1.DESCRIPTION = 'Purchase Order.'
                            JOIN PO_LINES_ALL PLA
                              ON PLA.PO_LINE_ID = PDA.PO_LINE_ID
                            JOIN PO_HEADERS_ALL PHA
                              ON PHA.PO_HEADER_ID = PLA.PO_HEADER_ID
                            JOIN GL_DAILY_RATES GDR
                              ON GDR.FROM_CURRENCY = 'USD'
                             AND GDR.TO_CURRENCY = 'COP'
                             AND GDR.CONVERSION_TYPE = '300000004035333'
                             AND TRUNC(PHA.CREATION_DATE) =
                                 TRUNC(GDR.CONVERSION_DATE)
                          
                          UNION ALL
                          
                          SELECT PCT_1.CMT_DISTRIBUTION_ID,
                                 GDR.CONVERSION_RATE,
                                 PTDT_1.DESCRIPTION
                            FROM PJC_COMMITMENT_TXNS PCT_1
                            JOIN PJF_TXN_DOCUMENT_TL PTDT_1
                              ON (PCT_1.DOCUMENT_ID = PTDT_1.DOCUMENT_ID AND
                                 PTDT_1.LANGUAGE = 'US')
                            JOIN INV_TRANSFER_ORDER_DISTRIBS ITOR
                              ON ITOR.DISTRIBUTION_ID =
                                 PCT_1.CMT_DISTRIBUTION_ID
                             AND PTDT_1.DESCRIPTION =
                                 'Specifies that the imported transactions are for Transfer Order Commitment from Oracle Cost Management.'
                            JOIN INV_TRANSFER_ORDER_LINES ITOL
                              ON ITOL.LINE_ID = ITOR.LINE_ID
                            JOIN INV_TRANSFER_ORDER_HEADERS ITOH
                              ON ITOH.HEADER_ID = ITOL.HEADER_ID
                            JOIN GL_DAILY_RATES GDR
                              ON GDR.FROM_CURRENCY = 'USD'
                             AND GDR.TO_CURRENCY = 'COP'
                             AND GDR.CONVERSION_TYPE = '300000004035333'
                             AND TRUNC(ITOH.CREATION_DATE) =
                                 TRUNC(GDR.CONVERSION_DATE)
                           GROUP BY PCT_1.CMT_DISTRIBUTION_ID,
                                    GDR.CONVERSION_RATE,
                                    PTDT_1.DESCRIPTION), TS_COMPROMISOS_PERIODOS AS (SELECT PTDT_1.DESCRIPTION AS TIPO_DOCUMENTO,
                                                                                            (SUM(PCT_1.PRJ_RAW_COST) *
                                                                                            NVL(TR.CONVERSION_RATE,
                                                                                                 1)) AS MONTO,
                                                                                            PCT_1.PROJECT_ID,
                                                                                            PCT_1.TASK_ID,
                                                                                            PCT_1.EXPENDITURE_TYPE_ID,
                                                                                            PCT_1.PA_PERIOD AS PERIODO,
                                                                                            PCT_1.PRJ_CURRENCY_CODE AS MONEDA,
                                                                                            --PA_PERIOD as Provider_Project_Accounting_Period
                                                                                            --PPEV_1.NAME as TAREA
                                                                                            PPET.NAME           as TAREA,
                                                                                            PCT_1.CMT_HEADER_ID
                                                                                       from PJC_COMMITMENT_TXNS PCT_1
                                                                                      INNER JOIN PJF_EXP_TYPES_VL PETV_1
                                                                                         ON PCT_1.EXPENDITURE_TYPE_ID =
                                                                                            PETV_1.EXPENDITURE_TYPE_ID
                                                                                      INNER JOIN PJF_TXN_DOCUMENT_TL PTDT_1
                                                                                         ON (PCT_1.DOCUMENT_ID =
                                                                                            PTDT_1.DOCUMENT_ID AND
                                                                                            PTDT_1.LANGUAGE = 'US')
                                                                                     --NUEVO FILTRO PARA MOSTRAR MONTOS (ORDENES DE)
                                                                                      INNER JOIN PJF_PROJ_ELEMENTS_TL PPET
                                                                                         ON (PPET.PROJ_ELEMENT_ID =
                                                                                            PCT_1.TASK_ID AND
                                                                                            PPET.LANGUAGE = 'E')
                                                                                       LEFT JOIN TS_RATES TR
                                                                                         ON TR.CMT_DISTRIBUTION_ID =
                                                                                            PCT_1.CMT_DISTRIBUTION_ID
                                                                                        AND TR.DESCRIPTION =
                                                                                            PTDT_1.DESCRIPTION
                                                                                        AND :P_ORIGENMONEDA =
                                                                                            'COP'
                                                                                     ---
                                                                                     --INNER JOIN PJF_PROJ_ELEMENTS_VL PPEV_1
                                                                                     --ON PCT_1.PROJECT_ID = PPEV_1.PROJECT_ID
                                                                                     --AND PPEV_1.OBJECT_TYPE = 'PJF_TASKS'
                                                                                      WHERE 1 = 1
                                                                                     --AND PCT_1.PROJECT_ID = PPAV.PROJECT_ID
                                                                                     --AND PCT_1.CMT_NUMBER = '11-ORD-0007-2022'
                                                                                     --AND CONDICION DE PERIODO ANTERIOR 
                                                                                     --AND PTDT_1.DESCRIPTION = 'Purchase Order' -- Solicitud de compra
                                                                                      GROUP BY PCT_1.CMT_HEADER_ID,
                                                                                               PTDT_1.DESCRIPTION,
                                                                                               PCT_1.PROJECT_ID,
                                                                                               PCT_1.TASK_ID,
                                                                                               PCT_1.EXPENDITURE_TYPE_ID,
                                                                                               PCT_1.PA_PERIOD,
                                                                                               PCT_1.PRJ_CURRENCY_CODE,
                                                                                               --PPEV_1.NAME
                                                                                               PPET.NAME,
                                                                                               TR.CONVERSION_RATE
                                                                                     --PCT.CMT_NUMBER,
                                                                                     --PTDT.DESCRIPTION,
                                                                                     --PA_PERIOD
                                                                                     ),
       
       TS_OBLIGACIONES_PERIODOS AS (SELECT pcdl.project_id AS proyecto,
                                           pcdl.TASK_ID,
                                           pei.EXPENDITURE_TYPE_ID,
                                           ptd.document_name AS documento,
                                           pcdl.prvdr_gl_period_name as periodo,
                                           SUM(pcdl.PROJECT_RAW_COST) monto
                                    --SUM(pcdl.projfunc_raw_cost) monto
                                    --SUM(pcdl.DENOM_RAW_COST) monto
                                      FROM pjc_cost_dist_lines_all pcdl
                                     INNER JOIN pjc_exp_items_all pei
                                        ON pcdl.expenditure_item_id =
                                           pei.expenditure_item_id
                                     INNER JOIN pjf_txn_document_tl ptd
                                        ON pei.document_id = ptd.document_id
                                       AND ptd.language = 'US'
                                    
                                     GROUP BY pcdl.project_id,
                                              pcdl.TASK_ID,
                                              pei.EXPENDITURE_TYPE_ID,
                                              ptd.document_name,
                                              pcdl.prvdr_gl_period_name),
       
       TS_PROJECTO_TAREA_RECURSO AS (SELECT A.PROJECT_ID,
                                            A.TASK_ID,
                                            substr(trim(A.ALIAS), 1, 62) ALIAS
                                     --A.PROJECT_ID, substr(trim(A.ALIAS),1,62) ALIAS, SUM(A.RAW_COST) RAW_COST
                                       FROM PJO_BASE_PLAN_BY_PA_PERIOD_V A
                                      INNER JOIN PJO_PLAN_VERSIONS_VL B
                                         ON A.PROJECT_ID = B.PROJECT_ID
                                        AND A.PLAN_VERSION_ID =
                                            B.PLAN_VERSION_ID
                                        AND A.APPROVED_COST_PLAN_TYPE_FLAG = 'Y'
                                        AND A.APPROVED_REV_PLAN_TYPE_FLAG = 'Y'
                                        AND B.PLAN_STATUS_CODE = 'B'
                                        AND B.CURRENT_PLAN_STATUS_FLAG = 'Y'
                                     
                                      INNER JOIN PJF_PROJECTS_ALL_B C
                                         ON A.PROJECT_ID = C.PROJECT_ID
                                        AND A.ORG_ID = C.ORG_ID
                                     --AND substr(trim(A.ALIAS),1,62) LIKE '504704%'
                                      GROUP BY A.PROJECT_ID,
                                               A.TASK_ID,
                                               A.ALIAS)
       
         Select HOU.NAME AS COMPANIA,
                TO_CHAR(PPAV.START_DATE, 'MM') as "PERIODO",
                PPAV.SEGMENT1 as "Numero Proyecto",
                TO_CHAR(PPAV.START_DATE, 'DD/MM/YYYY') as "Fecha Inicio",
                TO_CHAR(PPAV.COMPLETION_DATE, 'DD/MM/YYYY') as "Fecha Finalizacion",
                PPTV.PROJECT_TYPE as "Tipo de Proyecto",
                PPAV.PROJECT_STATUS_CODE as "Estado",
                PPAV.ATTRIBUTE1 as "Centro de Costo",
                PPAV.ATTRIBUTE2 as "Nro. AFE",
                PPEV.ELEMENT_NUMBER as "Tarea",
                --AÑADIR CAMPO NOMBRE DE TAREA
                PPEV.NAME       as "Nombre_Tarea",
                PPAV.ATTRIBUTE3 as "BILL CODE",
                PPAV.ATTRIBUTE5 as "Proyecto",
                PPAV.ATTRIBUTE6 as "Área",
                PPAV.ATTRIBUTE7 as "Etapa",
                PCCV.CLASS_CODE as "Línea de Negocio",
                PPAV.ATTRIBUTE8 as "Bloque",
                TSPTR.ALIAS     AS "Recursos",
                
                --SUM(PPVV.TOTAL_PC_RAW_COST)
                
                /*(
                 SELECT SUM(total_pc_raw_cost)
                   FROM pjo_plan_versions_b 
                  WHERE project_id = ppav.project_id
                    AND current_plan_status_flag = 'Y' 
                    AND plan_status_code = 'B'
                )
                 as "TB",   ---> REVISAR
                 */
                (
                 
                 SELECT SUM(A.RAW_COST) RAW_COST
                 --SELECT A.PROJECT_ID, substr(trim(A.ALIAS),1,62) ALIAS, SUM(A.RAW_COST) RAW_COST 
                   FROM PJO_BASE_PLAN_BY_PA_PERIOD_V A,
                         PJO_PLAN_VERSIONS_VL         B,
                         PJF_PROJECTS_ALL_B           C
                  WHERE 1 = 1
                    AND a.project_id = ppav.project_id
                    AND substr(trim(A.ALIAS), 1, 62) = TSPTR.ALIAS
                       --PETV.EXPENDITURE_TYPE_NAME
                       --AND A.PROJECT_ID = 300000006398194
                    AND A.PROJECT_ID = B.PROJECT_ID
                    AND A.PLAN_VERSION_ID = B.PLAN_VERSION_ID
                    AND A.PROJECT_ID = C.PROJECT_ID
                    AND A.ORG_ID = C.ORG_ID
                    AND B.PLAN_STATUS_CODE = 'B'
                    AND B.CURRENT_PLAN_STATUS_FLAG = 'Y'
                    AND A.APPROVED_COST_PLAN_TYPE_FLAG = 'Y'
                    AND A.APPROVED_REV_PLAN_TYPE_FLAG = 'Y'
                  GROUP BY A.PROJECT_ID, A.ALIAS
                 
                 ) as "TB", --"TOTAL BUDGET"
                -- PCT.DENOM_CURRENCY_CODE
                PPAV.PROJECT_CURRENCY_CODE as "Origen Moneda", --->
                ------COMPROMISOS PERIODO ANTERIOR--------
                (SELECT SUM(MONTO)
                   FROM TS_COMPROMISOS_PERIODOS TSCOM_SC
                  WHERE TSCOM_SC.TIPO_DOCUMENTO = 'Purchase Requisition.'
                    AND TSCOM_SC.PROJECT_ID = PPAV.PROJECT_ID
                    AND TSCOM_SC.TASK_ID = PPEV.DENORM_TOP_ELEMENT_ID
                    AND TSCOM_SC.EXPENDITURE_TYPE_ID =
                        PETV.EXPENDITURE_TYPE_ID
                    AND TSCOM_SC.PERIODO IN (SELECT GLP.PERIOD_NAME
                                               FROM GL_PERIODS GLP
                                              WHERE EXISTS (SELECT 1
                                                       FROM GL_PERIODS GP
                                                      WHERE GP.PERIOD_SET_NAME =
                                                            'CNC_CALENDARIO'
                                                        AND UPPER(GP.PERIOD_NAME) =
                                                            UPPER(:P_PERIODO_INI)
                                                        AND GP.PERIOD_SET_NAME =
                                                            GLP.PERIOD_SET_NAME
                                                        AND GLP.END_DATE BETWEEN
                                                            TO_DATE('01/01/20' ||
                                                                    TO_CHAR(TO_NUMBER(SUBSTR(:P_PERIODO_INI,
                                                                                             5)) - 1),
                                                                    'DD/MM/YYYY') AND
                                                            GP.YEAR_START_DATE - 1
                                                     --AND GLP.END_DATE BETWEEN GP.YEAR_START_DATE AND GP.START_DATE -1
                                                     ))
                    AND TSCOM_SC.MONEDA = PPAV.PROJECT_CURRENCY_CODE
                       
                    AND NOT EXISTS
                  (SELECT 1
                           FROM POR_REQUISITION_HEADERS_ALL LRHA
                          WHERE LRHA.FUNDS_STATUS IN
                                ('NOT_RESERVED', 'FAILED', 'RESERVED_PARTIAL')
                            AND TSCOM_SC.CMT_HEADER_ID =
                                LRHA.REQUISITION_HEADER_ID)) as "ASC", --"CPA SOLICITUDES DE COMPRA"
                (SELECT SUM(MONTO)
                   FROM TS_COMPROMISOS_PERIODOS TSCOM_SC
                  WHERE TSCOM_SC.TIPO_DOCUMENTO = 'Purchase Order.'
                    AND TSCOM_SC.PROJECT_ID = PPAV.PROJECT_ID
                    AND TSCOM_SC.TASK_ID = PPEV.DENORM_TOP_ELEMENT_ID
                    AND TSCOM_SC.EXPENDITURE_TYPE_ID =
                        PETV.EXPENDITURE_TYPE_ID
                    AND TSCOM_SC.PERIODO IN (SELECT GLP.PERIOD_NAME
                                               FROM GL_PERIODS GLP
                                              WHERE EXISTS (SELECT 1
                                                       FROM GL_PERIODS GP
                                                      WHERE GP.PERIOD_SET_NAME =
                                                            'CNC_CALENDARIO'
                                                        AND UPPER(GP.PERIOD_NAME) =
                                                            UPPER(:P_PERIODO_INI)
                                                        AND GP.PERIOD_SET_NAME =
                                                            GLP.PERIOD_SET_NAME
                                                        AND GLP.END_DATE BETWEEN
                                                            TO_DATE('01/01/20' ||
                                                                    TO_CHAR(TO_NUMBER(SUBSTR(:P_PERIODO_INI,
                                                                                             5)) - 1),
                                                                    'DD/MM/YYYY') AND
                                                            GP.YEAR_START_DATE - 1
                                                     --AND GLP.END_DATE BETWEEN GP.YEAR_START_DATE AND GP.START_DATE -1
                                                     ))
                    AND TSCOM_SC.MONEDA = PPAV.PROJECT_CURRENCY_CODE
                       
                    AND NOT EXISTS
                  (SELECT 1
                           FROM PO_HEADERS_ALL LRHA
                          WHERE LRHA.FUNDS_STATUS IN
                                ('NOT_RESERVED', 'FAILED', 'RESERVED_PARTIAL')
                            AND TSCOM_SC.CMT_HEADER_ID = LRHA.PO_HEADER_ID)) as "AOC", --"CPA ORDENES DE COMPRA"
                (SELECT SUM(MONTO)
                   FROM TS_COMPROMISOS_PERIODOS TSCOM_SC
                  WHERE TSCOM_SC.TIPO_DOCUMENTO =
                        'Supplier Invoice Commitment.'
                    AND TSCOM_SC.PROJECT_ID = PPAV.PROJECT_ID
                    AND TSCOM_SC.TASK_ID = PPEV.DENORM_TOP_ELEMENT_ID
                    AND TSCOM_SC.EXPENDITURE_TYPE_ID =
                        PETV.EXPENDITURE_TYPE_ID
                    AND TSCOM_SC.PERIODO IN (SELECT GLP.PERIOD_NAME
                                               FROM GL_PERIODS GLP
                                              WHERE EXISTS (SELECT 1
                                                       FROM GL_PERIODS GP
                                                      WHERE GP.PERIOD_SET_NAME =
                                                            'CNC_CALENDARIO'
                                                        AND UPPER(GP.PERIOD_NAME) =
                                                            UPPER(:P_PERIODO_INI)
                                                        AND GP.PERIOD_SET_NAME =
                                                            GLP.PERIOD_SET_NAME
                                                        AND GLP.END_DATE BETWEEN
                                                            TO_DATE('01/01/20' ||
                                                                    TO_CHAR(TO_NUMBER(SUBSTR(:P_PERIODO_INI,
                                                                                             5)) - 1),
                                                                    'DD/MM/YYYY') AND
                                                            GP.YEAR_START_DATE - 1
                                                     --AND GLP.END_DATE BETWEEN GP.YEAR_START_DATE AND GP.START_DATE -1
                                                     ))
                    AND TSCOM_SC.MONEDA = PPAV.PROJECT_CURRENCY_CODE
                       
                    AND NOT EXISTS
                  (SELECT 1
                           FROM AP_INVOICES_ALL LRHA
                          WHERE LRHA.FUNDS_STATUS IN
                                ('NOT_RESERVED', 'FAILED', 'RESERVED_PARTIAL')
                            AND TSCOM_SC.CMT_HEADER_ID = LRHA.INVOICE_ID)) as "AFNC", --"CPA FACTURAS NO CONTABILIZADAS"
                (SELECT SUM(MONTO)
                   FROM TS_COMPROMISOS_PERIODOS TSCOM_SC
                  WHERE TSCOM_SC.TIPO_DOCUMENTO =
                        'Specifies that the imported transactions are for Transfer Order Commitment from Oracle Cost Management.'
                    AND TSCOM_SC.PROJECT_ID = PPAV.PROJECT_ID
                    AND TSCOM_SC.TASK_ID = PPEV.DENORM_TOP_ELEMENT_ID
                    AND TSCOM_SC.EXPENDITURE_TYPE_ID =
                        PETV.EXPENDITURE_TYPE_ID
                    AND TSCOM_SC.PERIODO IN (SELECT GLP.PERIOD_NAME
                                               FROM GL_PERIODS GLP
                                              WHERE EXISTS (SELECT 1
                                                       FROM GL_PERIODS GP
                                                      WHERE GP.PERIOD_SET_NAME =
                                                            'CNC_CALENDARIO'
                                                        AND UPPER(GP.PERIOD_NAME) =
                                                            UPPER(:P_PERIODO_INI)
                                                        AND GP.PERIOD_SET_NAME =
                                                            GLP.PERIOD_SET_NAME
                                                        AND GLP.END_DATE BETWEEN
                                                            TO_DATE('01/01/20' ||
                                                                    TO_CHAR(TO_NUMBER(SUBSTR(:P_PERIODO_INI,
                                                                                             5)) - 1),
                                                                    'DD/MM/YYYY') AND
                                                            GP.YEAR_START_DATE - 1
                                                     --AND GLP.END_DATE BETWEEN GP.YEAR_START_DATE AND GP.START_DATE -1
                                                     ))
                    AND TSCOM_SC.MONEDA = PPAV.PROJECT_CURRENCY_CODE) as"AOT", --"CPA ORDENES DE TRANSFERENCIA"
                
                ------COMPROMISOS PERIODO--------
                (SELECT SUM(MONTO)
                   FROM TS_COMPROMISOS_PERIODOS TSCOM_SC
                  WHERE TSCOM_SC.TIPO_DOCUMENTO = 'Purchase Requisition.'
                    AND TSCOM_SC.PROJECT_ID = PPAV.PROJECT_ID
                    AND TSCOM_SC.TASK_ID = PPEV.DENORM_TOP_ELEMENT_ID
                    AND TSCOM_SC.EXPENDITURE_TYPE_ID =
                        PETV.EXPENDITURE_TYPE_ID
                    AND TSCOM_SC.PERIODO IN
                        (SELECT GLP.PERIOD_NAME
                           FROM GL_PERIODS GLP
                          WHERE GLP.PERIOD_SET_NAME = 'CNC_CALENDARIO'
                            AND GLP.START_DATE BETWEEN
                                (SELECT GP.START_DATE
                                   FROM GL_PERIODS GP
                                  WHERE GP.PERIOD_SET_NAME = 'CNC_CALENDARIO'
                                    AND UPPER(GP.PERIOD_NAME) =
                                        UPPER(:P_PERIODO_INI))
                            AND (SELECT GP.START_DATE
                                   FROM GL_PERIODS GP
                                  WHERE GP.PERIOD_SET_NAME = 'CNC_CALENDARIO'
                                    AND UPPER(GP.PERIOD_NAME) =
                                        UPPER(:P_PERIODO_FIN)))
                    AND TSCOM_SC.MONEDA = PPAV.PROJECT_CURRENCY_CODE
                       
                    AND NOT EXISTS
                  (SELECT 1
                           FROM POR_REQUISITION_HEADERS_ALL LRHA
                          WHERE LRHA.FUNDS_STATUS IN
                                ('NOT_RESERVED', 'FAILED', 'RESERVED_PARTIAL')
                            AND TSCOM_SC.CMT_HEADER_ID =
                                LRHA.REQUISITION_HEADER_ID)) as "PSC", --"CP SOLICITUDES DE COMPRA"
                (SELECT SUM(MONTO)
                   FROM TS_COMPROMISOS_PERIODOS TSCOM_SC
                  WHERE TSCOM_SC.TIPO_DOCUMENTO = 'Purchase Order.'
                    AND TSCOM_SC.PROJECT_ID = PPAV.PROJECT_ID
                    AND TSCOM_SC.TASK_ID = PPEV.DENORM_TOP_ELEMENT_ID
                    AND TSCOM_SC.EXPENDITURE_TYPE_ID =
                        PETV.EXPENDITURE_TYPE_ID
                    AND TSCOM_SC.PERIODO IN
                        (SELECT GLP.PERIOD_NAME
                           FROM GL_PERIODS GLP
                          WHERE GLP.PERIOD_SET_NAME = 'CNC_CALENDARIO'
                            AND GLP.START_DATE BETWEEN
                                (SELECT GP.START_DATE
                                   FROM GL_PERIODS GP
                                  WHERE GP.PERIOD_SET_NAME = 'CNC_CALENDARIO'
                                    AND UPPER(GP.PERIOD_NAME) =
                                        UPPER(:P_PERIODO_INI))
                            AND (SELECT GP.START_DATE
                                   FROM GL_PERIODS GP
                                  WHERE GP.PERIOD_SET_NAME = 'CNC_CALENDARIO'
                                    AND UPPER(GP.PERIOD_NAME) =
                                        UPPER(:P_PERIODO_FIN)))
                    AND TSCOM_SC.MONEDA = PPAV.PROJECT_CURRENCY_CODE
                       
                    AND NOT EXISTS
                  (SELECT 1
                           FROM PO_HEADERS_ALL LRHA
                          WHERE LRHA.FUNDS_STATUS IN
                                ('NOT_RESERVED', 'FAILED', 'RESERVED_PARTIAL')
                            AND TSCOM_SC.CMT_HEADER_ID = LRHA.PO_HEADER_ID)) as "POC", --"CP ORDENES DE COMPRA"
                (SELECT SUM(MONTO)
                   FROM TS_COMPROMISOS_PERIODOS TSCOM_SC
                  WHERE TSCOM_SC.TIPO_DOCUMENTO =
                        'Supplier Invoice Commitment.'
                    AND TSCOM_SC.PROJECT_ID = PPAV.PROJECT_ID
                    AND TSCOM_SC.TASK_ID = PPEV.DENORM_TOP_ELEMENT_ID
                    AND TSCOM_SC.EXPENDITURE_TYPE_ID =
                        PETV.EXPENDITURE_TYPE_ID
                    AND TSCOM_SC.PERIODO IN
                        (SELECT GLP.PERIOD_NAME
                           FROM GL_PERIODS GLP
                          WHERE GLP.PERIOD_SET_NAME = 'CNC_CALENDARIO'
                            AND GLP.START_DATE BETWEEN
                                (SELECT GP.START_DATE
                                   FROM GL_PERIODS GP
                                  WHERE GP.PERIOD_SET_NAME = 'CNC_CALENDARIO'
                                    AND UPPER(GP.PERIOD_NAME) =
                                        UPPER(:P_PERIODO_INI))
                            AND (SELECT GP.START_DATE
                                   FROM GL_PERIODS GP
                                  WHERE GP.PERIOD_SET_NAME = 'CNC_CALENDARIO'
                                    AND UPPER(GP.PERIOD_NAME) =
                                        UPPER(:P_PERIODO_FIN)))
                    AND TSCOM_SC.MONEDA = PPAV.PROJECT_CURRENCY_CODE
                       
                    AND NOT EXISTS
                  (SELECT 1
                           FROM AP_INVOICES_ALL LRHA
                          WHERE LRHA.FUNDS_STATUS IN
                                ('NOT_RESERVED', 'FAILED', 'RESERVED_PARTIAL')
                            AND TSCOM_SC.CMT_HEADER_ID = LRHA.INVOICE_ID)) as "PFNC", --"CP FACTURAS NO CONTABILIZADAS"
                (SELECT SUM(MONTO)
                   FROM TS_COMPROMISOS_PERIODOS TSCOM_SC
                  WHERE TSCOM_SC.TIPO_DOCUMENTO =
                        'Specifies that the imported transactions are for Transfer Order Commitment from Oracle Cost Management.'
                    AND TSCOM_SC.PROJECT_ID = PPAV.PROJECT_ID
                    AND TSCOM_SC.TASK_ID = PPEV.DENORM_TOP_ELEMENT_ID
                    AND TSCOM_SC.EXPENDITURE_TYPE_ID =
                        PETV.EXPENDITURE_TYPE_ID
                    AND TSCOM_SC.PERIODO IN
                        (SELECT GLP.PERIOD_NAME
                           FROM GL_PERIODS GLP
                          WHERE GLP.PERIOD_SET_NAME = 'CNC_CALENDARIO'
                            AND GLP.START_DATE BETWEEN
                                (SELECT GP.START_DATE
                                   FROM GL_PERIODS GP
                                  WHERE GP.PERIOD_SET_NAME = 'CNC_CALENDARIO'
                                    AND UPPER(GP.PERIOD_NAME) =
                                        UPPER(:P_PERIODO_INI))
                            AND (SELECT GP.START_DATE
                                   FROM GL_PERIODS GP
                                  WHERE GP.PERIOD_SET_NAME = 'CNC_CALENDARIO'
                                    AND UPPER(GP.PERIOD_NAME) =
                                        UPPER(:P_PERIODO_FIN)))
                    AND TSCOM_SC.MONEDA = PPAV.PROJECT_CURRENCY_CODE) as "POT", --"CP ORDENES DE TRANSFERENCIA"
                
                --PCT. +  PCT. + PCT. + '' + '' + '' as "TOTAL COMPROMISOS", (SUMA DE COMPROMISOS PERIODO ANTERIOR + COMPROMISOS PERIODO)
                
                ------OBLIGATIONS PERIODO ANTERIOR---------
                --PCT.AMOUNT_INVOICED as "FACTURAS CONTABILIZADAS PERIODO ANTERIOR",
                (SELECT SUM(monto)
                   FROM ts_obligaciones_periodos tsobli_sc
                  WHERE tsobli_sc.proyecto = ppav.project_id
                       
                    AND tsobli_sc.TASK_ID = PPEV.DENORM_TOP_ELEMENT_ID
                    AND tsobli_sc.EXPENDITURE_TYPE_ID =
                        PETV.EXPENDITURE_TYPE_ID
                       
                    AND tsobli_sc.documento = 'Supplier Invoice'
                    AND tsobli_sc.periodo IN (SELECT glp.period_name
                                                FROM gl_periods glp
                                               WHERE EXISTS (SELECT 1
                                                        FROM gl_periods gp
                                                       WHERE gp.period_set_name =
                                                             'CNC_CALENDARIO'
                                                         AND UPPER(GP.PERIOD_NAME) =
                                                             UPPER(:P_PERIODO_INI)
                                                         AND gp.period_set_name =
                                                             glp.period_set_name
                                                         AND GLP.END_DATE BETWEEN
                                                             TO_DATE('01/01/20' ||
                                                                     TO_CHAR(TO_NUMBER(SUBSTR(:P_PERIODO_INI,
                                                                                              5)) - 1),
                                                                     'DD/MM/YYYY') AND
                                                             GP.YEAR_START_DATE - 1
                                                      --AND glp.end_date BETWEEN gp.year_start_date AND gp.start_date -1
                                                      ))) as "AFC", --"OPA FACTURAS CONTABILIZADAS"
                (SELECT SUM(monto)
                   FROM ts_obligaciones_periodos tsobli_sc
                  WHERE tsobli_sc.proyecto = ppav.project_id
                       
                    AND tsobli_sc.TASK_ID = PPEV.DENORM_TOP_ELEMENT_ID
                    AND tsobli_sc.EXPENDITURE_TYPE_ID =
                        PETV.EXPENDITURE_TYPE_ID
                       
                    AND tsobli_sc.documento = 'Transfer Order Delivery'
                    AND tsobli_sc.periodo IN (SELECT glp.period_name
                                                FROM gl_periods glp
                                               WHERE EXISTS (SELECT 1
                                                        FROM gl_periods gp
                                                       WHERE gp.period_set_name =
                                                             'CNC_CALENDARIO'
                                                         AND UPPER(GP.PERIOD_NAME) =
                                                             UPPER(:P_PERIODO_INI)
                                                         AND gp.period_set_name =
                                                             glp.period_set_name
                                                         AND GLP.END_DATE BETWEEN
                                                             TO_DATE('01/01/20' ||
                                                                     TO_CHAR(TO_NUMBER(SUBSTR(:P_PERIODO_INI,
                                                                                              5)) - 1),
                                                                     'DD/MM/YYYY') AND
                                                             GP.YEAR_START_DATE - 1
                                                      --AND glp.end_date BETWEEN gp.year_start_date AND gp.start_date -1
                                                      ))) as "ATOD", --"OPA ORDENES DE TRANSFERENCIA DELIVERY"
                (SELECT SUM(monto)
                   FROM ts_obligaciones_periodos tsobli_sc
                  WHERE tsobli_sc.proyecto = ppav.project_id
                       
                    AND tsobli_sc.TASK_ID = PPEV.DENORM_TOP_ELEMENT_ID
                    AND tsobli_sc.EXPENDITURE_TYPE_ID =
                        PETV.EXPENDITURE_TYPE_ID
                       
                    AND tsobli_sc.documento = 'Miscellaneous Inventory'
                    AND tsobli_sc.periodo IN (SELECT glp.period_name
                                                FROM gl_periods glp
                                               WHERE EXISTS (SELECT 1
                                                        FROM gl_periods gp
                                                       WHERE gp.period_set_name =
                                                             'CNC_CALENDARIO'
                                                         AND UPPER(GP.PERIOD_NAME) =
                                                             UPPER(:P_PERIODO_INI)
                                                         AND gp.period_set_name =
                                                             glp.period_set_name
                                                         AND GLP.END_DATE BETWEEN
                                                             TO_DATE('01/01/20' ||
                                                                     TO_CHAR(TO_NUMBER(SUBSTR(:P_PERIODO_INI,
                                                                                              5)) - 1),
                                                                     'DD/MM/YYYY') AND
                                                             GP.YEAR_START_DATE - 1
                                                      --AND glp.end_date BETWEEN gp.year_start_date AND gp.start_date -1
                                                      ))) as "AINV",
                ------OBLIGATIONS PERIODO---------
                (SELECT SUM(monto)
                   FROM ts_obligaciones_periodos tsobli_sc
                  WHERE tsobli_sc.proyecto = ppav.project_id
                       
                    AND tsobli_sc.TASK_ID = PPEV.DENORM_TOP_ELEMENT_ID
                    AND tsobli_sc.EXPENDITURE_TYPE_ID =
                        PETV.EXPENDITURE_TYPE_ID
                       
                    AND tsobli_sc.documento = 'Supplier Invoice'
                    AND tsobli_sc.periodo IN
                        (SELECT GLP.PERIOD_NAME
                           FROM GL_PERIODS GLP
                          WHERE GLP.PERIOD_SET_NAME = 'CNC_CALENDARIO'
                            AND GLP.START_DATE BETWEEN
                                (SELECT GP.START_DATE
                                   FROM GL_PERIODS GP
                                  WHERE GP.PERIOD_SET_NAME = 'CNC_CALENDARIO'
                                    AND UPPER(GP.PERIOD_NAME) =
                                        UPPER(:P_PERIODO_INI))
                            AND (SELECT GP.START_DATE
                                   FROM GL_PERIODS GP
                                  WHERE GP.PERIOD_SET_NAME = 'CNC_CALENDARIO'
                                    AND UPPER(GP.PERIOD_NAME) =
                                        UPPER(:P_PERIODO_FIN)))) as "PFC", --"OP FACTURAS CONTABILIZADAS"
                (SELECT SUM(monto)
                   FROM ts_obligaciones_periodos tsobli_sc
                  WHERE tsobli_sc.proyecto = ppav.project_id
                       
                    AND tsobli_sc.TASK_ID = PPEV.DENORM_TOP_ELEMENT_ID
                    AND tsobli_sc.EXPENDITURE_TYPE_ID =
                        PETV.EXPENDITURE_TYPE_ID
                       
                    AND tsobli_sc.documento = 'Transfer Order Delivery'
                    AND tsobli_sc.periodo IN
                        (SELECT GLP.PERIOD_NAME
                           FROM GL_PERIODS GLP
                          WHERE GLP.PERIOD_SET_NAME = 'CNC_CALENDARIO'
                            AND GLP.START_DATE BETWEEN
                                (SELECT GP.START_DATE
                                   FROM GL_PERIODS GP
                                  WHERE GP.PERIOD_SET_NAME = 'CNC_CALENDARIO'
                                    AND UPPER(GP.PERIOD_NAME) =
                                        UPPER(:P_PERIODO_INI))
                            AND (SELECT GP.START_DATE
                                   FROM GL_PERIODS GP
                                  WHERE GP.PERIOD_SET_NAME = 'CNC_CALENDARIO'
                                    AND UPPER(GP.PERIOD_NAME) =
                                        UPPER(:P_PERIODO_FIN)))) as "PTOD", --"OP ORDENES DE TRANSFERENCIA DELIVERY"
                (SELECT SUM(monto)
                   FROM ts_obligaciones_periodos tsobli_sc
                  WHERE tsobli_sc.proyecto = ppav.project_id
                       
                    AND tsobli_sc.TASK_ID = PPEV.DENORM_TOP_ELEMENT_ID
                    AND tsobli_sc.EXPENDITURE_TYPE_ID =
                        PETV.EXPENDITURE_TYPE_ID
                       
                    AND tsobli_sc.documento = 'Miscellaneous Inventory'
                    AND tsobli_sc.periodo IN
                        (SELECT GLP.PERIOD_NAME
                           FROM GL_PERIODS GLP
                          WHERE GLP.PERIOD_SET_NAME = 'CNC_CALENDARIO'
                            AND GLP.START_DATE BETWEEN
                                (SELECT GP.START_DATE
                                   FROM GL_PERIODS GP
                                  WHERE GP.PERIOD_SET_NAME = 'CNC_CALENDARIO'
                                    AND UPPER(GP.PERIOD_NAME) =
                                        UPPER(:P_PERIODO_INI))
                            AND (SELECT GP.START_DATE
                                   FROM GL_PERIODS GP
                                  WHERE GP.PERIOD_SET_NAME = 'CNC_CALENDARIO'
                                    AND UPPER(GP.PERIOD_NAME) =
                                        UPPER(:P_PERIODO_FIN)))) as "PINV" 
         
         ----------------------------------
         --PCT.AMOUNT_INVOICED + '' as "TOTAL OBLIGACIONES",(SUMA DE OBLIGATIONS PERIODO + OBLIGATIONS PERIODO ANTERIOR)
         
         -- adiciona 
         
         --,PPAV.PROJECT_ID
           from PJF_PROJECTS_ALL_VL PPAV
          INNER JOIN PJF_PROJECT_TYPES_VL PPTV
             ON PPAV.PROJECT_TYPE_ID = PPTV.PROJECT_TYPE_ID
         -- PASAR DE INNER JOIN A LEFT JOIN MSB251122
           LEFT JOIN PJF_PROJECT_CLASSES_V PPCV
             ON PPAV.PROJECT_ID = PPCV.PROJECT_ID
         -- PASAR DE INNER JOIN A LEFT JOIN MSB251122
           LEFT JOIN PJF_CLASS_CODES_VL PCCV
             ON PCCV.CLASS_CODE_ID = PPCV.CLASS_CODE_ID
            AND PCCV.CLASS_CATEGORY_ID = PPCV.CLASS_CATEGORY_ID
         -- MSB121022 / PASAR DE INNER JOIN A LEFT JOIN MSB251122
           LEFT JOIN PJF_CLASS_CATEGORIES_TL PCCT
             ON PCCT.CLASS_CATEGORY_ID = PCCV.CLASS_CATEGORY_ID
            AND PCCT.LANGUAGE = 'US'
            AND PCCT.CLASS_CATEGORY = 'LINEA DE NEGOCIO'
         
          INNER JOIN HR_ORGANIZATION_UNITS HOU
             ON PPAV.ORG_ID = HOU.ORGANIZATION_ID
          INNER JOIN PJF_PROJ_ELEMENTS_VL PPEV
             ON PPAV.PROJECT_ID = PPEV.PROJECT_ID
            AND PPEV.OBJECT_TYPE = 'PJF_TASKS'
         
          INNER JOIN TS_PROJECTO_TAREA_RECURSO TSPTR
             ON TSPTR.PROJECT_ID = PPEV.PROJECT_ID
            AND TSPTR.TASK_ID = PPEV.DENORM_TOP_ELEMENT_ID
         
         --LEFT JOIN PJC_EXP_ITEMS_ALL PEIA
         --ON PPAV.PROJECT_ID = TSPTR.PROJECT_ID
         --AND PPEV.DENORM_TOP_ELEMENT_ID = TSPTR.TASK_ID
         
         --nueva linea de codigo
         -- EXPENDITURE_TYPE_NAME
           LEFT JOIN PJF_EXP_TYPES_VL PETV
             ON TSPTR.ALIAS = PETV.EXPENDITURE_TYPE_NAME  502001
         
         --INNER JOIN PJC_COMMITMENT_TXNS PCT
         --ON PCT.EXPENDITURE_TYPE_ID = PETV.EXPENDITURE_TYPE_ID
         --INNER JOIN PJO_PLAN_VERSIONS_VL PPVV --COLOCAR CUALQUIER TABLA 
         --ESTA TABLA NO TIENE VISTA
         --ON PPVV.PROJECT_ID = PCT.PROJECT_ID
         
          WHERE 1 = 1
               --CONSULTA NORMAL: FALTA DEFINIR PARÁMETRO CUÁL SERÁ EL CAMPO OBLIGATORIO (ATTRIBUTE1)
               --AND PPAV.START_DATE = :P_FECDESDE -- "Fecha desde"
               --AND PPAV.COMPLETION_DATE = :P_FECHASTA -- "Fecha hasta"
            AND (PPAV.SEGMENT1 = :P_NROPROYECTO OR :P_NROPROYECTO IS NULL) -- "Numero de Proyecto"
            AND (PPTV.PROJECT_TYPE = :P_DESCRIPTION OR
                :P_DESCRIPTION IS NULL) -- "Tipo de Proyecto" (GAS)
            AND (:P_RECURSOS IS NOT NULL AND
                (UPPER(TSPTR.ALIAS) LIKE '%' || UPPER(:P_RECURSOS) || '%') OR
                :P_RECURSOS IS NULL) -- "Recursos"
            AND (PPAV.PROJECT_STATUS_CODE = :P_PROJECT_STATUS_CODE OR
                :P_PROJECT_STATUS_CODE IS NULL) -- as "Estado"
            AND (PPEV.ELEMENT_NUMBER = :P_ELEMENT_NUMBER OR
                :P_ELEMENT_NUMBER IS NULL) -- as "Tarea" 
            AND (PPAV.PROJECT_CURRENCY_CODE = :P_ORIGENMONEDA OR
                :P_ORIGENMONEDA IS NULL) -- as "Origen Moneda (COP/USD)""
            AND (PCCV.CLASS_CODE = :P_LINEANEGOCIO OR
                :P_LINEANEGOCIO IS NULL) -- "Línea de Negocio"
            AND (PPAV.ATTRIBUTE1 = :P_CENTROCOSTO OR :P_CENTROCOSTO IS NULL) -- Centro de Costo (990001)
            AND (PPAV.ATTRIBUTE2 = :P_NROAFE OR :P_NROAFE IS NULL) --"WECF2002" Nro de Afe (ADMIN023)
            AND (PPAV.ATTRIBUTE5 = :P_PROYECTO OR :P_PROYECTO IS NULL)
            AND (PPAV.ATTRIBUTE6 = :P_AREA OR :P_AREA IS NULL) --"DRILLING" Area (ADMINISTRATIVE)
            AND (PPAV.ATTRIBUTE7 = :P_ETAPA OR :P_ETAPA IS NULL) --"DEVELOPMENT" Etapa (PRODUCTIVA)
            AND (PPAV.ATTRIBUTE8 = :P_BLOQUE OR :P_BLOQUE IS NULL) --Bloque
            AND (HOU.NAME = :P_NAME OR :P_NAME IS NULL) -- COMPAÑIA
          GROUP BY HOU.NAME,
                   TO_CHAR(PPAV.START_DATE, 'MM'),
                   PPAV.SEGMENT1,
                   TO_CHAR(PPAV.START_DATE, 'DD/MM/YYYY'),
                   TO_CHAR(PPAV.COMPLETION_DATE, 'DD/MM/YYYY'),
                   PPTV.PROJECT_TYPE,
                   PPAV.PROJECT_STATUS_CODE,
                   PPAV.ATTRIBUTE1,
                   PPAV.ATTRIBUTE2,
                   PPEV.ELEMENT_NUMBER,
                   --INSERCIÓN DE CAMPO
                   PPEV.NAME,
                   PPAV.ATTRIBUTE3,
                   PPAV.ATTRIBUTE5,
                   PPAV.ATTRIBUTE6,
                   PPAV.ATTRIBUTE7,
                   PCCV.CLASS_CODE,
                   PPAV.ATTRIBUTE8,
                   TSPTR.ALIAS,
                   PPAV.PROJECT_CURRENCY_CODE
                   
                  ,
                   PPAV.PROJECT_ID
                   
                  ,
                   PPEV.DENORM_TOP_ELEMENT_ID,
                   PETV.EXPENDITURE_TYPE_ID
         
          ORDER BY PPAV.SEGMENT1, PPEV.ELEMENT_NUMBER) v1
          WHERE v1."TB" IS NOT NULL