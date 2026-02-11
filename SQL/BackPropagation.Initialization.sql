CREATE SCHEMA IF NOT EXISTS ai_BackPropagation;
SET search_path TO ai_BackPropagation, public; 

-- Create table for tha pairs (x,y) input to the algorithm 
DROP TABLE IF EXISTS actual_data CASCADE;
CREATE TABLE actual_data (
x FLOAT8 PRIMARY KEY,
y FLOAT8
);
INSERT INTO Actual_Data
SELECT -3, 10 UNION ALL
SELECT -2, 15 UNION ALL
SELECT -1, 20 UNION ALL
SELECT 1, 23 UNION ALL
SELECT 2, 27 UNION ALL
SELECT 3, 18 UNION ALL
SELECT 4, 14 UNION ALL
SELECT 5, 12 UNION ALL
SELECT 6, 10 UNION ALL
SELECT 7, 10 UNION ALL
SELECT 8, 12 UNION ALL
SELECT 9, 17 UNION ALL
SELECT 10, 20 UNION ALL
SELECT 11, 26 UNION ALL
SELECT 12, 30 UNION ALL
SELECT 13, 28 UNION ALL
SELECT 14, 26 UNION ALL
SELECT 15, 22 ;

--
-- create the table with the initial paramters: the main parameter is initial weights used by the model in the step 0 computation
DROP TABLE IF EXISTS model_parameters;
CREATE TABLE model_parameters (
	max_iterations numeric,
	weights FLOAT8[]                -- L'array [a, b, c, d, bias]
);

INSERT INTO model_parameters 
    (max_iterations, weights)
VALUES (
    2000, 
    ARRAY[0.1, 0.1, 0.1, 0.1, 18.0] -- [a, b, c, d, intercept/bias]
);

-- 
-- LR Scheduler: It configures the proper LR weight to use in the strp i-simo for the new weight computation
DROP TABLE IF EXISTS learning_rate_scheduler;
CREATE TABLE learning_rate_scheduler (
	from_step			NUMERIC PRIMARY KEY
	,to_step			NUMERIC
	,LR 				FLOAT8
);
INSERT INTO learning_rate_scheduler
SELECT   0,   100, 0.01 UNION ALL
SELECT 101,   200, 0.05 UNION ALL
SELECT 201,   500, 0.07 UNION ALL
SELECT 501, 10000, 0.07 
;


-- It solves the data normalization problem. X values in input (x_scaled column) to the backpropagation algorithm are the standardized ones
DROP VIEW IF EXISTS actual_data_scaled;
CREATE VIEW actual_data_scaled AS
WITH x_stats AS (
select 
	AVG(x) 				AS mean_x
	,STDDEV_POP(x) 		AS std_x 
	,MIN(x) 			AS min_x 
	,MAX(x) 			AS max_x 
from actual_data
)

, actual_data_scaled_temp AS (	
SELECT 
	actual_data.x														AS x
	,actual_data.y														AS y
	,(actual_data.x -  x_stats.mean_x) / x_stats.std_x					AS x_std
	,(actual_data.x -  x_stats.min_x) / (x_stats.max_x - x_stats.min_x)	AS x_norm
FROM actual_data, x_stats
)

SELECT
	actual_data_scaled_temp.x						AS x
	,actual_data_scaled_temp.y						AS y
-- ----------------------------------------------------------------------------------------------------
-- ========               =====    
-- x_scaled column is the input of BackPropagation algorithm 
-- ========               =====    
--
-- Never tested the backpropagation with x_norm method. 
--
	,actual_data_scaled_temp.x_std					AS x_scaled --> Dev std scaling works well
--	,actual_data_scaled_temp.x_norm					AS x_scaled --> Not tested
--	,actual_data_scaled_temp.x						AS x_scaled --> It doesn't work at all
FROM actual_data_scaled_temp
;

