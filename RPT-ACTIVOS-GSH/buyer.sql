SELECT
    (SELECT ffvt.description
            FROM FND_FLEX_VALUE_SETS  ffvs,
                FND_FLEX_VALUES      ffv,
                FND_FLEX_VALUES_TL   ffvt
            WHERE ffvs.flex_value_set_name = 'CNC_CENTRO_DE_COSTO'
            AND ffvs.flex_value_set_id = ffv.flex_value_set_id
            AND ffv.flex_value_id = ffvt.flex_value_id
            AND ffv.flex_value = gcc.segment3
            AND ffvt.language = 'E') AS RESP_UNIT,

        gcc.segment1 AS COD_COMPANIA,

        prha.requisition_number AS RQ_NUMBER,

        (SELECT ffvt.description
            FROM FND_FLEX_VALUE_SETS  ffvs,
                FND_FLEX_VALUES      ffv,
                FND_FLEX_VALUES_TL   ffvt
            WHERE ffvs.flex_value_set_name = 'CNC_COMPANIA'
            AND ffvs.flex_value_set_id = ffv.flex_value_set_id
            AND ffv.flex_value_id = ffvt.flex_value_id
            AND ffvt.language = 'E'
            AND ffv.flex_value = gcc.segment1) AS DES_COMPANIA,

                SUBSTR(prha.requisition_number , 7) AS NUMERO,
        prha.description AS RQ_DESCRIPCION,
        prla.line_number AS LINE_NUM,
        prla.item_description AS ITEM_DESCRIPCION,
        prla.quantity AS CANTIDAD,
        prla.uom_code AS UNIDAD,
        TO_CHAR(prha.creation_date,'DD/MM/RRRR') AS RQ_FECHA,


        (SELECT TO_CHAR(pah.action_date,'DD/MM/RRRR')
            FROM PO_ACTION_HISTORY  pah
            WHERE pah.object_id = prha.requisition_header_id
            AND pah.object_type_code = 'REQ'
            AND pah.action_code = 'APPROVE'
            ORDER BY SEQUENCE_NUM FETCH FIRST 1 ROW ONLY) AS RQ_FECHA_APROBACION,
        hla.location_code AS DELIVER_TO,
        prha.ATTRIBUTE6  AS RQ_SOLICITANTE,


        (SELECT PPNF.FULL_NAME
                FROM PO_ACTION_HISTORY PAH,
                    PER_PERSON_NAMES_F PPNF
                WHERE PAH.OBJECT_ID = PRHA.REQUISITION_HEADER_ID
                    AND PAH.OBJECT_TYPE_CODE = 'REQ'
                    AND PAH.OBJECT_SUB_TYPE_CODE = 'PURCHASE'
                    AND PAH.ACTION_CODE = 'APPROVE'
                    AND PAH.PERFORMER_ID = PPNF.PERSON_ID
                    AND PPNF.NAME_TYPE = 'GLOBAL'
                    AND PAH.SEQUENCE_NUM = (SELECT MAX(PAH1.SEQUENCE_NUM) FROM PO_ACTION_HISTORY PAH1
                                                WHERE PAH1.OBJECT_ID = PRHA.REQUISITION_HEADER_ID
                                                AND PAH1.OBJECT_TYPE_CODE = 'REQ'
                                                AND PAH1.OBJECT_SUB_TYPE_CODE = 'PURCHASE'
                                                AND PAH1.ACTION_CODE = 'APPROVE')
            ) AS RQ_APROBADOR,



            (SELECT display_name
            FROM PER_PERSON_NAMES_F
            WHERE person_id = prha.PREPARER_ID 
            AND name_type = 'CO')RQ_CREADOR,


        --prla.created_by AS RQ_CREADOR,
        (SELECT TO_CHAR(pha.creation_date,'DD/MM/RRRR')
            FROM PO_HEADERS_ALL pha
            WHERE pha.po_header_id = prla.po_header_id) AS Delivery_date,
            PRHA.DESCRIPTION AS COMMENTS,
        prla.note_to_supplier AS NOTA_AL_PROVEEDOR,
        prla.line_status AS ESTADO_LINEA,


        CASE
            WHEN prla.po_header_id IS NOT NULL THEN
            (SELECT psv.vendor_name
                FROM PO_HEADERS_ALL   pha,
                    POZ_SUPPLIERS_V  psv
                WHERE pha.vendor_id = psv.vendor_id
                AND pha.po_header_id = prla.po_header_id)
            ELSE
            prla.suggested_vendor_name
        END AS PROVEEDOR,


        (prla.quantity * prla.currency_unit_price) AS LINE_AMOUNT,
        (SELECT pha.segment1
            FROM PO_HEADERS_ALL pha
            WHERE pha.po_header_id = prla.po_header_id) AS NRO_OC,
                (SELECT DISTINCT AOS.VENDOR_VAT_REGISTRATION_NUM
                FROM AP_OFR_SUPPLIERS_V AOS,
                POZ_SUPPLIERS_v PS,


                PO_HEADERS_ALL   pha
                WHERE AOS.vendor_id = PS.vendor_id
                and pha.vendor_id = ps.vendor_id
            AND pha.po_header_id = prla.po_header_id)AS NIT_PROVEEDOR_OC,

        -- (SELECT psv.segment1||'-'||psv.attribute5
            -- FROM PO_HEADERS_ALL   pha,
                -- POZ_SUPPLIERS_V  psv
            -- WHERE pha.vendor_id = psv.vendor_id
            -- AND pha.po_header_id = prla.po_header_id) AS NIT_PROVEEDOR_OC,
        NULL AS NIT_PROVEEDOR_RQ,

        gcc.segment1||'-'||
        gcc.segment2||'-'||
        gcc.segment3||'-'||
        gcc.segment4||'-'||
        gcc.segment5||'-'||
        gcc.segment6||'-'||
        gcc.segment7||'-'||
        gcc.segment8||'-'||
        gcc.segment9 AS FQA,

        (SELECT pla.quantity
            FROM PO_LINES_ALL pla
            WHERE pla.po_header_id = prla.po_header_id
            AND pla.po_line_id = prla.po_line_id) AS CANTIDAD_OC,

        (SELECT pla.item_description
            FROM PO_LINES_ALL pla
            WHERE pla.po_header_id = prla.po_header_id
            AND pla.po_line_id = prla.po_line_id) AS DESCRIPCION_OC,

        prla.currency_unit_price AS PRECIO_UNITARIO_RQ,
        prla.currency_code AS MONEDA_RQ,
        --prha.APPROVAL_INSTANCE_ID as COD_MA,
        --prha.ATTRIBUTE5 as AREA,
        ESIB.ITEM_NUMBER as COD_MATERIAL,
        pha.SEGMENT1 AS Agreement, 	--  
		pha2.DOCUMENT_STATUS as Status_PO, ---d---
        pla.LINE_NUM AS Agreement_line,    
		prla.LINE_NUMBER AS Line_num_PO,  ----d---
        PBVV.FULL_NAME AS Buyer
        --ESIB.INVENTORY_ORGANIZATION_ID	AS INVENTORY_ORGANIZATION_ID,
        --prla.SOURCE_ORGANIZATION_ID as SOURCE_ORGANIZATION_ID


    FROM POR_REQUISITION_HEADERS_ALL    prha,
        POR_REQUISITION_LINES_ALL      prla,
        POR_REQ_DISTRIBUTIONS_ALL      prda,
        GL_CODE_COMBINATIONS           gcc,
        HR_LOCATIONS_ALL               hla,
		
        EGP_SYSTEM_ITEMS_B            ESIB,
        PO_BUYERS_VAL_V               PBVV, 
        po_lines_all                   pla,
        PO_HEADERS_ALL                 pha,
		
		PO_HEADERS_ALL				   pha2, --
        po_lines_all                   pla2 --



    WHERE prha.requisition_header_id = prla.requisition_header_id
    AND prla.requisition_line_id = prda.requisition_line_id
    AND prda.code_combination_id = gcc.code_combination_id
    AND prla.deliver_to_location_id = hla.location_id
		
    AND prla.SOURCE_DOC_HEADER_ID = pha.PO_HEADER_ID(+)
	AND prla.SOURCE_DOC_LINE_ID = pla.PO_LINE_ID(+)
	
	AND prla.PO_HEADER_ID = pha2.PO_HEADER_ID(+)
	AND prla.PO_LINE_ID = pla2.PO_LINE_ID(+)
	
    AND prla.ASSIGNED_BUYER_ID = PBVV.PERSON_ID(+)
    AND prla.ITEM_ID = ESIB.INVENTORY_ITEM_ID(+)
    AND prla.DESTINATION_ORGANIZATION_ID = ESIB.INVENTORY_ORGANIZATION_ID(+)
    AND prha.creation_date BETWEEN :P_FCH_DESDE AND :P_FCH_HASTA
    AND (SELECT display_name
            FROM PER_PERSON_NAMES_F
            WHERE person_id = prha.PREPARER_ID 
            AND name_type = 'CO') = NVL(:P_USUARIO , (SELECT display_name
                                                        FROM PER_PERSON_NAMES_F
                                                        WHERE person_id = prha.PREPARER_ID 
                                                        AND name_type = 'CO'))
    AND prla.line_status = NVL(:P_STATUS_RQ , prla.line_status)
    ORDER BY prha.requisition_number, prla.line_numbe