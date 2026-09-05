# 🏅 Olympics History Analysis — SQL Server

## 📌 Project Overview

A **SQL Server / T-SQL analytics project** using 120 years of Olympic history to answer analytical questions about athletes, teams, medals, sports, events, and Olympic seasons.

The project demonstrates how relational Olympic data can be transformed into meaningful insights using joins, CTEs, aggregation, ranking, conditional logic, and window functions.

## 🎯 Business Questions

The analysis answers eight key questions:

1. Which team has won the maximum number of Gold medals?
2. For each team, what is the total Silver medal count and the year of its maximum Silver-medal performance?
3. Which athlete has the most Gold medals among athletes who have won only Gold?
4. For each year, which athlete(s) won the most Gold medals, including ties?
5. When and in which sport did India win its first Gold, Silver and Bronze medals?
6. Which athletes won Gold medals in both Summer and Winter Olympics?
7. Which athletes won Gold, Silver and Bronze in the same Olympic year?
8. Which athletes won Gold in the same event across three consecutive Summer Olympics from 2000 onwards?

## 🗂️ Dataset

The source description states that the data covers **120 years of Olympic history** and contains two datasets: an athletes table and an athlete-events table. The `athlete_id` in the event data refers to the athlete ID in the athletes data. fileciteturn1file0L1-L3

### Tables

| Table | Purpose |
|---|---|
| `athletes` | Athlete master data |
| `athlete_events` | Olympic participation, event, season and medal-level data |

### Key Relationship

```text
athletes
   │
   │ athletes.id = athlete_events.Athlete_ID
   ▼
athlete_events
```

## 🛠️ Tools & Technologies

- **Microsoft SQL Server**
- **T-SQL**
- **SQL Server Management Studio (SSMS)**
- **GitHub**

## 🧠 SQL Concepts Demonstrated

- INNER JOIN
- GROUP BY
- HAVING
- CASE expressions
- CTEs
- Aggregate functions
- `RANK()`
- `ROW_NUMBER()`
- `LEAD()`
- Window functions
- `PARTITION BY`
- `STRING_AGG()`
- Conditional aggregation
- Top-N analysis
- Consecutive-year analysis

## 🔍 Analytical Approach

### Medal Analysis
Medal records are filtered and aggregated to identify team and athlete performance.

### Ranking
`RANK()` and `ROW_NUMBER()` are used to identify maximum performers and first medal occurrences.

### Tie Handling
`STRING_AGG()` is used to return multiple athletes in a single year when they share the maximum number of Gold medals.

### Consecutive Olympic Analysis
`LEAD()` is used to compare Olympic years and identify athletes winning Gold in the same event across three consecutive four-year Summer Olympic cycles.

## 💡 Business / Analytical Value

Although the dataset is sports-focused, the project demonstrates transferable analytics skills:

- Ranking entities based on performance
- Finding first/maximum occurrences
- Comparing performance across time
- Handling ties
- Joining master and transactional/event data
- Detecting consecutive-period patterns
- Converting complex business questions into SQL logic

## 📁 Repository Structure

```text
olympics-sql-analysis/
│
├── README.md
│
├── sql/
│   └── Olympics_Analysis.sql
│
├── data/
│   ├── athletes.csv
│   └── athlete_events.csv
│
├── docs/
│   └── project-summary.md
│
└── results/
    └── README.md
```

## ▶️ How to Run

1. Create a database in SQL Server.
2. Import `data/athletes.csv` as the `athletes` table.
3. Import `data/athlete_events.csv` as the `athlete_events` table.
4. Verify that the athlete key relationship is maintained.
5. Open `sql/Olympics_Analysis.sql` in SSMS.
6. Execute the queries section by section.

## 📈 Future Improvements

- Build a Power BI dashboard for medal and athlete performance.
- Add country/team-level trend analysis.
- Compare Summer vs Winter performance over time.
- Create athlete medal leaderboards.
- Analyze sport-level medal distribution.
- Add interactive filters for country, athlete, sport, season and year.

## 👤 Author

**Mohammad Shahrukh**

Data Analyst / Business Analyst Portfolio

**Core Skills:** SQL | Data Analysis | Business Analysis | Reporting

## 💼 Recruiter Summary

> Built a SQL Server-based Olympics History Analysis project using relational athlete and event data. Applied joins, CTEs, aggregations, ranking and window functions to analyze medal performance, athlete rankings, first occurrences, cross-season achievements and consecutive Olympic victories, translating complex analytical questions into structured SQL solutions.
