USE Box_Office

--Top 3 profitable writers with their movie
select top(3)concat(w.Writer_Fname , w.Writer_Lname ) as Writer_Name
,sum(f.Gross_Million - f.Budget_Million) as Total_Profit 
,v.Movie_name
from writer w join movie_writer m
on w.Writer_ID = m.Writer_ID
join movie v
on m.Movie_ID = v.Movie_id
join finance f
on f.Finance_ID = v.Finance_ID
group by w.Writer_ID, w.Writer_Fname ,w.Writer_Lname ,v.Movie_name
order by Total_Profit desc

--The most actors nationalities which participated in action movies
select top(1) count(n.Nationality_ID) as Nationality_count , n.Nationality_Name 
from nationality n join actor a 
on  n.Nationality_ID = a.Nat_ID
join movie_actor m
on a.Actor_ID = m.Actor_ID
join movie e
on m.Movie_ID = e.Movie_id
where e.Genre ='Action'
group by n.Nationality_ID , n.Nationality_Name 
ORDER BY Nationality_count DESC

---The most actors nationalities which participated in action movies
select top(1) count(n.Nationality_ID) as Nationality_count , n.Nationality_Name 
from nationality n join actor a 
on  n.Nationality_ID = a.Nat_ID
join movie_actor m
on a.Actor_ID = m.Actor_ID
join movie e
on m.Movie_ID = e.Movie_id
where e.Genre ='Action'
group by n.Nationality_ID , n.Nationality_Name 
ORDER BY Nationality_count DESC


--number of movies for each actor and the total avg revenue  

SELECT (a.Actor_Fname+a.Actor_Lname)  AS Full_Name,
COUNT(mo.Actor_ID) AS NumMoviesPerActor,
AVG(Gross_Million-Budget_Million) AS Avg_Reveneu
   FROM movie_actor mo 
   JOIN actor a ON mo.Actor_ID = a.Actor_ID 
   JOIN movie m ON m.Movie_id = mo.Movie_ID 
   JOIN finance f ON f.Finance_ID = m.Finance_ID 
       GROUP BY a.Actor_Fname+a.Actor_Lname 
	     ORDER BY NumMoviesPerActor DESC

--Count the movie for range of time

CREATE PROC mv_count (@year1 INT , @year2 INT)  AS 

SELECT  COUNT(Movie_id ) AS Num_Of_Movies, AVG(rating) AS Avg_Rating 
   FROM movie
     WHERE [Release year] BETWEEN @year1 AND @year2

EXEC mv_count 2010, 2019


--This stored procedure retrieves the top N actors or directors 
--based on the number of movies they've worked on.
CREATE OR ALTER PROC GetTopMovieCountPerRole
    @roleType NVARCHAR(50), -- 'Actor' or 'Director'
    @topCount INT
AS
BEGIN
    IF @roleType = 'Actor'
    BEGIN
        SELECT TOP (@topCount) a.Actor_ID, a.Actor_Fname, a.Actor_Lname, COUNT(ma.Movie_ID) AS Movie_Count
        FROM actor a
        LEFT JOIN movie_actor ma ON a.Actor_ID = ma.Actor_ID
        GROUP BY a.Actor_ID, a.Actor_Fname, a.Actor_Lname
        ORDER BY Movie_Count DESC;
    END
    ELSE IF @roleType = 'Director'
    BEGIN
        SELECT TOP (@topCount) d.Direct_ID, d.Direct_Fname, d.Direct_Lname, COUNT(md.Movie_ID) AS Movie_Count
        FROM director d
        LEFT JOIN movie_director md ON d.Direct_ID = md.Direct_ID
        GROUP BY d.Direct_ID, d.Direct_Fname, d.Direct_Lname
        ORDER BY Movie_Count DESC
    END
END

EXEC GetTopMovieCountPerRole @roleType = 'director', @topCount = 5