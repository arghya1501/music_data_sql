# Music Database SQL Project

## Overview

This project explores SQL queries for a music database. The dataset includes tables such as `employee`, `invoice`, `customer`, `track2`, `artist`, `album2`, and `genre`. Below are the questions categorized into Easy, Moderate, and Advanced levels, along with the SQL queries to solve them.

## Database Setup

```sql
CREATE DATABASE music;
USE music;
```

---

## Question Set 1 - Easy

### 1. Who is the senior-most employee based on job title?
```sql
SELECT first_name, last_name, title, MAX(levels) AS title_levels
FROM employee
GROUP BY first_name, last_name, title
ORDER BY title_levels DESC
LIMIT 1;
```

### 2. Which countries have the most invoices?
```sql
SELECT billing_country, COUNT(invoice_id) AS most_invoices
FROM invoice
GROUP BY billing_country
ORDER BY most_invoices DESC
LIMIT 1;
```

### 3. What are the top 3 values of total invoice amounts?
```sql
SELECT total AS total_invoice
FROM invoice
ORDER BY total_invoice DESC
LIMIT 3;
```

### 4. Which city has the best customers?
Return the city with the highest sum of invoice totals.
```sql
SELECT billing_city, SUM(total) AS sum_of_invoice
FROM invoice
GROUP BY billing_city
ORDER BY sum_of_invoice DESC
LIMIT 1;
```

### 5. Who is the best customer?
The customer who has spent the most money.
```sql
SELECT customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) AS spent_money
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name
ORDER BY spent_money DESC
LIMIT 1;
```

---

## Question Set 2 - Moderate

### 1. List all Rock Music listeners
Return the email, first name, last name, and Genre, ordered alphabetically by email.
```sql
SELECT c.first_name, c.last_name, c.email, g.name
FROM customer AS c
JOIN invoice AS i ON c.customer_id = i.customer_id
JOIN invoice_line AS il ON i.invoice_id = il.invoice_id
JOIN track2 AS t ON il.tracks_id = t.tracks_id
JOIN genre AS g ON t.genre_id = g.genre_id
WHERE g.name = "Rock"
ORDER BY c.email ASC;
```

### 2. Top 10 Rock bands by track count
```sql
SELECT a.name, g.name, COUNT(t.tracks_id) AS total_track
FROM artist AS a
JOIN album2 AS al ON a.artist_id = al.artist_id
JOIN track2 AS t ON al.album_id = t.album_id
JOIN genre AS g ON t.genre_id = g.genre_id
WHERE g.name = "Rock"
GROUP BY a.name, g.name
ORDER BY total_track DESC
LIMIT 10;
```

### 3. Tracks longer than the average song length
Return the track names and their durations in milliseconds.
```sql
SELECT name, milliseconds
FROM track2
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track2)
ORDER BY milliseconds DESC;
```

---

## Question Set 3 - Advanced

### 1. Amount spent by each customer on top artists
```sql
WITH best_artist AS (
  SELECT a.artist_id, a.name, SUM(il.unit_price * il.quantity) AS total_amount
  FROM artist AS a
  JOIN album2 AS al ON a.artist_id = al.artist_id
  JOIN track2 AS t ON al.album_id = t.album_id
  JOIN invoice_line AS il ON t.tracks_id = il.tracks_id
  GROUP BY a.artist_id
  ORDER BY total_amount DESC
  LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, ba.name AS artist_name, SUM(il.unit_price * il.quantity) AS total_spent
FROM best_artist AS ba
JOIN album2 AS al ON ba.artist_id = al.artist_id
JOIN track2 AS t ON al.album_id = t.album_id
JOIN invoice_line AS il ON t.tracks_id = il.tracks_id
JOIN invoice AS i ON il.invoice_id = i.invoice_id
JOIN customer AS c ON i.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, artist_name
ORDER BY total_spent DESC;
```

### 2. Most popular music genre for each country
```sql
WITH Top_purchases AS (
  SELECT g.name, i.billing_country, COUNT(quantity) AS total_purchases,
         ROW_NUMBER() OVER (PARTITION BY i.billing_country ORDER BY COUNT(quantity) DESC) AS row_no
  FROM genre AS g
  JOIN track2 AS t ON g.genre_id = t.genre_id
  JOIN invoice_line AS il ON t.tracks_id = il.tracks_id
  JOIN invoice AS i ON il.invoice_id = i.invoice_id
  GROUP BY g.name, i.billing_country
)
SELECT *
FROM Top_purchases
WHERE row_no = 1;
```

### 3. Top customer by spending in each country
```sql
WITH top_customer AS (
  SELECT c.customer_id, c.first_name, c.last_name, i.billing_country, SUM(il.unit_price * il.quantity) AS total_spent,
         ROW_NUMBER() OVER (PARTITION BY i.billing_country ORDER BY SUM(il.unit_price * il.quantity) DESC) AS row_no
  FROM customer AS c
  JOIN invoice AS i ON c.customer_id = i.customer_id
  JOIN invoice_line AS il ON i.invoice_id = il.invoice_id
  GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country
)
SELECT *
FROM top_customer
WHERE row_no = 1;
