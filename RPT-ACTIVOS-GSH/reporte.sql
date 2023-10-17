WITH
TS_DEPRECIACION_YTD AS
(
SELECT FDS.ASSET_ID,
       FDS.BOOK_TYPE_CODE,
       --FDP.PERIOD_NAME,
       MAX(FDP.PERIOD_NUM) AS PERIOD_NUM,
       FDP.FISCAL_YEAR,
       SUM((CASE
              WHEN FDS.BOOK_TYPE_CODE LIKE '%COP%' AND FDP.PERIOD_NUM = 1 THEN
                FDS.DEPRN_AMOUNT
				WHEN FDS.BOOK_TYPE_CODE LIKE '%CAD%' AND FDP.PERIOD_NUM = 1 THEN
                FDS.DEPRN_AMOUNT
              WHEN FDS.BOOK_TYPE_CODE NOT LIKE '%COP%' AND FDP.PERIOD_NUM = 1 THEN
                FMDS.DEPRN_AMOUNT
             ELSE
                0
            END)) AS DEPRN_AMOUNT_ENE,
       SUM((CASE
              WHEN FDS.BOOK_TYPE_CODE LIKE '%COP%' AND FDP.PERIOD_NUM = 2 THEN
                FDS.DEPRN_AMOUNT
				WHEN FDS.BOOK_TYPE_CODE LIKE '%CAD%' AND FDP.PERIOD_NUM = 2 THEN
                FDS.DEPRN_AMOUNT
              WHEN FDS.BOOK_TYPE_CODE NOT LIKE '%COP%' AND FDP.PERIOD_NUM = 2 THEN
                FMDS.DEPRN_AMOUNT
              ELSE
                0
            END)) AS DEPRN_AMOUNT_FEB,
       SUM((CASE
              WHEN FDS.BOOK_TYPE_CODE LIKE '%COP%' AND FDP.PERIOD_NUM = 3 THEN
                FDS.DEPRN_AMOUNT
				WHEN FDS.BOOK_TYPE_CODE LIKE '%CAD%' AND FDP.PERIOD_NUM = 3 THEN
                FDS.DEPRN_AMOUNT
              WHEN FDS.BOOK_TYPE_CODE NOT LIKE '%COP%' AND FDP.PERIOD_NUM = 3 THEN
                FMDS.DEPRN_AMOUNT
              ELSE
                0
            END)) AS DEPRN_AMOUNT_MAR,
       SUM((CASE
              WHEN FDS.BOOK_TYPE_CODE LIKE '%COP%' AND FDP.PERIOD_NUM = 4 THEN
                FDS.DEPRN_AMOUNT
				WHEN FDS.BOOK_TYPE_CODE LIKE '%CAD%' AND FDP.PERIOD_NUM = 4 THEN
                FDS.DEPRN_AMOUNT
              WHEN FDS.BOOK_TYPE_CODE NOT LIKE '%COP%' AND FDP.PERIOD_NUM = 4 THEN
                FMDS.DEPRN_AMOUNT
              ELSE
                0
            END)) AS DEPRN_AMOUNT_ABR,
       SUM((CASE
              WHEN FDS.BOOK_TYPE_CODE LIKE '%COP%' AND FDP.PERIOD_NUM = 5 THEN
                FDS.DEPRN_AMOUNT
				WHEN FDS.BOOK_TYPE_CODE LIKE '%CAD%' AND FDP.PERIOD_NUM = 5 THEN
                FDS.DEPRN_AMOUNT
              WHEN FDS.BOOK_TYPE_CODE NOT LIKE '%COP%' AND FDP.PERIOD_NUM = 5 THEN
                FMDS.DEPRN_AMOUNT
              ELSE
                0
            END)) AS DEPRN_AMOUNT_MAY,
       SUM((CASE
              WHEN FDS.BOOK_TYPE_CODE LIKE '%COP%' AND FDP.PERIOD_NUM = 6 THEN
                FDS.DEPRN_AMOUNT
				WHEN FDS.BOOK_TYPE_CODE LIKE '%CAD%' AND FDP.PERIOD_NUM = 6 THEN
                FDS.DEPRN_AMOUNT
              WHEN FDS.BOOK_TYPE_CODE NOT LIKE '%COP%' AND FDP.PERIOD_NUM = 6 THEN
                FMDS.DEPRN_AMOUNT
              ELSE
                0
            END)) AS DEPRN_AMOUNT_JUN,
       SUM((CASE
              WHEN FDS.BOOK_TYPE_CODE LIKE '%COP%' AND FDP.PERIOD_NUM = 7 THEN
                FDS.DEPRN_AMOUNT
				WHEN FDS.BOOK_TYPE_CODE LIKE '%CAD%' AND FDP.PERIOD_NUM = 7 THEN
                FDS.DEPRN_AMOUNT
              WHEN FDS.BOOK_TYPE_CODE NOT LIKE '%COP%' AND FDP.PERIOD_NUM = 7 THEN
                FMDS.DEPRN_AMOUNT
              ELSE
                0
            END)) AS DEPRN_AMOUNT_JUL,
       SUM((CASE
              WHEN FDS.BOOK_TYPE_CODE LIKE '%COP%' AND FDP.PERIOD_NUM = 8 THEN
                FDS.DEPRN_AMOUNT
				WHEN FDS.BOOK_TYPE_CODE LIKE '%CAD%' AND FDP.PERIOD_NUM = 8 THEN
                FDS.DEPRN_AMOUNT
              WHEN FDS.BOOK_TYPE_CODE NOT LIKE '%COP%' AND FDP.PERIOD_NUM = 8 THEN
                FMDS.DEPRN_AMOUNT
              ELSE
                0
            END)) AS DEPRN_AMOUNT_AGO,
       SUM((CASE
              WHEN FDS.BOOK_TYPE_CODE LIKE '%COP%' AND FDP.PERIOD_NUM = 9 THEN
                FDS.DEPRN_AMOUNT
				WHEN FDS.BOOK_TYPE_CODE LIKE '%CAD%' AND FDP.PERIOD_NUM = 9 THEN
                FDS.DEPRN_AMOUNT
              WHEN FDS.BOOK_TYPE_CODE NOT LIKE '%COP%' AND FDP.PERIOD_NUM = 9 THEN
                FMDS.DEPRN_AMOUNT
              ELSE
                0
            END)) AS DEPRN_AMOUNT_SEP,
       SUM((CASE
              WHEN FDS.BOOK_TYPE_CODE LIKE '%COP%' AND FDP.PERIOD_NUM = 10 THEN
                FDS.DEPRN_AMOUNT
				WHEN FDS.BOOK_TYPE_CODE LIKE '%CAD%' AND FDP.PERIOD_NUM = 10 THEN
                FDS.DEPRN_AMOUNT
              WHEN FDS.BOOK_TYPE_CODE NOT LIKE '%COP%' AND FDP.PERIOD_NUM = 10 THEN
                FMDS.DEPRN_AMOUNT
              ELSE
                0
            END)) AS DEPRN_AMOUNT_OCT,
       SUM((CASE
              WHEN FDS.BOOK_TYPE_CODE LIKE '%COP%' AND FDP.PERIOD_NUM = 11 THEN
                FDS.DEPRN_AMOUNT
				WHEN FDS.BOOK_TYPE_CODE LIKE '%CAD%' AND FDP.PERIOD_NUM = 11 THEN
                FDS.DEPRN_AMOUNT
              WHEN FDS.BOOK_TYPE_CODE NOT LIKE '%COP%' AND FDP.PERIOD_NUM = 11 THEN
                FMDS.DEPRN_AMOUNT
              ELSE
                0
            END)) AS DEPRN_AMOUNT_NOV,
       SUM((CASE
              WHEN FDS.BOOK_TYPE_CODE LIKE '%COP%' AND FDP.PERIOD_NUM = 12 THEN
                FDS.DEPRN_AMOUNT
				WHEN FDS.BOOK_TYPE_CODE LIKE '%CAD%' AND FDP.PERIOD_NUM = 12 THEN
                FDS.DEPRN_AMOUNT
              WHEN FDS.BOOK_TYPE_CODE NOT LIKE '%COP%' AND FDP.PERIOD_NUM = 12 THEN
                FMDS.DEPRN_AMOUNT
              ELSE
                0
            END)) AS DEPRN_AMOUNT_DIC,
       SUM((CASE
              WHEN FDS.BOOK_TYPE_CODE LIKE '%COP%' THEN
                FDS.DEPRN_AMOUNT
				WHEN FDS.BOOK_TYPE_CODE LIKE '%CAD%' THEN
                FDS.DEPRN_AMOUNT
              WHEN FDS.BOOK_TYPE_CODE NOT LIKE '%COP%' THEN
                FMDS.DEPRN_AMOUNT
              ELSE
                0
            END)) AS DEPRN_AMOUNT_TOTAL
  FROM FA_BOOKS_SUMMARY        FDS,
       FA_DEPRN_PERIODS        FDP,
       FA_MC_DEPRN_SUMMARY     FMDS
 WHERE FDS.BOOK_TYPE_CODE = FDP.BOOK_TYPE_CODE
   AND FDS.PERIOD_COUNTER = FDP.PERIOD_COUNTER
   AND FDS.ASSET_ID = FMDS.ASSET_ID(+)
   AND FDS.BOOK_TYPE_CODE = FMDS.BOOK_TYPE_CODE(+)
   AND FDS.PERIOD_COUNTER = FMDS.PERIOD_COUNTER(+)
   AND FDP.FISCAL_YEAR = :P_YEAR
 GROUP BY FDS.ASSET_ID,
          FDS.BOOK_TYPE_CODE,
          FDP.FISCAL_YEAR
)

SELECT REP.ASSET_NUMBER,
       REP.BOOK_TYPE_CODE,
       REP.MONEDA,
       REP.COMPANY,
       REP.CURRENT_UNITS,
       REP.GRUPO,
       REP.CLASSIFICATION,
       REP.DEDUCIBLE,
       REP.FASE,
       REP.CATEGORIA,
       REP.LOCATION,
       REP.CGU,
       REP.CECO,
       REP.NAME_CECO,
       REP.GRUPO_ACTIVO,
       REP.AFE,
       REP.DESCRIPTION,
       REP.PUC_COSTO,
       REP.PUC_D,
       REP.PUC_E,
       REP.CORP_COSTO,
       REP.CORP_D,
       REP.CORP_E,
       REP.DATE_PLACED_IN_SERVICE,
       REP.METHOD_CODE,
       REP.LIFE,
       REP.AF_IDEAS, 
       REP.STATUS, 
       REP.COST,
       REP.COST_HISTORICO,
       REP.BALANT_DEPR - REP.TOT_ANU AS BALANT_DEPR,
       REP.ENE,
       REP.FEB,
       REP.MAR,
       REP.ABR,
       REP.MAY,
       REP.JUN,
       REP.JUL,
       REP.AGO,
       REP.SEP,
       REP.OCT,
       REP.NOV,
       REP.DIC,
       REP.TOT_ANU,
       REP.BALANT_DEPR AS TOT_ACU,
	   --CASE WHEN 
       --(NVL(REP.COST_HISTORICO,0) - NVL(REP.BALANT_DEPR,0)) < 0 THEN 0
       -- ELSE NVL(REP.COST_HISTORICO,0) - NVL(REP.BALANT_DEPR,0) END AS BOOK_VALUE
	   NVL(REP.COST,0) - NVL(REP.BALANT_DEPR,0) AS BOOK_VALUE
  FROM (SELECT FAB.ASSET_NUMBER,
               FAB.ASSET_ID,
               FAB.CURRENT_UNITS,
               FAB.CREATION_DATE,
               FAB.ATTRIBUTE3 GRUPO_ACTIVO,
               NVL(FAB.ATTRIBUTE4, GCC1.SEGMENT4) AFE,
               FAT.DESCRIPTION,
               FC.SEGMENT1 GRUPO,
               FC.SEGMENT2 CLASSIFICATION,
               FC.SEGMENT3 DEDUCIBLE,
               FAK.SEGMENT1 FASE,
               FAK.SEGMENT2 CATEGORIA,
               FDH.BOOK_TYPE_CODE,
               (CASE
                  WHEN FDH.BOOK_TYPE_CODE LIKE '%COP%' THEN 'COP'
                  WHEN FDH.BOOK_TYPE_CODE LIKE '%USD%' THEN 'USD'
                  WHEN FDH.BOOK_TYPE_CODE LIKE '%CAD%' THEN 'CAD'
                END) AS MONEDA,
               GCC1.SEGMENT1 COMPANY,
               FL.SEGMENT2 LOCATION,
               FL.SEGMENT3 CGU,
               GCC4.SEGMENT3 CECO,
               (SELECT FFVT.DESCRIPTION
                  FROM FND_FLEX_VALUE_SETS     FFVS,
                       FND_FLEX_VALUES         FFV,
                       FND_FLEX_VALUES_TL      FFVT
                 WHERE FFVS.FLEX_VALUE_SET_ID = FFV.FLEX_VALUE_SET_ID
                   AND FFV.FLEX_VALUE_ID = FFVT.FLEX_VALUE_ID
                   AND FFVS.FLEX_VALUE_SET_NAME = 'CNC_CENTRO_COSTO'
                   AND FFV.SUMMARY_FLAG = 'N'
                   AND FFVT.LANGUAGE = 'E'
                   AND FFV.FLEX_VALUE = GCC4.SEGMENT3) NAME_CECO,
               TO_CHAR(FBO.DATE_PLACED_IN_SERVICE,'DD/MM/YYYY') AS DATE_PLACED_IN_SERVICE,
               CASE
                 WHEN (FBO.BOOK_TYPE_CODE LIKE '%COP%' OR FBO.BOOK_TYPE_CODE LIKE '%CAD%') THEN
                   FBO.COST
                 ELSE
                   (SELECT COST
                      FROM FA_MC_BOOKS    FMBO
                     WHERE FMBO.TRANSACTION_HEADER_ID_IN = FBO.TRANSACTION_HEADER_ID_IN 
                       AND FMBO.ASSET_ID = FBO.ASSET_ID
                       AND FMBO.DATE_INEFFECTIVE IS NULL)
               END AS COST_HISTORICO,
               CASE
                 WHEN (FBO.BOOK_TYPE_CODE LIKE '%COP%' OR FBO.BOOK_TYPE_CODE LIKE '%CAD%') THEN
                   FBO.ORIGINAL_COST
                 ELSE
                   (SELECT FMBO.ORIGINAL_COST
                      FROM FA_MC_BOOKS    FMBO
                     WHERE FMBO.TRANSACTION_HEADER_ID_IN = FBO.TRANSACTION_HEADER_ID_IN 
                       AND FMBO.ASSET_ID = FBO.ASSET_ID
                       AND FMBO.DATE_INEFFECTIVE IS NULL)
               END AS COST,
               CASE
                 WHEN (FBO.BOOK_TYPE_CODE LIKE '%COP%' OR FBO.BOOK_TYPE_CODE LIKE '%CAD%') THEN
                    NVL((SELECT FBS.DEPRN_RESERVE 
                           FROM FA_BOOKS_SUMMARY  FBS
                          WHERE FBS.ASSET_ID = FAB.ASSET_ID
                            AND decode(FBS.FISCAL_YEAR, '','2022',FBS.FISCAL_YEAR) = :P_YEAR
                            AND FBS.BOOK_TYPE_CODE = FBO.BOOK_TYPE_CODE
                            AND FBS.PERIOD_COUNTER = (SELECT MAX(FBS1.PERIOD_COUNTER)
                                                        FROM FA_BOOKS_SUMMARY  FBS1
                                                       WHERE FBS1.ASSET_ID = FBS.ASSET_ID
                                                         AND decode(FBS1.FISCAL_YEAR, '','2022',FBS1.FISCAL_YEAR) = decode(FBS.FISCAL_YEAR, '','2022',FBS.FISCAL_YEAR)
                                                         AND FBS1.BOOK_TYPE_CODE = FBS.BOOK_TYPE_CODE)),0)
                 ELSE
                    NVL((SELECT FMBS.DEPRN_RESERVE 
                           FROM FA_MC_BOOKS_SUMMARY  FMBS
                          WHERE FMBS.ASSET_ID = FAB.ASSET_ID
                            AND decode(FMBS.FISCAL_YEAR, '','2022',FMBS.FISCAL_YEAR) = :P_YEAR
                            AND FMBS.BOOK_TYPE_CODE = FBO.BOOK_TYPE_CODE
                            AND FMBS.PERIOD_COUNTER = (SELECT MAX(FMBS1.PERIOD_COUNTER)
                                                        FROM FA_MC_BOOKS_SUMMARY  FMBS1
                                                       WHERE FMBS1.ASSET_ID = FMBS.ASSET_ID
                                                         AND decode(FMBS1.FISCAL_YEAR, '','2022',FMBS1.FISCAL_YEAR) = decode(FMBS.FISCAL_YEAR, '','2022',FMBS.FISCAL_YEAR)
                                                         AND FMBS1.BOOK_TYPE_CODE = FMBS.BOOK_TYPE_CODE)),0)
               END AS BALANT_DEPR,
               NVL(TDY.DEPRN_AMOUNT_ENE,0) AS ENE,
               NVL(TDY.DEPRN_AMOUNT_FEB,0) AS FEB,
               NVL(TDY.DEPRN_AMOUNT_MAR,0) AS MAR,
               NVL(TDY.DEPRN_AMOUNT_ABR,0) AS ABR,
               NVL(TDY.DEPRN_AMOUNT_MAY,0) AS MAY,
               NVL(TDY.DEPRN_AMOUNT_JUN,0) AS JUN,
               NVL(TDY.DEPRN_AMOUNT_JUL,0) AS JUL,
               NVL(TDY.DEPRN_AMOUNT_AGO,0) AS AGO,
               NVL(TDY.DEPRN_AMOUNT_SEP,0) AS SEP,
               NVL(TDY.DEPRN_AMOUNT_OCT,0) AS OCT,
               NVL(TDY.DEPRN_AMOUNT_NOV,0) AS NOV,
               NVL(TDY.DEPRN_AMOUNT_DIC,0) AS DIC,
               NVL(TDY.DEPRN_AMOUNT_TOTAL,0) AS TOT_ANU,
               FM.METHOD_CODE,
               (SELECT DISTINCT CASE
                  WHEN FTH.TRANSACTION_TYPE_CODE = 'FULL RETIREMENT' THEN
                                   'Baja'
                                  ELSE  
                                   'Alta'
                                END status
                  FROM FA_TRANSACTION_HEADERS FTH
                 WHERE FTH.ASSET_ID = FAB.ASSET_ID
                   AND FTH.BOOK_TYPE_CODE = FBO.BOOK_TYPE_CODE
                   AND FTH.TRANSACTION_HEADER_ID = (SELECT MAX(FTH1.TRANSACTION_HEADER_ID)
                                                      FROM FA_TRANSACTION_HEADERS FTH1
                                                     WHERE FTH1.ASSET_ID = FAB.ASSET_ID
                                                       AND FTH1.BOOK_TYPE_CODE = FBO.BOOK_TYPE_CODE)) AS STATUS,
               ROUND(FM.LIFE_IN_MONTHS / 12, 2) AS LIFE,
               FAB.ATTRIBUTE6 AS AF_IDEAS,
               GCC1.SEGMENT7 AS PUC_COSTO,
               GCC3.SEGMENT7 AS PUC_D,
               GCC4.SEGMENT7 AS PUC_E,
               GCC1.SEGMENT2 AS CORP_COSTO,
               GCC3.SEGMENT2 AS CORP_D,
               GCC4.SEGMENT2 AS CORP_E,
               NVL(TDY.FISCAL_YEAR, :P_YEAR) AS FISCAL_YEAR
          FROM FA_ADDITIONS_B          FAB,
               FA_ADDITIONS_TL         FAT,
               FA_CATEGORIES_B         FC,
               FA_ASSET_KEYWORDS       FAK,
               FA_BOOKS                FBO,
               FA_CATEGORY_BOOKS       FCB,
               FA_DISTRIBUTION_HISTORY FDH,
               FA_LOCATIONS            FL,
               FA_METHODS              FM,
               TS_DEPRECIACION_YTD     TDY,
               GL_CODE_COMBINATIONS    GCC1,
               GL_CODE_COMBINATIONS    GCC3,
               GL_CODE_COMBINATIONS    GCC4
         WHERE 1 = 1
           AND FAB.ASSET_ID = FAT.ASSET_ID
           AND FAT.LANGUAGE = USERENV('LANG')
           AND FAB.ASSET_CATEGORY_ID = FC.CATEGORY_ID(+)
           AND FC.CATEGORY_ID = FCB.CATEGORY_ID(+)
           AND FAB.ASSET_ID = FBO.ASSET_ID
           AND FBO.DATE_INEFFECTIVE IS NULL
           AND FBO.BOOK_TYPE_CODE = FCB.BOOK_TYPE_CODE
           AND FAB.ASSET_KEY_CCID = FAK.CODE_COMBINATION_ID(+)
           AND FAB.ASSET_ID = FDH.ASSET_ID
           AND FBO.BOOK_TYPE_CODE = FDH.BOOK_TYPE_CODE
           AND FDH.DATE_INEFFECTIVE IS NULL
           AND FDH.LOCATION_ID = FL.LOCATION_ID
           AND FBO.METHOD_ID = FM.METHOD_ID
           --
           AND FAB.ASSET_ID = TDY.ASSET_ID(+)
           AND FBO.BOOK_TYPE_CODE = TDY.BOOK_TYPE_CODE(+)
           --
           AND FCB.ASSET_COST_ACCOUNT_CCID = GCC1.CODE_COMBINATION_ID
           AND FCB.RESERVE_ACCOUNT_CCID = GCC3.CODE_COMBINATION_ID
           AND FDH.CODE_COMBINATION_ID = GCC4.CODE_COMBINATION_ID) REP

 WHERE 1 = 1
   AND REP.FISCAL_YEAR IN (:P_YEAR)
   AND REP.COMPANY IN (:P_COMPANY)
   AND REP.BOOK_TYPE_CODE IN (:P_LIBRO)
   AND REP.MONEDA IN NVL(:P_MONEDA)
   AND REP.FASE IN (:P_FASE)
   AND REP.CGU IN (:P_CGU)

 ORDER BY REP.BOOK_TYPE_CODE, REP.ASSET_NUMBER




