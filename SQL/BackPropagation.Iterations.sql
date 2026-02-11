SET search_path TO ai_BackPropagation, public; 


--======================================================================================================================================
-- You can change the Degree of the polynomial adding or removing a value in the <weights> array. 
-- A <weights> array with 2 values means a first-degree polynomial o linear polynomial
-- A <weights> array with 3 values means a second-degree polynomial o quadratic polynomial
-- ...
-- A <weights> array with (n + 1) values means a polynomial of degree n o n-th degree polynomial
UPDATE 	model_parameters 
   SET 	max_iterations 	= 5000, 
		weights 		= ARRAY[0.1, 0.1, 0.1, 0.1, 18.0] -- [a, b, c, d, intercept/bias] - A fourth-degree polynomial is initialized with 5 weights
--		weights 		= ARRAY[0.1, 0.1, 0.1, 0.1, 0.1, 18.0] -- A fifth-degree polynomial is initialized with 6 weights
;


--======================================================================================================================================


-- Setting the LR low means a model prudent but slow in learning, otherwise the risk to have a model learning nothing is high
-- It's suggested the set up for the first steps a low LR, and raise the LR as the #steps increase 
DELETE FROM learning_rate_scheduler;
INSERT INTO learning_rate_scheduler
SELECT    0,    50, 0.01 UNION ALL
SELECT   51,   200, 0.05 UNION ALL
SELECT  201,   450, 0.07 UNION ALL
SELECT  451, 10000, 0.07 
;
--/*
DELETE FROM learning_rate_scheduler;
INSERT INTO learning_rate_scheduler
SELECT    0,   200, 0.01 UNION ALL
SELECT  201,   240, 0.01 UNION ALL
SELECT  241,  1000, 0.01 UNION ALL
SELECT 1001, 10000, 0.01 
;
--*/

-- 
-- ========================================================================================================================================
--
-- The recursive CTE <iterations> implemts the iterations of the backpropagation algorithm: from the iteration 0 to the model_parameters.max_iterations
-- The update_weights function computes the core of the backpropagation
-- ========================================================================================================================================
WITH RECURSIVE iterations (
	current_step								--NUMERIC
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
	0											AS current_step
	,p.weights									AS weights
	,current_metrics.sse						AS sse
	,current_metrics.gradients_x_next_iteration	AS gradients_x_next_iteration
	,p.max_iterations							AS max_iterations

	,current_metrics.R2							AS R2
	,current_metrics.MAE						AS MAE
	,current_metrics.MAPE						AS MAPE
	
FROM model_parameters p
CROSS JOIN LATERAL calculate_step_metrics(p.weights) current_metrics

UNION ALL

SELECT
	prev.current_step + 1						AS current_step
	,current_iteration.new_weights				AS weights
	,current_metrics.sse						AS sse
	,current_metrics.gradients_x_next_iteration	AS gradients_x_next_iteration
	,prev.max_iterations						AS max_iterations

	,current_metrics.R2							AS R2
	,current_metrics.MAE						AS MAE
	,current_metrics.MAPE						AS MAPE
	
FROM iterations prev
LEFT OUTER JOIN learning_rate_scheduler lr ON (prev.current_step BETWEEN lr.from_step AND lr.to_step)
CROSS JOIN LATERAL (
        SELECT update_weights(prev.weights, prev.gradients_x_next_iteration, COALESCE(lr.lr, 0.01)) AS new_weights
    ) current_iteration
CROSS JOIN LATERAL calculate_step_metrics(current_iteration.new_weights) current_metrics
WHERE prev.current_step < prev.max_iterations
)

SELECT 
	current_step					AS current_step
	,ROUND(sse::NUMERIC, 2) 		AS SSE
	,weights						AS weights
	
	,ROUND((R2 * 100)::NUMERIC, 2)	AS R2
	,ROUND((MAE)::NUMERIC, 2)		AS MAE
	,ROUND((MAPE * 100)::NUMERIC, 2)AS MAPE

from iterations
ORDER BY current_step
;
