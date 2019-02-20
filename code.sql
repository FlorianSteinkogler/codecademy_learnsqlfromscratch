{\rtf1\ansi\ansicpg1252\cocoartf1671\cocoasubrtf200
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww10800\viewh8400\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\fs24 \cf0 WITH sources as (SELECT user_id, utm_source,\
        MIN(timestamp) as first_touch_at\
    FROM page_visits\
    GROUP BY user_id)\
SELECT utm_source, \
   count(*)\
FROM sources\
GROUP BY 1\
ORDER BY 2 DESC\
LIMIT 10;\
\
SELECT user_id, utm_source,\
        MIN(timestamp) as first_touch_at\
    FROM page_visits\
    GROUP BY user_id\
    limit 10;\
\
/*\
Here's the first-touch query, in case you need it\
*/\
\
WITH first_touch AS (\
    SELECT user_id,\
        MIN(timestamp) as first_touch_at\
    FROM page_visits\
    GROUP BY user_id)\
SELECT ft.user_id,\
    ft.first_touch_at,\
    pv.utm_source,\
		pv.utm_campaign\
FROM first_touch ft\
JOIN page_visits pv\
    ON ft.user_id = pv.user_id\
    AND ft.first_touch_at = pv.timestamp\
 limit 10;\
\
/*1.1*/\
SELECT COUNT(DISTINCT utm_campaign) as 'Q1.1 - Number of Campaigns' \
FROM page_visits;\
/*1.2*/\
SELECT COUNT(DISTINCT utm_source) as 'Q1.2 - Number of Sources' \
FROM page_visits;\
/*1.3*/\
SELECT DISTINCT utm_source as 'Q1.3 V1 - utm_source', \
	utm_campaign as 'Q1.3 V1 - utm_campaign' FROM page_visits\
ORDER BY utm_source;\
\
/* 1.3 alternative */\
SELECT utm_source as 'Q1.3 V2 - utm_source', utm_campaign as 'Q1.3 V2 - utm_campaign'\
FROM page_visits\
GROUP BY 2\
ORDER BY 1;\
\
/*2.1*/\
SELECT DISTINCT page_name as 'Q2 - Page Name' \
FROM page_visits;\
\
/*3.1*/\
WITH first_touch as (SELECT user_id,\
        MIN(timestamp) as first_touch_at\
    FROM page_visits\
    GROUP BY user_id),\
 ft_count as (\
 		SELECT ft.user_id, \
   			ft.first_touch_at, \
   			pv.utm_source, \
   			pv.utm_campaign\
 FROM first_touch as ft\
 JOIN page_visits as pv\
 		ON ft.user_id = pv.user_id AND \
 			ft.first_touch_at = pv.timestamp)\
SELECT ft_count.utm_source as 'First Touch Source', \
	ft_count.utm_campaign 'First Touch Campaign', \
  COUNT(first_touch_at) as '# of First Touches'\
FROM ft_count\
GROUP BY 1,2\
ORDER BY 3 DESC;\
\
/*4.1*/\
WITH last_touch as (\
  SELECT user_id,\
        MAX(timestamp) as last_touch_at\
  FROM page_visits\
  GROUP BY user_id),\
lt_count as (\
 			SELECT lt.user_id, \
  			lt.last_touch_at, \
  			pv.utm_source, \
  			pv.utm_campaign\
 FROM last_touch as lt\
 JOIN page_visits as pv\
 		ON lt.user_id = pv.user_id AND \
 		lt.last_touch_at = pv.timestamp)\
SELECT lt_count.utm_source as 'Last Touch Source', \
		lt_count.utm_campaign as 'Last Touch Campaign', \
    COUNT(last_touch_at) as '# of Last Touches'\
FROM lt_count\
GROUP BY 1,2\
ORDER BY 3 DESC;\
\
/*5.1*/\
SELECT COUNT (DISTINCT user_id) as 'Q5 - v1 # of UserIDs on purchase page' \
FROM page_visits\
WHERE page_name = '4 - purchase';\
\
/* 5.1. alternative */\
SELECT page_name, \
	COUNT(DISTINCT user_id) as 'Q5 - v2 # of UserIDs on purchase page'\
FROM page_visits\
WHERE page_name = '4 - purchase'\
GROUP BY 1;\
\
/*6.1*/\
WITH last_touch as (\
  SELECT user_id,\
        MAX(timestamp) as last_touch_at\
   FROM page_visits\
   WHERE page_name = '4 - purchase'\
   GROUP BY user_id),\
lt_count as (\
 			SELECT lt.user_id, \
   			lt.last_touch_at, \
  			pv.utm_source, \
  			pv.utm_campaign\
 FROM last_touch as lt\
 JOIN page_visits as pv\
	 ON lt.user_id = pv.user_id and \
 lt.last_touch_at = pv.timestamp)\
SELECT lt_count.utm_source as 'Last Touch Source', \
			lt_count.utm_campaign as 'Last Touch Campaign', \
      COUNT(last_touch_at) as '# of Last Touches'\
FROM lt_count\
GROUP BY 1,2\
ORDER BY 3 desc;\
\
/*6.1 alternative*/\
SELECT utm_campaign, \
	COUNT(DISTINCT user_id) as 'last touch count'\
FROM page_visits\
WHERE page_name = '4 - purchase'\
GROUP BY 1\
ORDER BY 2 DESC;\
\
/* join last und first touch */\
\
WITH first_touch AS (\
    SELECT user_id,\
        MIN(timestamp) as first_touch_at\
    FROM page_visits\
    GROUP BY user_id),\
first_touch_campaigns as (SELECT ft.user_id,\
    ft.first_touch_at,\
    pv.utm_source as first_touch_source,\
		pv.utm_campaign as first_touch_campaign,\
    pv.page_name as first_touch_page_name\
FROM first_touch ft\
JOIN page_visits pv\
    ON ft.user_id = pv.user_id\
    AND ft.first_touch_at = pv.timestamp),\
last_touch AS (\
    SELECT user_id,\
        Max(timestamp) as last_touch_at\
    FROM page_visits\
    GROUP BY user_id),\
last_touch_campaigns as (SELECT lt.user_id,\
    lt.last_touch_at,\
    pv.utm_source as last_touch_source,\
		pv.utm_campaign as last_touch_campaign,\
    pv.page_name as last_touch_page_name\
FROM last_touch lt\
JOIN page_visits pv\
    ON lt.user_id = pv.user_id\
    AND lt.last_touch_at = pv.timestamp)\
SELECT ftc.user_id, ftc.first_touch_source, 	ftc.first_touch_campaign,\
	ftc.first_touch_page_name,\
  ltc.last_touch_source,\
  ltc.last_touch_campaign,\
  ltc.last_touch_page_name\
FROM first_touch_campaigns as ftc\
 JOIN last_touch_campaigns as ltc\
 	ON ftc.user_id = ltc.user_id;\
 \
 \
/* join last und first touch - group by */\
\
WITH first_touch AS (\
    SELECT user_id,\
        MIN(timestamp) as first_touch_at\
    FROM page_visits\
    GROUP BY user_id),\
first_touch_campaigns as (SELECT ft.user_id,\
    ft.first_touch_at,\
    pv.utm_source as first_touch_source,\
		pv.utm_campaign as first_touch_campaign,\
    pv.page_name as first_touch_page_name\
FROM first_touch ft\
JOIN page_visits pv\
    ON ft.user_id = pv.user_id\
    AND ft.first_touch_at = pv.timestamp),\
last_touch AS (\
    SELECT user_id,\
        Max(timestamp) as last_touch_at\
    FROM page_visits\
    GROUP BY user_id),\
last_touch_campaigns as (SELECT lt.user_id,\
    lt.last_touch_at,\
    pv.utm_source as last_touch_source,\
		pv.utm_campaign as last_touch_campaign,\
    pv.page_name as last_touch_page_name\
FROM last_touch lt\
JOIN page_visits pv\
    ON lt.user_id = pv.user_id\
    AND lt.last_touch_at = pv.timestamp), \
fltc as (SELECT \
   ftc.user_id,\
   ftc.first_touch_source,\
   ftc.first_touch_campaign,\
   ftc.first_touch_page_name, \
   ltc.last_touch_source, \
   ltc.last_touch_campaign, \
   ltc.last_touch_page_name\
 FROM first_touch_campaigns as ftc\
 JOIN last_touch_campaigns as ltc\
 	ON ftc.user_id = ltc.user_id)\
SELECT \
 	first_touch_source, \
  first_touch_campaign, \
  first_touch_page_name,\
  last_touch_source, \
  last_touch_campaign, \
  last_touch_page_name, \
  COUNT (*)\
 FROM fltc\
 WHERE last_touch_page_name = '4 - purchase'\
 GROUP BY 1,2,3,4,5,6\
 ORDER BY 7 DESC;\
 \
 /* join last und first touch - conv.rate per first touch and last touch */\
\
WITH first_touch AS (\
    SELECT user_id,\
        MIN(timestamp) as first_touch_at\
    FROM page_visits\
    GROUP BY user_id),\
first_touch_campaigns as (\
  SELECT ft.user_id,\
    ft.first_touch_at,\
    pv.utm_source as first_touch_source,\
		pv.utm_campaign as first_touch_campaign,\
    pv.page_name as first_touch_page_name\
FROM first_touch ft\
JOIN page_visits pv\
    ON ft.user_id = pv.user_id\
    AND ft.first_touch_at = pv.timestamp),\
last_touch AS (\
    SELECT user_id,\
        Max(timestamp) as last_touch_at\
    FROM page_visits\
    GROUP BY user_id),\
last_touch_campaigns as (SELECT lt.user_id,\
    lt.last_touch_at,\
    pv.utm_source as last_touch_source,\
		pv.utm_campaign as last_touch_campaign,\
    pv.page_name as last_touch_page_name\
FROM last_touch lt\
JOIN page_visits pv\
    ON lt.user_id = pv.user_id\
    AND lt.last_touch_at = pv.timestamp), \
fltc as (\
  select ftc.user_id, \
  	ftc.first_touch_source, \
  	ftc.first_touch_campaign,\
		ftc.first_touch_page_name, \
  	ltc.last_touch_source, \
  	ltc.last_touch_campaign,\
  	ltc.last_touch_page_name\
 FROM first_touch_campaigns as ftc\
 JOIN last_touch_campaigns as ltc\
	 ON ftc.user_id = ltc.user_id),\
fltc_group as (\
 SELECT first_touch_source, \
  first_touch_campaign, \
  first_touch_page_name,\
  last_touch_source, \
  last_touch_campaign, \
  last_touch_page_name, \
  COUNT (*) as number_fltc\
 FROM fltc\
 GROUP BY 1,2,3,4,5,6\
 ORDER BY 7 DESC),\
cross_join as (\
 SELECT sum(number_fltc) as all_first_touches\
 FROM fltc_group),\
convrate as (\
 SELECT * \
 FROM fltc_group\
 CROSS JOIN cross_join)\
SELECT first_touch_source, \
  first_touch_campaign, \
  first_touch_page_name,\
  last_touch_source, \
  last_touch_campaign, \
  last_touch_page_name, \
  round(1.0 * number_fltc / all_first_touches * 100,2) as conversionrate\
FROM convrate\
WHERE last_touch_page_name = '4 - purchase';\
 \
  \
  \
  \
 \
 \
\
\
\
\
\
\
\
}