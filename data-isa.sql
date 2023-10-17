--version modificada
SELECT HEADER_ID,
       comprador,
       mes_creacion,
       creation_date,
       usuario_creacion,
       tipo,
       identificador,
       company_nro,
       legal_entity_name,
       area_solicitante,
       admin_contrato,
       NIT,
       vendor_name,
       --description,
       duration_months,
       duration_months_decimal,
       start_date,
       NRO_RQ,  
       end_date,
       months_exp,
       days_exp,
       currency_code,
       CASE currency_code
         WHEN 'USD' THEN
          ROUND(amount * rate_usd, 2)
         WHEN 'COP' THEN
          amount
       END AS amount_cop,
       CASE currency_code
         WHEN 'USD' THEN
          amount
         WHEN 'COP' THEN
          ROUND(amount * rate_usd, 2)
       END AS amount_usd,

       --MAX(PRH.REQUISITION_NUMBER) AS NRO_RQ,
       NVL((SELECT SUM(PLA.UNIT_PRICE * PLA.QUANTITY)
             FROM PO_LINES_ALL PLA
            WHERE PLA.FROM_HEADER_ID = HEADER_ID),
           0.00) AS EXECUTED_WO,
       NVL((SELECT SUM(PLA.UNIT_PRICE * PLL.QUANTITY_RECEIVED)
             FROM PO_LINES_ALL PLA, PO_LINE_LOCATIONS_ALL PLL
            WHERE PLL.po_line_id = PLA.po_line_id
              AND PLA.FROM_HEADER_ID = HEADER_ID),
           0.00) AS EXECUTED_GR,
       NVL((SELECT SUM(NVL(AIA.invoice_amount, 0))
             FROM AP_INVOICES_aLL AIA
            WHERE AIA.PO_HEADER_ID IN
                  (SELECT DISTINCT PL.PO_HEADER_ID
                     FROM PO_LINES_ALL PL
                    WHERE DECODE(type_lookup_code,
                                 'BLANKET',
                                 PL.FROM_HEADER_ID,
                                 PL.PO_HEADER_ID) = HEADER_ID --FROM_HEADER
                   )
              AND AIA.INVOICE_CURRENCY_CODE = 'USD'),
           (SELECT SUM(NVL(AIA.invoice_amount, 0))
              FROM AP_INVOICES_aLL AIA
             WHERE AIA.PO_HEADER_ID IN
                   (SELECT DISTINCT PL.PO_HEADER_ID
                      FROM PO_LINES_ALL PL
                     WHERE DECODE(type_lookup_code,
                                  'BLANKET',
                                  PL.FROM_HEADER_ID,
                                  PL.PO_HEADER_ID) = HEADER_ID --FROM_HEADER
                    )
               AND AIA.INVOICE_CURRENCY_CODE = 'COP') / RATE_USD) AS INVOICED_VALUE_CURRENCY,
       NVL((SELECT SUM(NVL(AIA.invoice_amount, 0))
             FROM AP_INVOICES_aLL AIA
            WHERE AIA.PO_HEADER_ID IN
                  (SELECT DISTINCT PL.PO_HEADER_ID
                     FROM PO_LINES_ALL PL
                    WHERE DECODE(type_lookup_code,
                                 'BLANKET',
                                 PL.FROM_HEADER_ID,
                                 PL.PO_HEADER_ID) = HEADER_ID --FROM_HEADER
                   )
              AND AIA.INVOICE_CURRENCY_CODE = 'COP'),
           (SELECT SUM(NVL(AIA.invoice_amount, 0))
              FROM AP_INVOICES_aLL AIA
             WHERE AIA.PO_HEADER_ID IN
                   (SELECT DISTINCT PL.PO_HEADER_ID
                      FROM PO_LINES_ALL PL
                     WHERE DECODE(type_lookup_code,
                                  'BLANKET',
                                  PL.FROM_HEADER_ID,
                                  PL.PO_HEADER_ID) = HEADER_ID --FROM_HEADER
                    )
               AND AIA.INVOICE_CURRENCY_CODE = 'USD') * RATE_USD) AS INVOICES_VALUE_COP,
       NVL(AMOUNT - (SELECT SUM(PLA.UNIT_PRICE * PLA.QUANTITY)
                       FROM PO_LINES_ALL PLA
                      WHERE PLA.FROM_HEADER_ID = HEADER_ID),
           0.00) AS BALANCE_TO_DATE, --AMOUNT - EXECUTED_WO, 

       NVL(CASE currency_code
             WHEN 'USD' THEN
              AMOUNT - (SELECT SUM(PLA.UNIT_PRICE * PLA.QUANTITY)
                          FROM PO_LINES_ALL PLA
                         WHERE PLA.FROM_HEADER_ID = HEADER_ID)
             WHEN 'COP' THEN
              (AMOUNT - (SELECT SUM(PLA.UNIT_PRICE * PLA.QUANTITY)
                           FROM PO_LINES_ALL PLA
                          WHERE PLA.FROM_HEADER_ID = HEADER_ID)) * RATE_USD --AMOUNT - EXECUTED_WO, 
           END,
           0.00) AS BALANCE_TO_DATE_USD, --AMOUNT - EXECUTED_WO * RATE_USD
       
       NVL(CASE type_lookup_code
             WHEN 'BLANKET' THEN
              CASE
                WHEN AMOUNT IS NULL OR AMOUNT = 0 THEN
                 NULL
                WHEN (SELECT SUM(PLA.UNIT_PRICE * PLA.QUANTITY)
                        FROM PO_LINES_ALL PLA
                       WHERE PLA.FROM_HEADER_ID = HEADER_ID) IS NULL THEN
                 0
                ELSE
                -- executed_wo / AMOUNT
                 ROUND((((SELECT SUM(PLA.UNIT_PRICE * PLA.QUANTITY)
                            FROM PO_LINES_ALL PLA
                           WHERE PLA.FROM_HEADER_ID = HEADER_ID) / AMOUNT) * 100),
                       2)
              END
             ELSE
              NULL
           END,
           0.00) AS percentage_comm_wo,
       
       NVL(CASE currency_code
             WHEN 'USD' THEN
              ((SELECT SUM(NVL(AIA.invoice_amount, 0)) -- ,invoice_currency_code--PO_HEADER_ID
                  FROM AP_INVOICES_aLL AIA
                 WHERE AIA.PO_HEADER_ID IN
                       (SELECT DISTINCT PL.PO_HEADER_ID
                          FROM PO_LINES_ALL PL
                         WHERE DECODE(type_lookup_code,
                                      'BLANKET',
                                      PL.FROM_HEADER_ID,
                                      PL.PO_HEADER_ID) = HEADER_ID --FROM_HEADER
                        )
                   AND AIA.INVOICE_CURRENCY_CODE = 'USD') +
              (SELECT SUM(NVL(AIA.invoice_amount, 0)) -- ,invoice_currency_code--PO_HEADER_ID
                  FROM AP_INVOICES_aLL AIA
                 WHERE AIA.PO_HEADER_ID IN
                       (SELECT DISTINCT PL.PO_HEADER_ID
                          FROM PO_LINES_ALL PL
                         WHERE DECODE(type_lookup_code,
                                      'BLANKET',
                                      PL.FROM_HEADER_ID,
                                      PL.PO_HEADER_ID) = HEADER_ID --FROM_HEADER
                        )
                   AND AIA.INVOICE_CURRENCY_CODE = 'COP') / RATE_USD) /
              AMOUNT
             WHEN 'COP' THEN
              ((SELECT SUM(NVL(AIA.invoice_amount, 0)) -- ,invoice_currency_code--PO_HEADER_ID
                  FROM AP_INVOICES_aLL AIA
                 WHERE AIA.PO_HEADER_ID IN
                       (SELECT DISTINCT PL.PO_HEADER_ID
                          FROM PO_LINES_ALL PL
                         WHERE DECODE(type_lookup_code,
                                      'BLANKET',
                                      PL.FROM_HEADER_ID,
                                      PL.PO_HEADER_ID) = HEADER_ID --FROM_HEADER
                        )
                   AND AIA.INVOICE_CURRENCY_CODE = 'COP') +
              (SELECT SUM(NVL(AIA.invoice_amount, 0)) -- ,invoice_currency_code--PO_HEADER_ID
                  FROM AP_INVOICES_aLL AIA
                 WHERE AIA.PO_HEADER_ID IN
                       (SELECT DISTINCT PL.PO_HEADER_ID
                          FROM PO_LINES_ALL PL
                         WHERE DECODE(type_lookup_code,
                                      'BLANKET',
                                      PL.FROM_HEADER_ID,
                                      PL.PO_HEADER_ID) = HEADER_ID --FROM_HEADER
                        )
                   AND AIA.INVOICE_CURRENCY_CODE = 'USD') * RATE_USD) /
              AMOUNT
           END,
           0.00) AS PERCENTAGE_AMENDED, --invoices_value / AMOUNT
       
       NVL(CASE
             WHEN (case
                    when currency_code = 'USD' THEN
                     AMOUNT
                    ELSE
                     AMOUNT
                  END) > 5000 then
              'Y'
             else
              'N'
           end,
           0.00) AS COND_5K_USD,
       --CASE WHEN amount * rate_usd > 5000 then 'Y'
       case
         when attribute1 in ('Y', 'SI') then
          'Y'
         else
          'N'
       end ifrs16,
       case
         when attribute1 in ('Y', 'SI') then
          'LEASING'
         else
          'SERVICE'
       end service_type,
       --case when end_date - start_date >= 365  then 'Y' else 'N' end contract_year
       case
         when (decode(type_lookup_code,
                      'BLANKET',
                      trunc(end_date),
                      'STANDARD',
                      (select min(plla.need_by_date)
                         from PO_LINE_LOCATIONS_ALL plla
                        WHERE plla.po_header_id = HEADER_ID)) -
              decode(type_lookup_code,
                      'BLANKET',
                      trunc(start_date),
                      'STANDARD',
                      (select max(pah.action_date)
                         from PO_ACTION_HISTORY pah
                        where pah.object_id = HEADER_ID
                          and pah.object_type_code = 'PO'
                          and pah.action_code = 'APPROVE'))) >= 365 then
          'Y'
         else
          'N'
       end AS CONTRACT_YEAR,
       document_status,
       (SELECT LISTAGG(invoice_NUM)
          FROM AP_INVOICES_aLL
         WHERE PO_HEADER_ID IN (SELECT DISTINCT PL.PO_HEADER_ID
                                  FROM PO_LINES_ALL PL
                                 WHERE DECODE(type_lookup_code,
                                              'BLANKET',
                                              PL.FROM_HEADER_ID,
                                              PL.PO_HEADER_ID) = HEADER_ID --FROM_HEADER
                                )) AS INVOICES
--NULL AS COMMENTS
  FROM (SELECT ph.po_header_id AS HEADER_ID,
               (SELECT initcap(pnf1.first_name || ' ' || pnf1.last_name)
                  FROM per_person_names_f pnf1
                 WHERE ph.agent_id = pnf1.person_id
                   and pnf1.name_type = 'GLOBAL') comprador,
               to_char(trunc(ph.creation_date),
                       'Month',
                       'NLS_DATE_LANGUAGE = Spanish') mes_creacion,
               trunc(ph.creation_date) creation_date,

               (select DISTINCT LISTAGG(DISTINCT PRH.REQUISITION_NUMBER,',') WITHIN GROUP (ORDER BY PRH.REQUISITION_NUMBER) OVER (PARTITION BY PH.PO_HEADER_ID)
               from
                    POR_REQUISITION_HEADERS_ALL PRH,
                    POR_REQUISITION_LINES_ALL PRLA
               where
                    1 = 1
                    AND ph.PO_HEADER_ID = PRLA.PO_HEADER_ID
                    AND PRLA.REQUISITION_HEADER_ID = PRH.REQUISITION_HEADER_ID
               ) AS NRO_RQ,  
               
               (select initcap(ppnf.first_name || ' ' || ppnf.last_name)
                  from PER_USERS pu, PER_PERSON_NAMES_F ppnf
                 where pu.username = ph.CREATED_BY
                   and pu.person_id = ppnf.person_id
                   and ppnf.name_type = 'GLOBAL') usuario_creacion,
               decode(ph.type_lookup_code,
                      'BLANKET',
                      'Contrato',
                      'STANDARD',
                      'Orden') tipo,
               ph.segment1 identificador,
               (SELECT substr(gllv.ledger_name, 1, 2)
                  FROM hr_organization_v         hov,
                       hr_org_details_by_class_v hodbc,
                       gl_ledger_le_v            gllv
                 WHERE hov.organization_id = hodbc.organization_id
                   AND hov.classification_code = hodbc.classification_code
                   AND hov.classification_code =
                       hodbc.org_information_context
                   AND hov.classification_code = 'FUN_BUSINESS_UNIT'
                   AND hodbc.org_information2 = gllv.legal_entity_id
                   AND hodbc.org_information3 = gllv.ledger_id
                   AND hov.status = 'A'
                   AND hov.organization_id = ph.prc_bu_id) AS company_nro,
               (SELECT gllv.legal_entity_name
                  FROM hr_organization_v         hov,
                       hr_org_details_by_class_v hodbc,
                       gl_ledger_le_v            gllv
                 WHERE hov.organization_id = hodbc.organization_id
                   AND hov.classification_code = hodbc.classification_code
                   AND hov.classification_code =
                       hodbc.org_information_context
                   AND hov.classification_code = 'FUN_BUSINESS_UNIT'
                   AND hodbc.org_information2 = gllv.legal_entity_id
                   AND hodbc.org_information3 = gllv.ledger_id
                   AND hov.status = 'A'
                   AND hov.organization_id = ph.prc_bu_id) AS legal_entity_name,
               ph.attribute5 area_solicitante,
               initcap(ph.attribute4) admin_contrato,
               (SELECT DISTINCT AOS.VENDOR_VAT_REGISTRATION_NUM
                  FROM AP_OFR_SUPPLIERS_V AOS, POZ_SUPPLIERS_v PS
                 WHERE AOS.vendor_id = PS.vendor_id
                   and ph.vendor_id = ps.vendor_id) AS NIT,
               (SELECT v.vendor_name
                  FROM POZ_SUPPLIERS_V v
                 WHERE v.vendor_id = ph.vendor_id) AS vendor_name,
                replace(replace(ph.comments, chr(13)), chr(10)) AS Po_desc,
               ROUND(MONTHS_BETWEEN(decode(ph.type_lookup_code,
                                           'BLANKET',
                                           trunc(ph.end_date),
                                           'STANDARD',
                                           (select min(plla.need_by_date) need_by_date
                                              from PO_LINE_LOCATIONS_ALL plla
                                             WHERE plla.po_header_id =
                                                   ph.po_header_id)),
                                    decode(ph.type_lookup_code,
                                           'BLANKET',
                                           trunc(ph.start_date),
                                           'STANDARD',
                                           (select max(pah.action_date)
                                              from PO_ACTION_HISTORY pah
                                             where pah.object_id =
                                                   ph.po_header_id
                                               and pah.object_type_code = 'PO'
                                               and pah.action_code = 'APPROVE'))),
                     0) AS duration_months, -- ROUND(MONTHS_BETWEEN(end_date,start_date),0) 
               ROUND(decode(ph.type_lookup_code,
                            'BLANKET',
                            trunc(ph.end_date),
                            'STANDARD',
                            (select min(plla.need_by_date) need_by_date
                               from PO_LINE_LOCATIONS_ALL plla
                              WHERE plla.po_header_id = ph.po_header_id)) -
                     decode(ph.type_lookup_code,
                            'BLANKET',
                            trunc(ph.start_date),
                            'STANDARD',
                            (select max(pah.action_date)
                               from PO_ACTION_HISTORY pah
                              where pah.object_id = ph.po_header_id
                                and pah.object_type_code = 'PO'
                                and pah.action_code = 'APPROVE')),
                     0) AS duration_months_decimal, -- ROUND(end_date - start_date,0) 
               decode(ph.type_lookup_code,
                      'BLANKET',
                      trunc(ph.start_date),
                      'STANDARD',
                      (select max(pah.action_date) action_date
                         from PO_ACTION_HISTORY pah
                        where pah.object_id = ph.po_header_id
                          and pah.object_type_code = 'PO'
                          and pah.action_code = 'APPROVE')) start_date,
               decode(ph.type_lookup_code,
                      'BLANKET',
                      trunc(ph.end_date),
                      'STANDARD',
                      (select min(plla.need_by_date) need_by_date
                         from PO_LINE_LOCATIONS_ALL plla
                        WHERE plla.po_header_id = ph.po_header_id)) end_date,
               case
                 when decode(ph.type_lookup_code,
                             'BLANKET',
                             trunc(ph.end_date),
                             'STANDARD',
                             (select min(plla.need_by_date) need_by_date
                                from PO_LINE_LOCATIONS_ALL plla
                               WHERE plla.po_header_id = ph.po_header_id)) >
                      sysdate then
                  FLOOR(MONTHS_BETWEEN(decode(ph.type_lookup_code,
                                              'BLANKET',
                                              trunc(ph.end_date),
                                              'STANDARD',
                                              (select min(plla.need_by_date) need_by_date
                                                 from PO_LINE_LOCATIONS_ALL plla
                                                WHERE plla.po_header_id =
                                                      ph.po_header_id)),
                                       (TRUNC(SYSDATE, 'MM') - 1)))
                 else
                  0
               end months_exp,
               --case when end_date > sysdate then FLOOR(MONTHS_BETWEEN(end_date,  (TRUNC(SYSDATE,'MM')-1) )) else 0 end months_exp,
               case
                 when decode(ph.type_lookup_code,
                             'BLANKET',
                             trunc(ph.end_date),
                             'STANDARD',
                             (select min(plla.need_by_date) need_by_date
                                from PO_LINE_LOCATIONS_ALL plla
                               WHERE plla.po_header_id = ph.po_header_id)) >
                      sysdate then
                  FLOOR(decode(ph.type_lookup_code,
                               'BLANKET',
                               trunc(ph.end_date),
                               'STANDARD',
                               (select min(plla.need_by_date) need_by_date
                                  from PO_LINE_LOCATIONS_ALL plla
                                 WHERE plla.po_header_id = ph.po_header_id)) -
                        (TRUNC(SYSDATE, 'MM') - 1))
                 else
                  0
               end days_exp,
               --case when end_date > sysdate then FLOOR(end_date - (TRUNC(SYSDATE,'MM')-1) ) else 0 end days_exp,     
               ph.currency_code,
               --amount * rate_to_cop amount_cop,    
               decode(ph.type_lookup_code,
                      'BLANKET',
                      ph.blanket_total_amount,
                      'STANDARD',
                      (select sum(pda.TAX_EXCLUSIVE_AMOUNT) +
                              sum(pda.NONRECOVERABLE_TAX)
                         from PO_DISTRIBUTIONS_ALL pda
                        where pda.po_header_id = ph.po_header_id)) AS AMOUNT,
               NVL((SELECT GDR.CONVERSION_RATE
                     FROM GL_DAILY_RATES GDR
                    WHERE GDR.FROM_CURRENCY = 'COP'
                      AND GDR.TO_CURRENCY = 'USD' -- ph.currency_code 
                      AND TO_CHAR(GDR.CONVERSION_DATE, 'DD/MM/YYYY') =
                          NVL(TO_CHAR(ph.start_date, 'DD/MM/YYYY'),
                              TO_CHAR(PH.CREATION_DATE, 'DD/MM/YYYY'))
                      AND GDR.CONVERSION_TYPE = '300000004035333' --'300000004035335' --'300000002552087'
                   ),
                    1) AS RATE_USD,
               ph.type_lookup_code,
               ph.blanket_total_amount,
               ph.attribute1,
               ph.rate,
               ph.document_status
        --ph.FROM_HEADER_ID AS FROM_HEADER
          FROM po_headers_all ph
         
         /*INNER JOIN PO_LINES_ALL PL
         ON PH.PO_HEADER_ID = PL.PO_HEADER_ID

         INNER JOIN por_requisition_lines_all prla
         ON prla.po_header_id = ph.po_header_id
         AND prla.po_line_id = pl.po_line_id

         INNER JOIN por_requisition_headers_all prh
         ON prh.requisition_header_id = prla.requisition_header_id */
        -- WHERE ph.SEGMENT1 IN ('GEO-048-2019','40-OR-00088','40-WO-10067','11-WO-5580','11-SO-367','11-PO-1116','11-SO-367','CEC-071-2022','CEC-052-2022','CEC-013-2020.','CEC-013-2020','GEO-089-2019','CONVENIO-CAMU','CMD-001-2021')
        --AND ph.type_lookup_code = 'BLANKET'
        )
 where creation_date >= :P_FCH_DESDE
   AND creation_date < :P_FCH_HASTA + 1
   and (:p_numero is null or identificador = :p_numero)
   and (:p_tipo is null or tipo = :p_tipo)
   and (:p_empresa is null or legal_entity_name = :p_empresa)