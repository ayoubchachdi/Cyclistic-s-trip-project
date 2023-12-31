select*
from bike

---Exploring DATA----
EXEC sp_help 'bike'

----Detecting null values----
Select *
From bike
Where start_station_name is Null OR end_station_name is Null

-----Detecting duplicate row----
Select ride_id, count(*)
From bike
Group by ride_id
Having count(*) = 2

------Number of trips according to rider type----
Select member_casual, Count(member_casual) as Number_of_trips
From bike
Where start_station_name is not Null AND end_station_name is not Null
Group by member_casual
Order by 2 desc

------Hours of exploitation according to rider type----
Select member_casual, Sum(DATEDIFF(minute,started_at, ended_at))/60 as hours_of_exploitation
From bike
Where start_station_name is not Null AND end_station_name is not Null
Group by member_casual
Order by 2 Desc

------Break trip down into 3 types-----
Select member_casual, Type_of_trip, Count(Type_of_trip) as Number_of_trip, Sum(Duration_of_ride)/60 as hours_of_exploitation
From (Select member_casual, DATEDIFF(minute,started_at, ended_at) as Duration_of_ride, Case
When 60 >= DATEDIFF(minute,started_at, ended_at) Then 'Short_trip'
When 180 >= DATEDIFF(minute,started_at, ended_at) and DATEDIFF(minute,started_at, ended_at)> 60 Then 'Medium_trip'
Else 'Long_trip'
End as Type_of_trip
From bike
Where start_station_name is not Null AND end_station_name is not Null) as MA
Group by member_casual, Type_of_trip
Order by 1, 2

-------Average duration of trip and total trips for each type of rider-------
Select member_casual, AVG(DATEDIFF(minute,started_at, ended_at)) as Average_duration_of_Trip_by_min, Count(member_casual) as Total_Trips
From bike
Where start_station_name is not Null AND end_station_name is not Null
Group by member_casual

--------Break trips down into destinations and determine its types-----
Select start_station_name, end_station_name, Count(*) as Number_of_trips, Case
When Count(*)>=70 Then 'Popular_destination'
When Count(*)>=30 and 70>Count(*) Then 'Mediums_popular_destination'
Else 'weak_popular_destination' End as Type_of_Destination
From bike
Where start_station_name is not Null AND end_station_name is not Null
Group by start_station_name, end_station_name
Order by 3 Desc

---Calculate total trips for each type of destination----
Select bike.member_casual, Type_of_Destination, Count(Type_of_Destination) as Total_trips From
(Select start_station_name, end_station_name, Count(*) as Number_of_trips, Case
When Count(*)>=70 Then 'Popular_destination'
When Count(*)>=30 and 70>Count(*) Then 'Mediums_popular_destination'
Else 'weak_popular_destination' End as Type_of_Destination
From bike
Group by start_station_name, end_station_name) as MA
Inner Join bike on bike.start_station_name=MA.start_station_name and bike.end_station_name=MA.end_station_name
Where bike.start_station_name is not Null OR bike.end_station_name is not Null
Group by bike.member_casual, Type_of_Destination
Order by 1,2 Desc

-----Convert started_at date to day of week----
Select *, DATEPART(DW, started_at) AS day_of_week
From bike
Where start_station_name is not Null OR end_station_name is not Null
Order by 3

-----Calculate daily number of trips------
Select b.New_date, b.day_of_week, Count(b.New_date) as number_of_trips From
(select ride_id, CONVERT(DATE, started_at) as New_date, DATEPART(DW, started_at) AS day_of_week
From bike
Where start_station_name is not Null and end_station_name is not Null) as b
Group by b.New_date, b.day_of_week
Order by b.New_date, b.day_of_week




---Creation of tables-------
----------------------------
Create table Numberoftrips
(
Type_of_membership nvarchar(255),
Number_of_trips numeric,
)
Insert into Numberoftrips
Select member_casual, Count(member_casual) as Number_of_trips
From bike
Where start_station_name is not Null AND end_station_name is not Null
Group by member_casual
Order by 2 desc

Select*
From Numberoftrips

Create table Hoursofexploitation
(
Type_of_membership nvarchar(255),
hours_of_exploitation numeric,
)
Insert into Hoursofexploitation
Select member_casual, Sum(DATEDIFF(minute,started_at, ended_at))/60 as hours_of_exploitation
From bike
Where start_station_name is not Null AND end_station_name is not Null
Group by member_casual
Order by 2 Desc

select*
from Hoursofexploitation

Select*
From Numberoftrips

Create table TypeHoursofExploitationofTrip
(
Type_of_membership nvarchar(255),
Type_of_trip nvarchar(255),
Number_of_trips numeric,
hours_of_exploitation numeric,
)
Insert into TypeHoursofExploitationofTrip
Select member_casual, Type_of_trip, Count(Type_of_trip) as Number_of_trip, Sum(Duration_of_ride)/60 as hours_of_exploitation
From (Select member_casual, DATEDIFF(minute,started_at, ended_at) as Duration_of_ride, Case
When 60 >= DATEDIFF(minute,started_at, ended_at) Then 'Short_trip'
When 180 >= DATEDIFF(minute,started_at, ended_at) and DATEDIFF(minute,started_at, ended_at)> 60 Then 'Medium_trip'
Else 'Long_trip'
End as Type_of_trip
From bike
Where start_station_name is not Null AND end_station_name is not Null) as MA
Group by member_casual, Type_of_trip
Order by 1, 2

select*
from TypeHoursofExploitationofTrip
Order by 1, 2

Create table  AveragedurationofTrip
(
Type_of_membership nvarchar(255),
Average_duration_of_Trip_by_min numeric,
Total_Trips numeric,
)
Insert into AveragedurationofTrip
Select member_casual, AVG(DATEDIFF(minute,started_at, ended_at)) as Average_duration_of_Trip_by_min, Count(member_casual) as Total_Trips
From bike
Where start_station_name is not Null AND end_station_name is not Null
Group by member_casual

select*
from AveragedurationofTrip

Create table TypeofDestination
(
Type_of_membership nvarchar(255),
Type_of_Destination nvarchar(255),
Total_Trips numeric,
)
Insert into TypeofDestination
Select bike.member_casual, Type_of_Destination, Count(Type_of_Destination) as Total_trips From
(Select start_station_name, end_station_name, Count(*) as Number_of_trips, Case
When Count(*)>=70 Then 'Popular_destination'
When Count(*)>=30 and 70>Count(*) Then 'Mediums_popular_destination'
Else 'weak_popular_destination' End as Type_of_Destination
From bike
Group by start_station_name, end_station_name) as MA
Inner Join bike on bike.start_station_name=MA.start_station_name and bike.end_station_name=MA.end_station_name
Where bike.start_station_name is not Null OR bike.end_station_name is not Null
Group by bike.member_casual, Type_of_Destination
Order by 1,2 Desc

select* from TypeofDestination


Create table TypetotalofDestination
(
Type_of_Destination nvarchar(255),
Total_of_Trips numeric,
)
Insert into TypetotalofDestination
select Type_of_Destination, Sum(Total_Trips) as Total_of_trips
from TypeofDestination
Group by Type_of_Destination

select* from TypetotalofDestination

Create table weekdaynumbertrips
(
Day_of_week numeric,
number_of_trips numeric,
)
Insert into weekdaynumbertrips
Select b.day_of_week, Count(b.New_date) as number_of_trips From
(select ride_id, CONVERT(DATE, started_at) as New_date, DATEPART(DW, started_at) AS day_of_week
From bike
Where start_station_name is not Null and end_station_name is not Null) as b
Group by b.day_of_week
Order by b.day_of_week

select* from weekdaynumbertrips

Create table dailynumbertrips
(
Date_ Date,
Day_of_week numeric,
number_of_trips numeric,
)
Insert into dailynumbertrips
Select b.New_date as Date_, b.day_of_week, Count(b.New_date) as Number_of_trips From
(select ride_id, CONVERT(DATE, started_at) as New_date, DATEPART(DW, started_at) AS day_of_week
From bike
Where start_station_name is not Null and end_station_name is not Null) as b
Group by b.New_date, b.day_of_week
Order by b.New_date, b.day_of_week

select* from dailynumbertrips


Create table alltable
(
ride_id nvarchar(255),
rideable_type nvarchar(255),
started_at Datetime,
ended_at Datetime,
start_station_name nvarchar(255),
end_station_name nvarchar(255),
member_casual nvarchar(255),
_date date,
Day_of_week numeric,
)
Insert into alltable
Select ride_id, rideable_type, started_at, ended_at, start_station_name, end_station_name, member_casual, CONVERT(DATE, started_at) as _date, DATEPART(DW, started_at) AS day_of_week
From bike
Where start_station_name is Not Null OR end_station_name is Not Null
Order by _date