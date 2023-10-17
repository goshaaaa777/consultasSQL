SELECT DISTINCT wpsv.pick_slip_number,
       decode(msik.reservable_type,2,wdd.subinventory,wpsv.subinventory_code) from_subinventory,
       decode(msik.reservable_type,2,wdd.locator_id,wpsv.locator_id) from_locator_id,
       wpsv.pick_slip_line_number pick_sequence_line,
       wpsv.transfer_subinventory to_subinventory,
       wpsv.transfer_to_location  to_locator_id,
       nvl(wpsv.transaction_temp_id ,-99) transaction_id,
       nvl(wpsv.transaction_temp_id, -99) rev_txn_id,
       wpsv.move_order_line_id,
       wpsv.creation_date         detailing_date,
       ABS(wpsv.primary_quantity) primary_qty,
       mtrh.request_number mo_number,
       mtrl.line_id mo_line_id,
       mtrl.line_number mo_line_number,
       -99  delivery_detail_id1,
       -99 ser_dd_id,
       wdd.sales_order_number,
       to_char(wdd.sales_order_number) order_n_header_char,
       to_char(wdd.sales_order_line_number) order_n_line_char1,
       wdd.source_header_id,
       wdd.source_line_id,
       wdd.source_shipment_id,
       to_char(wdd.source_header_id) source_header_chr, 
       to_char(wdd.source_line_id) source_line_chr, 
       wdd.shipping_instructions,
       wdd.ship_tolerance_above,
       wdd.ship_tolerance_below,
       wdd.inventory_item_id,
       wdd.requested_quantity_uom requested_quantity_uom_code,
       iuom.unit_of_measure requested_quantity_uom,
       wdd.batch_id,
       wnd.delivery_id,
       to_char(wnd.delivery_id) delivery_chr, 
       wnd.delivery_name  delivery_name,
       wnd.initial_pickup_location_id,
       wdd.sales_order_line_number   sales_line_number,
       msik.description item_description,
       msik.revision_qty_control_code  ,
       msik.serial_number_control_code,
       wdd.ship_set_name,
       wpgr.customer_flag CUSTOMER_FLAG1,
       wpgr.order_number_flag,
       wpgr.subinventory_flag,
       wpgr.customer_flag,
       wpgr.ship_to_flag,
       wpgr.carrier_flag,
       wpgr.shipment_priority_flag,
       wpgr.delivery_flag,
       wpgr.pick_grouping_rule_name name,
       wdd.ship_method_code carrier,
       wdd.shipment_priority_code priority,
       wdd.organization_id,
       wdd.requested_quantity2  secondary_qty_requested,
       wdd.requested_quantity_uom2 secondary_qty_req_uom_code,
       iuom2.unit_of_measure secondary_qty_requested_uom,
       wdd.shipped_quantity2 secondary_qty_shipped,
       wdd.requested_quantity_uom2 secondary_qty_ship_uom_code,
       iuom2.unit_of_measure secondary_qty_shipped_uom,
       wdd.preferred_grade grade,
       wdd.freight_terms_code freight_terms,
       wdd.date_requested requested_ship_date,
       wdd.attribute1   wdd_attribute1,
       wdd.attribute2   wdd_attribute2,
       wdd.attribute3   wdd_attribute3,
       wdd.attribute4   wdd_attribute4,
       wdd.attribute5   wdd_attribute5,
       wdd.attribute6   wdd_attribute6,
       wdd.attribute7   wdd_attribute7,
       wdd.attribute8   wdd_attribute8,
       wdd.attribute9   wdd_attribute9,
       wdd.attribute10  wdd_attribute10,
       wdd.attribute11  wdd_attribute11,
       wdd.attribute12  wdd_attribute12,
       wdd.attribute13  wdd_attribute13,
       wdd.attribute14  wdd_attribute14,
       wdd.attribute15  wdd_attribute15,
       wdd.attribute16  wdd_attribute16,
       wdd.attribute17  wdd_attribute17,
       wdd.attribute18  wdd_attribute18,
       wdd.attribute19  wdd_attribute19,
       wdd.attribute20  wdd_attribute20,
       wdd.attribute_date1  wdd_attribute_date1,
       wdd.attribute_date2  wdd_attribute_date2,
       wdd.attribute_date3  wdd_attribute_date3,
       wdd.attribute_date4  wdd_attribute_date4,
       wdd.attribute_date5  wdd_attribute_date5,
       wdd.attribute_timestamp1  wdd_attribute_timestamp1,
       wdd.attribute_timestamp2  wdd_attribute_timestamp2,
       wdd.attribute_timestamp3  wdd_attribute_timestamp3,
       wdd.attribute_timestamp4  wdd_attribute_timestamp4,
       wdd.attribute_timestamp5  wdd_attribute_timestamp5,
       wdd.attribute_number1  wdd_attribute_number1,
       wdd.attribute_number2  wdd_attribute_number2,
       wdd.attribute_number3  wdd_attribute_number3,
       wdd.attribute_number4  wdd_attribute_number4,
       wdd.attribute_number5  wdd_attribute_number5,
       wdd.attribute_number6  wdd_attribute_number6,
       wdd.attribute_number7  wdd_attribute_number7,
       wdd.attribute_number8  wdd_attribute_number8,
       wdd.attribute_number9  wdd_attribute_number9,
       wdd.attribute_number10 wdd_attribute_number10,
        wdd.pjc_project_id,
        wdd.pjc_task_id,
        wdd.project_id,
        wdd.task_id,
        wdd.country_of_origin_code,
        wdd.inv_striping_category,
        wdd.inv_reserved_attribute1,
        wdd.inv_reserved_attribute2,
        wdd.inv_user_def_attribute1,
        wdd.inv_user_def_attribute2,
        wdd.inv_user_def_attribute3,
        wdd.inv_user_def_attribute4,
        wdd.inv_user_def_attribute5,
        wdd.inv_user_def_attribute6,
        wdd.inv_user_def_attribute7,
        wdd.inv_user_def_attribute8,
        wdd.inv_user_def_attribute9,
        wdd.inv_user_def_attribute10,
        WSH_PICK_SLIP_RPT.f_inv_projects_formula('PROJECT', wdd.project_id) inv_project_number,
        WSH_PICK_SLIP_RPT.f_inv_projects_formula('TASK', wdd.task_id) inv_task_number,
        WSH_PICK_SLIP_RPT.f_inv_projects_formula('PROJECT', wdd.pjc_project_id) pjc_project_number,
        WSH_PICK_SLIP_RPT.f_inv_projects_formula('TASK', wdd.pjc_task_id) pjc_task_number,
       wnd.attribute1   wnd_attribute1,
       wnd.attribute2   wnd_attribute2,
       wnd.attribute3   wnd_attribute3,
       wnd.attribute4   wnd_attribute4,
       wnd.attribute5   wnd_attribute5,
       wnd.attribute6   wnd_attribute6,
       wnd.attribute7   wnd_attribute7,
       wnd.attribute8   wnd_attribute8,
       wnd.attribute9   wnd_attribute9,
       wnd.attribute10  wnd_attribute10,
       wnd.attribute11  wnd_attribute11,
       wnd.attribute12  wnd_attribute12,
       wnd.attribute13  wnd_attribute13,
       wnd.attribute14  wnd_attribute14,
       wnd.attribute15  wnd_attribute15,
       wnd.attribute16  wnd_attribute16,
       wnd.attribute17  wnd_attribute17,
       wnd.attribute18  wnd_attribute18,
       wnd.attribute19  wnd_attribute19,
       wnd.attribute20  wnd_attribute20,
       wnd.attribute_date1  wnd_attribute_date1,
       wnd.attribute_date2  wnd_attribute_date2,
       wnd.attribute_date3  wnd_attribute_date3,
       wnd.attribute_date4  wnd_attribute_date4,
       wnd.attribute_date5  wnd_attribute_date5,
       wnd.attribute_timestamp1  wnd_attribute_timestamp1,
       wnd.attribute_timestamp2  wnd_attribute_timestamp2,
       wnd.attribute_timestamp3  wnd_attribute_timestamp3,
       wnd.attribute_timestamp4  wnd_attribute_timestamp4,
       wnd.attribute_timestamp5  wnd_attribute_timestamp5,
       wnd.attribute_number1  wnd_attribute_number1,
       wnd.attribute_number2  wnd_attribute_number2,
       wnd.attribute_number3  wnd_attribute_number3,
       wnd.attribute_number4  wnd_attribute_number4,
       wnd.attribute_number5  wnd_attribute_number5,
       wnd.attribute_number6  wnd_attribute_number6,
       wnd.attribute_number7  wnd_attribute_number7,
       wnd.attribute_number8  wnd_attribute_number8,
       wnd.attribute_number9  wnd_attribute_number9,
       wnd.attribute_number10 wnd_attribute_number10,
    WSH_PICK_SLIP_RPT.cf_warehouseformula(wdd.organization_id) CF_warehouse, 
    WSH_PICK_SLIP_RPT.cf_tempformula(wpgr.shipment_priority_flag, wdd.shipment_priority_code) CF_temp, 
  decode(wdd.source_line_type,'TRANSFER_ORDER',WSH_PICK_SLIP_RPT.cf_requisition_numberformula(wdd.sales_order_number,wdd.sales_order_line_number),NULL)  CF_requisition_number,
  WSH_PICK_SLIP_RPT.cf_ship_to_addressformula(wnd.ultimate_dropoff_location_id, wnd.delivery_id) CF_ship_to_address,
  WSH_PICK_SLIP_RPT.cf_carrierformula(wpgr.carrier_flag, wnd.carrier_id, wnd.organization_id, wnd.delivery_id) CF_carrier,
    WSH_PICK_SLIP_RPT.cf_shipment_priorityformula(wpgr.shipment_priority_flag, wdd.shipment_priority_code) CF_shipment_priority, 
    WSH_PICK_SLIP_RPT.cf_subinventoryformula(wpgr.subinventory_flag, decode ( msik.reservable_type , 2 , wdd.subinventory , wpsv.subinventory_code )) CF_subinventory, 
    WSH_PICK_SLIP_RPT.cf_delivery_idformula(wpgr.delivery_flag, wnd.delivery_id) CF_delivery_id, 
    WSH_PICK_SLIP_RPT.cf_deliveryformula(wpgr.delivery_flag, wnd.delivery_name) CF_delivery, 
    WSH_PICK_SLIP_RPT.cf_order_numberformula(wpgr.order_number_flag, wdd.sales_order_number) CF_order_number, 
    WSH_PICK_SLIP_RPT.cf_customer_nameformula(wdd.sold_to_party_id) CF_customer_name,
    WSH_PICK_SLIP_RPT.CP_warehouse_code_p CP_warehouse_code,
    WSH_PICK_SLIP_RPT.CP_warehouse_name_p CP_warehouse_name,
    WSH_PICK_SLIP_RPT.st_addr1_p st_addr1,
    WSH_PICK_SLIP_RPT.st_addr4_p st_addr4,
    WSH_PICK_SLIP_RPT.st_addr5_p st_addr5,
    WSH_PICK_SLIP_RPT.st_addr2_p st_addr2,
    WSH_PICK_SLIP_RPT.st_addr3_p st_addr3, 
    WSH_PICK_SLIP_RPT.f_to_locationformula(wpsv.transfer_to_location, wdd.organization_id) F_TO_LOCATION, 
  WSH_PICK_SLIP_RPT.cf_customerformula(wdd.sold_to_party_id) CF_customer, 
  WSH_PICK_SLIP_RPT.CF_CONTACT_NAMEFORMULA(wdd.ship_to_contact_id, wdd.delivery_detail_id, wdd.source_line_type,wdd.sold_to_party_id) CF_contact_name,
    WSH_PICK_SLIP_RPT.f_item_descriptionformula(msik.description, wdd.inventory_item_id, wdd.organization_id, msik.description) F_ITEM_DESCRIPTION, 
    WSH_PICK_SLIP_RPT.f_requested_quantityformula(wdd.sales_order_number, wdd.sales_order_line_number, wpsv.move_order_line_id) F_REQUESTED_QUANTITY, 
    WSH_PICK_SLIP_RPT.f_shipped_quantityformula() F_SHIPPED_QUANTITY, 
    WSH_PICK_SLIP_RPT.f_from_locationformula(decode ( msik.reservable_type , 2 , wdd.locator_id , wpsv.locator_id ), wdd.organization_id) F_FROM_LOCATION,  
  WSH_PICK_SLIP_RPT.cf_freight_terms_nameformula(wdd.freight_terms_code) CF_FREIGHT_TERMS_NAME,
    WSH_PICK_SLIP_RPT.cf_revisionformula(nvl ( wpsv.transaction_temp_id , - 99 )) CF_REVISION,
  WSH_PICK_SLIP_RPT.cf_pick_wave_nameformula(wdd.batch_id) CF_PICK_WAVE,
  WSH_PICK_SLIP_RPT.cf_line_status('1') CF_LINE_STATUS,
       ABS(wpsv.transaction_quantity) requested_pick_qty,
       wpsv.transaction_uom requested_pick_qty_uom_code,
       iuom3.unit_of_measure requested_pick_qty_uom,
       ABS(NVL(wpsv.transaction_quantity,0)) + NVL(WSH_PICK_SLIP_RPT.get_max_over_pick_quantity(wpsv.trx_source_line_id, wpsv.transaction_uom, msik.primary_uom_code, wpsv.inventory_item_id),0) MAXIMUM_OVER_PICK_QUANTITY,
       wpsv.pick_slip_number pick_slip_number2, --27/12/2022
       decode(wdd.source_line_type,'TRANSFER_ORDER',WSH_PICK_SLIP_RPT.cf_requisition_numberformula(wdd.sales_order_number,wdd.sales_order_line_number),NULL) CF_requisition_number2, --27/12/2022
       (select r.JUSTIFICATION 
          from POR_REQUISITION_HEADERS_ALL r 
         where r.REQUISITION_NUMBER = decode(wdd.source_line_type,'TRANSFER_ORDER',WSH_PICK_SLIP_RPT.cf_requisition_numberformula(wdd.sales_order_number,wdd.sales_order_line_number),NULL) 
           and rownum = 1) justi_rq,
       (select r.DESCRIPTION 
          from POR_REQUISITION_HEADERS_ALL r 
         where r.REQUISITION_NUMBER = decode(wdd.source_line_type,'TRANSFER_ORDER',WSH_PICK_SLIP_RPT.cf_requisition_numberformula(wdd.sales_order_number,wdd.sales_order_line_number),NULL) 
           and rownum = 1) desc_rq,
       WSH_PICK_SLIP_RPT.cf_pick_wave_nameformula(wdd.batch_id) CF_PICK_WAVE2,  --27/12/2022
       msik.item_number,
       msik.description item_desc2,
       decode(msik.reservable_type,2,wdd.subinventory,wpsv.subinventory_code) from_subinventory2,
       WSH_PICK_SLIP_RPT.CP_warehouse_name_p CP_warehouse_name2,
       WSH_PICK_SLIP_RPT.f_to_locationformula(wpsv.transfer_to_location, wdd.organization_id) F_TO_LOCATION2,
    ---(select name from HR_ORGANIZATION_UNITS h where h.organization_id = wpsv.TRANSFER_ORGANIZATION) f_to_org2,
	   (select name from HR_ORGANIZATION_UNITS h where h.LOCATION_ID = wdd.SHIP_TO_LOCATION_ID ) f_to_org2,   ----***
       nvl((select sum(i.PRIMARY_TRANSACTION_QUANTITY)
              from inv_onhand_quantities_detail i
             where i.inventory_item_id = wdd.inventory_item_id 
               and i.locator_id = decode(msik.reservable_type,2,wdd.locator_id,wpsv.locator_id)
               and i.subinventory_code = decode(msik.reservable_type,2,wdd.subinventory,wpsv.subinventory_code)
               and i.ORGANIZATION_ID = wdd.organization_id),
           0) qty_o2,
       nvl((select sum(i.PRIMARY_TRANSACTION_QUANTITY)
              from inv_onhand_quantities_detail i
             where i.inventory_item_id = wdd.inventory_item_id 
               and i.locator_id = wpsv.transfer_to_location
               and i.subinventory_code = wpsv.transfer_subinventory
               and i.ORGANIZATION_ID = wpsv.TRANSFER_ORGANIZATION),
           0) qty_d2,
       (select h.name
          from inv_org_parameters o, HR_ORGANIZATION_UNITS h
         where o.BUSINESS_UNIT_ID = h.organization_id
           and o.organization_id = wdd.organization_id) BUSINESS_UNIT
  FROM INV_MATERIAL_TXNS_TEMP wpsv,
       wsh_delivery_details wdd,
       inv_txn_request_lines mtrl,
       inv_txn_request_headers mtrh,
       wsh_delivery_assignments wda,  
       wsh_new_deliveries wnd,
       inv_pick_grouping_rules_vl wpgr,
       egp_system_items_vl  msik,
       inv_units_of_measure_vl iuom,
       inv_units_of_measure_vl iuom2,
       inv_units_of_measure_vl iuom3
 WHERE wpsv.pick_slip_number IS NOT NULL
   AND ABS(NVL(wpsv.transaction_quantity,0)) > 0
   AND wpsv.move_order_line_id = mtrl.line_id
   AND mtrl.header_id = mtrh.header_id
   AND mtrl.line_id = wdd.move_order_line_id
  AND wdd.inventory_item_id = msik.inventory_item_id(+)
  AND wdd.organization_id = msik.organization_id(+)
   AND wdd.delivery_detail_id = wda.delivery_detail_id
   AND wda.delivery_id = wnd.delivery_id(+)
   AND (wnd.delivery_type is null or wnd.delivery_type = 'STANDARD') 
   AND wdd.released_status='S'
   AND mtrh.grouping_rule_id = wpgr.pick_grouping_rule_id(+)
   AND wdd.requested_quantity_uom = iuom.uom_code
   AND wdd.requested_quantity_uom2 = iuom2.uom_code (+)
   AND wpsv.transaction_uom = iuom3.uom_code
        &LP_PICK_STATUS_UNPICK  
        &LP_WAREHOUSE_CLAUSE
        &LP_MO_CLAUSE
        &lp_pick_slip_num
        &LP_ORDER_NUM
        &LP_CUSTOMER_ID
        &lp_ship_method_code 
UNION ALL
SELECT DISTINCT wpsv.pick_slip_number,
       decode(msik.reservable_type,2,wdd.subinventory,wpsv.subinventory_code) from_subinventory,
       decode(msik.reservable_type,2,wdd.locator_id,wpsv.locator_id) from_locator_id,
       wpsv.pick_slip_line_number pick_sequence_line,
       wpsv.transfer_subinventory to_subinventory,
       wpsv.transfer_locator_id to_locator_id,
       nvl(wpsv.transaction_id ,-99) transaction_id,
       nvl(wdd.transaction_id, -99) rev_txn_id,
       wpsv.move_order_line_id,
       wpsv.transaction_date detailing_date,
       wdd.requested_quantity primary_qty,
       mtrh.request_number mo_number,
       mtrl.line_id          mo_line_id,
       mtrl.line_number  mo_line_number,
       wdd.delivery_detail_id delivery_detail_id1,
       wdd.delivery_detail_id  ser_dd_id,
       wdd.sales_order_number,
       to_char(wdd.sales_order_number) order_n_header_char,
       to_char(wdd.sales_order_line_number) order_n_line_char1,
       wdd.source_header_id,
       wdd.source_line_id,
       wdd.source_shipment_id,
       to_char(wdd.source_header_id) source_header_chr, 
       to_char(wdd.source_line_id) source_line_chr, 
       wdd.shipping_instructions,
       wdd.ship_tolerance_above,
       wdd.ship_tolerance_below,
       wdd.inventory_item_id,
       wdd.requested_quantity_uom requested_quantity_uom_code,
       iuom.unit_of_measure requested_quantity_uom,
       wdd.batch_id,
       wnd.delivery_id,
       to_char(wnd.delivery_id) delivery_chr, 
       wnd.delivery_name  delivery_name,
       wnd.initial_pickup_location_id,
       wdd.sales_order_line_number   sales_line_number,     
       msik.description item_description,
       msik.revision_qty_control_code,
       msik.serial_number_control_code,
       wdd.ship_set_name,
       wpgr.customer_flag CUSTOMER_FLAG1,
       wpgr.order_number_flag,
       wpgr.subinventory_flag,
       wpgr.customer_flag,
       wpgr.ship_to_flag,
       wpgr.carrier_flag,
       wpgr.shipment_priority_flag,
       wpgr.delivery_flag,
       wpgr.pick_grouping_rule_name,
       wdd.ship_method_code carrier,
       wdd.shipment_priority_code priority,
       wdd.organization_id,
       wdd.requested_quantity2  secondary_qty_requested,
       wdd.requested_quantity_uom2 secondary_qty_req_uom_code,
       iuom2.unit_of_measure secondary_qty_requested_uom,
       wdd.shipped_quantity2 secondary_qty_shipped,
       wdd.requested_quantity_uom2 secondary_qty_ship_uom_code,
       iuom2.unit_of_measure secondary_qty_shipped_uom,
       wdd.preferred_grade grade,
       wdd.freight_terms_code freight_terms,
       wdd.date_requested requested_ship_date,
       wdd.attribute1   wdd_attribute1,
       wdd.attribute2   wdd_attribute2,
       wdd.attribute3   wdd_attribute3,
       wdd.attribute4   wdd_attribute4,
       wdd.attribute5   wdd_attribute5,
       wdd.attribute6   wdd_attribute6,
       wdd.attribute7   wdd_attribute7,
       wdd.attribute8   wdd_attribute8,
       wdd.attribute9   wdd_attribute9,
       wdd.attribute10  wdd_attribute10,
       wdd.attribute11  wdd_attribute11,
       wdd.attribute12  wdd_attribute12,
       wdd.attribute13  wdd_attribute13,
       wdd.attribute14  wdd_attribute14,
       wdd.attribute15  wdd_attribute15,
       wdd.attribute16  wdd_attribute16,
       wdd.attribute17  wdd_attribute17,
       wdd.attribute18  wdd_attribute18,
       wdd.attribute19  wdd_attribute19,
       wdd.attribute20  wdd_attribute20,
       wdd.attribute_date1  wdd_attribute_date1,
       wdd.attribute_date2  wdd_attribute_date2,
       wdd.attribute_date3  wdd_attribute_date3,
       wdd.attribute_date4  wdd_attribute_date4,
       wdd.attribute_date5  wdd_attribute_date5,
       wdd.attribute_timestamp1  wdd_attribute_timestamp1,
       wdd.attribute_timestamp2  wdd_attribute_timestamp2,
       wdd.attribute_timestamp3  wdd_attribute_timestamp3,
       wdd.attribute_timestamp4  wdd_attribute_timestamp4,
       wdd.attribute_timestamp5  wdd_attribute_timestamp5,
       wdd.attribute_number1  wdd_attribute_number1,
       wdd.attribute_number2  wdd_attribute_number2,
       wdd.attribute_number3  wdd_attribute_number3,
       wdd.attribute_number4  wdd_attribute_number4,
       wdd.attribute_number5  wdd_attribute_number5,
       wdd.attribute_number6  wdd_attribute_number6,
       wdd.attribute_number7  wdd_attribute_number7,
       wdd.attribute_number8  wdd_attribute_number8,
       wdd.attribute_number9  wdd_attribute_number9,
       wdd.attribute_number10 wdd_attribute_number10,
        wdd.pjc_project_id,
        wdd.pjc_task_id,
        wdd.project_id,
        wdd.task_id,
        wdd.country_of_origin_code,
        wdd.inv_striping_category,
        wdd.inv_reserved_attribute1,
        wdd.inv_reserved_attribute2,
        wdd.inv_user_def_attribute1,
        wdd.inv_user_def_attribute2,
        wdd.inv_user_def_attribute3,
        wdd.inv_user_def_attribute4,
        wdd.inv_user_def_attribute5,
        wdd.inv_user_def_attribute6,
        wdd.inv_user_def_attribute7,
        wdd.inv_user_def_attribute8,
        wdd.inv_user_def_attribute9,
        wdd.inv_user_def_attribute10,
        WSH_PICK_SLIP_RPT.f_inv_projects_formula('PROJECT', wdd.project_id) inv_project_number,
        WSH_PICK_SLIP_RPT.f_inv_projects_formula('TASK', wdd.task_id) inv_task_number,
        WSH_PICK_SLIP_RPT.f_inv_projects_formula('PROJECT', wdd.pjc_project_id) pjc_project_number,
        WSH_PICK_SLIP_RPT.f_inv_projects_formula('TASK', wdd.pjc_task_id) pjc_task_number,
       wnd.attribute1   wnd_attribute1,
       wnd.attribute2   wnd_attribute2,
       wnd.attribute3   wnd_attribute3,
       wnd.attribute4   wnd_attribute4,
       wnd.attribute5   wnd_attribute5,
       wnd.attribute6   wnd_attribute6,
       wnd.attribute7   wnd_attribute7,
       wnd.attribute8   wnd_attribute8,
       wnd.attribute9   wnd_attribute9,
       wnd.attribute10  wnd_attribute10,
       wnd.attribute11  wnd_attribute11,
       wnd.attribute12  wnd_attribute12,
       wnd.attribute13  wnd_attribute13,
       wnd.attribute14  wnd_attribute14,
       wnd.attribute15  wnd_attribute15,
       wnd.attribute16  wnd_attribute16,
       wnd.attribute17  wnd_attribute17,
       wnd.attribute18  wnd_attribute18,
       wnd.attribute19  wnd_attribute19,
       wnd.attribute20  wnd_attribute20,
       wnd.attribute_date1  wnd_attribute_date1,
       wnd.attribute_date2  wnd_attribute_date2,
       wnd.attribute_date3  wnd_attribute_date3,
       wnd.attribute_date4  wnd_attribute_date4,
       wnd.attribute_date5  wnd_attribute_date5,
       wnd.attribute_timestamp1  wnd_attribute_timestamp1,
       wnd.attribute_timestamp2  wnd_attribute_timestamp2,
       wnd.attribute_timestamp3  wnd_attribute_timestamp3,
       wnd.attribute_timestamp4  wnd_attribute_timestamp4,
       wnd.attribute_timestamp5  wnd_attribute_timestamp5,
       wnd.attribute_number1  wnd_attribute_number1,
       wnd.attribute_number2  wnd_attribute_number2,
       wnd.attribute_number3  wnd_attribute_number3,
       wnd.attribute_number4  wnd_attribute_number4,
       wnd.attribute_number5  wnd_attribute_number5,
       wnd.attribute_number6  wnd_attribute_number6,
       wnd.attribute_number7  wnd_attribute_number7,
       wnd.attribute_number8  wnd_attribute_number8,
       wnd.attribute_number9  wnd_attribute_number9,
       wnd.attribute_number10 wnd_attribute_number10,
    WSH_PICK_SLIP_RPT.cf_warehouseformula(wdd.organization_id) CF_warehouse, 
    WSH_PICK_SLIP_RPT.cf_tempformula(wpgr.shipment_priority_flag, wdd.shipment_priority_code) CF_temp, 
  decode(wdd.source_line_type,'TRANSFER_ORDER',WSH_PICK_SLIP_RPT.cf_requisition_numberformula(wdd.sales_order_number,wdd.sales_order_line_number),NULL) CF_requisition_number, 
  WSH_PICK_SLIP_RPT.cf_ship_to_addressformula(wnd.ultimate_dropoff_location_id, wnd.delivery_id) CF_ship_to_address,
  WSH_PICK_SLIP_RPT.cf_carrierformula(wpgr.carrier_flag, wnd.carrier_id, wnd.organization_id, wnd.delivery_id) CF_carrier,
    WSH_PICK_SLIP_RPT.cf_shipment_priorityformula(wpgr.shipment_priority_flag, wdd.shipment_priority_code) CF_shipment_priority, 
    WSH_PICK_SLIP_RPT.cf_subinventoryformula(wpgr.subinventory_flag, decode ( msik.reservable_type , 2 , wdd.subinventory , wpsv.subinventory_code )) CF_subinventory, 
    WSH_PICK_SLIP_RPT.cf_delivery_idformula(wpgr.delivery_flag, wnd.delivery_id) CF_delivery_id, 
    WSH_PICK_SLIP_RPT.cf_deliveryformula(wpgr.delivery_flag, wnd.delivery_name) CF_delivery, 
    WSH_PICK_SLIP_RPT.cf_order_numberformula(wpgr.order_number_flag, wdd.sales_order_number) CF_order_number, 
    WSH_PICK_SLIP_RPT.cf_customer_nameformula(wdd.sold_to_party_id) CF_customer_name,
    WSH_PICK_SLIP_RPT.CP_warehouse_code_p CP_warehouse_code,
    WSH_PICK_SLIP_RPT.CP_warehouse_name_p CP_warehouse_name,
    WSH_PICK_SLIP_RPT.st_addr1_p st_addr1,
    WSH_PICK_SLIP_RPT.st_addr4_p st_addr4,
    WSH_PICK_SLIP_RPT.st_addr5_p st_addr5,
    WSH_PICK_SLIP_RPT.st_addr2_p st_addr2,
    WSH_PICK_SLIP_RPT.st_addr3_p st_addr3, 
    WSH_PICK_SLIP_RPT.f_to_locationformula(wpsv.transfer_locator_id, wdd.organization_id) F_TO_LOCATION, 
    WSH_PICK_SLIP_RPT.cf_customerformula(wdd.sold_to_party_id) CF_customer, 
    WSH_PICK_SLIP_RPT.CF_CONTACT_NAMEFORMULA(wdd.ship_to_contact_id, wdd.delivery_detail_id, wdd.source_line_type, wdd.sold_to_party_id) CF_contact_name, 
    WSH_PICK_SLIP_RPT.f_item_descriptionformula(msik.description, wdd.inventory_item_id, wdd.organization_id, msik.description) F_ITEM_DESCRIPTION, 
    WSH_PICK_SLIP_RPT.f_requested_quantityformula(wdd.sales_order_number, wdd.sales_order_line_number, wpsv.move_order_line_id) F_REQUESTED_QUANTITY, 
  WSH_PICK_SLIP_RPT.f_shipped_quantityformula() F_SHIPPED_QUANTITY, 
    WSH_PICK_SLIP_RPT.f_from_locationformula(decode ( msik.reservable_type , 2 , wdd.locator_id , wpsv.locator_id ), wdd.organization_id) F_FROM_LOCATION,  
  WSH_PICK_SLIP_RPT.cf_freight_terms_nameformula(wdd.freight_terms_code) CF_FREIGHT_TERMS_NAME,
    WSH_PICK_SLIP_RPT.cf_revisionformula(nvl ( wpsv.transaction_id , - 99 )) CF_REVISION,
  WSH_PICK_SLIP_RPT.cf_pick_wave_nameformula(wdd.batch_id) CF_PICK_WAVE,
  WSH_PICK_SLIP_RPT.cf_line_status('2') CF_LINE_STATUS,
       WSH_PICK_SLIP_RPT.uom_convert(WDD.inventory_item_id, ABS(wpsv.transaction_quantity), WDD.requested_quantity_uom, WPSV.transaction_uom) requested_pick_qty,
       wpsv.transaction_uom requested_pick_qty_uom_code,
       iuom3.unit_of_measure requested_pick_qty_uom,
       null MAXIMUM_OVER_PICK_QUANTITY,
       wpsv.pick_slip_number pick_slip_number2, --27/12/2022
       decode(wdd.source_line_type,'TRANSFER_ORDER',WSH_PICK_SLIP_RPT.cf_requisition_numberformula(wdd.sales_order_number,wdd.sales_order_line_number),NULL) CF_requisition_number2, --27/12/2022
       (select r.JUSTIFICATION 
          from POR_REQUISITION_HEADERS_ALL r 
         where r.REQUISITION_NUMBER = decode(wdd.source_line_type,'TRANSFER_ORDER',WSH_PICK_SLIP_RPT.cf_requisition_numberformula(wdd.sales_order_number,wdd.sales_order_line_number),NULL) 
           and rownum = 1) justi_rq,
       (select r.DESCRIPTION 
          from POR_REQUISITION_HEADERS_ALL r 
         where r.REQUISITION_NUMBER = decode(wdd.source_line_type,'TRANSFER_ORDER',WSH_PICK_SLIP_RPT.cf_requisition_numberformula(wdd.sales_order_number,wdd.sales_order_line_number),NULL) 
           and rownum = 1) desc_rq,
       WSH_PICK_SLIP_RPT.cf_pick_wave_nameformula(wdd.batch_id) CF_PICK_WAVE2, --27/12/2022
       msik.item_number,
       msik.description item_desc2,
       decode(msik.reservable_type,2,wdd.subinventory,wpsv.subinventory_code) from_subinventory2,
       WSH_PICK_SLIP_RPT.CP_warehouse_name_p CP_warehouse_name2,
       WSH_PICK_SLIP_RPT.f_to_locationformula(wpsv.transfer_locator_id, wdd.organization_id) F_TO_LOCATION2,
--       (select name from HR_ORGANIZATION_UNITS h where h.organization_id = wpsv.TRANSFER_ORGANIZATION_ID) f_to_org2,
	   (select name from HR_ORGANIZATION_UNITS h where h.LOCATION_ID = wdd.SHIP_TO_LOCATION_ID ) f_to_org2,   ----***
       nvl((select sum(i.PRIMARY_TRANSACTION_QUANTITY)
              from inv_onhand_quantities_detail i
             where i.inventory_item_id = wdd.inventory_item_id 
               and i.locator_id = decode(msik.reservable_type,2,wdd.locator_id,wpsv.locator_id)
               and i.subinventory_code = decode(msik.reservable_type,2,wdd.subinventory,wpsv.subinventory_code)
               and i.ORGANIZATION_ID = wdd.organization_id),
           0) qty_o2,
       nvl((select sum(i.PRIMARY_TRANSACTION_QUANTITY)
              from inv_onhand_quantities_detail i
             where i.inventory_item_id = wdd.inventory_item_id 
               and i.locator_id = wpsv.transfer_locator_id
               and i.subinventory_code = wpsv.transfer_subinventory
               and i.ORGANIZATION_ID = wpsv.TRANSFER_ORGANIZATION_ID),
           0) qty_d2,
       (select h.name
          from inv_org_parameters o, HR_ORGANIZATION_UNITS h
         where o.BUSINESS_UNIT_ID = h.organization_id
           and o.organization_id = wdd.organization_id) BUSINESS_UNIT
  FROM 
       inv_material_txns wpsv,
       wsh_delivery_details wdd,
       inv_txn_request_headers mtrh,
       inv_txn_request_lines mtrl,
       wsh_delivery_assignments wda,   
       wsh_new_deliveries wnd,
       inv_pick_grouping_rules_vl wpgr,
       egp_system_items_vl  msik,
       inv_units_of_measure_vl iuom,
       inv_units_of_measure_vl iuom2,
       inv_units_of_measure_vl iuom3
 WHERE wpsv.pick_slip_number is not NULL
   AND nvl(wpsv.transaction_quantity,0) < 0 
   AND wpsv.move_order_line_id = mtrl.line_id
   AND wpsv.move_order_line_id = wdd.move_order_line_id
   AND nvl(wpsv.transaction_id,-99) = decode(nvl(wdd.transaction_id ,-99),-99,nvl(wpsv.transaction_id,-99),wdd.transaction_id)
   AND wdd.inventory_item_id = msik.inventory_item_id(+)
   AND wdd.organization_id = msik.organization_id(+)
   AND wdd.delivery_detail_id = wda.delivery_detail_id
   AND wda.delivery_id = wnd.delivery_id(+)
   AND (wnd.delivery_type is null or wnd.delivery_type = 'STANDARD') 
   --AND wdd.released_status != 'S'
   AND mtrh.grouping_rule_id = wpgr.pick_grouping_rule_id(+)
   AND mtrl.header_id = mtrh.header_id
   AND mtrl.line_id = wdd.move_order_line_id
   AND wdd.requested_quantity_uom = iuom.uom_code
   AND wdd.requested_quantity_uom2 = iuom2.uom_code (+)
   AND wpsv.transaction_uom = iuom3.uom_code
        &LP_PICK_STATUS       
        &LP_WAREHOUSE_CLAUSE  
        &LP_PICK_SLIP_NUM
        &LP_MO_CLAUSE
        &LP_ORDER_NUM
        &LP_CUSTOMER_ID
        &lp_ship_method_code
        ORDER BY 1 ASC,50 ASC,47 ASC,12 ASC,42 ASC,38 ASC,39 ASC,40 ASC,41 ASC,45 ASC,46 ASC,18 ASC,20 ASC,4 ASC,2 ASC,5 ASC,8 ASC,9 ASC,13 ASC,10 ASC,14 ASC,17 ASC,24 ASC,25 ASC,26 ASC,27 ASC,28 ASC,29 ASC,31 ASC,33 ASC,19 ASC,22 ASC,32 ASC,30 ASC,34 ASC,37 ASC,48 ASC,43 ASC,23 ASC,44 ASC,49 ASC,21 ASC,3 ASC





        select
    Nombre_BU,
    Nombre_LM,
    Cuenta_Desembolso,
    Propuesta_Pago,
    Numero_Pago,
    Estado_Pago,
    Tipo_Pago,
    Tipo_TC,
    Estado_Conciliacion,
    Fecha_Factura,
    Fecha_Vencimiento,
    Numero_Factura,
    Descripcion,
    Id_Contribuyente,
    Proveedor,
    Beneficiario_Pago,
    Sitio_Pago,
    Fecha_Pago,
    Valor_Pago,
    Moneda_Pago,
    TrmPago,
    Valor_Factura,
    Moneda_Factura,
    Trm_Factura,
    Banco_Beneficiario,
    Numero_Cuenta_Beneficiario
    
from
    (
        SELECT
            (
                select
                    xep.name
                from
                    xle_entity_profiles xep
                where
                    xep.LEGAL_ENTITY_ID = aia.LEGAL_ENTITY_ID
            ) as Nombre_BU,
            (
                select
                    gl.name
                from
                    gl_ledgers gl
                where
                    gl.LEDGER_ID = aia.SET_OF_BOOKS_ID
            ) as Nombre_LM,
            aca.BANK_ACCOUNT_NAME as Cuenta_Desembolso,
            (
                case
                    when aca.CHECKRUN_NAME like 'Quick payment:%' then 'N/A'
                    when aca.CHECKRUN_NAME like 'Pago rápido:%' then 'N/A'
                    else aca.CHECKRUN_NAME
                end
            ) as Propuesta_Pago,
            aca.CHECK_NUMBER as Numero_Pago,
            aca.STATUS_LOOKUP_CODE as Estado_Pago,
            flv.MEANING as Tipo_Pago,
            gdct.USER_CONVERSION_TYPE as Tipo_TC,
            decode(aca.RECON_FLAG, 'Y', 'Yes', 'N', 'No') as Estado_Conciliacion,
            to_char(aia.INVOICE_DATE, 'dd/mm/yyyy') as Fecha_Factura,
            to_char(idpa.PAYMENT_DUE_DATE, 'dd/mm/yyyy') as Fecha_Vencimiento,
            aia.invoice_num as Numero_Factura,
            aia.DESCRIPTION as Descripcion,
            ipa.INV_PAYEE_LE_REG_NUM as Id_Contribuyente,
            aca.vendor_name as Proveedor,
            aca.REMIT_TO_SUPPLIER_NAME as Beneficiario_Pago,
            pssam.VENDOR_SITE_CODE as Sitio_Pago,
            to_char(aca.CHECK_DATE, 'dd/mm/yyyy') as Fecha_Pago,
            TRIM(
                to_char(aca.AMOUNT, '999G999G999G999G999G999G999D99')
            ) as Valor_Pago,
            aca.CURRENCY_CODE as Moneda_Pago,
            (
                case
                    when aipa.INVOICE_CURRENCY_CODE = aipa.PAYMENT_CURRENCY_CODE then (
                        select
                            CONVERSION_RATE
                        from
                            GL_DAILY_RATES
                        where
                            1 = 1
                            and conversion_date = aca.CHECK_DATE
                            and from_currency = 'USD'
                            and to_currency = 'COP'
                            and conversion_type = '300000004035333'
                    )
                    else aipa.X_CURR_RATE
                end
            ) as TrmPago, --RDSR
            TRIM(
                to_char(
                    aipa.AMOUNT_INV_CURR ,
                    '999G999G999G999G999G999G999D99'
                )
            ) as Valor_Factura,
            aia.INVOICE_CURRENCY_CODE as Moneda_Factura,
            (
                select
                    CONVERSION_RATE
                from
                    GL_DAILY_RATES
                where
                    1 = 1
                    and conversion_date = aia.GL_DATE
                    and from_currency = 'USD'
                    and to_currency = 'COP'
                    and conversion_type = '300000004035333'
            ) as Trm_Factura, --RDSR
            ipaav.BANK_NAME as Banco_Beneficiario,
            ieba.MASKED_BANK_ACCOUNT_NUM as Numero_Cuenta_Beneficiario
        FROM
            ap_invoices_all aia,
            ap_invoice_payments_all aipa,
            ap_checks_all aca,
            POZ_SUPPLIER_SITES_ALL_M pssam,
            IBY_PAYEE_ALL_BANKACCT_V ipaav,
            IBY_EXT_BANK_ACCOUNTS ieba,
            IBY_DOCS_PAYABLE_ALL idpa, --solo es usado para la fecha de vencimiento de pago
            IBY_PAYMENTS_ALL ipa,
            gl_daily_conversion_types gdct,
            FND_LOOKUP_VALUES flv
        WHERE
            1 = 1
            and aia.invoice_id = aipa.invoice_id
            and aipa.check_id = aca.check_id
            and aca.status_lookup_code <> 'VOIDED'
            and aia.vendor_site_id = pssam.vendor_site_id
            and aca.EXTERNAL_BANK_ACCOUNT_ID = ipaav.EXT_BANK_ACCOUNT_ID
            and ipaav.EXT_BANK_ACCOUNT_ID = ieba.EXT_BANK_ACCOUNT_ID
            and aca.payment_id = idpa.payment_id
            and idpa.DOCUMENT_TYPE = 'STANDARD'
            and idpa.CALLING_APP_DOC_REF_NUMBER = aia.invoice_num --match entre pago y su factura
            and aca.payment_id = ipa.payment_id
            and aca.X_CURR_RATE_TYPE = gdct.CONVERSION_TYPE
            and aca.PAYMENT_TYPE_FLAG = flv.LOOKUP_CODE
            and flv.LANGUAGE = 'US' --Tipo de pago en ingles
            --and flv.LANGUAGE = 'E' --Tipo de pago en español
            and flv.LOOKUP_TYPE = 'PAYMENT TYPE'
            and aca.CHECK_NUMBER = '124' 
            --Casos
            --and aia.invoice_num in ('DSMD-25','DSMD-26','DSMD-28')
             
    ) A
where
    1 = 1
    and (
        A.Nombre_BU IN (:P_BU)
        or A.Nombre_BU is NULL
    )
    and (
        to_date(A.Fecha_Factura, 'dd/MM/yyyy') between nvl(
            :P_Fecha_Fact_Desde,
            to_date(A.Fecha_Factura, 'dd/MM/yyyy')
        )
        and nvl(
            :P_Fecha_Fact_Hasta,
            to_date(A.Fecha_Factura, 'dd/MM/yyyy')
        )
    )
    and (
        to_date(A.Fecha_Pago, 'dd/MM/yyyy') between nvl(
            :P_Fecha_Pago_Desde,
            to_date(A.Fecha_Pago, 'dd/MM/yyyy')
        )
        and nvl(
            :P_Fecha_Pago_Hasta,
            to_date(A.Fecha_Pago, 'dd/MM/yyyy')
        )
    )
    --Casos
    --and A.Nombre_BU IN ('C47 - CNEMED S.A.S. (Colombia)')
ORDER BY
    A.Nombre_BU, A.Numero_Factura