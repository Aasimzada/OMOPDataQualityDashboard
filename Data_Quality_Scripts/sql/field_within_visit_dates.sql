/*********
FIELD LEVEL check:
WITHIN_VISIT_DATES - find events that occur one week before the corresponding visit_start_date or one week after the corresponding visit_end_date

Parameters used in this template:
schema = @schema
cdmTableName = @cdmTableName
cdmFieldName = @cdmFieldName

**********/


SELECT num_violated_rows,
  CASE
    WHEN denominator.num_rows = 0 THEN 0 
    ELSE 1.0*num_violated_rows/denominator.num_rows
  END AS pct_violated_rows,
  denominator.num_rows AS num_denominator_rows
FROM (
	SELECT 
	  COUNT_BIG(violated_rows.violating_field) AS num_violated_rows
	FROM (
		/*violatedRowsBegin*/
		SELECT 
		  '@cdmTableName.@cdmFieldName' AS violating_field, 
		  cdmTable.*
    FROM @schema.@cdmTableName cdmTable
      
      JOIN  @schema.visit_occurrence vo
      ON cdmTable.visit_occurrence_id = vo.visit_occurrence_id
    WHERE cdmTable.@cdmFieldName < dateadd(day, -7, vo.visit_start_date)
      OR cdmTable.@cdmFieldName > dateadd(day, 7, vo.visit_end_date)
		/*violatedRowsEnd*/
	) violated_rows
) violated_row_count,
(
	SELECT 
	  COUNT_BIG(*) AS num_rows
	FROM @schema.@cdmTableName cdmTable
	  
    JOIN @schema.visit_occurrence
    ON cdmTable.visit_occurrence_id = vo.visit_occurrence_id
) denominator
;
