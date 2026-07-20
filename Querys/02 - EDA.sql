-- EDA

USE CustomerChurnDB;

-- Perguntas a serem respondidas:
/* 
- Qual a taxa geral de churn?
- Clientes novos cancelam mais? 
- Qual tipo de contrato apresenta maior taxa de churn? 
- Qual faixa etária apresenta maior taxa de cancelamentos?
- Qual método de pagamento apresenta maior taxa de cancelamentos?
- O gênero influencia no cancelamento?
- Clientes com pagamentos mensais mais altos cancelam mais?
- Qual a média de tempo até cancelarem ? 
- Qual impacto mensal financeiro do churn?
- Quais clientes apresentam perfil que podem indicar um possível churn futuro?
*/

SELECT * FROM Customers;

-- 1. Qual a taxa geral de churn?

SELECT 
	FORMAT(100.0 * SUM(CASE
					WHEN Churn = 'Yes' THEN 1
					ELSE 0
					END)/COUNT(*),'N') + '%' AS 'Taxa de Churn'
FROM Customers;

-- Taxa de churn de 33,14%

-- 2.Qual grupo de clientes tem maior probabilidade de cancelar?  
SELECT
	CASE
		WHEN Tenure <= 12 THEN 'Até 1 ano'
		WHEN Tenure <= 24 THEN 'Até 2 anos'
		ELSE 'Mais de 2 anos'
	END AS 'Faixa Tenure',
	COUNT(*) AS 'Qtd.Clientes',
	FORMAT(100.0 * SUM(CASE
					WHEN Churn = 'Yes' THEN 1
					ELSE 0
					END)/COUNT(*),'N') + '%' AS 'Taxa de Churn',
	SUM(CASE
			WHEN Churn = 'Yes' THEN 1
			ELSE 0
		END) AS 'Qtd. Churn'
FROM Customers
GROUP BY CASE
		WHEN Tenure <= 12 THEN 'Até 1 ano'
		WHEN Tenure <= 24 THEN 'Até 2 anos'
		ELSE 'Mais de 2 anos'
	END
	ORDER BY [Faixa Tenure];

-- Qual a média e mediana de tempo até cancelarem ?

-- média
SELECT
    AVG(CAST(Tenure AS DECIMAL(10,2))) AS Media
FROM Customers
WHERE Churn = 'Yes';

-- mediana
SELECT DISTINCT
	CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Tenure) OVER () AS DECIMAL(10,2)) AS 'Mediana'
FROM Customers
WHERE Churn = 'Yes';

-- Clientes com apenas 1 ano de empresa possuem a maior taxa% de churn, ou seja clientes com menos tempo de empresa tem maiores chances de cancelarem. Porém entre os clientes que cancelaram o tempo médio até cancelarem foi de 30,88 meses e a mediana de 28 meses, sugerindo que o churn também ocorre entre os clientes mais antigos.

-- 3.Qual tipo de contrato apresenta maior taxa de churn?

SELECT
	Contract,
	COUNT(*) AS 'Qtd.Clientes',
	FORMAT(100.0 * SUM(CASE
					WHEN Churn = 'Yes' THEN 1
					ELSE 0
					END)/COUNT(*),'N') + '%' AS 'Taxa de Churn',
	SUM(CASE
			WHEN Churn = 'Yes' THEN 1
			ELSE 0
		END) AS 'Qtd. Churn'
FROM Customers
GROUP BY Contract
ORDER BY [Taxa de Churn];

-- Clientes com contratos Month-to-Month possuem a maior taxa de churn 46.55%, sendo quase 3 vezes maior em relação aos contratos One year e Two year, com 16.74% e 16.87%. Ou seja, clientes com contratos mais longos são muito mais propensos a serem fidelizados.

-- 4.Qual faixa etária apresenta maior taxa de cancelamentos?

SELECT 
	CASE	
		WHEN Age BETWEEN 18 AND 30 THEN '18-30 anos'
		WHEN Age BETWEEN 31 AND 50 THEN '31-50 anos'
		WHEN Age BETWEEN 51 AND 70 THEN '51-70 anos'
		ELSE '70 +' 
	END AS 'Faixa Etária',
	COUNT(*) AS 'Qtd.Clientes',
	FORMAT(100.0 * SUM(CASE
					WHEN Churn = 'Yes' THEN 1
					ELSE 0
					END)/COUNT(*),'N') + '%' AS 'Taxa de Churn',
	SUM(CASE
			WHEN Churn = 'Yes' THEN 1
			ELSE 0
		END) AS 'Qtd. Churn'
FROM	
	Customers
GROUP BY 
	CASE	
		WHEN Age BETWEEN 18 AND 30 THEN '18-30 anos'
		WHEN Age BETWEEN 31 AND 50 THEN '31-50 anos'
		WHEN Age BETWEEN 51 AND 70 THEN '51-70 anos'
		ELSE '70 +' 
	END 
ORDER BY [Taxa de Churn] DESC;

-- a maior taxa de cancelamentos está entre os clientes de 18-30 anos, porém a diferença entre a faixa etária que mais cancelou e a que menos cancelou, 70+, é de apenas 1%, o que nos diz que a idade não interfere na taxa de churn, todas as faixas etárias se encontram com uma taxa próxima a 33%. As causas de churn se encontram em outras variantes.


-- 5.Qual método de pagamento apresenta maior taxa de cancelamentos?

SELECT
	PaymentMethod,
	FORMAT(100.0 * SUM(CASE
					WHEN Churn = 'Yes' THEN 1
					ELSE 0
					END)/COUNT(*),'N') + '%' AS 'Taxa de Churn',
	COUNT(*) AS 'Qtd.Clientes'
FROM 
	Customers
GROUP BY PaymentMethod
ORDER BY [Taxa de Churn] DESC;

-- assim como por faixa etária, as taxas de churn entre os diferentes tipos de pagamentos são praticamente iguais, o que também nos indica que o tipo de pagamento não intefere no churn.

-- 6.O gênero influencia no cancelamento?
SELECT
	Gender,
	FORMAT(100.0 * SUM(CASE
					WHEN Churn = 'Yes' THEN 1
					ELSE 0
					END)/COUNT(*),'N') + '%' AS 'Taxa de Churn',
	COUNT(*) AS 'Qtd.Clientes'
FROM 
	Customers
GROUP BY Gender
ORDER BY [Taxa de Churn] DESC;

-- o genero não influencia na taxa de churn

-- 7.Clientes com pagamentos mensais mais altos cancelam mais?

SELECT 
	MIN(MonthlyCharges) AS 'Min.Pag.Mensal',
	MAX(MonthlyCharges) AS 'Max.Pag.Mensal',
	AVG(MonthlyCharges) AS 'Avg.Pag.Mensal'
FROM
	Customers;

SELECT
	CASE
		WHEN MonthlyCharges <= 50 THEN 'Baixo'
		WHEN MonthlyCharges <= 100 THEN 'Médio'
		ELSE 'Alto'
	END AS 'MonthlyCharges',
	FORMAT(100.0 * SUM(CASE
					WHEN Churn = 'Yes' THEN 1
					ELSE 0
					END)/COUNT(*),'N') + '%' AS 'Taxa de Churn',
	COUNT(*) AS 'Qtd. Clientes',
	SUM(CASE
					WHEN Churn = 'Yes' THEN 1
					ELSE 0
					END) AS 'Qtd. Churn'
FROM	
	Customers
GROUP BY CASE
		WHEN MonthlyCharges <= 50 THEN 'Baixo'
		WHEN MonthlyCharges <= 100 THEN 'Médio'
		ELSE 'Alto'
	END
ORDER BY [Taxa de Churn] DESC;

-- pagamentos mensais mais altos(a partir de 100) possuem a maior taxa de churn,52.46%, sendo praticamente 2 vezes maior que pagamentos médios(até 100) e pagamentos baixos(até 50).


-- Qual impacto mensal financeiro do churn?

SELECT
	FORMAT(SUM(MonthlyCharges), 'N') AS 'Total Pagamentos Mensais Com Churn'
FROM Customers
WHERE Churn = 'Yes';

SELECT
	FORMAT(SUM(MonthlyCharges), 'N') AS 'Total Pagamentos Mensais Sem Churn'
FROM Customers
WHERE Churn = 'No';

-- Quanto do percentual mensal representa no faturamento ? 

SELECT
	FORMAT(SUM(CASE
				WHEN Churn = 'Yes' THEN MonthlyCharges
				ELSE 0 
			END), 'N') AS 'Total Perdido Mensalmente',
	FORMAT(100.0 * SUM(CASE
			WHEN Churn = 'Yes' THEN MonthlyCharges
			ELSE 0
		END)/SUM(MonthlyCharges), 'N') + '%' AS '% Sobre Faturamento Mensal'
FROM Customers;

-- Quais clientes apresentam perfil que podem indicar um possível churn futuro?
-- clientes com tenure <= 31 meses
-- com contratos month-to-month
-- com monthlycharges > 100

SELECT
	* 
FROM Customers
WHERE Tenure <= 31 AND Contract = 'Month-to-month' AND MonthlyCharges > 100 AND Churn = 'No';

-- 1.908 clientes possuem perfil crítico, muito propenso a cancelarem seus contratos.