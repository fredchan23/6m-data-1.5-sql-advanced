# Assignment

## Brief

Write the SQL statements for the following questions.

## Instructions

Paste the answer as SQL in the answer code section below each question.

### Question 1

Using the `claim` and `car` tables, write a SQL query to return a table containing `id, claim_date, travel_time, claim_amt` from `claim`, and `car_type, car_use` from `car`. Use an appropriate join based on the `car_id`.

Answer:

```sql
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
```

### Question 2

Write a SQL query to compute the running total of the `travel_time` column for each `car_id` in the `claim` table. The resulting table should contain `id, car_id, travel_time, running_total`.

Answer:

```sql
SELECT 
    id, 
    car_id, 
    travel_time,
    SUM(travel_time) OVER (PARTITION BY car_id ORDER BY id) AS running_total
FROM 
    claim; 
```

### Question 3

Using a Common Table Expression (CTE), write a SQL query to return a table containing `id, resale_value, car_use` from `car`, where the car resale value is less than the average resale value for the car use.

Answer:

```sql
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
```

# **Level Up: The Insurance Auditor Project**

Scenario:  
You are the Lead Data Analyst for "SafeDrive Insurance". The CEO suspects that certain car types in specific cities are disproportionately expensive.  
Your Task:  
Create a comprehensive SQL report that answers the following in a single script (using CTEs):

1. **Market Comparison:** For every claim, show the claim\_amt alongside the **average claim amount for that specific car\_type**.  
2. **Risk Ranking:** Within each state, rank the clients by their total claim amounts.  
3. **Efficiency:** Only show the **top 2** highest-claiming clients per state.  
4. **Final Output:** The table should include: Client Name, State, Car Type, Total Claimed, State Rank.

Submission:  
A single .sql file with comments explaining your logic.

```sql
WITH ClaimWithAvg AS (
    -- Step 1: Calculate average claim amount per car_type
    SELECT 
        cl.id AS claim_id,
        cl.claim_amt,
        c.car_type,
        cl.client_id,
        AVG(cl.claim_amt) OVER (PARTITION BY c.car_type) AS avg_claim_by_cartype
    FROM 
        claim cl
    JOIN 
        car c ON cl.car_id = c.id
), ClientTotalClaims AS (
    -- Step 2: Calculate total claim amounts per client
    SELECT 
        c.id AS client_id,
        CONCAT(c.first_name, ' ', c.last_name) AS client_name,
        a.state,
        SUM(cwa.claim_amt) AS total_claimed,
        STRING_AGG(DISTINCT cwa.car_type, ', ') AS car_types
    FROM 
        ClaimWithAvg cwa
    JOIN 
        client c ON cwa.client_id = c.id
    JOIN 
        address a ON c.address_id = a.id
    GROUP BY 
        c.id, c.first_name, c.last_name, a.state
), RankedClients AS (
    -- Step 3: Rank clients within each state by total claimed amount
    SELECT 
        ctc.client_name,
        ctc.state,
        ctc.car_types,
        ctc.total_claimed,
        RANK() OVER (PARTITION BY ctc.state ORDER BY ctc.total_claimed DESC) AS state_rank
    FROM 
        ClientTotalClaims ctc
)
-- Step 4: Select top 2 highest-claiming clients per state
SELECT 
    client_name,
    state,
    car_types,
    total_claimed,
    state_rank
FROM 
    RankedClients
WHERE 
    state_rank <= 2
ORDER BY 
    state, state_rank;
```
