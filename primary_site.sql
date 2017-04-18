-- primary dc

select
	prod_code,
	fulfillingdc
from
(
	select prod_code
		, fulfillingdc
		, count(*)
		, row_number()over(partition by prod_code order by count(*) desc)myrank
	from test_orders
	group by prod_code
		, fulfillingdc
)
where myrank = 1;