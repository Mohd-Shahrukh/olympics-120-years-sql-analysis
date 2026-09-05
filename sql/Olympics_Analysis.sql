/*
===============================================================================
PROJECT : Olympics History Analysis
AUTHOR  : Abhishek Singhaniya
TOOL    : Microsoft SQL Server / T-SQL
DATASET : 120 years of Olympic history

PURPOSE
-------
Analyze Olympic medal data to answer business-style analytical questions
around teams, athletes, medals, Olympic seasons, sports and events.

TABLE RELATIONSHIP
------------------
athletes.id = athlete_events.athlete_id

KEY SQL CONCEPTS
----------------
JOINs | CTEs | Aggregate Functions | Window Functions | RANK()
PARTITION BY | STRING_AGG() | Conditional Aggregation | Date/Year Logic
===============================================================================
*/


/*=============================================================================
01. TEAM WITH THE MOST GOLD MEDALS
Business Question:
Which team has won the maximum number of gold medals over the years?
=============================================================================*/

SELECT TOP 1
    Team,
    COUNT(*) AS total_gold_medals
FROM athlete_events
WHERE Medal = 'Gold'
GROUP BY Team
ORDER BY total_gold_medals DESC;


/*=============================================================================
02. SILVER MEDALS BY TEAM + YEAR OF MAXIMUM SILVER MEDALS
Business Question:
For each team, how many silver medals did they win and in which year did
they win their maximum number of silver medals?

Output:
Team | Total Silver Medals | Year of Maximum Silver
=============================================================================*/

WITH team_year_silver AS
(
    SELECT
        Team,
        Year,
        COUNT(*) AS silver_medals
    FROM athlete_events
    WHERE Medal = 'Silver'
    GROUP BY
        Team,
        Year
),
team_total_silver AS
(
    SELECT
        Team,
        SUM(silver_medals) AS total_silver_medals
    FROM team_year_silver
    GROUP BY Team
),
ranked_years AS
(
    SELECT
        Team,
        Year,
        silver_medals,
        RANK() OVER
        (
            PARTITION BY Team
            ORDER BY silver_medals DESC, Year
        ) AS year_rank
    FROM team_year_silver
)
SELECT
    ts.Team,
    ts.total_silver_medals,
    ry.Year AS year_of_max_silver
FROM team_total_silver AS ts
INNER JOIN ranked_years AS ry
    ON ts.Team = ry.Team
WHERE ry.year_rank = 1
ORDER BY
    ts.total_silver_medals DESC,
    ts.Team;


/*=============================================================================
03. ATHLETE WITH THE MOST GOLD MEDALS AMONG GOLD-ONLY ATHLETES
Business Question:
Which athlete has won the maximum number of gold medals while never winning
a silver or bronze medal?

Approach:
1. Keep athletes who have won at least one Gold.
2. Exclude athletes who have won Silver or Bronze.
3. Rank remaining athletes by gold-medal count.
=============================================================================*/

WITH athlete_medals AS
(
    SELECT
        Athlete_ID,
        SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS gold_medals,
        SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS silver_medals,
        SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze_medals
    FROM athlete_events
    GROUP BY Athlete_ID
),
gold_only_ranked AS
(
    SELECT
        Athlete_ID,
        gold_medals,
        RANK() OVER (ORDER BY gold_medals DESC) AS athlete_rank
    FROM athlete_medals
    WHERE gold_medals > 0
      AND silver_medals = 0
      AND bronze_medals = 0
)
SELECT
    a.name,
    g.gold_medals
FROM gold_only_ranked AS g
INNER JOIN athletes AS a
    ON g.Athlete_ID = a.id
WHERE g.athlete_rank = 1;


/*=============================================================================
04. ATHLETE(S) WITH MOST GOLD MEDALS IN EACH YEAR
Business Question:
For each year, which athlete won the most gold medals?

In case of a tie, athlete names are returned as a comma-separated list.
=============================================================================*/

WITH athlete_year_gold AS
(
    SELECT
        Year,
        Athlete_ID,
        COUNT(*) AS gold_medals
    FROM athlete_events
    WHERE Medal = 'Gold'
    GROUP BY
        Year,
        Athlete_ID
),
year_max_gold AS
(
    SELECT
        Year,
        MAX(gold_medals) AS max_gold_medals
    FROM athlete_year_gold
    GROUP BY Year
)
SELECT
    ayg.Year,
    STRING_AGG(a.name, ', ') AS player_name,
    ayg.gold_medals
FROM athlete_year_gold AS ayg
INNER JOIN year_max_gold AS ymg
    ON ayg.Year = ymg.Year
   AND ayg.gold_medals = ymg.max_gold_medals
INNER JOIN athletes AS a
    ON ayg.Athlete_ID = a.id
GROUP BY
    ayg.Year,
    ayg.gold_medals
ORDER BY
    ayg.Year;


/*=============================================================================
05. INDIA'S FIRST GOLD, SILVER AND BRONZE MEDALS
Business Question:
In which year and sport did India win its first Gold, Silver and Bronze medal?

Output:
Medal | Year | Sport
=============================================================================*/

WITH india_medals AS
(
    SELECT
        Medal,
        Year,
        Sport,
        ROW_NUMBER() OVER
        (
            PARTITION BY Medal
            ORDER BY Year
        ) AS medal_rank
    FROM athlete_events
    WHERE Team = 'India'
      AND Medal IN ('Gold', 'Silver', 'Bronze')
)
SELECT
    Medal,
    Year,
    Sport
FROM india_medals
WHERE medal_rank = 1
ORDER BY
    CASE Medal
        WHEN 'Gold' THEN 1
        WHEN 'Silver' THEN 2
        WHEN 'Bronze' THEN 3
    END;


/*=============================================================================
06. ATHLETES WHO WON GOLD IN BOTH SUMMER AND WINTER OLYMPICS
Business Question:
Which athletes have won at least one Gold medal in both Olympic seasons?
=============================================================================*/

SELECT
    a.name
FROM athletes AS a
INNER JOIN athlete_events AS ae
    ON a.id = ae.Athlete_ID
WHERE ae.Medal = 'Gold'
GROUP BY
    a.id,
    a.name
HAVING COUNT(DISTINCT ae.Season) = 2
ORDER BY
    a.name;


/*=============================================================================
07. ATHLETES WHO WON GOLD, SILVER AND BRONZE IN A SINGLE OLYMPICS
Business Question:
Which athletes won all three medal types in the same Olympic edition?

Output:
Athlete | Year
=============================================================================*/

SELECT
    a.name,
    ae.Year
FROM athlete_events AS ae
INNER JOIN athletes AS a
    ON ae.Athlete_ID = a.id
WHERE ae.Medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY
    a.id,
    a.name,
    ae.Year
HAVING COUNT(DISTINCT ae.Medal) = 3
ORDER BY
    ae.Year,
    a.name;


/*=============================================================================
08. GOLD MEDALS IN THREE CONSECUTIVE SUMMER OLYMPICS
Business Question:
Which athletes won Gold medals in the same event across three consecutive
Summer Olympics, considering 2000 onwards?

Assumption:
Summer Olympics occur every four years starting in 2000.

Approach:
1. Filter Gold medals from Summer Olympics from 2000 onwards.
2. Group by athlete, event and year.
3. Compare each year with the next two Olympic cycles using LEAD().
4. Require a four-year gap between consecutive victories.
=============================================================================*/

WITH summer_gold AS
(
    SELECT DISTINCT
        Athlete_ID,
        Event,
        Year
    FROM athlete_events
    WHERE Medal = 'Gold'
      AND Season = 'Summer'
      AND Year >= 2000
),
three_consecutive AS
(
    SELECT
        Athlete_ID,
        Event,
        Year AS first_year,
        LEAD(Year, 1) OVER
        (
            PARTITION BY Athlete_ID, Event
            ORDER BY Year
        ) AS second_year,
        LEAD(Year, 2) OVER
        (
            PARTITION BY Athlete_ID, Event
            ORDER BY Year
        ) AS third_year
    FROM summer_gold
)
SELECT DISTINCT
    a.name,
    tc.Event
FROM three_consecutive AS tc
INNER JOIN athletes AS a
    ON tc.Athlete_ID = a.id
WHERE second_year = first_year + 4
  AND third_year = second_year + 4
ORDER BY
    a.name,
    tc.Event;
