-- PROJETO: Identificando os fatores associados ao cancelamento de clientes.
-- Etapa: Criando o banco de dados, importando tabela e limpeza de dados.

CREATE DATABASE CustomerChurnDB;

USE CustomerChurnDB;


-- LIMPEZA DE DADOS

-- 1.Primeiro select para conhecer a tabela 

SELECT 
	*
FROM Customers;

-- 2.Verificando os tipos de dados

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Customers';

-- CustomerID e Tenure se encontram como VARCHAR, nos impossibilitando de realizar cálculos nas respectivas colunas, mudaremos as duas colunas para INT.

-- Alterando a coluna Tenura para INT
ALTER TABLE Customers
ALTER COLUMN Tenure INT;

-- A coluna customerID não permite ser alterada pois é uma primary key, para conseguir alterar vamos remover a constraint primary key, alterar a coluna e novamente adicionar a constraint.

-- Removendo a constraint
ALTER TABLE Customers
DROP CONSTRAINT PK_Customers;

--Alterando a coluna para int
ALTER TABLE Customers
ALTER COLUMN CustomerID INT NOT NULL;

-- Adicionando novamente a constraint
ALTER TABLE Customers
ADD CONSTRAINT PK_Customers
PRIMARY KEY(CustomerID);

-- Colunas alteradas para INT
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Customers';

-- Os valores monetários não estão com seus separadores decimais corretos, então ajustaremos isso dividindo o valor de cada linha por 100.

BEGIN TRANSACTION

UPDATE Customers
SET MonthlyCharges = MonthlyCharges / 100.0,
	TotalCharges = TotalCharges / 100.0;

SELECT
    CustomerID,
    MonthlyCharges,
	TotalCharges 
FROM Customers
ORDER BY CustomerID;

COMMIT TRANSACTION;

-- 3.Verificando se existem duplicatas
SELECT 
	CustomerID,
	COUNT(*)
FROM 
	Customers
GROUP BY CustomerID
HAVING COUNT(*) > 1;

-- Verificando se existem duplicatas nas demais colunas

SELECT 
	Age,Gender,Tenure,MonthlyCharges,Contract,PaymentMethod,TotalCharges,Churn,
	COUNT(*)
FROM 
	Customers
GROUP BY Age,Gender,Tenure,MonthlyCharges,Contract,PaymentMethod,TotalCharges,Churn
HAVING COUNT(*) > 1;

-- Não existem.

-- 4.Vamos verificar quais os valores distintos de cada coluna e se existem valores inválidos e nulos.

SELECT DISTINCT CustomerID FROM Customers;
SELECT DISTINCT Age FROM Customers; -- MUITOS
SELECT DISTINCT Gender FROM Customers;
SELECT DISTINCT Tenure FROM Customers; -- MUITOS
SELECT DISTINCT MonthlyCharges FROM Customers; -- MUITOS
SELECT DISTINCT Contract FROM Customers;
SELECT DISTINCT PaymentMethod FROM Customers;
SELECT DISTINCT TotalCharges FROM Customers;
SELECT DISTINCT Churn FROM Customers;

-- Os valores parecem válidos, porém as colunas Age, Tenure, MonthlyCharges e TotalCharges possuem muitos valores distintos, então vamos analisar coluna por coluna.

-- Procurando valores nulos nessas colunas
SELECT 
	Age,
	Tenure, 
	MonthlyCharges,
	TotalCharges
FROM Customers
WHERE Age IS NULL OR Tenure IS NULL OR MonthlyCharges IS NULL;
-- Não encontrados.

-- Procurando caracteres estranhos 
SELECT 
	Age,
	Tenure, 
	MonthlyCharges,
	TotalCharges
FROM Customers
WHERE Age LIKE '%^0-9%' OR Tenure LIKE '%^0-9%' OR MonthlyCharges LIKE '%^0-9%';
-- Não encontrados.

-- Procurando valores negativos
SELECT 
	*
FROM Customers
WHERE Age < 0 OR Tenure < 0 OR MonthlyCharges < 0 OR TotalCharges <0;

-- Existem 265 linhas onde os valores da coluna TotalCharges são negativos. A regra matemática dessa base de dados é, Tenure * MonthCharges = TotalCharges, sabendo disso, iremos atualizar os negativos com o resultado da regra matemática.

BEGIN TRANSACTION;

UPDATE Customers
SET TotalCharges = Tenure * MonthlyCharges
WHERE TotalCharges < 0;

SELECT 
	*
FROM Customers
WHERE TotalCharges <0;

COMMIT TRANSACTION;

-- Valores negativos alteradas.

-- Ainda que os valores de TotalCharges deveriam ser Tenure * MonthCharges, podemos notar que os valores não batem 100%, apenas 269 linhas correspondem exatamente, isso porque essa é uma base de dados gerada artificialmente e um pequeno ruído foi atribuido aos valores. Esses ruídos poderiam representar muitos fatores, como, juros,descontos, mudanças de tipo de contrato, etc, por esse motivo, manteremos os ruídos e deixaremos os valores como estão.

-- Linhas correspondentes a Tenure * MonthlyCharges
SELECT
	*
FROM 
	Customers
WHERE TotalCharges = Tenure * MonthlyCharges



-- Os dados parecem todos de acordo, as únicas mudanças necessárias foram:
-- alterar os tipos de dados da coluna CustomerID e Tenure de VARCHAR para INT
-- ajuste nas casas decimais das colunas MonthlyCharges e TotalCharges
-- alterar os valores negativos da coluna TotalCharges.
-- inconsistencia matemática entre as colunas Tenure, MonthlyCharges e TotalCharges, mas os dados foram mantidos sem alteração pois outros fatores podem interferir no resultado de TotalCharges