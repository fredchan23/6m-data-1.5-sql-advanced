/*
CREATE TABLE "main"."address" ( 
  "id" BIGINT NULL,
  "country" VARCHAR NULL,
  "state" VARCHAR NULL,
  "city" VARCHAR NULL
);
CREATE TABLE "main"."car" ( 
  "id" BIGINT NULL,
  "resale_value" BIGINT NULL,
  "car_type" VARCHAR NULL,
  "car_use" VARCHAR NULL,
  "car_manufacture_year" BIGINT NULL
);
CREATE TABLE "main"."claim" ( 
  "id" BIGINT NULL,
  "claim_date" VARCHAR NULL,
  "travel_time" BIGINT NULL,
  "claim_amt" BIGINT NULL,
  "motor_vehicle_record" BIGINT NULL,
  "car_id" BIGINT NULL,
  "client_id" BIGINT NULL
);
CREATE TABLE "main"."client" ( 
  "id" BIGINT NULL,
  "first_name" VARCHAR NULL,
  "last_name" VARCHAR NULL,
  "email" VARCHAR NULL,
  "phone" VARCHAR NULL,
  "birth_year" BIGINT NULL,
  "education" VARCHAR NULL,
  "gender" VARCHAR NULL,
  "home_value" BIGINT NULL,
  "home_kids" BIGINT NULL,
  "income" BIGINT NULL,
  "kids_drive" BIGINT NULL,
  "marriage_status" BOOLEAN NULL,
  "occupation" VARCHAR NULL,
  "address_id" BIGINT NULL
);
*/

-- Using the claim and car tables, write a SQL query to return a table containing id, claim_date, travel_time, claim_amt from claim, and car_type, car_use from car. Use an appropriate join based on the car_id.

SELECT 
    claim.id, 
    claim.claim_date, 
    claim.travel_time, 
    claim.claim_amt, 
    car.car_type, 
    car.car_use
FROM 
    claim
JOIN 
    car ON claim.car_id = car.id;   

-- Write a SQL query to compute the running total of the travel_time column for each car_id in the claim table. The resulting table should contain id, car_id, travel_time, running_total.
SELECT 
    id, 
    car_id, 
    travel_time,
    SUM(travel_time) OVER (PARTITION BY car_id ORDER BY id) AS running_total
FROM 
    claim;

-- Using a Common Table Expression (CTE), write a SQL query to return a table containing id, resale_value, car_use from car, where the car resale value is less than the average resale value for the car use.
WITH AvgResale AS (
    SELECT 
        car_use, 
        AVG(resale_value) AS avg_resale_value
    FROM 
        car
    GROUP BY 
        car_use
)
SELECT 
    c.id, 
    c.resale_value, 
    c.car_use
FROM 
    car c
JOIN 
    AvgResale ar ON c.car_use = ar.car_use
WHERE 
    c.resale_value < ar.avg_resale_value;

/*
Scenario:
You are the Lead Data Analyst for "SafeDrive Insurance". The CEO suspects that certain car types in specific cities are disproportionately expensive.
Your Task:
Create a comprehensive SQL report that answers the following in a single script (using CTEs):

Market Comparison: For every claim, show the claim_amt alongside the average claim amount for that specific car_type.
Risk Ranking: Within each state, rank the clients by their total claim amounts.
Efficiency: Only show the top 2 highest-claiming clients per state.
Final Output: The table should include: Client Name, State, Car Type, Total Claimed, State Rank.

Add comments in the SQL script to explain each step of your query.
*/

WITH ClaimWithAvg AS (
    -- Step 1: Calculate average claim amount per car_type
    SELECT 
        cl.id AS claim_id,
        cl.claim_amt,
        c.car_type,
        cl.client_id
    FROM 
        claim cl
    JOIN 
        car c ON cl.car_id = c.id
), ClientTotalClaims AS (
    -- Step 2: Calculate total claim amounts per client
    SELECT 
        c.id AS client_id,
        c.first_name || ' ' || c.last_name AS client_name,
        a.state,
        SUM(cw.claim_amt) AS total_claimed
    FROM 
        ClaimWithAvg cw
    JOIN 
        client c ON cw.client_id = c.id
    JOIN 
        address a ON c.address_id = a.id
    GROUP BY 
        c.id, c.first_name, c.last_name, a.state
), RankedClients AS (
    -- Step 3: Rank clients within each state by total claimed amount
    SELECT 
        ctc.client_name,
        ctc.state,
        cw.car_type,
        ctc.total_claimed,
        RANK() OVER (PARTITION BY ctc.state ORDER BY ctc.total_claimed DESC) AS state_rank
    FROM 
        ClientTotalClaims ctc
    JOIN 
        ClaimWithAvg cw ON ctc.client_id = cw.client_id
)
-- Step 4: Select top 2 highest-claiming clients per state
SELECT 
    client_name,
    state,
    car_type,
    total_claimed,
    state_rank
FROM 
    RankedClients
WHERE 
    state_rank <= 2
ORDER BY 
    state, state_rank;