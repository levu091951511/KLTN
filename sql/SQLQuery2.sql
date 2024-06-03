USE dtm_stock;

DECLARE @TableName NVARCHAR(MAX);
DECLARE tableCursor CURSOR FOR
    SELECT TABLE_NAME
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_TYPE = 'BASE TABLE';

OPEN tableCursor;

FETCH NEXT FROM tableCursor INTO @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = 'DROP TABLE ' + @TableName;
    EXEC sp_executesql @SQL;
    
    FETCH NEXT FROM tableCursor INTO @TableName;
END

CLOSE tableCursor;
DEALLOCATE tableCursor;