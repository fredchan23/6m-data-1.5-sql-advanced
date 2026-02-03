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
