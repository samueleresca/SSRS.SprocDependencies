-- =============================================
-- Author:Resca Samuele
-- Description: Returns names of stored procedure that are used in report
-- =============================================
CREATE PROCEDURE [dbo].[ReportSPROCDependencies]
    @ReportName nvarchar(max) = NULL
AS
BEGIN
    SET NOCOUNT ON;
 
        ;WITH XMLNAMESPACES (
        DEFAULT
        --IMPORTANT(!)   There are different namespaces for every version of Sql server.
        'http://schemas.microsoft.com/sqlserver/reporting/2010/01/reportdefinition',
        'http://schemas.microsoft.com/SQLServer/reporting/reportdesigner' AS rd
        )
        SELECT DISTINCT
        Name,
        Path,
        xmldoc.value('CommandType[1]', 'VARCHAR(50)') AS CommandType,
        xmldoc.value('CommandText[1]','VARCHAR(100)') AS StoredProcedreName
        FROM (
        select name, path,
        CAST(CAST(content AS VARBINARY(MAX)) AS XML) AS reportXML
        from ReportServer.dbo.Catalog
        ) tmp
        CROSS APPLY reportXML.nodes('/Report/DataSets/DataSet/Query') r(xmldoc)
        WHERE xmldoc.value('CommandType[1]', 'VARCHAR(50)') = 'StoredProcedure'
        AND (@ReportName LIKE '%'+@ReportName+'%' OR @ReportName IS NULL)
END