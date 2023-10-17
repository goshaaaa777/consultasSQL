with puc as
 (SELECT ffv.flex_value AS cuenta_puc, ffvt.description AS desc_cuenta_puc
    FROM fnd_flex_value_sets ffvs,
         fnd_flex_values     ffv,
         fnd_flex_values_tl  ffvt
   WHERE ffvs.flex_value_set_id = ffv.flex_value_set_id
     AND ffv.flex_value_id = ffvt.flex_value_id
     AND ffvs.flex_value_set_name = 'CNC_PUC'
     AND ffvt.language = :P_IDIOMA
     AND ffvt.description <> 'NULL'),
periodoini as
 (select period_name, start_date
    from GL_PERIOD_STATUSES
   where set_of_books_id IN
         (SELECT gllv.ledger_id
            FROM hr_organization_v         hov,
                 hr_org_details_by_class_v hodbc,
                 gl_ledger_le_v            gllv
           WHERE hov.organization_id = hodbc.organization_id
             AND hov.classification_code = hodbc.classification_code
             AND hov.classification_code = hodbc.org_information_context
             AND hov.classification_code = 'FUN_BUSINESS_UNIT'
             AND hodbc.org_information2 = gllv.legal_entity_id
             AND hodbc.org_information3 = gllv.ledger_id
             AND gllv.legal_entity_name = :P_EMPRESA
             AND hov.status = 'A')
     and application_id = 101
        --and adjustment_period_flag = 'N'
     and period_name = :P_PERIODO_INI),
periodofin as
 (select period_name, start_date
    from GL_PERIOD_STATUSES
   where set_of_books_id IN
         (SELECT gllv.ledger_id
            FROM hr_organization_v         hov,
                 hr_org_details_by_class_v hodbc,
                 gl_ledger_le_v            gllv
           WHERE hov.organization_id = hodbc.organization_id
             AND hov.classification_code = hodbc.classification_code
             AND hov.classification_code = hodbc.org_information_context
             AND hov.classification_code = 'FUN_BUSINESS_UNIT'
             AND hodbc.org_information2 = gllv.legal_entity_id
             AND hodbc.org_information3 = gllv.ledger_id
             AND TRIM(gllv.legal_entity_name) = :P_EMPRESA
             AND hov.status = 'A')
     and application_id = 101
        --and adjustment_period_flag = 'N'
     and period_name = :P_PERIODO_FIN),
Saldos as
 (SELECT puc.cuenta_puc,
         puc.desc_cuenta_puc,
         gcc.segment2 AS cuenta_corp,
         SUM(CASE
               WHEN gb.period_name = periodoini.period_name and
                    gl.name like '%IFRS%' and gb.currency_code = 'COP' THEN
                NVL(gb.begin_balance_dr, 0) - NVL(gb.begin_balance_cr, 0)
               ELSE
                0
             END) AS SaldoIniIfrsCOP,
         SUM(CASE
               WHEN gb.period_name = periodoini.period_name and
                    gl.name like '%IFRS%' and gb.currency_code = 'USD' THEN
                NVL(gb.begin_balance_dr, 0) - NVL(gb.begin_balance_cr, 0)
               ELSE
                0
             END) AS SaldoIniIfrsUSD,
         SUM(CASE
               WHEN gb.period_name = periodoini.period_name and
                    gl.name like '%PRIM%' and gb.currency_code = 'COP' THEN
                NVL(gb.begin_balance_dr, 0) - NVL(gb.begin_balance_cr, 0)
               ELSE
                0
             END) AS SaldoIniFiscalCOP,
         SUM(CASE
               WHEN gb.period_name = periodoini.period_name and
                    gl.name not like '%IFRS%' and gb.currency_code = 'USD' THEN
                NVL(gb.begin_balance_dr, 0) - NVL(gb.begin_balance_cr, 0)
               ELSE
                0
             END) AS SaldoIniFiscalUSD,
         SUM(CASE
               WHEN gl.name like '%IFRS%' and gb.currency_code = 'COP' THEN
                NVL(gb.period_net_dr, 0) - NVL(gb.period_net_cr, 0)
               ELSE
                0
             END) AS NetoPeriodoIfrsCOP,
         SUM(CASE
               WHEN gl.name like '%IFRS%' and gb.currency_code = 'USD' THEN
                NVL(gb.period_net_dr, 0) - NVL(gb.period_net_cr, 0)
               ELSE
                0
             END) AS NetoPeriodoIfrsUSD,
         SUM(CASE
               WHEN gl.name like '%PRIM%' and gb.currency_code = 'COP' THEN
                NVL(gb.period_net_dr, 0) - NVL(gb.period_net_cr, 0)
               ELSE
                0
             END) AS NetoPeriodoFiscalCOP,
         SUM(CASE
               WHEN gl.name not like '%IFRS%' and gb.currency_code = 'USD' THEN
                NVL(gb.period_net_dr, 0) - NVL(gb.period_net_cr, 0)
               ELSE
                0
             END) AS NetoPeriodoFiscalUSD
    FROM gl_balances          gb,
         gl_code_combinations gcc,
         gl_ledgers           gl,
         gl_period_statuses   gps,
         puc,
         periodoini,
         periodofin
   WHERE gb.code_combination_id = gcc.code_combination_id
     AND gb.ledger_id = gl.ledger_id
     AND gl.ledger_id in
         (SELECT ledger_id
            FROM gl_ledger_le_v
           WHERE TRIM(legal_entity_name) = :P_EMPRESA)
     AND gb.period_name = gps.period_name
     AND gb.actual_flag = 'A'
     AND gb.currency_code = gl.currency_code
     AND gcc.summary_flag = 'N'
     AND gps.application_id = 101
     AND gps.set_of_books_id = gl.ledger_id
        --AND gps.adjustment_period_flag = 'N'
     AND trunc(gps.start_date) between trunc(periodoini.start_date) and
         trunc(periodofin.start_date)
     AND gcc.segment7 = puc.cuenta_puc
     AND gcc.segment5 IN (:P_BILL_CODE)
   GROUP BY puc.cuenta_puc, puc.desc_cuenta_puc, gcc.segment2)
select cuenta_puc,
       desc_cuenta_puc,
       cuenta_corp,
       SaldoIniIfrsCOP,
       NetoPeriodoIfrsCOP,
       SaldoIniIfrsCOP + NetoPeriodoIfrsCOP SaldoFinIfrsCOP,
       SaldoIniIfrsUSD,
       NetoPeriodoIfrsUSD,
       SaldoIniIfrsUSD + NetoPeriodoIfrsUSD SaldoFinIfrsUSD,
       SaldoIniFiscalCOP,
       NetoPeriodoFiscalCOP,
       SaldoIniFiscalCOP + NetoPeriodoFiscalCOP SaldoFinFiscalCOP,
       SaldoIniFiscalUSD,
       NetoPeriodoFiscalUSD,
       SaldoIniFiscalUSD + NetoPeriodoFiscalUSD SaldoFinFiscalUSD
  from Saldos
 order by rpad(cuenta_puc, 10, ';')