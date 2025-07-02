--- Total de receitas no ano de 1997
SELECT SUM(od.quantity * od.unit_price * (1.0 - od.discount)) AS TOTAL_REV FROM order_details od
JOIN (
	SELECT order_id FROM orders o
	WHERE EXTRACT(YEAR FROM order_date) = '1997'
) AS ord
ON od.order_id = ord.order_id;


--- Análise do crescimento mensal e o cálculo de YTD
WITH ReceitasMensais as (
	SELECT 
		EXTRACT(YEAR FROM o.order_date) as Ano, 
		EXTRACT(MONTH FROM o.order_date) as Mes, 
		SUM(od.quantity * od.unit_price * (1.0 - od.discount)) AS Total_rev
	FROM order_details od
	INNER JOIN orders o ON o.order_id = od.order_id
	GROUP BY 
		EXTRACT(YEAR FROM o.order_date),
		EXTRACT(MONTH FROM o.order_date)
),
ReceitasAcumuladas as (
	SELECT
		Ano,
		Mes,
		Total_rev,
		SUM(Total_rev) OVER (PARTITION BY Ano ORDER BY Mes) AS Total_rev_YTD
	FROM
		ReceitasMensais
)
SELECT
	Ano,
	Mes,
	Total_rev,
	Total_rev - LAG(Total_rev) OVER (PARTITION BY Ano ORDER BY MES) AS Diff_mensal,
	(Total_rev - LAG(Total_rev) OVER (PARTITION BY Ano ORDER BY MES)) / LAG(Total_rev) OVER (PARTITION BY Ano ORDER BY Mes) * 100 AS Perc_diff_mensal
FROM ReceitasAcumuladas
ORDER BY Ano, Mes

