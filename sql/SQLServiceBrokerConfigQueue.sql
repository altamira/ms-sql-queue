IF EXISTS (SELECT * FROM sys.databases WHERE name = 'SourceDB' AND is_broker_enabled = 0)
BEGIN
    ALTER DATABASE [SourceDB] SET NEW_BROKER WITH ROLLBACK IMMEDIATE
END
GO

ALTER MESSAGE TYPE [TrackingRequest]
    --VALIDATION = WELL_FORMED_XML
	VALIDATION = NONE  
GO
 
CREATE MESSAGE TYPE [TrackingResponse]
    VALIDATION = NONE    
GO

CREATE CONTRACT [TrackingContract] (
    [TrackingRequest]   SENT BY INITIATOR, 
    [TrackingResponse]  SENT BY TARGET
    )
GO

CREATE QUEUE [TrackingRequestQueue]
    WITH
        STATUS = ON,
        RETENTION = OFF
    ON [PRIMARY]
GO

CREATE QUEUE [TrackingResponseQueue]
    WITH 
        STATUS = ON,
        RETENTION = OFF
    ON [PRIMARY]
GO

CREATE QUEUE [TrackingNotificationQueue]
    WITH
        STATUS = ON,
        RETENTION = OFF 
    ON [PRIMARY]
GO

CREATE SERVICE [TrackingInitiatorService]
    ON QUEUE [TrackingResponseQueue] ([TrackingContract])
GO

CREATE SERVICE [TrackingTargetService]
    ON QUEUE [TrackingRequestQueue] ([TrackingContract])
GO

CREATE SERVICE [TrackingNotificationService]
    ON QUEUE [TrackingNotificationQueue] ([http://schemas.microsoft.com/SQL/Notifications/PostEventNotification])
GO

CREATE EVENT NOTIFICATION [TrackingEventNotification]
    ON QUEUE [TrackingRequestQueue]
    FOR QUEUE_ACTIVATION
    TO SERVICE 'TrackingNotificationService', 'current database'
GO

CREATE TRIGGER [dbo].[trg_INS_Products]
    ON [dbo].[Products]
    AFTER INSERT
AS
BEGIN

    SET NOCOUNT ON

    DECLARE @productId      AS INT
    DECLARE @trackingType   AS NVARCHAR(8)
    DECLARE @inserted       AS XML
    DECLARE @deleted        AS XML

    SELECT  @productId      = ProductId FROM inserted
    SET     @trackingType   = 'INSERT'
    SET     @inserted       = (SELECT * FROM inserted FOR XML PATH(''), ROOT('Row'), ELEMENTS)
    SET     @deleted        = NULL

    EXECUTE [dbo].[usp_SendTrackingRequest] @productId, @trackingType, @inserted, @deleted

END
GO

CREATE TRIGGER [dbo].[trg_UPD_Products]
    ON [dbo].[Products]
    AFTER UPDATE
AS
BEGIN

    SET NOCOUNT ON

    DECLARE @productId      AS INT
    DECLARE @trackingType   AS NVARCHAR(8)
    DECLARE @inserted       AS XML
    DECLARE @deleted        AS XML

    SELECT  @productId      = ProductId FROM inserted
    SET     @trackingType   = 'UPDATE'
    SET     @inserted       = (SELECT * FROM inserted FOR XML PATH(''), ROOT('Row'), ELEMENTS)
    SET     @deleted        = (SELECT * FROM deleted FOR XML PATH(''), ROOT('Row'), ELEMENTS)

    EXECUTE [dbo].[usp_SendTrackingRequest] @productId, @trackingType, @inserted, @deleted

END
GO

CREATE TRIGGER [dbo].[trg_DEL_Products]
    ON [dbo].[Products]
    AFTER DELETE
AS
BEGIN

    SET NOCOUNT ON

    DECLARE @productId      AS INT
    DECLARE @trackingType   AS NVARCHAR(8)
    DECLARE @inserted       AS XML
    DECLARE @deleted        AS XML

    SELECT  @productId      = ProductId FROM deleted
    SET     @trackingType   = 'DELETE'
    SET     @inserted       = NULL
    SET     @deleted        = (SELECT * FROM deleted FOR XML PATH(''), ROOT('Row'), ELEMENTS)

    EXECUTE [dbo].[usp_SendTrackingRequest] @productId, @trackingType, @inserted, @deleted

END
GO


