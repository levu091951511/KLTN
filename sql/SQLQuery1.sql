USE dtm_stock;

CREATE TABLE dim_date (
    dateid INT PRIMARY KEY IDENTITY,
    date DATE,
    year INT,
    quarter INT,
    month INT,
    day INT,
    weekday INT
);

CREATE TABLE dim_indicator (
    indicatorid INT PRIMARY KEY IDENTITY,
    indicatorname VARCHAR(255) NOT NULL,
    description VARCHAR(1000)
);

CREATE TABLE dim_trade_center (
    tradecenterid INT PRIMARY KEY IDENTITY,
    tradecentername VARCHAR(255) NOT NULL
);

CREATE TABLE dim_category (
    categoryid INT PRIMARY KEY IDENTITY,
    categoryname VARCHAR(255) NOT NULL
);

CREATE TABLE dim_stock (
    stocksymbol VARCHAR(10) PRIMARY KEY,
    companyname VARCHAR(255) NOT NULL,
    categoryid INT,
    tradecenterid INT,
    FOREIGN KEY (categoryid) REFERENCES dim_category(categoryid),
    FOREIGN KEY (tradecenterid) REFERENCES dim_trade_center(tradecenterid)
);

CREATE TABLE fact_stock_indicator (
    stock_indicatorid INT PRIMARY KEY IDENTITY,
    stocksymbol VARCHAR(10),
    dateid INT,
    indicatorid INT,
    indicatorvalue DECIMAL(18, 2),
    FOREIGN KEY (stocksymbol) REFERENCES dim_stock(stocksymbol),
    FOREIGN KEY (dateid) REFERENCES dim_date(dateid),
    FOREIGN KEY (indicatorid) REFERENCES dim_indicator(indicatorid)
);

CREATE TABLE fact_price_history (
    pricehistoryid INT PRIMARY KEY IDENTITY,
    stocksymbol VARCHAR(10),
    dateid INT,
    openprice DECIMAL(18, 2),
    closeprice DECIMAL(18, 2),
    highprice DECIMAL(18, 2),
    lowprice DECIMAL(18, 2),
    volume BIGINT,
    FOREIGN KEY (stocksymbol) REFERENCES dim_stock(stocksymbol),
    FOREIGN KEY (dateid) REFERENCES dim_date(dateid)
);

CREATE TABLE fact_evaluation (
    evaluationid INT PRIMARY KEY IDENTITY,
    stocksymbol VARCHAR(10),
    fromdateid INT,
    todateid INT,
    pe DECIMAL(10, 2),
    pb DECIMAL(10, 2),
    industrype DECIMAL(10, 2),
    industrypb DECIMAL(10, 2),
    indexpe DECIMAL(10, 2),
    indexpb DECIMAL(10, 2),
    FOREIGN KEY (stocksymbol) REFERENCES dim_stock(stocksymbol),
    FOREIGN KEY (fromdateid) REFERENCES dim_date(dateid),
    FOREIGN KEY (todateid) REFERENCES dim_date(dateid)
);