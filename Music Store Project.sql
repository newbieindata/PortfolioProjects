/* ANALYSIS OF MUSIC STORE DATA USING :
Aggregated functions, JOINs, CTEs in order to extract the data of customers, countries, sales, invoices, employees and genres of music*/


Select * From dbo.album;

--Q1: Who is the senior most employee based on job title?

Select  top 1 * from employee
Order by levels desc; 


-- Q2: Which Countries have the most Invoices?

Select top 1 Count(*) as C, billing_country
From invoice
Group By billing_country
Order by c DESC;


--Q3: What are top 3 values of total invoice

Select top 3 total
From invoice
Order by total DESC


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the City we made the most money.
Write a query that returns one city that has the highest sum of invoice totals. Return both city & sum of all invoices totals.*/

Select top 1 Sum(total) As Invoice_total, billing_city
From Invoice
Group BY billing_city
order by invoice_total desc

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
 Write a query that returns the person who has spent the most money.*/

 Select top 1 SUM(i.total) as total , c.customer_id, c.first_name, c.last_name from Invoice I
 Join customer c
  on i.customer_id = c.customer_id
Group BY c.customer_id, c.first_name, c.last_name
Order by total DESC

/* Q6: Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A.*/

--Version 1
Select DISTINCT c.email, c.first_name, c.last_name
from Customer c
Join Invoice I 
    on I.customer_id = c.customer_id
Join invoice_line Il
    on Il.invoice_id = i.invoice_id
Join track t
    on t.track_id = il.track_id
Join Genre g
    on g.genre_id = t.genre_id
Where g.name like 'Rock'
Order by c.email 

--Version 2 (better automated)

Select DISTINCT c.email, c.first_name, c.last_name
from Customer c
Join Invoice I 
    on I.customer_id = c.customer_id
Join invoice_line Il
    on Il.invoice_id = i.invoice_id
Where track_id IN (
					Select t.track_id 
					From track t
					Join Genre g
						on g.genre_id = t.genre_id
					Where g.name = 'Rock')
Order by c.email

/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */


Select top 10 artist.artist_id, artist.name, Count(t.track_id) as number_of_songs
From artist 
JOIN album ON artist.artist_id = album.artist_id
JOIN track t ON t.album_id = album.album_id
JOIN genre g ON g.genre_id = t.genre_id
 Where g.name = 'Rock'
Group By artist.artist_id, artist.name
ORDER BY number_of_songs DESC


/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */


Select track.name, track.milliseconds
From Track
Where track.milliseconds > (Select Avg ( milliseconds) 
From Track)
Order by track.milliseconds DESC


/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */


With Best_Selling_Artist AS 
(Select Top 1 artist.name, artist.artist_id, Sum(invoice_line.unit_price*invoice_line.quantity) As TotalSpent 
FROM invoice_line
Join track ON Invoice_line.track_id = track.track_id
Join album ON track.album_id = album.album_id
Join artist ON album.artist_id = artist.artist_id
Group By artist.name, artist.artist_id
Order by 3 DESC)

Select c.customer_id, c.first_name, c.last_name, bsa.name, Sum(il.unit_price*il.quantity) As totalSpent
From Invoice i
Join invoice_line il ON  i.invoice_id = il.invoice_id
Join customer c ON c.customer_id = i.customer_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.name
ORDER BY 5 DESC

/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

With popular_genre AS(
SELECT Count(il.quantity) AS Purchase, c.country, g.name, g.genre_id, 
ROW_NUMBER() OVER (PARTITION BY c.country ORDER BY (COUNT(il.quantity)) DESC) AS Row_num
FROM Invoice_line il
JOIN Invoice i ON i.invoice_id = il.invoice_id
JOIN customer c ON c.customer_id = i.customer_id
JOIN track t ON t.track_id = il.track_id
JOIN genre g ON g.genre_id= t.genre_id
Group BY c.country, g.name, g.genre_id

)

SELECT * FROM popular_genre WHERE Row_num = 1



/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */


WITH Customer_of_Country AS 
(SELECT c.country, c.first_name, c.last_name, i.billing_country, SUM(i.total) AS TotalAmt, 
ROW_NUMBER() OVER (PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) AS Row_num
FROM customer c
JOIN Invoice i ON i.customer_id = c.customer_id
Group BY c.country, c.first_name, c.last_name, i.billing_country
--ORDER BY i.billing_country, TotalAmt DESC
)

SELECT * FROM Customer_of_Country WHERE ROW_num <= 1


