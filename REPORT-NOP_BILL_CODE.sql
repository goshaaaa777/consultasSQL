WITH 
tbl_cta_desc AS 
(
	SELECT
	ffv.flex_value AS Cuenta,
	ffvt.description AS Descripcion
	FROM
	fnd_flex_value_sets  ffvs,
	fnd_flex_values      ffv,
	fnd_flex_values_tl   ffvt
	WHERE
	ffvs.flex_value_set_name = 'CNC_CUENTA'
	AND ffvs.flex_value_set_id = ffv.flex_value_set_id
	AND ffv.flex_value_id = ffvt.flex_value_id
	AND ffvt.description <> 'NULL'
	AND ffvt.language = :P_IDIOMA
), periodoini as
(
	select
	period_name, start_date
	from
	GL_PERIOD_STATUSES
	where
	set_of_books_id IN (SELECT gllv.ledger_id
                          FROM hr_organization_v         hov
                              ,hr_org_details_by_class_v hodbc
                              ,gl_ledger_le_v            gllv
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
	and period_name = :P_PERIODO_INI
), periodofin as
(
	select
	period_name, start_date
	from
	GL_PERIOD_STATUSES
	where
	set_of_books_id IN (SELECT gllv.ledger_id
                          FROM hr_organization_v         hov
                              ,hr_org_details_by_class_v hodbc
                              ,gl_ledger_le_v            gllv
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
	and period_name = :P_PERIODO_FIN
), Saldos as
(
SELECT
gcc.segment2 AS Cuenta,
cta.Descripcion AS Nombre_Cuenta,
SUM(
	CASE WHEN gb.period_name = (select period_name from periodoini) and gl.name like '%IFRS%' and gb.currency_code = 'COP' THEN NVL(gb.begin_balance_dr, 0) - NVL (gb.begin_balance_cr, 0)
	ELSE 0 END) AS SaldoIniIfrsCOP,
SUM(
	CASE WHEN gb.period_name = (select period_name from periodoini) and gl.name like '%IFRS%' and gb.currency_code = 'USD' THEN NVL(gb.begin_balance_dr, 0) - NVL (gb.begin_balance_cr, 0)
	ELSE 0 END) AS SaldoIniIfrsUSD,
SUM(
	CASE WHEN gb.period_name = (select period_name from periodoini) and gl.name not like '%IFRS%' and gb.currency_code = 'COP' THEN NVL(gb.begin_balance_dr, 0) - NVL (gb.begin_balance_cr, 0)
	ELSE 0 END) AS SaldoIniFiscalCOP,
SUM(
	CASE WHEN gb.period_name = (select period_name from periodoini) and gl.name not like '%IFRS%' and gb.currency_code = 'USD' THEN NVL(gb.begin_balance_dr, 0) - NVL (gb.begin_balance_cr, 0)
	ELSE 0 END) AS SaldoIniFiscalUSD,
SUM(
	CASE WHEN gl.name like '%IFRS%' and gb.currency_code = 'COP' THEN NVL(gb.period_net_dr, 0) - NVL(gb.period_net_cr, 0)
	ELSE 0 END) AS NetoPeriodoIfrsCOP,
SUM(
	CASE WHEN gl.name like '%IFRS%' and gb.currency_code = 'USD' THEN NVL(gb.period_net_dr, 0) - NVL(gb.period_net_cr, 0)
	ELSE 0 END) AS NetoPeriodoIfrsUSD,
SUM(
	CASE WHEN gl.name not like '%IFRS%' and gb.currency_code = 'COP' THEN NVL(gb.period_net_dr, 0) - NVL(gb.period_net_cr, 0)
	ELSE 0 END) AS NetoPeriodoFiscalCOP,
SUM(
	CASE WHEN gl.name not like '%IFRS%' and gb.currency_code = 'USD' THEN NVL(gb.period_net_dr, 0) - NVL(gb.period_net_cr, 0)
	ELSE 0 END) AS NetoPeriodoFiscalUSD
FROM
gl_balances          gb,
gl_code_combinations gcc,
gl_ledgers           gl,
tbl_cta_desc         cta,
gl_period_statuses gps,
periodoini,
periodofin
WHERE
gb.code_combination_id = gcc.code_combination_id
AND gb.ledger_id = gl.ledger_id
AND gb.period_name = gps.period_name
AND gb.currency_code = gl.currency_code
AND gcc.segment2 = cta.Cuenta
AND gl.ledger_id IN (SELECT ledger_id
					FROM gl_ledger_le_v 
					WHERE legal_entity_name = :P_EMPRESA)
AND gb.actual_flag = 'A'
AND gcc.summary_flag = 'N'
AND gps.application_id = 101
AND GCC.SEGMENT5 IN (:P_BILL_CODE) --
AND gps.set_of_books_id = gl.ledger_id
--AND gps.adjustment_period_flag = 'N'
AND trunc(gps.start_date) between trunc(periodoini.start_date) and trunc(periodofin.start_date)
GROUP BY
gcc.segment2,
cta.Descripcion
)
SELECT
Cuenta,
Nombre_Cuenta,
SaldoIniIfrsCOP,
SaldoIniIfrsUSD,
SaldoIniFiscalCOP,
SaldoIniFiscalUSD,
NetoPeriodoIfrsCOP,
NetoPeriodoIfrsUSD,
NetoPeriodoFiscalCOP,
NetoPeriodoFiscalUSD,
SaldoIniIfrsCOP + NetoPeriodoIfrsCOP SaldoFinalIFRSCop,
SaldoIniIfrsUSD + NetoPeriodoIfrsUSD SaldoFinalIFRSUSD,
SaldoIniFiscalCOP + NetoPeriodoFiscalCOP SaldoFinalFiscalCop,
SaldoIniFiscalUSD + NetoPeriodoFiscalUSD SaldoFinalFiscalUSD
FROM
Saldos
ORDER BY
Cuenta