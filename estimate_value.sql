
SELECT clm.claim_id 
, clm.claim_number
, dim_est.estimate_id
, dim_est.CLAIM_COVERAGE_NAME
FROM UAT_EDW.CWS.DIM_CLAIM clm
JOIN UAT_EDW.CWS.F_ESTIMATE est 
    ON clm.claim_key=est.claim_key
JOIN UAT_EDW.CWS.DIM_ESTIMATE dim_est 
    ON est.estimate_key=dim_est.estimate_key
--WHERE claim_id=9067220;
WHERE estimate_id=17147441;