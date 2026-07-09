--the given proc full loads the tables after applying transformations on the bronze table into the silver layer, the loading is done by truncating and inserting 

create or alter procedure silver.load_silver as
begin
	declare @start_time datetime, @end_time datetime; 
	begin try 
		set @start_time = getdate()
		print('truncating and loading silver tables')	
		truncate table silver.crm_cust_info
		insert into silver.crm_cust_info(cst_id, cst_key, cst_firstname, cst_lastname,
		cst_marital_status, cst_gndr, cst_create_date)
			select cst_id, cst_key, trim(cst_firstname), 
				   trim(cst_lastname), 
				   case when cst_marital_status = 'S' then 'single'
						when cst_marital_status = 'M' then 'married'
						else 'n/a'
					end cst_marital_status, 
				   case when cst_gndr = 'M' then 'male'
						when cst_gndr = 'F' then 'female'
						else 'n/a'
					end cst_gndr, cst_create_date 
			from(
				select *, row_number() over(partition by cst_id order by cst_create_date desc) 
				as flag from bronze.crm_cust_info
			)t where flag = 1 and cst_id is not null


		truncate table silver.crm_prd_info;
		insert into silver.crm_prd_info(prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, 
		prd_start_dt, prd_end_dt)
		select prd_id, replace(substring(prd_key, 1, 5), '-', '_') as cat_id, 
		substring(prd_key, 7, len(prd_key)) as prd_key, prd_nm, isnull(prd_cost, 0) as prd_cost, 
		case when prd_line = 'M' then 'mountain'
			 when prd_line = 'R' then 'road'
			 when prd_line = 'S' then 'other sales'
			 when prd_line = 'T' then 'touring'
			 else 'na'
			 end prd_line, 
		cast(prd_start_dt as date) as prd_start_dt, 
		cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt
		from bronze.crm_prd_info; 


		truncate table silver.crm_sales_details
		insert into silver.crm_sales_details(sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, 
		sls_sales, sls_quantity, sls_price)
		select sls_ord_num, sls_prd_key, sls_cust_id, 
		case when sls_order_dt = 0 or len(sls_order_dt) != 8 then null
		else cast(cast(sls_order_dt as varchar) as date)
		end as sls_order_dt, 
		cast(cast(sls_ship_dt as varchar) as date) as sls_ship_dt,
		cast(cast(sls_due_dt as varchar) as date) as sls_due_dt, 
		case when sls_sales <= 0 or sls_sales is null or sls_sales != sls_quantity*abs(sls_price) then sls_quantity*abs(sls_price)
			 else sls_sales 
		end as sls_sales, 
		sls_quantity, 
		case when sls_price = 0 or sls_price is null then abs(sls_sales)/sls_quantity
			 when sls_price < 0 then abs(sls_price)
			 else sls_price 
		end as sls_price from bronze.crm_sales_details


		truncate table silver.erp_cust_az12; 
		insert into silver.erp_cust_az12(cid, bdate, gen) 
		select case when cid like 'NAS%' then substring(cid, 4, len(cid))
					else cid
			   end as cid, 
		case when bdate > getdate() then null
			 else bdate
		end as bdate, 
		case when trim(gen) = 'M' then 'Male'
			 when trim(gen) = 'F' then 'Female'
			 when trim(gen) = '' then 'n/a'
			 when gen is null then 'n/a'
			 else gen
		end as gen from bronze.erp_cust_az12; 

		truncate table silver.erp_loc_a101;
		insert into silver.erp_loc_a101(cid, cntry)
		select replace(cid, '-', '') as cid, 
		case when trim(cntry) in ('USA', 'US') then 'United States'
			 when trim(cntry) = 'DE' then 'Germany'
			 when trim(cntry) = '' or cntry is null then 'n/a'
			 else trim(cntry)
		end as cntry from bronze.erp_loc_a101

		truncate table silver.erp_px_cat_g1v2; 
		insert into silver.erp_px_cat_g1v2(id, cat, subcat, maintenance) 
		select id, cat, subcat, maintenance from bronze.erp_px_cat_g1v2;
		set @end_time = getdate()
		print 'the time elpased to load silver layer: '+ cast(datediff(second, @start_time, @end_time) as nvarchar) + ' secs'
	end try 
	begin catch 
		print('an error occured while loading the silver layer') 
		print('error messsage: ' + error_message())
		print('error number: ' + cast(error_number() as nvarchar))
		print('error state: ' + cast(error_state() as nvarchar))
	end catch 
end 
go 
exec silver.load_silver;
