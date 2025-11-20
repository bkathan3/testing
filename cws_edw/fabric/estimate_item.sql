--average # of items per claim
SELECT 
    AVG(items_per_claim) AS average_num_items
FROM (
    SELECT 
        CLAIM_KEY,
        COUNT(ESTIMATE_ITEM_KEY) AS items_per_claim
    FROM [Claims_LH].[CWS].[F_ESTIMATE_ITEM]
    GROUP BY CLAIM_KEY
) AS sub; --21 sec 357 ms
--second run: 12 sec 284 ms 

--depreciation
SELECT TOP 1000
		d_est.ESTIMATE_ID,
		dim_est_it.ESTIMATE_ITEM_ID,

		/*--Amount Values--*/
		f_est_it.TOTAL_MATERIAL,
		f_est_it.TOTAL_LABOR,
		f_est_it.TOTAL_EQUIPMENT,
		f_est_it.TOTAL_MARKET_CONDITION,
		f_est_it.TOTAL,

        /*--Depreciation--*/
        f_est_it.TOTAL_DEPRECIATION,
        dim_est_it.DEPRECIATION_APPLICABILITY,
        dim_est_it.DEPRECIATION_APPLICABILITY_DESCRIPTION,
        f_est_it.DEPRECIATION_AGE,
        f_est_it.DEPRECIATION_FLAT,
        dim_est_it.DEPRECIATION_TYPE,
        dim_est_it.DEPRECIATION_TYPE_DESCRIPTION,
        dim_est_it.DEPRECIATION_USAGE,
        f_est_it.DEPRECIATION_FIXED_RATE,
        f_est_it.DEPRECIATION_MAXIMUM_RATE,
        f_est_it.DEPRECIATION_FIRST_YEAR_RATE,
        f_est_it.DEPRECIATION_ADDITIONAL_YEAR_RATE,
        f_est_it.DEPRECIATION_LIFE_EXPECTANCY,
        dim_est_it.RECOVERABLE_DEPRECIATION,

        /*--TradeName TradeGroup--*/
        d_it_cat.CATEGORY_CODE as ParentItemCategoryCode, --Trade Group
        d_it_cat.CATEGORY_NAME as ParentItemCategoryName, --Trade Group
        d_it_cat.SUB_CATEGORY_CODE as ItemCategoryCode, -- Trade Name
        d_it_cat.SUB_CATEGORY_NAME as ItemCategoryName, -- Trade Name

         /*--Trades--*/
        dim_est_it.ROOT_ITEM_CATEGORY_NAME AS EI_ROOTITEMCATEGORYNAME,
        dim_est_it.ITEM_CATEGORY_NAME AS EI_ITEMCATEGORYNAME,
        dim_est_it.SUB_ITEM_CATEGORY_NAME AS EI_SUBITEMCATEGORYNAME,
		dim_est_it.ITEM_CATEGORY_FULL_NAME,
        dim_est_it.GRADE_DESCRIPTION,
		/*--Misc Flags or Values--*/
		dim_est_it.SUPPLEMENT_TYPE_DESCRIPTION,
		dim_est_it.TYPE_DESCRIPTION,
		dim_est_it.LINE_TYPE,
        dim_est_it.LINE_TYPE_DESCRIPTION,
		dim_est_it.CREATED_DATE,
		dim_est_it.LAST_MODIFIED_DATE
FROM [Claims_LH].[CWS].[F_ESTIMATE_ITEM] f_est_it
JOIN [Claims_LH].[CWS].[DIM_ESTIMATE_ITEM] dim_est_it
    ON f_est_it.ESTIMATE_ITEM_KEY = dim_est_it.ESTIMATE_ITEM_KEY
JOIN [Claims_LH].[CWS].[DIM_ESTIMATE] d_est 
    ON f_est_it.ESTIMATE_KEY = d_est.ESTIMATE_KEY
JOIN [Claims_LH].[CWS].[DIM_ITEM_CATEGORY] d_it_cat
    ON f_est_it.ITEM_CATEGORY_KEY = d_it_cat.ITEM_CATEGORY_KEY;
-- 49 sec 458 ms
-- second run: 14 sec 148 ms

-- total overhead and profit for painting
SELECT 
    CASE 
        WHEN Dim_EstimateItems.APPLY_OVERHEAD_AND_PROFIT = 1 THEN EstimateItems.TOTAL * Estimates.OVERHEAD_RATE
        ELSE 0
    END AS ItemOverhead,
    CASE 
        WHEN Dim_EstimateItems.APPLY_OVERHEAD_AND_PROFIT = 1 THEN EstimateItems.TOTAL * Estimates.PROFIT_RATE
        ELSE 0
    END AS ItemProfit
FROM [Claims_LH].[CWS].[F_ESTIMATE_ITEM] AS EstimateItems
-- I know it is an anti-pattern to join fact to fact in dimensional models, but I understand the cartesian product that could occur and I know the granularity to use in this case
JOIN [Claims_LH].[CWS].[F_ESTIMATE] AS Estimates
  ON EstimateItems.[ESTIMATE_KEY] = Estimates.[ESTIMATE_KEY]
JOIN [Claims_LH].[CWS].[DIM_ESTIMATE_ITEM] as Dim_EstimateItems
  ON EstimateItems.ESTIMATE_ITEM_KEY=Dim_EstimateItems.ESTIMATE_ITEM_KEY
JOIN [Claims_LH].[CWS].[DIM_ITEM_CATEGORY] as item_cat 
  ON EstimateItems.ITEM_CATEGORY_KEY=item_cat.ITEM_CATEGORY_KEY
WHERE item_cat.CATEGORY_NAME='PNT - Painting';
--31 sec 641 ms
--second run: 39 sec 975 ms


 --average total for painting from water mitigation perils
SELECT 
  item_cat.CATEGORY_NAME,
  DC.INDUSTRY_LOSS_TYPE,
  AVG(FEI.TOTAL) AS AvgTotalPainting
FROM [Claims_LH].[CWS].[F_ESTIMATE_ITEM] AS FEI
JOIN [Claims_LH].[CWS].[DIM_ESTIMATE_ITEM] AS DEI
  ON FEI.ESTIMATE_ITEM_KEY = DEI.ESTIMATE_ITEM_KEY 
JOIN [Claims_LH].[CWS].[DIM_ITEM_CATEGORY] AS item_cat 
  ON FEI.ITEM_CATEGORY_KEY = item_cat.ITEM_CATEGORY_KEY
JOIN [Claims_LH].[CWS].[DIM_ESTIMATE] DE 
  ON FEI.ESTIMATE_KEY = DE.ESTIMATE_KEY
JOIN [Claims_LH].[CWS].[F_ESTIMATE] FE
  ON DE.ESTIMATE_KEY = FE.ESTIMATE_KEY 
JOIN [Claims_LH].[CWS].[DIM_CLAIM] DC
  ON FE.CLAIM_KEY = DC.CLAIM_KEY
WHERE item_cat.CATEGORY_NAME = 'PNT - Painting'
  AND DC.INDUSTRY_LOSS_TYPE LIKE '%Water%'
GROUP BY 
  item_cat.CATEGORY_NAME,
  DC.INDUSTRY_LOSS_TYPE;
--14 sec 974 ms
--second run: 12 sec 448 ms

--which vendors handle our painting line items?
SELECT DISTINCT 
    d_cl_pt.PARENT_PARTICIPANT_COMPANY_NAME,
    COUNT(DISTINCT f_est_it.ESTIMATE_KEY) as record_ct
FROM [Claims_LH].[CWS].[F_ESTIMATE_ITEM] f_est_it
JOIN [Claims_LH].[CWS].[DIM_ESTIMATE] DE 
    ON f_est_it.ESTIMATE_KEY = DE.ESTIMATE_KEY
JOIN [Claims_LH].[CWS].[DIM_CLAIM_EVENT] d_ce 
    ON DE.ESTIMATE_KEY = d_ce.ESTIMATE_KEY
JOIN [Claims_LH].[CWS].[DIM_CLAIM_PARTICIPANT] d_cl_pt
    ON d_ce.CLAIM_PARTICIPANT_KEY = d_cl_pt.CLAIM_PARTICIPANT_KEY
JOIN [Claims_LH].[CWS].[DIM_ITEM_CATEGORY] item_cat 
    ON f_est_it.ITEM_CATEGORY_KEY = item_cat.ITEM_CATEGORY_KEY
WHERE item_cat.CATEGORY_NAME = 'PNT - Painting'
GROUP BY d_cl_pt.PARENT_PARTICIPANT_COMPANY_NAME
;
--53 sec 430 ms
--second run: 21 sec 899 ms 