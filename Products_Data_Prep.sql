CREATE OR REPLACE TABLE DP_PREPPIN_DATA_2024_WK10 AS

WITH transactions_1 AS (
    SELECT * FROM (
  
        SELECT
        
        -- Converting transaction date to date type
            TO_DATE(
                RIGHT(TO_VARCHAR("Transaction_Date"), LEN(TO_VARCHAR("Transaction_Date")) - 5),
                'MMMM DD, YYYY'
            ) AS "Transaction Date"
    
            ,MAX("Transaction Date") OVER () AS "Latest Transaction Date"
            
            ,"Transanction_Number" AS "Transaction Number"
            ,"Product_ID" AS "Product ID"
    
        -- Updating field values from numbers to names values
            ,CASE
                WHEN "Cash_or_Card" = 1 THEN 'Card'
                WHEN "Cash_or_Card" = 2 THEN 'Cash'
            END AS "Cash or Card"
            
            ,"Loyalty_Number" AS "Loyalty Number"
            ,"Sales_Before_Discount" AS "Sales Before Discount"
            
        FROM TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2024_WK10_TRANSACTION
    )
    
-- Filter to last 2 years for year-on-year comparison
    WHERE YEAR("Transaction Date") >= YEAR("Latest Transaction Date") - 1
)
,


transactions_2 AS (
    SELECT
        t.*
        ,calendar
    FROM transactions_1 t

-- Builds list of all dates from 03/01/23 to 06/03/2024 (first and last transaction dates in dataset)
    RIGHT JOIN (
        SELECT
            ROW_NUMBER() OVER (ORDER BY SEQ4()) AS days
            ,TO_DATE(DATEADD(day, days, '2023-01-02')) AS calendar
        FROM TABLE(GENERATOR(rowcount => 429))
    ) c
    
    ON t."Transaction Date" = c.calendar
)
,


products AS (
    SELECT
    
    -- Building product ID to join to transactions
        "Product Type" || '-' || REPLACE("Product Scent",' ','_') || '-' || "Product Size" AS "Product ID"
        ,a.*
        
    FROM (
    
        SELECT
            TO_VARCHAR("Product_Scent") AS "Product Scent"

        -- If product size is null, use pack size. Groups both sizes in one column
            ,NVL(TO_VARCHAR("Product_Size"), TO_VARCHAR("Pack_Size")) AS "Product Size"
            
            ,TO_VARCHAR("Product_Type") AS "Product Type"
            ,TO_NUMERIC(TO_VARCHAR("Unit_Cost"),5 ,2) AS "Unit Cost"
            ,TO_NUMERIC(TO_VARCHAR("Selling_Price"),5 ,2) AS "Selling Price"
            
        FROM TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2024_WK10_PRODUCT
    ) a
)
,


loyalty AS (
    SELECT
    
    -- Change to first name - last name by splitting on space, capitalising first letter then concatenating
        INITCAP(SPLIT_PART(TO_VARCHAR("Customer_Name"),', ',2)) || ' ' ||
            INITCAP(SPLIT_PART(TO_VARCHAR("Customer_Name"),', ',1)) AS "Customer Name"

    -- Remove % sign from discount field, then convert to decimal numeric
        ,ROUND(TO_NUMERIC(RTRIM(TO_VARCHAR("Loyalty_Discount"), '%')) / 100, 2) AS "Loyalty Discount"

    -- Grouping misspelled loyalty tiers into correct values
        ,CASE TO_VARCHAR("Loyalty_Tier")
            WHEN 'Goald' THEN 'Gold'
            WHEN 'Bronz' THEN 'Bronze'
            WHEN 'Sliver' THEN 'Silver'
            ELSE INITCAP(TO_VARCHAR("Loyalty_Tier"))
        END AS "Loyalty Tier"
        
        ,TO_VARCHAR("Loyalty_Number") AS "Loyalty Number"
        
    FROM TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2024_WK10_LOYALTY
)


SELECT
    calendar AS "Transaction Date"
    ,"Transaction Number"
    ,"Product Type"
    ,"Product Scent"
    ,"Product Size"
    ,"Cash or Card"
    ,"Loyalty Number"
    ,"Customer Name"
    ,"Loyalty Tier"
    ,"Loyalty Discount"
    ,"Quantity"
    ,"Unit Cost"
    ,"Selling Price"
    ,"Sales Before Discount"
    ,"Sales After Discount"
    ,"Sales After Discount" - ("Unit Cost" * "Quantity") AS "Profit"
FROM (

    SELECT
        t2.*
        ,t2."Sales Before Discount" / p."Selling Price" AS "Quantity"
        ,p."Product Scent"
        ,p."Product Size"
        ,p."Product Type"
        ,p."Unit Cost"
        ,p."Selling Price"
        ,l."Customer Name"
        ,l."Loyalty Discount"
        ,l."Loyalty Tier"

    -- For customers with a loyalty number, apply discount
        ,CASE
            WHEN t2."Loyalty Number" IS NOT NULL THEN (1 - l."Loyalty Discount") * t2."Sales Before Discount"
            ELSE t2."Sales Before Discount"
        END AS "Sales After Discount"
        
    FROM transactions_2 t2
    
    LEFT JOIN products p
    ON t2."Product ID" = p."Product ID"
    
    LEFT JOIN loyalty l
    ON t2."Loyalty Number" = l."Loyalty Number"
)

ORDER BY "Transaction Date" DESC, "Transaction Number", "Product Type", "Product Scent", "Product Size"
;
