DROP FUNCTION IF EXISTS gd_month;
DELIMITER $$
CREATE FUNCTION gd_month(ts TIMESTAMP)
  RETURNS TIMESTAMP
BEGIN
  RETURN DATE_FORMAT(ts, '%Y-%m-01');
END;
$$
DELIMITER ;


SELECT gd_month(u.date) as cohort, COUNT(*)
FROM users as u
GROUP BY cohort; 

SELECT gd_month(e.date) as cohort, COUNT(*)
FROM events as e
GROUP BY cohort; 


-- Cohort analysis for february cohort
SELECT DATE_FORMAT(gd_month(e.date), '%Y/%m') as engagement_date, 
		COUNT(e.id) as num_events
FROM users as u
JOIN events as e ON u.id=e.user_id
WHERE DATE_FORMAT(u.date, '%Y/%m') = '2013/02'
GROUP BY engagement_date;



-- find percent active and inactive users for february cohort
SELECT DATE_FORMAT(gd_month(e.date), '%Y/%m') as engagement_date, 
		COUNT(DISTINCT(u.date)) as actives
FROM users as u
JOIN events as e ON u.id=e.user_id
WHERE DATE_FORMAT(u.date, '%Y/%m') = '2013/02'
GROUP BY engagement_date;



-- Find total users per cohort
SELECT DATE_FORMAT(gd_month(u.date), '%Y/%m') as cohort,
		COUNT(DISTINCT(u.id)) as total_users
FROM users as u
GROUP BY cohort; 


-- Find active users per month for each cohort
SELECT DATE_FORMAT(u.date, '%Y/%m') as cohort,
		PERIOD_DIFF(DATE_FORMAT(e.date, '%Y%m'), DATE_FORMAT(u.date, '%Y%m')) as months, 
		COUNT(DISTINCT(u.id)) as actives
FROM users as u
JOIN events as e ON u.id = e.user_id
GROUP BY cohort, months
HAVING months >= 0
ORDER BY cohort, months ASC;



-- combine active users and total users 
SELECT a.cohort, a.months, a.actives as active_users, t.total_users as total_users, a.actives/t.total_users as percent_active
FROM 
(SELECT DATE_FORMAT(u.date, '%Y/%m') as cohort,
		PERIOD_DIFF(DATE_FORMAT(e.date, '%Y%m'), DATE_FORMAT(u.date, '%Y%m')) as months, 
		COUNT(DISTINCT(u.id)) as actives
FROM users as u
JOIN events as e ON u.id = e.user_id
GROUP BY cohort, months
HAVING months >= 0) as a
JOIN 
(SELECT DATE_FORMAT(gd_month(u.date), '%Y/%m') as cohort,
		COUNT(DISTINCT(u.id)) as total_users
FROM users as u
GROUP BY cohort) as t
ON a.cohort = t.cohort
ORDER BY a.cohort, a.months ASC;






