--this script produces the gold layer views for the data warehouse, we make use of a star schema data model and 
--have 2 dimension and 1 fact table

create view gold.dim_customers as
select 
row_number() over(order by ci.cst_id) as customer_key,
ci.cst_id as customer_id,
ci.cst_key as customer_number, 
ci.cst_firstname as first_name, 
ci.cst_lastname as last_name, 
ci.cst_marital_status as marital_status, 
case when ci.cst_gndr != 'n/a' then ci.cst_gndr
	 else coalesce(ca.gen, 'n/a')
end as gender,
ci.cst_create_date as create_date, 
ca.bdate as birthdate, 
la.cntry as country
from silver.crm_cust_info as ci left join silver.erp_cust_az12 as ca
on ci.cst_key = ca.cid left join silver.erp_loc_a101 as la on ci.cst_key = la.cid


create view gold.dim_products as
select 
row_number() over(order by pn.prd_start_dt, pn.prd_key) as indexx, 
pn.prd_id as product_id, 
pn.cat_id as category_id, 
pn.prd_key as product_number, 
pn.prd_nm as product_name, 
pn.prd_cost as cost, 
pn.prd_line as product_line, 
pn.prd_start_dt as start_date, 
pc.cat as category, 
pc.subcat as subcategory, 
pc.maintenance from silver.crm_prd_info as pn left join silver.erp_px_cat_g1v2 
as pc on pn.cat_id = pc.id where pn.prd_end_dt is null; 


create view gold.fact_sales as
select 
sd.sls_ord_num as order_number, 
pr.indexx, 
cu.customer_key, 
sd.sls_order_dt as order_date, 
sd.sls_ship_dt as ship_date, 
sd.sls_due_dt as due_date, 
sd.sls_sales as sales_amount, 
sd.sls_quantity as quantity,
sd.sls_price as price
from silver.crm_sales_details as sd left join gold.dim_products as pr on sd.sls_prd_key = pr.product_number
left join gold.dim_customers as cu on sd.sls_cust_id = cu.customer_id; 
