SET search_path TO ai_BackPropagation, public; 

-- The same query runs different trainings on differnet model
-- The single model is defined as:
-- 1. polynomial degree 
-- 2. Inital wieights
-- 3. max_iterations - how long the training is -
-- 4. LR. A single learning rate for all the steps
WITH RECURSIVE polynomial_models AS (
SELECT
	'4'											AS degree
	,ARRAY[0.1, 0.1, 0.1, 0.1, 18.0]::FLOAT8[]	AS coefficients
	,5000										AS max_iterations
	,0.01::FLOAT8								AS LR
UNION ALL
SELECT
	'5'												AS degree
	,ARRAY[0.1, 0.1, 0.1, 0.1, 0.1, 18.0]::FLOAT8[]	AS coefficients
	,5000											AS max_iterations
	,0.01::FLOAT8									AS LR
UNION ALL
SELECT
	'6'														AS degree
	,ARRAY[0.1, 0.1, 0.18, 0.1, 0.1, 0.1, 18.0]::FLOAT8[]	AS coefficients	
	,15000													AS max_iterations
	,0.01::FLOAT8											AS LR
UNION ALL
SELECT
	'7'															AS degree
	,ARRAY[0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 18.0]::FLOAT8[]	AS coefficients
	,20000														AS max_iterations
	,0.001::FLOAT8												AS LR
UNION ALL
SELECT
	'8'																AS degree
	,ARRAY[0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 18.0]::FLOAT8[]	AS coefficients
	,20000															AS max_iterations
	,0.0001::FLOAT8													AS LR
UNION ALL
SELECT
	'9'																	AS degree
	,ARRAY[0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 18.0]::FLOAT8[]	AS coefficients
	,20000															AS max_iterations
	,0.0001::FLOAT8													AS LR
UNION ALL
SELECT
	'10'																	AS degree
	,ARRAY[0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 18.0]::FLOAT8[]AS coefficients
	,20000															AS max_iterations
	,0.0001::FLOAT8													AS LR
),
iterations (
	degree										--TEXT
	,LR											--FLOAT8
	,current_step								--NUMERIC
	,weights									--FLOAT8[]
	,sse										--FLOAT8
	,gradients_x_next_iteration					--FLOAT8[]
	,max_iterations 							--NUMERIC

	,R2											--FLOAT8
	,MAE										--FLOAT8
	,MAPE										--FLOAT8
)
AS (
SELECT
	p.degree									AS degree
	,p.LR										AS LR
	,0											AS current_step
	,p.coefficients								AS weights
	,current_metrics.sse						AS sse
	,current_metrics.gradients_x_next_iteration	AS gradients_x_next_iteration
	,p.max_iterations							AS max_iterations

	,current_metrics.R2							AS R2
	,current_metrics.MAE						AS MAE
	,current_metrics.MAPE						AS MAPE
	
FROM polynomial_models p
CROSS JOIN LATERAL calculate_step_metrics(p.coefficients) current_metrics

UNION ALL

SELECT
	prev.degree									AS degree
	,prev.LR									AS LR
	,prev.current_step + 1						AS current_step
	,current_iteration.new_weights				AS weights
	,current_metrics.sse						AS sse
	,current_metrics.gradients_x_next_iteration	AS gradients_x_next_iteration
	,prev.max_iterations						AS max_iterations

	,current_metrics.R2							AS R2
	,current_metrics.MAE						AS MAE
	,current_metrics.MAPE						AS MAPE

FROM iterations prev
CROSS JOIN LATERAL (
        SELECT update_weights(prev.weights, prev.gradients_x_next_iteration, COALESCE(prev.LR, 0.001)) AS new_weights
    ) current_iteration
CROSS JOIN LATERAL calculate_step_metrics(current_iteration.new_weights) current_metrics
WHERE prev.current_step < prev.max_iterations

)
/*
select 
		degree::INTEGER
		,LR
		,SSE
		,R2
		,MAE
		,MAPE
		,max_iterations
from 	iterations 
WHERE 	current_step = max_iterations
ORDER BY 1;
*/

-- Flatting the results on a single row for each model
select 
		current_step
		,MAX(CASE WHEN degree = '4' THEN SSE ELSE 0 END) AS polynomial_4_SSE
		,MAX(CASE WHEN degree = '5' THEN SSE ELSE 0 END) AS polynomial_5_SSE
		,MAX(CASE WHEN degree = '6' THEN SSE ELSE 0 END) AS polynomial_6_SSE
		,MAX(CASE WHEN degree = '7' THEN SSE ELSE 0 END) AS polynomial_7_SSE
		,MAX(CASE WHEN degree = '8' THEN SSE ELSE 0 END) AS polynomial_8_SSE
		,MAX(CASE WHEN degree = '9' THEN SSE ELSE 0 END) AS polynomial_9_SSE
		,MAX(CASE WHEN degree = '10' THEN SSE ELSE 0 END) AS polynomial_10_SSE
from 	iterations 
WHERE 	degree in ('4', '5', '6', '7', '8', '9', '10')
AND current_step <= 10000
GROUP BY current_step
ORDER BY current_step;












;
