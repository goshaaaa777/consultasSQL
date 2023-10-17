SET VARIABLE PREFERRED_CURRENCY='User Preferred Currency 1';SELECT
   0 s_0,
   "Fixed Assets - Asset Transactions Real Time"."Asset Category"."Category Description" s_1,
   "Fixed Assets - Asset Transactions Real Time"."Asset Category"."Category" s_2,
   "Fixed Assets - Asset Transactions Real Time"."Descriptive Details"."FA_ADDITIONS_CNC_AFE_" s_3,
   "Fixed Assets - Asset Transactions Real Time"."Descriptive Details"."FA_ADDITIONS_CNC_F_NF_CNPLNTR_" s_4,
   "Fixed Assets - Asset Transactions Real Time"."Descriptive Details"."FA_ADDITIONS_CNC_F_NR_CT_NTR_" s_5,
   "Fixed Assets - Asset Transactions Real Time"."Descriptive Details"."FA_ADDITIONS_CNC_FA_ETIQUETA_" s_6,
   "Fixed Assets - Asset Transactions Real Time"."Descriptive Details"."FA_ADDITIONS_CNC_FA_GRUPO_ACTIVO_" s_7,
   "Fixed Assets - Asset Transactions Real Time"."Descriptive Details"."FA_ADDITIONS_CNC_SERIAL_" s_8,
   "Fixed Assets - Asset Transactions Real Time"."Descriptive Details"."Manufacturer" s_9,
   "Fixed Assets - Asset Transactions Real Time"."Descriptive Details"."Model" s_10,
   "Fixed Assets - Asset Transactions Real Time"."Descriptive Details"."Physical Inventory Indicator" s_11,
   "Fixed Assets - Asset Transactions Real Time"."General Information"."Asset Number" s_12,
   "Fixed Assets - Asset Transactions Real Time"."General Information"."Description" s_13,
   "Fixed Assets - Asset Transactions Real Time"."General"."Cash Generating Unit" s_14,
   DESCRIPTOR_IDOF("Fixed Assets - Asset Transactions Real Time"."Descriptive Details"."Physical Inventory Indicator") s_15
FROM "Fixed Assets - Asset Transactions Real Time"
ORDER BY 13 ASC NULLS LAST, 14 ASC NULLS LAST, 7 ASC NULLS LAST, 5 ASC NULLS LAST, 8 ASC NULLS LAST, 4 ASC NULLS LAST, 9 ASC NULLS LAST,
 6 ASC NULLS LAST, 10 ASC NULLS LAST, 11 ASC NULLS LAST, 12 ASC NULLS LAST, 15 ASC NULLS LAST, 2 ASC NULLS LAST, 3 ASC NULLS LAST
FETCH FIRST 75001 ROWS ONLY


SET VARIABLE PREFERRED_CURRENCY='User Preferred Currency 1';SELECT
   0 s_0,
   "Fixed Assets - Asset Transactions Real Time"."Asset Category"."Category Description" s_1,
   "Fixed Assets - Asset Transactions Real Time"."Cost Center Segment Value"."Cost Center Description" s_2,
   "Fixed Assets - Asset Transactions Real Time"."Descriptive Details"."FA_ADDITIONS_CNC_AFE_" s_3,
   "Fixed Assets - Asset Transactions Real Time"."Descriptive Details"."FA_ADDITIONS_CNC_F_NF_CNPLNTR_" s_4,
   "Fixed Assets - Asset Transactions Real Time"."Descriptive Details"."FA_ADDITIONS_CNC_F_NR_CT_NTR_" s_5,
   "Fixed Assets - Asset Transactions Real Time"."Descriptive Details"."FA_ADDITIONS_CNC_FA_ETIQUETA_" s_6,
   "Fixed Assets - Asset Transactions Real Time"."Descriptive Details"."FA_ADDITIONS_CNC_FA_GRUPO_ACTIVO_" s_7,
   "Fixed Assets - Asset Transactions Real Time"."Descriptive Details"."FA_ADDITIONS_CNC_SERIAL_" s_8,
   "Fixed Assets - Asset Transactions Real Time"."Descriptive Details"."Manufacturer" s_9,
   "Fixed Assets - Asset Transactions Real Time"."Descriptive Details"."Model" s_10,
   "Fixed Assets - Asset Transactions Real Time"."Descriptive Details"."Physical Inventory Indicator" s_11,
   "Fixed Assets - Asset Transactions Real Time"."General Information"."Asset Number" s_12,
   "Fixed Assets - Asset Transactions Real Time"."General Information"."Description" s_13,
   "Fixed Assets - Asset Transactions Real Time"."General"."Cash Generating Unit" s_14,
   'All' s_15,
   DESCRIPTOR_IDOF("Fixed Assets - Asset Transactions Real Time"."Cost Center Segment Value"."Cost Center Description") s_16,
   DESCRIPTOR_IDOF("Fixed Assets - Asset Transactions Real Time"."Descriptive Details"."Physical Inventory Indicator") s_17,
   IDOF("Fixed Assets - Asset Transactions Real Time"."Cost Center Segment Value"."Cost Center"."All") s_18
FROM "Fixed Assets - Asset Transactions Real Time"
ORDER BY 13 ASC NULLS LAST, 14 ASC NULLS LAST, 7 ASC NULLS LAST, 5 ASC NULLS LAST, 8 ASC NULLS LAST, 4 ASC NULLS LAST, 9 ASC NULLS LAST, 6 ASC NULLS LAST, 10 ASC NULLS LAST, 11 ASC NULLS LAST, 12 ASC NULLS LAST, 18 ASC NULLS LAST, 15 ASC NULLS LAST, 16 ASC NULLS FIRST, 19 ASC NULLS FIRST, 2 ASC NULLS LAST
FETCH FIRST 75001 ROWS ONLY
