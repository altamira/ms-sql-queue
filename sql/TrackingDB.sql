USE [master]
GO
/****** Object:  Database [TrackingDB]    Script Date: 21/09/2015 12:04:14 ******/
CREATE DATABASE [TrackingDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'TrackingDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\TrackingDB.mdf' , SIZE = 4160KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'TrackingDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\TrackingDB_log.ldf' , SIZE = 1040KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [TrackingDB] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [TrackingDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [TrackingDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [TrackingDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [TrackingDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [TrackingDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [TrackingDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [TrackingDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [TrackingDB] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [TrackingDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [TrackingDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [TrackingDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [TrackingDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [TrackingDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [TrackingDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [TrackingDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [TrackingDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [TrackingDB] SET  ENABLE_BROKER 
GO
ALTER DATABASE [TrackingDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [TrackingDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [TrackingDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [TrackingDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [TrackingDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [TrackingDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [TrackingDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [TrackingDB] SET RECOVERY FULL 
GO
ALTER DATABASE [TrackingDB] SET  MULTI_USER 
GO
ALTER DATABASE [TrackingDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [TrackingDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [TrackingDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [TrackingDB] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'TrackingDB', N'ON'
GO
USE [TrackingDB]
GO
/****** Object:  User [NT SERVICE\SSBExternalActivator]    Script Date: 21/09/2015 12:04:15 ******/
CREATE USER [NT SERVICE\SSBExternalActivator] FOR LOGIN [NT SERVICE\SSBExternalActivator] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [NT SERVICE\SSBExternalActivator]
GO
/****** Object:  StoredProcedure [dbo].[usp_SendTrackingRequest]    Script Date: 21/09/2015 12:04:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[usp_SendTrackingRequest]
    @productId      AS INT,
    @trackingType   AS NVARCHAR(8),
    @inserted       AS XML,
    @deleted        AS XML
AS
BEGIN
 
    SET NOCOUNT ON;
 
    DECLARE @data    AS XML
 
    SET @data = (SELECT
                    @productId              AS ProductId,
                    @trackingType           AS TrackingType,
                    COALESCE(@inserted, '') AS Inserted,
                    COALESCE(@deleted, '')  AS Deleted
                 FOR XML PATH(''), ROOT('Changes'), ELEMENTS)
 
    DECLARE @handle    AS UNIQUEIDENTIFIER
 
    BEGIN DIALOG CONVERSATION @handle  
        FROM
            SERVICE [TrackingInitiatorService]
        TO
            SERVICE 'TrackingTargetService'
        ON
            CONTRACT [TrackingContract]
        WITH
            ENCRYPTION = OFF;
 
    SEND
        ON CONVERSATION @handle
        MESSAGE TYPE [TrackingRequest] (@data)
 
END

GO
/****** Object:  Table [dbo].[TrackingLogs]    Script Date: 21/09/2015 12:04:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TrackingLogs](
	[TrackingLogId] [int] IDENTITY(1,1) NOT NULL,
	[Source] [nvarchar](50) NOT NULL,
	[Field] [nvarchar](50) NOT NULL,
	[TrackingType] [nvarchar](8) NOT NULL,
	[OldValue] [nvarchar](max) NULL,
	[NewValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_TrackingLogs] PRIMARY KEY CLUSTERED 
(
	[TrackingLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
USE [master]
GO
ALTER DATABASE [TrackingDB] SET  READ_WRITE 
GO
