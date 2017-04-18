-- dominant site

select
	*
from
(
	select
		main.prod_code,
		main.fulfillingdc,
		freq,
		row_number()over(partition by prod_code order by freq desc)myrank
	from
	(
		select
			p.prod_code,
			t1.fulfillingdc,
			count(*)freq
		from test_orders t1 cross join (select distinct prod_code from test_orders) p 
		where t1.orderid in
			(
				select
					distinct t2.orderid
				from test_orders t2
				where t2.prod_code = p.prod_code
			)
		and t1.prod_code != p.prod_code
		group by
			p.prod_code,
			t1.fulfillingdc
	)main
	where exists
	(
		select 1
		from
		(
			-- primary fulfillingdc
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
			where myrank = 1
		)base
		where base.prod_code = main.prod_code
		and base.fulfillingdc != main.fulfillingdc
	)
)
where myrank = 1;
