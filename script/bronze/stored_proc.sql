--this is a stored procedure to full load content from the crm and erp files to the sql tables

create or alter procedure bronze.load_bronze as
begin 
	declare @start_time datetime, @end_time datetime;
	begin try
		set @start_time = getdate(); 
		print('truncating and loading crm tables.........'); 

		truncate table bronze.crm_cust_info; 
		bulk insert bronze.crm_cust_info from 
		'C:\Users\DeLL\Downloads\sql-data-warehouse-project (1)\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with(
			firstrow = 2, 
			fieldterminator = ',', 
			tablock
		)

		truncate table bronze.crm_prd_info; 
		bulk insert bronze.crm_prd_info from 
		'C:\Users\DeLL\Downloads\sql-data-warehouse-project (1)\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with(
			firstrow = 2, 
			fieldterminator = ',', 
			tablock
		)

		truncate table bronze.crm_sales_details; 
		bulk insert bronze.crm_sales_details from 
		'C:\Users\DeLL\Downloads\sql-data-warehouse-project (1)\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with(
			firstrow = 2, 
			fieldterminator = ',', 
			tablock
		)

		print('truncating and loading erp tables.........'); 

		truncate table bronze.erp_cust_az12; 
		bulk insert bronze.erp_cust_az12 from 
		'C:\Users\DeLL\Downloads\sql-data-warehouse-project (1)\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		with(
			firstrow = 2, 
			fieldterminator = ',', 
			tablock
		)

		truncate table bronze.erp_loc_a101; 
		bulk insert bronze.erp_loc_a101 from 
		'C:\Users\DeLL\Downloads\sql-data-warehouse-project (1)\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		with(
			firstrow = 2, 
			fieldterminator = ',', 
			tablock
		)

		truncate table bronze.erp_px_cat_g1v2; 
		bulk insert bronze.erp_px_cat_g1v2 from 
		'C:\Users\DeLL\Downloads\sql-data-warehouse-project (1)\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		with(
			firstrow = 2, 
			fieldterminator = ',', 
			tablock
		)
		set @end_time = getdate(); 
		print('load duration: '+ cast(datediff(second, @start_time, @end_time) as nvarchar)) + 'secs'
	end try
	begin catch 
		print('an error occured while loading the bronze layer') 
		print('error messsage: ' + error_message())
		print('error number: ' + cast(error_number() as nvarchar))
		print('error state: ' + cast(error_state() as nvarchar))
	end catch 
end 
go

exec bronze.load_bronze; 
