CREATE DATABASE sachin_career_analysis_project
USE sachin_career_analysis_project

SELECT * FROM sachin_career

-- Q1. What is Sachin's total career innings count and total runs scored?
SELECT 
    COUNT(*) AS total_innings,
    SUM(runs) AS total_runs
FROM sachin_career;

-- Q2 What is Sachin's overall career batting average?
-- Purpose: Batting average = Total Runs / (Innings - Not Outs). NULLIF prevents division by zero.
SELECT 
    CONVERT(DECIMAL(10,2),
        SUM(runs) * 1.0 / NULLIF((COUNT(*) - SUM(not_out_flag)), 0)
    ) AS career_batting_average
FROM sachin_career;

--Q3 What does Sachin's complete overall career summary look like?
-- Purpose: One-stop query for all major career statistics: innings, runs, average, centuries, fifties, highest score, and strike rate.
SELECT 
    COUNT(*) AS total_innings,
    SUM(runs) AS total_runs,
    CAST(
        ROUND(SUM(runs) * 1.0 / NULLIF((COUNT(*) - SUM(not_out_flag)), 0), 2)
        AS DECIMAL(10,2)
    ) AS career_average,
    SUM(CASE WHEN runs >= 100 THEN 1 ELSE 0 END) AS centuries,
    SUM(CASE WHEN runs BETWEEN 50 AND 99 THEN 1 ELSE 0 END) AS half_centuries,
    MAX(runs) AS highest_score,
    CAST(
        ROUND(SUM(runs) * 100.0 / NULLIF(SUM(bf), 0), 2)
        AS DECIMAL(10,2)
    ) AS overall_strike_rate
FROM sachin_career;

-- Q4 How did Sachin perform across different match formats (Test, ODI, T20I)?
-- Purpose: Breaks down all key stats by format to compare his performance across different game types.
SELECT
    match_type,
    COUNT(*) AS innings,
    SUM(runs) AS total_runs,
    CAST(SUM(runs) * 1.0 / NULLIF((COUNT(*) - SUM(not_out_flag)), 0) AS DECIMAL(10,2)) AS average,
    SUM(CASE WHEN runs >= 100 THEN 1 ELSE 0 END) AS centuries,
    SUM(CASE WHEN runs BETWEEN 50 AND 99 THEN 1 ELSE 0 END) AS fifties,
    MAX(runs) AS highest,
    CAST(SUM(runs) * 100.0 / NULLIF(SUM(bf), 0) AS DECIMAL(10,2)) AS strike_rate
FROM sachin_career
GROUP BY match_type;

-- Q5 Which opponents did Sachin score the most runs against?
-- Purpose: Ranks opponents by total runs scored, revealing Sachin's favourite and toughest opponents.
SELECT 
    opponent,
    COUNT(*) AS total_innings,
    SUM(runs) AS total_runs,
    CAST(
        ROUND(
            SUM(runs) * 1.0 / NULLIF((COUNT(*) - SUM(not_out_flag)), 0),
            2
        ) AS DECIMAL(10,2)
    ) AS average,
    MAX(runs) AS highest
FROM sachin_career
GROUP BY opponent
HAVING COUNT(*) >= 10  
ORDER BY total_runs DESC;

-- Q6	Which are the top 5 venues where Sachin scored the most runs?
--Purpose: Identifies Sachin's favourite grounds by total runs, innings played, average, and highest score.
SELECT 
    TOP 5
    ground,
    COUNT(*) AS innings,
    SUM(runs) AS total_runs,
    CAST(
        ROUND(
            SUM(runs) * 1.0 / NULLIF((COUNT(*) - SUM(not_out_flag)), 0),
            2
        ) AS DECIMAL(10,2)
    ) AS avg_per_innings,
    MAX(runs) AS highest
FROM sachin_career
GROUP BY ground
ORDER BY total_runs DESC;

-- Q7 How does Sachin's performance compare between Home and Away matches?
-- Purpose: Shows whether Sachin performed better in home conditions (India) or away (overseas).
SELECT
    home,
    COUNT(*) AS innings,
    SUM(runs) AS total_runs,
    CAST(
        ROUND(SUM(runs) * 1.0 / NULLIF((COUNT(*) - SUM(not_out_flag)), 0), 2)
        AS DECIMAL(10,2)
    ) AS average,
    SUM(CASE WHEN runs >= 100 THEN 1 ELSE 0 END) AS centuries,
    SUM(CASE WHEN runs BETWEEN 50 AND 99 THEN 1 ELSE 0 END) AS fifties,
    MAX(runs) AS highest_score,
    CAST(
        ROUND(SUM(runs) * 100.0 / NULLIF(SUM(bf), 0), 2)
        AS DECIMAL(10,2)
    ) AS strike_rate
FROM sachin_career
GROUP BY home;

-- Q8 How did Sachin's run tally and average change year by year?
-- Purpose: Shows career progression over time — peak years, decline, and consistency across seasons.
SELECT
    year,
    COUNT(*) AS innings,
    SUM(runs) AS yearly_runs,
    CAST(ROUND(SUM(runs) * 1.0 / NULLIF((COUNT(*) - SUM(not_out_flag)), 0), 2) AS DECIMAL(10,2) )AS yearly_average
FROM sachin_career
GROUP BY year
ORDER BY year;

-- Q9 How was Sachin most frequently dismissed during his career?
-- Purpose: Analyses dismissal types to understand his batting weaknesses and vulnerabilities.
SELECT
    dismissal,
    COUNT(*) AS times
FROM sachin_career
WHERE not_out_flag = 0
  AND dismissal != 'not out'
GROUP BY dismissal
ORDER BY times DESC;

-- Q10	How did Sachin perform at different batting positions?
-- Purpose: Reveals which position in the batting order brought out his best performances.
SELECT
    pos AS batting_position,
    COUNT(*) AS innings,
    SUM(runs) AS total_runs,
    CAST(ROUND(SUM(runs) * 1.0 / NULLIF((COUNT(*) - SUM(not_out_flag)), 0), 2) AS DECIMAL(10,2)) AS average,
    ROUND(SUM(runs) * 100.0 / NULLIF(SUM(bf), 0), 2) AS strike_rate
FROM sachin_career
GROUP BY pos
ORDER BY batting_position;

-- Q11 What percentage of Sachin's fifties were converted into centuries?
-- Purpose: Measures batting conversion rate — a key indicator of big-innings ability and mental strength.
SELECT 
    CAST(
        ROUND(
            SUM(CASE WHEN runs >= 100 THEN 1 ELSE 0 END) * 100.0 /
            NULLIF(SUM(CASE WHEN runs >= 50 THEN 1 ELSE 0 END), 0),
            2
        ) AS DECIMAL(10,2)
    ) AS conversion_pct
FROM sachin_career;

-- Q12	What is the frequency distribution of Sachin's scores across ranges?
-- Purpose: Shows how often Sachin scored ducks, low scores, fifties, and centuries — a full scoring profile.
SELECT
    score_range,
    COUNT(*) AS frequency,
    CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM sachin_career), 2) AS Decimal(10,2))AS percentage
FROM (
    SELECT
        CASE
            WHEN runs = 0 THEN 'Duck'
            WHEN runs < 10 THEN '1-9'
            WHEN runs < 25 THEN '10-24'
            WHEN runs < 50 THEN '25-49'
            WHEN runs < 100 THEN '50-99'
            ELSE '100+'
        END AS score_range
    FROM sachin_career
) AS score_groups
GROUP BY score_range
ORDER BY frequency DESC;

-- Q13	Which were Sachin's top 3 best years by total runs scored?
-- Purpose: Identifies peak performance years in Sachin's career.
SELECT TOP 3
    year,
    SUM(runs) AS total_runs,
    COUNT(*) AS innings,
    CAST(ROUND(SUM(runs) * 1.0 / NULLIF((COUNT(*) - SUM(not_out_flag)), 0), 2) AS Decimal(10, 2) )AS average
FROM sachin_career
GROUP BY year
ORDER BY total_runs DESC;

-- Q14	How did Sachin's strike rate evolve year by year throughout his career?
-- Purpose: Tracks batting aggression over time — useful to see if he became more or less attacking.
SELECT
    year,
    ROUND(SUM(runs) * 100.0 / NULLIF(SUM(bf), 0), 2) AS strike_rate,
    COUNT(*) AS innings
FROM sachin_career
WHERE bf IS NOT NULL
GROUP BY year
ORDER BY year;

-- Q15 How did Sachin perform at Home vs Away across each match format?
-- Purpose: Combines format and venue context for a deeper performance breakdown.
SELECT
    home,
    match_type,
    COUNT(*) AS innings,
    SUM(runs) AS total_runs,
    CAST(ROUND(SUM(runs) * 1.0 / NULLIF((COUNT(*) - SUM(not_out_flag)), 0), 2) AS Decimal(10,2) )AS average
FROM sachin_career
GROUP BY home, match_type
ORDER BY match_type, home;

-- Q16	What is the cumulative run tally across Sachin's entire career innings by innings?
-- Purpose: Uses a window function to show running total of runs — great for career progression chart in Power BI.
SELECT
    CAST(date AS DATE) AS date,
    runs,
    SUM(runs) OVER (ORDER BY date, inns) AS cumulative_runs
FROM sachin_career
ORDER BY date, inns;

-- Q17	What are Sachin's top 10 highest individual scores?
-- Purpose: Lists the greatest innings of Sachin's career with opponent, venue, date, and format.
SELECT TOP 10
    runs,
    opponent,
    ground,
    CAST(date AS DATE) AS date,
    match_type
FROM sachin_career
ORDER BY runs DESC;

-- Q18	Against which opponents did Sachin average the most runs per innings?
-- Purpose: Finds Sachin's favourite opponents by batting average — not just total runs.
SELECT TOP 5
    opponent,
    COUNT(*) AS innings,
    SUM(runs) AS total_runs,
    ROUND(AVG(CAST(runs AS FLOAT)), 2) AS batting_avg
FROM sachin_career
GROUP BY opponent
HAVING COUNT(*) >= 10
ORDER BY batting_avg DESC;

-- Q19 Against which opponents was Sachin most consistent (lowest score variation)?
-- Purpose: Uses STDEV to measure scoring consistency — lower standard deviation means more predictable performance.
SELECT
    opponent,
    ROUND(AVG(CAST(runs AS FLOAT)), 2) AS avg_runs,
    ROUND(STDEV(CAST(runs AS FLOAT)), 2) AS consistency
FROM sachin_career
GROUP BY opponent
HAVING COUNT(*) >= 10
ORDER BY avg_runs DESC;








