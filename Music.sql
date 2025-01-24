create database music;
use music;

-- Question Set 1 - Easy
-- 1. Who is the senior most employee based on job title?
select first_name, last_name,title,max(levels) as title_levels  from employee
group by first_name, last_name,title
order by title_levels desc limit 1;

-- 2. Which countries have the most Invoices?
select billing_country,count(invoice_id) as most_Invoices  from invoice
group by billing_country
order by most_Invoices desc limit 1;
-- 3. What are top 3 values of total invoice?
select total as total_invoice from invoice
order by total_invoice desc limit 3;
-- 4. Which city has the best customers? We would like to throw a promotional Music 
-- Festival in the city we made the most money. Write a query that returns one city that 
-- has the highest sum of invoice totals. Return both the city name & sum of all invoice 
-- totals

select billing_city, sum(total) as sum_of_invoice  from invoice
group by billing_city
order by sum_of_invoice desc limit 1;
-- 5. Who is the best customer? The customer who has spent the most money will be 
-- declared the best customer. Write a query that returns the person who has spent the 
-- most money
select  customer.customer_id ,customer.first_name, customer.last_name,sum(invoice.total) as spent_money
from customer join invoice
on customer.customer_id = invoice.customer_id
group by customer.customer_id ,customer.first_name, customer.last_name
order by  spent_money desc limit 1;

-- Question Set 2 – Moderate
-- 1. Write query to return the email, first name, last name, & Genre of all Rock Music 
-- listeners. Return your list ordered alphabetically by email starting with A
select c.first_name,c.last_name,c.email,g.name 
from customer as c join invoice as i
on c.customer_id = i.customer_id
join invoice_line as il
on i.invoice_id = il.invoice_id
join track2 as t
on il.tracks_id = t.tracks_id
join genre as g
on t.genre_id = g.genre_id
where g.name = "Rock"
order by c.email asc;

-- 2. Let's invite the artists who have written the most rock music in our dataset. Write a 
-- query that returns the Artist name and total track count of the top 10 rock bands
select a.name, g.name,count(t.tracks_id) as  total_track
from artist as a
join album2 as al on a.artist_id = al.artist_id
join track2 as t on al.album_id = t.album_id
join genre as g on t.genre_id = g.genre_id
where g.name = "Rock"
group by a.name, g.name
order by total_track desc limit 10;
-- 3. Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the 
-- longest songs listed first
select name,milliseconds from track2 where milliseconds > (select avg(milliseconds) from track2) 
order by milliseconds desc;
-- Question Set 3 – Advance
-- 1. Find how much amount spent by each customer on Top artists? Write a query to return
-- customer name, artist name and total spent
with best_artist as
(select a.artist_id,a.name,sum(il.unit_price* il.quantity) as total_amount
from artist as a
join album2 as al on a.artist_id = al.artist_id
join track2 as t on al.album_id = t.album_id
join invoice_line as il on t.tracks_id = il.tracks_id
group by a.artist_id
order by total_amount desc limit 1)
select c.customer_id,c.first_name,c.last_name,ba.name as artist_name, sum(il.unit_price* il.quantity) as total_spent
from best_artist as ba
join album2 as al on ba.artist_id = al.artist_id
join track2 as t on al.album_id = t.album_id
join invoice_line as il on t.tracks_id = il.tracks_id
join invoice as i on il.invoice_id = i.invoice_id
join customer as c on i.customer_id  = c.customer_id
group by c.customer_id,c.first_name,c.last_name, artist_name
order by total_spent desc;

-- 2. We want to find out the most popular music Genre for each country. We determine the 
-- most popular genre as the genre with the highest amount of purchases. Write a query 
-- that returns each country along with the top Genre. For countries where the maximum 
-- number of purchases is shared return all Genres
with Top_purchases as 
(select g.name,i.billing_country,count(quantity) as total_purchases,
row_number() OVER (PARTITION BY i.billing_country order by count(quantity) desc) as row_no
from genre as g 
join track2 as t on g.genre_id = t.genre_id
join invoice_line as il on t.tracks_id  = il.tracks_id
join invoice as i on il.invoice_id = i.invoice_id
group by g.name,i.billing_country)

select * from Top_purchases where row_no =1;


-- 3. Write a query that determines the customer that has spent the most on music for each 
-- country. Write a query that returns the country along with the top customer and how
-- much they spent. For countries where the top amount spent is shared, provide all 
-- customers who spent this amount

with top_customer as(
select c.customer_id,c.first_name,c.last_name,i.billing_country,sum(il.unit_price* il.quantity) as total_spent,
row_number() over(partition by i.billing_country order by sum(il.unit_price* il.quantity)desc) as row_no
from customer as c 
join invoice as i on c.customer_id = i.customer_id
join invoice_line as il on i.invoice_id = il.invoice_id
group by c.customer_id,c.first_name,c.last_name,i.billing_country)
select * from top_customer where row_no = 1 ;


