------------------------------------------------------------------
----- performance test on all CWS data with no limit on date -----
------------------------------------------------------------------

-- Estimate Value Analysis
--# claims by peril
select 
c.INDUSTRY_LOSS_TYPE as peril,
count(e.CLAIM_KEY)
from [UAT_EDW_2_2].[CWS].[F_ESTIMATE] e
join [UAT_EDW_2_2].[CWS].[DIM_CLAIM] c on e.CLAIM_KEY = c.CLAIM_KEY
group by c.INDUSTRY_LOSS_TYPE; --9 sec 331 ms

--# Avg Value/Estimate by peril
select
SUM(f.TOTAL)/COUNT(distinct d_e.ROOT_COPY_FROM_ESTIMATE_ID),
d_c.INDUSTRY_LOSS_TYPE
from [UAT_EDW_2_2].[CWS].[F_ESTIMATE] f
join [UAT_EDW_2_2].[CWS].[DIM_ESTIMATE] d_e
	on  f.ESTIMATE_KEY=d_e.ESTIMATE_KEY
join [UAT_EDW_2_2].[CWS].[DIM_CLAIM] d_c
	on  f.CLAIM_KEY=d_c.CLAIM_KEY
GROUP BY d_c.INDUSTRY_LOSS_TYPE
; --12 sec 347 ms

--User Performance 
--assignment counts by user
select 
DU.LOGIN_NAME,
count(DA.ASSIGNMENT_KEY) as assign_ct  
from [UAT_EDW_2_2].[CWS].[F_ESTIMATE] FE
JOIN [UAT_EDW_2_2].[CWS].[DIM_ASSIGNMENT] DA on FE.ASSIGNMENT_KEY = DA.ASSIGNMENT_KEY
JOIN [UAT_EDW_2_2].[CWS].[DIM_ESTIMATE_CLAIM_EVENT] EDEC on FE.ESTIMATE_KEY = EDEC.ESTIMATE_KEY
JOIN [UAT_EDW_2_2].[CWS].[DIM_CLAIM_EVENT] DEC on EDEC.CLAIM_EVENT_KEY = DEC.CLAIM_EVENT_KEY
JOIN [UAT_EDW_2_2].[CWS].[DIM_USER] DU on DEC.USER_KEY = DU.USER_KEY
group by DU.LOGIN_NAME; --1 min 9 sec 64 ms

--sum of estimate amount by user
select 
DU.LOGIN_NAME,
SUM(FE.TOTAL) as sum_estimate_amt
from [UAT_EDW_2_2].[CWS].[F_ESTIMATE] FE
JOIN [UAT_EDW_2_2].[CWS].[DIM_ESTIMATE_CLAIM_EVENT] EDEC on FE.ESTIMATE_KEY = EDEC.ESTIMATE_KEY
JOIN [UAT_EDW_2_2].[CWS].[DIM_CLAIM_EVENT] DEC on EDEC.CLAIM_EVENT_KEY = DEC.CLAIM_EVENT_KEY
JOIN [UAT_EDW_2_2].[CWS].[DIM_USER] DU on DEC.USER_KEY = DU.USER_KEY
group by DU.LOGIN_NAME; --31 sec 41 ms

--total estimates by carrier
SELECT
PART.PARENT_PARTICIPANT_COMPANY_NAME AS carrier,
COUNT(DISTINCT FE.ESTIMATE_KEY) as estimate_ct
FROM [UAT_EDW_2_2].[CWS].[F_ESTIMATE] FE
JOIN [UAT_EDW_2_2].[CWS].[DIM_ESTIMATE_CLAIM_EVENT] EDEC on FE.ESTIMATE_KEY = EDEC.ESTIMATE_KEY
JOIN [UAT_EDW_2_2].[CWS].[DIM_CLAIM_EVENT] DEC on EDEC.CLAIM_EVENT_KEY = DEC.CLAIM_EVENT_KEY
JOIN [UAT_EDW_2_2].[CWS].[DIM_PARTICIPANT] PART on DEC.PARTICIPANT_KEY = PART.PARTICIPANT_KEY
GROUP BY PART.PARENT_PARTICIPANT_COMPANY_NAME
; --38 sec 448 ms


------------------------------------------------------------------
------------ performance test on 5 years of CWS data  ------------
------------------------------------------------------------------


--# claims by peril
select 
c.INDUSTRY_LOSS_TYPE as peril,
count(e.CLAIM_KEY)
from [Claims_LH].[CWS].[F_ESTIMATE] e
join [Claims_LH].[CWS].[DIM_CLAIM] c on e.CLAIM_KEY = c.CLAIM_KEY
group by c.INDUSTRY_LOSS_TYPE; --9 sec 331 ms
--new views: 12 sec 481 ms, second run: 5 sec 780 ms

--# Avg Value/Estimate by peril
select
SUM(f.TOTAL)/COUNT(distinct d_e.ROOT_COPY_FROM_ESTIMATE_ID),
d_c.INDUSTRY_LOSS_TYPE
from [Claims_LH].[CWS].[F_ESTIMATE] f
join [Claims_LH].[CWS].[DIM_ESTIMATE] d_e
	on  f.ESTIMATE_KEY=d_e.ESTIMATE_KEY
join [Claims_LH].[CWS].[DIM_CLAIM] d_c
	on  f.CLAIM_KEY=d_c.CLAIM_KEY
GROUP BY d_c.INDUSTRY_LOSS_TYPE
; --12 sec 347 ms
--new views: 18 sec 94 ms, second run: 12 sec 363 ms

--User Performance 
--assignment counts by user
select 
DU.LOGIN_NAME,
count(DA.ASSIGNMENT_KEY) as assign_ct  
from [Claims_LH].[CWS].[F_ESTIMATE] FE
JOIN [Claims_LH].[CWS].[DIM_ASSIGNMENT] DA on FE.ASSIGNMENT_KEY = DA.ASSIGNMENT_KEY
--JOIN [Claims_LH].[CWS].[DIM_ESTIMATE_CLAIM_EVENT] EDEC on FE.ESTIMATE_KEY = EDEC.ESTIMATE_KEY
JOIN [Claims_LH].[CWS].[DIM_CLAIM_EVENT] DEC on FE.ESTIMATE_KEY = DEC.ESTIMATE_KEY
JOIN [Claims_LH].[CWS].[DIM_USER] DU on DEC.USER_KEY = DU.USER_KEY
group by DU.LOGIN_NAME; --1 min 9 sec 64 ms
--new views: 19 sec 258 ms, second run: 12 sec 91 ms

--sum of estimate amount by user
select 
DU.LOGIN_NAME,
SUM(FE.TOTAL) as sum_estimate_amt
from [Claims_LH].[CWS].[F_ESTIMATE] FE
JOIN [Claims_LH].[CWS].[DIM_CLAIM_EVENT] DEC on FE.ESTIMATE_KEY = DEC.ESTIMATE_KEY
JOIN [Claims_LH].[CWS].[DIM_USER] DU on DEC.USER_KEY = DU.USER_KEY
group by DU.LOGIN_NAME; --31 sec 41 ms
--4 sec 757 ms, second run: 5 sec 918 ms

--total estimates by carrier
SELECT
PART.PARENT_PARTICIPANT_COMPANY_NAME AS carrier,
COUNT(DISTINCT FE.ESTIMATE_KEY) as estimate_ct
FROM [Claims_LH].[CWS].[F_ESTIMATE] FE
JOIN [Claims_LH].[CWS].[DIM_CLAIM_EVENT] DEC on FE.ESTIMATE_KEY = DEC.ESTIMATE_KEY
JOIN [Claims_LH].[CWS].[DIM_PARTICIPANT] PART on DEC.PARTICIPANT_KEY = PART.PARTICIPANT_KEY
GROUP BY PART.PARENT_PARTICIPANT_COMPANY_NAME
; --38 sec 448 ms
--new views: 8 sec 830 ms, second run: 7 sec 350 ms




