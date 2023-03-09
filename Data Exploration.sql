--Merging all months into one table

CREATE TABLE CyclisticTripMerged
(
ride_id nvarchar(255),
rideable_type nvarchar(255),
started_at datetime,
ended_at datetime,
start_station_name nvarchar(255),
start_station_id nvarchar (255),
end_station_name nvarchar(255),
end_station_id nvarchar (255),
start_lat float,
start_lng float,
end_lat float,
end_lng float,
member_casual nvarchar(255)
)

INSERT INTO CyclisticTripMerged

SELECT*  FROM CyclisticPortfolio..SeptTrip
UNION ALL
SELECT*  FROM CyclisticPortfolio..OctTrip
UNION ALL
SELECT*  FROM CyclisticPortfolio..NovTrip
UNION ALL
SELECT*  FROM CyclisticPortfolio..AprilTrip
UNION ALL
SELECT*  FROM CyclisticPortfolio..AugustTrip
UNION ALL
SELECT*  FROM CyclisticPortfolio..DecTrip
UNION ALL
SELECT*  FROM CyclisticPortfolio..FebTrip
UNION ALL
SELECT*  FROM CyclisticPortfolio..JanTrip23
UNION ALL
SELECT*  FROM CyclisticPortfolio..JulyTrip
UNION ALL
SELECT*  FROM CyclisticPortfolio..JuneTrip
UNION ALL
SELECT*  FROM CyclisticPortfolio..MarchTrip
UNION ALL
SELECT*  FROM CyclisticPortfolio..MayTrip
----------------------------------------------------------------------------------------------------------------------------------
SELECT*
FROM CyclisticPortfolio..CyclisticTripMerged

----Adding length of travel column

SELECT 
	member_casual,
	CAST((ended_at - started_at) AS time) AS travel_time
FROM
	CyclisticPortfolio..CyclisticTripMerged
GROUP BY
	member_casual
ORDER BY 2;

--Updating Table

 ALTER TABLE CyclisticPortfolio..CyclisticTripMerged
	ADD
	travel_time time,
	day_used int;

UPDATE CyclisticPortfolio..CyclisticTripMerged
	SET 
	   travel_time = CAST((ended_at - started_at) AS time);

UPDATE CyclisticPortfolio..CyclisticTripMerged
	SET 
	   day_used =  DATEPART(WEEKDAY,started_at);

-- Adding month_year column
SELECT CONCAT(DATENAME(month,started_at),' ',DATEPART(yyyy,started_at)) AS month_year
FROM 
	CyclisticPortfolio..CyclisticTripMerged

ALTER TABLE CyclisticTripMerged
Add month_year date;

UPDATE CyclisticTripMerged
SET month_year = CONCAT(DATENAME(month,started_at),' ',DATEPART(yyyy,started_at))



--------------------------------------------------------------------------------------------------------------------------------------------

--DATA EXPLORATION

--AVERAGE MINUTES SPENT BY MEMBERS AND CASUAL USERS BY MONTH

SELECT member_casual, 
	   DATENAME(month,month_year) as month_used, 
	   AVG(CAST(LTRIM(DATEDIFF(MINUTE, 0, travel_time))AS INT)) AS average_travel_time
FROM CyclisticPortfolio..CyclisticTripMerged
GROUP BY member_casual, month_year
ORDER BY month_year;

--AVERAGE MINUTES SPENT BY MEMBERS AND CASUAL USERS BY WEEK 
SELECT member_casual, 
	   DATENAME(weekday,day_used) as day_used, 
	   AVG(CAST(LTRIM(DATEDIFF(MINUTE, 0, travel_time))AS INT)) AS average_travel_time
FROM CyclisticPortfolio..CyclisticTripMerged
GROUP BY member_casual, day_used
ORDER BY day_used desc;

-----------------------------------------------------------------------------------------------------------------------------------------------
-- COMMON DAY USED BY MEMBERS AND CASUAL RIDERS
--Monday
CREATE VIEW monday as
	SELECT 
		member_casual, COUNT (day_used) as monday
	FROM CyclisticPortfolio..CyclisticTripMerged
	WHERE day_used=1
	GROUP BY member_casual;

--Tuesday
CREATE VIEW tuesday as
	SELECT  
		member_casual, COUNT (day_used) as tuesday
	FROM CyclisticPortfolio..CyclisticTripMerged 
	WHERE day_used=2
	GROUP BY member_casual
	--ORDER BY 1;

--Wednesday
CREATE VIEW wednesday as
	SELECT  
		member_casual, COUNT (day_used) as wednesday
	FROM CyclisticPortfolio..CyclisticTripMerged
	WHERE day_used=3
	GROUP BY member_casual
	--ORDER BY 1;

--Thursday
CREATE VIEW thursday as
	SELECT  
		member_casual, COUNT (day_used) as thursday
	FROM CyclisticPortfolio..CyclisticTripMerged
	WHERE day_used=4
	GROUP BY member_casual
--	ORDER BY 1;

--Friday
CREATE VIEW friday as
	SELECT  
		member_casual, COUNT (day_used) as friday
	FROM CyclisticPortfolio..CyclisticTripMerged
	WHERE day_used=5
	GROUP BY member_casual
	--ORDER BY 1;

--Saturday
CREATE VIEW saturday as
	SELECT  
		member_casual, COUNT (day_used) as saturday
	FROM CyclisticPortfolio..CyclisticTripMerged
	WHERE day_used=6
	GROUP BY member_casual
	--ORDER BY 1;

--Sunday
CREATE VIEW sunday as
	SELECT  
		member_casual, COUNT(day_used) as sunday
	FROM CyclisticPortfolio..CyclisticTripMerged
	WHERE day_used=7
	GROUP BY member_casual
--	ORDER BY 1


-- ANNUAL MEMBER AND CASUAL RIDERS USAGE OF CYCLISTIC PER DAY
--JOINING ALL DAYS OF THE WEEK

SELECT mon.member_casual,mon.monday,tue.tuesday,wed.wednesday,thu.thursday,fri.friday,sat.saturday,sun.sunday
FROM ..monday mon
JOIN CyclisticPortfolio..tuesday tue
ON mon.member_casual = tue.member_casual
JOIN CyclisticPortfolio..wednesday wed
ON tue.member_casual = wed.member_casual
JOIN CyclisticPortfolio..thursday thu
ON wed.member_casual = thu.member_casual
JOIN CyclisticPortfolio..friday fri
ON thu.member_casual = fri.member_casual
JOIN CyclisticPortfolio..saturday sat
ON fri.member_casual = sat.member_casual
JOIN CyclisticPortfolio..sunday sun
ON sat.member_casual = sun.member_casual

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Common start and end stations used by casual riders
CREATE VIEW casual_start_station as

SELECT  TOP 3 (start_station_name) AS most_used_start_station,
		member_casual
FROM CyclisticPortfolio..CyclisticTripMerged
WHERE start_station_name is not null and member_casual = 'casual'
GROUP BY start_station_name,member_casual;

CREATE VIEW casual_end_station as

SELECT  TOP 3 (end_station_name) AS most_used_end_station,
		member_casual
FROM 
		CyclisticPortfolio..CyclisticTripMerged 
WHERE   end_station_name is not null and member_casual = 'casual'
GROUP BY member_casual,end_station_name



--Most used start and end stations by annual members

CREATE VIEW member_start_station as

SELECT  TOP 3 (start_station_name) AS most_used_start_station,
		member_casual
FROM CyclisticPortfolio..CyclisticTripMerged
WHERE start_station_name is not null and member_casual = 'member'
GROUP BY start_station_name,member_casual;

CREATE VIEW member_end_station as
SELECT  TOP 3 (end_station_name) AS most_used_end_station,
		member_casual
FROM 
		CyclisticPortfolio..CyclisticTripMerged 
WHERE   end_station_name is not null and member_casual = 'member'
GROUP BY end_station_name, member_casual

--MERGING COMMON STATIONS USED
SELECT *
FROM CyclisticPortfolio.. casual_start_station cs
JOIN CyclisticPortfolio..casual_end_station ce
ON CS.member_casual = ce.member_casual

UNION ALL

SELECT *
FROM CyclisticPortfolio.. member_start_station ms
JOIN CyclisticPortfolio..member_end_station me
ON ms.member_casual = me.member_casual

---------------------------------------------------------------------------------------------------------------------------------

-- HOW MANY CASUAL RIDERS AND ANNUAL MEMBERS USE CYCLISTIC PER MONTH
CREATE VIEW number_of_annual_member_per_month as
SELECT 
	   month_year,
	   COUNT(member_casual) as number_of_member_used
FROM CyclisticPortfolio..CyclisticTripMerged
WHERE member_casual='member'
GROUP BY month_year
--ORDER BY month_year;

SELECT 
	   DATENAME(MONTH,cas.month_year) AS month,
	   COUNT(cas.member_casual) as number_of_casual_used,
	   mem.number_of_member_used
FROM CyclisticPortfolio..CyclisticTripMerged cas
JOIN CyclisticPortfolio..number_of_annual_member_per_month mem
ON cas.month_year=mem.month_year
WHERE member_casual='casual'
GROUP BY cas.month_year,mem.number_of_member_used
ORDER BY cas.month_year;

---------------------------------------------------------------------------------------------------------------------------------------------
--CREATING VIEWS FOR VISUALIZATION
CREATE VIEW NumberUsersPerMonth as

SELECT 
	   DATENAME(MONTH,cas.month_year) AS month,
	   COUNT(cas.member_casual) as number_of_casual_used,
	   mem.number_of_member_used
FROM CyclisticPortfolio..CyclisticTripMerged cas
JOIN CyclisticPortfolio..number_of_annual_member_per_month mem
ON cas.month_year=mem.month_year
WHERE member_casual='casual'
GROUP BY cas.month_year,mem.number_of_member_used
--ORDER BY cas.month_year;


CREATE VIEW MostUsedStations as

SELECT *
FROM CyclisticPortfolio.. casual_start_station cs
JOIN CyclisticPortfolio..casual_end_station ce
ON CS.member_casual = ce.member_casual

UNION ALL

SELECT *
FROM CyclisticPortfolio.. member_start_station ms
JOIN CyclisticPortfolio..member_end_station me
ON ms.member_casual = me.member_casual



CREATE VIEW TimesUsedPerDay as
SELECT mon.member_casual,mon.monday,tue.tuesday,wed.wednesday,thu.thursday,fri.friday,sat.saturday,sun.sunday
FROM ..monday mon
JOIN CyclisticPortfolio..tuesday tue
ON mon.member_casual = tue.member_casual
JOIN CyclisticPortfolio..wednesday wed
ON tue.member_casual = wed.member_casual
JOIN CyclisticPortfolio..thursday thu
ON wed.member_casual = thu.member_casual
JOIN CyclisticPortfolio..friday fri
ON thu.member_casual = fri.member_casual
JOIN CyclisticPortfolio..saturday sat
ON fri.member_casual = sat.member_casual
JOIN CyclisticPortfolio..sunday sun
ON sat.member_casual = sun.member_casual;


CREATE VIEW AverageMinutesPerWeek as
SELECT member_casual, 
	   DATENAME(weekday,day_used) as day_used, 
	   AVG(CAST(LTRIM(DATEDIFF(MINUTE, 0, travel_time))AS INT)) AS average_travel_time
FROM CyclisticPortfolio..CyclisticTripMerged
GROUP BY member_casual, day_used
--ORDER BY day_used desc;

CREATE VIEW AverageMinutesPerMonth as
SELECT member_casual, 
	   DATENAME(month,month_year) as month_used, 
	   AVG(CAST(LTRIM(DATEDIFF(MINUTE, 0, travel_time))AS INT)) AS average_travel_time
FROM CyclisticPortfolio..CyclisticTripMerged
GROUP BY member_casual, month_year
--ORDER BY month_year;