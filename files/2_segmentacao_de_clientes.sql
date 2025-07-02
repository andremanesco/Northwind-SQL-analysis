--- Total pago por cliente
SELECT 
	c.customer_id,
	c.contact_name,
	SUM(od.unit_price * od.quantity * (1.0 - od.discount))
FROM 
	customers c
INNER JOIN 
	orders o ON c.customer_id = o.customer_id
INNER JOIN
	order_details od ON o.order_id = od.order_id
GROUP BY
	c.customer_id, c.contact_name

--- Separando clientes de acordo com o total pago
WITH 
    TotalPagoPorCliente AS (
        SELECT 
            c.customer_id,
            c.contact_name,
            SUM(od.unit_price * od.quantity * (1.0 - od.discount)) AS total
        FROM 
            customers c
        INNER JOIN 
            orders o ON c.customer_id = o.customer_id
        INNER JOIN
            order_details od ON o.order_id = od.order_id
        GROUP BY
            c.customer_id, c.contact_name
        ORDER BY
            total
        )
SELECT 
	customer_id,
	contact_name,
	total,
	NTILE(5) OVER (ORDER BY total DESC) AS grupo
FROM
	TotalPagoPorCliente
ORDER BY
	total DESC