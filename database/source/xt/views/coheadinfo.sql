select xt.create_view('xt.coheadinfo', $$

select cohead_id,
  cohead_number,
  cohead_cust_id,
  cohead_custponumber,
  cohead_orderdate,
  cohead_warehous_id,
  cohead_shipto_id,
  cohead_shiptoname,
  cohead_shiptoaddress1,
  cohead_shiptoaddress2,
  cohead_shiptoaddress3,
  cohead_shiptoaddress4,
  cohead_shiptoaddress5,
  cohead_salesrep_id,
  cohead_terms_id,
  cohead_fob,
  cohead_shipvia,
  cohead_shiptocity,
  cohead_shiptostate,
  cohead_shiptozipcode,
  cohead_freight,
  cohead_misc,
  cohead_imported,
  cohead_ordercomments,
  cohead_shipcomments,
  cohead_shiptophone,
  cohead_shipchrg_id,
  cohead_shipform_id,
  cohead_billtoname,
  cohead_billtoaddress1,
  cohead_billtoaddress2,
  cohead_billtoaddress3,
  cohead_billtocity,
  cohead_billtostate,
  cohead_billtozipcode,
  cohead_misc_accnt_id,
  cohead_misc_descrip,
  cohead_commission,
  cohead_miscdate,
  cohead_holdtype,
  cohead_packdate,
  cohead_prj_id,
  cohead_wasquote,
  cohead_lastupdated,
  cohead_shipcomplete,
  cohead_created,
  cohead_creator,
  cohead_quote_number,
  cohead_billtocountry,
  cohead_shiptocountry,
  cohead_curr_id,
  cohead_calcfreight,
  cohead_shipto_cntct_id,
  cohead_shipto_cntct_honorific,
  cohead_shipto_cntct_first_name,
  cohead_shipto_cntct_middle,
  cohead_shipto_cntct_last_name,
  cohead_shipto_cntct_suffix,
  cohead_shipto_cntct_phone,
  cohead_shipto_cntct_title,
  cohead_shipto_cntct_fax,
  cohead_shipto_cntct_email,
  cohead_billto_cntct_id,
  cohead_billto_cntct_honorific,
  cohead_billto_cntct_first_name,
  cohead_billto_cntct_middle,
  cohead_billto_cntct_last_name,
  cohead_billto_cntct_suffix,
  cohead_billto_cntct_phone,
  cohead_billto_cntct_title,
  cohead_billto_cntct_fax,
  cohead_billto_cntct_email,
  cohead_taxzone_id,
  cohead_taxtype_id,
  cohead_ophead_id,
  cohead_status,
  cohead_saletype_id,
  cohead_shipzone_id,
  cohead.obj_uuid,
  create_dfltworkflow,
  xt.co_schedule_date(cohead) as schedule_date,
  xt.co_freight_weight(cohead) as freight_weight,
  xt.co_subtotal(cohead) as subtotal,
  xt.co_tax_total(cohead) as tax_total,
  xt.co_total(cohead) as total,
  xt.co_margin(cohead) as margin,
  xt.co_allocated_credit(cohead)::numeric as allocated_credit,
  xt.co_authorized_credit(cohead_number) as authorized_credit,
  xt.cust_outstanding_credit(cohead_cust_id, cohead_curr_id, cohead_orderdate) as outstanding_credit,
  greatest(0.0, (
    xt.co_total(cohead)
    - COALESCE(xt.co_allocated_credit(cohead), 0)
    - COALESCE(xt.co_authorized_credit(cohead_number), 0)
    - COALESCE(xt.cust_outstanding_credit(cohead_cust_id, cohead_curr_id, cohead_orderdate), 0))
  ) as balance,
  ophead_number,
  cust_number 
  from cohead
    left join cust on cust_id = cohead_cust_id
    left join ophead on ophead_id = cohead_ophead_id;

$$, false);

create or replace rule "_INSERT" as on insert to xt.coheadinfo do instead

insert into cohead (
  cohead_id,
  cohead_number,
  cohead_cust_id,
  cohead_orderdate,
  cohead_shipto_id,
  cohead_shiptoname,
  cohead_shiptoaddress1,
  cohead_shiptoaddress2,
  cohead_shiptoaddress3,
  cohead_shiptoaddress4,
  cohead_shiptoaddress5,
  cohead_shiptocity,
  cohead_shiptostate,
  cohead_shiptozipcode,
  cohead_shiptophone,
  cohead_shipchrg_id,
  cohead_shipform_id,
  cohead_salesrep_id,
  cohead_terms_id,
  cohead_freight,
  cohead_ordercomments,
  cohead_shipcomments,
  cohead_billtoname,
  cohead_billtoaddress1,
  cohead_billtoaddress2,
  cohead_billtoaddress3,
  cohead_billtocity,
  cohead_billtostate,
  cohead_billtozipcode,
  cohead_commission,
  cohead_miscdate,
  cohead_holdtype,
  cohead_custponumber,
  cohead_fob,
  cohead_shipvia,
  cohead_warehous_id,
  cohead_packdate,
  cohead_prj_id,
  cohead_wasquote,
  cohead_lastupdated,
  cohead_shipcomplete,
  cohead_created,
  cohead_creator,
  cohead_quote_number,
  cohead_misc,
  cohead_misc_accnt_id,
  cohead_misc_descrip,
  cohead_billtocountry,
  cohead_shiptocountry,
  cohead_curr_id,
  cohead_imported,
  cohead_calcfreight,
  cohead_shipto_cntct_id,
  cohead_shipto_cntct_honorific,
  cohead_shipto_cntct_first_name,
  cohead_shipto_cntct_middle,
  cohead_shipto_cntct_last_name,
  cohead_shipto_cntct_suffix,
  cohead_shipto_cntct_phone,
  cohead_shipto_cntct_title,
  cohead_shipto_cntct_fax,
  cohead_shipto_cntct_email,
  cohead_billto_cntct_id,
  cohead_billto_cntct_honorific,
  cohead_billto_cntct_first_name,
  cohead_billto_cntct_middle,
  cohead_billto_cntct_last_name,
  cohead_billto_cntct_suffix,
  cohead_billto_cntct_phone,
  cohead_billto_cntct_title,
  cohead_billto_cntct_fax,
  cohead_billto_cntct_email,
  cohead_taxzone_id,
  cohead_taxtype_id,
  cohead_ophead_id,
  cohead_status,
  cohead_saletype_id,
  cohead_shipzone_id
) values (
  new.cohead_id,
  new.cohead_number,
  new.cohead_cust_id,
  new.cohead_orderdate,
  new.cohead_shipto_id,
  new.cohead_shiptoname,
  new.cohead_shiptoaddress1,
  new.cohead_shiptoaddress2,
  new.cohead_shiptoaddress3,
  new.cohead_shiptoaddress4,
  new.cohead_shiptoaddress5,
  new.cohead_shiptocity,
  new.cohead_shiptostate,
  new.cohead_shiptozipcode,
  new.cohead_shiptophone,
  new.cohead_shipchrg_id,
  new.cohead_shipform_id,
  new.cohead_salesrep_id,
  new.cohead_terms_id,
  new.cohead_freight,
  new.cohead_ordercomments,
  new.cohead_shipcomments,
  new.cohead_billtoname,
  new.cohead_billtoaddress1,
  new.cohead_billtoaddress2,
  new.cohead_billtoaddress3,
  new.cohead_billtocity,
  new.cohead_billtostate,
  new.cohead_billtozipcode,
  new.cohead_commission,
  new.cohead_miscdate,
  coalesce(new.cohead_holdtype, 'N'),
  new.cohead_custponumber,
  new.cohead_fob,
  new.cohead_shipvia,
  new.cohead_warehous_id,
  new.cohead_packdate,
  new.cohead_prj_id,
  new.cohead_wasquote,
  new.cohead_lastupdated,
  new.cohead_shipcomplete,
  coalesce(new.cohead_created, now()),
  coalesce(new.cohead_creator, geteffectivextuser()),
  new.cohead_quote_number,
  new.cohead_misc,
  new.cohead_misc_accnt_id,
  new.cohead_misc_descrip,
  new.cohead_billtocountry,
  new.cohead_shiptocountry,
  new.cohead_curr_id,
  coalesce(new.cohead_imported, false),
  new.cohead_calcfreight,
  new.cohead_shipto_cntct_id,
  new.cohead_shipto_cntct_honorific,
  new.cohead_shipto_cntct_first_name,
  new.cohead_shipto_cntct_middle,
  new.cohead_shipto_cntct_last_name,
  new.cohead_shipto_cntct_suffix,
  new.cohead_shipto_cntct_phone,
  new.cohead_shipto_cntct_title,
  new.cohead_shipto_cntct_fax,
  new.cohead_shipto_cntct_email,
  new.cohead_billto_cntct_id,
  new.cohead_billto_cntct_honorific,
  new.cohead_billto_cntct_first_name,
  new.cohead_billto_cntct_middle,
  new.cohead_billto_cntct_last_name,
  new.cohead_billto_cntct_suffix,
  new.cohead_billto_cntct_phone,
  new.cohead_billto_cntct_title,
  new.cohead_billto_cntct_fax,
  new.cohead_billto_cntct_email,
  new.cohead_taxzone_id,
  new.cohead_taxtype_id,
  new.cohead_ophead_id,
  new.cohead_status,
  new.cohead_saletype_id,
  new.cohead_shipzone_id
)

returning cohead_id,
  cohead_number,
  cohead_cust_id,
  cohead_custponumber,
  cohead_orderdate,
  cohead_warehous_id,
  cohead_shipto_id,
  cohead_shiptoname,
  cohead_shiptoaddress1,
  cohead_shiptoaddress2,
  cohead_shiptoaddress3,
  cohead_shiptoaddress4,
  cohead_shiptoaddress5,
  cohead_salesrep_id,
  cohead_terms_id,
  cohead_fob,
  cohead_shipvia,
  cohead_shiptocity,
  cohead_shiptostate,
  cohead_shiptozipcode,
  cohead_freight,
  cohead_misc,
  cohead_imported,
  cohead_ordercomments,
  cohead_shipcomments,
  cohead_shiptophone,
  cohead_shipchrg_id,
  cohead_shipform_id,
  cohead_billtoname,
  cohead_billtoaddress1,
  cohead_billtoaddress2,
  cohead_billtoaddress3,
  cohead_billtocity,
  cohead_billtostate,
  cohead_billtozipcode,
  cohead_misc_accnt_id,
  cohead_misc_descrip,
  cohead_commission,
  cohead_miscdate,
  cohead_holdtype,
  cohead_packdate,
  cohead_prj_id,
  cohead_wasquote,
  cohead_lastupdated,
  cohead_shipcomplete,
  cohead_created,
  cohead_creator,
  cohead_quote_number,
  cohead_billtocountry,
  cohead_shiptocountry,
  cohead_curr_id,
  cohead_calcfreight,
  cohead_shipto_cntct_id,
  cohead_shipto_cntct_honorific,
  cohead_shipto_cntct_first_name,
  cohead_shipto_cntct_middle,
  cohead_shipto_cntct_last_name,
  cohead_shipto_cntct_suffix,
  cohead_shipto_cntct_phone,
  cohead_shipto_cntct_title,
  cohead_shipto_cntct_fax,
  cohead_shipto_cntct_email,
  cohead_billto_cntct_id,
  cohead_billto_cntct_honorific,
  cohead_billto_cntct_first_name,
  cohead_billto_cntct_middle,
  cohead_billto_cntct_last_name,
  cohead_billto_cntct_suffix,
  cohead_billto_cntct_phone,
  cohead_billto_cntct_title,
  cohead_billto_cntct_fax,
  cohead_billto_cntct_email,
  cohead_taxzone_id,
  cohead_taxtype_id,
  cohead_ophead_id,
  cohead_status,
  cohead_saletype_id,
  cohead_shipzone_id,
  cohead.obj_uuid,
  create_dfltworkflow, null::date, null::numeric, null::numeric, null::numeric, 
null::numeric, null::numeric, null::numeric, null::numeric, null::numeric, null::numeric, 
null::text, null::text;

create or replace rule "_UPDATE" as on update to xt.coheadinfo do instead

update cohead set
  cohead_number = new.cohead_number,
  cohead_cust_id = new.cohead_cust_id,
  cohead_orderdate = new.cohead_orderdate,
  cohead_shipto_id = new.cohead_shipto_id,
  cohead_shiptoname = new.cohead_shiptoname,
  cohead_shiptoaddress1 = new.cohead_shiptoaddress1,
  cohead_shiptoaddress2 = new.cohead_shiptoaddress2,
  cohead_shiptoaddress3 = new.cohead_shiptoaddress3,
  cohead_shiptoaddress4 = new.cohead_shiptoaddress4,
  cohead_shiptoaddress5 = new.cohead_shiptoaddress5,
  cohead_shiptocity = new.cohead_shiptocity,
  cohead_shiptostate = new.cohead_shiptostate,
  cohead_shiptozipcode = new.cohead_shiptozipcode,
  cohead_shiptophone = new.cohead_shiptophone,
  cohead_shipchrg_id = new.cohead_shipchrg_id,
  cohead_shipform_id = new.cohead_shipform_id,
  cohead_salesrep_id = new.cohead_salesrep_id,
  cohead_terms_id = new.cohead_terms_id,
  cohead_freight = new.cohead_freight,
  cohead_ordercomments = new.cohead_ordercomments,
  cohead_shipcomments = new.cohead_shipcomments,
  cohead_billtoname = new.cohead_billtoname,
  cohead_billtoaddress1 = new.cohead_billtoaddress1,
  cohead_billtoaddress2 = new.cohead_billtoaddress2,
  cohead_billtoaddress3 = new.cohead_billtoaddress3,
  cohead_billtocity = new.cohead_billtocity,
  cohead_billtostate = new.cohead_billtostate,
  cohead_billtozipcode = new.cohead_billtozipcode,
  cohead_commission = new.cohead_commission,
  cohead_miscdate = new.cohead_miscdate,
  cohead_holdtype = new.cohead_holdtype,
  cohead_custponumber = new.cohead_custponumber,
  cohead_fob = new.cohead_fob,
  cohead_shipvia = new.cohead_shipvia,
  cohead_warehous_id = new.cohead_warehous_id,
  cohead_packdate = new.cohead_packdate,
  cohead_prj_id = new.cohead_prj_id,
  cohead_wasquote = new.cohead_wasquote,
  cohead_lastupdated = new.cohead_lastupdated,
  cohead_shipcomplete = new.cohead_shipcomplete,
  cohead_created = new.cohead_created,
  cohead_creator = new.cohead_creator,
  cohead_quote_number = new.cohead_quote_number,
  cohead_misc = new.cohead_misc,
  cohead_misc_accnt_id = new.cohead_misc_accnt_id,
  cohead_misc_descrip = new.cohead_misc_descrip,
  cohead_billtocountry = new.cohead_billtocountry,
  cohead_shiptocountry = new.cohead_shiptocountry,
  cohead_curr_id = new.cohead_curr_id,
  cohead_imported = new.cohead_imported,
  cohead_calcfreight = new.cohead_calcfreight,
  cohead_shipto_cntct_id = new.cohead_shipto_cntct_id,
  cohead_shipto_cntct_honorific = new.cohead_shipto_cntct_honorific,
  cohead_shipto_cntct_first_name = new.cohead_shipto_cntct_first_name,
  cohead_shipto_cntct_middle = new.cohead_shipto_cntct_middle,
  cohead_shipto_cntct_last_name = new.cohead_shipto_cntct_last_name,
  cohead_shipto_cntct_suffix = new.cohead_shipto_cntct_suffix,
  cohead_shipto_cntct_phone = new.cohead_shipto_cntct_phone,
  cohead_shipto_cntct_title = new.cohead_shipto_cntct_title,
  cohead_shipto_cntct_fax = new.cohead_shipto_cntct_fax,
  cohead_shipto_cntct_email = new.cohead_shipto_cntct_email,
  cohead_billto_cntct_id = new.cohead_billto_cntct_id,
  cohead_billto_cntct_honorific = new.cohead_billto_cntct_honorific,
  cohead_billto_cntct_first_name = new.cohead_billto_cntct_first_name,
  cohead_billto_cntct_middle = new.cohead_billto_cntct_middle,
  cohead_billto_cntct_last_name = new.cohead_billto_cntct_last_name,
  cohead_billto_cntct_suffix = new.cohead_billto_cntct_suffix,
  cohead_billto_cntct_phone = new.cohead_billto_cntct_phone,
  cohead_billto_cntct_title = new.cohead_billto_cntct_title,
  cohead_billto_cntct_fax = new.cohead_billto_cntct_fax,
  cohead_billto_cntct_email = new.cohead_billto_cntct_email,
  cohead_taxzone_id = new.cohead_taxzone_id,
  cohead_taxtype_id = new.cohead_taxtype_id,
  cohead_ophead_id = new.cohead_ophead_id,
  cohead_status = new.cohead_status,
  cohead_saletype_id = new.cohead_saletype_id,
  cohead_shipzone_id = cohead_shipzone_id
where cohead_id = old.cohead_id;

create or replace rule "_DELETE" as on delete to xt.coheadinfo do instead

select deleteso(old.cohead_id);
