create database SQL_PROJECT;

USE SQL_PROJECT;

select * from users;
select * from delivery_partner;
select * from food;
select * from menu;
select * from order_details;
select * from orders;
select * from restaurants;

-- Q1. Find the customers who have never ordered:

select name from users where user_id not in (select user_id from orders);

	--  shaswat and kowshika never ordered food.

-- Q2. average food price per dish. 

-- select distinct(f_id) from menu; -- there are 11 distinct food items are available.  
-- select distinct(r_id) from restaurants; -- there are 5 restaurants available in the dataset.  

select f_name, avg(price) 'Avg Price' from menu m
	join food f 
		on m.f_id = f.f_id
group by m.f_id
order by avg(price) desc;
	-- costly food items are non-veg pizza and veg pizza
    -- cheapest food item is choco lava cake
    
-- Q3. find the top restaurants in terms of number of orders for a given month. 

select * from orders;
select * from restaurants;

-- creating a procedure to find out the top  restaurants: 
delimiter $$
create procedure top_orders_of_the_month(IN mnth varchar(15))
begin
select r.r_name, o.r_id, count(o.order_id) as 'orders per month' from orders o
	join restaurants r 
    on o.r_id = r.r_id
    where monthname(date) = mnth
	group by  o.r_id
    order by count(o.order_id) desc;
end $$ 
delimiter ;   

call top_orders_of_the_month('JULY');

	-- top restaurants in terms of number of orders for a given month MAY - Dosa Plaza -> 3 orders  
    -- top restaurants in terms of number of orders for a given month JUNE - KFC -> 3 orders  
    -- top restaurants in terms of number of orders for a given month JULY - KFC -> 3 orders  

-- Q4. -- restaurants with monthly sales greater than x for
select * from orders;
select * from restaurants;

-- *hard coding*
-- select r.r_name, sum(o.amount) as 'revenue' from orders o 
-- join restaurants r 
-- on o.r_id = r.r_id
-- where monthname(o.date) = 'JUNE'
-- group by r.r_id
-- having sum(o.amount) > 500;

delimiter $$
create procedure top_revenue(IN mnth varchar(15), IN amount int)
begin
select r.r_name, sum(o.amount) as 'revenue' from orders o 
	join restaurants r 
    on o.r_id = r.r_id
where monthname(o.date) = mnth
group by r.r_id
having sum(o.amount) > amount;
end $$ 
delimiter ; 

call top_revenue('JUNE', 500);
 -- restaurants with monthly sales of MAY greater than 500/- -> dominos(1000), KFC(645) & DOSA PLAZA(780)
  -- restaurants with monthly sales of JUNE greater than 500/- -> dominos(950) & KFC(950)
 -- restaurants with monthly sales of july greater than 500/- -> china town(1050), dominos(110) & KFC(1935)
 
 
 -- Q5. Show all orders with order details for a particular customer in a particular date range.

 
select o.order_id,r.r_name, od.f_id, f.f_name from orders o
join restaurants r
    using (r_id) 
join order_details od 
	using (order_id)
join food f
	using (f_id)
where user_id = (select user_id from users where name like 'harsha')
and ( date > '2022-06-10' and date < '2022-07-10') ;

delimiter $$
create procedure orderedFood(IN NameOfUser varchar(20), IN fromdate date, IN tilldate date)
begin
select o.order_id,r.r_name, od.f_id, f.f_name from orders o
join restaurants r
    using (r_id) 
join order_details od 
	using (order_id)
join food f
	using (f_id)
where user_id = (select user_id from users where name like NameOfUser)
and ( date > fromdate and date < tilldate) ;
end $$ 

call orderedFood('chaya', '2022-06-10', '2022-07-10');

## 6. Find restaurants with max repeated customers 

select r_id as rest_id,r_name as rest_name, count(*) as loyalCustomers from 
(select r_id , user_id, count(*) as visits from orders 
group by r_id , user_id
having visits > 1) t
join restaurants r
using (r_id)
group by r_id
order by loyalCustomers desc limit 1 ;


## 7. Month over month revenue growth of swiggy

select month, ((revenue - previous)/previous)*100 as total_rev from
(with sales as
 (select sum(amount) revenue, monthname(date) as 'month' from orders
group by month(date))													## in output -> there is growth of 32% from may to june and 50% growth in june to july.
select revenue, month, lag(revenue,1) over(order by revenue) as previous from sales) t;


## 8. Customer - favorite food

with
feq_of_order as (	select o.user_id, od.f_id, count(*) as 'frequency' from orders o
					join order_details od
					using (order_id)
					group by o.user_id, od.f_id
				)
select u.name, f.f_name from feq_of_order f1 
join users u
using (user_id)
join food f
using (f_id)
	where f1.frequency = (select max(frequency) from feq_of_order f2
							where f1.user_id = f2.user_id);
	




