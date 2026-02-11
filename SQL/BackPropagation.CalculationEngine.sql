SET search_path TO ai_BackPropagation, public; 

-- The tabular function implements the forward computation. It is the equivalent of the <Engine_step_iesimo> excel table.
--
--                ===                                      =========
-- It returns the SSE, other model metricas and mainly the Gradients for the next iterations
--                ===                                      =========
--                    
-- 
--DROP FUNCTION calculate_step_metrics;
CREATE OR REPLACE FUNCTION calculate_step_metrics(weights FLOAT8[])
RETURNS TABLE(sse FLOAT8, gradients_x_next_iteration FLOAT8[], R2 FLOAT8, MAE FLOAT8, MAPE FLOAT8) 
AS $$

WITH parms AS (
select 
	weights				 		AS weights 
	,array_length(weights, 1) 	AS number_of_weights 
	,weight.index_id			AS weight_id
	,weight.value				AS weight_value
	,(array_length(weights, 1) - weight.index_id) AS exponent
FROM (Select weights AS weights) model_parameters
,UNNEST(weights) WITH ORDINALITY AS weight(value, index_id)
)
, y_predictions AS (
SELECT 
	a.x														AS x
	,a.y													AS y
	,a.x_scaled												AS x_scaled
	,SUM(p.weight_value * POWER(a.x_scaled, p.exponent))	AS y_hat  
FROM actual_data_scaled a, parms p
GROUP BY a.x, a,y, a.x_scaled
)

, predictions_err AS (
SELECT
	x 											AS x
	,x_scaled									AS x_scaled
	,y 											AS y
	,y_hat 										AS y_hat
	,(y_hat - y) 								AS err
	
	,POWER((y_hat - y), 2) 						AS squared_err

	,2 * (y_hat - y) * POWER(x_scaled, exponent)AS local_gradient
	,weight_id 									AS weight_id
	
FROM y_predictions, parms
)

, step_metrics AS (
SELECT DISTINCT
	weight_id
	,SUM(squared_err)  		AS sse
	,AVG(local_gradient)	AS gradient

	,POWER(CORR(y, y_hat),2)AS R2
	,AVG(ABS(err))          AS MAE
	,AVG(ABS(err) / y)      AS MAPE

FROM predictions_err
GROUP BY weight_id
)
select
	sse											AS sse
	,ARRAY_AGG((gradient) ORDER BY weight_id)	AS gradients

	,R2											AS R2
	,MAE										AS MAE
	,MAPE										AS MAPE

from step_metrics
GROUP BY sse, R2, MAE, MAPE
;
$$ LANGUAGE SQL;

-- FUNCTION update_weights computes the new weights from the previous ones, the gradient computed in the previous iteration 
-- and the proper LR weights
CREATE OR REPLACE FUNCTION update_weights(
    p_old_weights FLOAT8[], 
    p_gradients FLOAT8[], 
    p_lr FLOAT8
) 
RETURNS FLOAT8[] AS $$
    SELECT ARRAY(
        SELECT p_old_weights[i] - (p_lr * p_gradients[i])
        FROM generate_subscripts(p_old_weights, 1) AS i
        ORDER BY i -- It's fundamental to link the  weights[i] with the related gradient
    );
$$ LANGUAGE SQL IMMUTABLE;



