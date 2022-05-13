/*==============================================================*/
/* Lab 8     : Data Warehouse & BI                              */
/* Name      : Srilekha Sampath kumar                           */
/* Student ID: 8699606				                            */
/*==============================================================*/


USE master;  --Use Master Database
GO  

--Create WonderfulWheels database, if exist, drop existing databse before creating a new one.

IF DB_ID (N'WonderfulWheels') IS NOT NULL  
DROP DATABASE WonderfulWheels;  
GO  
CREATE DATABASE WonderfulWheels 
GO
--UseWonderfulWheels Database from now on.
USE WonderfulWheels;
GO


--Table Creation
/*==============================================================*/
/* Table: Location                                              */
/*==============================================================*/
CREATE TABLE [Location] (
   LocationID	int identity(1,1)	NOT NULL,
   StreeAddress	nvarchar(100)	NOT NULL,
   City			nvarchar(50)	NOT NULL,
   Province		char(2)			NOT NULL,
   PostalCode	char(7)			NOT NULL,
   CONSTRAINT PK_LOCATION PRIMARY KEY (LocationID)
)
GO


/*==============================================================*/
/* Table: Dealership                                            */
/*==============================================================*/
CREATE TABLE Dealership (
   DealershipID	int IDENTITY(1,1)	NOT NULL,
   LocationID	int					NOT NULL,
   DealerName	nvarchar(50)		NOT NULL,
   Phone		nvarchar(20)		      NULL,
   CONSTRAINT PK_DEALERSHIP PRIMARY KEY (DealershipID),
   CONSTRAINT FK_DEAL_LOC FOREIGN KEY (LocationID) REFERENCES Location (LocationID)
)
GO

/*==============================================================*/
/* Table: Person                                                */
/*==============================================================*/
CREATE TABLE Person (
   PersonID		int IDENTITY(1000,1)	NOT NULL,
   FirstName	nvarchar(50)	NOT NULL,
   LastName		nvarchar(50)	NOT NULL,
   Phone		nvarchar(20)	NULL,
   Email		nvarchar(100)	NULL,
   PerLocID	int				NOT NULL,
   DateofBirth	date			NULL,
   Title		char(2)			NULL,
   CONSTRAINT PK_PERSON PRIMARY KEY (PersonID),
   CONSTRAINT FK_PER_LOC FOREIGN KEY (PerLocID) REFERENCES Location (LocationID),
   CONSTRAINT CHK_TITLE	CHECK (Title='Mr' OR Title ='Ms')	
)
GO

/*==============================================================*/
/* Index: IndexPersonName                                       */
/*==============================================================*/
CREATE INDEX IndexPersonName ON Person ( FirstName ASC, LastName ASC)


/*==============================================================*/
/* Table: Customer                                              */
/*==============================================================*/
CREATE TABLE Customer (
   CustomerID		int				NOT NULL,
   RegDate			date			NOT NULL,
   CONSTRAINT PK_CUSTOMER PRIMARY KEY (CustomerID),
   CONSTRAINT FK_CUS_PER FOREIGN KEY (CustomerID) REFERENCES Person (PersonID)
)
GO

/*==============================================================*/
/* Table: Employee                                              */
/*==============================================================*/
CREATE TABLE Employee (
   EmployeeID		int				NOT NULL,
   EmpDealID		int				NOT NULL,
   HireDate			date			NOT NULL,
   EmpRole			nvarchar(50)	NOT NULL,
   ManagerID		int				NULL, 
   CONSTRAINT PK_EMPLOYEE PRIMARY KEY (EmployeeID),
   CONSTRAINT FK_EMP_PER FOREIGN KEY (EmployeeID) REFERENCES Person (PersonID),
   CONSTRAINT FK_EMP_DEAL FOREIGN KEY (EmpDealID) REFERENCES Dealership (DealershipID),
   CONSTRAINT FK_PER_MAN FOREIGN KEY (ManagerID) REFERENCES Employee (EmployeeID)
)
GO

/*==============================================================*/
/* Table: SalaryEmployee                                        */
/* Set Salary to Default 1000 since Check contraint should      */
/* not be less than 1000										*/
/*==============================================================*/
CREATE TABLE SalaryEmployee (
   EmployeeID		int				NOT NULL,
   Salary			decimal(12,2)	NOT NULL DEFAULT 1000.00,
   CONSTRAINT PK_SALEMPLOYEE PRIMARY KEY (EmployeeID),
   CONSTRAINT FK_SEMP_EMP FOREIGN KEY (EmployeeID) REFERENCES Employee (EmployeeID),
   CONSTRAINT CHK_SALARY	CHECK (Salary>=1000)
)
GO

/*==============================================================*/
/* Table: CommissionEmployee                                    */
/* Set Commission to Default 10 since Check contraint should    */
/* not be less than 10  										*/
/*==============================================================*/
CREATE TABLE CommissionEmployee (
   EmployeeID		int				NOT NULL,
   Commission		decimal(12,2)	NOT NULL DEFAULT 10.00,
   CONSTRAINT PK_COMEMPLOYEE PRIMARY KEY (EmployeeID),
   CONSTRAINT FK_CEMP_EMP FOREIGN KEY (EmployeeID) REFERENCES Employee (EmployeeID),
   CONSTRAINT CHK_COMMISSION	CHECK (Commission>=10)
)
GO

/*==============================================================*/
/* Table: Vehicle                                               */
/* Set Price to Default 1 since Check contraint should          */
/* not be less than 1											*/
/* Set VehicleYear Check contraint to be greater than 1800      */
/* and less than current year to capture appropriate Year   	*/
/*==============================================================*/

CREATE TABLE Vehicle (
   VehicleID	int	IDENTITY(100001,1)			NOT NULL,
   Make			nvarchar(50)	NOT NULL,
   Model		nvarchar(50)	NOT NULL,
   VehicleYear	int			NOT NULL,
   Colour		nvarchar(10)	NOT NULL,
   KM			int				NOT NULL,
   Price		decimal(12,2)	NULL DEFAULT 1.00,
   CONSTRAINT PK_VEHICLE PRIMARY KEY (VehicleID),
   CONSTRAINT CHK_PRICE	CHECK (Price>=1),
   CONSTRAINT CHK_YEAR	CHECK (VehicleYear>=1800 AND VehicleYear <= YEAR(GETDATE()))

)
GO

/*==============================================================*/
/* Table: VehicleOrder                                          */
/*==============================================================*/
CREATE TABLE [Order] (
   OrderID		int IDENTITY(1,1)	NOT NULL,
   OrderCustID	int				NOT NULL,
   OrderEmpID	int				NOT NULL,
   OrderDate	date			NOT NULL DEFAULT GetDate(),
   OrderDealID	int				NOT NULL,
   CONSTRAINT PK_ORDER PRIMARY KEY (OrderID),
   CONSTRAINT FK_ORD_CUST FOREIGN KEY (OrderCustID) REFERENCES Customer (CustomerID),
   CONSTRAINT FK_ORD_EMP FOREIGN KEY (OrderEmpID) REFERENCES Employee (EmployeeID),
   CONSTRAINT FK_ORD_DEAL FOREIGN KEY (OrderDealID) REFERENCES Dealership (DealershipID)
)
GO


/*==============================================================*/
/* Table: VOrderItem                                            */
/* Set FinalSalePrice to Default 1 since Check contraint should */
/* not be less than 1											*/
/*==============================================================*/
CREATE TABLE OrderItem (
   OrderID			int		NOT NULL,
   VehicleID		int		NOT NULL,
   FinalSalePrice	decimal(12,2)	NULL DEFAULT 1.00,
   CONSTRAINT PK_ORDERITEM PRIMARY KEY (OrderID, VehicleID),
   CONSTRAINT FK_ORDITM_ORD FOREIGN KEY (OrderID) REFERENCES [Order] (OrderID),
   CONSTRAINT FK_ORDITM_VEHICLE FOREIGN KEY (VehicleID) REFERENCES Vehicle (VehicleID),
   CONSTRAINT CHK_FINALSALEPRICE	CHECK (FinalSalePrice>=1)

)
GO

/*==============================================================*/
/* Table: Account                                               */
/*==============================================================*/
CREATE TABLE Account (
   AccountID			int	IDENTITY(1,1)	NOT NULL,
   CustomerID			int		NOT NULL,
   AccountBalance		decimal(12,2)	NOT NULL DEFAULT 0.00,
   LastPaymentAmount	decimal(12,2)	NOT NULL DEFAULT 0.00,
   LastPaymentDate		date	NULL,
   CONSTRAINT PK_ACCOUNT PRIMARY KEY (AccountID),
   CONSTRAINT FK_ACC_CUST FOREIGN KEY (CustomerID) REFERENCES Customer (CustomerID),
   CONSTRAINT CHK_BALANCE	CHECK (AccountBalance>=0),
   CONSTRAINT CHK_AMOUNT	CHECK (LastPaymentAmount>=0)

)
GO

/*==============================================================*/
/* Creating Error log table in WonderfulWheels Database         */
/*==============================================================*/

		
		CREATE TABLE dbo.DbErrorLog
		(UserName VARCHAR(200), 
		ErrorNumber INT, 
		ErrorState INT, 
		ErrorSeverity INT, 
		ErrorLine INT, 
		ErrorProcedure VARCHAR(max), 
		ErrorMessage VARCHAR(max));
		


--- Transaction to insert new data into the above created tables



/*==============================================================*/
/* 1. Inserting values into location Table                      */
/*==============================================================*/		


		INSERT INTO dbo.Location ([StreeAddress],[City],[Province],[PostalCode])
		VALUES
		('221 Kitng St W', 'Kitchner', 'ON', 'G8B3C6'),
		('77 Victoria St N', 'Campbridge', 'ON', 'N1Z8B8'),
		('100 White Oak Rd', 'London', 'ON', 'L9B1W2'),
		('22 Queen St', 'Waterloo', 'ON', 'N2A48B'),
		('44 King St', 'Guelph', 'ON', 'G2A47U'),
		('55 Krug St', 'Kitchener', 'ON', 'N2A4U7'),
		('77 Lynn Ct', 'Toronto', 'ON', 'M7U4BA'),
		('88 King St', 'Guelph', 'ON', 'G2A47U'),
		('99 Lynn Ct', 'Toronto', 'ON', 'M7U4BA'),
		('44 Cedar St', 'Kitchener', 'ON', 'N2A7L6');
		

SELECT * from Location;


/*==============================================================*/
/* 2. Inserting values into Vehicle Table                       */
/*==============================================================*/


		INSERT INTO dbo.Vehicle ([Make],[Model],[VehicleYear],[Colour],[KM],[Price])
		VALUES
		('Toyota', 'Corola', '2018', 'Silver', '45000', '18000'),
		('Toyota', 'Corola', '2016', 'White', '60000', '15000'),
		('Toyota', 'Corola', '2016', 'Black', '65000', '14000'),
		('Toyota', 'Camry', '2018', 'White', '35000', '22000'),
		('Honda', 'Acord', '2020', 'Gray', '10000', '24000'),
		('Honda', 'Acord', '2015', 'Red', '85000', '16000'),
		('Honda', 'Acord', '2000', 'Gray', '10000', '40000'),
		('Ford', 'Focus', '2017', 'Blue', '40000', '16000');

SELECT * from Vehicle;


/*==============================================================*/
/* 3. Inserting values into Person Table                        */
/*==============================================================*/


		INSERT INTO dbo.Person ([FirstName],[LastName],[Phone],[Email],[PerLocID],[DateofBirth],[Title])
		VALUES
		('John', 'Smith', '519-444-3333', 'jsmtith@email.com',
		(SELECT LocationID from Location WHERE StreeAddress = '22 Queen St'), '1968-04-09', 'Mr'),

		('Mary', 'Brown', '519-888-3333', 'mbrown@email.com',
		(SELECT LocationID from Location WHERE StreeAddress = '44 King St'), '1972-02-04', 'Ms'),

		('Tracy', 'Spencer', '519-888-2222', 'tspencer@email.com', 
		(SELECT LocationID from Location WHERE StreeAddress = '55 Krug St'), '1998-07-22', 'Ms'),

		('James', 'Stewart', '416-888-1111', 'jstewart@email.com', 
		(SELECT LocationID from Location WHERE StreeAddress = '77 Lynn Ct'),'1996-11-22', 'Mr'),

		('Paul', 'Newman', '519-888-4444', 'pnewman@email.com', 
		(SELECT LocationID from Location WHERE StreeAddress = '55 Krug St'),'1992-09-23', 'Mr'),

		('Tom', 'Cruise', '519-333-2222', 'tcruise@email.com', 
		(SELECT LocationID from Location WHERE StreeAddress = '55 Krug St'),'1962-03-22', 'Mr'),

		('Bette', 'Davis', '519-452-1111', 'bdavis@email.com', 
		(SELECT LocationID from Location WHERE StreeAddress = '88 King St'),'1952-09-01', 'Ms'),

		('Grace', 'Kelly', '416-887-2222', 'gkelly@email.com', 
		(SELECT LocationID from Location WHERE StreeAddress = '99 Lynn Ct'),'1973-06-09', 'Ms'),

		('Doris', 'Day', '519-888-5456', 'dday@email.com', 
		(SELECT LocationID from Location WHERE StreeAddress = '44 Cedar St'),'1980-05-25', 'Ms');


SELECT * from Person;


/*==============================================================*/
/* 4. Inserting values into Dealership Table                    */
/*==============================================================*/


		INSERT INTO dbo.Dealership ([LocationID],[DealerName],[Phone])
		VALUES
		((SELECT LocationID from Location WHERE StreeAddress = '221 Kitng St W'),
		'Kitchner', '324-456-2345'),

		((SELECT LocationID from Location WHERE StreeAddress = '77 Victoria St N'),
		'Campbridge', '980-768-6789'),

		((SELECT LocationID from Location WHERE StreeAddress = '100 White Oak Rd'),
		'London', '546-675-1122');

SELECT * from Dealership;


/*==============================================================*/
/* 5. Inserting values into Employee Table                      */
/*==============================================================*/


		INSERT INTO [dbo].[Employee]([EmployeeID],[EmpDealID],[HireDate],[EmpRole])
		VALUES ((SELECT PersonID FROM Person 
				WHERE FirstName='John' and LastName='Smith' and DateofBirth='1968-04-09'),
				(SELECT DealershipID from Dealership WHERE DealerName='Kitchner' and Phone='324-456-2345'),
				'1992-04-09','Manager');

		INSERT INTO [dbo].[Employee]([EmployeeID],[EmpDealID],[HireDate],[EmpRole],[ManagerID])
		VALUES ((SELECT PersonID FROM Person 
				WHERE FirstName='Mary' and LastName='Brown' and DateofBirth='1972-02-04'),
				(SELECT DealershipID from Dealership WHERE DealerName='Kitchner' and Phone='324-456-2345'),
				'1995-06-15','Office Admin',
				(SELECT EmployeeID from Employee WHERE EmployeeID = (SELECT PersonID FROM Person 
				WHERE FirstName='John' and LastName='Smith' and DateofBirth='1968-04-09'))),

				((SELECT PersonID FROM Person 
				WHERE FirstName='Tracy' and LastName='Spencer' and DateofBirth='1998-07-22'),
				(SELECT DealershipID from Dealership WHERE DealerName='Kitchner' and Phone='324-456-2345'),
				'2017-02-24','Sales',
				(SELECT EmployeeID from Employee WHERE EmployeeID = (SELECT PersonID FROM Person 
				WHERE FirstName='John' and LastName='Smith' and DateofBirth='1968-04-09'))),

				((SELECT PersonID FROM Person 
				WHERE FirstName='James' and LastName='Stewart' and DateofBirth='1996-11-22'),
				(SELECT DealershipID from Dealership WHERE DealerName='Kitchner' and Phone='324-456-2345'),
				'2017-04-16','Sales',
				(SELECT EmployeeID from Employee WHERE EmployeeID = (SELECT PersonID FROM Person 
				WHERE FirstName='John' and LastName='Smith' and DateofBirth='1968-04-09'))),

				((SELECT PersonID FROM Person 
				WHERE FirstName='Paul' and LastName='Newman' and DateofBirth='1992-09-23'),
				(SELECT DealershipID from Dealership WHERE DealerName='Kitchner' and Phone='324-456-2345'),
				'2016-03-23','Sales',
				(SELECT EmployeeID from Employee WHERE EmployeeID = (SELECT PersonID FROM Person 
				WHERE FirstName='John' and LastName='Smith' and DateofBirth='1968-04-09')));

SELECT * from Employee;


/*==============================================================*/
/* 6. Inserting values into SalaryEmployee Table                */
/*==============================================================*/
 

		INSERT INTO dbo.SalaryEmployee ([EmployeeID],[Salary])
		VALUES ((SELECT EmployeeID from Employee 
				WHERE EmployeeID = (SELECT PersonID FROM Person 
				WHERE FirstName='John' and LastName='Smith' and DateofBirth='1968-04-09')), 95000),

				((SELECT EmployeeID from Employee 
				WHERE EmployeeID = (SELECT PersonID FROM Person 
				WHERE FirstName='Mary' and LastName='Brown' and DateofBirth='1972-02-04')), 65000);

SELECT * from SalaryEmployee;


/*==============================================================*/
/* 7. Inserting values into CommissionEmployee Table            */
/*==============================================================*/


		INSERT INTO dbo.CommissionEmployee ([EmployeeID],[Commission])
		VALUES ((SELECT EmployeeID from Employee 
				WHERE EmployeeID = (SELECT PersonID FROM Person 
				WHERE FirstName='Tracy' and LastName='Spencer' and DateofBirth='1998-07-22')), 13),

				((SELECT EmployeeID from Employee 
				WHERE EmployeeID = (SELECT PersonID FROM Person 
				WHERE FirstName='James' and LastName='Stewart' and DateofBirth='1996-11-22')), 15),

				((SELECT EmployeeID from Employee 
				WHERE EmployeeID = (SELECT PersonID FROM Person 
				WHERE FirstName='Paul' and LastName='Newman' and DateofBirth='1992-09-23')), 10);

SELECT * from CommissionEmployee;


/*==============================================================*/
/* 8. Inserting values into Customer Table                      */
/*==============================================================*/
 

		INSERT INTO dbo.Customer ([CustomerID],[RegDate])
		VALUES ((SELECT PersonID FROM Person 
				WHERE FirstName='Tom' and LastName='Cruise' and DateofBirth='1962-03-22'), '2001-04-23'),

				((SELECT PersonID FROM Person 
				WHERE FirstName='Bette' and LastName='Davis' and DateofBirth='1952-09-01'), '1999-10-06'),

				((SELECT PersonID FROM Person 
				WHERE FirstName='Tracy' and LastName='Spencer' and DateofBirth='1998-07-22'), '2014-09-30'),

				((SELECT PersonID FROM Person 
				WHERE FirstName='Grace' and LastName='Kelly' and DateofBirth='1973-06-09'), '1991-04-22'),

				((SELECT PersonID FROM Person 
				WHERE FirstName='Doris' and LastName='Day' and DateofBirth='1980-05-25'), '2018-08-07');

SELECT * from Customer;


/*==============================================================*/
/* 9. Inserting values into Order Table                         */
/*==============================================================*/
 

		INSERT INTO [Order] 
		VALUES ((SELECT CustomerID FROM Customer 
				WHERE CustomerID=(SELECT PersonID FROM Person 
				WHERE FirstName='Tom' and LastName='Cruise' and DateofBirth='1962-03-22')),
				(SELECT EmployeeID from Employee 
				WHERE EmployeeID=(SELECT PersonID FROM Person 
				WHERE FirstName='Tracy' and LastName='Spencer' and DateofBirth='1998-07-22')), '2019-07-11',
				(SELECT DealershipID from Dealership WHERE DealerName='Kitchner' and Phone='324-456-2345'));

		INSERT INTO [Order] 
		VALUES ((SELECT CustomerID FROM Customer 
				WHERE CustomerID=(SELECT PersonID FROM Person 
				WHERE FirstName='Bette' and LastName='Davis' and DateofBirth='1952-09-01')),
				(SELECT EmployeeID from Employee 
				WHERE EmployeeID=(SELECT PersonID FROM Person 
				WHERE FirstName='Tracy' and LastName='Spencer' and DateofBirth='1998-07-22')), '2019-06-10',
				(SELECT DealershipID from Dealership WHERE DealerName='Kitchner' and Phone='324-456-2345'));


		INSERT INTO [Order] 
		VALUES ((SELECT CustomerID FROM Customer 
				WHERE CustomerID=(SELECT PersonID FROM Person 
				WHERE FirstName='Tracy' and LastName='Spencer' and DateofBirth='1998-07-22')),
				(SELECT EmployeeID from Employee 
				WHERE EmployeeID=(SELECT PersonID FROM Person 
				WHERE FirstName='James' and LastName='Stewart' and DateofBirth='1996-11-22')), '2019-02-03',
				(SELECT DealershipID from Dealership WHERE DealerName='Kitchner' and Phone='324-456-2345'));

SELECT * from [Order];


/*==============================================================*/
/* 10. Inserting values into OrderItem Table                    */
/*==============================================================*/
 

		INSERT INTO [dbo].[OrderItem] ([OrderID],[VehicleID],[FinalSalePrice])
		VALUES ((SELECT OrderID FROM [Order] WHERE OrderCustID=(SELECT CustomerID FROM Customer
				WHERE CustomerID=(SELECT PersonID FROM Person
				WHERE FirstName='Tom' and LastName='Cruise' and DateofBirth='1962-03-22'))),
				(SELECT VehicleID FROM Vehicle
				WHERE Make='Toyota' and Model='Corola' and VehicleYear=2018 and Colour='Silver' and Km=45000), 17500),

				((SELECT OrderID FROM [Order] WHERE OrderCustID=(SELECT CustomerID FROM Customer
				WHERE CustomerID=(SELECT PersonID FROM Person
				WHERE FirstName='Tom' and LastName='Cruise' and DateofBirth='1962-03-22'))),
				(SELECT VehicleID FROM Vehicle
				WHERE Make='Toyota' and Model='Camry' and VehicleYear=2018 and Colour='White' and Km=35000), 21000),

				((SELECT OrderID FROM [Order] WHERE OrderCustID=(SELECT CustomerID FROM Customer
				WHERE CustomerID=(SELECT PersonID FROM Person
				WHERE FirstName='Bette' and LastName='Davis' and DateofBirth='1952-09-01'))),
				(SELECT VehicleID FROM Vehicle
				WHERE Make='Ford' and Model='Focus' and VehicleYear=2017 and Colour='Blue' and Km=40000), 15000),

				((SELECT OrderID FROM [Order] WHERE OrderCustID=(SELECT CustomerID FROM Customer
				WHERE CustomerID=(SELECT PersonID FROM Person
				WHERE FirstName='Tracy' and LastName='Spencer' and DateofBirth='1998-07-22'))),
				(SELECT VehicleID FROM Vehicle
				WHERE Make='Honda' and Model='Acord' and VehicleYear=2015 and Colour='Red' and Km=85000), 15000);


SELECT * from OrderItem;



/*=====================================================================*/
/* Creating WonderfulWheels Data Warehouse                             */
/*=====================================================================*/


USE master;  --Use Master Database


--Create WonderfulWheelsDW data warehouse, if exist, drop existing databse before creating a new one.

IF DB_ID (N'WonderfulWheelsDW') IS NOT NULL  
DROP DATABASE WonderfulWheelsDW;  
 
CREATE DATABASE WonderfulWheelsDW 

--UseWonderfulWheels Database from now on.
USE WonderfulWheels;


-- Create and Load CommissionEmployee dimension table
	
	SELECT 		
		IDENTITY(INT,1,1) AS EmployeeSK,
		CE.EmployeeID AS EmployeeAK,
		P.Title,
		P.FirstName,
		P.LastName,
		P.DateofBirth,
		P.Phone,
		P.Email,
		E.HireDate,
		E.EmpRole,
		CE.Commission,
		CONCAT(M.FirstName,' ', M.LastName) AS Manager
	INTO [WonderfulWheelsDW].[dbo].[Dim_CommissionEmployee]
	FROM [dbo].[CommissionEmployee] AS CE
		JOIN [dbo].[Employee] AS E ON E.EmployeeID = CE.EmployeeID
		JOIN  [dbo].[Person] AS P on P.PersonID = CE.EmployeeID
		JOIN [dbo].[Employee] AS E2 ON E2.EmployeeID = E.ManagerID
		JOIN  [dbo].[Person] AS M on M.PersonID = E2.EmployeeID


	--Alter the table to make EmployeeSK the Primary Key
	ALTER TABLE [WonderfulWheelsDW].[dbo].[Dim_CommissionEmployee]
	ADD CONSTRAINT PK_DimCommissionEmployee
	PRIMARY KEY (EmployeeSK)

	-- Test 
	SELECT * FROM [WonderfulWheelsDW].[dbo].[Dim_CommissionEmployee]




-- Create and Load Customer dimension table
	
	SELECT 		
		IDENTITY(INT,1,1) AS CustomerSK,
		C.CustomerID AS CustomerAK,
		P.Title,
		P.FirstName,
		P.LastName,
		P.DateofBirth,
		P.Phone,
		P.Email,
		C.RegDate
	INTO [WonderfulWheelsDW].[dbo].[Dim_Customer]
	FROM [dbo].[Customer] AS C
		JOIN  [dbo].[Person] AS P on P.PersonID = C.CustomerID



	--Alter the table to make CustomerSK the Primary Key
	ALTER TABLE [WonderfulWheelsDW].[dbo].[Dim_Customer]
	ADD CONSTRAINT PK_DimCustomer
	PRIMARY KEY (CustomerSK)


	-- Test 
	SELECT * FROM [WonderfulWheelsDW].[dbo].[Dim_Customer]



-- Create and Load Vehicle dimension table
CREATE TABLE [WonderfulWheelsDW].[dbo].[Dim_Vehicle] (
   VehicleSK	int	IDENTITY(1,1)			NOT NULL,
   VehicleAK	int NOT NULL,
   Make			nvarchar(50)	NOT NULL,
   Model		nvarchar(50)	NOT NULL,
   VehicleYear	int				NOT NULL,
   Colour		nvarchar(10)	NOT NULL,
   KM			int				NOT NULL,
   Price		decimal(12,2)	NULL,
   CONSTRAINT PK_DimVehicle PRIMARY KEY (VehicleSK))

	INSERT INTO [WonderfulWheelsDW].[dbo].[Dim_Vehicle] (VehicleAK, Make, Model, VehicleYear, Colour, KM, Price)
	SELECT
		VehicleID,
		Make,
		Model,
		VehicleYear,
		Colour,
		KM,
		Price 
	FROM [dbo].[Vehicle]

	SELECT * FROM [WonderfulWheelsDW].[dbo].[Dim_Vehicle] --Test the code



-- Create and Load Dealership dimension table	
	SELECT 		
		IDENTITY(INT,1,1) AS DealershipSK,
		DealershipID AS DealershipAK,
		DealerName,
		Phone,
		L.StreeAddress,
		L.City,
		L.Province,
		L.PostalCode
	INTO [WonderfulWheelsDW].[dbo].[Dim_Dealership]
	FROM [dbo].[Dealership] AS D
	JOIN [Location] AS L ON L.LocationID = D.LocationID

	--Alter the table to make DealershipSK the Primary Key
	ALTER TABLE [WonderfulWheelsDW].[dbo].[Dim_Dealership]
	ADD CONSTRAINT PK_DimDealership
	PRIMARY KEY (DealershipSK)


	-- Test 
	SELECT * FROM [WonderfulWheelsDW].[dbo].[Dim_Dealership]


-- Create and Load Date dimension table
declare @StartDate date
declare @EndDate date
declare @TempDate date
set @StartDate = '1990-01-01'	-- Set this to whatever date you like to begin with
set @EndDate = '2049-12-31'	-- Set this to your final date. No date in your systems should exceed this value

declare @Counter int
declare @NumberOfDays int

set @Counter = 0
set @NumberOfDays = datediff(dd,@StartDate,@EndDate)

if not exists (select * from sys.tables where name = 'Dim_Date')

begin
create table [WonderfulWheelsDW].[dbo].[Dim_Date] ( DateSK int not null, [Date] date not null, StandardDate varchar(10) not null,
FullDate varchar(50) not null, [Year] int not null, [Month] tinyint not null, [MonthName] varchar(10) not null,
[Day] tinyint not null, [DayOfWeek] tinyint not null, [DayName] varchar(10) not null, WeekOfYear tinyint not null,
[DayOfYear] smallint not null, CalendarQuarter tinyint not null);
end



-- Insert Inferred Member
insert [WonderfulWheelsDW].[dbo].[Dim_Date] (
	DateSK,[Date],StandardDate,FullDate,
	[Year],[Month],[MonthName],[Day],[DayOfWeek],[DayName],
	WeekOfYear,[DayOfYear],CalendarQuarter) values (
	19000101,'1900-01-01','01/01/1900','January 1, 1900',
	1900,1,'January',1,2,'Monday',
	1,1,1);


set @TempDate = @StartDate
while @Counter <= @NumberOfDays
begin
insert [WonderfulWheelsDW].[dbo].[Dim_Date] (
	DateSK, [Date], StandardDate, FullDate, [Year], [Month], [MonthName], [Day], [DayOfWeek], [DayName], WeekOfYear, [DayOfYear], CalendarQuarter ) 
select year(@TempDate) * 10000 + month(@TempDate) * 100 + day(@TempDate) as DateSK,
	cast(@TempDate as date) as [Date], convert(varchar,@TempDate,101) as StandardDate,
	datename(mm,@TempDate) + ' ' + cast(day(@TempDate) as varchar(2)) + ', ' + cast(year(@TempDate) as char(4)) as FullDate,
	year(@TempDate) as [Year], month(@TempDate) as [Month], datename(mm,@TempDate) as [MonthName], day(@TempDate) as [Day],
	datepart(dw,@TempDate) as [DayOfWeek], datename(dw,@TempDate) as [DayName], datepart(wk,@TempDate) as WeekOfYear, datepart(dy,@TempDate) as [DayOfYear],
	case	when month(@TempDate) between 1 and 3 then 1
			when month(@TempDate) between 4 and 6 then 2
			when month(@TempDate) between 7 and 9 then 3
			when month(@TempDate) between 10 and 12 then 4
	end as CalendarQuarter

	set @Counter = @Counter + 1
	set @TempDate = DateAdd(dd,1,@TempDate)

end
if not exists (
select * from sys.indexes
where object_name(object_id) = 'Dim_Date'
and type_desc = 'CLUSTERED')
begin
-- Add PK/Clustered Index
alter table [WonderfulWheelsDW].[dbo].[Dim_Date]
add constraint PK_Dim_Date primary key clustered(DateSK);
end

 ---Test
SELECT * FROM [WonderfulWheelsDW].[dbo].[Dim_Date]


-- Create and Load FactSales Fact table
	SELECT DISTINCT 
		O.OrderID, -- This will become the first PK (Since OrderItem table have composite PK)
		OI.VehicleID, --This will become the second PK (Since OrderItem table have composite PK)
		ROW_NUMBER() OVER(PARTITION BY O.OrderID ORDER BY OI.OrderID, OI.VehicleID) AS OrderItemID,
		CAST (REPLACE (O.OrderDate,'-','') AS int) AS OrderDateSK,
		E.EmployeeSK,
		C.CustomerSK,
		V.VehicleSK,
		D.DealershipSK,
		OI.FinalSalePrice,
		CAST((Commission*FinalSalePrice) AS decimal(12,2)) AS CommissionAmount
	INTO [WonderfulWheelsDW].[dbo].[Fact_Sales]
	FROM [dbo].[Order] AS O
	JOIN [dbo].[OrderItem] AS OI ON OI.OrderID= O.OrderID
	LEFT JOIN [WonderfulWheelsDW].[dbo].[Dim_CommissionEmployee] as E ON E.EmployeeAK=O.OrderEmpID
	LEFT JOIN [WonderfulWheelsDW].[dbo].[Dim_Customer] as C ON C.CustomerAK=O.OrderCustID
	LEFT JOIN [WonderfulWheelsDW].[dbo].[Dim_Vehicle]as V ON V.VehicleAK=OI.VehicleID
	LEFT JOIN [WonderfulWheelsDW].[dbo].[Dim_Dealership] AS D ON D.DealershipAK=O.OrderDealID

	ALTER TABLE [WonderfulWheelsDW].[dbo].[Fact_Sales]
	ALTER COLUMN OrderItemID INT NOT NULL


SELECT * FROM [WonderfulWheelsDW].[dbo].[Fact_Sales]





	--Alter the table to make OrderID and VehicleID the Primary Key
	ALTER TABLE [WonderfulWheelsDW].[dbo].[Fact_Sales]
	ADD CONSTRAINT PK_FactSales
	PRIMARY KEY (OrderID, OrderItemID)

    --Alter the table to make DelaershipSK the Foreign Key
	ALTER TABLE [WonderfulWheelsDW].[dbo].[Fact_Sales]
	ADD CONSTRAINT FK_FactSales_DimDealership
	FOREIGN KEY (DealershipSK) REFERENCES Dim_Dealership(DealershipSK)


    --Alter the table to make CustomerSK the Foreign Key
	ALTER TABLE [WonderfulWheelsDW].[dbo].[Fact_Sales]
	ADD CONSTRAINT FK_FactSales_DimCustomer
	FOREIGN KEY (CustomerSK) REFERENCES Dim_Customer(CustomerSK)


	--Alter the table to make EmployeeSK the Foreign Key
	ALTER TABLE [WonderfulWheelsDW].[dbo].[Fact_Sales]
	ADD CONSTRAINT FK_FactSales_DimCommissionEmployee
	FOREIGN KEY (EmployeeSK) REFERENCES Dim_CommissionEmployee(EmployeeSK)


	--Alter the table to make VehicleSK the Foreign Key
	ALTER TABLE [WonderfulWheelsDW].[dbo].[Fact_Sales]
	ADD CONSTRAINT FK_FactSales_DimVehicle
	FOREIGN KEY (VehicleSK) REFERENCES Dim_Vehicle(VehicleSK)


--Alter the table to make OrderItemSK the Foreign Key
	ALTER TABLE [WonderfulWheelsDW].[dbo].[Fact_Sales]
	ADD CONSTRAINT FK_FactSales_DimDate
	FOREIGN KEY (OrderDateSK) REFERENCES [WonderfulWheelsDW].[dbo].[Dim_Date](DateSK)


	-- Test 
	SELECT * FROM [WonderfulWheelsDW].[dbo].[Fact_Sales]





--Create main view that is used to display data in report and test it.
-- exec spGetEmployeeSales '','',null,null

USE WonderfulWheelsDW; -- use the warehous DB


Create view dbo.vwGetEmployeeSales
as 		
select  e.FirstName,
e.LastName,
(e.FirstName+ ' '+ e.LastName) as [EmployeeName],
e.Email,
(datediff(year,e.DateOfBirth,getdate())) as age, 
(datediff(year,e.HireDate,getdate())) as [YearsOfService],
e.Commission as [CommissionPercentage],
isnull(CAST(f.CommissionAmount AS VARCHAR),'')as [SaleCommission],
isnull((c.FirstName+ ' ' + c.LastName),'') as [CustomerName],
isnull(c.RegDate , '')as RegistrationDate, 
isnull(c.Title,'')as Title,
isnull(d.DealerName,'')as DealershipName,
isnull(d.StreeAddress,'' )as StreetAddress,
isnull(d.City,'')as CityName,
isnull(d.Province,'')as ProvinceName,
isnull(v.Make,'')as Make,
isnull(v.Model,'')as Model,
isnull(v.VehicleYear,'') as [MakeYear],
isnull(v.KM,'')as KM,
isnull(CAST(v.Price AS VARCHAR),'')as Price,
isnull(CAST(FinalSalePrice AS VARCHAR),'')as FinalSalePrice,
isnull(dt.Year,'')as Year,
isnull(dt.CalendarQuarter,'')as CalendarQuarter,
isnull(dt.Month,'')as Month
from [WonderfulWheelsDW].[dbo].[Dim_CommissionEmployee] as e
left join [WonderfulWheelsDW].[dbo].[Fact_Sales] as f on e.EmployeeSK=f.EmployeeSK
left join [WonderfulWheelsDW].[dbo].[Dim_Customer] as c on c.CustomerSK=f.CustomerSK
left join [WonderfulWheelsDW].[dbo].[Dim_Dealership] as d on d.DealershipSK= f.DealershipSK
left join [WonderfulWheelsDW].[dbo].[Dim_Vehicle] as v on v.VehicleSK=f.VehicleSK
left join [WonderfulWheelsDW].[dbo].[Dim_Date] as dt on dt.DateSK=f.OrderDateSK

--Test view dbo.vwGetEmployeeSales 
use [WonderfulWheelsDW]


declare @FirstName varchar(50),
		@LastName varchar(50),
		@Year int,
		@Month int
		set @FirstName=''
		set @LastName=''
		set @Year = null
		set @Month = null


		select * from dbo.vwGetEmployeeSales 
		where(FirstName=@FirstName or @FirstName='')
		and (LastName=@LastName or @LastName='')
		and (Year=@Year or @Year is null)
		and (Month=@Month or @Month is null)
		ORDER BY FirstName, LastName



--Create main stored procedure and test it. Screen shot should include stored procedure and test. 
-- exec dbo.spGetEmployeeSales '','',null,null
CREATE procedure dbo.spGetEmployeeSales
(
		@FirstName varchar(50),
		@LastName varchar(50),
		@Year int,
		@Month int
)
		as 
		

		select * 
		from dbo.vwGetEmployeeSales 
		where(FirstName LIKE '%' + @FirstName + '%' or @FirstName='')
		and (LastName  LIKE '%'+ @LastName + '%' or @LastName='')
		and (Year=@Year or @Year is null)
		and (Month=@Month or @Month is null)
		ORDER BY FirstName, LastName



--Year for dropdown list
select distinct null as value, 'All' as Label, 0 as sortOrder
union
select Distinct [year] as value, cast([Year] as varchar(4)) as Label,1
from [dbo].[Dim_Date]
order by sortOrder, Label

--months for dropdown list
select distinct null as value, 'All' as Label, 0 as sortOrder
union
select Distinct [Month] as value, cast([Month] as varchar(2)) as Label,1
from [dbo].[Dim_Date]
order by sortOrder, Label

