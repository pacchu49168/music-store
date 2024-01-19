use music_database;

show tables;

select * from album;
select * from artist;
select * from customer;
select * from employee;
select * from genre;
select * from invoice;
select * from invoice_line;
select * from media_type;
select * from playlist;
select * from playlist_track;
select * from track;

/* Q1: Who is the senior most employee based on job title? */

select first_name,last_name,title 
from employee
order by levels desc
limit 1;

/* Q2: Which countries have the most Invoices? */

select count(*)as counts,billing_country 
from invoice
group by billing_country
order by counts desc;

/* Q3: What are top 3 values of total invoice? */

select distinct total
from invoice
order by total desc
limit 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select billing_city, sum(total)as invoice_total
from invoice
group by billing_city
order by invoice_total desc;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select customer.first_name ,customer.last_name, sum(invoice.total) as total_spending
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id,customer.first_name,customer.last_name
order by total_spending desc
limit 1;

/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select email,first_name as FirstName,last_name as lastname ,genre.name as Genre_name
from customer 
join invoice on invoice.customer_id = customer.customer_id 
join invoice_line on invoice_line.invoice_id =  invoice.invoice_id
join track on track.track_id= invoice_line.track_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
order by email;

/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select artist.artist_id ,artist.name, count(artist.artist_id) as number_of_songs
from track
join album on album.artist_id=track.album_id
join artist on artist.artist_id=album.artist_id
join genre on genre.genre_id= track.genre_id
group by artist.name,artist.artist_id
order by number_of_songs desc
limit 10;

/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name as longest_songs ,milliseconds
from track
where milliseconds>
(select avg(milliseconds)
from track)
order by milliseconds desc ;

/* Q9: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */


WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1