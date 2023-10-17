SELECT cpd.payment_document_name c_check_stock_name,
       ch.check_number c_check_number,
       TO_CHAR(ch.check_date, 'YYYY-MM-DD') c_check_date,
       ch.amount c_amount,
       nvl(substr(ch.remit_to_supplier_name, 1, 39),
           substr(ch.vendor_name, 1, 39)) c_vendor_name,
       substr(pssv.vendor_site_code, 1, 10),
       nvl(ch.remit_to_address_name, pssv.vendor_site_code) c_vendor_site_code,
       decode(nvl(ch.remit_to_supplier_name, '-999999'),
              '-999999',
              substr(pssv.address_line1, 1, 35),
              substr(hzl.address1, 1, 35)) c_address_line1,
       decode(nvl(ch.remit_to_supplier_name, '-999999'),
              '-999999',
              substr(pssv.address_line2, 1, 35),
              substr(hzl.address2, 1, 35)) c_address_line2,
       decode(nvl(ch.remit_to_supplier_name, '-999999'),
              '-999999',
              substr(pssv.address_line3, 1, 35),
              substr(hzl.address3, 1, 35)) c_address_line3,
       decode(nvl(ch.remit_to_supplier_name, '-999999'),
              '-999999',
              substr(pssv.city, 1, 20),
              substr(hzl.city, 1, 20)) c_city,
       decode(nvl(ch.remit_to_supplier_name, '-999999'),
              '-999999',
              substr(pssv.state, 1, 15),
              substr(hzl.state, 1, 15)) c_state,
       decode(nvl(ch.remit_to_supplier_name, '-999999'),
              '-999999',
              substr(pssv.zip, 1, 15),
              substr(hzl.postal_code, 1, 15)) c_zip,
       decode(nvl(ch.remit_to_supplier_name, '-999999'),
              '-999999',
              substr(pssv.country, 1, 25),
              substr(hzl.country, 1, 25)) c_country,
       TO_CHAR(ch.cleared_date, 'YYYY-MM-DD') c_cleared_date,
       ch.cleared_amount c_cleared_amount,
       lk2.displayed_field c_nls_status,
       br.bank_name c_bank,
       br.bank_branch_name c_branch,
       ch.bank_account_name c_account,
       /* rallamse, commented as not referred in DT or Layout template, column does not exist in Fusion schema 
       ch.bank_account_id  c_accountid,*/
       br.branch_party_id c_bank_branch,
       ba.currency_code c_currency_code,
       ch.currency_code c_pay_currency_code,
       --AP_APXMTDCR_XMLP_PKG.c_currency_descformula(ba.currency_code) 
       '' C_CURRENCY_DESC,
       --AP_APXMTDCR_XMLP_PKG.c_pay_currency_descformula(ch.currency_code) 
       '' C_PAY_CURRENCY_DESC,
       --AP_APXMTDCR_XMLP_PKG.check_flag(ba.currency_code, ch.currency_code) 
       '' C_CHECK_CURR_FLAG,
       ch.doc_sequence_value C_DOC_SEQUENCE_VALUE,

       ieba.BANK_ACCOUNT_NUM prov_bank_Acct,
       
       aia.invoice_num,
       to_char(aia.invoice_date, 'dd/MM/yyyy') invoice_date,
       trim(to_char(aipa.AMOUNT_INV_CURR,  'fm999,999,999,999,999,999.00')) || ' ' ||

       aipa.INVOICE_CURRENCY_CODE invoice_amount, ------
       
       trim(to_char(aipa.AMOUNT,  'fm999,999,999,999,999,999.00')) || ' ' ||
       aipa.PAYMENT_CURRENCY_CODE payment_amount,
       aia.invoice_amount doc_amount,
       initcap(aia.INVOICE_TYPE_LOOKUP_CODE) document_type


  FROM ap_checks_all ch
  join iby_ext_bank_accounts ieba
    on ieba.ext_bank_account_id = ch.external_bank_account_id
  left join ce_payment_documents cpd
    on cpd.payment_document_id = ch.payment_document_id --EDITED BY PKOLAN   
  join ce_bank_acct_uses_all cbau
    on ch.ce_bank_acct_use_id = cbau.bank_acct_use_id
  join ce_bank_accounts ba
    on cbau.bank_account_id = ba.bank_account_id
  join ce_bank_branches_v br
    on ba.bank_branch_id = br.branch_party_id
  left join poz_supplier_sites_v pssv
    on ch.vendor_id = pssv.vendor_id
   and ch.vendor_site_id = pssv.vendor_site_id
  join ap_lookup_codes lk2
    on lk2.lookup_code = ch.status_lookup_code
   and lk2.lookup_type = 'CHECK STATE'
  left join fnd_territories_vl ft
    on ch.country = ft.territory_code
  left join HZ_PARTY_SITES hps
    on ch.remit_to_address_id = hps.party_site_id
  left join hZ_LOCATIONS hzl
    on hps.location_id = hzl.location_id
-------------
  join AP_INVOICE_PAYMENTS_ALL aipa
    on ch.check_id = aipa.check_id

  join AP_INVOICES_ALL aia
    on ch.legal_entity_id = aia.legal_entity_id
   and aipa.invoice_id = aia.invoice_id

 where 1 = 1
   and ch.payment_type_flag = nvl(:P_PAYMENT_TYPE, ch.payment_type_flag)
   and trunc(ch.check_date) between --EDITED BY PKOLAN
       to_date(substr(to_char(:P_FROM_DATE), 1, 10), 'yyyy-MM-dd') and to_date(substr(to_char(:P_TO_DATE), 1, 10), 'yyyy-MM-dd')
   and ch.org_id = :P_BUSINESS_UNIT /* Added rallamse for org_id */
      
   and (ch.checkrun_name = :P_CHECKRUN OR
        (ch.checkrun_name LIKE '%' || :P_CHECKRUN || '%' AND
        UPPER(NVL(:P_PAYMENT_TYPE, 'X')) = 'Q') or
        :P_CHECKRUN is null
       )

 order by upper(br.bank_name),
          upper(br.bank_branch_name),
          upper(ch.bank_account_name),
          ch.currency_code,
          cpd.payment_document_name,
          ch.check_number