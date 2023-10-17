with t as
(
    SELECT
    ffv.flex_value AS cuenta,
    ffvt.description AS descripcion
    FROM
    fnd_flex_value_sets ffvs,
    fnd_flex_values ffv,
    fnd_flex_values_tl ffvt
    WHERE
    ffvs.flex_value_set_id = ffv.flex_value_set_id
    AND ffv.flex_value_id = ffvt.flex_value_id
    AND ffvs.flex_value_set_name = 'CNC_PUC'
    AND ffvt.language = :P_IDIOMA
    AND ffvt.description <> 'NULL'
), puc as
(
    SELECT SUBSTR(cuenta,1,1) AS CuentaPuc1,
    SUBSTR(cuenta,1,2) AS CuentaPuc2,
    SUBSTR(cuenta,1,4) AS CuentaPuc4,
    SUBSTR(cuenta,1,6) AS CuentaPuc6,
    SUBSTR(cuenta,1,8) AS CuentaPuc8,
    cuenta,
    descripcion,
    length(cuenta) nivel
    from t
), Saldos as
(
    SELECT
    SUBSTR(gcc.segment7,1,1) AS CuentaPuc1,
    SUBSTR(gcc.segment7,1,2) AS CuentaPuc2,
    SUBSTR(gcc.segment7,1,4) AS CuentaPuc4,
    SUBSTR(gcc.segment7,1,6) AS CuentaPuc6,
    SUBSTR(gcc.segment7,1,8) AS CuentaPuc8,
    gcc.segment7 AS CuentaPuc10,
    gcc.segment2 AS CuentaCorp,
	SUM(
		CASE WHEN gl.name like '%IFRS%' and gb.currency_code = 'COP' THEN NVL(gb.begin_balance_dr, 0) - NVL (gb.begin_balance_cr, 0)
		ELSE 0 END) AS SaldoIniIfrsCOP,
	SUM(
		CASE WHEN gl.name like '%IFRS%' and gb.currency_code = 'USD' THEN NVL(gb.begin_balance_dr, 0) - NVL (gb.begin_balance_cr, 0)
		ELSE 0 END) AS SaldoIniIfrsUSD,
	SUM(
		CASE WHEN gl.name like '%PRIM%' and gb.currency_code = 'COP' THEN NVL(gb.begin_balance_dr, 0) - NVL (gb.begin_balance_cr, 0)
		ELSE 0 END) AS SaldoIniFiscalCOP,
	SUM(
		CASE WHEN gl.name not like '%IFRS%' and gb.currency_code = 'USD' THEN NVL(gb.begin_balance_dr, 0) - NVL (gb.begin_balance_cr, 0)
		ELSE 0 END) AS SaldoIniFiscalUSD,
	SUM(
		CASE WHEN gl.name like '%IFRS%' and gb.currency_code = 'COP' THEN NVL(gb.period_net_dr, 0) - NVL(gb.period_net_cr, 0)
		ELSE 0 END) AS NetoPeriodoIfrsCOP,
	SUM(
		CASE WHEN gl.name like '%IFRS%' and gb.currency_code = 'USD' THEN NVL(gb.period_net_dr, 0) - NVL(gb.period_net_cr, 0)
		ELSE 0 END) AS NetoPeriodoIfrsUSD,
	SUM(
		CASE WHEN gl.name like '%PRIM%' and gb.currency_code = 'COP' THEN NVL(gb.period_net_dr, 0) - NVL(gb.period_net_cr, 0)
		ELSE 0 END) AS NetoPeriodoFiscalCOP,
	SUM(
		CASE WHEN gl.name not like '%IFRS%' and gb.currency_code = 'USD' THEN NVL(gb.period_net_dr, 0) - NVL(gb.period_net_cr, 0)
		ELSE 0 END) AS NetoPeriodoFiscalUSD
    FROM
    gl_balances gb,
    gl_code_combinations gcc,
    gl_ledgers gl
    WHERE
    gb.code_combination_id = gcc.code_combination_id
    AND gb.ledger_id = gl.ledger_id
    AND gl.ledger_id in (SELECT ledger_id
                          FROM gl_ledger_le_v 
                         WHERE TRIM(legal_entity_name) = :P_EMPRESA)
    AND gb.period_name = :P_PERIODO
    AND gb.actual_flag = 'A'
	AND gb.currency_code = gl.currency_code
    AND gcc.segment5 IN (:P_BILL_CODE)
    AND gcc.summary_flag = 'N'
    GROUP BY
    gcc.segment7,
	gcc.segment2
), SaldoSum as
(
select
puc.nivel,
puc.cuentapuc1,
puc.cuentapuc2,
puc.cuentapuc4,
puc.cuentapuc6,
puc.cuentapuc8,
puc.cuenta,
puc.descripcion,
saldos.cuentacorp,
sum(Saldos.SaldoIniIfrsCOP) SaldoIniIfrsCOP,
sum(Saldos.SaldoIniIfrsUSD) SaldoIniIfrsUSD,
sum(Saldos.SaldoIniFiscalCOP) SaldoIniFiscalCOP,
sum(Saldos.SaldoIniFiscalUSD) SaldoIniFiscalUSD,
sum(Saldos.NetoPeriodoIfrsCOP) NetoPeriodoIfrsCOP,
sum(Saldos.NetoPeriodoIfrsUSD) NetoPeriodoIfrsUSD,
sum(Saldos.NetoPeriodoFiscalCOP) NetoPeriodoFiscalCOP,
sum(Saldos.NetoPeriodoFiscalUSD) NetoPeriodoFiscalUSD
from
puc
inner join Saldos on (puc.nivel = 10 and puc.cuenta = Saldos.cuentapuc10)
group by
puc.nivel,
puc.cuentapuc1,
puc.cuentapuc2,
puc.cuentapuc4,
puc.cuentapuc6,
puc.cuentapuc8,
puc.cuenta,
puc.descripcion,
saldos.cuentacorp
)
select
nivel,
cuenta cuentapuc,
descripcion desc_cuentapuc,
cuentacorp,
SaldoIniIfrsCOP + NetoPeriodoIfrsCOP SaldoFinIfrsCOP,
SaldoIniIfrsUSD + NetoPeriodoIfrsUSD SaldoFinIfrsUSD,
SaldoIniFiscalCOP + NetoPeriodoFiscalCOP SaldoFinFiscalCOP,
SaldoIniFiscalUSD + NetoPeriodoFiscalUSD SaldoFinFiscalUSD
from
SaldoSum
order by rpad(cuenta,10,';')