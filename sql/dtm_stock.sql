CREATE DATABASE IF NOT EXISTS dtm_stock;

USE dtm_stock;

CREATE TABLE dim_date (
    dateid INT PRIMARY KEY,
    date DATE,
    year INT,
    quarter INT,
    month INT,
    day INT,
    weekday INT
);

CREATE TABLE dim_indicator (
    indicatorid INT PRIMARY KEY,
    indicatorname VARCHAR(255),
    description VARCHAR(1000)
);

CREATE TABLE dim_trade_center (
    tradecenterid INT PRIMARY KEY,
    tradecentername VARCHAR(255)
);

CREATE TABLE dim_category (
    categoryid INT PRIMARY KEY,
    categoryname VARCHAR(255)
);

CREATE TABLE dim_stock (
    stockid INT PRIMARY KEY,
    stocksymbol VARCHAR(10),
    companyname VARCHAR(255),
    categoryid INT,
    tradecenterid INT,
    FOREIGN KEY (categoryid) REFERENCES dim_category(categoryid),
    FOREIGN KEY (tradecenterid) REFERENCES dim_trade_center(tradecenterid)
);

CREATE TABLE fact_stock_indicator (
    stock_indicatorid INT PRIMARY KEY,
    stockid INT,
    dateid INT,
    indicatorid INT,
    indicatorvalue DECIMAL(18, 2),
    FOREIGN KEY (stockid) REFERENCES dim_stock(stockid),
    FOREIGN KEY (dateid) REFERENCES dim_date(dateid),
    FOREIGN KEY (indicatorid) REFERENCES dim_indicator(indicatorid)
);

CREATE TABLE fact_price_history (
    pricehistoryid INT PRIMARY KEY,
    stockid INT,
    dateid INT,
    openprice DECIMAL(18, 2),
    closeprice DECIMAL(18, 2),
    highprice DECIMAL(18, 2),
    lowprice DECIMAL(18, 2),
    volume BIGINT,
    FOREIGN KEY (stockid) REFERENCES dim_stock(stockid),
    FOREIGN KEY (dateid) REFERENCES dim_date(dateid)
);

CREATE TABLE fact_evaluation (
    evaluationid INT PRIMARY KEY,
    stockid INT,
    fromdateid INT,
    todateid INT,
    pe DECIMAL(10, 2),
    pb DECIMAL(10, 2),
    industrype DECIMAL(10, 2),
    industrypb DECIMAL(10, 2),
    indexpe DECIMAL(10, 2),
    indexpb DECIMAL(10, 2),
    FOREIGN KEY (stockid) REFERENCES dim_stock(stockid),
    FOREIGN KEY (fromdateid) REFERENCES dim_date(dateid),
    FOREIGN KEY (todateid) REFERENCES dim_date(dateid)
);
