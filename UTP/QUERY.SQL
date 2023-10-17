--REPORTE 42
with emp as
(
    SELECT   gllv.legal_entity_id,
      gllv.legal_entity_name,
      substr(gllv.ledger_name,1,2) company_nro,
      hov.organization_id
    FROM hr_organization_v hov,
         hr_org_details_by_class_v hodbc,
         gl_ledger_le_v gllv
    WHERE hov.organization_id   = hodbc.organization_id
    AND hov.classification_code = hodbc.classification_code
    AND hov.classification_code = hodbc.org_information_context
    AND hov.classification_code = 'FUN_BUSINESS_UNIT'
    AND hodbc.org_information2  = gllv.legal_entity_id
    AND hodbc.org_information3  = gllv.ledger_id
    AND hov.status = 'A'
)
select  --PL.PO_HEADER_ID,PL.PO_LINE_ID,
   DISTINCT 
   -- PL.PO_HEADER_ID,PL.PO_LINE_ID,
     emp.company_nro AS Entity
    ,TO_CHAR(ph.end_date,'DD/MM/YYYY') AS Pd_close_date
    ,TO_CHAR(ph.creation_date,'DD/MM/YYYY') AS Po_date  
    ,(select TO_CHAR(ACTION_DATE,'DD/MM/YYYY')
      from PO_ACTION_HISTORY
      where OBJECT_ID  = ph.po_header_id
      AND SEQUENCE_NUM = (select  MAX(SEQUENCE_NUM)
                          from PO_ACTION_HISTORY
                        where OBJECT_ID = ph.po_header_id
                        and action_code = 'APPROVE'
                        AND PERFORMER_ID IS NOT NULL
                          )
      and action_code = 'APPROVE'
    AND PERFORMER_ID IS NOT NULL    
     ) AS Approv_date  
    ,decode(type_lookup_code,'BLANKET','Contrato','STANDARD','Orden') AS Doc_type
    ,SUBSTR(PH.segment1,
      INSTR(PH.segment1,'-',1,2) + 1, 
            DECODE(INSTR(PH.segment1,'-',1,3), 0, LENGTH(PH.segment1)+1 ,INSTR(PH.segment1,'-',1,3) ) - (INSTR(PH.segment1,'-',1,2)+1)
           ) AS Po_no
    ,ph.segment1 AS Codigo_contrato
    ,gcc.SEGMENT4 AS AFE
    ,(SELECT DISTINCT AOS.VENDOR_VAT_REGISTRATION_NUM
                    FROM HZ_PARTIES HP1,
                         POZ_SUPPLIERS_V PS,
                         AP_OFR_SUPPLIERS_V AOS
                    WHERE HP1.PARTY_ID = PS.PARTY_ID
                    AND   AOS.vendor_id = PS.vendor_id
                    AND   PS.vendor_id = ph.vendor_id) vendor_id
    ,gcc.SEGMENT1 || '-' || gcc.SEGMENT2 || '-' || gcc.SEGMENT3 || '-' || gcc.SEGMENT4 || '-' || gcc.SEGMENT5 || '-' || gcc.SEGMENT6 || '-' || gcc.SEGMENT7 AS FQA
    ,v.vendor_name AS NAME 
    ,PL.LINE_NUM AS Line_num    
    ,(SELECT DISTINCT IT.item_number 
        FROM EGP_SYSTEM_ITEMS_B IT
       WHERE IT.INVENTORY_ITEM_ID = PL.ITEM_ID) AS ARTICULO
    ,ITEM_DESCRIPTION AS Long_desc
    ,DECODE(NVL(UNIT_PRICE,0),0,LIST_PRICE, UNIT_PRICE) * DECODE(NVL(QUANTITY,0),0, 1, QUANTITY) AS Line_amt
    ,NVL(PDA.NONRECOVERABLE_TAX,0) AS IVA
    ,NVL(PDA.NONRECOVERABLE_TAX,0) + (DECODE(NVL(UNIT_PRICE,0),0,LIST_PRICE,UNIT_PRICE) * 
                                      DECODE(NVL(QUANTITY,0)  ,0,1,QUANTITY)
                                     ) AS TOTAL
    ,DECODE(NVL(UNIT_PRICE,0),0,LIST_PRICE,UNIT_PRICE) AS Unit_price  
    ,DECODE(NVL(QUANTITY,0),0,1,QUANTITY) AS Qty
    ,ph.currency_code AS Cc_code
    ,ph.attribute5  AS Resp_unit
    ,(SELECT DISPLAY_NAME
      FROM  PER_PERSON_NAMES_F PNFS
      WHERE PERSON_ID  = (select PERFORMER_ID
                          from PO_ACTION_HISTORY
                          where OBJECT_ID  = ph.po_header_id
                          AND SEQUENCE_NUM = (select  MAX(SEQUENCE_NUM)
                                       from PO_ACTION_HISTORY
                                      where OBJECT_ID  = ph.po_header_id
                                      and action_code = 'APPROVE'
                        AND PERFORMER_ID IS NOT NULL
                                       )
                           and action_code = 'APPROVE'
               AND PERFORMER_ID IS NOT NULL
                         )  
       AND PNFS.NAME_TYPE = 'GLOBAL') AS Approval_by
    ,PH.COMMENTS AS Po_desc
    ,DECODE(NVL(ph.attribute1,' '),'SI','Y',ph.attribute1) AS Closed
    ,TO_CHAR(ph.creation_date,'YYYY') AS Pd_year
    ,PL.UOM_CODE  AS Unit
    ,PL.LINE_STATUS AS Line_status
    ,(SELECT DISPLAY_NAME
      FROM  PER_PERSON_NAMES_F PNFS
      WHERE PERSON_ID  = (select PERFORMER_ID
                        from PO_ACTION_HISTORY
                        where OBJECT_ID  = ph.po_header_id
                        and action_code = 'ORIGINAL DOCUMENT'
                       )  
      AND PNFS.NAME_TYPE = 'GLOBAL') AS Requested_by
    ,PH.PO_HEADER_ID
    ,PH.VENDOR_ID VENDOR_ID2
    ,PL.ITEM_ID
FROM PO_HEADERS_ALL PH
INNER JOIN PO_LINES_ALL PL ON PH.PO_HEADER_ID = PL.PO_HEADER_ID
LEFT JOIN PO_DISTRIBUTIONS_ALL PDA ON PDA.PO_HEADER_ID = PL.PO_HEADER_ID AND   PDA.PO_LINE_ID   = PL.PO_LINE_ID
LEFT JOIN GL_CODE_COMBINATIONS GCC ON PDA.code_combination_id = GCC.code_combination_id
LEFT JOIN PER_PERSON_NAMES_F PNF1 ON PH.AGENT_ID = PNF1.PERSON_ID AND PNF1.NAME_TYPE = 'GLOBAL'
LEFT JOIN EMP ON PH.PRC_BU_ID = EMP.ORGANIZATION_ID
LEFT JOIN POZ_SUPPLIERS_V V ON PH.VENDOR_ID = V.VENDOR_ID   
WHERE (emp.company_nro = NVL(:P_EMPRESA,emp.company_nro ))
AND   (type_lookup_code = decode( NVL (:P_TIPO, type_lookup_code),'Contrato','BLANKET','Orden','STANDARD',type_lookup_code ) )
AND   (:P_ARTICULO IS NULL OR PL.ITEM_ID = :P_ARTICULO)
AND   (:P_FECHA_DESDE IS NULL OR ph.creation_date >= :P_FECHA_DESDE)
AND   (:P_FECHA_HASTA IS NULL OR ph.creation_date <= :P_FECHA_HASTA)
AND   (:P_ORDEN_CONTRATO IS NULL OR PH.PO_HEADER_ID = :P_ORDEN_CONTRATO)
AND   (:P_PROVEEDOR IS NULL OR PH.VENDOR_ID = :P_PROVEEDOR)
and   (ph.attribute5 in (:P_RESP_UNIT) or 'All' in ('All' || :P_RESP_UNIT))
AND   (:P_ESTADO IS NULL OR PH.DOCUMENT_STATUS = :P_ESTADO)
ORDER BY ph.segment1, Line_num



