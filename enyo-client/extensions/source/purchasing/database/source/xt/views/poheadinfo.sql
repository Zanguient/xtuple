select xt.create_view('xt.poheadinfo', $$

-- 'Main' address is vendor address
select pohead.*,
  uuid as vendaddr_uuid,
  xt.po_freight_subtotal(pohead) as freight_subtotal,
  xt.po_subtotal(pohead) as subtotal,
  xt.po_tax_total(pohead) as tax_total,
  xt.po_total(pohead) as total
from pohead
  join xt.vendaddrxt on id=pohead_vend_id and vend_id=pohead_vend_id
where pohead_vendaddr_id is null

union all

-- Vendor address is an alternate address
select pohead.*,
  vendaddrinfo.obj_uuid as vendaddr_uuid,
  xt.po_freight_subtotal(pohead) as freight_subtotal,
  xt.po_subtotal(pohead) as subtotal,
  xt.po_tax_total(pohead) as tax_total,
  xt.po_total(pohead) as total
from pohead
  join vendaddrinfo on vendaddr_id=pohead_vendaddr_id

$$, false);

create or replace rule "_INSERT" as on insert to xt.poheadinfo do instead

insert into pohead (
  pohead_id,
  pohead_status,
  pohead_number,
  pohead_orderdate,
  pohead_vend_id,
  pohead_fob,
  pohead_shipvia,
  pohead_potype_id,
  pohead_comments,
  pohead_freight,
  pohead_printed,
  pohead_terms_id,
  pohead_warehous_id,
  pohead_vendaddr_id,
  pohead_agent_username,
  pohead_curr_id,
  pohead_saved,
  pohead_taxzone_id,
  pohead_taxtype_id,
  pohead_dropship,
  pohead_vend_cntct_id,
  pohead_vend_cntct_honorific,
  pohead_vend_cntct_first_name,
  pohead_vend_cntct_middle,
  pohead_vend_cntct_last_name,
  pohead_vend_cntct_suffix,
  pohead_vend_cntct_phone,
  pohead_vend_cntct_title,
  pohead_vend_cntct_fax,
  pohead_vend_cntct_email,
  pohead_vendaddress1,
  pohead_vendaddress2,
  pohead_vendaddress3,
  pohead_vendcity,
  pohead_vendstate,
  pohead_vendzipcode,
  pohead_vendcountry,
  pohead_shipto_cntct_id,
  pohead_shipto_cntct_honorific,
  pohead_shipto_cntct_first_name,
  pohead_shipto_cntct_middle,
  pohead_shipto_cntct_last_name,
  pohead_shipto_cntct_suffix,
  pohead_shipto_cntct_phone,
  pohead_shipto_cntct_title,
  pohead_shipto_cntct_fax,
  pohead_shipto_cntct_email,
  pohead_shiptoaddress_id,
  pohead_shiptoaddress1,
  pohead_shiptoaddress2,
  pohead_shiptoaddress3,
  pohead_shiptocity,
  pohead_shiptostate,
  pohead_shiptozipcode,
  pohead_shiptocountry,
  pohead_cohead_id,
  pohead_released,
  obj_uuid
) values (
  new.pohead_id,
  new.pohead_status,
  new.pohead_number,
  new.pohead_orderdate,
  new.pohead_vend_id,
  new.pohead_fob,
  new.pohead_shipvia,
  new.pohead_potype_id,
  new.pohead_comments,
  coalesce(new.pohead_freight, 0),
  coalesce(new.pohead_printed, false),
  new.pohead_terms_id,
  new.pohead_warehous_id,
  (select vendaddr_id from vendaddrinfo where obj_uuid=new.vendaddr_uuid),
  new.pohead_agent_username,
  coalesce(new.pohead_curr_id, basecurrid()),
  true,
  new.pohead_taxzone_id,
  new.pohead_taxtype_id,
  coalesce(new.pohead_dropship, false),
  new.pohead_vend_cntct_id,
  new.pohead_vend_cntct_honorific,
  new.pohead_vend_cntct_first_name,
  new.pohead_vend_cntct_middle,
  new.pohead_vend_cntct_last_name,
  new.pohead_vend_cntct_suffix,
  new.pohead_vend_cntct_phone,
  new.pohead_vend_cntct_title,
  new.pohead_vend_cntct_fax,
  new.pohead_vend_cntct_email,
  new.pohead_vendaddress1,
  new.pohead_vendaddress2,
  new.pohead_vendaddress3,
  new.pohead_vendcity,
  new.pohead_vendstate,
  new.pohead_vendzipcode,
  new.pohead_vendcountry,
  new.pohead_shipto_cntct_id,
  new.pohead_shipto_cntct_honorific,
  new.pohead_shipto_cntct_first_name,
  new.pohead_shipto_cntct_middle,
  new.pohead_shipto_cntct_last_name,
  new.pohead_shipto_cntct_suffix,
  new.pohead_shipto_cntct_phone,
  new.pohead_shipto_cntct_title,
  new.pohead_shipto_cntct_fax,
  new.pohead_shipto_cntct_email,
  new.pohead_shiptoaddress_id,
  new.pohead_shiptoaddress1,
  new.pohead_shiptoaddress2,
  new.pohead_shiptoaddress3,
  new.pohead_shiptocity,
  new.pohead_shiptostate,
  new.pohead_shiptozipcode,
  new.pohead_shiptocountry,
  new.pohead_cohead_id,
  new.pohead_released,
  coalesce(new.obj_uuid, xt.uuid_generate_v4())
)

returning pohead.*, null::uuid, null::numeric, null::numeric, null::numeric, null::numeric;

create or replace rule "_UPDATE" as on update to xt.poheadinfo do instead

update pohead set
  pohead_status=new.pohead_status,
  pohead_number=new.pohead_number,
  pohead_orderdate=new.pohead_orderdate,
  pohead_vend_id=new.pohead_vend_id,
  pohead_fob=new.pohead_fob,
  pohead_shipvia=new.pohead_shipvia,
  pohead_potype_id=new.pohead_potype_id,
  pohead_comments=new.pohead_comments,
  pohead_freight=new.pohead_freight,
  pohead_printed=new.pohead_printed,
  pohead_terms_id=new.pohead_terms_id,
  pohead_warehous_id=new.pohead_warehous_id,
  pohead_vendaddr_id=(select vendaddr_id from vendaddrinfo where obj_uuid=new.vendaddr_uuid),
  pohead_agent_username=new.pohead_agent_username,
  pohead_curr_id=new.pohead_curr_id,
  pohead_taxzone_id=new.pohead_taxzone_id,
  pohead_taxtype_id=new.pohead_taxtype_id,
  pohead_dropship=new.pohead_dropship,
  pohead_vend_cntct_id=new.pohead_vend_cntct_id,
  pohead_vend_cntct_honorific=new.pohead_vend_cntct_honorific,
  pohead_vend_cntct_first_name=new.pohead_vend_cntct_first_name,
  pohead_vend_cntct_middle=new.pohead_vend_cntct_middle,
  pohead_vend_cntct_last_name=new.pohead_vend_cntct_last_name,
  pohead_vend_cntct_suffix=new.pohead_vend_cntct_suffix,
  pohead_vend_cntct_phone=new.pohead_vend_cntct_phone,
  pohead_vend_cntct_title=new.pohead_vend_cntct_title,
  pohead_vend_cntct_fax=new.pohead_vend_cntct_fax,
  pohead_vend_cntct_email=new.pohead_vend_cntct_email,
  pohead_vendaddress1=new.pohead_vendaddress1,
  pohead_vendaddress2=new.pohead_vendaddress2,
  pohead_vendaddress3=new.pohead_vendaddress3,
  pohead_vendcity=new.pohead_vendcity,
  pohead_vendstate=new.pohead_vendstate,
  pohead_vendzipcode=new.pohead_vendzipcode,
  pohead_vendcountry=new.pohead_vendcountry,
  pohead_shipto_cntct_id=new.pohead_shipto_cntct_id,
  pohead_shipto_cntct_honorific=new.pohead_shipto_cntct_honorific,
  pohead_shipto_cntct_first_name=new.pohead_shipto_cntct_first_name,
  pohead_shipto_cntct_middle=new.pohead_shipto_cntct_middle,
  pohead_shipto_cntct_last_name=new.pohead_shipto_cntct_last_name,
  pohead_shipto_cntct_suffix=new.pohead_shipto_cntct_suffix,
  pohead_shipto_cntct_phone=new.pohead_shipto_cntct_phone,
  pohead_shipto_cntct_title=new.pohead_shipto_cntct_title,
  pohead_shipto_cntct_fax=new.pohead_shipto_cntct_fax,
  pohead_shipto_cntct_email=new.pohead_shipto_cntct_email,
  pohead_shiptoaddress_id=new.pohead_shiptoaddress_id,
  pohead_shiptoaddress1=new.pohead_shiptoaddress1,
  pohead_shiptoaddress2=new.pohead_shiptoaddress2,
  pohead_shiptoaddress3=new.pohead_shiptoaddress3,
  pohead_shiptocity=new.pohead_shiptocity,
  pohead_shiptostate=new.pohead_shiptostate,
  pohead_shiptozipcode=new.pohead_shiptozipcode,
  pohead_shiptocountry=new.pohead_shiptocountry,
  pohead_cohead_id=new.pohead_cohead_id,
  pohead_released=new.pohead_released,
  obj_uuid=new.obj_uuid
where pohead_id = old.pohead_id;

create or replace rule "_DELETE" as on delete to xt.poheadinfo do instead

select deletepo(old.pohead_id);
