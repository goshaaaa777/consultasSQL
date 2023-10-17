select  &BALANCING_SEG_ORDERBY          Bal_Seg,
        PS.start_date                   Period_Date,
	PS.period_name                  Period,
	JEB.name                        Name,
	JEB.posted_date                 Posted_date,
	JEB.creation_date               Created_date,
        JEB.created_by                  BATCH_CREATED_BY,
        JEB.last_updated_by             BATCH_LAST_UPDATED_BY,
        JEB.last_update_date            BATCH_LAST_UPDATE_DATE,
        JEB.last_update_login           BATCH_LAST_UPDATE_LOGIN,
	min(JG_JOURNALS_BATCH_RPT_EXT_PKG.batch_type(JEB.actual_flag)) Batch_Type,
	SRC.user_je_source_name         Source,
	JEH.doc_sequence_value          Seq_Value,
	min(decode(JEH.actual_flag, 'A', null, 'E', JG_JOURNALS_BATCH_RPT_EXT_PKG.enc_type(JEH.encumbrance_type_id))) Encumbrance_Type,
	CAT.user_je_category_name       Category,
	L.name                          LedgerName,
	L.CURRENCY_CODE                 LedgerCurrency,
	--&DEB_SELECT                     Debit,
	--&CRE_SELECT                     Credit,
	SUM(nvl(JEL.entered_dr,0))      Debit,
	SUM(nvl(JEL.entered_cr,0))      Credit,
	&FOR_BAL_SEG                    For_Bal_Seg,
	&FOR_COMP_NAME                  For_Comp_Name
    from	GL_PERIOD_STATUSES   PS,
        GL_JE_HEADERS        JEH,
        GL_JE_LINES          JEL,
        GL_CODE_COMBINATIONS CC,
        GL_JE_BATCHES        JEB,
        GL_JE_CATEGORIES     CAT,
        GL_JE_SOURCES        SRC,
        GL_LEDGERS           L,
	&LEDGER_FROM
	gl_daily_conversion_types gdct
where
	PS.APPLICATION_ID = 101 
and     PS.LEDGER_ID = JEH.LEDGER_ID 
/*and     ( :C_START_DATE between PS.start_date+0 and PS.end_date+0  or  
          :C_END_DATE between PS.start_date+0 and PS.end_date+0    or   
	  (  PS.start_date+0 >= :C_START_DATE and  PS.end_date+0 <= :C_END_DATE )              
	)
*/
and           JEH.period_name      =  PS.period_name
and			  JEH.status           = 'P'
--and           JEH.actual_flag      = 'A'
and           JEH.ledger_id        = L.ledger_id
and      JEL.period_name           =  JEH.period_name
and      JEL.je_header_id          =  JEH.je_header_id
and      JEL.status                = 'P'
-- and      JEL.effective_date between :C_START_DATE and :C_END_DATE
and      CC.code_combination_id   =  JEL.code_combination_id
and      CC.summary_flag          =  'N'
and      CC.template_id is null
and      CC.chart_of_accounts_id  = :STRUCT_NUM
and      CC.detail_posting_allowed_flag = 'Y'
--and      JEB.je_batch_id = decode(CC.code_combination_id, NULL, JEH.je_batch_id, JEH.je_batch_id) -- rrajarap
and      JEB.je_batch_id = JEH.je_batch_id -- rrajarap
--and      CAT.je_category_name = decode(CC.code_combination_id, NULL, JEH.je_category, JEH.je_category)  -- rrajarap
and      CAT.je_category_name = JEH.je_category  -- rrajarap
--and      SRC.je_source_name = decode(CC.code_combination_id, NULL, JEH.je_source, JEH.je_source) -- rrajarap
and      SRC.je_source_name = JEH.je_source -- rrajarap 
/* Fusion initiative multi currency change starts */ 
and  gdct.conversion_type = JEL.currency_conversion_type
/*changed from JEH.currency_conversion_type to JEL.currency_conversion_type. bug 	9198433
/* Fusion initiative multi currency change ends */
/* AND 'Y' != DECODE(TO_NUMBER((SELECT GP1.PERIOD_YEAR
                               FROM GL_PERIODS GP1
                              WHERE GP1.PERIOD_SET_NAME = L.PERIOD_SET_NAME
                                AND GP1.PERIOD_TYPE = L.ACCOUNTED_PERIOD_TYPE
                                AND :P_END_DATE
                                BETWEEN GP1.start_date AND GP1.end_date
                                AND GP1.adjustment_period_flag like decode(:P_ADJUSTMENT_PERIODS,'N','N','%')
                                AND    rownum = 1)) -
                  TO_NUMBER((SELECT GP2.PERIOD_YEAR
                               FROM GL_PERIODS GP2
                              WHERE GP2.PERIOD_SET_NAME = L.PERIOD_SET_NAME
                                AND GP2.PERIOD_TYPE = L.ACCOUNTED_PERIOD_TYPE
                                AND :P_START_DATE
                                BETWEEN GP2.start_date and GP2.end_date
                                AND GP2.adjustment_period_flag like decode(:P_ADJUSTMENT_PERIODS,'N','N','%')
                                AND rownum = 1)), 0, 'N', DECODE(:P_ADJUSTMENT_PERIODS, 'N', 'Y', 'N')) */
AND &C_WHERE_PERIOD
AND &ACCESS_WHERE
AND &LEDGER_WHERE
AND JEL.CURRENCY_CODE = :P_CURRENCY_CODE   -- rrajarap bug # 9195217
AND &BALANCING_SEG_WHERE
AND &BAL_SECURE = 'N'
AND &LP_INCREMENTAL_EXPORT
GROUP BY  &BALANCING_SEG_ORDERBY, --&BALANCING_SEG modified to &BALANCING_SEG_ORDERBY fix for bug # 9195198
          &FOR_BAL_SEG,
          &FOR_COMP_NAME,
          &BAL_SECURE,
          PS.start_date,
          PS.period_name,
          CAT.user_je_category_name,
          JEB.name,
          JEB.actual_flag,
          SRC.user_je_source_name,
          JEH.doc_sequence_value,
          JEH.encumbrance_type_id,
          JEB.creation_date,
          JEB.posted_date,
          JEB.created_by,
          JEB.last_updated_by,
          JEB.last_update_date,
          JEB.last_update_login,
          L.name,
          L.currency_code
	  --,&BALANCING_SEG_ORDERBY
order by  L.name,
          &BALANCING_SEG_ORDERBY,
          PS.start_date,
          CAT.user_je_category_name,
          JEB.name