-- arrays range and the open and closed samples

SELECT 
	INT4RANGE(1,6)  AS "[) closed-open",
	NUMRANGE(1.4258,2.5412 ,'[]') AS "[]- closed-closed",
	DATERANGE('20250101', '20251231', '()') AS "()-open-open starts from the 2025-01-02",
	TSRANGE(LOCALTIMESTAMP,LOCALTIMESTAMP + INTERVAL '8 DAYS ','(]') AS "(] open-close"

--Constructing array

SELECT 
	ARRAY[1,2,3] AS INT_ARRAY,
	ARRAY[1.224567::FLOAT] AS single_float_value,
	ARRAY[1.233, 2.336, 4.566] :: FLOAT[] AS FLOATING_ARRAY,
	ARRAY[CURRENT_DATE,CURRENT_DATE + 5] AS date_array

--using operators in arrays returns boolean

SELECT 
	ARRAY[1,2,3,4] = ARRAY[1,2,3,4] AS equality,
	ARRAY[1,2,3] = ARRAY[4,5,6] AS equality,
	ARRAY[1,2,3] > ARRAY[4,5,6] AS greaterthan,
	ARRAY[1,2,3] < ARRAY[4,5,6] AS lessthan,
	ARRAY[1,2,3] >= ARRAY[4,5,6] AS greaterthan_equalto,
	ARRAY[1,2,3] <= ARRAY[4,5,6] AS lessthan_equalto,
	ARRAY[1,2,3] != ARRAY[4,5,6] AS notqualto;


-- contains operator in arrays

SELECT 
	INT4RANGE(1,4) @> INT4RANGE (2,3) AS "Contains",
	1 <@ INT4RANGE(1,2) AS"Contaioned by"
	