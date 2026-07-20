USE CustomerChurnDB;

SELECT * FROM Customers;

-- fazer:
-- coluna de faixa de tenure (Até 1 ano, Até 2 anos, Mais de 2 anos)
-- coluna de faixa de pagamento mensal (Até 50 - Baixo, Até 100 - Médio, Maior 100 - Alto)
-- coluna de faixa de risco de cancelamento
-- coluna de faixa etária
-- não levar coluna TotalCharges

GO
CREATE OR ALTER VIEW Churn_Dashboards AS
SELECT
	CustomerID,
	Age,
	Gender,
	Tenure,
	MonthlyCharges,
	Contract,
	Churn,
	CASE
		WHEN Tenure <= 12 THEN 'Até 1 ano'
		WHEN Tenure <= 24 THEN 'Até 2 anos'
		ELSE 'Mais de 2 anos'
	END AS 'Faixa Tenure',
	CASE
		WHEN MonthlyCharges <= 50 THEN 'Até $50'
		WHEN MonthlyCharges <= 100 THEN 'Até $100'
		ELSE 'Maior $100'
	END AS 'Faixa MonthlyCharges',
	CASE 
		WHEN Tenure <= 31 AND Contract = 'Month-to-month' AND MonthlyCharges > 100 AND Churn = 'No' THEN 'Alto Risco'
		WHEN Churn = 'Yes' THEN 'Churn Realizado'
		ELSE 'Baixo Risco'
	END AS 'Risco de Churn',
	CASE	
		WHEN Age BETWEEN 18 AND 30 THEN '18-30 anos'
		WHEN Age BETWEEN 31 AND 50 THEN '31-50 anos'
		WHEN Age BETWEEN 51 AND 70 THEN '51-70 anos'
		ELSE '70 +' 
	END AS 'Faixa Etária'
FROM Customers;
GO 

SELECT * FROM Churn_Dashboards;