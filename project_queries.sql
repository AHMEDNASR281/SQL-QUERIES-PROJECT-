USE Box_Office

-- 1 Top 3 profitable writers with their movie
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

-- 2 The most actors nationalities which participated in action movies
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


-- 3 number of movies for each actor and the total avg revenue  

SELECT (a.Actor_Fname+a.Actor_Lname)  AS Full_Name,
COUNT(mo.Actor_ID) AS NumMoviesPerActor,
AVG(Gross_Million-Budget_Million) AS Avg_Reveneu
   FROM movie_actor mo 
   JOIN actor a ON mo.Actor_ID = a.Actor_ID 
   JOIN movie m ON m.Movie_id = mo.Movie_ID 
   JOIN finance f ON f.Finance_ID = m.Finance_ID 
       GROUP BY a.Actor_Fname+a.Actor_Lname 
	     ORDER BY NumMoviesPerActor DESC

-- 4 Count the movie for range of time

CREATE PROC mv_count (@year1 INT , @year2 INT)  AS 

SELECT  COUNT(Movie_id ) AS Num_Of_Movies, AVG(rating) AS Avg_Rating 
   FROM movie
     WHERE [Release year] BETWEEN @year1 AND @year2

EXEC mv_count 2010, 2019


-- 5 This stored procedure retrieves the top N actors or directors 
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


--- 6 This procedure recommends movies based on a specified genre and rating range
CREATE OR ALTER PROC GetMovieRecommendations
    @movieGenre NVARCHAR(50),
    @minRating INT,
    @maxRating INT
AS
BEGIN
    SELECT Movie_id, Movie_name, Summary, [Release year], [Run_time(minute)], Rating
    FROM movie
    WHERE Genre = @movieGenre AND Rating BETWEEN @minRating AND @maxRating
END

EXEC GetMovieRecommendations @movieGenre= 'Comedy', @minRating = 7, @maxRating = 9


-- 7 the actor who made the most number of films and the genre which is related to it 

	CREATE OR Alter VIEW ActorFilmCountView AS
SELECT TOP 100 PERCENT 
    a.Actor_ID,
    a.Actor_Fname,
    a.Actor_Lname,
    COUNT(ma.Movie_ID) AS NumberOfFilms
FROM 
    Actor a
JOIN 
    Movie_actor ma ON a.Actor_ID = ma.Actor_ID
GROUP BY 
    a.Actor_ID, a.Actor_Fname, a.Actor_Lname
ORDER BY NumberOfFilms DESC;

	CREATE or Alter VIEW TopActorGenresView AS
SELECT 
    afc.Actor_ID,
    m.Genre AS GenreName,
    COUNT(*) AS GenreCount
FROM 
    ActorFilmCountView afc
JOIN 
    Movie_actor ma ON afc.Actor_ID = ma.Actor_ID
JOIN 
    Movie m ON ma.Movie_ID = m.Movie_id

GROUP BY 
    afc.Actor_ID, m.Genre;


	SELECT 
    CONCAT(Actor_Fname, Actor_Lname) AS ActorName,
    GenreName AS Genre,
	subquery.NumberOfFilms
	
FROM (
    SELECT TOP 100 Percent
        afc.Actor_ID,
        afc.Actor_Fname,
        afc.Actor_Lname,
        t.GenreName,
        ROW_NUMBER() OVER (PARTITION BY afc.Actor_ID ORDER BY afc.NumberOfFilms ) AS rn ,
		NumberOfFilms
    FROM 
        ActorFilmCountView afc
    JOIN 
        TopActorGenresView t ON afc.Actor_ID = t.Actor_ID
	order by NumberOfFilms Desc
) AS subquery
WHERE rn = 1
Order by NumberOfFilms DESC




-- 8 the actor that get the greatest profit
SELECT 
    Concat(Actor_Fname , Actor_Lname ) AS ActorName, 
    SUM(Gross_Million - Budget_Million) AS TotalProfit
FROM 
    Actor
JOIN 
    Movie_actor ON Actor.Actor_ID = Movie_actor.Actor_ID
JOIN 
    Movie ON Movie_actor.Movie_ID = Movie.movie_id
JOIN 
    Finance ON Movie.Finance_ID = Finance.Finance_ID
GROUP BY 
    Actor.Actor_ID, Actor_Fname, Actor_Lname
ORDER BY 
    TotalProfit DESC




-- 9 duo actor and director who get the greates profit 
create or alter  proc top_DIRECT_ACTOR (@num int)

as
select top 10  Actor_Fname + ' ' + Actor_Lname as [Actor Name] 
,direct_fname + ' ' + direct_lname as [Director Name]
, sum (f.Gross_Million - f.Budget_Million) as [profit]

from  
actor a join movie_actor ma on a.Actor_ID = ma.Actor_ID 
join
movie m on ma.Movie_ID = m.Movie_id 
join 
movie_director md  on m.Movie_id = md.Movie_ID 
join 
director d on md.Direct_ID = d.Direct_ID 
join 
finance f on m.Finance_ID = f.Finance_ID 

group by Actor_Fname + ' ' + Actor_Lname, direct_fname + ' ' + direct_lname 
order by profit desc


exec top_DIRECT_ACTOR 5


-- 10 top 3 making profit Genres.


select  top 3  genre, sum (f.Gross_Million - f.Budget_Million) as [Profit of Genre] from movie m join finance f 
on m.Finance_ID = f.Finance_ID 
group by Genre 
order by sum (f.Gross_Million - f.Budget_Million) desc


 -- 11 Calculate the avg run_time per each genre
SELECT Genre,AVG([Run_time(minute)]) AS Avg_Runtime,AVG(Rating) AS Avg_Genre_Rating,
CASE
   WHEN AVG(Rating) > 7 THEN 'HIGH'
   ELSE 'LOW'
   END AS Rating_Classification
      FROM movie 
        GROUP BY Genre
	       ORDER BY Avg_Runtime DESC

 -- 12 number of movies for each actor and the total avg revenue  

SELECT (a.Actor_Fname+a.Actor_Lname)  AS Full_Name,
COUNT(mo.Actor_ID) AS NumMoviesPerActor,
AVG(Gross_Million-Budget_Million) AS Avg_Reveneu
   FROM movie_actor mo 
   JOIN actor a ON mo.Actor_ID = a.Actor_ID 
   JOIN movie m ON m.Movie_id = mo.Movie_ID 
   JOIN finance f ON f.Finance_ID = m.Finance_ID 
       GROUP BY a.Actor_Fname+a.Actor_Lname 
	     ORDER BY NumMoviesPerActor DESC


-- 13 Count the movie for range of time

CREATE PROC mv_count (@year1 INT , @year2 INT)  AS 

SELECT  COUNT(Movie_id ) AS Num_Of_Movies, AVG(rating) AS Avg_Rating 
   FROM movie
     WHERE [Release year] BETWEEN @year1 AND @year2

EXEC mv_count 2010, 2019


-- 14 This stored procedure retrieves the number of movies for a specific genre and year.

create or alter procedure Movies_By_Genre_and_year (@genre_param VARCHAR(255), @year_param INT )
as
 begin
SELECT COUNT(Movie_id) AS Num_of_Movies_Per_Year
    FROM movie 
    WHERE Genre = @genre_param AND [Release year] = @year_param;

end


exec Movies_By_Genre_and_year 'Drama' , 2009


-- 15 This stored procedure finds the movie with the highest budget and profit within a specific genre.

CREATE or alter PROCEDURE Highest_profit_Movie_for_Genre (@genre_param VARCHAR(255))
as 

BEGIN

    SELECT  top 1 movie_name,genre, max(gross_million - budget_million) as Profit 
    FROM movie m join finance f on m.Finance_ID = f.Finance_ID
    WHERE genre = @genre_param
	group by Genre , Movie_name
    ORDER BY Profit desc
    
END;


exec Highest_profit_Movie_for_Genre 'Action'



-- 16 procedure show the names of actor and director worked together 
-- and the sum of profit of movies the made together 
-- for number of movies you want 


create or alter  proc top_DIRECT_ACTOR (@num int)

as
select top 10  Actor_Fname + ' ' + Actor_Lname as [Actor Name] 
,direct_fname + ' ' + direct_lname as [Director Name]
, sum (f.Gross_Million - f.Budget_Million) as [profit]

from  
actor a join movie_actor ma on a.Actor_ID = ma.Actor_ID 
join
movie m on ma.Movie_ID = m.Movie_id 
join 
movie_director md  on m.Movie_id = md.Movie_ID 
join 
director d on md.Direct_ID = d.Direct_ID 
join 
finance f on m.Finance_ID = f.Finance_ID 

group by Actor_Fname + ' ' + Actor_Lname, direct_fname + ' ' + direct_lname 
order by profit desc


exec top_DIRECT_ACTOR 5


-- 17  top 3 making profit Genres.


select  top 3  genre, sum (f.Gross_Million - f.Budget_Million) as [Profit of Genre] from movie m join finance f 
on m.Finance_ID = f.Finance_ID 
group by Genre 
order by sum (f.Gross_Million - f.Budget_Million) desc 


-- 18 Calculate the avg run_time per each genre  

SELECT Genre,AVG([Run_time(minute)]) AS Avg_Runtime,AVG(Rating) AS Avg_Genre_Rating,
CASE
   WHEN AVG(Rating) > 7 THEN 'HIGH'
   ELSE 'LOW'
   END AS Rating_Classification
      FROM movie 
        GROUP BY Genre
	       ORDER BY Avg_Runtime DESC


-- 19 This trigger prevents the deletion of records from the director entity table
--if there are associated movies in the movie_director table. 

CREATE OR ALTER TRIGGER PreventDirectorDeletion
ON director
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM deleted d
        JOIN movie_director md ON d.Direct_ID = md.Direct_ID
    )
    BEGIN
        PRINT ('Deletion failed. Directors associated with movies cannot be deleted')
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
        DELETE FROM director
        WHERE Direct_ID IN (SELECT Direct_ID FROM deleted)
    END
END


-- 20 This trigger prevents the insertion of new records in the actor table
--if the first and last name of the actor already exists

CREATE OR ALTER TRIGGER PreventDuplicateActor
ON actor
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN actor a ON i.Actor_Fname = a.Actor_Fname AND i.Actor_Lname = a.Actor_Lname
    )
    BEGIN
        PRINT ('Insertion failed. Actor with the same first name and last name already exists')
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
        INSERT INTO actor (Actor_Fname, Actor_Lname, Actor_BD, Nat_ID)
        SELECT Actor_Fname, Actor_Lname, Actor_BD, Nat_ID
        FROM inserted
    END
END



-- 21 create view top_profitable_Director as
select top(3) concat(d.Direct_Fname , d.Direct_Lname ) as Director_Name
,sum (f.Gross_Million - f.Budget_Million) as Total_Profit 
,v.Movie_name
from director d join movie_director m
on d.Direct_ID = m.Direct_ID
join movie v
on m.Movie_ID = v.Movie_id
join finance f
on f.Finance_ID = v.Finance_ID
group by d.Direct_ID, d.Direct_Fname ,d.Direct_Lname ,v.Movie_name
order by Total_Profit desc


select * from top_profitable_Director


--- 22 The most actors nationalities who participated in a specific genre movies
create or alter proc most_actor_nationality 
@gen varchar(50)  
as
begin
	if exists ( select m.Genre from movie m where m.Genre = @gen )
	   begin
	  
select top(1) count(n.Nationality_ID) as Nationality_count , n.Nationality_Name 
from nationality n join actor a 
on  n.Nationality_ID = a.Nat_ID
join movie_actor m
on a.Actor_ID = m.Actor_ID
join movie e
on m.Movie_ID = e.Movie_id
where e.Genre =@gen
group by n.Nationality_ID , n.Nationality_Name 
ORDER BY Nationality_count DESC
	end
else 
begin
	print 'the genre is not exist' 
	end
end
exec most_actor_nationality @gen = 'Adventure'


-- 23 writers who have high rated movies (rating > 8) and the number of those movies

SELECT we.Writer_ID, we.Writer_Fname, we.Writer_Lname, COUNT(mw.Movie_ID) AS High_Rated_Movies
FROM writer we
INNER JOIN movie_writer mw ON we.Writer_ID = mw.Writer_ID
INNER JOIN movie me ON mw.Movie_ID = me.Movie_id
WHERE me.Rating > 8
GROUP BY we.Writer_ID, we.Writer_Fname, we.Writer_Lname