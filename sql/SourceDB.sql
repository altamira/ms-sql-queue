USE [master]
GO
/****** Object:  Database [SourceDB]    Script Date: 21/09/2015 12:03:34 ******/
CREATE DATABASE [SourceDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'SourceDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\SourceDB.mdf' , SIZE = 4160KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'SourceDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\SourceDB_log.ldf' , SIZE = 2880KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [SourceDB] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [SourceDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [SourceDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [SourceDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [SourceDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [SourceDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [SourceDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [SourceDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [SourceDB] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [SourceDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [SourceDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [SourceDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [SourceDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [SourceDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [SourceDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [SourceDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [SourceDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [SourceDB] SET  ENABLE_BROKER 
GO
ALTER DATABASE [SourceDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [SourceDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [SourceDB] SET TRUSTWORTHY ON 
GO
ALTER DATABASE [SourceDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [SourceDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [SourceDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [SourceDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [SourceDB] SET RECOVERY FULL 
GO
ALTER DATABASE [SourceDB] SET  MULTI_USER 
GO
ALTER DATABASE [SourceDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [SourceDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [SourceDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [SourceDB] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'SourceDB', N'ON'
GO
USE [SourceDB]
GO
/****** Object:  User [NT SERVICE\SSBExternalActivator]    Script Date: 21/09/2015 12:03:34 ******/
CREATE USER [NT SERVICE\SSBExternalActivator] FOR LOGIN [NT SERVICE\SSBExternalActivator] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [NT SERVICE\SSBExternalActivator]
GO
/****** Object:  StoredProcedure [dbo].[MANUFACTURING_BOM]    Script Date: 21/09/2015 12:03:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MANUFACTURING_BOM] (@order AS INT)
AS
BEGIN
 
    SET NOCOUNT ON;
 
    DECLARE @message    AS NVARCHAR(MAX)
 
    SET @message = (SELECT STUFF(
	(SELECT     
		',{"number":' + CAST(GPIMAC_Altamira.dbo.LPV.LPPED AS VARCHAR(MAX)) 
		+ ',"customer":"' + LTRIM(RTRIM(UPPER(ISNULL(GPIMAC_Altamira.dbo.CACLI.CCNOM, '')))) + '"'
		+ ',"representative":"' + LTRIM(RTRIM(UPPER(ISNULL(GPIMAC_Altamira.dbo.CAREP.CVNOM, '')))) + '"'
		+ ',"created":"' + LTRIM(RTRIM(ISNULL(CONVERT(NVARCHAR, GPIMAC_Altamira.dbo.LPV.LPENT, 127), ''))) /*'1410895028676'*/ + '"'
		+ ',"delivery":"' + LTRIM(RTRIM(ISNULL(CONVERT(NVARCHAR, GPIMAC_Altamira.dbo.LPV.LP0SAIRED, 127), ''))) /*'1410895028676'*/ + '"'
		+ ',"quotation":"' + GPIMAC_Altamira.dbo.LPV.LPWBCCADORCNUM + '"'
		+ ',"comment":"' + 
				CASE WHEN LTRIM(RTRIM(ISNULL(GPIMAC_Altamira.dbo.LPV.LPObsOP, ''))) <> '' THEN 'PRODUÇÃO: ' + REPLACE(REPLACE(REPLACE(REPLACE(UPPER(LTRIM(RTRIM(ISNULL(GPIMAC_Altamira.dbo.LPV.LPObsOP, '')))), CHAR(10), ''), CHAR(13), ' '), CHAR(39), ''), CHAR(34), '') ELSE '' END + 
				CASE WHEN LTRIM(RTRIM(ISNULL(GPIMAC_Altamira.dbo.LPV.LPObsInt, ''))) <> '' THEN 'PEDIDO: ' + REPLACE(REPLACE(REPLACE(REPLACE(UPPER(LTRIM(RTRIM(ISNULL(GPIMAC_Altamira.dbo.LPV.LPObsInt, '')))), CHAR(10), ''), CHAR(13), ' '), CHAR(39), ''), CHAR(34), '') ELSE '' END + 
				CASE WHEN LTRIM(RTRIM(ISNULL(GPIMAC_Altamira.dbo.LPV.LPObsNF, ''))) <> '' THEN 'FATURAMENTO: ' + REPLACE(REPLACE(REPLACE(REPLACE(UPPER(LTRIM(RTRIM(ISNULL(GPIMAC_Altamira.dbo.LPV.LPObsNF, '')))), CHAR(10), ''), CHAR(13), ' '), CHAR(39), ''), CHAR(34), '') ELSE '' END + '"',
		+ ',"finish":"' + LTRIM(RTRIM(UPPER(GPIMAC_Altamira.dbo.CAACAB.CAc0Nom))) + '"'
		+ ',"project":' + CAST(GPIMAC_Altamira.dbo.LPV.LPPED AS VARCHAR(MAX)) 
		+ ',"item":' + '[' + STUFF(
		(SELECT DISTINCT
			',{"item":' + CAST(ISNULL(WBCCAD.dbo.INTEGRACAO_ORCITM.ORCITM, 0) AS VARCHAR(MAX)) 
			+ ',"description":"' + REPLACE(REPLACE(UPPER(LTRIM(RTRIM(LEFT(ISNULL(WBCCAD.dbo.INTEGRACAO_ORCITM.ORCTXT,'ITEM 0'), ISNULL(CHARINDEX(' Valor total líquido:', WBCCAD.dbo.INTEGRACAO_ORCITM.ORCTXT), LEN('ITEM 0')))))), CHAR(39), ''), CHAR(34), '') + '"'
			--ISNULL(WBCCAD.dbo.INTEGRACAO_ORCITM.ORCPRDQTD, 0) AS quantity, 
			--LTRIM(RTRIM(ISNULL(WBCCAD.dbo.INTEGRACAO_ORCITM.ORCPRDCOD, ''))) AS code, 
			--ISNULL(WBCCAD.dbo.INTEGRACAO_ORCITM.GRPCOD, 0) AS [group], 
			--ISNULL(WBCCAD.dbo.INTEGRACAO_ORCITM.SUBGRPCOD, 0) AS subgroup,
			+ ',"component":' + '[' + STUFF(
			(SELECT
				(SELECT
					  --ISNULL([GRPCOD], 0) AS [group]
					  --,ISNULL([SUBGRPCOD], 0) AS subgroup
					  --,ISNULL([ORCITM], 0) AS item
					  ',{"material":{"id":0,"code":"' + LTRIM(RTRIM(UPPER(ISNULL([WBCCAD].[dbo].[PRDORC].[PRODUTO], '')))) + '"'
					  + ',"description":"' + REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(UPPER(ISNULL([WBCCAD].[dbo].[PRDORC].[DESCRICAO], '')))), CHAR(10), '\\n'), CHAR(13), '\\r'), CHAR(39), '\\'''), CHAR(34), '\\"') + '"}'
					  + ',"code":"' + LTRIM(RTRIM(UPPER(ISNULL([WBCCAD].[dbo].[INTEGRACAO_ORCPRD].[PRDCOD], '')))) + '"' 
					  + ',"description":"' + REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(UPPER(ISNULL(MIN([WBCCAD].[dbo].[INTEGRACAO_ORCPRD].[PRDDSC]), '')))), CHAR(10), '\\n'), CHAR(13), '\\r'), CHAR(39), '\\'''), CHAR(34), '\\"') + '"' 
					  + ',"color": ' + 
					  (SELECT TOP 1
							'{"id":' + CAST([INTEGRACAO].dbo.[CM_COLOR].[ID] AS NVARCHAR) 
							+ ',"code":"' + LTRIM(RTRIM([INTEGRACAO].dbo.[CM_COLOR].[CODE])) + '"' 
							+ ',"name":"' + LTRIM(RTRIM([INTEGRACAO].dbo.[CM_COLOR].[NAME])) + '"'
							+ '}'
						FROM 
							[INTEGRACAO].dbo.[CM_COLOR]
						WHERE 
							[INTEGRACAO].dbo.[CM_COLOR].[CODE] = MIN([CORCOD])
						FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
					  + ',"quantity":{"value": ' + CONVERT(VARCHAR(50), SUM(ISNULL([WBCCAD].[dbo].[INTEGRACAO_ORCPRD].[ORCQTD], 0)), 128) + ',"unit":' + 
					  (SELECT TOP 1
							'{"id":' + CAST([INTEGRACAO].dbo.[MS_UNIT].[ID] AS NVARCHAR) 
							+ ',"name":"' + LTRIM(RTRIM([INTEGRACAO].dbo.[MS_UNIT].[NAME])) + '"'
							+ ',"symbol":"' + LTRIM(RTRIM([INTEGRACAO].dbo.[MS_UNIT].[SYMBOL])) + '"'
							+ '}'
						FROM 
							[INTEGRACAO].dbo.[MS_UNIT]
						WHERE 
							[INTEGRACAO].dbo.[MS_UNIT].[SYMBOL] = CASE	WHEN LEFT([WBCCAD].[dbo].[PRDORC].[PRODUTO], 3) = 'ALP' THEN 'kg'
																		WHEN LEFT([WBCCAD].[dbo].[PRDORC].[PRODUTO], 3) = 'TPO' THEN 'kg'
																		ELSE 'un' END
						FOR XML PATH(''), TYPE).value('.', 'varchar(max)') + '}'
					  + ',"width": { "value": '  + CONVERT(VARCHAR(50), (CASE WHEN CHARINDEX('#', LTRIM(RTRIM(ISNULL([WBCCAD].[dbo].[INTEGRACAO_ORCPRD].[PRDCOD], '')))) > 0 THEN CAST(PARSENAME(REPLACE([WBCCAD].[dbo].[INTEGRACAO_ORCPRD].[PRDCOD], '#', '.'), 1) AS FLOAT) ELSE ISNULL([WBCCAD].[dbo].[PRDORC].[Comprimento], 0) END), 128) + ', "unit":' +
					  (SELECT TOP 1
							'{"id":' + CAST([INTEGRACAO].dbo.[MS_UNIT].[ID] AS NVARCHAR) 
							+ ',"name":"' + LTRIM(RTRIM([INTEGRACAO].dbo.[MS_UNIT].[NAME])) + '"'
							+ ',"symbol":"' + LTRIM(RTRIM([INTEGRACAO].dbo.[MS_UNIT].[SYMBOL])) + '"'
							+ '}'
						FROM 
							[INTEGRACAO].dbo.[MS_UNIT]
						WHERE 
							[INTEGRACAO].dbo.[MS_UNIT].[SYMBOL] = 'mm'
						FOR XML PATH(''), TYPE).value('.', 'varchar(max)') + '}'
					  + ',"height": { "value": '  + CONVERT(VARCHAR(50), (CASE WHEN CHARINDEX('#', LTRIM(RTRIM(ISNULL([WBCCAD].[dbo].[INTEGRACAO_ORCPRD].[PRDCOD], '')))) > 0 THEN CAST(PARSENAME(REPLACE([WBCCAD].[dbo].[INTEGRACAO_ORCPRD].[PRDCOD], '#', '.'), 2) AS FLOAT) ELSE ISNULL([WBCCAD].[dbo].[PRDORC].[Altura], 0) END), 128) + ', "unit":' +
					  (SELECT TOP 1
							'{"id":' + CAST([INTEGRACAO].dbo.[MS_UNIT].[ID] AS NVARCHAR) 
							+ ',"name":"' + LTRIM(RTRIM([INTEGRACAO].dbo.[MS_UNIT].[NAME])) + '"'
							+ ',"symbol":"' + LTRIM(RTRIM([INTEGRACAO].dbo.[MS_UNIT].[SYMBOL])) + '"'
							+ '}'
						FROM 
							[INTEGRACAO].dbo.[MS_UNIT]
						WHERE 
							[INTEGRACAO].dbo.[MS_UNIT].[SYMBOL] = 'mm'
						FOR XML PATH(''), TYPE).value('.', 'varchar(max)') + '}'
					  + ',"length": { "value": '  + CONVERT(VARCHAR(50), (CASE WHEN CHARINDEX('#', LTRIM(RTRIM(ISNULL([WBCCAD].[dbo].[INTEGRACAO_ORCPRD].[PRDCOD], '')))) > 0 THEN CAST(PARSENAME(REPLACE([WBCCAD].[dbo].[INTEGRACAO_ORCPRD].[PRDCOD], '#', '.'), 3) AS FLOAT) ELSE ISNULL([WBCCAD].[dbo].[PRDORC].[Largura], 0) END), 128) + ', "unit":' +
					  (SELECT TOP 1
							'{"id":' + CAST([INTEGRACAO].dbo.[MS_UNIT].[ID] AS NVARCHAR) 
							+ ',"name":"' + LTRIM(RTRIM([INTEGRACAO].dbo.[MS_UNIT].[NAME])) + '"'
							+ ',"symbol":"' + LTRIM(RTRIM([INTEGRACAO].dbo.[MS_UNIT].[SYMBOL])) + '"'
							+ '}'
						FROM 
							[INTEGRACAO].dbo.[MS_UNIT]
						WHERE 
							[INTEGRACAO].dbo.[MS_UNIT].[SYMBOL] = 'mm'
						FOR XML PATH(''), TYPE).value('.', 'varchar(max)') + '}'
					  --,CAST(ISNULL([ORCTOT], 0) AS DECIMAL(10,3)) AS value,
					  + ',"weight": { "value": ' + CONVERT(VARCHAR(50), SUM(ISNULL([WBCCAD].[dbo].[INTEGRACAO_ORCPRD].[ORCPES], 0)), 128) + ', "unit":' +
					  (SELECT TOP 1
							'{"id":' + CAST([INTEGRACAO].dbo.[MS_UNIT].[ID] AS NVARCHAR) 
							+ ',"name":"' + LTRIM(RTRIM([INTEGRACAO].dbo.[MS_UNIT].[NAME])) + '"'
							+ ',"symbol":"' + LTRIM(RTRIM([INTEGRACAO].dbo.[MS_UNIT].[SYMBOL])) + '"'
							+ '}'
						FROM 
							[INTEGRACAO].dbo.[MS_UNIT]
						WHERE 
							[INTEGRACAO].dbo.[MS_UNIT].[SYMBOL] = 'kg'
						FOR XML PATH(''), TYPE).value('.', 'varchar(max)') + '}'
					  +'}'
				  FROM
					[WBCCAD].[dbo].[PRDORC]
				  WHERE 
  					LTRIM(RTRIM([WBCCAD].[dbo].[PRDORC].[PRODUTO])) = CASE WHEN CHARINDEX('#', LTRIM(RTRIM(ISNULL([WBCCAD].[dbo].[INTEGRACAO_ORCPRD].[PRDCOD], '')))) > 0 THEN LEFT([WBCCAD].[dbo].[INTEGRACAO_ORCPRD].[PRDCOD], CHARINDEX('#', LTRIM(RTRIM(ISNULL([WBCCAD].[dbo].[INTEGRACAO_ORCPRD].[PRDCOD], '')))) -1) ELSE LTRIM(RTRIM([WBCCAD].[dbo].[INTEGRACAO_ORCPRD].[PRDCOD])) END
				  FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
			  FROM 
				[WBCCAD].[dbo].[INTEGRACAO_ORCPRD]
				--[WBCCAD].[dbo].[ORCMAT]				
			  WHERE 
				[WBCCAD].[dbo].[INTEGRACAO_ORCPRD].[ORCNUM] = [WBCCAD].[dbo].[INTEGRACAO_ORCCAB].[ORCNUM] AND
				[WBCCAD].[dbo].[INTEGRACAO_ORCPRD].[ORCITM] = ISNULL([WBCCAD].[dbo].[INTEGRACAO_ORCITM].[ORCITM], 0)
				--[WBCCAD].[dbo].[ORCMAT].[numeroOrcamento] = [WBCCAD].[dbo].[INTEGRACAO_ORCITM].ORCNUM AND
				--[WBCCAD].[dbo].[ORCMAT].
			  GROUP BY [WBCCAD].[dbo].[INTEGRACAO_ORCPRD].[PRDCOD]
			  FOR XML PATH(''), TYPE).value('.', 'varchar(max)'), 1, 1, '') + ']' + '}'
		FROM 
			[WBCCAD].[dbo].[INTEGRACAO_ORCCAB] WITH (NOLOCK) INNER JOIN
			[WBCCAD].[dbo].[INTEGRACAO_ORCPRD] WITH (NOLOCK) ON [WBCCAD].[dbo].[INTEGRACAO_ORCCAB].[ORCNUM] = [WBCCAD].[dbo].[INTEGRACAO_ORCPRD].[ORCNUM] LEFT OUTER JOIN
			[WBCCAD].[dbo].[INTEGRACAO_ORCITM] WITH (NOLOCK) ON [WBCCAD].[dbo].[INTEGRACAO_ORCPRD].[ORCITM] = [WBCCAD].[dbo].[INTEGRACAO_ORCITM].[ORCITM] AND
			[WBCCAD].[dbo].[INTEGRACAO_ORCCAB].[ORCNUM] = [WBCCAD].[dbo].[INTEGRACAO_ORCITM].[ORCNUM] 
		WHERE
			WBCCAD.dbo.INTEGRACAO_ORCCAB.ORCNUM = GPIMAC_Altamira.dbo.LPV.LPWBCCADORCNUM
		FOR XML PATH(''), TYPE).value('.', 'varchar(max)'), 1, 1, '') + ']' + '}'
	FROM         
		GPIMAC_Altamira.dbo.LPV WITH (NOLOCK) INNER JOIN
		GPIMAC_Altamira.dbo.CACLI WITH (NOLOCK) ON GPIMAC_Altamira.dbo.CACLI.CCCGC = GPIMAC_Altamira.dbo.LPV.CCCGC INNER JOIN
		GPIMAC_Altamira.dbo.CAREP WITH (NOLOCK) ON GPIMAC_Altamira.dbo.CAREP.CVCOD = GPIMAC_Altamira.dbo.LPV.LPVEN INNER JOIN
		GPIMAC_Altamira.dbo.CAACAB WITH (NOLOCK) ON GPIMAC_Altamira.dbo.CAACAB.CAC0COD = LPV.CAC0COD
		 /*INNER JOIN
		WBCCAD.dbo.INTEGRACAO_ORCCAB WITH (NOLOCK) INNER JOIN
		WBCCAD.dbo.INTEGRACAO_ORCITM WITH (NOLOCK) ON WBCCAD.dbo.INTEGRACAO_ORCCAB.ORCNUM = WBCCAD.dbo.INTEGRACAO_ORCITM.ORCNUM INNER JOIN
		WBCCAD.dbo.INTEGRACAO_ORCPRD WITH (NOLOCK) ON WBCCAD.dbo.INTEGRACAO_ORCITM.ORCNUM = WBCCAD.dbo.INTEGRACAO_ORCPRD.ORCNUM ON 
		GPIMAC_Altamira.dbo.LPV.LPWBCCADORCNUM = WBCCAD.dbo.INTEGRACAO_ORCCAB.ORCNUM*/
	WHERE     
		(GPIMAC_Altamira.dbo.LPV.LPPED = @order)
	FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 1, '') AS 'order')
 
END

GO
/****** Object:  Table [dbo].[LPV]    Script Date: 21/09/2015 12:03:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LPV](
	[LPPED] [int] NOT NULL
) ON [PRIMARY]

GO
USE [master]
GO
ALTER DATABASE [SourceDB] SET  READ_WRITE 
GO
