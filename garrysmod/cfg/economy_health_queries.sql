-- Economy health checks for DarkRP (run with SQLWorkbench or sqlite3 garrysmod/sv.db)

-- 1) Wallet snapshot: player count and spread
SELECT
  COUNT(*) AS players,
  ROUND(AVG(wallet), 2) AS avg_wallet,
  MIN(wallet) AS min_wallet,
  MAX(wallet) AS max_wallet,
  SUM(wallet) AS total_wallet
FROM darkrp_player;

-- 2) Wealth concentration: top 5 share of total wallets
WITH t AS (
  SELECT wallet FROM darkrp_player
),
s AS (
  SELECT SUM(wallet) AS total FROM t
),
top AS (
  SELECT SUM(wallet) AS top5
  FROM (SELECT wallet FROM t ORDER BY wallet DESC LIMIT 5)
)
SELECT top5, total, ROUND(100.0 * top5 / total, 2) AS pct_top5
FROM top, s;

-- 3) Economy snapshots availability (Xenin F4)
SELECT COUNT(*) AS snapshots, MIN(time) AS first_snapshot, MAX(time) AS last_snapshot
FROM xenin_f4menu_economysnapshots;

-- 4) 24h money trend from snapshots
WITH o AS (
  SELECT time, CAST(money AS INTEGER) AS money
  FROM xenin_f4menu_economysnapshots
  WHERE time >= datetime('now', '-24 hours')
  ORDER BY time
),
first AS (SELECT time AS t1, money AS m1 FROM o LIMIT 1),
last  AS (SELECT time AS t2, money AS m2 FROM o ORDER BY time DESC LIMIT 1)
SELECT
  t1, m1, t2, m2,
  (m2 - m1) AS delta,
  ROUND(100.0 * (m2 - m1) / NULLIF(m1, 0), 2) AS pct_change
FROM first, last;

-- 5) Salary sanity check against current player records
SELECT
  ROUND(AVG(salary), 2) AS avg_salary,
  MIN(salary) AS min_salary,
  MAX(salary) AS max_salary
FROM darkrp_player;
