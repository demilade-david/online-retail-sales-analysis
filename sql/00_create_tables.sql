CREATE TABLE Online_Retail_Stores(
InvoiceNo VARCHAR(20),
StockCode VARCHAR(20),
Description VARCHAR(100),
Quantity INT,
InvoiceDate TIMESTAMP,
UnitPrice DECIMAL(10,2),
CustomerID VARCHAR(10),
Country VARCHAR(50),
Month Varchar(10),
Revenue DECIMAL(10,2)
);
CREATE TABLE Cancelled_Orders(
InvoiceNo VARCHAR(20),
StockCode VARCHAR(20),
Description VARCHAR(100),
Quantity INT,
InvoiceDate TIMESTAMP,
UnitPrice DECIMAL(10,2),
CustomerID VARCHAR(10),
Country VARCHAR(50)
);